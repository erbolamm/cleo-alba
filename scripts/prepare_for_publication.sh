#!/usr/bin/env bash
# prepare_for_publication.sh — Auditoría de seguridad pre-push
# Escanea el proyecto en busca de datos sensibles antes de publicar en GitHub.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
ERRORS=0

echo "═══════════════════════════════════════════════"
echo "  🔒 ClawMobil — Auditoría pre-publicación"
echo "═══════════════════════════════════════════════"
echo ""

# --- 1. Verificar .gitignore ---
echo "📋 [1/5] Verificando .gitignore..."
REQUIRED_IGNORES=("Mis_configuraciones_locales/" "openclaw_gateway.log" "__pycache__/")
for pattern in "${REQUIRED_IGNORES[@]}"; do
    if grep -q "$pattern" "$PROJECT_ROOT/.gitignore" 2>/dev/null; then
        echo "  ✅ $pattern"
    else
        echo "  ❌ FALTA: $pattern"
        ERRORS=$((ERRORS + 1))
    fi
done
echo ""

# --- 2. Buscar API keys hardcodeadas ---
echo "🔑 [2/5] Buscando API keys hardcodeadas..."
# Buscar patrones de API keys comunes (Groq, OpenAI, Telegram tokens)
KEYS_FOUND=$(grep -rn \
    -e "gsk_[a-zA-Z0-9]\{20,\}" \
    -e "sk-[a-zA-Z0-9]\{20,\}" \
    -e "bot[0-9]\{8,\}:" \
    --include="*.py" --include="*.sh" --include="*.json" --include="*.js" \
    "$PROJECT_ROOT" 2>/dev/null | grep -v ".gitignore" | grep -v "node_modules" | grep -v "Mis_configuraciones_locales/" || true)

if [ -n "$KEYS_FOUND" ]; then
    echo "  ❌ API keys encontradas:"
    echo "$KEYS_FOUND" | sed 's/^/     /'
    ERRORS=$((ERRORS + 1))
else
    echo "  ✅ No se encontraron API keys hardcodeadas"
fi
echo ""

# --- 3. Buscar serials de dispositivo ---
echo "📱 [3/5] Buscando serials de dispositivo..."
SERIALS_FOUND=$(grep -rn "6PQ0217223005924" \
    --include="*.py" --include="*.sh" --include="*.md" --include="*.html" --include="*.json" \
    "$PROJECT_ROOT" 2>/dev/null | grep -v "Mis_configuraciones_locales/" | grep -v "prepare_for_publication.sh" || true)

if [ -n "$SERIALS_FOUND" ]; then
    echo "  ❌ Serials encontrados:"
    echo "$SERIALS_FOUND" | sed 's/^/     /'
    ERRORS=$((ERRORS + 1))
else
    echo "  ✅ No se encontraron serials de dispositivo"
fi
echo ""

# --- 4. Buscar IDs de Telegram ---
echo "💬 [4/5] Buscando IDs de chat de Telegram..."
CHAT_IDS=$(grep -rn "288220381" \
    --include="*.py" --include="*.sh" --include="*.md" --include="*.html" --include="*.json" \
    "$PROJECT_ROOT" 2>/dev/null | grep -v "Mis_configuraciones_locales/" | grep -v "prepare_for_publication.sh" || true)

if [ -n "$CHAT_IDS" ]; then
    echo "  ❌ Chat IDs encontrados:"
    echo "$CHAT_IDS" | sed 's/^/     /'
    ERRORS=$((ERRORS + 1))
else
    echo "  ✅ No se encontraron chat IDs de Telegram"
fi
echo ""

# --- 5. Verificar archivos .env no trackeados ---
echo "📁 [5/5] Verificando archivos sensibles no trackeados por git..."
TRACKED_ENV=$(cd "$PROJECT_ROOT" && git ls-files "*.env" "*.key" "*.pem" 2>/dev/null || true)

if [ -n "$TRACKED_ENV" ]; then
    echo "  ❌ Archivos sensibles trackeados por git:"
    echo "$TRACKED_ENV" | sed 's/^/     /'
    ERRORS=$((ERRORS + 1))
else
    echo "  ✅ No hay archivos .env/.key/.pem trackeados"
fi
echo ""

# --- Resultado ---
echo "═══════════════════════════════════════════════"
if [ "$ERRORS" -eq 0 ]; then
    echo "  ✅ PROYECTO LIMPIO — Listo para push a GitHub"
else
    echo "  ❌ $ERRORS problema(s) encontrado(s) — Revisa antes de hacer push"
fi
echo "═══════════════════════════════════════════════"

exit $ERRORS
