#!/bin/bash
# ═══════════════════════════════════════════════════════════════
# 🧹 DEBLOAT YesTeL Note 30 Pro (MT6763V/Helio P23) — ClawMobil
# ═══════════════════════════════════════════════════════════════
# Sin root — usa 'pm uninstall -k --user 0' (reversible)
# Para restaurar un paquete: adb shell cmd package install-existing <pkg>
# Serial: NOTE10PRO000400
# Chip: MediaTek Helio P23 (MT6763V) — 8x Cortex-A53 @ 2GHz
# RAM: 4GB — cada MB cuenta para ClawMobil
# ═══════════════════════════════════════════════════════════════
#
# APPS QUE SE CONSERVAN (NO TOCAR):
#   - Termux + API + Boot (el bot vive aquí)
#   - Vysor (control remoto, pantalla rota)
#   - Files by Google (compartir via Bluetooth/WiFi)
#   - Google Play Services + Framework (dependencias del sistema)
#   - WebView (necesario para Termux y futuro browser)
#   - Gboard (teclado, necesario para Vysor)
#   - Bluetooth, WiFi, Telefonía, Settings, SystemUI
#   - Launcher3 (home screen para Vysor)
#   - DuraSpeed (optimización de rendimiento MediaTek)
#   - NFC, VPN, SIM Toolkit
#   - Proveedores: Contactos, Media, Downloads, Calendar, Telephony
#
# Para restaurar TODO de golpe: reiniciar de fábrica
# Para restaurar UNA app:
#   adb -s NOTE10PRO000400 shell cmd package install-existing <paquete>
# ═══════════════════════════════════════════════════════════════

SERIAL="NOTE10PRO000400"
ADB="adb -s $SERIAL"
OK='\033[1;32m✅\033[0m'
SKIP='\033[1;33m⏩\033[0m'
ERR='\033[1;31m❌\033[0m'
INFO='\033[1;36mℹ️\033[0m'
ELIMINADOS=0
FALLIDOS=0
SALTADOS=0

echo ""
echo "═══════════════════════════════════════════════════════"
echo "  🧹 DEBLOAT YesTeL Note 30 Pro — RAM para ClawMobil"
echo "═══════════════════════════════════════════════════════"
echo ""

# ── Verificar dispositivo conectado ──────────────────────────
if ! adb devices | tr -d '\r' | grep -q "${SERIAL}.*device"; then
    echo -e "${ERR} Dispositivo $SERIAL no encontrado."
    echo "   Conecta el YesTeL por USB y activa depuración USB."
    exit 1
fi

# ── Estado de RAM ANTES ──────────────────────────────────────
echo "📊 RAM ANTES del debloat:"
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
            echo -e "${OK} Eliminado: ${pkg} (${desc})"
            ELIMINADOS=$((ELIMINADOS + 1))
        else
            echo -e "${ERR} Falló: ${pkg} — $result"
            FALLIDOS=$((FALLIDOS + 1))
        fi
    else
        echo -e "${SKIP} No presente: ${pkg}"
        SALTADOS=$((SALTADOS + 1))
    fi
}

# ═══════════════════════════════════════════════════════════════
# [1/9] 🚨 ACTUALIZACIONES OTA / FOTA — FUERA
# ═══════════════════════════════════════════════════════════════
echo "--- [1/9] Actualizaciones OTA / FOTA ---"
debloat "com.adups.fota"                            "Adups FOTA (actualizaciones sistema)"
debloat "com.google.android.configupdater"          "Google Config Updater"
debloat "com.google.android.gms.policy_sidecar_aps" "Android Platform Services (telemetría)"

# ═══════════════════════════════════════════════════════════════
# [2/9] 📱 GOOGLE APPS (todas menos GMS, GSF, WebView, Gboard, Files)
# ═══════════════════════════════════════════════════════════════
echo ""
echo "--- [2/9] Google Apps innecesarias ---"
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
debloat "com.android.chrome"                         "Chrome Browser"
debloat "com.android.vending"                        "Google Play Store"
debloat "com.google.android.tts"                    "Text-to-Speech Google"
debloat "com.google.android.ims"                    "Google IMS (Carrier Services)"
debloat "com.google.android.partnersetup"           "Google Partner Setup"
debloat "com.google.android.feedback"               "Google Feedback"
debloat "com.google.android.onetimeinitializer"     "Google One-Time Initializer"
debloat "com.google.android.setupwizard"            "Google Setup Wizard"
debloat "com.google.android.apps.restore"           "Google Restore"
debloat "com.google.android.backuptransport"        "Google Backup Transport"
debloat "com.google.android.syncadapters.contacts"  "Google Contacts Sync"
debloat "com.google.android.ext.shared"             "Google Ext Shared"
debloat "com.google.android.printservice.recommendation" "Google Print Recommendation"
debloat "com.google.android.gmsintegration"         "GMS EEA Integration"
# Google Package Installer — lo quitamos, no se instalarán apps por Play Store
debloat "com.google.android.packageinstaller"       "Google Package Installer"

