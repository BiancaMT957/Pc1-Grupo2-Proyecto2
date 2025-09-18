# Bitácora Sprint 1

### **Objetivo del sprint**

Implementar una herramienta inicial de **auditoría de conectividad TLS** que valide, de forma automatizada, tanto la disponibilidad HTTP de un endpoint como la correcta resolución DNS del dominio, dejando la base para pruebas automatizadas y un flujo de trabajo reproducible.

---

### **Estructura general**

---

### **Script principal: `src/auditor_tls.sh`**

Este script es el núcleo de la auditoría:

- **Parámetro de entrada:** variable de entorno `CHECK_URL` (por defecto `https://www.google.com`).
- **Salida:** archivo de log en `out/` con la fecha y hora de ejecución.

#### Funcionalidades principales

- **check_http**  
  Usa `curl` para realizar una petición GET y registrar el código HTTP:
  - `200` → conexión exitosa
  - `400` → error de cliente
  - otros → falla genérica
- **check_dns**  
  Usa `getent hosts` para comprobar si el dominio de la URL se resuelve correctamente.
- **extract_host**  
  Extrae el hostname de la URL para la prueba DNS.

El flujo finaliza con un **código de salida global**, permitiendo integrarlo fácilmente en pipelines de CI/CD:
- `0` → Todo OK
- `1/2/4` → Fallos específicos en HTTP o DNS.

Cada ejecución crea un archivo `result_YYYYMMDD_HHMMSS.txt` en `out/` con el detalle:

```
==== Proyecto 2 - Sprint 1 ====
Verificando conectividad HTTP con: https://www.google.com

HTTP 200
Conexión HTTP exitosa a https://www.google.com
 (0=ok)
DNS resuelto correctamente. (0=ok)
Resultado final: Todo OK (0=ok)
```


---

### **Pruebas automatizadas: `tests/auditor_tls.bats`**

Se usó **BATS** (Bash Automated Testing System) para validar el comportamiento del script:

- **Caso exitoso:**  
  Comprueba que con `CHECK_URL=https://www.google.com` el script retorna código `0`, imprime `HTTP 200` y muestra el mensaje final `Resultado final: Todo OK`.

- **Caso de error:**  
  Ejecuta el script sin definir `CHECK_URL` y espera que retorne un código distinto de `0`.

Estas pruebas se pueden ejecutar con:

```bash
make test
```
Los resultados se almacenan en out/tests.log.

Las ejecuciones son estas:

```
==> Verificando dependencias...
Todas las dependencias están disponibles.
==> Preparando directorios...
mkdir -p out dist
Build completado.
==> Ejecutando pruebas con bats
1..2
not ok 1 Ejecución correcta con https://www.google.com
# (in test file tests/auditor_tls.bats, line 5)
#   `[ "$status" -eq 0 ]' failed
ok 2 Falla si no se define CHECK_URL
```


---
## *Automatización con Makefile*

### Automatización con Makefile

El **Makefile** estandariza las tareas clave del proyecto:

| **Target** | **Descripción** |
|------------|-----------------|
| **tools**  | Verifica dependencias: `curl`, `getent` y `bats`. |
| **build**  | Crea las carpetas `out/` y `dist/`. |
| **test**   | Ejecuta las pruebas BATS y guarda el log en `out/tests.log`. |
| **run**    | Lanza el script `auditor_tls.sh` con `CHECK_URL=https://www.google.com`. |
| **clean**  | Limpia el contenido de `out/` y `dist/`. |
| **help**   | Muestra la lista de comandos disponibles. |



Aparte de las ejecuciones com `make test` y `make run`, tenemos estas:



```
bianca007@MSI:/mnt/c/Users/Bianca/Documents/Pc1-Grupo2-Proyecto2$ make tools
==> Verificando dependencias...
Todas las dependencias están disponibles.
bianca007@MSI:/mnt/c/Users/Bianca/Documents/Pc1-Grupo2-Proyecto2$ make bouild
make: *** No rule to make target 'bouild'.  Stop.
bianca007@MSI:/mnt/c/Users/Bianca/Documents/Pc1-Grupo2-Proyecto2$ make clean
==> Limpiando artefactos...
rm -rf out/* dist/*
bianca007@MSI:/mnt/c/Users/Bianca/Documents/Pc1-Grupo2-Proyecto2$ make help
Targets disponibles:
  tools  - Verificar dependencias necesarias
  build  - Crear directorios de salida
  test   - Ejecutar pruebas con BATS y guardar log en out/
  run    - Ejecutar el auditor con CHECK_URL por defecto
  clean  - Limpiar out/ y dist/
  help   - Mostrar esta ayuda
```


### **Directorios de salida**

out/: almacena los logs de cada ejecución y el archivo tests.log de las pruebas.

dist/: reservado para futuros artefactos de distribución (vacío en este sprint).


