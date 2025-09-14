# Bitácora de Sprint 1

## Ejecuciones y pruebas

- **13/09/2025**  
  - Se creó el script `auditor_tls.sh` para verificar conectividad HTTP y DNS.
  - Prueba inicial con `CHECK_URL=https://www.google.com`:  
    - **HTTP 200**  
    - **DNS resuelto correctamente**
    - **Resultado final: Todo OK (0=ok)**
  - Se agregaron pruebas con URLs que devuelven HTTP 400 y 404:
    - **CHECK_URL=https://httpstat.us/400** → HTTP 400 → Resultado final: HTTP falló con código 4
    - **CHECK_URL=https://www.google.com/404notfound** → HTTP 404 → Resultado final: HTTP falló con código 1
  - Prueba de dominio inexistente:
    - **CHECK_URL=https://no-existe-dominio-123456789.com** → DNS fallido → Resultado final: DNS falló con código 2

## Decisiones tomadas

- El script genera un archivo de salida con timestamp para cada ejecución.
- Los códigos de estado permiten identificar el tipo de error (HTTP, DNS, específico para 400).
- Se usa `trap` para capturar errores inesperados y registrar la línea de fallo en el log.
- Pruebas automatizadas con Bats para robustez: cubren casos de éxito y fallos representativos.
- El target `pack` en Makefile facilita la entrega reproducible y la organización del proyecto.
- La variable `CHECK_URL` es fácilmente parametrizable para pruebas y auditoría.

## Próximos pasos

- Mejorar mensajes de error para otros códigos HTTP si es necesario.
- Documentar posibles mejoras en la bitácora de próximos sprints.