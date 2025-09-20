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