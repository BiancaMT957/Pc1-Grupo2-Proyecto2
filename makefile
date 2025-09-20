# ========================
# Makefile - Proyecto 2
# Sprint 1
# ========================

# Variables
RELEASE ?= v0.1.0
PROJECT ?= Pc1-Grupo2-Proyecto2
SRC=src/auditor_tls.sh
OUT_DIR=out
DIST_DIR=dist
TEST_DIR ?= tests
SOURCE_DATE_EPOCH ?= 0	# Mantiene fecha determinada si los archivos no se modifican
PKG_NAME ?= $(PROJECT)-$(RELEASE).tar.gz

# Ajustes de Shell
SHELL := /bin/bash
.SHELLFLAGS := -euo pipefail -c
.ONESHELL:

# ------------------------
# Targets
# ------------------------

.PHONY: tools build run pack clean help test

tools:
	@echo "==> Verificando dependencias..."
	@command -v curl >/dev/null 2>&1 || { echo "Error: curl no está instalado"; exit 1; }
	@command -v getent >/dev/null 2>&1 || { echo "Error: getent no está instalado"; exit 1; }
	@command -v bats >/dev/null 2>&1 || { echo "Error: bats no está instalado"; exit 1; }
	@command -v bash >/dev/null 2>&1 || { echo "Error: bash no está instalado/visible"; exit 1; }
	@command -v tar  >/dev/null 2>&1 || { echo "Error: tar no está instalado"; exit 1; }
	@command -v gzip >/dev/null 2>&1 || { echo "Error: gzip no está instalado"; exit 1; }
	@echo "==> Verificando bats para pruebas..."
	@if command -v bats >/dev/null 2>&1; then echo "bats OK"; else echo "Aviso: 'bats' no encontrado. Instálalo para 'make test' (sudo apt-get install -y bats)"; fi
	@echo "==> Listo."
	@echo "Todas las dependencias están disponibles."

build:
	@echo "==> Preparando directorios..."
	mkdir -p $(OUT_DIR) $(DIST_DIR)
	@echo "Build completado."

# Ejecuta todos los bats, falla si uno falla
test: tools build
	@echo "==> Ejecutando pruebas con bats en '$(TEST_DIR)'"
	@if ! command -v bats >/dev/null 2>&1; then \
		echo "Error: 'bats' no está instalado. Instálalo (p.ej. sudo apt-get install -y bats) y vuelve a intentar."; \
		exit 2; \
	fi
	@bats -r $(TEST_DIR)

# pack: genera archivo reproducible en dist/
pack: build
	@echo "==> Empaquetando versión '$(RELEASE)' de forma reproducible..."
	@outfile="$(DIST_DIR)/$(PKG_NAME)"; [ -n "$$outfile" ] || { echo "PKG_NAME vacío"; exit 1; };\
	echo "Output: $$outfile"; \
	tar \
		--sort=name \
		--mtime=@$(SOURCE_DATE_EPOCH) \
		--owner=0 --group=0 --numeric-owner \
		--exclude="$(DIST_DIR)" \
		--exclude="$(OUT_DIR)" \
		--exclude=".git" \
		--exclude="*.swp" \
		-cf - . | gzip --no-name > "$$outfile"
	@echo "Paquete creado en $(DIST_DIR)/$(PKG_NAME)"


run: tools build
	@echo "==> Ejecutando $(SRC)"
	@chmod +x $(SRC) || true
	@CHECK_URL=$${CHECK_URL:-https://www.google.com} $(SRC) || true

clean:
	@echo "==> Limpiando artefactos..."
	rm -rf $(OUT_DIR)/* $(DIST_DIR)/*

help:
	@echo "Targets disponibles:"
	@echo "  tools  - Verificar dependencias necesarias"
	@echo "  build  - Crear directorios de salida"
	@echo "  test   - Ejecutar pruebas con BATS, falla si alguno falla, y guardar log en out/"
	@echo "  pack   - Crea paquete reproducible en $(DIST_DIR)/ con nombre $(PKG_NAME)"
	@echo "  run    - Ejecutar el auditor con CHECK_URL por defecto"
	@echo "  clean  - Limpiar out/ y dist/"
	@echo "  help   - Mostrar esta ayuda"