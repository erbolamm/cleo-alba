#!/data/data/com.termux/files/usr/bin/bash
# v23 - Reparación Definitiva (Modo Manual Seguro)
echo "--- INICIANDO REPARACIÓN v23 ---"

# 1. Limpieza total
echo "Limpiando procesos..."
pkill -9 -f python3
pkill -9 -f openclaw
pkill -9 -f node
sleep 1

# 2. Sincronizar archivos
mkdir -p ~/avatar
cp /sdcard/avatar/server.py ~/avatar/server.py || echo "Warning: cp server.py failed"

# 3. Configuración Global de Modelo
echo "Fijando modelo global a Copilot..."
proot-distro login debian -- openclaw config set model github-copilot/gpt-4o

# 4. Sincronizar Telegram
echo "Sincronizando Telegram..."
TG_KEY="channels.telegram"
if proot-distro login debian -- openclaw config get telegram >/dev/null 2>&1; then TG_KEY="telegram"; fi
proot-distro login debian -- bash -c "openclaw config set ${TG_KEY}.enabled true"
proot-distro login debian -- bash -c "openclaw config set ${TG_KEY}.botToken TU_TELEGRAM_BOT_TOKEN_AQUI"
proot-distro login debian -- bash -c "openclaw config set ${TG_KEY}.allowFrom '[\"TU_TELEGRAM_ID_AQUI\"]'"

# 5. Arrancar Motores
echo "Arrancando Bridge..."
nohup python3 ~/avatar/server.py > ~/bridge.log 2>&1 &

echo "Arrancando OpenClaw (solo localhost)..."
# SEGURIDAD: --bind 127.0.0.1 evita exponer el gateway a la red local.
# Cambia a --bind lan SÓLO si sabes lo que haces y tienes auth activado.
nohup proot-distro login debian -- bash -c "export OPENCLAW_SKIP_SYSTEMD=true && openclaw gateway run --port 18789 --bind 127.0.0.1" > ~/gateway.log 2>&1 &

sleep 2
echo "--- VERIFICACIÓN ---"
ps -A | grep -E 'python3|openclaw' | grep -v grep
echo "----------------------"
echo "¡Sistema en línea! Ready para login manual si fuera necesario."
