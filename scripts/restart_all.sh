#!/data/data/com.termux/files/usr/bin/bash
# ============================================
# 🔄 REINICIO COMPLETO DEL STACK ClawMobil
# ============================================
# Reinicia: server.py + OpenClaw (proot-distro Debian)
# Se puede llamar desde la App Flutter via server.py,
# desde Termux directamente, o desde Termux:Boot
#
# USO: bash /sdcard/restart_all.sh
# ============================================

LOG="/data/data/com.termux/files/home/restart.log"
echo "[$(date)] === REINICIO INICIADO ===" >> "$LOG"

# ─── 1. Matar procesos anteriores ─────────────────────────────────────────
echo "[$(date)] Matando server.py anterior..." >> "$LOG"
pkill -f "server.py" 2>/dev/null
sleep 1

echo "[$(date)] Matando OpenClaw anterior..." >> "$LOG"
pkill -f "openclaw" 2>/dev/null
pkill -f "camera_bridge" 2>/dev/null
sleep 1

# ─── 2. Arrancar server.py ────────────────────────────────────────────────
echo "[$(date)] Arrancando server.py..." >> "$LOG"

SERVER_PATH="/sdcard/avatar/server.py"
if [ ! -f "$SERVER_PATH" ]; then
    # Fallback: buscar en home
    SERVER_PATH="$HOME/avatar/server.py"
fi

if [ -f "$SERVER_PATH" ]; then
    SERVER_DIR="$(dirname "$SERVER_PATH")"
    nohup python3 "$SERVER_PATH" >> /data/data/com.termux/files/home/server.log 2>&1 &
    SERVER_PID=$!
    echo "[$(date)] server.py arrancado (PID: $SERVER_PID)" >> "$LOG"
else
    echo "[$(date)] ERROR: No se encontró server.py" >> "$LOG"
fi

# ─── 3. Arrancar OpenClaw en Debian (proot-distro) ───────────────────────
sleep 2
echo "[$(date)] Buscando binario de OpenClaw..." >> "$LOG"

# Intentar rutas comunes directamente
OC_BIN=""
for p in "/usr/bin/openclaw" "/usr/local/bin/openclaw" "/root/node_modules/.bin/openclaw"; do
    if proot-distro login debian -- [ -f "$p" ]; then
        OC_BIN="$p"
        break
    fi
done

if [ -n "$OC_BIN" ]; then
    echo "[$(date)] OpenClaw encontrado en $OC_BIN. Arrancando gateway..." >> "$LOG"
    # Matar instancia anterior limpiamente
    pkill -9 -f "openclaw" 2>/dev/null
    sleep 1
    # Lanzar gateway (en proot-distro no hay systemd, por lo que usamos run)
    nohup proot-distro login debian -- bash -c "
        cd /root
        openclaw gateway run
    " >> /data/data/com.termux/files/home/openclaw.log 2>&1 &
    OC_PID=$!
    echo "[$(date)] OpenClaw lanzado (PID: $OC_PID)" >> "$LOG"
else
    echo "[$(date)] ❌ ERROR: No se encontró el binario 'openclaw' en Debian." >> "$LOG"
    echo "Intenta instalarlo con: proot-distro login debian -- npm install -g github:erbolamm/openclaw" >> "$LOG"
fi

# ─── 4. Verificar que arrancaron ─────────────────────────────────────────
sleep 3
if pgrep -f "server.py" > /dev/null 2>&1; then
    echo "[$(date)] ✅ server.py RUNNING" >> "$LOG"
else
    echo "[$(date)] ❌ server.py NO arrancó" >> "$LOG"
fi

if pgrep -f "openclaw" > /dev/null 2>&1; then
    echo "[$(date)] ✅ OpenClaw RUNNING" >> "$LOG"
else
    echo "[$(date)] ⚠️ OpenClaw no detectado (puede ser normal si se inicia dentro de Debian)" >> "$LOG"
fi

echo "[$(date)] === REINICIO COMPLETADO ===" >> "$LOG"
echo "DONE"
