#!/bin/bash
# ============================================
# 🌐 Cloudflare Tunnel Toggle — ClawMobil
# ============================================
# Activa o desactiva la visibilidad online del servidor YesTeL.
#
# USO:
#   bash toggle_tunnel.sh on      # Activa el modo ONLINE
#   bash toggle_tunnel.sh off     # Vuelve al modo LOCAL (offline)
#   bash toggle_tunnel.sh status  # Estado actual del túnel
# ============================================

set -euo pipefail

PORT=11434
AUTH_PORT=11435
TERMUX_PREFIX="/data/data/com.termux/files/usr/bin"
TERMUX_HOME="/data/data/com.termux/files/home"
LOG_FILE="$TERMUX_HOME/cf_out.txt"
SCRIPTS_DIR="$(dirname "$0")"

# Colores
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

cmd_on() {
    echo -e "${BLUE}🌐 Activando MODO ONLINE...${NC}"
    
    if pgrep -f "cloudflared tunnel" > /dev/null; then
        echo -e "${YELLOW}⚠️ El túnel ya está activo.${NC}"
        cmd_status
        return
    fi

    echo -e "${BLUE}🛡️ Iniciando Proxy de Autenticación...${NC}"
    nohup python3 "$SCRIPTS_DIR/auth_proxy.py" > /tmp/auth_proxy.log 2>&1 &
    sleep 2

    # Iniciar túnel en screen apuntando al puerto del PROXY
    screen -dmS cf_tunnel cloudflared tunnel --url http://localhost:$AUTH_PORT
    
    echo -e "${BLUE}⏳ Generando URL pública (espera 5s)...${NC}"
    sleep 5
    
    # Capturar la URL
    screen -S cf_tunnel -X hardcopy "$LOG_FILE"
    URL=$(grep -o 'https://[a-zA-Z0-9.-]*trycloudflare.com' "$LOG_FILE" | tail -1 || true)
    
    if [ -n "$URL" ]; then
        echo -e "${GREEN}✅ SERVIDOR ONLINE: ${NC}${URL}"
        echo "$URL" > "$TERMUX_HOME/last_tunnel_url.txt"
        
        # Notificación en Android si Termux:API está disponible
        if command -v termux-notification &>/dev/null; then
            termux-notification -t "YesTeL Online 🌐" -c "Conectar a: $URL" --id "cf_tunnel"
        fi
        
        # También podemos usar termux-toast para algo rápido
        if command -v termux-toast &>/dev/null; then
            termux-toast -c green "YesTeL Online: $URL"
        fi
    else
        echo -e "${RED}❌ No se pudo capturar la URL automáticamente.${NC}"
        echo "Revisa manualmente con: screen -r cf_tunnel"
    fi
}

cmd_off() {
    echo -e "${YELLOW}🏠 Volviendo a MODO LOCAL (Offline)...${NC}"
    pkill -f "cloudflared tunnel" || true
    pkill -f "auth_proxy.py" || true
    
    # Quitar notificación
    if command -v termux-notification &>/dev/null; then
        termux-notification-remove "cf_tunnel" 2>/dev/null || true
    fi
    
    echo -e "${GREEN}✅ Túnel cerrado. Servidor solo visible en LAN.${NC}"
}

cmd_status() {
    if pgrep -f "cloudflared tunnel" > /dev/null; then
        URL=$(cat "$TERMUX_HOME/last_tunnel_url.txt" 2>/dev/null || echo "Desconocida")
        echo -e "${GREEN}● ESTADO: ONLINE${NC}"
        echo -e "  URL: ${URL}"
    else
        echo -e "${RED}○ ESTADO: LOCAL (Offline)${NC}"
    fi
}

case "${1:-status}" in
    on)     cmd_on ;;
    off)    cmd_off ;;
    status) cmd_status ;;
    *)      echo "Uso: toggle_tunnel.sh {on|off|status}" ;;
esac
