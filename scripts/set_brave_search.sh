#!/data/data/com.termux/files/usr/bin/bash
# Script para configurar Brave Search en OpenClaw (Debian)

if [ -z "$1" ]; then
    echo "Uso: ./set_brave_search.sh <API_KEY>"
    exit 1
fi

API_KEY=$1

echo "Configurando Brave Search API Key en OpenClaw..."

proot-distro login debian -- bash -c "
openclaw config set tools.web.search.apiKey $API_KEY
openclaw config set tools.web.search.enabled true
echo 'Configuración aplicada correctamente.'
"

echo "Reiniciando servicios para aplicar cambios..."
bash /sdcard/restart_all.sh
