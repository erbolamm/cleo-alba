#!/data/data/com.termux/files/usr/bin/bash
# ═══════════════════════════════════════════════════════════════
# 🧠 SETUP BRAIN — La Fábrica (Cerebro Offline)
# Compila llama.cpp nativamente y configura el modelo de IA local
# ═══════════════════════════════════════════════════════════════

set -e # Detener si hay un error crítico

# Colores para feedback en la consola
GREEN='\033[1;32m'
CYAN='\033[1;36m'
RED='\033[1;31m'
NC='\033[0m'

echo -e "${CYAN}🚀 Iniciando Setup Brain (La Fábrica)...${NC}"

# ─── 1. Preparación Segura ──────────────────────────────────────
echo -e "\n${CYAN}[1/4] Actualizando sistema e instalando dependencias puras...${NC}"
pkg update -y && pkg upgrade -y
pkg install -y git cmake make clang wget android-tools
echo -e "${GREEN}✅ Dependencias instaladas correctamente.${NC}"

# ─── 2. Compilación de llama.cpp ────────────────────────────────
echo -e "\n${CYAN}[2/4] Clonando y compilando llama.cpp...${NC}"
cd $HOME

if [ -d "llama.cpp" ]; then
    echo "📁 llama.cpp ya existe, actualizando repositorio..."
    cd llama.cpp
    git pull
else
    echo "⬇️ Clonando repositorio oficial de llama.cpp..."
    git clone https://github.com/ggerganov/llama.cpp
    cd llama.cpp
fi

echo "⚙️ Compilando (esto puede tardar unos minutos en hardware móvil)..."
# Compilamos usando make, aprovechando los núcleos del procesador ARM
make -j4
echo -e "${GREEN}✅ llama.cpp compilado exitosamente.${NC}"

# ─── 3. Descarga de Modelo Ligero ───────────────────────────────
# qwen1_5-1_8b-chat-q4_k_m.gguf pesa alrededor de 1.1GB, ideal para 3-4GB de RAM
echo -e "\n${CYAN}[3/4] Comprobando modelo LLM ligero (Qwen-1.5 1.8B Q4)...${NC}"
mkdir -p models/Qwen
MODEL_URL="https://huggingface.co/Qwen/Qwen1.5-1.8B-Chat-GGUF/resolve/main/qwen1_5-1_8b-chat-q4_k_m.gguf"
MODEL_FILE="models/Qwen/qwen1_5-1_8b-chat-q4_k_m.gguf"

if [ -f "$MODEL_FILE" ]; then
    echo -e "${GREEN}✅ El modelo ya está descargado en $MODEL_FILE.${NC}"
else
    echo "⬇️ Descargando el modelo ligero para funcionar offline..."
    # Descarga directa desde HuggingFace
    wget -O "$MODEL_FILE" "$MODEL_URL"
    echo -e "${GREEN}✅ Modelo descargado.${NC}"
fi

# ─── 4. Configuración de ADB Local ──────────────────────────────
echo -e "\n${CYAN}[4/4] Configurando puente ADB Local (Loopback)...${NC}"
echo "🔌 Intentando conectar el servidor ADB a localhost:5555..."

# Iniciar servidor si no está corriendo
adb start-server

# Intentar conectar
if adb connect 127.0.0.1:5555 | grep -q 'connected'; then
    echo -e "${GREEN}✅ ADB conectado exitosamente a localhost:5555.${NC}"
    echo "📱 Dispositivos disponibles:"
    adb devices
else
    echo -e "${RED}⚠️ No se pudo conectar ADB al propio dispositivo.${NC}"
    echo -e "${RED}IMPORTANTE: Para que el autómata pueda controlarse a sí mismo, debes habilitar TCP/IP.${NC}"
    echo -e "Pasos a seguir:"
    echo -e "1. Conecta el móvil al ordenador por cable."
    echo -e "2. Ejecuta en el ordenador: 'adb tcpip 5555'"
    echo -e "3. Una vez hecho, vuelve a ejecutar este script o 'adb connect 127.0.0.1:5555'."
fi

echo -e "\n${GREEN}🎉 SETUP COMPLETADO. El 'cerebro' offline está preparado.${NC}"
echo -e "Próximo paso: Ejecutar el puente de Python (brain_bridge.py)."
