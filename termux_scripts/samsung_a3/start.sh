#!/data/data/com.termux/files/usr/bin/bash
# ClawMobil - Arrancar servidor Samsung A3
DIR="$HOME/clawmobil"
mkdir -p "$DIR"

# Copiar archivos si vienen de /sdcard
cp /sdcard/clawmobil/server_a3.py "$DIR/" 2>/dev/null
cp /sdcard/clawmobil/chat.html    "$DIR/" 2>/dev/null

# Matar instancia anterior
pkill -f server_a3.py 2>/dev/null
sleep 1

# Arrancar sshd si no corre
pgrep sshd >/dev/null || sshd

# Arrancar el servidor en background
cd "$DIR"
nohup python server_a3.py > "$DIR/server.log" 2>&1 &
echo $! > "$DIR/server.pid"

sleep 2
if pgrep -f server_a3.py >/dev/null; then
  IP=$(ip addr show wlan0 2>/dev/null | grep 'inet ' | awk '{print $2}' | cut -d/ -f1)
  echo ""
  echo "✅ ClawMobil arrancado"
  echo "   http://localhost:8080"
  [ -n "$IP" ] && echo "   http://$IP:8080"
  echo ""
  echo "Abre en el navegador del móvil: http://localhost:8080"
else
  echo "❌ Error al arrancar. Log:"
  cat "$DIR/server.log"
fi
