#!/data/data/com.termux/files/usr/bin/bash
echo "--- ENTORNO DEBIAN ---"
proot-distro login debian -- bash -c "which openclaw && node -v && openclaw --version"
