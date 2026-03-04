#!/bin/bash
# ═══════════════════════════════════════════════════════════════
# 🔥 DEBLOAT ULTRA-AGRESIVO — YesTeL Server Mode
# ═══════════════════════════════════════════════════════════════
# LOBOTOMÍA TOTAL: este teléfono es SOLO un servidor.
# No necesita pantalla, teclado, cámara, teléfono, NFC, etc.
# Solo necesita: WiFi + Termux + los servicios mínimos de Android
#
# Sin root — usa 'pm uninstall -k --user 0' (reversible con factory reset)
# Serial: <TU_SERIAL_ADB>
# ═══════════════════════════════════════════════════════════════
#
# LO ÚNICO QUE SE CONSERVA:
#   - Android core (Settings, SystemUI, Shell, PackageInstaller)
#   - WiFi stack (wpa_supplicant, framework-res)
#   - Termux + Termux:API + Termux:Boot
#   - Google Play Services + Framework (dependencias mínimas de Termux:API)
#   - WebView (dependencia de Termux)
#   - DuraSpeed (optimización MediaTek — AYUDA al servidor)
#
# TODO LO DEMÁS: FUERA
# Para restaurar TODO: factory reset
# ═══════════════════════════════════════════════════════════════

SERIAL="<TU_SERIAL_ADB>"
ADB="adb -s $SERIAL"
OK='\033[1;32m✅\033[0m'
SKIP='\033[1;33m⏩\033[0m'
ERR='\033[1;31m❌\033[0m'
INFO='\033[1;36mℹ️\033[0m'
FIRE='\033[1;31m🔥\033[0m'
ELIMINADOS=0
FALLIDOS=0
SALTADOS=0

echo ""
echo "═══════════════════════════════════════════════════════"
echo "  🔥 LOBOTOMÍA TOTAL — YesTeL → Servidor Puro"
echo "  Solo queda: WiFi + Termux + Android mínimo"
echo "═══════════════════════════════════════════════════════"
echo ""

# ── Verificar dispositivo conectado ──────────────────────────
if ! adb devices | tr -d '\r' | grep -q "${SERIAL}.*device"; then
    echo -e "${ERR} Dispositivo $SERIAL no encontrado."
    echo "   Conecta el YesTeL por USB y activa depuración USB."
    exit 1
fi

echo -e "${OK} Dispositivo $SERIAL detectado"
echo ""

# ── Estado de RAM ANTES ──────────────────────────────────────
echo "📊 RAM ANTES de la lobotomía:"
$ADB shell cat /proc/meminfo | tr -d '\r' | grep -E "MemTotal|MemFree|MemAvailable|Cached" | head -4
echo ""

# ── Precargar lista de paquetes ──────────────────────────────
echo "📋 Cargando lista de paquetes instalados..."
PKG_LIST=$($ADB shell pm list packages 2>&1 | tr -d '\r')
TOTAL=$(echo "$PKG_LIST" | wc -l | tr -d ' ')
echo "   → $TOTAL paquetes encontrados"
echo ""

debloat() {
    local pkg="$1"
    local desc="$2"
    if echo "$PKG_LIST" | grep -q "^package:${pkg}$"; then
        result=$($ADB shell pm uninstall -k --user 0 "$pkg" 2>&1 | tr -d '\r')
        if echo "$result" | grep -qi "success"; then
            echo -e "${OK} ${pkg} (${desc})"
            ELIMINADOS=$((ELIMINADOS + 1))
        else
            echo -e "${ERR} Falló: ${pkg} — $result"
            FALLIDOS=$((FALLIDOS + 1))
        fi
    else
        SALTADOS=$((SALTADOS + 1))
    fi
}

disable_pkg() {
    local pkg="$1"
    local desc="$2"
    $ADB shell pm disable-user --user 0 "$pkg" 2>/dev/null | tr -d '\r' | grep -qi "disabled" && \
        echo -e "${INFO} Deshabilitado: ${pkg} (${desc})" || true
}

# ═══════════════════════════════════════════════════════════════
echo -e "${FIRE} [1/12] ACTUALIZACIONES OTA / FOTA"
# ═══════════════════════════════════════════════════════════════
debloat "com.adups.fota"                            "Adups FOTA"
debloat "com.adups.fota.sysoper"                    "Adups FOTA SysOper"
debloat "com.google.android.configupdater"          "Google Config Updater"
debloat "com.google.android.gms.policy_sidecar_aps" "Android Platform Services telemetría"

