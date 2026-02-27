#!/usr/bin/env bash
# Descubre ajustes potencialmente reutilizables desde
# Mis_configuraciones_locales/dispositivos/<device> comparando con _plantilla.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
DEVICES_DIR="$PROJECT_ROOT/Mis_configuraciones_locales/dispositivos"
TEMPLATE_DIR="$DEVICES_DIR/_plantilla"
REPORT_DIR="$PROJECT_ROOT/Mis_configuraciones_locales/reportes"

if [[ ! -d "$DEVICES_DIR" ]]; then
    echo "No existe el directorio de dispositivos: $DEVICES_DIR" >&2
    exit 1
fi

if [[ ! -d "$TEMPLATE_DIR" ]]; then
    echo "No existe la plantilla base: $TEMPLATE_DIR" >&2
    exit 1
fi

mkdir -p "$REPORT_DIR"
timestamp="$(date +%Y%m%d_%H%M%S)"
report_file="$REPORT_DIR/discovery_local_${timestamp}.md"

is_candidate_file() {
    local rel="$1"
    local base
    base="$(basename "$rel")"

    # Filtrado basico para evitar secretos y binarios.
    case "$base" in
        .DS_Store|claves.env|claves_globales.env|*.log|*.png|*.jpg|*.jpeg|*.gif|*.mp4|*.mov|*.sqlite|*.db|*.zip|*.tar|*.gz|*.key|*.pem)
            return 1
            ;;
    esac

    case "$rel" in
        scripts_temporales/*|transferencia_de_archivos/*|.git/*)
            return 1
            ;;
    esac

    return 0
}

{
    echo "# Discovery de configuraciones locales"
    echo
    echo "- Fecha: $(date '+%Y-%m-%d %H:%M:%S')"
    echo "- Plantilla base: $TEMPLATE_DIR"
    echo
} > "$report_file"

total_new=0
total_changed=0
devices_processed=0

for device_path in "$DEVICES_DIR"/*; do
    [[ -d "$device_path" ]] || continue
    device="$(basename "$device_path")"
    [[ "$device" == "_plantilla" ]] && continue
    [[ "$device" == .* ]] && continue
    devices_processed=$((devices_processed + 1))

    new_files=()
    changed_files=()

    while IFS= read -r -d '' file_path; do
        rel="${file_path#$device_path/}"
        if ! is_candidate_file "$rel"; then
            continue
        fi

        template_file="$TEMPLATE_DIR/$rel"
        if [[ ! -f "$template_file" ]]; then
            new_files+=("$rel")
            total_new=$((total_new + 1))
            continue
        fi

        if ! cmp -s "$file_path" "$template_file"; then
            changed_files+=("$rel")
            total_changed=$((total_changed + 1))
        fi
    done < <(find "$device_path" -type f -print0)

    {
        echo "## $device"
        echo

        if (( ${#new_files[@]} == 0 && ${#changed_files[@]} == 0 )); then
            echo "- Sin candidatos reutilizables detectados."
            echo
            continue
        fi

        if (( ${#new_files[@]} > 0 )); then
            echo "### Nuevos archivos candidatos"
            for rel in "${new_files[@]}"; do
                echo "- \`$rel\`"
                echo "  - Promocion sugerida: \`bash scripts/local_config_promote.sh $device '$rel'\`"
            done
            echo
        fi

        if (( ${#changed_files[@]} > 0 )); then
            echo "### Archivos que sobreescriben plantilla"
            for rel in "${changed_files[@]}"; do
                echo "- \`$rel\`"
                echo "  - Comparar: \`diff -u '$TEMPLATE_DIR/$rel' '$device_path/$rel'\`"
                echo "  - Promocion sugerida: \`bash scripts/local_config_promote.sh $device '$rel'\`"
            done
            echo
        fi
    } >> "$report_file"
done

{
    echo "## Resumen global"
    echo
    echo "- Dispositivos analizados: $devices_processed"
    echo "- Candidatos nuevos: $total_new"
    echo "- Candidatos de mejora: $total_changed"
    echo
    echo "## Flujo recomendado"
    echo
    echo '```bash'
    echo "bash scripts/local_config_evaluate.sh"
    echo "bash scripts/local_config_discovery.sh"
    echo "# Promociona solo lo valido:"
    echo "bash scripts/local_config_promote.sh <dispositivo> <ruta_relativa>"
    echo '```'
} >> "$report_file"

echo "Reporte generado: $report_file"
