#!/bin/bash
# ============================================================
#  🦀 ClawMobil - Setup completo de servidor IA en teléfono
#  Instala: Termux + proot-distro Ubuntu + Ollama + Modelo
#  Método: proot-distro (funciona en Android 12-15+)
#  Por Francisco (Apliarte) - apliarte.com
# ============================================================

RED='\033[0;31m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
BOLD='\033[1m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
TERMUX_APK="/tmp/termux_fdroid.apk"

echo ""
echo -e "${CYAN}╔══════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║${NC}  ${BOLD}🦀 ClawMobil - Setup Servidor IA${NC}            ${CYAN}║${NC}"
echo -e "${CYAN}║${NC}     Método: proot-distro + Ubuntu             ${CYAN}║${NC}"
echo -e "${CYAN}╚══════════════════════════════════════════════╝${NC}"
echo ""

# ---- Detectar dispositivo ----
DEVICE=$(adb devices 2>/dev/null | grep -w "device" | head -1 | awk '{print $1}')
if [ -z "$DEVICE" ]; then
    echo -e "${RED}❌ No hay teléfono conectado${NC}"
    echo "  Conecta el teléfono por USB y acepta 'Depuración USB'"
    exit 1
fi

MODEL=$(adb -s "$DEVICE" shell getprop ro.product.model 2>/dev/null | tr -d '\r')
ANDROID=$(adb -s "$DEVICE" shell getprop ro.build.version.release 2>/dev/null | tr -d '\r')
ARCH=$(adb -s "$DEVICE" shell getprop ro.product.cpu.abi 2>/dev/null | tr -d '\r')
RAM=$(adb -s "$DEVICE" shell cat /proc/meminfo 2>/dev/null | grep MemTotal | awk '{printf "%.1f GB", $2/1024/1024}')

echo -e "${GREEN}📱 ${BOLD}$MODEL${NC} ${GREEN}(Android $ANDROID, $ARCH, $RAM)${NC}"
echo ""

if [ "$ARCH" != "arm64-v8a" ]; then
    echo -e "${RED}❌ CPU no compatible. Se necesita arm64 pero tienes: $ARCH${NC}"
    exit 1
fi

# ---- Paso 1: Instalar Termux ----
echo -e "${BOLD}[1/6]${NC} Instalando Termux..."
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

# ---- Paso 2: Abrir Termux e inicializar ----
echo ""
echo -e "${BOLD}[2/6]${NC} Inicializando Termux..."
adb -s "$DEVICE" shell am start -n com.termux/.app.TermuxActivity > /dev/null 2>&1
adb -s "$DEVICE" shell dumpsys deviceidle whitelist +com.termux > /dev/null 2>&1
echo -e "${YELLOW}  ⏳ Esperando inicialización (20s)...${NC}"
sleep 20
echo -e "${GREEN}  ✅ Termux abierto y batería sin restricciones${NC}"

# ---- Paso 3: Crear script de setup para dentro de Termux ----
echo ""
echo -e "${BOLD}[3/6]${NC} Preparando script de instalación..."

cat > /tmp/claw_setup.sh << 'TERMUX_SCRIPT'
#!/data/data/com.termux/files/usr/bin/bash
echo "🦀 Instalando el cerebro de Claw..."
echo ""
echo "[1/4] Actualizando Termux..."
pkg update -y 2>/dev/null
pkg upgrade -y 2>/dev/null

echo "[2/4] Instalando proot-distro..."
pkg install -y proot-distro 2>/dev/null

echo "[3/4] Instalando Ubuntu (esto tarda 1-2 minutos)..."
proot-distro install ubuntu 2>/dev/null

echo "[4/4] Instalando Ollama dentro de Ubuntu..."
proot-distro login ubuntu -- bash -c 'curl -fsSL https://ollama.com/install.sh | sh' 2>/dev/null

echo ""
echo "✅ ¡Cerebro de Claw instalado!"
echo ""
echo "🚀 Arrancando Ollama..."
proot-distro login ubuntu -- bash -c 'export OLLAMA_HOST=0.0.0.0:11434 && ollama serve' &
sleep 5

echo "📥 Descargando modelo de IA (395MB, espera unos minutos)..."
proot-distro login ubuntu -- bash -c 'ollama pull qwen2.5:0.5b'

echo ""
echo "🎉 ¡TODO LISTO! Claw tiene cerebro."
echo ""
echo "Para arrancar Claw en el futuro:"
echo "  bash /sdcard/start_claw.sh"
TERMUX_SCRIPT

# Script de arranque rápido (para usar después)
cat > /tmp/start_claw.sh << 'START_SCRIPT'
#!/data/data/com.termux/files/usr/bin/bash
echo "🦀 Arrancando Claw..."
proot-distro login ubuntu -- bash -c 'export OLLAMA_HOST=0.0.0.0:11434 && ollama serve' &
sleep 3
echo "✅ Claw está lista. Abre la app ClawMobil Chat."
START_SCRIPT

