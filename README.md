# Proyecto 2 - Desarrollo de Software B

Este repositorio contiene el código fuente, pruebas automatizadas y documentación del Proyecto 2: **Auditor TLS Bash**. 
El objetivo es verificar conectividad HTTP y DNS de una URL configurable, reportando los resultados y cubriendo casos representativos.

## Estructura

- `src/`   – Código fuente principal (`auditor_tls.sh`).
- `test/`  – Pruebas automatizadas con Bats.
- `docs/`  – Documentación y bitácoras (`BITACORA.md`).
- `out/`   – Archivos temporales generados (logs y resultados).
- `dist/`  – Paquetes finales de distribución.

## Ejecución

```bash
# Ejecutar script principal
make run

# Ejecutar pruebas automatizadas
make test
```

## Variables de entorno

Puedes definir la URL a chequear y la ruta de salida usando variables de entorno.  
Aquí tienes una tabla de referencia:

| Variable      | Descripción                                    | Valor por defecto            | Ejemplo de uso                      |
|---------------|------------------------------------------------|------------------------------|-------------------------------------|
| `CHECK_URL`   | URL a verificar (HTTP y DNS)                   | `https://www.google.com`     | `CHECK_URL="https://httpstat.us/400" make run` |
| `OUTPUT_DIR`  | Carpeta para guardar los logs/resultados       | `out`                        | `OUTPUT_DIR="out" make run`         |

## Ejemplo de uso personalizado

```bash
CHECK_URL="https://httpstat.us/400" OUTPUT_DIR="out" ./src/auditor_tls.sh
```

## Explicación de salida

El script genera un archivo en `out/` llamado `result_YYYYMMDD_HHMMSS.txt` con información como:

```
==== Proyecto 2 - Sprint 1 ====
Verificando conectividad HTTP con: https://www.google.com
HTTP 200
Conexión HTTP exitosa a https://www.google.com (0=ok)
DNS resuelto correctamente. (0=ok)
Resultado final: Todo OK (0=ok)
```

Si ocurre un error, la salida indicará el tipo y código:

- HTTP 400/404:  
  ```HTTP 400``` o ```HTTP 404``` y  
  ```Resultado final: HTTP falló con código X```
- DNS incorrecto:  
  ```Fallo en la resolución DNS. (≠0=falla)``` y  
  ```Resultado final: DNS falló con código 2```

## Códigos de salida

| Código | Significado                |
|--------|---------------------------|
| 0      | Todo OK                   |
| 1      | Fallo genérico HTTP       |
| 2      | Fallo en resolución DNS   |
| 4      | HTTP 400 (Bad Request)    |

## Pruebas automatizadas

Las pruebas (`test/auditor-tls.bats`) cubren:

- Éxito HTTP 200
- Fallos HTTP 400/404
- Dominio DNS incorrecto

Ejecuta todas las pruebas con:

```bash
make test
```


## Explicación de salida



```

==> Ejecutando pruebas con bats

``
1..2
 ok 1 Ejecución correcta con https://www.google.com
# (in test file tests/auditor_tls.bats, line 5)
#   `[ "$status" -eq 0 ]' failed
ok 2 Falla si no se define CHECK_URL
```

* **`1..2`**: Indica que Bats ejecutó **2 pruebas en total**.  
  Bats utiliza el protocolo **TAP (Test Anything Protocol)** para reportar resultados.

### Resultado de cada prueba
1. **`ok 1 Ejecución correcta con https://www.google.com`** 
   -  La primera prueba pasó correctamente. 
   - El script `auditor_tls.sh` pudo conectarse a Google y generó la salida esperada.

2. ** `ok 2 Falla si no se define CHECK_URL`**  
   - La segunda prueba falló en la **línea 31**. 
   - La condición que no se cumplió fue:  
     ```
     [ "$status" -ne 0 ]
     ```
   - Esto indica que el script **terminó con código de salida 0** aun cuando `CHECK_URL` no estaba definida.  
     Sucede porque en el script se usa una asignación con valor por defecto:
     ```bash
     CHECK_URL="${CHECK_URL:-https://www.google.com}"
     ```
     por lo que nunca falla aunque la variable no esté definida.