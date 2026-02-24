#!/data/data/com.termux/files/usr/bin/bash
# BACKUP SIMPLIFICADO - EJECUTAR EN TERMUX
DEST="/sdcard/APLIBOT_SAFE_BACKUP"
mkdir -p "$DEST"
echo "Copiando archivos..."
cp -r ~/.openclaw "$DEST/openclaw_home"
cp /sdcard/*.py "$DEST/"
cp /sdcard/*.sh "$DEST/"
cp /sdcard/*.env "$DEST/"
cp /sdcard/*.json "$DEST/"
echo "HECHO. Verifica la carpeta APLIBOT_SAFE_BACKUP en tu memoria interna."
