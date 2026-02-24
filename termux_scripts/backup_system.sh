#!/data/data/com.termux/files/usr/bin/bash
# ============================================================
# 💾 ApliBot Backup System — "Device Exit Strategy"
# ============================================
# Copia de seguridad del estado del dispositivo.
# Adapta EXTERNAL_SD al UUID de tu tarjeta SD.
# Puedes encontrarlo con: ls -la /storage/
# ============================================

TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_DIR="/sdcard/aplibot_backup_$TIMESTAMP"
EXTERNAL_SD="/storage/YOUR_SD_UUID/aplibot_backup" # Personaliza según tu dispositivo

echo "🚀 Iniciando Backup Total en $BACKUP_DIR..."

mkdir -p "$BACKUP_DIR/termux_home"
mkdir -p "$BACKUP_DIR/openclaw_config"
mkdir -p "$BACKUP_DIR/sdcard_scripts"

# 1. Copiar configuración de OpenClaw (Debian y Termux)
echo "📦 Resguardando configuración de OpenClaw..."
cp -r ~/.openclaw "$BACKUP_DIR/openclaw_config/" 2>/dev/null
proot-distro login debian -- cp -r /root/.openclaw "$BACKUP_DIR/openclaw_config/debian_root/" 2>/dev/null

# 2. Copiar scripts de la SD (los que editamos siempre)
echo "📜 Resguardando scripts de ApliBot..."
cp /sdcard/*.py "$BACKUP_DIR/sdcard_scripts/"
cp /sdcard/*.sh "$BACKUP_DIR/sdcard_scripts/"
cp /sdcard/*.env "$BACKUP_DIR/sdcard_scripts/"
cp /sdcard/*.json "$BACKUP_DIR/sdcard_scripts/"
cp /sdcard/*.md "$BACKUP_DIR/sdcard_scripts/"

# 3. Datos de Termux (Scripts de boot, etc)
echo "🏠 Resguardando entorno Termux..."
cp -r ~/.termux "$BACKUP_DIR/termux_home/"
cp ~/sshd_config "$BACKUP_DIR/termux_home/" 2>/dev/null

# 4. Crear un índice de apps instaladas
echo "📝 Creando inventario de software..."
dpkg --get-selections > "$BACKUP_DIR/termux_packages.txt"

# Intentar mover a la micro-SD física si existe
if [ -d "/storage" ]; then
    SD_PATH=$(ls -d /storage/*/ | grep -v "self" | grep -v "emulated" | head -n 1)
    if [ -n "$SD_PATH" ]; then
        echo "💾 Detectada SD Externa: $SD_PATH"
        mkdir -p "$SD_PATH/aplibot_master_backup"
        cp -r "$BACKUP_DIR" "$SD_PATH/aplibot_master_backup/"
        echo "✅ Backup copiado a SD física: $SD_PATH/aplibot_master_backup/"
    fi
fi

echo "🎉 BACKUP COMPLETADO en $BACKUP_DIR"
echo "Ya puedes limpiar el teléfono con seguridad. 🛡️"
