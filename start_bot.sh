#!/data/data/com.termux/files/usr/bin/bash
# ============================================
# 🦞 ClawMobil — Arranque del bot
# ============================================
# Script principal de arranque. Ejecutar en Termux.
# USO: bash start_bot.sh
# ============================================

# Prevenir que Android detenga Termux en segundo plano
termux-wake-lock

cd /data/data/com.termux/files/home

# --- 1. Habilitar SSH ---
sshd -p 8022 2>/dev/null

# --- 2. Limpiar procesos previos (SIEMPRE, evitar zombies RAM) ---
pkill -f openclaw 2>/dev/null
pkill -f bridge_server 2>/dev/null
sleep 2
screen -wipe 2>/dev/null

# --- 3. Arrancar OpenClaw ---
if command -v openclaw &>/dev/null; then
    # Termux nativo (preferido)
    screen -dmS openclaw_gw openclaw gateway run --port 18789 --bind 127.0.0.1
elif command -v proot-distro &>/dev/null; then
    # Fallback: PRoot Debian (cargar claves.env si existe)
    CLAVES_CMD=""
    if [ -f /root/claves.env ]; then
        CLAVES_CMD="export \$(grep -v '^#' /root/claves.env | grep -v '^\$' | xargs) &&"
    fi
    screen -dmS openclaw_gw proot-distro login debian -- bash -c \
        "${CLAVES_CMD} openclaw gateway run --port 18789 --bind 127.0.0.1"
fi

# --- 4. Arrancar Ollama (IA offline) ---
# Detectar modelo configurado (si existe claves.env)
OLLAMA_MODEL="${OLLAMA_MODEL:-gemma2:2b}"
OLLAMA_PORT="${OLLAMA_PORT:-11434}"

if command -v ollama &>/dev/null; then
    # Ollama nativo en Termux
    pkill -f "ollama serve" 2>/dev/null; sleep 1
    screen -dmS ollama bash -c "OLLAMA_HOST=0.0.0.0:${OLLAMA_PORT} ollama serve"
    # Esperar a que el servidor arranque y descargar modelo si no existe
    sleep 5
    if curl -sf "http://127.0.0.1:${OLLAMA_PORT}/api/tags" > /dev/null 2>&1; then
        # Verificar si ya tiene el modelo, si no, descargarlo en background
        if ! curl -sf "http://127.0.0.1:${OLLAMA_PORT}/api/tags" | grep -q "${OLLAMA_MODEL}"; then
            screen -dmS ollama_pull bash -c "ollama pull ${OLLAMA_MODEL}"
        fi
    fi
elif command -v proot-distro &>/dev/null; then
    # Ollama dentro de PRoot Debian
    screen -dmS ollama proot-distro login debian -- bash -c "
        export OLLAMA_MODELS=/sdcard/ollama_models
        export OLLAMA_HOST=0.0.0.0:${OLLAMA_PORT}
        mkdir -p /sdcard/ollama_models
        pkill -f 'ollama serve' 2>/dev/null; sleep 1
        ollama serve
    "
fi

# --- 5. Arrancar Python Bridge (en Termux nativo) ---
if [ -f "bridge_server.py" ]; then
    screen -dmS bridge python3 bridge_server.py
fi

# --- 6. Arrancar Watchdog (si existe) ---
if [ -f "watchdog.sh" ]; then
    screen -dmS watchdog bash watchdog.sh
fi

# --- 7. Esperar y verificar ---
sleep 10
echo "=== Estado de servicios ==="
screen -ls 2>/dev/null | grep -E "(openclaw|bridge|watchdog|ollama|server)"

# --- 8. Notificar via Telegram (si hay claves configuradas) ---
# Las claves se leen del archivo claves.env del dispositivo activo
CLAVES_FILE=""
for f in "$HOME/claves.env" "/sdcard/claves.env"; do
    if [ -f "$f" ]; then
        CLAVES_FILE="$f"
        break
    fi
done

if [ -n "$CLAVES_FILE" ]; then
    source "$CLAVES_FILE" 2>/dev/null
    if [ -n "$TELEGRAM_BOT_TOKEN" ] && [ -n "$TELEGRAM_CHAT_ID" ]; then
        HOSTNAME=$(hostname 2>/dev/null || echo "ClawMobil")
        OLLAMA_MSG=""
        if curl -sf "http://127.0.0.1:${OLLAMA_PORT:-11434}/api/tags" > /dev/null 2>&1; then
            OLLAMA_MSG=" 🧠 Ollama OK."
        fi
        curl -s -X POST "https://api.telegram.org/bot${TELEGRAM_BOT_TOKEN}/sendMessage" \
            -d chat_id="${TELEGRAM_CHAT_ID}" \
            -d text="🦞 ${HOSTNAME}: Sistema arrancado. OpenClaw activo.${OLLAMA_MSG} 🚀" > /dev/null
    fi
fi

echo "✅ start_bot.sh completado"
