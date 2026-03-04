#!/bin/bash
# ============================================================
#  🦀 ClawMobil - Instalador Portable
#  Funciona en cualquier Mac sin nada preinstalado
#  Por Francisco (Apliarte) - apliarte.com
# ============================================================

RED='\033[0;31m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
BOLD='\033[1m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PACKAGE="com.apliarte.cleo_yestel_chat"
ADB_CMD=""

clear
echo ""
echo -e "${CYAN}╔══════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║${NC}  ${BOLD}🦀 ClawMobil - IA Privada para Todos${NC}        ${CYAN}║${NC}"
echo -e "${CYAN}║${NC}     por Francisco (${YELLOW}apliarte.com${NC})            ${CYAN}║${NC}"
echo -e "${CYAN}╚══════════════════════════════════════════════╝${NC}"
echo ""

# ---- PASO 1: Encontrar o descargar ADB ----
echo -e "${BOLD}[1/4]${NC} Preparando herramientas..."

if command -v adb &> /dev/null; then
    ADB_CMD="adb"
    echo -e "${GREEN}  ✅ ADB encontrado${NC}"
elif [ -f "$SCRIPT_DIR/platform-tools/adb" ]; then
    ADB_CMD="$SCRIPT_DIR/platform-tools/adb"
    echo -e "${GREEN}  ✅ ADB portable encontrado${NC}"
else
    echo -e "${YELLOW}  ⬇️  Descargando ADB portable...${NC}"
    if [[ "$OSTYPE" == "darwin"* ]]; then
        curl -sL -o /tmp/platform-tools.zip "https://dl.google.com/android/repository/platform-tools-latest-darwin.zip"
    else
        curl -sL -o /tmp/platform-tools.zip "https://dl.google.com/android/repository/platform-tools-latest-linux.zip"
    fi
    unzip -qo /tmp/platform-tools.zip -d "$SCRIPT_DIR/" 2>/dev/null
    ADB_CMD="$SCRIPT_DIR/platform-tools/adb"
    chmod +x "$ADB_CMD"
    echo -e "${GREEN}  ✅ ADB descargado y listo${NC}"
fi

# ---- PASO 2: Detectar teléfono ----
echo ""
echo -e "${BOLD}[2/4]${NC} Buscando teléfono Android..."
echo -e "${YELLOW}  📱 Conecta el teléfono por USB${NC}"

# Iniciar servidor ADB
$ADB_CMD start-server 2>/dev/null

RETRY=0
DEVICE=""
while [ -z "$DEVICE" ] && [ $RETRY -lt 60 ]; do
    DEVICE=$($ADB_CMD devices 2>/dev/null | grep -w "device" | head -1 | awk '{print $1}')
    if [ -z "$DEVICE" ]; then
        echo -ne "\r  ⏳ Esperando teléfono... ($RETRY s) - Acepta 'Depuración USB' si aparece   "
        sleep 2
        RETRY=$((RETRY + 2))
    fi
done

if [ -z "$DEVICE" ]; then
    echo -e "\n${RED}❌ No se encontró ningún teléfono.${NC}"
    echo ""
    echo "  Para activar Depuración USB:"
    echo "  1. Ajustes → Acerca del teléfono → pulsa 7 veces 'Número de compilación'"
    echo "  2. Ajustes → Opciones de desarrollador → Activar Depuración USB"
    echo "  3. Reconecta el cable y acepta el popup"
    exit 1
fi

MODEL=$($ADB_CMD -s "$DEVICE" shell getprop ro.product.model 2>/dev/null | tr -d '\r')
ANDROID=$($ADB_CMD -s "$DEVICE" shell getprop ro.build.version.release 2>/dev/null | tr -d '\r')
echo -e "\n${GREEN}  ✅ ${BOLD}$MODEL${NC} ${GREEN}(Android $ANDROID) conectado${NC}"

# ---- PASO 3: Buscar APK ----
echo ""
echo -e "${BOLD}[3/4]${NC} Preparando la App..."

APK=""
for path in \
    "$SCRIPT_DIR/ClawMobil-Chat.apk" \
    "$SCRIPT_DIR/../demo/ClawMobil-Chat.apk" \
    "$SCRIPT_DIR/app-release.apk"; do
    if [ -f "$path" ]; then
        APK="$path"
        break
    fi
done

if [ -z "$APK" ]; then
    echo -e "${RED}❌ No se encontró ClawMobil-Chat.apk${NC}"
    echo "  Coloca la APK en esta carpeta: $SCRIPT_DIR/"
    exit 1
fi

SIZE=$(ls -lh "$APK" | awk '{print $5}')
echo -e "${GREEN}  ✅ APK lista ($SIZE)${NC}"

# ---- PASO 4: Instalar ----
echo ""
echo -e "${BOLD}[4/4]${NC} ${CYAN}Instalando Claw en ${MODEL}...${NC}"

$ADB_CMD -s "$DEVICE" uninstall "$PACKAGE" > /dev/null 2>&1

RESULT=$($ADB_CMD -s "$DEVICE" install -r "$APK" 2>&1)
if echo "$RESULT" | grep -q "Success"; then
    # Abrir la App
    sleep 1
    $ADB_CMD -s "$DEVICE" shell am start -n "$PACKAGE/.MainActivity" > /dev/null 2>&1

    echo ""
    echo -e "${CYAN}╔══════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║${NC}                                              ${CYAN}║${NC}"
    echo -e "${CYAN}║${NC}  ${GREEN}${BOLD}🦀 ¡Claw instalada en $MODEL!${NC}"
    echo -e "${CYAN}║${NC}                                              ${CYAN}║${NC}"
    echo -e "${CYAN}║${NC}  Tu IA privada:                              ${CYAN}║${NC}"
    echo -e "${CYAN}║${NC}  • 100% local, sin internet                  ${CYAN}║${NC}"
    echo -e "${CYAN}║${NC}  • Tus datos son solo tuyos                  ${CYAN}║${NC}"
    echo -e "${CYAN}║${NC}  • Software libre y gratuito                 ${CYAN}║${NC}"
    echo -e "${CYAN}║${NC}                                              ${CYAN}║${NC}"
    echo -e "${CYAN}║${NC}  ${YELLOW}apliarte.com${NC}                                ${CYAN}║${NC}"
    echo -e "${CYAN}║${NC}                                              ${CYAN}║${NC}"
    echo -e "${CYAN}╚══════════════════════════════════════════════╝${NC}"
    echo ""
else
    echo -e "${RED}  ❌ Error: $RESULT${NC}"
    exit 1
fi
