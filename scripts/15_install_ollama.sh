#!/bin/bash
# ============================================
# 15. INSTALAR OLLAMA + MODELO LOCAL
# Ejecutar desde Terminal.app del Mac
# ============================================
# Requisito: SSH configurado (scripts 03-04)

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/../config/config.sh" 2>/dev/null || true

SSH_CMD="ssh -o ConnectTimeout=10 -o StrictHostKeyChecking=no -p 8022 localhost"

echo "=== 🧠 INSTALANDO IA OFFLINE (Ollama) ==="
echo ""

# 1. Verificar que SSH funciona
if ! $SSH_CMD "echo 'SSH_OK'" 2>/dev/null | grep -q "SSH_OK"; then
    echo "❌ No se puede conectar por SSH al teléfono."
    echo "   Ejecuta primero: adb forward tcp:8022 tcp:8022"
    exit 1
fi
echo "✅ SSH conectado"

# 2. Instalar Ollama dentro de Debian
echo ""
echo "📦 Instalando Ollama dentro de Debian..."
$SSH_CMD "proot-distro login debian -- bash -c '
# Usar la tarjeta SD (128GB) para almacenar modelos
export OLLAMA_MODELS=/sdcard/ollama_models
mkdir -p /sdcard/ollama_models

# Verificar si ya está instalado
if command -v ollama &>/dev/null; then
    echo \"✅ Ollama ya instalado: \$(ollama --version)\"
else
    echo \"📥 Descargando e instalando Ollama...\"
    curl -fsSL https://ollama.com/install.sh | sh
    echo \"✅ Ollama instalado: \$(ollama --version)\"
fi
'" 2>&1

# 3. Iniciar Ollama server en background y descargar modelo
echo ""
echo "🚀 Iniciando Ollama y descargando modelo Llama 3.2 1B..."
echo "⏳ Esto puede tardar varios minutos (descarga ~800MB)..."
$SSH_CMD "proot-distro login debian -- bash -c '
# Modelos en la SD de 128GB
export OLLAMA_MODELS=/sdcard/ollama_models

# Matar instancia anterior si existe
pkill -f \"ollama serve\" 2>/dev/null
sleep 2

# Iniciar servidor en background
nohup ollama serve > /tmp/ollama.log 2>&1 &
sleep 5

# Verificar que arrancó
if curl -s http://localhost:11434/api/tags > /dev/null 2>&1; then
    echo \"✅ Servidor Ollama corriendo\"
else
    echo \"⚠️ Esperando a que Ollama arranque...\"
    sleep 10
fi

# Descargar modelo pequeño para 4GB RAM
echo \"📥 Descargando modelo llama3.2:1b (Q4, ~800MB)...\"
ollama pull llama3.2:1b 2>&1

# Verificar
echo \"\"
echo \"=== Modelos instalados ===\"
ollama list 2>&1
'" 2>&1

# 4. Test rápido
echo ""
echo "🧪 Test rápido de IA offline..."
$SSH_CMD "proot-distro login debian -- bash -c '
RESPONSE=\$(curl -s http://localhost:11434/api/generate -d \"{\\\"model\\\":\\\"llama3.2:1b\\\",\\\"prompt\\\":\\\"Di solo: IA offline funcionando\\\",\\\"stream\\\":false}\" 2>&1)
if echo \"\$RESPONSE\" | grep -q \"response\"; then
    echo \"✅ IA OFFLINE FUNCIONANDO\"
    echo \"Respuesta: \$(echo \"\$RESPONSE\" | python3 -c \"import sys,json; print(json.load(sys.stdin).get(\\\"response\\\",\\\"error\\\"))\" 2>/dev/null)\"
else
    echo \"⚠️ Ollama respondió pero puede necesitar más RAM\"
    echo \"\$RESPONSE\"
fi
'" 2>&1

echo ""
echo "==========================================="
echo "🏁 Instalación de Ollama completada"
echo "==========================================="
echo ""
echo "Para añadir al auto-arranque de OpenClaw,"
echo "ejecuta el script 16 a continuación."
