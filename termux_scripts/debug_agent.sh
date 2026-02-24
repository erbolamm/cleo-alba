#!/data/data/com.termux/files/usr/bin/bash
# Diagnóstico de Agente (SEGURO)
# Solo verifica la existencia y metadatos de los archivos del agente para evitar fugas.

OC_MAIN_AGENT="/data/data/com.termux/files/usr/var/lib/proot-distro/installed-rootfs/debian/root/.openclaw/agents/main"
OUT="/sdcard/Download/agent_debug_seguro.txt"

echo "=== AGENT STATUS CHECK $(date) ===" > "$OUT"

echo -e "\n--- PRESENCIA DE ARCHIVOS ---" >> "$OUT"
[ -f "$OC_MAIN_AGENT/agent.json" ] && (ls -la "$OC_MAIN_AGENT/agent.json" >> "$OUT") || echo "agent.json: NO ENCONTRADO" >> "$OUT"
[ -f "$OC_MAIN_AGENT/auth-profiles.json" ] && (ls -la "$OC_MAIN_AGENT/auth-profiles.json" >> "$OUT") || echo "auth-profiles.json: NO ENCONTRADO" >> "$OUT"

echo -e "\n--- ESTRUCTURA DE DIRECTORIOS ---" >> "$OUT"
ls -R "$OC_MAIN_AGENT" | grep ":" | sed 's/://' >> "$OUT" 2>/dev/null

echo -e "\n--- VERIFICACIÓN DE LLAVES (MÁSCARA) ---" >> "$OUT"
# Busca líneas que parezcan contener secretos pero las máscara
if [ -f "$OC_MAIN_AGENT/auth-profiles.json" ]; then
    grep -E "key|token|id|secret" "$OC_MAIN_AGENT/auth-profiles.json" | sed -E 's/: ".*"/: "********"/' >> "$OUT"
fi

echo -e "\nDONE. Revisa $OUT antes de compartir." >> "$OUT"