# ═══════════════════════════════════════════════════════════════
echo ""
echo -e "${FIRE} [2/12] TODAS LAS GOOGLE APPS"
# En modo servidor no necesitamos NADA de Google salvo GMS/GSF
# ═══════════════════════════════════════════════════════════════
debloat "com.google.android.youtube"                "YouTube"
debloat "com.google.android.apps.photos"            "Google Photos"
debloat "com.google.android.apps.tachyon"           "Google Duo/Meet"
debloat "com.google.android.apps.wellbeing"         "Digital Wellbeing"
debloat "com.google.android.apps.messaging"         "Google Messages"
debloat "com.google.android.googlequicksearchbox"   "Google Search/Assistant"
debloat "com.google.android.apps.docs"              "Google Drive"
debloat "com.google.android.gm"                     "Gmail"
debloat "com.google.android.apps.maps"              "Google Maps"
debloat "com.google.android.music"                  "Google Play Music"
debloat "com.google.android.videos"                 "Google Play Videos"
debloat "com.google.android.calendar"               "Google Calendar"
debloat "com.android.chrome"                        "Chrome"
debloat "com.android.vending"                       "Play Store"
debloat "com.google.android.tts"                    "Text-to-Speech Google"
debloat "com.google.android.ims"                    "Google IMS"
debloat "com.google.android.partnersetup"           "Google Partner Setup"
debloat "com.google.android.feedback"               "Google Feedback"
debloat "com.google.android.onetimeinitializer"     "Google One-Time Init"
debloat "com.google.android.setupwizard"            "Setup Wizard"
debloat "com.google.android.apps.restore"           "Google Restore"
debloat "com.google.android.backuptransport"        "Google Backup Transport"
debloat "com.google.android.syncadapters.contacts"  "Google Contacts Sync"
debloat "com.google.android.ext.shared"             "Google Ext Shared"
debloat "com.google.android.printservice.recommendation" "Google Print"
debloat "com.google.android.gmsintegration"         "GMS EEA Integration"
debloat "com.google.android.packageinstaller"       "Google Package Installer"
debloat "com.google.android.marvin.talkback"        "TalkBack (accesibilidad)"
debloat "com.google.android.apps.nbu.files"         "Files by Google"
debloat "com.google.android.syncadapters.calendar"  "Google Calendar Sync"
debloat "com.google.android.tag"                    "Google NFC Tags"

# ═══════════════════════════════════════════════════════════════
echo ""
echo -e "${FIRE} [3/12] REDES SOCIALES"
# ═══════════════════════════════════════════════════════════════
debloat "com.facebook.katana"                       "Facebook"
debloat "com.facebook.system"                       "Facebook System"
debloat "com.facebook.appmanager"                   "Facebook App Manager"
debloat "com.facebook.services"                     "Facebook Services"
debloat "com.whatsapp"                              "WhatsApp"
debloat "com.instagram.android"                     "Instagram"
debloat "com.twitter.android"                       "Twitter"
debloat "com.tiktok.musically"                      "TikTok"
debloat "com.snapchat.android"                      "Snapchat"

# ═══════════════════════════════════════════════════════════════
echo ""
echo -e "${FIRE} [4/12] TECLADO — No necesita teclado, es servidor"
# ═══════════════════════════════════════════════════════════════
debloat "com.google.android.inputmethod.latin"      "Gboard (teclado)"
debloat "com.android.inputmethod.latin"             "Teclado Android"

# ═══════════════════════════════════════════════════════════════
echo ""
echo -e "${FIRE} [5/12] CÁMARA / MULTIMEDIA — No necesita pantalla"
# ═══════════════════════════════════════════════════════════════
debloat "com.mediatek.camera"                       "Cámara MediaTek"
debloat "com.mediatek.emcamera"                     "Cámara Ingeniería"
debloat "com.android.soundrecorder"                 "Grabadora sonido"
debloat "com.android.musicfx"                       "MusicFX"
debloat "com.android.gallery3d"                     "Galería"
debloat "com.android.music"                         "Músic Player"

# ═══════════════════════════════════════════════════════════════
echo ""
echo -e "${FIRE} [6/12] UTILIDADES — Todo fuera"
# ═══════════════════════════════════════════════════════════════
debloat "com.android.deskclock"                     "Reloj/Alarma"
debloat "com.android.calculator2"                   "Calculadora"
debloat "com.android.facelock"                      "Face Lock"
debloat "com.android.htmlviewer"                    "Visor HTML"
debloat "com.android.egg"                           "Easter Egg"
debloat "com.android.protips"                       "Pro Tips"
debloat "com.android.dreams.basic"                  "Daydream"
debloat "com.android.wallpaper.livepicker"          "Live Wallpaper"
debloat "com.android.wallpaperpicker"               "Wallpaper Picker"
debloat "com.android.wallpaperbackup"               "Wallpaper Backup"
debloat "com.android.wallpapercropper"              "Wallpaper Cropper"
debloat "com.android.watermark"                     "Watermark"
debloat "com.android.email"                         "Email"
debloat "com.android.exchange"                      "Exchange"
debloat "com.android.browser"                       "Browser"
debloat "com.android.contacts"                      "Contactos"
debloat "com.android.dialer"                        "Teléfono"

