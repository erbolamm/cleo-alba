#!/usr/bin/env bash
# Chequeo pre-directo de ClawMobil (sin tocar configuracion del sistema).

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

req_cmds=(bash node tar shasum find diff sed awk)
for cmd in "${req_cmds[@]}"; do
    if ! command -v "$cmd" >/dev/null 2>&1; then
        echo "[prelive] ERROR: comando requerido no disponible: $cmd" >&2
        exit 1
    fi
done

echo "[prelive] Sintaxis shell"
bash -n \
  "$SCRIPT_DIR/local_config_select.sh" \
  "$SCRIPT_DIR/local_config_evaluate.sh" \
  "$SCRIPT_DIR/local_config_discovery.sh" \
  "$SCRIPT_DIR/local_config_watch.sh" \
  "$SCRIPT_DIR/local_config_lab.sh" \
  "$SCRIPT_DIR/local_config_promote.sh" \
  "$SCRIPT_DIR/local_config_selftest.sh" \
  "$SCRIPT_DIR/wizard_local_smoketest.sh"

echo "[prelive] Selftest framework local"
bash "$SCRIPT_DIR/local_config_selftest.sh"

echo "[prelive] Smoke test wizard empezar.html"
bash "$SCRIPT_DIR/wizard_local_smoketest.sh"

echo "[prelive] Watch loop corto"
bash "$SCRIPT_DIR/local_config_watch.sh" --loop --interval 1 >/tmp/clawmobil_prelive_watch.log 2>&1 &
watch_pid=$!
sleep 2
kill "$watch_pid" >/dev/null 2>&1 || true
wait "$watch_pid" >/dev/null 2>&1 || true
sed -n '1,20p' /tmp/clawmobil_prelive_watch.log

echo "[prelive] OK: entorno local listo para directo"
echo "[prelive] Siguiente paso manual (solo lectura): adb -s <DEVICE_SERIAL> shell \"getprop ro.product.model; dumpsys battery | sed -n '1,30p'; df -h /data /sdcard; cat /proc/meminfo | sed -n '1,8p'; ps -A | grep -Ei 'openclaw|gateway|python|termux'; netstat -lnt\""
