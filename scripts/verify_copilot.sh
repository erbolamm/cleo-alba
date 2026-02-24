#!/data/data/com.termux/files/usr/bin/bash
# Verificar integración de Copilot (SEGURO)
# Solo comprueba si la palabra clave existe en la config sin volcar la línea.

DEBIAN_SHELL="/data/data/com.termux/files/usr/bin/proot-distro login debian"
OUT="/sdcard/provider_check.txt"

echo "=== VERIFICACIÓN COPILOT $(date) ===" > "$OUT"

if $DEBIAN_SHELL -- grep -qi "copilot" ~/.openclaw/openclaw.json; then
    echo "ESTADO: Copilot está presente en la configuración. ✅" >> "$OUT"
else
    echo "ESTADO: Copilot NO detectado en la configuración. ❌" >> "$OUT"
fi

chmod 600 "$OUT"
echo "Check completado en $OUT"
