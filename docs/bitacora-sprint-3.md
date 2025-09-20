# Bitácora – Sprint 3: Pack & Test

## Objetivo
Cerrar el ciclo de automatización con empaquetado reproducible y pruebas automáticas.

## Evidencias

### 1) `make tools`
**Descripcion:** Verificacion de dependencias
==> Verificando dependencias...
==> Verificando bats para pruebas...
bats OK
==> Listo.
Todas las dependencias están disponibles.

### 2) `make build`
**Descripcion:** creacion de directorios
==> Preparando directorios...
Build completado.

### 3) `make test`
**Descripcion:** test falla si bats falla
==> Verificando dependencias...
==> Verificando bats para pruebas...
bats OK
==> Listo.
Todas las dependencias están disponibles.
==> Preparando directorios...
Build completado.
==> Ejecutando pruebas con bats en 'tests'
auditor_tls.bats
 ✗ Ejecución correcta con https://www.google.com
   (in test file tests/auditor_tls.bats, line 5)
     `[ "$status" -eq 0 ]' failed
 ✓ Falla si no se define CHECK_URL

2 tests, 1 failure

make: *** [makefile:47: test] Error 1

### 4) `make pack RELEASE=v1.0.0 SOURCE_DATE_EPOCH=0`
==> Preparando directorios...
Build completado.
==> Empaquetando versión 'v1.0.0' de forma reproducible...
Output: dist/Pc1-Grupo2-Proyecto2-v1.0.0.tar.gz
Paquete creado en dist/Pc1-Grupo2-Proyecto2-v1.0.0.tar.gz

## Conclusiones
- `make pack` genera un archivo en `dist/` con `Nombre del proyecto`-`version` y reproducible.
- `make test` ejecuta los bats y falla si algunno falla.
- Se documento el uso en `docs/readme.md`



### **Procesamiento y filtrado de resultados TLS (`sort`, `uniq`, `tr`)**

Se actualizó el script para incluir una nueva función: **`generar_reporte_tls`**, cuyo objetivo es **generar un reporte legible de configuraciones TLS auditadas**.  

Este reporte se guarda automáticamente en la carpeta `out/` con un nombre que incluye la **fecha y hora de ejecución**.  

#### 🔹 Criterios de aceptación implementados:
- **Uso de `sort` y `uniq`**:  
  Se aplican sobre la salida de `ss` y `getent hosts` para **eliminar duplicados y ordenar resultados**, evitando confusión en el reporte.  

- **Uso de `tr`**:  
  Convierte todo a **minúsculas**, de modo que los datos tengan un formato uniforme y más fácil de comparar.  

- **Reporte final**:  
  Guardado en `out/reporte-TLS-<fecha>.txt`, garantizando trazabilidad de cada ejecución.  

####  Ejemplo de reporte generado:

```
==== REPORTE TLS ====
Host: www.google.com
Fecha: Fri Sep 19 20:11:59 CDT 2025

>> Conexiones SS (ordenadas y únicas)
netid state     recv-q send-q  local address:port    peer address:portprocess
tcp   listen    0      1000   10.255.255.254:53           0.0.0.0:*          
tcp   listen    0      4096             [::]:9000            [::]:*          
tcp   listen    0      4096             [::]:9870            [::]:*          
tcp   listen    0      4096          0.0.0.0:9000         0.0.0.0:*          
tcp   listen    0      4096          0.0.0.0:9870         0.0.0.0:*          
tcp   listen    0      4096        127.0.0.1:43129        0.0.0.0:*          
tcp   listen    0      4096       127.0.0.54:53           0.0.0.0:*          
tcp   listen    0      4096    127.0.0.53%lo:53           0.0.0.0:*          
tcp   time-wait 0      0       172.22.75.112:58514 172.217.28.164:443        
tcp   time-wait 0      0       172.22.75.112:58530 172.217.28.164:443        
udp   unconn    0      0               [::1]:323             [::]:*          
udp   unconn    0      0           127.0.0.1:323          0.0.0.0:*          
udp   unconn    0      0          127.0.0.54:53           0.0.0.0:*          
udp   unconn    0      0       127.0.0.53%lo:53           0.0.0.0:*          
udp   unconn    0      0      10.255.255.254:53           0.0.0.0:*          

