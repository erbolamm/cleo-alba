#!/data/data/com.termux/files/usr/bin/bash
echo "--- DIAGNÓSTICO DEBIAN ---"
proot-distro login debian -- bash -c "rm -f /root/.openclaw/openclaw.json && openclaw doctor && openclaw gateway start --daemon false"
