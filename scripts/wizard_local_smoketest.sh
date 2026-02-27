#!/usr/bin/env bash
# Prueba de humo del wizard local en empezar.html.
# Simula un usuario real, genera JSON/prompt/comando y ejecuta el comando generado.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
HTML_FILE="$PROJECT_ROOT/empezar.html"
DEVICES_DIR="$PROJECT_ROOT/Mis_configuraciones_locales/dispositivos"
ACTIVE_FILE="$DEVICES_DIR/.active_device"
ALIAS="demo_segundo_dispositivo"
PROFILE_DIR="$DEVICES_DIR/$ALIAS"
TMP_DIR="$(mktemp -d)"
JSON_OUT="$TMP_DIR/wizard_profile.json"
CMD_OUT="$TMP_DIR/wizard_command.sh"
PROMPT_OUT="$TMP_DIR/wizard_prompt.txt"

HAD_ACTIVE=0
PREV_ACTIVE=""

cleanup() {
    rm -rf "$PROFILE_DIR"
    if (( HAD_ACTIVE == 1 )); then
        printf '%s\n' "$PREV_ACTIVE" > "$ACTIVE_FILE"
    else
        rm -f "$ACTIVE_FILE"
    fi
    rm -rf "$TMP_DIR"
}
trap cleanup EXIT

mkdir -p "$DEVICES_DIR"
if [[ -f "$ACTIVE_FILE" ]]; then
    HAD_ACTIVE=1
    PREV_ACTIVE="$(cat "$ACTIVE_FILE")"
fi

JSON_OUT="$JSON_OUT" CMD_OUT="$CMD_OUT" PROMPT_OUT="$PROMPT_OUT" HTML_FILE="$HTML_FILE" node <<'NODE'
const fs = require('fs');
const vm = require('vm');

const htmlPath = process.env.HTML_FILE;
const html = fs.readFileSync(htmlPath, 'utf8');
const scripts = [...html.matchAll(/<script>([\s\S]*?)<\/script>/g)].map((m) => m[1]);
if (scripts.length === 0) {
  throw new Error('No se encontro bloque <script> en empezar.html');
}
const scriptContent = scripts[scripts.length - 1];

function element(value = '', checked = false) {
  return {
    value,
    checked,
    style: { display: 'none', background: '', borderColor: '' },
    innerText: '',
    innerHTML: '',
    select() {},
    appendChild() {},
    remove() {},
    click() {}
  };
}

const elements = {
  'lw-device-name': element('Demo Segundo Dispositivo'),
  'lw-device-serial': element('ABC123456'),
  'lw-profile': element('huawei_avanzado'),
  'lw-environment': element('hybrid'),
  'lw-language': element('es'),
  'lw-feature-messaging': element('', true),
  'lw-feature-stt': element('', true),
  'lw-feature-tts': element('', true),
  'lw-feature-camera': element('', true),
  'lw-feature-automation': element('', true),
  'lw-feature-offline': element('', false),
  'lw-perm-microphone': element('', true),
  'lw-perm-camera': element('', true),
  'lw-perm-storage': element('', true),
  'lw-perm-termux': element('', true),
  'lw-limit-child': element('', false),
  'lw-limit-no-root': element('', true),
  'lw-limit-no-cloud-write': element('', true),
  'local-json-output': element(''),
  'local-command-output': element(''),
  'local-prompt-output': element(''),
  'local-result': element(''),
  'local-validation-output': element('')
};

const document = {
  getElementById(id) {
    if (!elements[id]) {
      elements[id] = element('');
    }
    return elements[id];
  },
  createElement() {
    return element('');
  },
  body: {
    appendChild() {}
  },
  execCommand() { return true; }
};

const context = {
  document,
  navigator: { clipboard: { writeText: () => Promise.resolve() } },
  Blob: function Blob() {},
  URL: {
    createObjectURL: () => 'blob:test',
    revokeObjectURL: () => {}
  },
  setTimeout: (fn) => {
    fn();
    return 0;
  },
  clearTimeout: () => {},
  Date,
  console
};

vm.createContext(context);
vm.runInContext(scriptContent, context);
if (typeof context.generateLocalProfile !== 'function') {
  throw new Error('generateLocalProfile() no disponible');
}

context.generateLocalProfile();

const jsonOut = elements['local-json-output'].value;
const cmdOut = elements['local-command-output'].value;
const promptOut = elements['local-prompt-output'].value;

if (!jsonOut || !cmdOut || !promptOut) {
  throw new Error('El wizard no genero las tres salidas requeridas');
}

const parsed = JSON.parse(jsonOut);
if (!parsed.deviceAlias || !parsed.features || !parsed.permissions) {
  throw new Error('config_profile.json generado sin claves requeridas');
}
if (!cmdOut.includes('local_config_select.sh --json')) {
  throw new Error('Comando generado no incluye validacion local_config_select.sh');
}
if (!promptOut.includes('Mis_configuraciones_locales/dispositivos/')) {
  throw new Error('Prompt generado no incluye ruta de configuracion local');
}

fs.writeFileSync(process.env.JSON_OUT, jsonOut + '\n');
fs.writeFileSync(process.env.CMD_OUT, cmdOut + '\n');
fs.writeFileSync(process.env.PROMPT_OUT, promptOut + '\n');
NODE

bash "$CMD_OUT" >/tmp/wizard_local_command_exec.out

if [[ ! -f "$PROFILE_DIR/config_profile.json" ]]; then
    echo "[wizard-smoke] ERROR: no se creo $PROFILE_DIR/config_profile.json" >&2
    exit 1
fi

grep -q '"deviceAlias"' "$PROFILE_DIR/config_profile.json" || {
    echo "[wizard-smoke] ERROR: config_profile.json incompleto" >&2
    exit 1
}

grep -q 'Contexto:' "$PROMPT_OUT" || {
    echo "[wizard-smoke] ERROR: prompt modular no valido" >&2
    exit 1
}

echo "[wizard-smoke] OK: empezar.html genera JSON + prompt + comando funcional"
