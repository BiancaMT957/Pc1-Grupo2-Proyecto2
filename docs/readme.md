### Variables de entorno (12-Factor App – Config III)

| **Variable de entorno** | **Ubicación en el script** | **Propósito** |
|-------------------------|---------------------------|--------------|
| `CHECK_URL`            | En la parte inicial: `CHECK_URL="${CHECK_URL:-https://www.google.com}"` | Define el endpoint a auditar vía HTTP. Si no se especifica, usa por defecto `https://www.google.com`. |
| `OUTPUT_DIR`           | `OUTPUT_DIR="$(dirname "$0")/../out"` | Indica el directorio donde se almacenan los resultados de la ejecución. |
| `OUTPUT_FILE`          | `OUTPUT_FILE="$OUTPUT_DIR/result_$(date +%Y%m%d_%H%M%S).txt"` | Ruta completa del archivo de log generado en cada ejecución, con timestamp. |
