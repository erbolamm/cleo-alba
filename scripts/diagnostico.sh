#!/data/data/com.termux/files/usr/bin/bash
# Diagnóstico de sistema (Versión Segura v2)
# Reforzado para evitar fugas de información sensible.

OUT="/sdcard/diag_seguro.txt"
DEBIAN_ROOT="/data/data/com.termux/files/usr/var/lib/proot-distro/installed-rootfs/debian"

echo "=== DIAGNOSTICO SEGURO v2 $(date) ===" > "$OUT"

echo "--- PROCESOS ---" >> "$OUT"
ps -A | grep -E "openclaw|node" >> "$OUT" 2>&1

echo "--- PRESENCIA DE CONFIGURACIÓN ---" >> "$OUT"
for f in "openclaw.json" ".env" "openclaw.config"; do
    [ -f "$DEBIAN_ROOT/root/.openclaw/$f" ] && echo "$f: PRESENTE" || echo "$f: NO ENCONTRADO" >> "$OUT"
done

echo "--- VARIABLES DE ENTORNO (MÁSCARA FUERTE) ---" >> "$OUT"
if [ -f "$DEBIAN_ROOT/root/.openclaw/.env" ]; then
    grep "=" "$DEBIAN_ROOT/root/.openclaw/.env" | while read -r line; do
        var_name=$(echo "$line" | cut -d'=' -f1)
        var_val=$(echo "$line" | cut -d'=' -f2-)
        # Solo mostrar las primeras 3 letras y la longitud si no está vacío
        if [ -n "$var_val" ]; then
            echo "$var_name=${var_val:0:3}...(Longitud: ${#var_val})" >> "$OUT"
        else
            echo "$var_name=(VACÍO)" >> "$OUT"
        fi
    done
fi

echo "--- LOGS RECIENTES (REDACCIÓN AGRESIVA) ---" >> "$OUT"
# Filtro que elimina cualquier cadena alfanumérica larga (+20 caracteres)
REDACT="sed -E 's/[a-zA-Z0-9_-]{20,}/REDACTED/g; s/Bearer [^ \"\n]*/Bearer REDACTED/g'"
tail -n 30 ~/openclaw.log 2>/dev/null | eval $REDACT >> "$OUT" 2>&1

echo "--- CONECTIVIDAD ---" >> "$OUT"
curl -s -o /dev/null -w "API Status: %{http_code}\n" https://api.groq.com/openai/v1/chat/completions >> "$OUT" 2>&1

echo "--- FIN ---" >> "$OUT"
echo "Diagnóstico guardado en $OUT."
