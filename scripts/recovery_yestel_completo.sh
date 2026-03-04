#!/bin/bash
# ═══════════════════════════════════════════════════════════════
# 🦞 RECOVERY COMPLETO — YesTeL Note 30 Pro (Post Factory Reset)
# ═══════════════════════════════════════════════════════════════
# Ejecutar desde: MAC (VS Code terminal)
# Requisito: ADB conectado y autorizado (depuración USB activa)
# Serial: <TU_SERIAL_ADB>
# Fecha: 2026-03-02
# ═══════════════════════════════════════════════════════════════

SERIAL="<TU_SERIAL_ADB>"
ADB="adb -s $SERIAL"
OK='\033[1;32m✅\033[0m'
ERR='\033[1;31m❌\033[0m'
INFO='\033[1;36mℹ️\033[0m'
WARN='\033[1;33m⚠️\033[0m'

echo ""
echo "═══════════════════════════════════════════════════════════"
echo "  🦞 RECOVERY COMPLETO — YesTeL Note 30 Pro"
echo "═══════════════════════════════════════════════════════════"
echo ""

# ── FASE 0: Verificar dispositivo ────────────────────────────
echo -e "${INFO} Fase 0: Verificando conexión ADB..."
if ! adb devices | tr -d '\r' | grep -q "${SERIAL}.*device"; then
    echo -e "${ERR} Dispositivo $SERIAL no encontrado."
    echo "   1. Conecta el YesTeL por USB"
    echo "   2. Activa depuración USB en Ajustes > Opciones de desarrollo"
    echo "   3. Acepta el diálogo de autorización ADB en el teléfono"
    echo ""
    echo "   Si la pantalla táctil no funciona, usa un ratón USB OTG."
    echo "   Si ADB funciona en setup wizard (algunos YesTeL lo permiten):"
    echo "   adb shell input tap X Y"
    exit 1
fi
echo -e "${OK} Dispositivo conectado: $SERIAL"

# ── FASE 1: Info del dispositivo ─────────────────────────────
echo ""
echo -e "${INFO} Fase 1: Información del dispositivo..."
echo "  Modelo: $($ADB shell getprop ro.product.model | tr -d '\r')"
echo "  Android: $($ADB shell getprop ro.build.version.release | tr -d '\r')"
echo "  SDK: $($ADB shell getprop ro.build.version.sdk | tr -d '\r')"
echo ""

# ── FASE 2: Preparar SD Card ────────────────────────────────
echo -e "${INFO} Fase 2: Preparando SD Card..."
SD="/storage/8245-190E"
$ADB shell "
if [ -d '$SD' ]; then
    mkdir -p '$SD/ApliBot_Backup' '$SD/OpenClawData' \
             '$SD/Media/fotos' '$SD/Media/audios' '$SD/Media/videos' \
             '$SD/Memoria' '$SD/Logs' 2>/dev/null
    echo 'SD_OK'
else
    echo 'SD_NO'
fi
" | tr -d '\r' | while read line; do
    if [ "$line" = "SD_OK" ]; then
        echo -e "${OK} SD Card preparada en $SD"
    elif [ "$line" = "SD_NO" ]; then
        echo -e "${WARN} SD Card no detectada en $SD"
    fi
done

# ── FASE 3: Crear directorios base ──────────────────────────
echo ""
echo -e "${INFO} Fase 3: Preparando directorios en /sdcard/..."
$ADB shell "mkdir -p /sdcard/DCIM /sdcard/whisper_models /sdcard/scripts /sdcard/bridge_scripts" 2>/dev/null
echo -e "${OK} Directorios base creados"

# ── FASE 4: Subir scripts al teléfono ───────────────────────
echo ""
echo -e "${INFO} Fase 4: Subiendo scripts al teléfono..."

SCRIPTS_DIR="$(cd "$(dirname "$0")/.." && pwd)"

# Scripts de Termux
for f in "$SCRIPTS_DIR/termux_scripts/"*.sh; do
    if [ -f "$f" ]; then
        fname=$(basename "$f")
        $ADB push "$f" "/sdcard/$fname" >/dev/null 2>&1
        echo -e "  ${OK} $fname"
    fi
done

# Bridge scripts
if [ -d "$SCRIPTS_DIR/scripts/bridge_scripts" ]; then
    for f in "$SCRIPTS_DIR/scripts/bridge_scripts/"*; do
        if [ -f "$f" ]; then
            fname=$(basename "$f")
            $ADB push "$f" "/sdcard/bridge_scripts/$fname" >/dev/null 2>&1
            echo -e "  ${OK} bridge: $fname"
        fi
    done
fi

# Script de debloat para uso posterior
$ADB push "$SCRIPTS_DIR/scripts/debloat_yestel_note30pro.sh" "/sdcard/debloat.sh" >/dev/null 2>&1
echo -e "  ${OK} debloat_yestel_note30pro.sh"

# ── FASE 5: Instalar Termux (instrucciones) ─────────────────
echo ""
echo "═══════════════════════════════════════════════════════════"
echo -e "${WARN} FASE 5: INSTALACIÓN MANUAL REQUERIDA"
echo "═══════════════════════════════════════════════════════════"
echo ""
echo "  Instalar estas APKs desde F-Droid (via ADB browser):"
echo ""
echo "  1. Termux:       adb shell am start -a android.intent.action.VIEW -d 'https://f-droid.org/packages/com.termux/'"
echo "  2. Termux:API:   adb shell am start -a android.intent.action.VIEW -d 'https://f-droid.org/packages/com.termux.api/'"
echo "  3. Termux:Boot:  adb shell am start -a android.intent.action.VIEW -d 'https://f-droid.org/packages/com.termux.boot/'"
echo "  4. Fulguris:     adb shell am start -a android.intent.action.VIEW -d 'https://f-droid.org/packages/net.anthropic.nicefox/'"
echo ""
echo "  Alternativa rápida (APK directos si los tienes):"
echo "  adb install termux.apk && adb install termux-api.apk && adb install termux-boot.apk"
echo ""
echo "  Después de instalar Termux, ABRE la app Termux una vez."
echo "  Luego ejecuta: bash $(pwd)/scripts/recovery_fase2_termux.sh"
echo ""
echo "═══════════════════════════════════════════════════════════"
