#!/data/data/com.termux/files/usr/bin/bash
# v17 - Limpiar sesiones y reiniciar
DEBIAN_ROOT="/data/data/com.termux/files/usr/var/lib/proot-distro/installed-rootfs/debian"
SESSIONS_DIR="$DEBIAN_ROOT/root/.openclaw/agents/main/sessions"

# Parar
pkill -9 -x openclaw 2>/dev/null
pkill -9 -f "node.*openclaw" 2>/dev/null
sleep 1

# Borrar TODAS las sesiones (context overflow)
rm -rf "$SESSIONS_DIR"
mkdir -p "$SESSIONS_DIR"

# Limpiar config anterior que causa errores
rm -f /root/.openclaw/openclaw.json

proot-distro login debian -- bash -c "openclaw doctor --fix"
proot-distro login debian -- bash -c "openclaw config set agents.defaults.model.primary groq/llama-3.3-70b-versatile"
proot-distro login debian -- bash -c "openclaw config set channels.telegram.enabled true"
proot-distro login debian -- bash -c "openclaw config set channels.telegram.botToken TU_TELEGRAM_BOT_TOKEN_AQUI"
proot-distro login debian -- bash -c "openclaw config set gateway.mode local"
proot-distro login debian -- bash -c "openclaw config set gateway.port 18789"
# SEGURIDAD: No deshabilitar auth en producción.
# Si necesitas desactivar auth temporalmente para depuración local,
# hazlo manualmente y recuerda reactivarlo después.
# proot-distro login debian -- bash -c "openclaw config set gateway.auth.enabled false"

# Búsqueda Web (Brave Search)
proot-distro login debian -- bash -c "openclaw config set tools.web.search.apiKey TU_BRAVE_API_KEY_AQUI"
proot-distro login debian -- bash -c "openclaw config set tools.web.search.enabled true"

# MCP Configuration
proot-distro login debian -- bash -c "openclaw config set mcpServers.blogger.command npx"
proot-distro login debian -- bash -c "openclaw config set mcpServers.blogger.args '[\"-y\", \"@modelcontextprotocol/server-google-blogger\"]'"
proot-distro login debian -- bash -c "openclaw config set mcpServers.blogger.env.GOOGLE_REFRESH_TOKEN \"TU_GOOGLE_OAUTH_TOKEN_AQUI\""

proot-distro login debian -- bash -c "openclaw doctor --fix"

# Usar el nuevo comando de la versión @latest
echo "Ejecutando prueba de arranque de OpenClaw..."
# SEGURIDAD: --bind 127.0.0.1 evita exposición a la red local.
timeout 20 proot-distro login debian -- bash -c "openclaw gateway run --port 18789 --bind 127.0.0.1"

# Reinicio
bash /sdcard/restart_all.sh
echo "v17 completada. Sesiones limpiadas. Context overflow eliminado."
