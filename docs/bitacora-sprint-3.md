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
