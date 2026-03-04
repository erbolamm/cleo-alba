#!/data/data/com.termux/files/usr/bin/bash
# ============================================
# 🔄 REINICIO COMPLETO DEL STACK ClawMobil
# ============================================
# Reinicia: OpenClaw + server.py + bridges
# Se puede llamar desde la App Flutter, desde Termux directo,
# o desde un trigger de Telegram.
#
# USO: bash restart_all.sh
# ============================================
# LECCIONES APLICADAS (ver docs/LECCIONES_APRENDIDAS.md):
#   - Limpiar procesos previos SIEMPRE (evitar zombies RAM)
#   - Usar screen para todo (reconectable + persistente)
#   - OpenClaw preferido en Termux nativo (PRoot es fallback)
# ============================================

LOG="$HOME/restart.log"
echo "[$(date)] === REINICIO INICIADO ===" >> "$LOG"

# ─── 1. Matar TODOS los procesos anteriores ───────────────────────────────
echo "[$(date)] 🧹 Limpiando procesos..." >> "$LOG"
pkill -f openclaw 2>/dev/null
pkill -f server.py 2>/dev/null
pkill -f camera_bridge 2>/dev/null
pkill -f bridge_server 2>/dev/null
sleep 2

# Limpiar sesiones screen muertas
screen -wipe 2>/dev/null

# ─── 2. Arrancar OpenClaw ─────────────────────────────────────────────────
echo "[$(date)] 🦞 Arrancando OpenClaw..." >> "$LOG"

if command -v openclaw &>/dev/null; then
    # PREFERIDO: OpenClaw en Termux nativo
    screen -dmS openclaw_gw openclaw gateway run --port 18789 --bind 127.0.0.1
    echo "[$(date)] ✅ OpenClaw en Termux nativo (screen 'openclaw_gw')" >> "$LOG"
elif command -v proot-distro &>/dev/null; then
    # FALLBACK: OpenClaw en PRoot Debian
    echo "[$(date)] ⚠️ OpenClaw no en Termux, intentando PRoot..." >> "$LOG"

    # Buscar el binario dentro de Debian
    OC_BIN=""
    for p in "/usr/bin/openclaw" "/usr/local/bin/openclaw" \
             "/root/node_modules/.bin/openclaw" \
             "/usr/lib/node_modules/openclaw/bin/openclaw.js"; do
        if proot-distro login debian -- test -f "$p" 2>/dev/null; then
            OC_BIN="$p"
            break
        fi
    done

    if [ -n "$OC_BIN" ]; then
        screen -dmS openclaw_gw proot-distro login debian -- bash -c \
            "cd /root && $OC_BIN gateway run --port 18789 --bind 127.0.0.1"
        echo "[$(date)] ⚠️ OpenClaw en PRoot ($OC_BIN)" >> "$LOG"
    else
        echo "[$(date)] ❌ OpenClaw no encontrado en PRoot. Instalar con:" >> "$LOG"
        echo "    proot-distro login debian -- npm install -g openclaw --ignore-scripts" >> "$LOG"
    fi
else
    echo "[$(date)] ❌ Ni OpenClaw ni proot-distro encontrados." >> "$LOG"
    echo "    Instalar: npm install -g openclaw --ignore-scripts" >> "$LOG"
fi

# ─── 3. Arrancar server.py ────────────────────────────────────────────────
echo "[$(date)] 🌐 Arrancando server.py..." >> "$LOG"

SERVER_PATH=""
for p in /sdcard/avatar/server.py /sdcard/server.py "$HOME/avatar/server.py" "$HOME/server.py"; do
    if [ -f "$p" ]; then
        SERVER_PATH="$p"
        break
    fi
done

if [ -n "$SERVER_PATH" ]; then
    screen -dmS server python3 "$SERVER_PATH"
    echo "[$(date)] ✅ server.py arrancado (screen 'server')" >> "$LOG"
else
    echo "[$(date)] ⚠️ server.py no encontrado. Saltando." >> "$LOG"
fi

# ─── 4. Arrancar Camera Bridge ────────────────────────────────────────────
BRIDGE_PATH=""
for p in /sdcard/camera_bridge.sh "$HOME/camera_bridge.sh"; do
    if [ -f "$p" ]; then
        BRIDGE_PATH="$p"
        break
    fi
done

if [ -n "$BRIDGE_PATH" ]; then
    screen -dmS bridge bash "$BRIDGE_PATH"
    echo "[$(date)] ✅ Bridge arrancado (screen 'bridge')" >> "$LOG"
fi

# ─── 5. Verificar que arrancaron ──────────────────────────────────────────
sleep 5
echo "[$(date)] --- Estado de sesiones screen ---" >> "$LOG"
screen -ls 2>/dev/null | grep -E "(openclaw|server|bridge)" >> "$LOG"

# Verificar procesos reales
RUNNING=0
for proc in openclaw server.py; do
    if pgrep -f "$proc" > /dev/null 2>&1; then
        echo "[$(date)] ✅ $proc RUNNING" >> "$LOG"
        RUNNING=$((RUNNING + 1))
    else
        echo "[$(date)] ❌ $proc NO arrancó" >> "$LOG"
    fi
done

echo "[$(date)] === REINICIO COMPLETADO ($RUNNING servicios activos) ===" >> "$LOG"
echo "DONE ($RUNNING servicios activos)"
