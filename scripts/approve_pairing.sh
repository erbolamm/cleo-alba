#!/data/data/com.termux/files/usr/bin/bash
# Escribir resultado en home de Termux
OUT="$HOME/pairing_out.txt"
echo "=== $(date) ===" > "$OUT"
proot-distro login debian -- openclaw pairing approve telegram TRNGYR33 >> "$OUT" 2>&1
echo "EXIT: $?" >> "$OUT"
proot-distro login debian -- openclaw config set channels.telegram.autoApprove true >> "$OUT" 2>&1
echo "AUTOAPPROVE_EXIT: $?" >> "$OUT"
# Copiar al sdcard
cp "$OUT" /sdcard/pairing_result.txt 2>/dev/null
