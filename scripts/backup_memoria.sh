#!/bin/bash
# backup_memoria.sh — Backup de memoria y workspace del bot a GitHub
# Se ejecuta: manualmente, via cron, o via comando /backup del bot
# Ubicación en VPS: /home/apliarte/docker/services/apliarte-bot/backup_memoria.sh

set -euo pipefail

BOT_DIR="/home/apliarte/docker/services/apliarte-bot"
REPO_DIR="/home/apliarte/aplibot-memoria"
DATE=$(date '+%Y-%m-%d %H:%M')

echo "[backup] Iniciando backup de ApliArteBot — $DATE"

# 1. Copiar workspace
echo "[backup] Copiando workspace..."
cp -f "$BOT_DIR/workspace/"*.md "$REPO_DIR/" 2>/dev/null || true

# 2. Copiar memoria (si existe)
if [ -d "$BOT_DIR/config/memory" ]; then
    echo "[backup] Copiando memoria..."
    mkdir -p "$REPO_DIR/memory/"
    cp -rf "$BOT_DIR/config/memory/"* "$REPO_DIR/memory/" 2>/dev/null || true
fi

# 3. Copiar agentes (si hay sesiones guardadas)
if [ -d "$BOT_DIR/config/agents" ]; then
    echo "[backup] Copiando agentes..."
    mkdir -p "$REPO_DIR/agents/"
    cp -rf "$BOT_DIR/config/agents/"* "$REPO_DIR/agents/" 2>/dev/null || true
fi

# 4. Copiar config (sin secretos — openclaw.json tiene env vars, no valores)
echo "[backup] Copiando configuración..."
cp -f "$BOT_DIR/config/openclaw.json" "$REPO_DIR/config_openclaw.json" 2>/dev/null || true

# 5. Git push
cd "$REPO_DIR"
git add -A
if git diff --cached --quiet; then
    echo "[backup] Sin cambios. Nada que subir."
else
    git commit -m "Backup automático — $DATE"
    git push
    echo "[backup] Backup subido a GitHub correctamente."
fi

echo "[backup] Completado."
