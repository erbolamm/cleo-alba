# 📚 Lecciones Aprendidas — ClawMobil

> Conocimiento acumulado de todas las instalaciones en dispositivos reales.
> Estas lecciones se aplican a **cualquier teléfono** que se convierta con ClawMobil.

---

## 🏗️ Arquitectura: PRoot vs Termux nativo

### El problema
Termux ofrece dos entornos:
- **Termux nativo**: shell Android directo, acceso a hardware (`termux-*`), mejor rendimiento
- **PRoot Debian**: distribución Linux emulada dentro de Termux, más herramientas, pero sin acceso al hardware real del teléfono

### Lo aprendido

| Característica | Termux nativo | PRoot Debian |
|---|---|---|
| `termux-camera-photo`, `termux-tts-speak`, etc. | ✅ Funciona | ❌ No funciona |
| `am start` (Activity Manager) | ✅ Funciona | ❌ No funciona |
| Escribir en `/storage/` (SD card) | ✅ Funciona | ❌ No tiene acceso |
| `systemd` / `D-Bus` | ❌ No existe | ❌ No existe tampoco |
| `screen` para persistencia | ✅ | ✅ |
| OpenClaw (Node.js) | ✅ Recomendado | ⚠️ Se cuelga en algunos dispositivos |
| Compilar código nativo (CMake/make) | ⚠️ Limitado | ❌ Peor aún |
| Git, SSH, Python, etc. | ✅ | ✅ |

### Regla de oro
> **Ejecutar OpenClaw en Termux nativo.** Usar PRoot Debian solo para herramientas que no estén en Termux (compilar Whisper, etc.), nunca para servicios persistentes.

### Persistencia sin systemd
En ambos entornos NO hay `systemd`. Para mantener procesos vivos:
```bash
# Usar screen (NO nohup, que pierde la terminal)
screen -dmS openclaw_gw openclaw gateway run --port 18789 --bind 127.0.0.1

# Verificar que está vivo
screen -ls | grep openclaw_gw

# Reconectar a la sesión
screen -r openclaw_gw
```

---

## 🦞 OpenClaw: Instalación y Configuración

### Instalación correcta (Termux nativo)
```bash
# 1. Instalar dependencias
pkg install nodejs cmake clang make binutils

# 2. Instalar OpenClaw SALTANDO compilación nativa (koffi no compila en Android)
npm install -g openclaw --ignore-scripts

# 3. Si hay restos de instalaciones previas:
rm -rf /usr/lib/node_modules/openclaw /usr/lib/node_modules/.openclaw*
npm install -g openclaw --ignore-scripts
```

> **Error conocido**: El módulo `koffi` necesita CMake nativo y falla en `aarch64-unknown-linux-android`. La flag `--ignore-scripts` es **obligatoria** en Termux.

### Configuración — `openclaw.json`
Ubicación: `~/.openclaw/openclaw.json`
```json
{
  "gateway": {
    "auth": {
      "token": "TU_TOKEN_SEGURO"
    },
    "port": 18789,
    "channels": ["telegram"]
  },
  "channels": {
    "telegram": {
      "botToken": "${TELEGRAM_BOT_TOKEN}",
      "dmPolicy": "allowlist",
      "allowFrom": ["TU_CHAT_ID"]
    }
  }
}
```

> **Error conocido `dmPolicy`**: Los valores válidos son `"pairing"`, `"allowlist"`, `"open"`, `"disabled"`. Usar `"allowFrom"` como valor provoca errores silenciosos.

### Configuración — `auth-profiles.json`
Ubicación: `~/.openclaw/agents/main/agent/auth-profiles.json`
```json
{
  "default": {
    "groq": {
      "apiKey": "TU_GROQ_API_KEY"
    }
  }
}
```

> **Error conocido**: El formato con `{ "profiles": { ... }, "activeProfile": "default" }` no funciona. Usar el formato plano de arriba.

### Arranque limpio
```bash
# SIEMPRE limpiar procesos previos (evitar zombies que consumen toda la RAM)
pkill -f openclaw 2>/dev/null
sleep 2
screen -wipe 2>/dev/null

# Arrancar con screen
screen -dmS openclaw_gw openclaw gateway run --port 18789 --bind 127.0.0.1

# Verificar
screen -ls | grep openclaw_gw
```

