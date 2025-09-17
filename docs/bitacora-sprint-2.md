# Bitacora sprint 2 
##  Comprobar el estado de los puertos de los servidores auditados.

## 1. Error al ejecutar en Git Bash
- Al ejecutar el `auditor_tls.sh` en Git Bash saltaba el siguiente error: "Error: falta la herramienta 'getent'".
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



## Simular politicas de permiso y guia para consultar logs

## 1. Creacion de la funcion perm_sandbox_setup
- Se crea la funcion con el proposito de aplicar una umask configurable (027 por defecto) y analizar los permisos que reda a los nuevos directorios y archivos que se crearan.
- Crea un directorio temporal `SANDBOX_DIR` y un archivo `probe.txt` con el proposito de evaluar sus permisos. Luego estos seran borrados, pero quedara registro en el journal.
- Comando clave `stat -c %a %n` nos muestra los permisos con codigo octal y el nombre del directorio/archivo evaluado.
- Se crea la funcion complemetaria `perm_sandbox_teardown` que nos ayudara a borrar el directorio temporal.

## 2. Registro de log's en Journal
- Actualizamos la funcion `log` que ahora imprime el valor de salida en: consola, archivo de salida y en Journal. Comando clave `logger -t auditor_tls` registra los logs en el script.

## 3. Guia rapida para consultas en el Journal
- Los mensajes enviados al Journal pueden revisarse con `journalctl -t auditor_tls` para ver todos los registros, o `journalctl -t auditor_tls --since "2 min ago"` para ver los registros de los ultimos 2 minutos. 
- Tambien podemos hacerlo la revision por lineas `journalctl -t auditor_tls -n 20` que nos imprime las ultimas 20 lineas, o `journalctl -t auditor_tls -n 20 --no-pager` para los registros esten en un solo bloque y no en paginas.


