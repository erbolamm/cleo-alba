#!/bin/bash
# ============================================
# 🔑 Set YesTeL Password — ClawMobil
# ============================================
# Cambia la contraseña para el acceso online.

set -euo pipefail

PASSWORD_FILE="$HOME/last_password.txt"

# Colores
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}🔑 Configuración de Contraseña YesTeL${NC}"

if [ -z "${1:-}" ]; then
    echo -n "Introduce la nueva contraseña: "
    read -s NEW_PASS
    echo ""
else
    NEW_PASS="$1"
fi

if [ -z "$NEW_PASS" ]; then
    echo -e "❌ La contraseña no puede estar vacía."
    exit 1
fi

echo "$NEW_PASS" > "$PASSWORD_FILE"
echo -e "${GREEN}✅ Contraseña actualizada correctamente.${NC}"
echo "La próxima vez que actives el modo ONLINE se usará esta clave."
