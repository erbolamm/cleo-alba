#!/usr/bin/env bash
# Self-test end-to-end del framework local de configuraciones.
# No requiere hardware; valida scripts sobre un dispositivo de prueba local.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
DEVICES_DIR="$PROJECT_ROOT/Mis_configuraciones_locales/dispositivos"
TEMPLATE_DIR="$DEVICES_DIR/_plantilla"
REPORT_DIR="$PROJECT_ROOT/Mis_configuraciones_locales/reportes"
SELFTEST_DEVICE="selftest_device"
SELFTEST_DIR="$DEVICES_DIR/$SELFTEST_DEVICE"
PROMOTE_TARGET_DIR="$TEMPLATE_DIR/_selftest"
ACTIVE_FILE="$DEVICES_DIR/.active_device"
PREV_ACTIVE=""
HAD_ACTIVE=0

fail() {
    echo "[selftest] ERROR: $*" >&2
    exit 1
}

cleanup() {
    rm -rf "$SELFTEST_DIR"
    rm -rf "$PROMOTE_TARGET_DIR"
    if (( HAD_ACTIVE == 1 )); then
        printf '%s\n' "$PREV_ACTIVE" > "$ACTIVE_FILE"
    else
        rm -f "$ACTIVE_FILE"
    fi
}

trap cleanup EXIT

mkdir -p "$TEMPLATE_DIR" "$REPORT_DIR"

if [[ -f "$ACTIVE_FILE" ]]; then
    HAD_ACTIVE=1
    PREV_ACTIVE="$(cat "$ACTIVE_FILE")"
fi

# Asegura plantilla minima
[[ -f "$TEMPLATE_DIR/notas.md" ]] || echo "# notas plantilla" > "$TEMPLATE_DIR/notas.md"
[[ -f "$TEMPLATE_DIR/claves.env" ]] || echo "API_KEY=CAMBIAR" > "$TEMPLATE_DIR/claves.env"
[[ -f "$TEMPLATE_DIR/log_instalacion.md" ]] || echo "# log" > "$TEMPLATE_DIR/log_instalacion.md"

mkdir -p "$SELFTEST_DIR"
cp "$TEMPLATE_DIR/notas.md" "$SELFTEST_DIR/notas.md"
cp "$TEMPLATE_DIR/claves.env" "$SELFTEST_DIR/claves.env"
cp "$TEMPLATE_DIR/log_instalacion.md" "$SELFTEST_DIR/log_instalacion.md"

cat > "$SELFTEST_DIR/config_profile.json" <<'JSON'
{
  "schemaVersion": "1.0",
  "profileId": "selftest_profile",
  "deviceAlias": "selftest_device",
  "profile": "custom",
  "language": "es",
  "features": {
    "messaging": true,
    "automation": true
  },
  "permissions": {
    "microphone": true,
    "storage": true
  }
}
JSON

echo "selftest_device" > "$ACTIVE_FILE"

echo "[selftest] local_config_select"
select_json="$(bash "$SCRIPT_DIR/local_config_select.sh" --json)"
echo "$select_json" | grep -q '"device": "selftest_device"' || fail "select no detecto selftest_device"

echo "[selftest] local_config_evaluate"
bash "$SCRIPT_DIR/local_config_evaluate.sh" >/tmp/local_config_evaluate.out

echo "[selftest] local_config_discovery"
bash "$SCRIPT_DIR/local_config_discovery.sh" >/tmp/local_config_discovery.out

echo "[selftest] local_config_watch"
bash "$SCRIPT_DIR/local_config_watch.sh" >/tmp/local_config_watch.out

echo "[selftest] local_config_lab snapshot/list/diff/restore"
snapshot_line="$(bash "$SCRIPT_DIR/local_config_lab.sh" snapshot "$SELFTEST_DEVICE")"
snapshot_path="${snapshot_line#Snapshot creado: }"
[[ -f "$snapshot_path" ]] || fail "snapshot no generado"

bash "$SCRIPT_DIR/local_config_lab.sh" list "$SELFTEST_DEVICE" >/tmp/local_config_lab_list.out

echo "selftest-cambio" >> "$SELFTEST_DIR/notas.md"
bash "$SCRIPT_DIR/local_config_lab.sh" diff "$SELFTEST_DEVICE" "$snapshot_path" >/tmp/local_config_lab_diff.out || true

bash "$SCRIPT_DIR/local_config_lab.sh" restore "$SELFTEST_DEVICE" "$snapshot_path" >/tmp/local_config_lab_restore.out

echo "[selftest] local_config_promote"
bash "$SCRIPT_DIR/local_config_promote.sh" "$SELFTEST_DEVICE" "notas.md" --to "_selftest/notas.md" >/tmp/local_config_promote.out

if bash "$SCRIPT_DIR/local_config_promote.sh" "$SELFTEST_DEVICE" "claves.env" --to "_selftest/claves.env" >/tmp/local_config_promote_block.out 2>&1; then
    fail "promote deberia bloquear secretos y no lo hizo"
fi

echo "[selftest] OK: flujo local completo validado"
