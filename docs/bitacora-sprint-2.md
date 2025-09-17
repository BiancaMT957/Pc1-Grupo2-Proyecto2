# Bitacora sprint 2
## **Objetivo:** Comprobar el estado de los puertos de los servidores auditados.

## 1. Error al ejecutar en Git Bash
- Al ejecutar el archivo `auditor_tls.sh` en Git Bash saltaba el siguiente error: "Error: falta la herramienta 'getent'".
- Esto sucede debido a que Git Bash no incluye todas las utilidades de Linux.
- **Solucion:** Ejecutamos en WSL, donde `getnet` si esta disponible.

## 2. Error con `bash\r` 
- Se presento el siguiente error: "/usr/bin/env: ‘bash\r’: No such file or directory"
- El archivo se genero en Windows por lo que los saltos de linea eran (CRLF).
- **Solucion:** En VS Code donde generamos el archivo, buscamos la opcion de convertir CRLF en LS, y guardamos el archivo.

## 3. Ejemplos de log's de salida:
- Asignamos el valor por defecto 443 (HTTPS) al puerto objetivo:
==== Proyecto 2 - Sprint 1 ====
Verificando conectividad HTTP con: https://www.google.com
HTTP 200
Conexión HTTP exitosa a https://www.google.com (0=ok)
DNS resuelto correctamente. (0=ok)
ss: No se encontraron sockets con puerto 443 y estado LISTEN (≠0=falla)
nc: Puerto 443 accesible en www.google.com (TCP handshake OK) (0=ok)
Resultado final: ss detectó ausencia de sockets esperados (código 5)

- Asignamos el valor de 44444 al puerto objetivo:
==== Proyecto 2 - Sprint 1 ====
Verificando conectividad HTTP con: https://www.google.com
HTTP 200
Conexión HTTP exitosa a https://www.google.com (0=ok)
DNS resuelto correctamente. (0=ok)
ss: No se encontraron sockets con puerto 44444 y estado LISTEN (≠0=falla)
nc: Puerto 44444 NO accesible en www.google.com (timeout/conn refused) (≠0=falla)
Resultado final: ss detectó ausencia de sockets esperados (código 5)
