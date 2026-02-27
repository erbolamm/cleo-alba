#!/bin/bash
# ═══════════════════════════════════════════════════════════════
# 🧹 DEBLOAT Samsung SM-A300FU (Android 6.0.1) — ClawMobil
# ═══════════════════════════════════════════════════════════════
# Sin root — usa 'pm uninstall -k --user 0' (reversible)
# Para restaurar un paquete: adb shell cmd package install-existing <pkg>
# Serial objetivo: <DEVICE_SERIAL>
# ═══════════════════════════════════════════════════════════════

SERIAL="<DEVICE_SERIAL>"
ADB="adb -s $SERIAL"
OK='\033[1;32m✅\033[0m'
SKIP='\033[1;33m⏩\033[0m'
ERR='\033[1;31m❌\033[0m'
ELIMINADOS=0
FALLIDOS=0

echo ""
echo "═══════════════════════════════════════════════════════"
echo "  🧹 DEBLOAT Samsung A3 — Liberando RAM para ClawMobil"
echo "═══════════════════════════════════════════════════════"
echo ""

# Verificar dispositivo conectado
if ! adb devices | tr -d '\r' | grep -q "${SERIAL}.*device"; then
    echo -e "${ERR} Dispositivo $SERIAL no encontrado. Conéctalo por USB."
    exit 1
fi

# Precargar lista de paquetes UNA sola vez (tr -d '\r' elimina retornos de carro Android)
echo "📋 Cargando lista de paquetes instalados..."
PKG_LIST=$($ADB shell pm list packages | tr -d '\r')
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
    fi
}

# ─── KNOX / MDM / Enterprise (pesados, inútiles en uso personal) ─────────────
echo "--- [1/10] Knox / MDM / Enterprise ---"
debloat "com.samsung.klmsagent"                     "Knox License Manager"
debloat "com.sec.enterprise.knox.attestation"       "Knox Attestation Agent"
debloat "com.sec.knox.foldercontainer"              "Knox Folder Container"
debloat "com.sec.knox.knoxsetupwizardclient"        "Knox Setup Wizard"
debloat "com.sec.knox.switcher"                     "Knox Switcher"
debloat "com.samsung.android.mdm"                   "Samsung MDM"
debloat "com.sec.enterprise.knox.cloudmdm.smdms"    "Universal MDM Client"
debloat "com.samsung.knox.appsupdateagent"            "Knox Apps Update Agent"
debloat "com.samsung.knox.rcp.components"           "Knox RCP Components"
debloat "com.sec.enterprise.knox.myknoxsetupwizard" "MyKNOX Setup Wizard"
debloat "com.sec.enterprise.mdm.services.simpin"    "MDM SIM PIN Service"
debloat "com.sec.enterprise.mdm.vpn"                "MDM VPN Services"
debloat "com.policydm"                              "SPD Client (MDM)"
debloat "com.samsung.android.sm.devicesecurity"     "Smart Manager Device Security"

# ─── Samsung Cloud / Cuentas / Sincronización ────────────────────────────────
echo ""
echo "--- [2/10] Samsung Cloud / Cuentas ---"
debloat "com.samsung.android.scloud"                "Samsung Cloud"
debloat "com.samsung.android.scloud.backup"         "Samsung Cloud Backup"
debloat "com.sec.android.cloudagent"                "Samsung Cloud Agent"
debloat "com.sec.android.cloudagent.dropboxoobe dummy" "Dropbox Promo"
debloat "com.osp.app.signin"                        "Samsung Account (SSO)"
debloat "com.sec.android.app.SecSetupWizard"        "Samsung Setup Wizard"
debloat "com.google.android.setupwizard"            "Google Setup Wizard"
debloat "com.samsung.android.easysetup"             "Samsung Easy Setup"

