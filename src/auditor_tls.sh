#!/usr/bin/env bash
set -euo pipefail

# -----------------------
# Configuración inicial
# -----------------------
CHECK_URL="${CHECK_URL:-https://www.google.com}"
OUTPUT_DIR="$(dirname "$0")/../out"
# Idempotencia: un nombre fijo y estable
OUTPUT_BASENAME="${OUTPUT_BASENAME:-auditor_tls}"
OUTPUT_FILE="$OUTPUT_DIR/${OUTPUT_BASENAME}.log"
# Buffer temporal
TMP_FILE="$(mktemp -p "$OUTPUT_DIR" "${OUTPUT_BASENAME}.tmp.XXXXXX")"
# Integridad
OUTPUT_SHA256="$OUTPUT_FILE.sha256"
# Controlar chequeo de sockets en CI (idempotencia de exits)
CHECK_SS="${CHECK_SS:-1}"                  # 1=fatal según lógica; 0=no fatal/skip
# Evitar “cuelgues” en CI
ENABLE_SLEEP="${ENABLE_SLEEP:-0}"
SLEEP_SECONDS="${SLEEP_SECONDS:-60}"

TARGET_PORT="${TARGET_PORT:-443}"   # Por defecto HTTPS (443). Sobreescribe TARGET_PORT=####

# Nuevos: politica de permisos
PERM_UMASK="${PERM_UMASK:-027}"                    # umask documentada (p. ej. 027: dir 750, file 640)
PERM_SANDBOX_PARENT="${PERM_SANDBOX_PARENT:-"$OUTPUT_DIR"}" # dónde crear sandbox temporal

# Journal logging
JOURNAL_TAG="${JOURNAL_TAG:-auditor_tls}"  # tag de logger: journalctl -t auditor_tls
REQUIRE_LOGGER="${REQUIRE_LOGGER:-0}"      # 1=exigir logger; 0=opcional

# -----------------------
# Funciones log (implementa a Journal) y require
# -----------------------
log() {
    local msg="$*"                  
    echo "$msg"                     
    echo "$msg" >> "$TMP_FILE"   
    if command -v logger >/dev/null 2>&1; then
        logger -t "$JOURNAL_TAG" -- "$msg"
    fi
}

require() {  
  command -v "$1" >/dev/null 2>&1 || { log "Error: falta la herramienta '$1'"; exit 99; }
}

# -----------------------
# Funciones HTTP / DNS
# -----------------------
check_http() {
    local url=$1
    local code
    # Timeouts para evitar bloqueos
    code=$(curl -sS --connect-timeout 3 --max-time 5 -o /dev/null -w "%{http_code}" "$url" || true)
    log "HTTP $code"
    case "$code" in
        200)
            log "Conexión HTTP exitosa a $url (0=ok)"
            return 0
            ;;
        400)
            log "Error: el servidor respondió con HTTP 400 (Bad Request) (≠0=falla)"
            return 4
            ;;
        *)
            log "Fallo en la conexión HTTP a $url (≠0=falla)"
            return 1
            ;;
    esac
}

check_dns() {
    local host=$1
    if getent hosts "$host" > /dev/null 2>&1; then
        log "DNS resuelto correctamente. (0=ok)"
        return 0
    else
        log "Fallo en la resolución DNS. (≠0=falla)"
        return 2
    fi
}

extract_host() {
    echo "$1" | awk -F/ '{print $3}'
}

# -----------------------
# Funciones de puertos con ss y nc
# -----------------------
check_port_ss() {
    local port="$1"
    local state="${2:-LISTEN}"

    if ss -tuna state "$state" "( sport = :$port or dport = :$port )" 2>/dev/null | grep -q ":"; then
        log "ss: Se encontraron sockets con puerto $port y estado $state (0=ok)"
        return 0
    else
        log "ss: No se encontraron sockets con puerto $port y estado $state (≠0=falla)"
        return 5
    fi
}

check_port_nc() {
    local host="$1"
    local port="$2"
    local timeout="${NC_TIMEOUT:-3}"

    if nc -z -v -w "$timeout" "$host" "$port" >/dev/null 2>&1; then
        log "nc: Puerto $port accesible en $host (TCP handshake OK) (0=ok)"
        return 0
    else
        log "nc: Puerto $port NO accesible en $host (timeout/conn refused) (≠0=falla)"
        return 6
    fi
}


generar_reporte_tls() {
    local host="$1"
    local base="reporte-TLS-${host}.txt"             # nombre determinístico
    local final="$OUTPUT_DIR/$base"
    local tmp="$(mktemp -p "$OUTPUT_DIR" "${base}.tmp.XXXXXX")"

    {
        echo "==== REPORTE TLS ===="
        echo "Host: $host"
        echo "Generado por auditor_tls.sh (determinístico)"
        echo ""
        echo ">> Conexiones SS (ordenadas y únicas)"
        ss -tuna | sort | uniq | tr 'A-Z' 'a-z'
        echo ""
        echo ">> Resolución DNS"
        getent hosts "$host" | sort | uniq | tr 'A-Z' 'a-z'
    } > "$tmp"

    # Commit idempotente (solo si cambia)
    if [[ -f "$final" ]]; then
        if diff -q "$final" "$tmp" >/dev/null 2>&1; then
            rm -f -- "$tmp"
            log "Reporte TLS sin cambios: $final"
            return 0
        fi
    fi

    mv -f -- "$tmp" "$final"
    if command -v sha256sum >/dev/null 2>&1; then
        sha256sum "$final" > "$final.sha256"
    fi
    log "Reporte TLS generado/actualizado: $final"
}


