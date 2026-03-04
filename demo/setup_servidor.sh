#!/bin/bash
# ============================================================
#  🦀 ClawMobil - Setup completo de servidor IA en teléfono
#  Instala: Termux + Ollama + Modelo + App ClawMobil Chat
# ============================================================

RED='\033[0;31m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
BOLD='\033[1m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
TERMUX_APK="/tmp/termux_fdroid.apk"
OLLAMA_BIN="/tmp/ollama-extract/bin/ollama"

echo ""
echo -e "${CYAN}╔══════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║${NC}  ${BOLD}🦀 ClawMobil - Setup Servidor IA${NC}            ${CYAN}║${NC}"
echo -e "${CYAN}╚══════════════════════════════════════════════╝${NC}"
echo ""

# Detectar dispositivo
DEVICE=$(adb devices 2>/dev/null | grep -w "device" | head -1 | awk '{print $1}')
if [ -z "$DEVICE" ]; then
    echo -e "${RED}❌ No hay teléfono conectado${NC}"
    exit 1
fi

MODEL=$(adb -s "$DEVICE" shell getprop ro.product.model 2>/dev/null | tr -d '\r')
ANDROID=$(adb -s "$DEVICE" shell getprop ro.build.version.release 2>/dev/null | tr -d '\r')
ARCH=$(adb -s "$DEVICE" shell getprop ro.product.cpu.abi 2>/dev/null | tr -d '\r')
RAM=$(adb -s "$DEVICE" shell cat /proc/meminfo 2>/dev/null | grep MemTotal | awk '{printf "%.1f GB", $2/1024/1024}')

echo -e "${GREEN}📱 Dispositivo: ${BOLD}$MODEL${NC} ${GREEN}(Android $ANDROID, $ARCH, $RAM)${NC}"
echo ""

# Paso 1: Instalar Termux
echo -e "${BOLD}[1/5]${NC} Instalando Termux..."
if adb -s "$DEVICE" shell pm list packages 2>/dev/null | grep -q com.termux; then
    echo -e "${GREEN}  ✅ Termux ya instalado${NC}"
else
    if [ ! -f "$TERMUX_APK" ]; then
        echo -e "${YELLOW}  ⬇️ Descargando Termux F-Droid...${NC}"
        curl -sL -o "$TERMUX_APK" "https://f-droid.org/repo/com.termux_1000.apk"
    fi
    adb -s "$DEVICE" install "$TERMUX_APK" 2>/dev/null
    echo -e "${GREEN}  ✅ Termux instalado${NC}"
fi

# Paso 2: Abrir Termux e inicializar
echo ""
echo -e "${BOLD}[2/5]${NC} Inicializando Termux..."
adb -s "$DEVICE" shell am start -n com.termux/.app.TermuxActivity > /dev/null 2>&1
echo -e "${YELLOW}  ⏳ Esperando inicialización (30s)...${NC}"
sleep 30
echo -e "${GREEN}  ✅ Termux inicializado${NC}"

# Paso 3: Subir Ollama al teléfono
echo ""
echo -e "${BOLD}[3/5]${NC} Subiendo Ollama al teléfono..."
if [ ! -f "$OLLAMA_BIN" ]; then
    echo -e "${YELLOW}  ⬇️ Descargando Ollama para ARM64...${NC}"
    mkdir -p /tmp/ollama-extract
    curl -L -o /tmp/ollama-linux-arm64.tar.zst "https://github.com/ollama/ollama/releases/download/v0.17.6/ollama-linux-arm64.tar.zst"
    cd /tmp/ollama-extract && tar --use-compress-program=unzstd -xf /tmp/ollama-linux-arm64.tar.zst 2>/dev/null
fi
adb -s "$DEVICE" push "$OLLAMA_BIN" /sdcard/ollama > /dev/null 2>&1
echo -e "${GREEN}  ✅ Ollama subido${NC}"

# Paso 4: Instalar Ollama dentro de Termux
echo ""
echo -e "${BOLD}[4/5]${NC} Configurando Ollama en Termux..."
echo -e "${YELLOW}  ⏳ Esto puede tardar unos minutos...${NC}"

# Dar permiso de almacenamiento
adb -s "$DEVICE" shell pm grant com.termux android.permission.READ_EXTERNAL_STORAGE 2>/dev/null
adb -s "$DEVICE" shell pm grant com.termux android.permission.WRITE_EXTERNAL_STORAGE 2>/dev/null

# Crear script de setup para ejecutar dentro de Termux
cat > /tmp/termux_setup.sh << 'TERMUX_SCRIPT'
#!/data/data/com.termux/files/usr/bin/bash
# Copiar ollama a home
cp /storage/emulated/0/ollama ~/ollama 2>/dev/null || cp /sdcard/ollama ~/ollama
chmod +x ~/ollama

# Intentar patchelf
termux-change-repo << EOF
1
1
EOF

pkg update -y 2>/dev/null
pkg install -y patchelf 2>/dev/null

if command -v patchelf &> /dev/null; then
    # Parchear el intérprete ELF para Termux
    patchelf --set-interpreter /data/data/com.termux/files/usr/lib/ld-linux-aarch64.so.1 ~/ollama 2>/dev/null || \
    patchelf --set-interpreter $PREFIX/lib/ld-linux-aarch64.so.1 ~/ollama 2>/dev/null
fi

mv ~/ollama $PREFIX/bin/ollama
echo "OLLAMA_SETUP_DONE"
TERMUX_SCRIPT

adb -s "$DEVICE" push /tmp/termux_setup.sh /sdcard/termux_setup.sh > /dev/null 2>&1

echo -e "${YELLOW}  📋 Abre Termux y ejecuta:${NC}"
echo -e "     ${BOLD}bash /sdcard/termux_setup.sh${NC}"
echo ""
echo -e "  Luego:"
echo -e "     ${BOLD}ollama serve &${NC}"  
echo -e "     ${BOLD}ollama pull qwen2.5:0.5b${NC}"

# Paso 5: Instalar App ClawMobil
echo ""
echo -e "${BOLD}[5/5]${NC} Instalando ClawMobil Chat..."
APK="$SCRIPT_DIR/ClawMobil-Chat.apk"
if [ -f "$APK" ]; then
    adb -s "$DEVICE" install -r "$APK" > /dev/null 2>&1
    echo -e "${GREEN}  ✅ App instalada${NC}"
else
    echo -e "${YELLOW}  ⚠️ APK no encontrada en $SCRIPT_DIR/ClawMobil-Chat.apk${NC}"
fi

echo ""
echo -e "${CYAN}╔══════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║${NC}  ${BOLD}Setup completado${NC}                             ${CYAN}║${NC}"
echo -e "${CYAN}║${NC}  Siguiente: ejecuta en Termux:               ${CYAN}║${NC}"
echo -e "${CYAN}║${NC}  ${YELLOW}bash /sdcard/termux_setup.sh${NC}                 ${CYAN}║${NC}"
echo -e "${CYAN}║${NC}  ${YELLOW}ollama serve &${NC}                               ${CYAN}║${NC}"
echo -e "${CYAN}║${NC}  ${YELLOW}ollama pull qwen2.5:0.5b${NC}                     ${CYAN}║${NC}"
echo -e "${CYAN}╚══════════════════════════════════════════════╝${NC}"
echo ""
