#!/usr/bin/env bash
# Detecta la configuracion local activa para ClawMobil.
# Prioridad:
# 1) --device <nombre>
# 2) CLAWMOBIL_DEVICE
# 3) Mis_configuraciones_locales/dispositivos/.active_device
# 4) DEVICE_NAME en config/config.sh (si no es placeholder)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
LOCAL_DEVICES_DIR="$PROJECT_ROOT/Mis_configuraciones_locales/dispositivos"
ACTIVE_FILE="$LOCAL_DEVICES_DIR/.active_device"
CONFIG_SH="$PROJECT_ROOT/config/config.sh"

OUTPUT_MODE="exports"
DEVICE_ARG=""

usage() {
    cat <<'EOF'
Uso:
  bash scripts/local_config_select.sh [--device <nombre>] [--name|--json]

Salida por defecto:
  export CLAWMOBIL_DEVICE="..."
  export CLAWMOBIL_DEVICE_DIR="..."
  export CLAWMOBIL_PROFILE_JSON="..."

Opciones:
  --device <nombre>  Fuerza un dispositivo concreto.
  --name             Imprime solo el nombre del dispositivo activo.
  --json             Imprime un objeto JSON con la seleccion.
  -h, --help         Muestra esta ayuda.
EOF
}

list_devices() {
    if [[ ! -d "$LOCAL_DEVICES_DIR" ]]; then
        return
    fi
    local path base
    for path in "$LOCAL_DEVICES_DIR"/*; do
        [[ -d "$path" ]] || continue
        base="$(basename "$path")"
        [[ "$base" == "_plantilla" ]] && continue
        [[ "$base" == .* ]] && continue
        echo "$base"
    done
}

validate_device_name() {
    local value="$1"
    if [[ "$value" =~ ^[a-zA-Z0-9_-]+$ ]]; then
        return 0
    fi
    return 1
}

parse_config_device_name() {
    if [[ ! -f "$CONFIG_SH" ]]; then
        return 0
    fi
    local cfg
    cfg="$(sed -n 's/^DEVICE_NAME="\([^"]*\)"/\1/p' "$CONFIG_SH" | head -n 1)"
    if [[ -n "$cfg" && "$cfg" != "mi_dispositivo" ]]; then
        echo "$cfg"
    fi
    return 0
}

while [[ $# -gt 0 ]]; do
    case "$1" in
        --device)
            if [[ $# -lt 2 ]]; then
                echo "Falta valor para --device" >&2
                exit 1
            fi
            DEVICE_ARG="${2:-}"
            shift 2
            ;;
        --name)
            OUTPUT_MODE="name"
            shift
            ;;
        --json)
            OUTPUT_MODE="json"
            shift
            ;;
        -h|--help)
            usage
            exit 0
            ;;
        *)
            echo "Parametro no reconocido: $1" >&2
            usage >&2
            exit 1
            ;;
    esac
done

selected=""

if [[ -n "$DEVICE_ARG" ]]; then
    selected="$DEVICE_ARG"
elif [[ -n "${CLAWMOBIL_DEVICE:-}" ]]; then
    selected="$CLAWMOBIL_DEVICE"
elif [[ -f "$ACTIVE_FILE" ]]; then
    selected="$(tr -d '[:space:]' < "$ACTIVE_FILE")"
elif cfg_name="$(parse_config_device_name)"; [[ -n "${cfg_name:-}" ]]; then
    selected="$cfg_name"
fi

if [[ -z "$selected" ]]; then
    mapfile -t available_devices < <(list_devices)
    if (( ${#available_devices[@]} == 1 )); then
        selected="${available_devices[0]}"
    else
        echo "No se pudo detectar un dispositivo activo." >&2
        echo "Dispositivos disponibles:" >&2
        list_devices | sed 's/^/  - /' >&2 || true
        echo "Sugerencia: export CLAWMOBIL_DEVICE=<nombre> o crea $ACTIVE_FILE" >&2
        exit 1
    fi
fi

if ! validate_device_name "$selected"; then
    echo "Nombre de dispositivo invalido: '$selected'" >&2
    echo "Usa solo letras, numeros, guion (-) o guion bajo (_)." >&2
    exit 1
fi

selected_dir="$LOCAL_DEVICES_DIR/$selected"
if [[ ! -d "$selected_dir" ]]; then
    echo "El dispositivo '$selected' no existe en: $selected_dir" >&2
    echo "Dispositivos disponibles:" >&2
    list_devices | sed 's/^/  - /' >&2 || true
    exit 1
fi

profile_json="$selected_dir/config_profile.json"
profile_state="missing"
if [[ -f "$profile_json" ]]; then
    profile_state="present"
fi

case "$OUTPUT_MODE" in
    name)
        echo "$selected"
        ;;
    json)
        cat <<EOF
{
  "device": "$selected",
  "deviceDir": "$selected_dir",
  "profileJson": "$profile_json",
  "profileState": "$profile_state"
}
EOF
        ;;
    exports)
        cat <<EOF
export CLAWMOBIL_DEVICE="$selected"
export CLAWMOBIL_DEVICE_DIR="$selected_dir"
export CLAWMOBIL_PROFILE_JSON="$profile_json"
EOF
        ;;
esac
