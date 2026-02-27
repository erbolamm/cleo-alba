#!/usr/bin/env bash
# Promociona un archivo desde un dispositivo local hacia _plantilla
# con backup automatico y log de trazabilidad.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
DEVICES_DIR="$PROJECT_ROOT/Mis_configuraciones_locales/dispositivos"
TEMPLATE_DIR="$DEVICES_DIR/_plantilla"
REPORT_DIR="$PROJECT_ROOT/Mis_configuraciones_locales/reportes"
PROMO_LOG="$REPORT_DIR/promociones.log"

usage() {
    cat <<'EOF'
Uso:
  bash scripts/local_config_promote.sh <dispositivo> <ruta_relativa> [--to <ruta_template>]

Ejemplo:
  bash scripts/local_config_promote.sh huawei_p10 notas.md
  bash scripts/local_config_promote.sh huawei_p10 custom/setup.md --to docs/setup.md
EOF
}

validate_rel_path() {
    local rel="$1"
    if [[ -z "$rel" ]]; then
        return 1
    fi
    if [[ "$rel" == /* ]]; then
        return 1
    fi
    if [[ "$rel" == *".."* ]]; then
        return 1
    fi
    if [[ "$rel" == *$'\n'* || "$rel" == *$'\r'* ]]; then
        return 1
    fi
    return 0
}

validate_device_name() {
    local value="$1"
    [[ "$value" =~ ^[a-zA-Z0-9_-]+$ ]]
}

if [[ $# -lt 2 ]]; then
    usage >&2
    exit 1
fi

device="$1"
relative_path="$2"
target_relative="$relative_path"

shift 2
while [[ $# -gt 0 ]]; do
    case "$1" in
        --to)
            target_relative="${2:-}"
            shift 2
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

if ! validate_rel_path "$relative_path"; then
    echo "Ruta relativa invalida (origen): $relative_path" >&2
    exit 1
fi

if ! validate_rel_path "$target_relative"; then
    echo "Ruta relativa invalida (destino): $target_relative" >&2
    exit 1
fi

if [[ "$device" == "_plantilla" ]]; then
    echo "No puedes promocionar desde _plantilla." >&2
    exit 1
fi

if ! validate_device_name "$device"; then
    echo "Nombre de dispositivo invalido: $device" >&2
    exit 1
fi

source_file="$DEVICES_DIR/$device/$relative_path"
target_file="$TEMPLATE_DIR/$target_relative"

if [[ ! -f "$source_file" ]]; then
    echo "Archivo origen no encontrado: $source_file" >&2
    exit 1
fi

base_name="$(basename "$source_file")"
case "$base_name" in
    claves.env|claves_globales.env|*.key|*.pem|*.p12|*.jks)
        echo "Bloqueado por seguridad: no se promocionan secretos ($base_name)." >&2
        exit 1
        ;;
esac

mkdir -p "$(dirname "$target_file")"
mkdir -p "$TEMPLATE_DIR/_historial"
mkdir -p "$REPORT_DIR"

timestamp="$(date +%Y%m%d_%H%M%S)"
if [[ -f "$target_file" ]]; then
    backup_name="$(echo "$target_relative" | tr '/' '_')"
    cp "$target_file" "$TEMPLATE_DIR/_historial/${timestamp}__${backup_name}"
fi

cp "$source_file" "$target_file"

{
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] device=$device source=$relative_path target=$target_relative"
} >> "$PROMO_LOG"

echo "Promocion aplicada:"
echo "  origen : $source_file"
echo "  destino: $target_file"
echo "  log    : $PROMO_LOG"