adb -s "$DEVICE" push /tmp/claw_setup.sh /sdcard/claw_setup.sh > /dev/null 2>&1
adb -s "$DEVICE" push /tmp/start_claw.sh /sdcard/start_claw.sh > /dev/null 2>&1
echo -e "${GREEN}  ✅ Scripts subidos al teléfono${NC}"

# ---- Paso 4: Ejecutar setup en Termux ----
echo ""
echo -e "${BOLD}[4/6]${NC} ${CYAN}Ejecutando instalación en Termux...${NC}"
echo -e "${YELLOW}  📱 Mira la pantalla del teléfono — verás el progreso${NC}"
adb -s "$DEVICE" shell "input text 'bash%s/sdcard/claw_setup.sh'" 2>/dev/null
sleep 1
adb -s "$DEVICE" shell "input keyevent 66" 2>/dev/null

echo -e "${YELLOW}  ⏳ Esto tarda 5-10 minutos. El script:${NC}"
echo -e "     1. Actualiza Termux"
echo -e "     2. Instala proot-distro"
echo -e "     3. Descarga Ubuntu dentro de Termux"
echo -e "     4. Instala Ollama dentro de Ubuntu"
echo -e "     5. Descarga el modelo de IA (395MB)"
echo ""
echo -e "${YELLOW}  👀 Vigila la pantalla del teléfono.${NC}"
echo -e "${YELLOW}     Cuando veas '🎉 ¡TODO LISTO!', sigue al paso 5.${NC}"
echo ""
read -p "  Pulsa Enter cuando veas '🎉 ¡TODO LISTO!' en el teléfono... "

# ---- Paso 5: Instalar App ClawMobil ----
echo ""
echo -e "${BOLD}[5/6]${NC} Instalando ClawMobil Chat..."
APK=""
for path in \
    "$SCRIPT_DIR/ClawMobil-Chat.apk" \
    "$SCRIPT_DIR/../public/ClawMobil-Chat.apk" \
    "$SCRIPT_DIR/../demo/ClawMobil-Chat.apk"; do
    if [ -f "$path" ]; then
        APK="$path"
        break
    fi
done

if [ -n "$APK" ]; then
    adb -s "$DEVICE" install -r "$APK" > /dev/null 2>&1
    echo -e "${GREEN}  ✅ App instalada${NC}"
else
    echo -e "${YELLOW}  ⚠️ APK no encontrada. Búscala en demo/ o public/${NC}"
fi

# ---- Paso 6: Verificar ----
echo ""
echo -e "${BOLD}[6/6]${NC} Verificando..."
sleep 2
RESPONSE=$(adb -s "$DEVICE" shell "curl -s http://localhost:11434/api/tags" 2>/dev/null)
if echo "$RESPONSE" | grep -q "qwen"; then
    echo -e "${GREEN}  ✅ Ollama respondiendo con modelo qwen2.5:0.5b${NC}"
else
    echo -e "${YELLOW}  ⚠️ Ollama puede tardar unos segundos en arrancar${NC}"
fi

echo ""
echo -e "${CYAN}╔══════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║${NC}                                              ${CYAN}║${NC}"
echo -e "${CYAN}║${NC}  ${GREEN}${BOLD}🦀 ¡Claw instalada en $MODEL!${NC}"
echo -e "${CYAN}║${NC}                                              ${CYAN}║${NC}"
echo -e "${CYAN}║${NC}  ${BOLD}Abre la app ClawMobil Chat y habla${NC}          ${CYAN}║${NC}"
echo -e "${CYAN}║${NC}  con tu IA privada. 100% local.              ${CYAN}║${NC}"
echo -e "${CYAN}║${NC}                                              ${CYAN}║${NC}"
echo -e "${CYAN}║${NC}  Para arrancar Claw tras reiniciar:          ${CYAN}║${NC}"
echo -e "${CYAN}║${NC}  1. Abre Termux                              ${CYAN}║${NC}"
echo -e "${CYAN}║${NC}  2. Escribe: ${YELLOW}bash /sdcard/start_claw.sh${NC}      ${CYAN}║${NC}"
echo -e "${CYAN}║${NC}  3. Abre ClawMobil Chat                      ${CYAN}║${NC}"
echo -e "${CYAN}║${NC}                                              ${CYAN}║${NC}"
echo -e "${CYAN}║${NC}  ${YELLOW}apliarte.com${NC}                                ${CYAN}║${NC}"
echo -e "${CYAN}╚══════════════════════════════════════════════╝${NC}"
echo ""
