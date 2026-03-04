#!/bin/bash
# ═══════════════════════════════════════════════════════════════
# 🦞 RECOVERY FASE 2 — Configurar Termux + PRoot + OpenClaw
# ═══════════════════════════════════════════════════════════════
# Ejecutar desde: MAC (VS Code terminal)
# Requisito: Termux ya instalado y abierto al menos una vez
# ═══════════════════════════════════════════════════════════════

SERIAL="NOTE10PRO000400"
ADB="adb -s $SERIAL"
OK='\033[1;32m✅\033[0m'
ERR='\033[1;31m❌\033[0m'
INFO='\033[1;36mℹ️\033[0m'

echo ""
echo "═══════════════════════════════════════════════════════════"
echo "  🦞 RECOVERY FASE 2 — Termux + PRoot + OpenClaw"
echo "═══════════════════════════════════════════════════════════"
echo ""

# ── Verificar dispositivo ────────────────────────────────────
if ! adb devices | tr -d '\r' | grep -q "${SERIAL}.*device"; then
    echo -e "${ERR} Dispositivo $SERIAL no encontrado."
    exit 1
fi

# ── PASO 1: Configurar Termux básico ────────────────────────
echo -e "${INFO} Paso 1: Configurando Termux..."

# Dar permisos de almacenamiento y ejecutar setup
$ADB shell "run-as com.termux mkdir -p /data/data/com.termux/files/home/.termux" 2>/dev/null

# Ejecutar comandos dentro de Termux usando am broadcast
# Método: escribir un script en /sdcard/ y ejecutarlo desde Termux

cat > /tmp/termux_setup_fase1.sh << 'TERMUX_SCRIPT'
#!/data/data/com.termux/files/usr/bin/bash
# === Termux Setup Fase 1 ===

echo "🔧 Configurando Termux..."

# 1. Actualizar paquetes
pkg update -y && pkg upgrade -y

# 2. Instalar paquetes esenciales
pkg install -y \
    termux-api \
    openssh \
    proot-distro \
    git \
    curl \
    wget \
    jq \
    python \
    espeak \
    nano \
    screen \
    nmap \
    net-tools \
    fuse

echo "✅ Paquetes base instalados"

# 3. Configurar SSH
sshd
echo "✅ SSH activado en puerto 8022"

# 4. Configurar almacenamiento compartido
termux-setup-storage <<< "y"
echo "✅ Almacenamiento compartido configurado"

# 5. Instalar PRoot Debian
echo "📦 Instalando PRoot Debian..."
proot-distro install debian

echo "✅ PRoot Debian instalado"

# 6. Configurar boot automático
mkdir -p ~/.termux/boot
cp /sdcard/boot_autostart.sh ~/.termux/boot/boot_autostart.sh
chmod +x ~/.termux/boot/boot_autostart.sh
echo "✅ AutoBoot configurado"

# 7. Instalar bridge scripts en PATH
echo "📦 Instalando bridge scripts..."
BRIDGE_DIR="/sdcard/bridge_scripts"
BIN_DIR="/data/data/com.termux/files/usr/bin"

