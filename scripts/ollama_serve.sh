#!/bin/bash
# ============================================
# 🧠 Ollama Server Manager — ClawMobil
# ============================================
# Gestiona el servidor Ollama en cualquier plataforma.
# Compatible con: Termux (Android), Mac, Linux, Docker.
#
# USO:
#   bash scripts/ollama_serve.sh start     # Arranca el servidor
#   bash scripts/ollama_serve.sh stop      # Para el servidor
#   bash scripts/ollama_serve.sh status    # Estado + modelos
#   bash scripts/ollama_serve.sh pull      # Descarga modelo recomendado
#   bash scripts/ollama_serve.sh test      # Test rápido de la API
#   bash scripts/ollama_serve.sh health    # Health check (para monitoreo)
# ============================================

set -euo pipefail

# ── Configuración ─────────────────────────────────────────────────

OLLAMA_HOST="${OLLAMA_HOST:-http://127.0.0.1:11434}"
OLLAMA_PORT="${OLLAMA_PORT:-11434}"

# Modelo por defecto según RAM disponible
detect_recommended_model() {
    local ram_gb=4
    if command -v free &>/dev/null; then
        ram_gb=$(free -g 2>/dev/null | awk '/^Mem:/{print $2}' || echo 4)
    elif [[ "$(uname)" == "Darwin" ]]; then
        ram_gb=$(( $(sysctl -n hw.memsize 2>/dev/null || echo 4294967296) / 1073741824 ))
    fi

    if (( ram_gb >= 8 )); then
        echo "llama3.2:3b"
    elif (( ram_gb >= 4 )); then
        echo "gemma2:2b"
    elif (( ram_gb >= 2 )); then
        echo "llama3.2:1b"
    else
        echo "qwen2.5:0.5b"
    fi
}

OLLAMA_MODEL="${OLLAMA_MODEL:-$(detect_recommended_model)}"

# ── Colores ───────────────────────────────────────────────────────

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color
BOLD='\033[1m'

# ── Utilidades ────────────────────────────────────────────────────

log_info()  { echo -e "${GREEN}✅${NC} $*"; }
log_warn()  { echo -e "${YELLOW}⚠️${NC}  $*"; }
log_error() { echo -e "${RED}❌${NC} $*"; }
log_step()  { echo -e "${BLUE}▶${NC}  $*"; }
log_brain() { echo -e "${PURPLE}🧠${NC} $*"; }

is_ollama_running() {
    curl -sf "${OLLAMA_HOST}/api/tags" > /dev/null 2>&1
}

detect_platform() {
    if [ -d "/data/data/com.termux" ]; then
        echo "termux"
    elif [[ "$(uname)" == "Darwin" ]]; then
        echo "mac"
    elif command -v docker &>/dev/null; then
        echo "docker"
    else
        echo "linux"
    fi
}

# ── Comandos ──────────────────────────────────────────────────────

