#!/usr/bin/env bash
# Evalua configuraciones locales de Mis_configuraciones_locales/dispositivos
# y genera un reporte en Mis_configuraciones_locales/reportes/.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
DEVICES_DIR="$PROJECT_ROOT/Mis_configuraciones_locales/dispositivos"
REPORT_DIR="$PROJECT_ROOT/Mis_configuraciones_locales/reportes"
STRICT_MODE=0

usage() {
    cat <<'EOF'
Uso:
  bash scripts/local_config_evaluate.sh [--strict]

Opciones:
  --strict  Devuelve codigo != 0 si hay configuraciones incompletas.
  -h        Muestra esta ayuda.
EOF
}

while [[ $# -gt 0 ]]; do
    case "$1" in
        --strict)
            STRICT_MODE=1
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

if [[ ! -d "$DEVICES_DIR" ]]; then
    echo "No existe el directorio: $DEVICES_DIR" >&2
    exit 1
fi

mkdir -p "$REPORT_DIR"
timestamp="$(date +%Y%m%d_%H%M%S)"
report_file="$REPORT_DIR/evaluacion_local_${timestamp}.md"

total=0
ok_count=0
warn_count=0

{
    echo "# Evaluacion de configuraciones locales"
    echo
    echo "- Fecha: $(date '+%Y-%m-%d %H:%M:%S')"
    echo "- Proyecto: $PROJECT_ROOT"
    echo
    echo "| Dispositivo | Estado | Puntuacion | Observaciones |"
    echo "|---|---|---:|---|"
} > "$report_file"

for device_path in "$DEVICES_DIR"/*; do
    [[ -d "$device_path" ]] || continue
    device="$(basename "$device_path")"
    [[ "$device" == "_plantilla" ]] && continue
    [[ "$device" == .* ]] && continue

    total=$((total + 1))
    score=100
    notes=()

    required_files=(
        "notas.md"
        "claves.env"
        "log_instalacion.md"
    )

    for req in "${required_files[@]}"; do
        if [[ ! -f "$device_path/$req" ]]; then
            notes+=("falta '$req'")
            score=$((score - 20))
        fi
    done

    profile_file="$device_path/config_profile.json"
    if [[ -f "$profile_file" ]]; then
        for key in profileId deviceAlias features permissions language; do
            if ! grep -q "\"$key\"" "$profile_file"; then
                notes+=("config_profile.json sin clave '$key'")
                score=$((score - 8))
            fi
        done
    else
        notes+=("sin config_profile.json")
        score=$((score - 10))
    fi

    status="OK"
    if (( score < 80 )) || (( ${#notes[@]} > 0 )); then
        status="WARN"
    fi

    if [[ "$status" == "OK" ]]; then
        ok_count=$((ok_count + 1))
    else
        warn_count=$((warn_count + 1))
    fi

    if (( score < 0 )); then
        score=0
    fi

    if (( ${#notes[@]} == 0 )); then
        note_text="lista para pruebas"
    else
        note_text="$(IFS='; '; echo "${notes[*]}")"
    fi

    echo "| $device | $status | $score | $note_text |" >> "$report_file"
done

{
    echo
    echo "## Resumen"
    echo
    echo "- Total dispositivos evaluados: $total"
    echo "- OK: $ok_count"
    echo "- WARN: $warn_count"
    echo
    echo "## Siguiente paso recomendado"
    echo
    echo '```bash'
    echo "bash scripts/local_config_discovery.sh"
    echo '```'
} >> "$report_file"

echo "Reporte generado: $report_file"

if (( STRICT_MODE == 1 && warn_count > 0 )); then
    exit 2
fi