# ─── AllShare / MirrorLink / NFC extras ──────────────────────────────────────
echo ""
echo "--- [3/10] AllShare / MirrorLink / NFC ---"
debloat "com.samsung.android.allshare.service.fileshare"   "AllShare File Share"
debloat "com.samsung.android.app.FileShareClient"          "AllShare File Share Client"
debloat "com.samsung.android.app.FileShareServer"          "AllShare File Share Server"
debloat "com.samsung.android.nearby.mediaserver"           "AllShare Media Server"
debloat "com.samsung.android.allshare.service.mediashare"  "AllShare Media Share"
debloat "com.samsung.android.app.mirrorlink"               "MirrorLink"
debloat "com.samsung.android.sconnect"                     "Quick Connect"
debloat "com.mobeam.barcodeService"                        "Beam Service (Barcode)"
debloat "com.sec.android.app.wfdbroker"                    "WiFi Display Broker"
debloat "com.samsung.android.beaconmanager"                "Beacon Manager"

# ─── ANT+ (sensores fitness — inútil sin pulsómetro) ─────────────────────────
echo ""
echo "--- [4/10] ANT+ Fitness ---"
debloat "com.dsi.ant.plugins.antplus"               "ANT+ Plugins"
debloat "com.dsi.ant.server"                        "ANT HAL Service"
debloat "com.dsi.ant.service.socket"                "ANT Radio Service"

# ─── Google Bloatware ─────────────────────────────────────────────────────────
echo ""
echo "--- [5/10] Google Bloatware ---"
debloat "com.google.android.apps.books"             "Google Play Books"
debloat "com.google.android.apps.magazines"         "Google Newsstand"
debloat "com.google.android.apps.plus"              "Google+"
debloat "com.google.android.play.games"             "Google Play Games"
debloat "com.google.android.talk"                   "Hangouts"
debloat "com.google.android.videos"                 "Google Play Videos"
debloat "com.google.android.music"                  "Google Play Music"
debloat "com.google.android.marvin.talkback"        "TalkBack (accesibilidad)"
debloat "com.google.android.feedback"               "Google Feedback"
debloat "com.google.android.onetimeinitializer"     "Google One-Time Initializer"
debloat "com.google.android.partnersetup"           "Google Partner Setup"

# ─── Samsung Apps / Widgets innecesarios ─────────────────────────────────────
echo ""
echo "--- [6/10] Samsung Apps / Widgets ---"
debloat "flipboard.app"                             "Flipboard"
debloat "flipboard.boxer.app"                       "Flipboard Briefing"
debloat "com.dropbox.android"                       "Dropbox"
debloat "com.seat.connectedcar.samsung"             "SEAT ConnectedCar"
debloat "com.vlingo.midas"                          "S-Voice"
debloat "com.samsung.helphub"                       "Samsung Interactive Tutorial"
debloat "com.samsung.safetyinformation"             "Safety Information"
debloat "com.samsung.android.app.memo"              "Samsung Memo"
debloat "com.sec.android.Kies"                      "Samsung Kies"
debloat "com.samsung.android.app.watchmanagerstub"  "Gear Manager Stub"
debloat "com.sec.android.app.sns3"                  "Samsung SNS"
debloat "com.samsung.android.app.SamsungContentsAgent" "Samsung Contents Agent"
debloat "com.sec.android.app.SamsungContentsAgent"  "Samsung Contents Agent (alt)"
debloat "com.sec.android.app.billing"               "Samsung Billing"
debloat "com.sec.android.app.samsungapps"           "Galaxy Apps Store"
debloat "com.sec.android.widgetapp.samsungapps"     "Galaxy Apps Widget"
debloat "com.sec.android.app.personalization"       "Personalization Service"
debloat "com.hancom.office.viewer"                  "Hancom Office Viewer"

