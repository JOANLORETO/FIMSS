#!/bin/bash

# FIMSS - Sincronización automática con GitHub
# Detecta cambios, analiza Flutter y sincroniza cambios válidos.

set -u

PROJECT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
cd "$PROJECT_DIR" || exit 1

echo "========================================"
echo " FIMSS - SINCRONIZACIÓN AUTOMÁTICA"
echo "========================================"
echo "Proyecto: $PROJECT_DIR"
echo ""
echo "Esperando cambios..."
echo "Presiona Ctrl+C para detener."
echo ""

while true; do

    fswatch -1 \
        --exclude '\.git/' \
        --exclude 'build/' \
        --exclude '\.dart_tool/' \
        --exclude '\.idea/' \
        --exclude 'Pods/' \
        --exclude '\.symlinks/' \
        "$PROJECT_DIR" >/dev/null

    echo ""
    echo "----------------------------------------"
    echo "Cambio detectado."
    echo "Esperando 10 segundos..."
    sleep 10

    STATUS="$(git status --porcelain)"

    if [ -z "$STATUS" ]; then
        echo "No hay cambios de Git que sincronizar."
        continue
    fi

    echo ""
    echo "Cambios detectados:"
    git status --short
    echo ""

    # Verificar que GitHub no tenga cambios pendientes.
    git fetch origin main >/dev/null 2>&1

    LOCAL="$(git rev-parse main)"
    REMOTE="$(git rev-parse origin/main)"

    if [ "$LOCAL" != "$REMOTE" ]; then
        echo "========================================"
        echo " SINCRONIZACIÓN DETENIDA"
        echo "========================================"
        echo "GitHub contiene cambios que todavía"
        echo "no están en este Mac."
        echo ""
        echo "Primero debemos sincronizar manualmente"
        echo "el repositorio para evitar conflictos."
        echo ""
        continue
    fi

    echo "Ejecutando flutter analyze..."
    echo ""

    if ! flutter analyze; then
        echo ""
        echo "========================================"
        echo " SINCRONIZACIÓN DETENIDA"
        echo "========================================"
        echo "Flutter encontró errores."
        echo "Los cambios NO serán enviados a GitHub."
        echo ""
        echo "Corrige los errores y vuelve a guardar."
        echo ""
        continue
    fi

    echo ""
    echo "Flutter analyze: OK"
    echo ""

    # Solo preparar archivos que Git ya conoce.
    echo "Archivos modificados que serán preparados:"
    git diff --name-only
    echo ""

    git add -u

    # Detectar archivos nuevos que estén fuera de las exclusiones.
    NEW_FILES="$(git ls-files --others --exclude-standard)"

    if [ -n "$NEW_FILES" ]; then
        echo "Archivos nuevos detectados:"
        echo "$NEW_FILES"
        echo ""
        echo "Los archivos nuevos NO serán agregados automáticamente."
        echo "Agrégalos manualmente si forman parte del proyecto."
    fi

    if git diff --cached --quiet; then
        echo "No hay cambios preparados para crear commit."
        continue
    fi

    echo "Cambios preparados para commit:"
    git diff --cached --stat
    echo ""

    TIMESTAMP="$(date '+%Y-%m-%d %H:%M')"
    COMMIT_MESSAGE="chore: auto-sync FIMSS - $TIMESTAMP"

    echo "Creando commit:"
    echo "$COMMIT_MESSAGE"
    echo ""

    if ! git commit -m "$COMMIT_MESSAGE"; then
        echo ""
        echo "ERROR: No se pudo crear el commit."
        continue
    fi

    echo ""
    echo "Commit creado correctamente."
    echo "Enviando cambios a GitHub..."
    echo ""

    if ! git push origin main; then
        echo ""
        echo "========================================"
        echo " PUSH FALLIDO"
        echo "========================================"
        echo "El commit existe localmente, pero"
        echo "no pudo enviarse a GitHub."
        echo ""
        continue
    fi

    echo ""
    echo "========================================"
    echo " FIMSS SINCRONIZADO CON GITHUB"
    echo "========================================"
    echo ""

done
