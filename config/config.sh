#!/bin/bash
# ============================================
# ClawMobil — Configuración local del usuario
# ============================================
# ⚠️ Personaliza este archivo con tus datos.
# No subas datos reales al repositorio público.
# ============================================

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")/.." && pwd)"

# ============================================
# DISPOSITIVOS — Mis teléfonos
# ============================================
# Dispositivo activo (cambiar para trabajar con otro)
DEVICE_NAME="mi_dispositivo"
ACTIVE_DEVICE_FILE="$PROJECT_ROOT/Mis_configuraciones_locales/dispositivos/.active_device"

# Priorizamos selección automática para forks/clones locales:
# 1) variable CLAWMOBIL_DEVICE
# 2) archivo .active_device
if [ -n "${CLAWMOBIL_DEVICE:-}" ]; then
    DEVICE_NAME="$CLAWMOBIL_DEVICE"
elif [ -f "$ACTIVE_DEVICE_FILE" ]; then
    ACTIVE_NAME="$(tr -d '[:space:]' < "$ACTIVE_DEVICE_FILE")"
    if [ -n "$ACTIVE_NAME" ]; then
        DEVICE_NAME="$ACTIVE_NAME"
    fi
fi

# Alias → Serial (añadir más con elif)
# Obtén el serial con: adb devices
case "$DEVICE_NAME" in
    mi_dispositivo) DEVICE_SERIAL="TU_SERIAL_ADB_AQUI" ;;
    otro)           DEVICE_SERIAL="OTRO_SERIAL_AQUI" ;;
    *)              DEVICE_SERIAL="" ;;
esac

# ADB path (ajusta a tu sistema)
# macOS: ~/Library/Android/sdk/platform-tools/adb
# Linux: /usr/bin/adb o ~/Android/Sdk/platform-tools/adb
ADB_PATH=""

# ============================================
# NO EDITAR POR DEBAJO
# ============================================
if [ -n "$ADB_PATH" ] && [ -f "$ADB_PATH" ]; then
    export PATH="$(dirname "$ADB_PATH"):$PATH"
fi

adb_cmd() {
    if [ -n "$DEVICE_SERIAL" ]; then
        adb -s "$DEVICE_SERIAL" "$@"
    else
        adb "$@"
    fi
}

LOCAL_DEVICE_DIR="$PROJECT_ROOT/Mis_configuraciones_locales/dispositivos/$DEVICE_NAME"