# ═══════════════════════════════════════════════════════════════
echo ""
echo -e "${FIRE} [7/12] TELEFONÍA — No es un teléfono"
# ═══════════════════════════════════════════════════════════════
debloat "com.android.stk"                           "SIM Toolkit"
debloat "com.android.stk2"                          "SIM Toolkit 2"
debloat "com.android.simappdialog"                  "SIM App Dialog"
debloat "com.android.phone"                         "Teléfono (core)"
debloat "com.android.incallui"                      "UI Llamadas"
debloat "com.android.mms"                           "MMS"
debloat "com.mediatek.mms.appservice"               "MMS AppService"
debloat "com.mediatek.callrecorder"                 "Call Recorder"
debloat "com.android.smspush"                       "WAP Push"
debloat "com.android.cellbroadcastreceiver"         "Cell Broadcast"

# ═══════════════════════════════════════════════════════════════
echo ""
echo -e "${FIRE} [8/12] BLUETOOTH / NFC — No los usará"
# ═══════════════════════════════════════════════════════════════
debloat "com.android.bluetooth"                     "Bluetooth"
debloat "com.android.bluetoothmidiservice"          "Bluetooth MIDI"
debloat "com.android.nfc"                           "NFC"
debloat "com.android.nfcprovision"                  "NFC Provision"

# ═══════════════════════════════════════════════════════════════
echo ""
echo -e "${FIRE} [9/12] IMPRESIÓN / SERVICIOS EXTRA"
# ═══════════════════════════════════════════════════════════════
debloat "com.android.bips"                          "Print Service"
debloat "com.android.printspooler"                  "Print Spooler"
debloat "com.android.bookmarkprovider"              "Bookmark Provider"
debloat "com.android.companiondevicemanager"        "Companion Device"
debloat "com.android.mtp"                           "MTP"
debloat "com.android.pacprocessor"                  "PAC Processor"
debloat "com.android.providers.partnerbookmarks"    "Partner Bookmarks"

# ═══════════════════════════════════════════════════════════════
echo ""
echo -e "${FIRE} [10/12] MEDIATEK — Diagnóstico / Testing"
# ═══════════════════════════════════════════════════════════════
debloat "com.android.agingtest"                     "Aging Test"
debloat "com.example"                               "Auto Dialer test"
debloat "com.mediatek.mtklogger"                    "MTK Logger"
debloat "com.mediatek.ygps"                         "YGPS test"
debloat "com.mediatek.lbs.em2.ui"                   "Location EM2"
debloat "com.mediatek.mdmconfig"                    "MDM Config"
debloat "com.mediatek.mdmlsample"                   "MDM Sample"
debloat "com.mediatek.sensorhub.ui"                 "Sensor Hub UI"
debloat "com.mediatek.engineermode"                 "Engineer Mode"
debloat "com.teksun.factorytest"                    "Factory Test"
debloat "com.mtk.telephony"                         "SIM Recovery"
debloat "com.android.traceur"                       "System Tracing"
debloat "com.mediatek.omacp"                        "OMA CP"
debloat "com.mediatek.calendarimporter"             "Calendar Importer"
debloat "com.mediatek.gba"                          "GBA auth"
debloat "com.mediatek.location.lppe.main"           "LPPe Service"
debloat "com.mediatek.location.mtknlp"              "MTK NLP"
debloat "com.mediatek.nlpservice"                   "NLP Service"
debloat "com.mediatek.providers.drm"                "DRM Provider"
debloat "com.mediatek.thermalmanager"               "Thermal Manager UI"