cmd_start() {
    echo ""
    log_brain "${BOLD}Arrancando servidor Ollama...${NC}"
    echo ""

    if is_ollama_running; then
        log_info "Ollama ya está corriendo en ${CYAN}${OLLAMA_HOST}${NC}"
        cmd_status
        return 0
    fi

    local platform=$(detect_platform)
    log_step "Plataforma detectada: ${CYAN}${platform}${NC}"

    case "$platform" in
        termux)
            # En Termux, intentar primero nativo, luego PRoot Debian
            if command -v ollama &>/dev/null; then
                log_step "Arrancando Ollama nativo en Termux..."
                export OLLAMA_HOST="0.0.0.0:${OLLAMA_PORT}"
                nohup ollama serve > /tmp/ollama.log 2>&1 &
            elif command -v proot-distro &>/dev/null; then
                log_step "Arrancando Ollama dentro de PRoot Debian..."
                proot-distro login debian -- bash -c "
                    export OLLAMA_MODELS=/sdcard/ollama_models
                    export OLLAMA_HOST=0.0.0.0:${OLLAMA_PORT}
                    mkdir -p /sdcard/ollama_models
                    nohup ollama serve > /tmp/ollama.log 2>&1 &
                "
            else
                log_error "Ollama no encontrado. Instala con: pkg install ollama"
                exit 1
            fi
            ;;
        mac)
            if command -v ollama &>/dev/null; then
                log_step "Arrancando Ollama en Mac..."
                OLLAMA_HOST="0.0.0.0:${OLLAMA_PORT}" nohup ollama serve > /tmp/ollama.log 2>&1 &
            else
                log_error "Ollama no instalado. Instala con: brew install ollama"
                exit 1
            fi
            ;;
        docker)
            log_step "Arrancando Ollama con Docker..."
            docker run -d \
                --name clawmobil-ollama \
                -p "${OLLAMA_PORT}:11434" \
                -v ollama_data:/root/.ollama \
                --restart unless-stopped \
                ollama/ollama
            ;;
        linux)
            if command -v ollama &>/dev/null; then
                log_step "Arrancando Ollama en Linux..."
                OLLAMA_HOST="0.0.0.0:${OLLAMA_PORT}" nohup ollama serve > /tmp/ollama.log 2>&1 &
            else
                log_error "Ollama no instalado. Instala con: curl -fsSL https://ollama.com/install.sh | sh"
                exit 1
            fi
            ;;
    esac

    # Esperar a que arranque
    log_step "Esperando que Ollama responda..."
    for i in $(seq 1 30); do
        if is_ollama_running; then
            echo ""
            log_info "Ollama arrancado correctamente en ${CYAN}${OLLAMA_HOST}${NC}"
            cmd_status
            return 0
        fi
        sleep 1
        printf "."
    done

    echo ""
    log_error "Ollama no respondió tras 30 segundos."
    echo "   Revisa los logs: cat /tmp/ollama.log"
    return 1
}

cmd_stop() {
    echo ""
    log_brain "${BOLD}Deteniendo servidor Ollama...${NC}"

    local platform=$(detect_platform)

    case "$platform" in
        docker)
            docker stop clawmobil-ollama 2>/dev/null && docker rm clawmobil-ollama 2>/dev/null
            ;;
        *)
            pkill -f "ollama serve" 2>/dev/null || true
            ;;
    esac

    sleep 2
    if is_ollama_running; then
        log_warn "Ollama todavía está corriendo."
    else
        log_info "Ollama detenido."
    fi
}

cmd_status() {
    echo ""
    echo -e "${PURPLE}╔══════════════════════════════════════════╗${NC}"
    echo -e "${PURPLE}║${NC}    ${BOLD}🧠 Estado del Servidor Ollama${NC}          ${PURPLE}║${NC}"
    echo -e "${PURPLE}╚══════════════════════════════════════════╝${NC}"
    echo ""

    if ! is_ollama_running; then
        log_error "Ollama NO está corriendo en ${OLLAMA_HOST}"
        echo ""
        echo "   Para arrancar: bash scripts/ollama_serve.sh start"
        return 1
    fi

    log_info "Servidor: ${CYAN}${OLLAMA_HOST}${NC}"
    echo ""

    # Listar modelos instalados
    echo -e "${BOLD}📦 Modelos instalados:${NC}"
    local models=$(curl -sf "${OLLAMA_HOST}/api/tags" 2>/dev/null)
    if [ -n "$models" ]; then
        echo "$models" | python3 -c "
import sys, json
data = json.load(sys.stdin)
models = data.get('models', [])
if not models:
    print('   (ninguno — ejecuta: bash scripts/ollama_serve.sh pull)')
else:
    for m in models:
        name = m.get('name', '?')
        size_gb = m.get('size', 0) / (1024**3)
        print(f'   • {name} ({size_gb:.1f} GB)')
" 2>/dev/null || echo "   (error al parsear modelos)"
    fi

    echo ""
    echo -e "${BOLD}⚙️  Configuración:${NC}"
    echo "   Modelo preferido: ${OLLAMA_MODEL}"
    echo "   Puerto:           ${OLLAMA_PORT}"
    echo ""
}