# ─── Widgets / Fondos de pantalla animados ───────────────────────────────────
echo ""
echo "--- [7/10] Widgets / Live Wallpapers ---"
debloat "com.android.dreams.basic"                  "Basic Dreams (Daydream)"
debloat "com.android.dreams.phototable"             "Photo Table (Daydream)"
debloat "com.android.noisefield"                    "Noise Field Wallpaper"
debloat "com.android.phasebeam"                     "Phase Beam Wallpaper"
debloat "com.sec.android.widgetapp.ap.hero.accuweather" "Accuweather Widget"
debloat "com.sec.android.daemonapp"                 "Weather Daemon"
debloat "com.sec.android.widgetapp.digitalclock"    "Digital Clock Widget"
debloat "com.sec.android.widgetapp.digitalclockeasy" "Digital Clock Easy Widget"
debloat "com.sec.android.widgetapp.dualclockdigital" "Dual Clock Widget"
debloat "com.sec.android.widgetapp.SPlannerAppWidget" "S Planner Widget"
debloat "com.sec.android.widgetapp.tapandpay"       "Tap & Pay Widget"
debloat "com.sec.android.widgetapp.webmanual"       "Web Manual Widget"
debloat "com.sec.android.widgetapp.activeapplicationwidget" "Active Apps Widget"
debloat "com.sec.android.widgetapp.easymodecontactswidget" "Easy Mode Contacts Widget"

# ─── Fuentes extra (Samsung) ─────────────────────────────────────────────────
echo ""
echo "--- [8/10] Fuentes extra Samsung ---"
debloat "com.monotype.android.font.chococooky"      "Fuente Choco Cooky"
debloat "com.monotype.android.font.cooljazz"        "Fuente Cool Jazz"
debloat "com.monotype.android.font.rosemary"        "Fuente Rosemary"

# ─── Telemetría / Diagnóstico / Logging ──────────────────────────────────────
echo ""
echo "--- [9/10] Telemetría / Diagnóstico ---"
debloat "com.samsung.android.securitylogagent"      "Security Log Agent"
debloat "com.sec.android.app.sysscope"              "SysScope (diagnóstico)"
debloat "com.sec.android.diagmonagent"              "Diag Monitor Agent"
debloat "com.samsung.android.intelligenceservice"   "Intelligence Service 1"
debloat "com.samsung.android.intelligenceservice2"  "Intelligence Service 2"
debloat "com.samsung.android.bbc.bbcagent"          "BBC Agent"
debloat "com.qapp.secprotect"                       "SecProtect (Qualcomm)"
debloat "com.sec.android.app.mt"                    "Mobile Tracker Engine"
debloat "com.samsung.android.fmm"                   "Find My Mobile"
debloat "com.wssyncmldm"                            "FOTA Agent (OTA updater)"
debloat "com.wsomacp"                               "OmaCP (provisioning)"
debloat "com.wssnps"                                "WSSyncML NPS"
debloat "com.sec.spp.push"                          "SPP Push Client"
debloat "com.sec.automation"                        "Tethering Automation"
debloat "com.samsung.android.asksmanager"           "ASKS Manager"
debloat "com.samsung.android.sm"                    "Smart Manager"
debloat "com.samsung.android.sm.provider"           "Smart Manager Provider"
debloat "com.cleanmaster.sdk"                       "CleanMaster SDK (bloat)"

# ─── Temas Samsung extra ─────────────────────────────────────────────────────
echo ""
echo "--- [10/10] Temas Samsung extra ---"
debloat "com.sec.android.romantic2"                 "Tema Romantic"
debloat "com.sec.android.classic2"                  "Tema Classic"
debloat "com.sec.android.casual2"                   "Tema Casual"
debloat "com.sec.android.theme.natural"             "Tema Natural"
debloat "com.sec.android.app.themechooser"          "Theme Chooser"

echo ""
echo "═══════════════════════════════════════════════════════"
printf "  🎉 DEBLOAT COMPLETADO — ✅ %d eliminados / ❌ %d fallidos\n" "$ELIMINADOS" "$FALLIDOS"
echo "═══════════════════════════════════════════════════════"
echo ""
echo "📊 Estado de RAM:"
$ADB shell cat /proc/meminfo | tr -d '\r' | grep -E "MemTotal|MemFree|Cached"
echo ""
echo "Para restaurar cualquier app:"
echo "  adb -s $SERIAL shell cmd package install-existing <paquete>"
echo ""
