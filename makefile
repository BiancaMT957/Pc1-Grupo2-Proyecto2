# ========================
# Makefile - Proyecto 2
# Sprint 1
# ========================

# Variables
SRC=src/auditor_tls.sh
OUT_DIR=out
DIST_DIR=dist

# ------------------------
# Targets
# ------------------------

.PHONY: tools build run clean help

tools:
	@echo "==> Verificando dependencias..."
	@command -v curl >/dev/null 2>&1 || { echo "Error: curl no está instalado"; exit 1; }
	@command -v getent >/dev/null 2>&1 || { echo "Error: getent no está instalado"; exit 1; }
	@command -v bats >/dev/null 2>&1 || { echo "Error: bats no está instalado"; exit 1; }
	@echo "Todas las dependencias están disponibles."

build:
	@echo "==> Preparando directorios..."
	mkdir -p $(OUT_DIR) $(DIST_DIR)
	@echo "Build completado."

# Nuevo: test
test: tools build
	@echo "==> Ejecutando pruebas con bats"
	@mkdir -p $(OUT_DIR)
	@bats tests/ | tee $(OUT_DIR)/tests.log

run: tools build
	@echo "==> Ejecutando auditor_tls.sh"
	@CHECK_URL=https://www.google.com $(SRC)

clean:
	@echo "==> Limpiando artefactos..."
	rm -rf $(OUT_DIR)/* $(DIST_DIR)/*

help:
	@echo "Targets disponibles:"
	@echo "  tools  - Verificar dependencias necesarias"
	@echo "  build  - Crear directorios de salida"
	@echo "  run    - Ejecutar el auditor con CHECK_URL por defecto"
	@echo "  clean  - Limpiar out/ y dist/"
	@echo "  help   - Mostrar esta ayuda"
