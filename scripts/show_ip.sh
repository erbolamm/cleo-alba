#!/bin/bash
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

IP=$(ip addr show wlan0 | grep "inet " | awk '{print $2}' | cut -d/ -f1 | head -n1)

echo -e "${BLUE}==============================${NC}"
echo -e "${GREEN}  Tu IP Local es: ${IP}${NC}"
echo -e "${BLUE}==============================${NC}"
echo ""
echo "Usa esta dirección en tu App o navegador:"
echo "http://${IP}:11434"
echo ""
