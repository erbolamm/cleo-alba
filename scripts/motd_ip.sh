#!/bin/bash
# ============================================
# 📡 ClawMobil — Banner de Conexión
# ============================================
# Script ultraligero para mostrar la IP del servidor
# al abrir Termux. Añade esto a tu .bashrc:
#   source ~/clawmobil/scripts/motd_ip.sh
# ============================================

IP=$(ip addr show wlan0 2>/dev/null | grep "inet " | awk '{print $2}' | cut -d/ -f1 | head -n1)
TUNNEL_URL=$(cat "$HOME/last_tunnel_url.txt" 2>/dev/null)

echo ""
echo "┌──────────────────────────────────────┐"
echo "│     🦀 ClawMobil Server Activo       │"
echo "├──────────────────────────────────────┤"

if [ -n "$IP" ]; then
    printf "│  📶 Local:  %-24s│\n" "http://$IP:11434"
else
    echo "│  📶 Local:  (sin WiFi)              │"
fi

if [ -n "$TUNNEL_URL" ] && pgrep -f "cloudflared" > /dev/null 2>&1; then
    printf "│  🌐 Online: %-23s│\n" "$TUNNEL_URL"
else
    echo "│  🌐 Online: (túnel apagado)         │"
fi

echo "└──────────────────────────────────────┘"
echo ""
