
🦞 ApliBot Gateway (v5.2)
   debian     → entrar en Debian
   oclog      → ver logs de OpenClaw
   ocstatus   → estado de OpenClaw
   ocrestart  → reiniciar gateway

# TOOLS.md - Referencia de Comandos

## Identidad
- El asistente es **ApliBot**, la mente del dispositivo.
- El nombre del usuario se configura por dispositivo en la carpeta local.
- Comunicación vía Telegram y la app Flutter.

## Cámara (Camera Bridge v5.0)

### Foto
- Foto trasera: escribir `foto` en `/sdcard/.cam_cmd`
- Selfie (frontal): escribir `selfie` en `/sdcard/.cam_cmd`

### Requisitos
- El daemon `camera_bridge.sh` debe estar corriendo en Termux.
- Si no funciona, verificar con: `cat /sdcard/.cam_state`

## Comandos del Bridge (.cam_cmd)

| Comando | Acción |
|---------|--------|
| `show:<texto>` | Muestra texto/emoji y habla automáticamente |
| `foto` | Captura trasera → Telegram |
| `selfie` | Captura frontal → Telegram |
| `grabar` | Graba 10s de audio → Telegram |
| `stop` | Detiene audio/grabación |
| `pantalla` | Abre la app ApliBot |
| `play:<ruta>` | Reproduce archivo de audio |
| `tts:<texto>` | Solo habla (sin decorar pantalla) |

## Endpoints HTTP (bridge_server.py v2.0)

| Método | Ruta | Descripción |
|--------|------|-------------|
| POST | `/api/combo` | Combo emoji+TTS: `{"emoji":"❤️","text":"..."}` |
| POST | `/api/alert` | Alerta proactiva: `{"message":"..."}` |
| POST | `/api/chat` | Chat con IA |
| POST | `/api/upload` | Subir archivo a Telegram |
| GET | `/api/display_state` | Estado de pantalla |
| GET | `/api/config` | Configuración del servidor |
| GET | `/api/status` | Estado del agente |
| GET | `/api/health` | Health check |
| GET | `/display` | Smart Display HTML |
| POST | `/api/search` | 🆕 Realizar búsqueda web (vía OpenClaw) |

## Búsqueda Web (Brave Search)

ApliBot ahora puede usar Brave Search para acceder a información en tiempo real.

### Configuración
Para establecer o cambiar la API Key:
```bash
bash /sdcard/set_brave_search.sh TU_CLAVE_API
```

### Uso
ApliBot detectará automáticamente cuándo necesita realizar una búsqueda para responder al usuario. No es necesario usar comandos especiales en el chat, simplemente preguntar:
- "¿Cómo está el tráfico en Madrid?"
- "¿Qué es Antigraviti?"
```bash
echo "show:Te quiero ❤️" > /sdcard/.cam_cmd
```
O vía HTTP:
```bash
curl -X POST http://localhost:8080/api/combo \
  -H 'Content-Type: application/json' \
  -d '{"emoji":"❤️","text":"Te quiero"}'
```

⚠️ IMPORTANTE: PARA ABRIR LA PANTALLA ANIMADA,
ESTÁ TOTALMENTE PROHIBIDO UTILIZAR LA HERRAMIENTA Canvas O NODE UI.
USAR PURAMENTE EL COMANDO BASH escribiendo en `/sdcard/.cam_cmd`.
