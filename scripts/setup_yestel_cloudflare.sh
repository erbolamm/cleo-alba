#!/bin/bash
# ========================================================
# 🚀 Setup Cloudflare Tunnel on YesTeL Server (vía ADB)
# ========================================================

SERIAL="NOTE10PRO000400"
PORT=11434

echo "🔍 Buscando dispositivo YesTeL ($SERIAL)..."

if ! adb -s "$SERIAL" get-state &>/dev/null; then
    echo "❌ Dispositivo no encontrado vía ADB."
    echo "Por favor, conecta el YesTeL por USB y asegúrate de que la depuración USB está activa."
    exit 1
fi

TERMUX_PREFIX="/data/data/com.termux/files/usr/bin"
TERMUX_HOME="/data/data/com.termux/files/home"

echo "✅ YesTeL detectado."

# 1. Instalar dependencias si no existen
echo "📦 Instalando cloudflared y screen en Termux..."
adb -s "$SERIAL" shell "$TERMUX_PREFIX/pkg update -y && $TERMUX_PREFIX/pkg install -y cloudflared screen"

# 2. Iniciar túnel rápido (Quick Tunnel)
echo "🌐 Iniciando túnel temporal de Cloudflare para Ollama ($PORT)..."
echo "--------------------------------------------------------"
echo "⚠️  COPIA LA URL QUE APAREZCA (ej: https://...trycloudflare.com)"
echo "--------------------------------------------------------"

# Abrir el túnel en una sesión de screen para que no se cierre
# Usamos un archivo de log para capturar la URL
adb -s "$SERIAL" shell "export PATH=$TERMUX_PREFIX:\$PATH && screen -dmS cf_tunnel cloudflared tunnel --url http://localhost:$PORT"

# Esperar un poco y tratar de obtener la URL buscando en la salida de cloudflared
echo "⏳ Generando túnel... espera 10 segundos..."
sleep 10

# Cloudflared suele imprimir la URL en stderr, intentamos capturarla redireccionando a un archivo temporal
adb -s "$SERIAL" shell "export PATH=$TERMUX_PREFIX:\$PATH && screen -r cf_tunnel -X hardcopy $TERMUX_HOME/cf_out.txt"
URL=$(adb -s "$SERIAL" shell "grep -o 'https://[a-zA-Z0-9.-]*trycloudflare.com' $TERMUX_HOME/cf_out.txt | tail -1")

if [ -n "$URL" ]; then
    echo "✅ Tu servidor Ollama es accesible en: $URL"
    echo "Usa esta URL en tu index.html o apps externas."
else
    echo "ℹ️  No se pudo extraer la URL automáticamente."
    echo "Prueba a ejecutar: 'adb -s $SERIAL shell $TERMUX_PREFIX/screen -list' para verificar."
fi
