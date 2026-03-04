#!/bin/bash
# ============================================
# Deploy @ApliArteBot al VPS (DockerHostinger)
# ============================================
# EJECUTAR DESDE: Mac (VS Code terminal)
# REQUIERE: Acceso SSH al VPS
#
# USO:
#   bash scripts/deploy_apliarte_bot.sh
#
# ⚠️ CUIDADO: Este script modifica el VPS.
#    Revisar CADA paso antes de ejecutar.
#    Se pide confirmación antes de cambios críticos.
# ============================================

set -euo pipefail

# ─── CONFIGURACIÓN ───
VPS_USER="root"
VPS_HOST="<TU_IP_VPS>"
VPS_DIR="/home/apliarte/docker"
LOCAL_CONFIG="$(cd "$(dirname "$0")/../config/apliarte_bot" && pwd)"
OPENCLAW_FORK="$HOME/trabajo/openclaw"  # Ruta local del fork clonado

# ─── COLORES ───
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# ─── FUNCIONES ───
info()    { echo -e "${GREEN}[INFO]${NC} $1"; }
warn()    { echo -e "${YELLOW}[WARN]${NC} $1"; }
error()   { echo -e "${RED}[ERROR]${NC} $1"; exit 1; }

confirm() {
    echo -e "${YELLOW}[CONFIRMAR]${NC} $1"
    read -p "¿Continuar? (s/n): " -n 1 -r
    echo
    [[ $REPLY =~ ^[Ss]$ ]] || { echo "Cancelado."; exit 0; }
}

# ─── VERIFICACIONES ───
echo "============================================"
echo " Deploy @ApliArteBot al VPS"
echo "============================================"
echo ""

# Verificar que se ha configurado el host
if [ -z "$VPS_HOST" ]; then
    error "VPS_HOST no configurado. Edita este script y pon la IP/dominio del VPS."
fi

# Verificar archivos locales
info "Verificando archivos locales..."
[ -f "$LOCAL_CONFIG/openclaw.json" ]         || error "Falta: $LOCAL_CONFIG/openclaw.json"
[ -f "$LOCAL_CONFIG/workspace/SOUL.md" ]     || error "Falta: $LOCAL_CONFIG/workspace/SOUL.md"
[ -f "$LOCAL_CONFIG/workspace/IDENTITY.md" ] || error "Falta: $LOCAL_CONFIG/workspace/IDENTITY.md"
[ -f "$LOCAL_CONFIG/workspace/USER.md" ]     || error "Falta: $LOCAL_CONFIG/workspace/USER.md"
info "✅ Archivos locales OK"

# Verificar SSH
info "Verificando conexión SSH al VPS..."
ssh -q -o ConnectTimeout=5 "$VPS_USER@$VPS_HOST" "echo ok" > /dev/null 2>&1 \
    || error "No se puede conectar por SSH a $VPS_USER@$VPS_HOST"
info "✅ SSH OK"

echo ""
echo "─── PLAN DE DEPLOY ───"
echo "1. Crear estructura de carpetas en el VPS"
echo "2. Subir fork de OpenClaw al VPS (o clonar)"
echo "3. Buildear imagen Docker de OpenClaw"
echo "4. Subir config (openclaw.json + workspace)"
echo "5. Añadir variables al .env del VPS"
echo "6. Añadir servicio al docker-compose.yml"
echo "7. Arrancar el servicio"
echo ""
confirm "¿Proceder con el deploy?"

# ─── PASO 1: Estructura de carpetas ───
info "PASO 1: Creando estructura en el VPS..."
ssh "$VPS_USER@$VPS_HOST" "mkdir -p $VPS_DIR/services/apliarte-bot/{config,workspace}"
info "✅ Carpetas creadas"

