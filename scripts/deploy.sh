#!/bin/bash
# ============================================
# 🚀 DEPLOY ClawMobil al teléfono via ADB
# ============================================
# Ejecutar desde Mac/Linux con el teléfono conectado por USB.
# Este script hace TODO: build, install, push archivos, arrancar servidor.
#
# USO:
#   cd /ruta/a/ClawMobil
#   bash scripts/deploy.sh
#
# REQUISITOS:
#   - ADB instalado (brew install android-platform-tools)
#   - Flutter instalado
#   - Teléfono conectado USB con depuración USB activa
#   - Termux instalado en el teléfono
# ============================================

# No usar set -e: queremos que el script continúe aunque falle algún paso no crítico
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
APP_DIR="$PROJECT_ROOT/app"
AVATAR_DIR="$PROJECT_ROOT/avatar"

# Colores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log() { echo -e "${GREEN}✅ $1${NC}"; }
warn() { echo -e "${YELLOW}⚠️  $1${NC}"; }
err() { echo -e "${RED}❌ $1${NC}"; exit 1; }
step() { echo -e "\n${BLUE}━━━ $1 ━━━${NC}"; }

# ============================================
# 0. Parsing de argumentos
# ============================================
SKIP_APK=false
SERVER_ONLY=false

for arg in "$@"; do
    case $arg in
        --no-apk)
            SKIP_APK=true
            shift
            ;;
        --server-only)
            SERVER_ONLY=true
            SKIP_APK=true
            shift
            ;;
    esac
done

# ============================================
# 1. Verificar teléfono conectado
# ============================================
step "1/6 Verificando conexión ADB"

if ! command -v adb &> /dev/null; then
    err "ADB no instalado. Ejecuta: brew install android-platform-tools"
fi

DEVICE=$(adb devices | grep -w "device" | head -1 | awk '{print $1}')
if [ -z "$DEVICE" ]; then
    err "No se detecta ningún teléfono.\n   → Conecta el teléfono USB\n   → Activa Depuración USB en Ajustes > Opciones de desarrollador"
fi
log "Teléfono detectado: $DEVICE"

# Verificar que Termux está instalado
if ! adb shell pm list packages 2>/dev/null | grep -q "com.termux"; then
    err "Termux no está instalado en el teléfono.\n   → Instálalo desde F-Droid: https://f-droid.org/packages/com.termux/"
fi
log "Termux detectado"

# ============================================
# 2. Build APK
# ============================================
if [ "$SKIP_APK" = true ]; then
    warn "Saltando paso de compilación APK"
else
    step "2/6 Compilando APK"
    cd "$APP_DIR"
    flutter build apk --debug 2>&1 | tail -3
    APK_PATH="$APP_DIR/build/app/outputs/flutter-apk/app-debug.apk"

    if [ ! -f "$APK_PATH" ]; then
        err "No se generó el APK"
    fi
    log "APK compilado"
fi

# ============================================
# 3. Instalar APK
# ============================================
if [ "$SKIP_APK" = true ]; then
    warn "Saltando paso de instalación APK"
else
    step "3/6 Instalando APK en el teléfono"
    adb install -r "$APK_PATH" 2>&1
    log "APK instalado"
fi

# ============================================
# 4. Push archivos al teléfono
# ============================================
step "4/6 Subiendo archivos al teléfono"

# server.py (cerebro principal)
# Lo subimos tanto a la raíz como a /avatar para asegurar que find_file lo encuentre
adb shell "mkdir -p /sdcard/avatar" 2>/dev/null
adb push "$AVATAR_DIR/server.py" /sdcard/server.py
adb push "$AVATAR_DIR/server.py" /sdcard/avatar/server.py
adb push "$AVATAR_DIR/factory.html" /sdcard/avatar/factory.html
adb push "$AVATAR_DIR/factory.css" /sdcard/avatar/factory.css
adb push "$AVATAR_DIR/factory.js" /sdcard/avatar/factory.js
log "Archivos de Avatar y server.py subidos"

# Scripts de utilidad
adb push "$SCRIPT_DIR/fix_openclaw_config.sh" /sdcard/fix_openclaw_config.sh 2>/dev/null && \
    log "fix_openclaw_config.sh subido" || warn "No se pudo subir fix_openclaw_config.sh"

adb push "$SCRIPT_DIR/boot_openclaw.sh" /sdcard/boot_openclaw.sh 2>/dev/null && \
    log "boot_openclaw.sh subido" || warn "No se pudo subir boot_openclaw.sh"

adb push "$SCRIPT_DIR/restart_all.sh" /sdcard/restart_all.sh 2>/dev/null && \
    log "restart_all.sh subido" || warn "No se pudo subir restart_all.sh"

adb push "$SCRIPT_DIR/set_brave_search.sh" /sdcard/set_brave_search.sh 2>/dev/null && \
    log "set_brave_search.sh subido" || warn "No se pudo subir set_brave_search.sh"

# ============================================
# 5. Ejecutar fix config via Termux RUN_COMMAND
# ============================================
step "5/6 Configurando OpenClaw en Termux"

# Usamos el intent RUN_COMMAND de Termux (requiere "Allow External Apps" en Termux > Settings)
# Es mucho más fiable que simular teclado con 'input text'
RUN="am broadcast --user 0 \
  -a com.termux.RUN_COMMAND \
  --es com.termux.RUN_COMMAND_PATH '/data/data/com.termux/files/usr/bin/bash' \
  --esa 'com.termux.RUN_COMMAND_ARGUMENTS' '-l,-c,bash /sdcard/fix_openclaw_config.sh > /sdcard/avatar/fix.log 2>&1' \
  --ez com.termux.RUN_COMMAND_BACKGROUND true \
  com.termux"

adb shell "$RUN" 2>/dev/null
log "Fix config enviado a Termux (en background)"
sleep 4

# ============================================
# 6. Arrancar server.py y OpenClaw
# ============================================
step "6/6 Arrancando servidor (restart_all.sh)"

RUN_RESTART="am broadcast --user 0 \
  -a com.termux.RUN_COMMAND \
  --es com.termux.RUN_COMMAND_PATH '/data/data/com.termux/files/usr/bin/bash' \
  --esa 'com.termux.RUN_COMMAND_ARGUMENTS' '-l,-c,bash /sdcard/restart_all.sh > /sdcard/avatar/restart.log 2>&1' \
  --ez com.termux.RUN_COMMAND_BACKGROUND true \
  com.termux"

adb shell "$RUN_RESTART" 2>/dev/null
log "restart_all.sh enviado a Termux (en background)"

# ============================================
# RESUMEN
# ============================================
echo ""
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}  🚀 DEPLOY COMPLETADO${NC}"
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
if [ "$SKIP_APK" = true ]; then
    echo -e "  ⏸️  APK (saltado)"
else
    echo -e "  📱 APK instalado"
fi
echo -e "  📂 server.py subido a /sdcard/"
echo -e "  ⚙️  Scripts de boot subidos a /sdcard/"
echo ""

echo ""
echo -e "  ${YELLOW}Si algún paso dio ⚠️, abre Termux y ejecuta:${NC}"
echo -e "  ${BLUE}bash /sdcard/fix_openclaw_config.sh${NC}"
echo -e "  ${BLUE}cd /sdcard/avatar && python3 server.py &${NC}"
echo ""
echo -e "  ${GREEN}¡Todo listo! 🎉${NC}"
