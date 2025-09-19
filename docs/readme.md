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