# ─── PASO 2: Subir fork OpenClaw ───
info "PASO 2: Preparando OpenClaw..."
if [ -d "$OPENCLAW_FORK" ]; then
    confirm "¿Subir fork local de OpenClaw ($OPENCLAW_FORK) al VPS? (puede tardar)"
    # Crear tarball excluyendo node_modules y .git
    info "Creando tarball..."
    tar -czf /tmp/openclaw-fork.tar.gz -C "$OPENCLAW_FORK" \
        --exclude='node_modules' --exclude='.git' --exclude='dist' .
    info "Subiendo al VPS..."
    scp /tmp/openclaw-fork.tar.gz "$VPS_USER@$VPS_HOST:/tmp/"
    ssh "$VPS_USER@$VPS_HOST" "
        mkdir -p $VPS_DIR/services/apliarte-bot/openclaw
        cd $VPS_DIR/services/apliarte-bot/openclaw
        tar -xzf /tmp/openclaw-fork.tar.gz
        rm /tmp/openclaw-fork.tar.gz
    "
    rm /tmp/openclaw-fork.tar.gz
    info "✅ Fork subido"
else
    warn "Fork no encontrado en $OPENCLAW_FORK"
    confirm "¿Clonar desde GitHub? (git clone https://github.com/erbolamm/openclaw)"
    ssh "$VPS_USER@$VPS_HOST" "
        cd $VPS_DIR/services/apliarte-bot
        git clone https://github.com/erbolamm/openclaw.git openclaw
    "
    info "✅ Fork clonado"
fi

# ─── PASO 3: Build Docker ───
info "PASO 3: Buildeando imagen Docker de OpenClaw..."
confirm "¿Buildear imagen Docker? (puede tardar 5-10 minutos)"
ssh "$VPS_USER@$VPS_HOST" "
    cd $VPS_DIR/services/apliarte-bot/openclaw
    docker build -t openclaw:local .
"
info "✅ Imagen buildeada"

# ─── PASO 4: Subir config ───
info "PASO 4: Subiendo configuración..."
scp "$LOCAL_CONFIG/openclaw.json" "$VPS_USER@$VPS_HOST:$VPS_DIR/services/apliarte-bot/config/"
scp -r "$LOCAL_CONFIG/workspace/" "$VPS_USER@$VPS_HOST:$VPS_DIR/services/apliarte-bot/"
info "✅ Config subida"

# ─── PASO 5: Variables .env ───
info "PASO 5: Verificando variables en .env del VPS..."
warn "Las siguientes variables deben estar en $VPS_DIR/.env:"
echo "  APLIARTE_BOT_TOKEN=TU_TELEGRAM_TOKEN_AQUI"
echo "  APLIARTE_GATEWAY_TOKEN=<generar con: openssl rand -hex 32>"
echo "  BRAVE_API_KEY=TU_BRAVE_KEY_AQUI"
echo "  DEEPSEEK_API_KEY=TU_DEEPSEEK_KEY_AQUI"
echo ""
confirm "¿Las variables ya están en el .env del VPS? (Si no, añádelas manualmente)"

# ─── PASO 6: docker-compose ───
info "PASO 6: Servicio docker-compose..."
warn "El fragmento de docker-compose debe añadirse MANUALMENTE al archivo del VPS."
warn "Archivo local de referencia: config/apliarte_bot/docker-compose-fragment.yml"
echo ""
confirm "¿Ya añadiste el servicio apliarte-bot al docker-compose.yml del VPS?"

# ─── PASO 7: Arrancar ───
info "PASO 7: Arrancando @ApliArteBot..."
confirm "¿ARRANCAR el servicio? (docker compose up -d apliarte-bot)"
ssh "$VPS_USER@$VPS_HOST" "
    cd $VPS_DIR
    docker compose up -d apliarte-bot
"
info "✅ @ApliArteBot arrancado"

# ─── VERIFICACIÓN ───
echo ""
info "Verificando que está corriendo..."
sleep 5
ssh "$VPS_USER@$VPS_HOST" "docker logs --tail 20 apliarte-bot"

echo ""
echo "============================================"
echo -e "${GREEN} ✅ Deploy completado${NC}"
echo "============================================"
echo ""
echo "Próximos pasos:"
echo "1. Envía un mensaje a @ApliArteBot en Telegram"
echo "2. Verifica que responde"
echo "3. Añade monitor en Uptime Kuma"
echo "4. Prueba los comandos: /coach, /familia, /legado"
echo ""