cmd_pull() {
    echo ""
    log_brain "${BOLD}Descargando modelo: ${CYAN}${OLLAMA_MODEL}${NC}"
    echo ""

    if ! is_ollama_running; then
        log_warn "Ollama no está corriendo. Arrancando primero..."
        cmd_start
    fi

    log_step "Descargando ${OLLAMA_MODEL}... (puede tardar varios minutos)"
    echo ""

    local platform=$(detect_platform)
    if [ "$platform" = "termux" ] && command -v proot-distro &>/dev/null && ! command -v ollama &>/dev/null; then
        proot-distro login debian -- bash -c "
            export OLLAMA_MODELS=/sdcard/ollama_models
            ollama pull ${OLLAMA_MODEL}
        "
    else
        ollama pull "${OLLAMA_MODEL}"
    fi

    echo ""
    log_info "Modelo ${CYAN}${OLLAMA_MODEL}${NC} descargado."
    cmd_status
}

cmd_test() {
    echo ""
    log_brain "${BOLD}Test rápido de IA...${NC}"
    echo ""

    if ! is_ollama_running; then
        log_error "Ollama no está corriendo."
        echo "   Arranca con: bash scripts/ollama_serve.sh start"
        return 1
    fi

    log_step "Enviando prompt de test a ${CYAN}${OLLAMA_MODEL}${NC}..."

    local response
    response=$(curl -sf "${OLLAMA_HOST}/v1/chat/completions" \
        -H "Content-Type: application/json" \
        -d "{
            \"model\": \"${OLLAMA_MODEL}\",
            \"messages\": [{\"role\": \"user\", \"content\": \"Di exactamente: IA offline funcionando correctamente\"}],
            \"max_tokens\": 50,
            \"temperature\": 0.1
        }" 2>&1)

    if [ $? -eq 0 ] && echo "$response" | grep -q "choices"; then
        local text
        text=$(echo "$response" | python3 -c "import sys,json; print(json.load(sys.stdin)['choices'][0]['message']['content'])" 2>/dev/null)
        echo ""
        log_info "Respuesta del modelo:"
        echo -e "   ${CYAN}\"${text}\"${NC}"
        echo ""
        log_info "¡La IA offline funciona perfectamente! 🎉"
    else
        echo ""
        log_error "El modelo no respondió correctamente."
        echo "   ¿Está descargado? Prueba: bash scripts/ollama_serve.sh pull"
        echo "   Respuesta cruda: $response"
    fi
}

cmd_health() {
    # Health check silencioso para monitoreo (watchdog, uptime kuma, etc.)
    if is_ollama_running; then
        echo "OK"
        exit 0
    else
        echo "DOWN"
        exit 1
    fi
}

# ── Main ──────────────────────────────────────────────────────────

case "${1:-help}" in
    start)  cmd_start ;;
    stop)   cmd_stop ;;
    status) cmd_status ;;
    pull)   cmd_pull ;;
    test)   cmd_test ;;
    health) cmd_health ;;
    *)
        echo ""
        echo -e "${BOLD}🧠 Ollama Server Manager — ClawMobil${NC}"
        echo ""
        echo "Uso: bash scripts/ollama_serve.sh <comando>"
        echo ""
        echo "Comandos:"
        echo "  start    Arranca el servidor Ollama"
        echo "  stop     Detiene el servidor"
        echo "  status   Muestra estado y modelos instalados"
        echo "  pull     Descarga el modelo recomendado para tu RAM"
        echo "  test     Test rápido de la API"
        echo "  health   Health check (para monitoreo)"
        echo ""
        echo "Variables de entorno:"
        echo "  OLLAMA_HOST   URL del servidor (default: http://127.0.0.1:11434)"
        echo "  OLLAMA_PORT   Puerto (default: 11434)"
        echo "  OLLAMA_MODEL  Modelo a usar (auto-detectado según RAM)"
        echo ""
        ;;
esac
