# 📟 Smart Display PRO v5.2 - Guía de Comandos (Simplificada)

Todo el sistema está respaldado en el repositorio, carpeta `termux_scripts/`.

## 🕹️ Poderes del Dispositivo
El dispositivo **interactúa visual y auditivamente** de forma sincronizada.

### Comandos de Pantalla y Audio (Simplificado v5.2)
- **`show:<contenido>`**: El comando maestro. Muestra texto y emojis en pantalla y los habla por el altavoz automáticamente.
  - Ejemplo mixto: `show:Hola 👋`
  - Ejemplo solo emoji: `show:❤️`
  - Ejemplo solo texto: `show:Iniciando protocolo`
- **`pantalla`**: Abre la interfaz visual (la app ApliBot).
- **Reloj (Modo Idle)**: Se activa solo cuando el sistema está en reposo. Sin sombras "feas" para un look más limpio.
- **Fondo Dinámico**: Muestra la última foto tomada por la cámara (difuminada).

### Comandos de Cámara
- **`foto`**: Captura trasera y envío a Telegram.
- **`selfie`**: Captura frontal y envío a Telegram.

---

## 🌐 Endpoints HTTP (server.py v3.0 + bridge_server.py v2.0)

> **NOTA**: Todas estas rutas están ahora integradas en el servidor principal `avatar/server.py`.
> Ya no es necesario ejecutar `bridge_server.py` por separado.

| Método | Endpoint | Descripción |
|--------|----------|-------------|
| POST | `/api/combo` | Envía combo emoji+TTS: `{"emoji":"❤️","text":"Te quiero"}` |
| POST | `/api/alert` | Alerta proactiva: `{"message":"Texto de alerta"}` |
| POST | `/api/chat` | Chat con la IA |
| GET | `/api/display_state` | Estado actual de la pantalla |
| GET | `/api/latest_photo` | Última foto tomada (JPEG) |
| GET | `/api/health` | Health check |
| GET | `/display` | Smart Display HTML (reloj, emojis, estados) |
| GET | `/panel` | Panel de gestión/setup |
| GET | `/` | Avatar web (index.html) |

### Ejemplo de uso con curl:
```bash
# Combo: emoji + TTS
curl -X POST http://localhost:8080/api/combo \
  -H 'Content-Type: application/json' \
  -d '{"emoji":"❤️","text":"Te quiero"}'

# Alerta del sistema
curl -X POST http://localhost:8080/api/alert \
  -H 'Content-Type: application/json' \
  -d '{"message":"Batería baja"}'

# Ver estado de la pantalla
curl http://localhost:8080/api/display_state
```

### Acceso web desde navegador:
- **Smart Display**: `http://<ip-del-dispositivo>:8080/display`
- **Panel de gestión**: `http://<ip-del-dispositivo>:8080/panel`
- **Avatar web**: `http://<ip-del-dispositivo>:8080/`

---

## ⚡ Solución de Errores con el Bot
Si el Bot intenta usar sus herramientas internas de dibujo (Canvas/Node UI), ordénalo así:
> "Abre tu pantalla" o "Pon el modo interactivo"

La pantalla se abre mediante **Bash** enviando la palabra `pantalla` al archivo `.cam_cmd`.

---

## 💾 Backups en local
Copia de seguridad en la raíz del proyecto:
- `avatar/server.py` (v3.0 — servidor principal con Smart Display integrado)
- `termux_scripts/bridge_server.py` (v2.0 — legacy, ya no necesario)
- `termux_scripts/camera_bridge.sh` (v5.0)
- `termux_scripts/SmartDisplay.html`

---

## 📋 Changelog
- **v5.2** (2026-02-22): Simplificación total con el comando `show:`. Eliminación de sombras en títulos y emojis para estética minimalista.
- **v5.1** (2026-02-22): Smart Display, Panel, y endpoints combo/alert integrados en `avatar/server.py`.
- **v5.0** (2026-02-22): Comandos `emoji:` y `combo:`, renombre a ApliBot.
