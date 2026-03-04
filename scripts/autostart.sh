#!/bin/bash
# ============================================
# 🦀 ClawMobil — Script de Arranque Automático
# ============================================
# Este script se ejecuta al encender el YesTeL.
# Instalar con Termux:Boot o añadir a .bashrc
#
# Copia este archivo en: ~/.termux/boot/
#   mkdir -p ~/.termux/boot
#   cp autostart.sh ~/.termux/boot/
#   chmod +x ~/.termux/boot/autostart.sh
# ============================================

# Esperar a que Android esté completamente cargado
sleep 15

# Desbloquear wakelock para que Termux no se duerma
termux-wake-lock 2>/dev/null

# 1. Arrancar Ollama
echo "🧠 Arrancando Ollama..."
export OLLAMA_HOST="0.0.0.0:11434"
nohup ollama serve > /tmp/ollama.log 2>&1 &
sleep 5

# 2. Arrancar pantalla de estado
echo "📡 Arrancando pantalla de estado..."
nohup python3 ~/clawmobil/scripts/server_display.py > /tmp/display.log 2>&1 &

# 3. Mostrar IP en notificación
IP=$(ip addr show wlan0 2>/dev/null | grep "inet " | awk '{print $2}' | cut -d/ -f1 | head -n1)
if command -v termux-notification &>/dev/null && [ -n "$IP" ]; then
    termux-notification \
        -t "🦀 ClawMobil Activo" \
        -c "Local: http://$IP:11434 | Display: http://$IP:8080" \
        --id "clawmobil_server" \
        --ongoing
fi

# 4. Mostrar banner
source ~/clawmobil/scripts/motd_ip.sh 2>/dev/null

echo "✅ ClawMobil Server listo para conectar."
