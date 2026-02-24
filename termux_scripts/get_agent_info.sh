#!/data/data/com.termux/files/usr/bin/bash
# Información de Agente (SEGURO)
# Versión no intrusiva para diagnósticos rápidos.

OC_MAIN_AGENT="/data/data/com.termux/files/usr/var/lib/proot-distro/installed-rootfs/debian/root/.openclaw/agents/main"
OUT="/sdcard/Download/agent_info_safe.txt"

echo "=== AGENT INFO (SAFE) ===" > "$OUT"

echo "Directorio: $OC_MAIN_AGENT" >> "$OUT"

echo -e "\n--- Archivos Críticos ---" >> "$OUT"
for f in "agent.json" "auth-profiles.json" "instructions.md"; do
    if [ -f "$OC_MAIN_AGENT/$f" ]; then
        echo "[✓] $f ($(du -h "$OC_MAIN_AGENT/$f" | cut -f1))" >> "$OUT"
    else
        echo "[ ] $f (NO ENCONTRADO)" >> "$OUT"
    fi
done

echo -e "\n--- Perfiles de Audio/Auth (Sin secretos) ---" >> "$OUT"
if [ -f "$OC_MAIN_AGENT/auth-profiles.json" ]; then
   grep -E "\"provider\"|\"mode\"" "$OC_MAIN_AGENT/auth-profiles.json" | sed 's/^[[:space:]]*//' >> "$OUT"
fi

echo -e "\nFIN. El contenido sensible ha sido omitido." >> "$OUT"
