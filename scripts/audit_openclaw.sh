# ============================================
# 🔍 AUDITORÍA DE OPENCLAW
# ============================================
# Este script ayuda a diagnosticar problemas de conexión, 
# procesos colgados o configuración incorrecta.
# Ejecútalo desde el Mac con el teléfono conectado.

echo "🔍 Auditando OpenClaw en el dispositivo..."
echo ""

# 1. Verificar que ADB ve el teléfono
if ! adb devices 2>/dev/null | grep -q "device$"; then
    echo "❌ No se detecta el teléfono vía ADB."
    echo "   Asegúrate de que está conectado por USB y con depuración USB activada."
    exit 1
fi
echo "✅ Teléfono conectado vía ADB"
echo ""

# 2. Procesos activos relacionados con OpenClaw/Node
echo "=== 🟢 PROCESOS ACTIVOS EN EL TELÉFONO ==="
echo "(Si no ves 'node' o 'python', el servidor no está corriendo)"
adb shell "ps -A 2>/dev/null | grep -E 'node|openclaw|proot|python' | grep -v grep" || \
    echo "  ⚠️ No hay procesos de IA activos"
echo ""

# 3. Buscar binarios de openclaw dentro de Termux
echo "=== 📦 BINARIOS DE OPENCLAW ==="

# En Termux nativo
echo "--- Termux (nativo) ---"
adb shell "ls -la /data/data/com.termux/files/usr/bin/openclaw 2>/dev/null" || \
    echo "  (no encontrado en Termux nativo)"

# En Debian (proot-distro)
echo "--- Debian (proot-distro) ---"
adb shell "ls -la /data/data/com.termux/files/usr/var/lib/proot-distro/installed-rootfs/debian/usr/bin/openclaw 2>/dev/null" || \
    echo "  (no encontrado en /usr/bin)"
adb shell "ls -la /data/data/com.termux/files/usr/var/lib/proot-distro/installed-rootfs/debian/usr/local/bin/openclaw 2>/dev/null" || \
    echo "  (no encontrado en /usr/local/bin)"

# En node_modules global
echo "--- Node global ---"
adb shell "find /data/data/com.termux/files/usr/var/lib/proot-distro/installed-rootfs/debian -path '*/node_modules/.bin/openclaw' 2>/dev/null" || \
    echo "  (no encontrado en node_modules)"
echo ""

# 4. Aliases configurados en .bashrc
echo "=== 🏷️ ESTADO DE .bashrc ==="
adb shell "[ -f /data/data/com.termux/files/home/.bashrc ] && echo '.bashrc presente' && grep 'alias' /data/data/com.termux/files/home/.bashrc || echo '.bashrc no encontrado o sin aliases'"
echo ""

# 5. Script de boot
echo "=== 🚀 SCRIPT DE AUTO-ARRANQUE (Estado) ==="
adb shell "ls -la /data/data/com.termux/files/home/.termux/boot/start-openclaw.sh 2>/dev/null" || \
    echo "  (no encontrado)"
echo ""

# 6. Configuración de OpenClaw (Estado)
echo "=== ⚙️ CONFIGURACIÓN OPENCLAW (Presencia) ==="
adb shell "ls -la /data/data/com.termux/files/usr/var/lib/proot-distro/installed-rootfs/debian/root/.openclaw/openclaw.config 2>/dev/null" || \
    echo "  (no se encontró openclaw.config)"
adb shell "ls -la /data/data/com.termux/files/usr/var/lib/proot-distro/installed-rootfs/debian/root/.openclaw/openclaw.json 2>/dev/null" || \
    echo "  (no se encontró openclaw.json)"
echo ""

# 7. Logs recientes (Redactados)
echo "=== 📋 ÚLTIMOS LOGS (Redactados) ==="
echo "--- boot.log ---"
adb shell "tail -5 /data/data/com.termux/files/home/boot.log 2>/dev/null" | sed 's/TOKEN=[^ ]*/TOKEN=********/' || \
    echo "  (no encontrado)"
echo "--- openclaw.log ---"
adb shell "tail -10 /data/data/com.termux/files/home/openclaw.log 2>/dev/null" | sed -E 's/gsk_[a-zA-Z0-9]{32,}/gsk_REDACTED/g; s/sk_[a-zA-Z0-9]{32,}/sk_REDACTED/g' || \
    echo "  (no encontrado)"
echo ""

# 8. SSH keys check (Solo existencia)
echo "=== 🔐 SSH KEYS (Estado) ==="
adb shell "[ -f /data/data/com.termux/files/home/.ssh/authorized_keys ] && echo 'authorized_keys presente (SSH debería funcionar)' || echo 'authorized_keys NO ENCONTRADO'"
echo ""

echo "==========================================="
echo "🏁 Auditoría completada"
echo "==========================================="
