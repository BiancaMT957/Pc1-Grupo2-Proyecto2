### Variables de entorno (12-Factor App – Config III)

| **Variable de entorno** | **Ubicación en el script** | **Propósito** |
|-------------------------|---------------------------|--------------|
| `CHECK_URL`            | En la parte inicial: `CHECK_URL="${CHECK_URL:-https://www.google.com}"` | Define el endpoint a auditar vía HTTP. Si no se especifica, usa por defecto `https://www.google.com`. |
| `OUTPUT_DIR`           | `OUTPUT_DIR="$(dirname "$0")/../out"` | Indica el directorio donde se almacenan los resultados de la ejecución. |
| `OUTPUT_FILE`          | `OUTPUT_FILE="$OUTPUT_DIR/result_$(date +%Y%m%d_%H%M%S).txt"` | Ruta completa del archivo de log generado en cada ejecución, con timestamp. |

# Uso – Sprint 3 (Isuue 2: test y pack)

## Requisitos
- GNU Make
- `tar` y `gzip`
- [`bats`](https://github.com/bats-core/bats-core) para ejecutar pruebas
  - Ubuntu/WSL: `sudo apt-get update && sudo apt-get install -y bats`

## Comandos principales

```bash
# 1) Verifica dependencias
make tools

# 2) Crea las carpetas out/ y dist/
make build

# 3) Ejecuta todas las pruebas Bats (falla si alguna falla)
make test

# 4) Empaqueta de forma reproducible (usa RELEASE para el nombre)
make pack RELEASE=v1.0.0

# Opcional: fijar fecha para reproducibilidad bit-a-bit
make pack RELEASE=v1.0.0 SOURCE_DATE_EPOCH=$(date -u +%s)






# Contrato de Salidas – Proyecto 2 (Sprint 3)

## 1) Propósito
Definir **qué artefactos** produce el sistema, **dónde** se generan, **formato**, **condiciones de idempotencia**, y **cómo validar su integridad y reproducibilidad**.

## 2) Artefactos

### 2.1 Paquete distribuible (reproducible)
- **Ruta**: `dist/<PROJECT>-<RELEASE>.tar.gz`
- **Origen**: `make pack`
- **Formato**: `tar.gz` reproducible
- **Determinismo aplicado**:
  - `tar --sort=name --mtime=@$SOURCE_DATE_EPOCH --owner=0 --group=0 --numeric-owner`
  - compresión sin timestamp (`gzip --no-name` o `GZIP=-n`)
- **Integridad**: validable por `sha256sum` (mismo hash si no cambian fuentes ni `SOURCE_DATE_EPOCH`)
- **No se regenera** si ya existe: **sí**, se **vuelve a crear** (pero con el **mismo hash** si no hay cambios).

**Validación rápida**
```bash
make clean && make build
make pack RELEASE=v1.0.0 SOURCE_DATE_EPOCH=0
sha256sum dist/Pc1-Grupo2-Proyecto2-v1.0.0.tar.gz

# repetir:
make clean && make build
make pack RELEASE=v1.0.0 SOURCE_DATE_EPOCH=0
sha256sum dist/Pc1-Grupo2-Proyecto2-v1.0.0.tar.gz   # => mismo hash