# ═══════════════════════════════════════════════════════════════
# [3/9] 📲 REDES SOCIALES pre-instaladas
# ═══════════════════════════════════════════════════════════════
echo ""
echo "--- [3/9] Redes sociales pre-instaladas ---"
debloat "com.facebook.katana"                       "Facebook"
debloat "com.whatsapp"                              "WhatsApp"

# ═══════════════════════════════════════════════════════════════
# [4/9] 📸 CÁMARA / MULTIMEDIA (el bot usa camera_bridge.sh)
# ═══════════════════════════════════════════════════════════════
echo ""
echo "--- [4/9] Cámara / Multimedia ---"
debloat "com.mediatek.camera"                       "Cámara MediaTek"
debloat "com.mediatek.emcamera"                     "Cámara Modo Ingeniería"
debloat "com.android.soundrecorder"                 "Grabadora de sonido (usa whisper)"
debloat "com.android.musicfx"                       "Music FX (ecualizador)"

# ═══════════════════════════════════════════════════════════════
# [5/9] 🕐 UTILIDADES innecesarias para servidor
# ═══════════════════════════════════════════════════════════════
echo ""
echo "--- [5/9] Utilidades innecesarias ---"
debloat "com.android.deskclock"                     "Reloj / Alarma"
debloat "com.android.calculator2"                   "Calculadora"
debloat "com.android.facelock"                      "Face Lock (pantalla rota)"
debloat "com.android.htmlviewer"                    "Visor HTML"
debloat "com.android.egg"                           "Easter Egg Android"
debloat "com.android.protips"                       "Pro Tips"

# ═══════════════════════════════════════════════════════════════
# [6/9] 🎨 FONDOS / WALLPAPERS / PERSONALIZACIÓN
# ═══════════════════════════════════════════════════════════════
echo ""
echo "--- [6/9] Fondos de pantalla / Personalización ---"
debloat "com.android.dreams.basic"                  "Basic Dreams (Daydream)"
debloat "com.android.wallpaper.livepicker"          "Live Wallpaper Picker"
debloat "com.android.wallpaperpicker"               "Wallpaper Picker"
debloat "com.android.wallpaperbackup"               "Wallpaper Backup"
debloat "com.android.wallpapercropper"              "Wallpaper Cropper"
debloat "com.android.watermark"                     "Watermark"

# ═══════════════════════════════════════════════════════════════
# [7/9] 🖨️ IMPRESIÓN / NFC MIDI / EXTRAS
# ═══════════════════════════════════════════════════════════════
echo ""
echo "--- [7/9] Impresión / Servicios extra ---"
debloat "com.android.bips"                          "Print Service integrado"
debloat "com.android.printspooler"                  "Print Spooler"
debloat "com.android.bluetoothmidiservice"          "Bluetooth MIDI (música)"
debloat "com.android.bookmarkprovider"              "Bookmark Provider"
debloat "com.android.companiondevicemanager"        "Companion Device Manager"
debloat "com.android.mtp"                           "MTP Documents Provider"
debloat "com.android.smspush"                       "WAP Push Manager"
debloat "com.android.pacprocessor"                  "PAC Processor"
debloat "com.android.providers.partnerbookmarks"    "Partner Bookmarks"

# ═══════════════════════════════════════════════════════════════
# [8/9] 🔧 MEDIATEK — Diagnóstico / Testing / Logging
# ═══════════════════════════════════════════════════════════════
echo ""
echo "--- [8/9] MediaTek diagnóstico / testing ---"
debloat "com.android.agingtest"                     "Aging Test (fábrica)"
debloat "com.example"                               "Auto Dialer (test)"
debloat "com.mediatek.mtklogger"                    "MTK Logger (diagnóstico)"
debloat "com.mediatek.ygps"                         "YGPS (test GPS)"
debloat "com.mediatek.lbs.em2.ui"                   "Location EM2 (debug)"
debloat "com.mediatek.mdmconfig"                    "MDM Config"
debloat "com.mediatek.mdmlsample"                   "MDM Sample"
debloat "com.mediatek.sensorhub.ui"                 "Sensor Hub UI"
debloat "com.mediatek.engineermode"                 "Engineer Mode"
debloat "com.teksun.factorytest"                    "Factory Test"
debloat "com.mtk.telephony"                         "SIM Recovery Test Tool"
debloat "com.android.traceur"                       "System Tracing"
debloat "com.mediatek.omacp"                        "OMA CP (provisioning carrier)"
debloat "com.mediatek.calendarimporter"             "Calendar Importer"
debloat "com.mediatek.gba"                          "GBA (auth carrier)"
debloat "com.mediatek.location.lppe.main"           "LPPe Service (location)"
debloat "com.mediatek.location.mtknlp"              "MTK NLP (location debug)"
debloat "com.mediatek.nlpservice"                   "NLP Service (location)"
debloat "com.mediatek.providers.drm"                "DRM Provider"
debloat "com.mediatek.thermalmanager"               "Thermal Manager UI"

