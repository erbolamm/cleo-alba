#!/bin/bash
# ═══════════════════════════════════════════════════════════════
# 📱 NAVEGACIÓN SETUP WIZARD — Sin pantalla táctil (via ADB)
# ═══════════════════════════════════════════════════════════════
# Ejecutar desde: MAC
# El YesTeL Note 30 Pro tiene la pantalla táctil rota.
# Este script simula toques para pasar el setup wizard de Android
# post factory reset.
#
# IMPORTANTE: Si ADB no responde después del factory reset,
# necesitas un ratón USB OTG conectado al teléfono para:
# 1. Pasar la pantalla inicial de bienvenida
# 2. Conectar WiFi
# 3. Ir a Ajustes > Opciones de desarrollo > Depuración USB
#
# Si ADB SÍ responde (algunos YesTeL lo permiten sin auth):
# Ejecuta este script paso a paso.
# ═══════════════════════════════════════════════════════════════

SERIAL="NOTE10PRO000400"
ADB="adb -s $SERIAL"

# Pantalla: 720 x 1560
WIDTH=720
HEIGHT=1560

echo "═══════════════════════════════════════════════"
echo "  📱 Setup Wizard Helper — YesTeL Note 30 Pro"
echo "═══════════════════════════════════════════════"
echo ""

# Verificar conexión
echo "🔍 Verificando conexión ADB..."
if ! adb devices | tr -d '\r' | grep -q "${SERIAL}"; then
    echo ""
    echo "❌ El teléfono no aparece en ADB."
    echo ""
    echo "OPCIONES:"
    echo ""
    echo "  OPCIÓN A — Ratón USB OTG (RECOMENDADO)"
    echo "    1. Conecta un ratón USB al teléfono via adaptador OTG"
    echo "    2. Navega el setup wizard con el ratón"
    echo "    3. Activa Depuración USB:"
    echo "       Ajustes > Acerca del teléfono > Toca 7 veces 'Número de compilación'"
    echo "       Ajustes > Opciones de desarrollo > Depuración USB: ON"
    echo "    4. Conecta USB al Mac y acepta el diálogo de autorización ADB"
    echo ""
    echo "  OPCIÓN B — Intentar ADB sin autorización"  
    echo "    Desconecta y reconecta USB."
    echo "    Algunos dispositivos permiten ADB básico durante el setup."
    echo "    adb devices"
    echo ""
    echo "  OPCIÓN C — ADB via WiFi (si puedes conectar WiFi)"
    echo "    Si logras conectar WiFi via OTG mouse:"
    echo "    adb connect <IP_del_telefono>:5555"
    echo ""
    exit 1
fi

STATUS=$(adb devices | tr -d '\r' | grep "${SERIAL}" | awk '{print $2}')
if [ "$STATUS" = "unauthorized" ]; then
    echo "⚠️ ADB conectado pero NO autorizado."
    echo "   Necesitas aceptar el diálogo en el teléfono."
    echo "   Si no puedes tocar la pantalla, usa ratón USB OTG."
    exit 1
fi

echo "✅ ADB conectado y autorizado"
echo ""

# ── FUNCIONES HELPER ─────────────────────────────────────────
tap() {
    $ADB shell input tap "$1" "$2"
    sleep 1
}

swipe_left() {
    $ADB shell input swipe 600 780 100 780 300
    sleep 1
}

swipe_right() {
    $ADB shell input swipe 100 780 600 780 300
    sleep 1
}

press_back() {
    $ADB shell input keyevent KEYCODE_BACK
    sleep 0.5
}

press_home() {
    $ADB shell input keyevent KEYCODE_HOME
    sleep 0.5
}

press_enter() {
    $ADB shell input keyevent KEYCODE_ENTER
    sleep 0.5
}

type_text() {
    $ADB shell input text "$1"
    sleep 0.5
}

screenshot() {
    $ADB shell screencap -p /sdcard/setup_screen.png
    $ADB pull /sdcard/setup_screen.png /tmp/setup_screen.png 2>/dev/null
    echo "📸 Captura guardada en /tmp/setup_screen.png"
}

# ── MENÚ INTERACTIVO ─────────────────────────────────────────
echo "COMANDOS DISPONIBLES:"
echo "  tap X Y       — Simular toque en coordenadas"
echo "  swipe         — Deslizar a la izquierda"
echo "  back          — Botón atrás"
echo "  home          — Botón home"
echo "  enter         — Tecla enter"
echo "  type TEXTO    — Escribir texto"
echo "  screen        — Captura de pantalla"
echo "  skip          — Intentar saltar wizard (botones comunes)"
echo "  wifi          — Abrir ajustes WiFi"
echo "  dev           — Ir a Opciones de desarrollo"
echo "  exit          — Salir"
echo ""
echo "Coordenadas útiles (720x1560):"
echo "  Centro: 360 780"
echo "  Botón inferior derecho (Siguiente/Skip): 600 1450"
echo "  Botón inferior izquierdo (Atrás): 120 1450"
echo ""

while true; do
    read -p "📱> " INPUT
    CMD=$(echo "$INPUT" | awk '{print $1}')
    ARGS=$(echo "$INPUT" | cut -d' ' -f2-)
    
    case "$CMD" in
        tap)
            X=$(echo "$ARGS" | awk '{print $1}')
            Y=$(echo "$ARGS" | awk '{print $2}')
            echo "  Tap en ($X, $Y)"
            tap "$X" "$Y"
            ;;
        swipe)
            swipe_left
            ;;
        back)
            press_back
            ;;
        home)
            press_home
            ;;
        enter)
            press_enter
            ;;
        type)
            type_text "$ARGS"
            ;;
        screen)
            screenshot
            ;;
        skip)
            echo "  Intentando saltar wizard..."
            # Botón SKIP suele estar arriba-derecha o abajo
            tap 600 100   # Skip arriba derecha
            tap 600 1450  # Skip/Next abajo derecha
            tap 360 1450  # Centro abajo
            ;;
        wifi)
            $ADB shell am start -a android.settings.WIFI_SETTINGS
            ;;
        dev)
            $ADB shell am start -a android.settings.APPLICATION_DEVELOPMENT_SETTINGS
            ;;
        settings)
            $ADB shell am start -a android.settings.SETTINGS
            ;;
        usb)
            echo "  Activando depuración USB..."
            $ADB shell settings put global adb_enabled 1
            echo "  ✅ Depuración USB activada (si teníamos permisos)"
            ;;
        exit|quit|q)
            echo "👋 Saliendo"
            break
            ;;
        *)
            echo "  Comando no reconocido: $CMD"
            ;;
    esac
done