>> Resolución DNS
172.217.28.164  www.google.com
```


## Issue 3: Sprint 3
**Objetivo** Cerrar ciclo de automatización:
- Empaquetado reproducible (`make pack`)
- Pruebas automáticas (`make test`)
- Idempotencia y contrato de salidas (`make run` consecutivo)

## Ejemplo de ejecucion (idempotencia)
### 1) Primera ejecucion
$ CHECK_SS=0 ENABLE_SLEEP=0 make run
luis@LAPTOP-LC:/mnt/c/Users/Luis/Documents/Pc1-Grupo2-Proyecto2$ CHECK_SS=0 ENABLE_SLEEP=0 make run
==> Verificando dependencias...
==> Verificando bats para pruebas...
bats OK
==> Listo.
Todas las dependencias están disponibles.
==> Preparando directorios...
Build completado.
==> Ejecutando src/auditor_tls.sh
SANDBOX creada: src/../out/auditor_sbx.JYDc6U (umask=027)
Permisos sandbox: 777 src/../out/auditor_sbx.JYDc6U ; archivo: 777 src/../out/auditor_sbx.JYDc6U/probe.txt
==== Proyecto 2 - Sprint 1 ====
Verificando conectividad HTTP con: https://www.google.com
HTTP 200
Conexión HTTP exitosa a https://www.google.com (0=ok)
DNS resuelto correctamente. (0=ok)
ss: SKIP (CHECK_SS=0)
nc: Puerto 443 accesible en www.google.com (TCP handshake OK) (0=ok)
Script en pausa 60s para pruebas de señales (puedes usar kill -TERM o Ctrl+C)
Reporte TLS generado/actualizado: src/../out/reporte-TLS-www.google.com.txt
Resultado final: Todo OK (0=ok)
SANDBOX eliminada: src/../out/auditor_sbx.JYDc6U

$ stat -c '%Y %n' out/auditor_tls.log
1758337203 out/auditor_tls.log

$ sha256sum out/auditor_tls.log
47f0f2aeb2c6c7649a0ff218a16d037eb28a6595143c30abb19ccc3ddd54f610  out/auditor_tls.log

### 2) Segunda ejecucion
Mismos valores:
luis@LAPTOP-LC:/mnt/c/Users/Luis/Documents/Pc1-Grupo2-Proyecto2$ CHECK_SS=0 ENABLE_SLEEP=0 make run
==> Verificando dependencias...
==> Verificando bats para pruebas...
bats OK
==> Listo.
Todas las dependencias están disponibles.
==> Preparando directorios...
Build completado.
==> Ejecutando src/auditor_tls.sh
SANDBOX creada: src/../out/auditor_sbx.zOBDRo (umask=027)
Permisos sandbox: 777 src/../out/auditor_sbx.zOBDRo ; archivo: 777 src/../out/auditor_sbx.zOBDRo/probe.txt
==== Proyecto 2 - Sprint 1 ====
Verificando conectividad HTTP con: https://www.google.com
HTTP 200
Conexión HTTP exitosa a https://www.google.com (0=ok)
DNS resuelto correctamente. (0=ok)
ss: SKIP (CHECK_SS=0)
nc: Puerto 443 accesible en www.google.com (TCP handshake OK) (0=ok)
Script en pausa 60s para pruebas de señales (puedes usar kill -TERM o Ctrl+C)
Reporte TLS generado/actualizado: src/../out/reporte-TLS-www.google.com.txt
Resultado final: Todo OK (0=ok)
SANDBOX eliminada: src/../out/auditor_sbx.zOBDRo

### 3) Empaquetado reproducible
==> Preparando directorios...
Build completado.
==> Empaquetando versión 'v1.0.0' de forma reproducible...
Output: dist/Pc1-Grupo2-Proyecto2-v1.0.0.tar.gz
Paquete creado en dist/Pc1-Grupo2-Proyecto2-v1.0.0.tar.gz