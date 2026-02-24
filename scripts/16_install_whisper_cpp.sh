#!/bin/bash
# ============================================
# 16. INSTALAR WHISPER.CPP (STT OFFLINE)
# Ejecutar desde Terminal.app del Mac
# ============================================
# Requisito: SSH configurado (scripts 03-04)

SSH_CMD="ssh -o ConnectTimeout=10 -o StrictHostKeyChecking=no -o ServerAliveInterval=30 -p 8022 localhost"

echo "=== 🎤 INSTALANDO WHISPER.CPP (Speech-to-Text Offline) ==="
echo ""

# 1. Verificar SSH
if ! $SSH_CMD "echo 'SSH_OK'" 2>/dev/null | grep -q "SSH_OK"; then
    echo "❌ No se puede conectar por SSH."
    exit 1
fi
echo "✅ SSH conectado"

# 2. Compilar whisper.cpp dentro de Debian
echo ""
echo "📦 Compilando whisper.cpp para ARM..."
echo "⏳ Esto puede tardar unos minutos..."
$SSH_CMD "proot-distro login debian -- bash -c '
# Instalar dependencias de compilación
apt-get update -qq && apt-get install -y -qq git cmake g++ make curl > /dev/null 2>&1
echo \"✅ Dependencias instaladas\"

# Clonar whisper.cpp si no existe
if [ -d /opt/whisper.cpp ]; then
    echo \"✅ whisper.cpp ya descargado\"
    cd /opt/whisper.cpp && git pull --quiet
else
    echo \"📥 Clonando whisper.cpp...\"
    git clone --depth 1 https://github.com/ggerganov/whisper.cpp.git /opt/whisper.cpp
fi

# Compilar
cd /opt/whisper.cpp
echo \"🔨 Compilando (ARM NEON)...\"
cmake -B build -DCMAKE_BUILD_TYPE=Release 2>&1 | tail -3
cmake --build build --config Release -j4 2>&1 | tail -5
echo \"✅ Compilación completa\"

# Verificar binario
if [ -f build/bin/whisper-cli ]; then
    echo \"✅ Binario: build/bin/whisper-cli\"
    ls -lh build/bin/whisper-cli
else
    echo \"⚠️ Binario no encontrado, buscando...\"
    find build -name \"whisper*\" -type f | head -10
fi
'" 2>&1

# 3. Descargar modelo base (150MB) en la SD
echo ""
echo "📥 Descargando modelo Whisper base (~150MB) en la SD..."
$SSH_CMD "proot-distro login debian -- bash -c '
mkdir -p /sdcard/whisper_models
cd /opt/whisper.cpp

# Descargar modelo base si aún no existe
if [ -f /sdcard/whisper_models/ggml-base.bin ]; then
    echo \"✅ Modelo base ya descargado\"
else
    echo \"📥 Descargando ggml-base.bin...\"
    curl -L -o /sdcard/whisper_models/ggml-base.bin \
        https://huggingface.co/ggerganov/whisper.cpp/resolve/main/ggml-base.bin
    echo \"✅ Modelo descargado\"
    ls -lh /sdcard/whisper_models/ggml-base.bin
fi
'" 2>&1

# 4. Crear wrapper script para uso fácil
echo ""
echo "🔧 Creando script wrapper..."
$SSH_CMD "proot-distro login debian -- bash -c '
cat > /usr/local/bin/whisper-transcribe << \"WEOF\"
#!/bin/bash
# Transcribir audio offline con whisper.cpp
# Uso: whisper-transcribe archivo.wav [idioma]
AUDIO_FILE=\$1
LANG=\${2:-es}
MODEL=/sdcard/whisper_models/ggml-base.bin

if [ -z \"\$AUDIO_FILE\" ]; then
    echo \"Uso: whisper-transcribe <archivo.wav> [idioma (es/en/...)]\"
    exit 1
fi

/opt/whisper.cpp/build/bin/whisper-cli -m \$MODEL -l \$LANG -f \"\$AUDIO_FILE\" --no-timestamps 2>/dev/null
WEOF
chmod +x /usr/local/bin/whisper-transcribe
echo \"✅ Wrapper instalado: whisper-transcribe\"
'" 2>&1

echo ""
echo "==========================================="
echo "🏁 Instalación de whisper.cpp completada"
echo "==========================================="
echo ""
echo "Uso: whisper-transcribe grabacion.wav es"
