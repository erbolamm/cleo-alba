#!/data/data/com.termux/files/usr/bin/bash
# ============================================
# 🚀 MIGRACIÓN A MICRO SD PARA APLIMOBILBOT
# ============================================
export PATH="/data/data/com.termux/files/usr/bin:$PATH"

# Personaliza YOUR_SD_UUID con el UUID de tu tarjeta SD.
# Encúentralo con: ls -la /storage/
SD_PATH="/storage/YOUR_SD_UUID/Android/data/com.termux/files/OpenClawData"
DEBIAN_ROOT="/data/data/com.termux/files/usr/var/lib/proot-distro/installed-rootfs/debian"
OC_PATH="$DEBIAN_ROOT/root/.openclaw"
SD_OC_PATH="$SD_PATH/.openclaw"

echo ""
echo "=== INICIANDO MIGRACION A MICRO SD ==="

mkdir -p "$SD_PATH"
if [ ! -d "$SD_OC_PATH" ]; then
    echo "[+] Deteniendo OpenClaw..."
    pkill -9 -f openclaw 2>/dev/null
    
    echo "[+] Copiando cerebro y configuración a la tarjeta SD..."
    cp -r "$OC_PATH" "$SD_PATH/"
    
    echo "[+] Creando enlaces simbólicos..."
    mv "$OC_PATH" "${OC_PATH}_backup"
    ln -s "$SD_OC_PATH" "$OC_PATH"
    
    echo "[+] ¡Migración del cerebro completada!"
else
    echo "[!] La tarjeta SD ya contenía el cerebro de OpenClaw."
    echo "[+] Recreando enlace simbólico por seguridad..."
    mv "$OC_PATH" "${OC_PATH}_backup" 2>/dev/null
    ln -s "$SD_OC_PATH" "$OC_PATH"
fi

OBSIDIAN_SD="$SD_PATH/Obsidian"
mkdir -p "$OBSIDIAN_SD"
echo "[+] Bóveda privada de Obsidian creada en la tarjeta SD: $OBSIDIAN_SD"
echo "=== PROCESO FINALIZADO ==="

bash /sdcard/restart_all.sh
