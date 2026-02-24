#!/data/data/com.termux/files/usr/bin/bash
# Intentar listar comandos y guardar en una ruta accesible
DEBIAN_SHELL="/data/data/com.termux/files/usr/bin/proot-distro login debian"

$DEBIAN_SHELL -- openclaw-gateway --help > /sdcard/claw_help_v2.txt 2>&1
$DEBIAN_SHELL -- openclaw-gateway login --help >> /sdcard/claw_help_v2.txt 2>&1
$DEBIAN_SHELL -- openclaw-gateway setup --help >> /sdcard/claw_help_v2.txt 2>&1
chmod 600 /sdcard/claw_help_v2.txt
