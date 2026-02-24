#!/data/data/com.termux/files/usr/bin/bash
# ============================================================
# 🦞 ApliBot AutoBoot — Inicio automático al encender el dispositivo
# Archivo: ~/.termux/boot/boot_autostart.sh
# ============================================================
# INSTALACIÓN:
#   1. Instalar Termux:Boot desde F-Droid
#   2. Abrir Termux:Boot UNA VEZ para activarlo
#   3. crear directorio: mkdir -p ~/.termux/boot
#   4. copiar este archivo: cp /sdcard/boot_autostart.sh ~/.termux/boot/
#   5. dar permisos:       chmod +x ~/.termux/boot/boot_autostart.sh
# ============================================================

# Esperar a que el sistema Android esté estable antes de arrancar
sleep 20

# Mantener la CPU activa (sin dormir) mientras los servicios corren
termux-wake-lock

# Redirigir logs al sdcard para diagnóstico
LOG="/sdcard/aplibot_boot.log"
echo "======================================" >> "$LOG"
echo "[$(date)] 🚀 ApliBot AutoBoot iniciado" >> "$LOG"

# --- FASE 1: Iniciar el Bridge (Cámara + TTS + Pantalla) ---
echo "[$(date)] 📸 Iniciando Camera Bridge..." >> "$LOG"
if [ -f /sdcard/camera_bridge.sh ]; then
    bash /sdcard/camera_bridge.sh >> "$LOG" 2>&1 &
    echo "[$(date)] ✅ Bridge PID: $!" >> "$LOG"
else
    echo "[$(date)] ❌ ERROR: /sdcard/camera_bridge.sh no encontrado" >> "$LOG"
fi

# --- FASE 2: Iniciar el Servidor Principal (API + Smart Display) ---
echo "[$(date)] 🌐 Iniciando server.py..." >> "$LOG"
if [ -f /sdcard/server.py ]; then
    python3 /sdcard/server.py >> "$LOG" 2>&1 &
    echo "[$(date)] ✅ Server PID: $!" >> "$LOG"
else
    echo "[$(date)] ❌ ERROR: /sdcard/server.py no encontrado" >> "$LOG"
fi

# --- FASE 3: Iniciar OpenClaw en Debian (cerebro IA) ---
echo "[$(date)] 🦞 Iniciando OpenClaw en Debian..." >> "$LOG"

# Comprobamos que proot-distro y debian estén instalados
if command -v proot-distro &>/dev/null && proot-distro list 2>/dev/null | grep -q "debian"; then
    proot-distro login debian -- bash -c "
        cd /root
        # SEGURIDAD: --bind 127.0.0.1 para no exponer el gateway a la LAN.
        nohup openclaw gateway run --port 18789 --bind 127.0.0.1 > /root/openclaw.log 2>&1 &
        echo 'OpenClaw Gateway PID: '\$!
    " >> "$LOG" 2>&1 &
    echo "[$(date)] ✅ OpenClaw lanzado en Debian" >> "$LOG"
else
    echo "[$(date)] ⚠️ proot-distro o Debian no encontrados. Saltando OpenClaw." >> "$LOG"
fi

echo "[$(date)] 🎉 AutoBoot completo. Todos los servicios en marcha." >> "$LOG"
echo "======================================" >> "$LOG"
