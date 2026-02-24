#!/data/data/com.termux/files/usr/bin/bash
# Editar directamente el archivo de config
DEBIAN_ROOT="/data/data/com.termux/files/usr/var/lib/proot-distro/installed-rootfs/debian"
CONFIG="$DEBIAN_ROOT/root/.openclaw/openclaw.json"

# Cambiar dmPolicy de pairing a open
sed -i 's/"dmPolicy":\s*"pairing"/"dmPolicy": "open"/g' "$CONFIG"

# Aprobar pairing SX49DGW9
proot-distro login debian -- openclaw pairing approve telegram SX49DGW9 &

# Reiniciar gateway para aplicar
pkill -9 -f "openclaw-gateway" 2>/dev/null
sleep 2
bash /sdcard/restart_all.sh
