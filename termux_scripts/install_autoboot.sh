#!/data/data/com.termux/files/usr/bin/bash
# ============================================================
# 🦞 ApliBot — Instalador de AutoBoot
# Archivo: /sdcard/install_autoboot.sh
# Ejecutar UNA VEZ después de instalar Termux:Boot
# ============================================================

echo "🔧 Instalando ApliBot AutoBoot..."

# 1. Crear directorio de Termux:Boot
mkdir -p ~/.termux/boot
echo "✅ Directorio ~/.termux/boot/ creado"

# 2. Copiar el script de arranque automático
if [ -f /sdcard/boot_autostart.sh ]; then
    cp /sdcard/boot_autostart.sh ~/.termux/boot/boot_autostart.sh
    chmod +x ~/.termux/boot/boot_autostart.sh
    echo "✅ Script boot_autostart.sh instalado"
else
    echo "❌ ERROR: No se encontró /sdcard/boot_autostart.sh"
    echo "   Descárgalo primero desde el repositorio de ClawMobil."
    exit 1
fi

# 3. Verificar que Termux:Boot esté disponible
if [ -d ~/.termux/boot ]; then
    echo ""
    echo "✅ ¡Instalación completa!"
    echo ""
    echo "PASOS FINALES REQUERIDOS:"
    echo "  1. Instala 'Termux:Boot' desde F-Droid si no lo has hecho."
    echo "  2. Abre la app 'Termux:Boot' UNA VEZ para activarla."
    echo "  3. Reinicia el teléfono para probar el inicio automático."
    echo ""
    echo "📋 Log de arranque disponible en: /sdcard/aplibot_boot.log"
else
    echo "❌ ERROR: No se pudo crear el directorio de boot."
fi
