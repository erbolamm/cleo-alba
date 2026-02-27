#!/usr/bin/env bash
# Detector automatico de cambios en Mis_configuraciones_locales/dispositivos.
# Si detecta cambios, ejecuta discovery y muestra una notificacion en consola.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
DEVICES_DIR="$PROJECT_ROOT/Mis_configuraciones_locales/dispositivos"
STATE_DIR="$PROJECT_ROOT/Mis_configuraciones_locales/.watch"
STATE_FILE="$STATE_DIR/last_hash.txt"
LOOP_MODE=0
INTERVAL=20

usage() {
    cat <<'HELP'
Uso:
  bash scripts/local_config_watch.sh [--loop] [--interval <segundos>]

Opciones:
  --loop               Mantiene vigilancia continua.
  --interval <seg>     Frecuencia de escaneo en modo loop (default: 20).
  -h, --help           Muestra ayuda.
HELP
}

while [[ $# -gt 0 ]]; do
    case "$1" in
        --loop)
            LOOP_MODE=1
            shift
            ;;
        --interval)
            if [[ $# -lt 2 ]]; then
                echo "Falta valor para --interval" >&2
                exit 1
            fi
            INTERVAL="$2"
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

if [[ ! -d "$DEVICES_DIR" ]]; then
    echo "No existe el directorio de dispositivos: $DEVICES_DIR" >&2
    exit 1
fi

if ! [[ "$INTERVAL" =~ ^[0-9]+$ ]] || (( INTERVAL < 1 )); then
    echo "Intervalo invalido: $INTERVAL" >&2
    exit 1
fi

mkdir -p "$STATE_DIR"

calc_hash() {
    local files_hash
    files_hash="$({
        find "$DEVICES_DIR" -type f \
            ! -name ".DS_Store" \
            ! -name "*.log" \
            ! -name "*.tar" \
            ! -name "*.gz" \
            -print0 | LC_ALL=C sort -z | xargs -0 shasum 2>/dev/null || true
    } | shasum | awk '{print $1}')"
    echo "$files_hash"
}

run_once() {
    local current_hash previous_hash report_line
    current_hash="$(calc_hash)"
    previous_hash=""

    if [[ -f "$STATE_FILE" ]]; then
        previous_hash="$(cat "$STATE_FILE")"
    fi

    if [[ "$current_hash" != "$previous_hash" ]]; then
        echo "$current_hash" > "$STATE_FILE"
        report_line="$(bash "$SCRIPT_DIR/local_config_discovery.sh" | tail -n 1)"
        echo "[local-config-watch] Cambios detectados en configuraciones locales."
        echo "[local-config-watch] $report_line"
    else
        echo "[local-config-watch] Sin cambios desde el ultimo escaneo."
    fi
}

if (( LOOP_MODE == 1 )); then
    echo "[local-config-watch] Vigilancia continua activada (cada ${INTERVAL}s). Ctrl+C para salir."
    while true; do
        run_once
        sleep "$INTERVAL"
    done
else
    run_once
fi
