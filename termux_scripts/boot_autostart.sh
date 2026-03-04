#!/data/data/com.termux/files/usr/bin/bash
# ============================================================
# 🦞 ClawMobil AutoBoot — Inicio automático al encender el dispositivo
# Archivo: ~/.termux/boot/boot_autostart.sh
# ============================================================
# INSTALACIÓN:
#   1. Instalar Termux:Boot desde F-Droid
#   2. Abrir Termux:Boot UNA VEZ para activarlo
#   3. Crear directorio: mkdir -p ~/.termux/boot
#   4. Copiar este archivo: cp boot_autostart.sh ~/.termux/boot/
#   5. Dar permisos:       chmod +x ~/.termux/boot/boot_autostart.sh
# ============================================================
# LECCIONES APLICADAS (ver docs/LECCIONES_APRENDIDAS.md):
#   - Usar screen en vez de nohup (reconectable + logs en vivo)
#   - Matar procesos previos antes de arrancar (evitar zombies RAM)
#   - OpenClaw en Termux nativo (no PRoot, se cuelga)
#   - SD card solo se toca desde Termux nativo (PRoot no tiene acceso)
#   - No hay systemd ni D-Bus en Termux/PRoot
# ============================================================

# Esperar a que el sistema Android esté estable antes de arrancar
sleep 20

# Mantener la CPU activa (sin dormir) mientras los servicios corren
termux-wake-lock

# ------------------------------------------------------------------
# FASE 0: Preparar SD Card (solo Termux nativo puede escribir aquí)
# ------------------------------------------------------------------
# Buscar SD automáticamente
SD=""
for dir in /storage/*; do
    if [ -d "$dir" ] && [ "$dir" != "/storage/emulated" ] && [ "$dir" != "/storage/self" ]; then
        SD="$dir"
        break
    fi
done

LOG="/sdcard/clawmobil_boot.log"
echo "======================================" >> "$LOG"
echo "[$(date)] 🚀 ClawMobil AutoBoot iniciado" >> "$LOG"

if [ -n "$SD" ]; then
    mkdir -p "$SD/ClawMobil_Backup" "$SD/Media/fotos" "$SD/Media/audios" \
             "$SD/Media/videos" "$SD/Logs" 2>/dev/null
    echo "[$(date)] 💾 SD preparada en $SD" >> "$LOG"
else
    echo "[$(date)] ⚠️ SD no detectada. Usando almacenamiento interno." >> "$LOG"
fi

# ------------------------------------------------------------------
# FASE 1: Limpiar procesos previos (evitar zombies que comen RAM)
# ------------------------------------------------------------------
echo "[$(date)] 🧹 Limpiando procesos anteriores..." >> "$LOG"
pkill -f openclaw 2>/dev/null
pkill -f camera_bridge 2>/dev/null
pkill -f server.py 2>/dev/null
pkill -f bridge_server 2>/dev/null
sleep 2
screen -wipe 2>/dev/null

# ------------------------------------------------------------------
# FASE 2: Iniciar SSH
# ------------------------------------------------------------------
echo "[$(date)] 🔑 Iniciando SSH..." >> "$LOG"
sshd -p 8022 2>/dev/null
echo "[$(date)] ✅ SSH lanzado en puerto 8022" >> "$LOG"

# ------------------------------------------------------------------
# FASE 3: Iniciar Bridge Scripts (Cámara, TTS, etc.)
# ------------------------------------------------------------------
echo "[$(date)] 📸 Iniciando Camera Bridge..." >> "$LOG"
BRIDGE_PATH="/sdcard/camera_bridge.sh"
if [ ! -f "$BRIDGE_PATH" ]; then
    BRIDGE_PATH="$HOME/camera_bridge.sh"
fi
if [ -f "$BRIDGE_PATH" ]; then
    screen -dmS bridge bash "$BRIDGE_PATH"
    echo "[$(date)] ✅ Bridge lanzado en screen 'bridge'" >> "$LOG"
else
    echo "[$(date)] ⚠️ camera_bridge.sh no encontrado. Bridges desactivados." >> "$LOG"
fi

# ------------------------------------------------------------------
# FASE 4: Iniciar OpenClaw Gateway (en Termux nativo, NO PRoot)
# ------------------------------------------------------------------
echo "[$(date)] 🦞 Iniciando OpenClaw Gateway..." >> "$LOG"

if command -v openclaw &>/dev/null; then
    # OpenClaw está instalado en Termux nativo (recomendado)
    screen -dmS openclaw_gw openclaw gateway run --port 18789 --bind 127.0.0.1
    echo "[$(date)] ✅ OpenClaw lanzado en Termux nativo (screen 'openclaw_gw')" >> "$LOG"
elif command -v proot-distro &>/dev/null && proot-distro list 2>/dev/null | grep -q "debian"; then
    # Fallback: OpenClaw en PRoot Debian (puede ser inestable)
    echo "[$(date)] ⚠️ OpenClaw no encontrado en Termux. Intentando PRoot Debian..." >> "$LOG"
    screen -dmS openclaw_gw proot-distro login debian -- bash -c \
        "openclaw gateway run --port 18789 --bind 127.0.0.1"
    echo "[$(date)] ⚠️ OpenClaw lanzado en PRoot (menos estable)" >> "$LOG"
else
    echo "[$(date)] ❌ OpenClaw no encontrado. Instalar con:" >> "$LOG"
    echo "    npm install -g openclaw --ignore-scripts" >> "$LOG"
fi

# ------------------------------------------------------------------
# FASE 5: Iniciar servidor web/API (si existe)
# ------------------------------------------------------------------
SERVER_PATH=""
for p in /sdcard/server.py /sdcard/avatar/server.py "$HOME/server.py" "$HOME/avatar/server.py"; do
    if [ -f "$p" ]; then
        SERVER_PATH="$p"
        break
    fi
done

if [ -n "$SERVER_PATH" ]; then
    echo "[$(date)] 🌐 Iniciando server.py ($SERVER_PATH)..." >> "$LOG"
    screen -dmS server python3 "$SERVER_PATH"
    echo "[$(date)] ✅ Server lanzado en screen 'server'" >> "$LOG"
fi

# ------------------------------------------------------------------
# FASE 6: Verificación final
# ------------------------------------------------------------------
sleep 5
echo "[$(date)] --- Estado de servicios ---" >> "$LOG"
screen -ls 2>/dev/null | grep -E "(openclaw|bridge|server)" >> "$LOG"

echo "[$(date)] 🎉 AutoBoot completo." >> "$LOG"
echo "======================================" >> "$LOG"