# ------------------------------------------------
# Sandbox de permisos con umask documentado
# ------------------------------------------------
perm_sandbox_setup() {
  local old_umask
  old_umask=$(umask)
  umask "$PERM_UMASK"

  SANDBOX_DIR="$(mktemp -d -p "$PERM_SANDBOX_PARENT" auditor_sbx.XXXXXX)"
  : > "$SANDBOX_DIR/probe.txt"

  local dperm fperm
  dperm="$(stat -c '%a %n' "$SANDBOX_DIR")"
  fperm="$(stat -c '%a %n' "$SANDBOX_DIR/probe.txt")"
  log "SANDBOX creada: $SANDBOX_DIR (umask=$PERM_UMASK)"
  log "Permisos sandbox: $dperm ; archivo: $fperm"

  umask "$old_umask"
}

perm_sandbox_teardown() {
  if [[ -n "${SANDBOX_DIR:-}" && -d "$SANDBOX_DIR" ]]; then
    rm -rf -- "$SANDBOX_DIR"
    log "SANDBOX eliminada: $SANDBOX_DIR"
  fi
}

# -----------------------
# Manejo de errores global
# -----------------------
cleanup() {
  set +e
  log "Recibida señal de interrupción. Limpiando..."
  perm_sandbox_teardown
  if [[ -f "$TMP_FILE" ]]; then
    rm -f -- "$TMP_FILE"
    echo "TMP eliminado: $TMP_FILE" >> /dev/null
  fi
  set -e
  exit 130
}

trap cleanup INT TERM
trap 'perm_sandbox_teardown' EXIT
trap 'log "Error inesperado en la línea $LINENO"; perm_sandbox_teardown' ERR

# -----------------------
# Check para permisos de escritura
# -----------------------
check_write_dir() {
  local dir="$1"
  if [[ ! -d "$dir" ]]; then
    log "Directorio no existe: $dir (≠0=falla)"
    return 7
  fi
  if [[ ! -w "$dir" ]]; then
    log "Permisos insuficientes: no puedo escribir en $dir (≠0=falla)"
    return 8
  fi
  return 0
}

finalize_output() {
  set +e
  if [[ -f "$OUTPUT_FILE" ]]; then
    if command -v sha256sum >/dev/null 2>&1; then
      old_sum="$(sha256sum "$OUTPUT_FILE" 2>/dev/null | awk '{print $1}')"
      new_sum="$(sha256sum "$TMP_FILE"    2>/dev/null | awk '{print $1}')"
      if [[ "$old_sum" = "$new_sum" ]]; then
        rm -f -- "$TMP_FILE"
        return 0
      fi
    else
      if diff -q "$OUTPUT_FILE" "$TMP_FILE" >/dev/null 2>&1; then
        rm -f -- "$TMP_FILE"
        return 0
      fi
    fi
  fi
  mv -f -- "$TMP_FILE" "$OUTPUT_FILE"
  if command -v sha256sum >/dev/null 2>&1; then
    sha256sum "$OUTPUT_FILE" > "$OUTPUT_SHA256"
  fi
  set -e
}

# -----------------------
# Ejecución principal
# -----------------------
require curl
require getent
require ss
require nc
require logger

perm_sandbox_setup

log "==== Proyecto 2 - Sprint 1 ===="
log "Verificando conectividad HTTP con: $CHECK_URL"

host=$(extract_host "$CHECK_URL")

check_http "$CHECK_URL"; http_status=$?
check_dns "$host"; dns_status=$?
check_write_dir "$OUTPUT_DIR"; write_status=$?

# Validaciones de puertos
check_ss_status="LISTEN"
if [[ "$CHECK_SS" = "1" ]]; then
    if check_port_ss "$TARGET_PORT" "${SS_STATE:-$check_ss_status}"; then
        ss_status=0
    else
        ss_status=$?
    fi
else
    log "ss: SKIP (CHECK_SS=0)"
    ss_status=0
fi

if check_port_nc "$host" "$TARGET_PORT"; then
    nc_status=0
else
    nc_status=$?
fi

log "Script en pausa 60s para pruebas de señales (puedes usar kill -TERM o Ctrl+C)"
sleep 1

# -----------------------
# Generar reporte TLS
# -----------------------
generar_reporte_tls "$host"

# -----------------------
# Código de salida final
# -----------------------
if [ "$http_status" -ne 0 ]; then
    log "Resultado final: HTTP falló con código $http_status (≠0=falla)"
    exit_code="$http_status"
elif [ "$dns_status" -ne 0 ]; then
    log "Resultado final: DNS falló con código $dns_status (≠0=falla)"
    exit_code="$dns_status"
elif [ "$ss_status" -ne 0 ]; then
    log "Resultado final: ss detectó ausencia de sockets esperados (código $ss_status)"
    exit_code="$ss_status"
elif [ "$nc_status" -ne 0 ]; then
    log "Resultado final: nc no pudo conectarse a $host:$TARGET_PORT (código $nc_status)"
    exit_code="$nc_status"
elif [ "$write_status" -ne 0 ]; then
    log "Resultado final: permisos insuficientes en $OUTPUT_DIR (código $write_status)"
    exit_code="$write_status"
else
    log "Resultado final: Todo OK (0=ok)"
    exit_code=0
fi
# Consolida el log (idempotente)
finalize_output
exit "$exit_code"