# ═══════════════════════════════════════════════════════════════
echo ""
echo -e "${FIRE} [11/12] BACKUP / SETUP / PROVISIONING"
# ═══════════════════════════════════════════════════════════════
debloat "com.android.backupconfirm"                 "Backup Restore"
debloat "com.android.calllogbackup"                 "Call Log Backup"
debloat "com.android.sharedstoragebackup"           "Storage Backup"
debloat "com.android.managedprovisioning"           "Managed Provisioning"
debloat "com.android.secretcode"                    "Secret Code Handler"
debloat "com.android.intelligentsense"              "Intelligent Sense"
debloat "com.mediatek.ppl"                          "Privacy Protection"
debloat "com.android.se"                            "Secure Element"
debloat "com.android.statementservice"              "Statement Service"
debloat "com.android.internal.display.cutout.emulation.corner" "Cutout Corner"
debloat "com.android.internal.display.cutout.emulation.double" "Cutout Double"
debloat "com.android.internal.display.cutout.emulation.tall"   "Cutout Tall"

# ═══════════════════════════════════════════════════════════════
echo ""
echo -e "${FIRE} [12/12] LAUNCHER / UI — Servidor no necesita interfaz"
# ═══════════════════════════════════════════════════════════════
debloat "com.android.launcher3"                     "Launcher3 (pantalla inicio)"
debloat "com.koushikdutta.vysor"                    "Vysor (no necesitamos pantalla remota)"
debloat "com.android.documentsui"                   "DocumentsUI"
debloat "com.android.quicksearchbox"                "Quick Search Box"
debloat "com.android.providers.calendar"            "Calendar Provider"
debloat "com.android.providers.contacts"            "Contacts Provider"
debloat "com.android.providers.userdictionary"      "User Dictionary"

# ═══════════════════════════════════════════════════════════════
echo ""
echo -e "${FIRE} EXTRA: Deshabilitar lo que no se puede desinstalar"
# ═══════════════════════════════════════════════════════════════
# Animaciones a 0 (más rápido)
$ADB shell settings put global window_animation_scale 0.0
$ADB shell settings put global transition_animation_scale 0.0
$ADB shell settings put global animator_duration_scale 0.0
echo -e "${OK} Animaciones desactivadas (0x)"

# No suspender nunca (servidor siempre activo)
$ADB shell settings put global stay_on_while_plugged_in 3
echo -e "${OK} Pantalla siempre encendida cuando carga"

# Brillo mínimo
$ADB shell settings put system screen_brightness 1
echo -e "${OK} Brillo al mínimo"

# Timeout de pantalla al mínimo (15s)
$ADB shell settings put system screen_off_timeout 15000
echo -e "${OK} Pantalla se apaga en 15s"

# Desactivar notificaciones innecesarias
$ADB shell settings put global heads_up_notifications_enabled 0 2>/dev/null || true

# ═══════════════════════════════════════════════════════════════
# RESUMEN
# ═══════════════════════════════════════════════════════════════
echo ""
echo "═══════════════════════════════════════════════════════"
printf "  🔥 LOBOTOMÍA COMPLETADA\n"
printf "  ✅ %d eliminados\n" "$ELIMINADOS"
printf "  ❌ %d fallidos\n" "$FALLIDOS"
printf "  ⏩ %d ya limpios\n" "$SALTADOS"
echo "═══════════════════════════════════════════════════════"
echo ""

# ── Estado de RAM DESPUÉS ────────────────────────────────────
echo "📊 RAM DESPUÉS de la lobotomía:"
$ADB shell cat /proc/meminfo | tr -d '\r' | grep -E "MemTotal|MemFree|MemAvailable|Cached" | head -4
echo ""

# ── Paquetes que quedan ──────────────────────────────────────
RESTANTES=$($ADB shell pm list packages 2>&1 | tr -d '\r' | wc -l | tr -d ' ')
echo "📦 Paquetes restantes: $RESTANTES (de $TOTAL originales)"
echo ""

echo "═══════════════════════════════════════════════════════"
echo "  LO QUE QUEDA VIVO (lo mínimo absoluto):"
echo "═══════════════════════════════════════════════════════"
echo "  🤖 com.termux              — Cerebro del servidor"
echo "  🤖 com.termux.api          — Termux:API"
echo "  🤖 com.termux.boot         — Auto-arranque"
echo "  🌐 com.google.android.webview — WebView (dep Termux)"
echo "  ⚙️  com.google.android.gms  — Play Services (dep Termux:API)"
echo "  ⚙️  com.google.android.gsf  — Services Framework"
echo "  ⚡ com.mediatek.duraspeed   — Optimización CPU"
echo "  🔧 com.android.settings     — Settings (lo mínimo)"
echo "  🖥️  com.android.systemui     — SystemUI"
echo "  📶 WiFi stack               — Conectividad"
echo ""
echo "  🧠 Siguiente paso: instalar Termux + Ollama"
echo "     bash scripts/recovery_yestel_server.sh"
echo ""