> **Error conocido**: Sin el `pkill` previo, múltiples instancias de OpenClaw consumen toda la RAM (2 procesos = 1.5 GB). El teléfono se congela.

---

## 🎤 Audio: Whisper + TTS

### Whisper (Speech-to-Text offline)
```bash
# Compilar en PRoot Debian (mejor soporte de build)
apt install build-essential cmake git
git clone https://github.com/ggerganov/whisper.cpp
cd whisper.cpp && make -j4

# Descargar modelo
bash models/download-ggml-model.sh base
```

**Conversión de audio obligatoria**: Telegram envía audios en OGG/OPUS. Whisper solo acepta WAV.
```bash
# Instalar ffmpeg
apt install ffmpeg  # o pkg install ffmpeg en Termux

# Convertir antes de transcribir
ffmpeg -i audio.ogg -ar 16000 -ac 1 audio.wav
./main -m models/ggml-base.bin -f audio.wav -l es
```

> **Modelos recomendados por RAM**:
> - 2-3 GB RAM: `ggml-tiny.bin` (~75 MB, rápido pero menos preciso)
> - 4 GB RAM: `ggml-base.bin` (~142 MB, buen balance)
> - 6+ GB RAM: `ggml-small.bin` (~466 MB, mejor precisión)

### TTS (Text-to-Speech offline)
```bash
# espeak-ng funciona tanto en Termux como en PRoot
pkg install espeak-ng  # en Termux
# o
apt install espeak-ng  # en PRoot

# Para que suene por el ALTAVOZ PRINCIPAL del teléfono:
# 1. Generar WAV con espeak-ng
espeak-ng -v es -w /tmp/habla.wav "Hola, soy ApliBot"

# 2. Reproducir con termux-media-player (SOLO desde Termux nativo)
termux-media-player play /tmp/habla.wav
```

> **Truco importante**: `espeak-ng` genera el audio, pero reproducirlo por el altavoz del teléfono requiere `termux-media-player`, que solo está disponible desde Termux nativo (no PRoot).

---

## 🔍 Brave Search

**Error común**: Brave Search no funciona aunque la API key sea correcta.

**Causa**: La herramienta `tools.web.search` está **desactivada por defecto** en OpenClaw.

**Solución**:
```bash
openclaw config set tools.web.search.enabled true
# Alternativamente, añadir al openclaw.json:
# "tools": { "web": { "search": { "enabled": true } } }
```

> **Verificar**: `openclaw config get tools.web.search.enabled` debe devolver `true`.

---

## 🤖 Comportamiento del Bot: Reglas entrenadas

Las siguientes reglas se descubrieron necesarias durante el uso real del bot. Incluir en el system prompt de cada dispositivo:

### 1. Regla ANTI-ECO
> No repitas el mensaje del usuario de ninguna forma (viñetas, resumen, eco textual). Ve directo a ejecutar la tarea.

### 2. Regla AUTONOMÍA
> Si tienes las herramientas para hacer una tarea, hazla directamente. No preguntes "¿quieres que lo haga?".

### 3. Regla AUDIO
> Nunca mandes archivos de audio a Telegram. Transcríbelos con `whisper.cpp` y manda el texto.

### 4. Regla ESCALADO
> La cadena es: intentar → si falla → buscar en internet → si falla → preguntar al usuario. Nunca preguntar sin haber intentado primero.

### 5. Regla CONTEXTO PRoot/Termux
> Distinguir siempre entre los dos entornos. Los comandos `termux-*` y `am start` SOLO funcionan en Termux nativo.

### 6. Regla SD CARD
> Para operaciones en `/storage/` (SD card), usar Termux nativo. PRoot no tiene acceso al almacenamiento externo.

### 7. Regla PROCESOS
> Antes de arrancar cualquier servicio, siempre matar procesos anteriores con `pkill -f`. Verificar después con `ps aux | grep`.

### 8. Regla GATEWAY
> Usar `screen` para el gateway, nunca `nohup` solo. Con `screen` se puede reconectar y ver los logs en vivo.

---

## 🗑️ Debloat (eliminar apps innecesarias)