# ═══════════════════════════════════════════════════════════════
# [9/9] 🔒 BACKUP / SETUP / PROVISIONING
# ═══════════════════════════════════════════════════════════════
echo ""
echo "--- [9/9] Backup / Setup / Provisioning ---"
debloat "com.android.backupconfirm"                 "Backup Restore Confirmation"
debloat "com.android.calllogbackup"                 "Call Log Backup"
debloat "com.android.sharedstoragebackup"           "Shared Storage Backup"
debloat "com.android.managedprovisioning"           "Managed Provisioning (MDM)"
debloat "com.android.secretcode"                    "Secret Code Handler"
debloat "com.android.simappdialog"                  "SIM App Dialog"
debloat "com.android.intelligentsense"              "Intelligent Sense"
debloat "com.mediatek.ppl"                          "Privacy Protection Lock"
debloat "com.mediatek.callrecorder"                 "Call Recorder"
debloat "com.android.se"                            "Secure Element"
debloat "com.android.statementservice"              "Statement Service (URL verify)"
debloat "com.mediatek.mms.appservice"               "MMS App Service (extra)"
# Display cutout emulations (inútiles en este teléfono)
debloat "com.android.internal.display.cutout.emulation.corner" "Display Cutout Corner"
debloat "com.android.internal.display.cutout.emulation.double" "Display Cutout Double"
debloat "com.android.internal.display.cutout.emulation.tall"   "Display Cutout Tall"

# ═══════════════════════════════════════════════════════════════
# RESUMEN
# ═══════════════════════════════════════════════════════════════
echo ""
echo "═══════════════════════════════════════════════════════"
printf "  🎉 DEBLOAT COMPLETADO\n"
printf "  ✅ %d eliminados\n" "$ELIMINADOS"
printf "  ❌ %d fallidos\n" "$FALLIDOS"
printf "  ⏩ %d no presentes (ya limpios)\n" "$SALTADOS"
echo "═══════════════════════════════════════════════════════"
echo ""

# ── Estado de RAM DESPUÉS ────────────────────────────────────
echo "📊 RAM DESPUÉS del debloat:"
$ADB shell cat /proc/meminfo | tr -d '\r' | grep -E "MemTotal|MemFree|MemAvailable|Cached" | head -4
echo ""

# ── Paquetes que quedan ──────────────────────────────────────
RESTANTES=$($ADB shell pm list packages 2>&1 | tr -d '\r' | wc -l | tr -d ' ')
echo "📦 Paquetes restantes: $RESTANTES (de $TOTAL originales)"
echo ""

echo "═══════════════════════════════════════════════════════"
echo "  APPS CONSERVADAS (críticas para ClawMobil):"
echo "═══════════════════════════════════════════════════════"
echo "  🤖 com.termux            — Termux (cerebro del bot)"
echo "  🤖 com.termux.api        — Termux:API"
echo "  🤖 com.termux.boot       — Termux:Boot (auto-arranque)"
echo "  🖥️  com.koushikdutta.vysor — Vysor (pantalla remota)"
echo "  📁 com.google.android.apps.nbu.files — Files (compartir)"
echo "  🌐 com.google.android.webview — WebView"
echo "  ⌨️  com.google.android.inputmethod.latin — Gboard"
echo "  ⚙️  com.google.android.gms — Play Services"
echo "  ⚙️  com.google.android.gsf — Services Framework"
echo "  ⚡ com.mediatek.duraspeed — DuraSpeed (rendimiento)"
echo "  📞 com.android.dialer + telephony + contacts"
echo "  📶 com.android.bluetooth + com.android.nfc"
echo "  🔧 com.android.settings + systemui + shell"
echo ""
echo "Para restaurar una app:"
echo "  adb -s $SERIAL shell cmd package install-existing <paquete>"
echo ""
