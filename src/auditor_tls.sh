#!/usr/bin/env bash
set -euo pipefail

# -----------------------
# Configuración inicial
# -----------------------
CHECK_URL="${CHECK_URL:-https://www.google.com}"
# dirname me dirige a la carpeta donde se encuentra "auditor.sh"
# y lo guarda ../out en la carpeta out fuera de src.
OUTPUT_DIR="$(dirname "$0")/../out" 
OUTPUT_FILE="$OUTPUT_DIR/result_$(date +%Y%m%d_%H%M%S).txt"

# -----------------------
# Manejo de errores global
# -----------------------
trap 'echo "Error inesperado en la línea $LINENO" | tee -a "$OUTPUT_FILE"' ERR

# -----------------------
# Funciones
# -----------------------
log() {
    echo "$1" | tee -a "$OUTPUT_FILE"
}

check_http() {
    local url=$1
    local code
    code=$(curl -s -o /dev/null -w "%{http_code}" "$url")
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
    # Extrae el host de una URL
    echo "$1" | awk -F/ '{print $3}'
}

# -----------------------
# Ejecución principal
# -----------------------
log "==== Proyecto 2 - Sprint 1 ===="
log "Verificando conectividad HTTP con: $CHECK_URL"

host=$(extract_host "$CHECK_URL")

check_http "$CHECK_URL"
http_status=$?

check_dns "$host"
dns_status=$?

# -----------------------
# Código de salida final
# -----------------------
if [ "$http_status" -ne 0 ]; then
    log "Resultado final: HTTP falló con código $http_status (≠0=falla)"
    exit "$http_status"
elif [ "$dns_status" -ne 0 ]; then
    log "Resultado final: DNS falló con código $dns_status (≠0=falla)"
    exit "$dns_status"
else
    log "Resultado final: Todo OK (0=ok)"
    exit 0
fi