El debloat libera RAM (crítico para IA en dispositivos de gama baja). Resultados reales:

| Dispositivo | Apps eliminadas | RAM liberada |
|---|---|---|
| YesTeL Note 30 Pro | 92 apps | ~225 MB |

**Procedimiento genérico**:
```bash
# 1. Listar todas las apps del sistema
adb shell pm list packages -s

# 2. Deshabilitar (no desinstalar, para poder revertir)
adb shell pm disable-user --user 0 com.ejemplo.app

# 3. O desinstalar para el usuario actual (reversible con factory reset)
adb shell pm uninstall -k --user 0 com.ejemplo.app
```

> **Precaución**: Nunca desinstalar apps de sistema críticas (launcher, settings, telephony). Crear siempre un script con `adb shell cmd package install-existing` para revertir.

Los scripts de debloat por dispositivo están en `scripts/debloat_*.sh`.

---

## 🔑 Git y Seguridad de Tokens

### Tokens Fine-Grained (recomendado)
El token clásico `ghp_*` da acceso a TODOS los repos de la cuenta. Para un bot autónomo esto es peligroso.

**Usar tokens fine-grained** que limitan el acceso:
- Solo repositorios específicos (ej: `aplibot-memoria`, `aplibot-web`)
- Solo permisos necesarios (ej: `Contents: Read & Write`)
- Caducidad configurada (30, 60, 90 días)

### Archivos con secretos
Nunca commitear:
- `claves.env` (API keys)
- `auth-profiles.json` (claves de IA)
- `models.json` (puede contener API keys cacheadas por OpenClaw)
- Archivos `.session` de Telegram

> Verificar siempre con `git diff --staged | grep -i "sk-\|key\|token\|secret"` antes de hacer push.

---

## 📱 Scripts Puente (Bridge Scripts)

Para ejecutar comandos del teléfono desde PRoot Debian, es necesario pasar por Termux nativo usando "scripts puente":

```
PRoot Debian → escribe comando en archivo compartido → Termux nativo lee y ejecuta → devuelve resultado
```

Los 9 bridges disponibles están en `scripts/bridge_scripts/`:

| Bridge | Función | Requiere |
|---|---|---|
| `foto` | Tomar foto con cámara del teléfono | Termux:API |
| `grabar` | Grabar audio con micrófono | Termux:API |
| `hablar` | TTS por el altavoz principal | espeak-ng + termux-media-player |
| `vibrar` | Vibrar el teléfono | Termux:API |
| `linterna` | Encender/apagar linterna | Termux:API |
| `notificar` | Mostrar notificación en Android | Termux:API |
| `captura` | Captura de pantalla | ADB / MediaProjection |
| `abrir_web` | Abrir URL en el navegador | `am start` |
| `bateria` | Consultar nivel de batería | Termux:API |

---

## 📋 Checklist de instalación validado

Esta es la secuencia real probada que funciona:

1. ✅ Factory reset del teléfono
2. ✅ Instalar Termux + Termux:Boot + Termux:API (desde F-Droid)
3. ✅ `pkg update && pkg upgrade`
4. ✅ `pkg install openssh nodejs python git cmake clang make binutils screen`
5. ✅ Configurar SSH: `ssh-keygen` + copiar clave pública del Mac
6. ✅ Ejecutar script de debloat (específico por modelo)
7. ✅ `npm install -g openclaw --ignore-scripts`
8. ✅ Crear `~/.openclaw/openclaw.json` con la configuración
9. ✅ Crear `~/.openclaw/agents/main/agent/auth-profiles.json`
10. ✅ Instalar y configurar bridges en `/sdcard/`
11. ✅ Instalar `proot-distro` + Debian (opcional, para Whisper)
12. ✅ Compilar Whisper en PRoot Debian (si hay RAM suficiente)
13. ✅ Instalar espeak-ng para TTS
14. ✅ Configurar `boot_autostart.sh` para arranque automático
15. ✅ Test: enviar mensaje por Telegram y verificar respuesta
16. ✅ Test de estabilidad 24h

---

*Última actualización: 2026-03-03*
*Dispositivos que contribuyeron: Huawei P10, YesTeL Note 30 Pro*
