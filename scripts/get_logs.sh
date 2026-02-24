#!/data/data/com.termux/files/usr/bin/bash
# Extracción de Logs (SEGURO)
# Redacta automáticamente claves y tokens antes de exportar a la SD.

DEBIAN_ROOT="/data/data/com.termux/files/usr/var/lib/proot-distro/installed-rootfs/debian"
DATE=$(date +%Y-%m-%d)
REAL_LOG="$DEBIAN_ROOT/tmp/openclaw/openclaw-$DATE.log"
OUT="/sdcard/openclaw_error_seguro.txt"

echo "=== EXTRACCIÓN DE LOGS SEGURA $(date) ===" > "$OUT"

if [ -f "$REAL_LOG" ]; then
    echo "--- Fragmentos de Error Redactados ---" >> "$OUT"
    # Buscamos errores y aplicamos un filtro de redacción fuerte
    grep -A 10 -B 5 "isError" "$REAL_LOG" | \
    sed -E 's/[a-zA-Z0-9_-]{32,}/******** /g; s/Bearer [^"]*/Bearer ******** /g; s/key=[^ ]*/key=******** /g' >> "$OUT"
    
    echo -e "\n--- Últimas 50 líneas Redactadas ---" >> "$OUT"
    tail -n 50 "$REAL_LOG" | \
    sed -E 's/[a-zA-Z0-9_-]{32,}/******** /g; s/Bearer [^"]*/Bearer ******** /g; s/key=[^ ]*/key=******** /g' >> "$OUT"
else
    echo "Log no encontrado: $REAL_LOG" >> "$OUT"
    ls -la "$DEBIAN_ROOT/tmp/openclaw/" 2>/dev/null >> "$OUT"
fi

echo "Logs exportados a $OUT. REDACTA manualmente cualquier dato personal que quede."