if [ -d "$BRIDGE_DIR" ]; then
    for script in "$BRIDGE_DIR"/*; do
        fname=$(basename "$script")
        cp "$script" "$BIN_DIR/$fname"
        chmod +x "$BIN_DIR/$fname"
        echo "  ✅ Bridge: $fname"
    done
fi

echo ""
echo "🎉 Termux Fase 1 completada"
echo "Ahora ejecuta el setup de Debian:"
echo "  proot-distro login debian -- bash /sdcard/debian_setup.sh"
TERMUX_SCRIPT

$ADB push /tmp/termux_setup_fase1.sh /sdcard/termux_setup_fase1.sh >/dev/null 2>&1
echo -e "${OK} Script termux_setup_fase1.sh subido a /sdcard/"

# ── PASO 2: Crear script de setup para Debian ───────────────
echo -e "${INFO} Paso 2: Preparando script de Debian..."

cat > /tmp/debian_setup.sh << 'DEBIAN_SCRIPT'
#!/bin/bash
# === Debian PRoot Setup para OpenClaw ===

echo "🔧 Configurando Debian PRoot..."

# 1. Actualizar sistema
apt update && apt upgrade -y

# 2. Instalar dependencias
apt install -y \
    curl \
    wget \
    git \
    python3 \
    python3-pip \
    nodejs \
    npm \
    espeak-ng \
    nano \
    screen \
    jq \
    build-essential \
    ca-certificates

echo "✅ Dependencias base instaladas"

# 3. Instalar OpenClaw
echo "📦 Instalando OpenClaw..."
npm install -g openclaw@latest 2>/dev/null || {
    echo "⚠️ npm install falló, intentando con npx..."
    npx openclaw --version 2>/dev/null
}

# Verificar OpenClaw
if command -v openclaw &>/dev/null; then
    echo "✅ OpenClaw instalado: $(openclaw --version 2>/dev/null)"
else
    echo "⚠️ OpenClaw no en PATH, verificar instalación manual"
fi

# 4. Configurar Git
git config --global user.name "ApliBot"
git config --global user.email "erbolamm@gmail.com"
echo "✅ Git configurado"

# 5. Configurar token de GitHub
GITHUB_TOKEN="TU_TOKEN_AQUI"

git config --global credential.helper store
echo "https://erbolamm:${GITHUB_TOKEN}@github.com" > ~/.git-credentials
chmod 600 ~/.git-credentials
echo "✅ Credenciales Git almacenadas"

# 6. Clonar repos del bot
echo "📦 Clonando repositorios..."
cd ~

# Web
git clone "https://erbolamm:${GITHUB_TOKEN}@github.com/erbolamm/aplibot-web.git" ~/web 2>/dev/null
if [ -d ~/web ]; then
    echo "✅ Repo web clonado en ~/web"
else
    echo "❌ Error clonando repo web"
fi

# Memoria
git clone "https://erbolamm:${GITHUB_TOKEN}@github.com/erbolamm/aplibot-memoria.git" ~/memoria 2>/dev/null
if [ -d ~/memoria ]; then
    echo "✅ Repo memoria clonado en ~/memoria"
else
    echo "❌ Error clonando repo memoria"
fi

# 7. Configurar OpenClaw (si existe)
if command -v openclaw &>/dev/null; then
    echo "🦞 Configurando OpenClaw..."
    
    # Crear configuración
    mkdir -p ~/.config/openclaw
    
    cat > ~/.config/openclaw/config.yaml << 'OCCONFIG'
telegram:
  token: "TU_TELEGRAM_TOKEN_AQUI"
  allowed_user_ids:
    - TU_ID_AQUI

gateway:
  port: 18789
  bind: "127.0.0.1"

model:
  provider: "groq"
  name: "llama-3.3-70b-versatile"
  api_key: "TU_GROQ_KEY_AQUI"

brave_search:
  api_key: "TU_BRAVE_KEY_AQUI"
OCCONFIG

    echo "✅ OpenClaw configurado"
fi

# 8. Instalar espeak-ng para TTS
if command -v espeak-ng &>/dev/null; then
    echo "✅ espeak-ng ya instalado"
else
    apt install -y espeak-ng
fi

echo ""
echo "══════════════════════════════════════════════"
echo "  🎉 DEBIAN SETUP COMPLETADO"
echo "══════════════════════════════════════════════"
echo ""
echo "Para iniciar OpenClaw:"
echo "  nohup openclaw gateway run --port 18789 --bind 127.0.0.1 > ~/openclaw.log 2>&1 &"
echo ""
echo "Para verificar:"
echo "  curl http://127.0.0.1:18789/health"
echo ""
DEBIAN_SCRIPT

$ADB push /tmp/debian_setup.sh /sdcard/debian_setup.sh >/dev/null 2>&1
echo -e "${OK} Script debian_setup.sh subido a /sdcard/"

# ── PASO 3: Instrucciones finales ────────────────────────────
echo ""
echo "═══════════════════════════════════════════════════════════"
echo "  PASOS A EJECUTAR EN EL TELÉFONO"
echo "═══════════════════════════════════════════════════════════"
echo ""
echo "  1. Abrir Termux y ejecutar:"
echo "     bash /sdcard/termux_setup_fase1.sh"
echo ""
echo "  2. Cuando termine, ejecutar setup de Debian:"
echo "     proot-distro login debian -- bash /sdcard/debian_setup.sh"
echo ""
echo "  3. Verificar que todo funciona:"
echo "     proot-distro login debian -- openclaw --version"
echo ""
echo "  4. Ejecutar debloat desde Mac:"
echo "     bash scripts/debloat_yestel_note30pro.sh"
echo ""
echo "═══════════════════════════════════════════════════════════"
