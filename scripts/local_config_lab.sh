#!/usr/bin/env bash
# Laboratorio reversible para configuraciones locales.
# Permite snapshot, listado, diff y restauracion por dispositivo.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
DEVICES_DIR="$PROJECT_ROOT/Mis_configuraciones_locales/dispositivos"
SNAPSHOT_ROOT="$PROJECT_ROOT/Mis_configuraciones_locales/.snapshots"

usage() {
    cat <<'EOF'
Uso:
  bash scripts/local_config_lab.sh snapshot <dispositivo>
  bash scripts/local_config_lab.sh list <dispositivo>
  bash scripts/local_config_lab.sh diff <dispositivo> <snapshot.tar.gz>
  bash scripts/local_config_lab.sh restore <dispositivo> <snapshot.tar.gz>
EOF
}

validate_device_name() {
    local value="$1"
    [[ "$value" =~ ^[a-zA-Z0-9_-]+$ ]]
}

require_device() {
    local device="$1"
    if [[ -z "$device" ]]; then
        echo "Debes indicar un dispositivo." >&2
        exit 1
    fi
    if ! validate_device_name "$device"; then
        echo "Nombre de dispositivo invalido: $device" >&2
        exit 1
    fi
    if [[ "$device" == "_plantilla" ]]; then
        echo "No se permite operar sobre _plantilla con este comando." >&2
        exit 1
    fi
    if [[ ! -d "$DEVICES_DIR/$device" ]]; then
        echo "Dispositivo no encontrado: $DEVICES_DIR/$device" >&2
        exit 1
    fi
}

cmd="${1:-}"
device="${2:-}"
snap_arg="${3:-}"

case "$cmd" in
    snapshot)
        require_device "$device"
        mkdir -p "$SNAPSHOT_ROOT/$device"
        ts="$(date +%Y%m%d_%H%M%S)"
        snap_file="$SNAPSHOT_ROOT/$device/${ts}.tar.gz"
        tar -czf "$snap_file" -C "$DEVICES_DIR" "$device"
        echo "Snapshot creado: $snap_file"
        ;;
    list)
        require_device "$device"
        if [[ ! -d "$SNAPSHOT_ROOT/$device" ]]; then
            echo "No hay snapshots para $device"
            exit 0
        fi
        ls -1t "$SNAPSHOT_ROOT/$device"/*.tar.gz 2>/dev/null || echo "No hay snapshots para $device"
        ;;
    diff)
        require_device "$device"
        if [[ -z "$snap_arg" ]]; then
            echo "Debes indicar un snapshot para comparar." >&2
            exit 1
        fi
        if [[ ! -f "$snap_arg" ]]; then
            echo "Snapshot no encontrado: $snap_arg" >&2
            exit 1
        fi
        tmp_dir="$(mktemp -d)"
        trap 'rm -rf "$tmp_dir"' EXIT
        tar -xzf "$snap_arg" -C "$tmp_dir"
        diff -ru "$tmp_dir/$device" "$DEVICES_DIR/$device" || true
        ;;
    restore)
        require_device "$device"
        if [[ -z "$snap_arg" ]]; then
            echo "Debes indicar un snapshot para restaurar." >&2
            exit 1
        fi
        if [[ ! -f "$snap_arg" ]]; then
            echo "Snapshot no encontrado: $snap_arg" >&2
            exit 1
        fi
        mkdir -p "$SNAPSHOT_ROOT/$device"
        ts="$(date +%Y%m%d_%H%M%S)"
        backup_file="$SNAPSHOT_ROOT/$device/pre_restore_${ts}.tar.gz"
        tar -czf "$backup_file" -C "$DEVICES_DIR" "$device"

        rm -rf "$DEVICES_DIR/$device"
        tar -xzf "$snap_arg" -C "$DEVICES_DIR"
        echo "Restaurado: $DEVICES_DIR/$device"
        echo "Backup previo guardado en: $backup_file"
        ;;
    -h|--help|help|"")
        usage
        ;;
    *)
        echo "Comando no reconocido: $cmd" >&2
        usage >&2
        exit 1
        ;;
esac
