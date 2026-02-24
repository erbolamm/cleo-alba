#!/data/data/com.termux/files/usr/bin/bash
# ============================================================
# 🦞 ApliBot — Script de Arranque al Encender (Termux:Boot)
# ~/.termux/boot/start-openclaw.sh
# ============================================================

LOG="/sdcard/aplibot_boot.log"
echo "===================================" >> "$LOG"
echo "[$(date)] 🔄 AutoBoot iniciado" >> "$LOG"

# Esperar a que Android esté estable
sleep 20

# Mantener despierta la CPU
termux-wake-lock

# --- Fase 1: Camera Bridge ---
echo "[$(date)] 📸 Iniciando camera_bridge..." >> "$LOG"
bash /sdcard/camera_bridge.sh >> "$LOG" 2>&1 &
echo "[$(date)] Bridge PID: $!" >> "$LOG"
sleep 3

# --- Fase 2: Servidor Python (API + Smart Display) ---
echo "[$(date)] 🌐 Iniciando server.py..." >> "$LOG"
python3 /sdcard/server.py >> "$LOG" 2>&1 &
echo "[$(date)] Server PID: $!" >> "$LOG"
sleep 2

# --- Fase 3: OpenClaw en Debian ---
echo "[$(date)] 🦞 Iniciando OpenClaw..." >> "$LOG"
proot-distro login debian -- bash -c "
  # Verificar que gateway.mode=local esté en el config (2026.2.22+ lo requiere)
  if ! grep -q '\"mode\"' /root/.openclaw/openclaw.json 2>/dev/null; then
    openclaw config set gateway.mode local 2>/dev/null
  fi
  nohup openclaw gateway run >> /root/openclaw.log 2>&1 &
  echo OpenClaw PID: \$!
" >> "$LOG" 2>&1

echo "[$(date)] ✅ Todo arrancado" >> "$LOG"
echo "===================================" >> "$LOG"

# Mantener el script vivo para que Termux no muera (espera indefinida)
while true; do
    sleep 60
done
