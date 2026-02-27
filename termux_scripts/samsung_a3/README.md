# ClawMobil — Samsung Galaxy A3 2015

Chat de IA corriendo directamente en el Samsung A3, accesible desde el navegador del móvil.
**Sin Ollama, sin proot-distro, sin Telegram** — Python 3.8 stdlib + Groq API remota.

---

## Hardware objetivo

| Campo        | Valor                          |
|--------------|-------------------------------|
| Modelo       | Samsung SM-A300FU (a3ulte)    |
| Serial ADB   | `<DEVICE_SERIAL>`                    |
| Android      | 6.0.1                         |
| Arquitectura | armeabi-v7a (32-bit)          |
| RAM          | 1.4 GB                        |
| IP WiFi      | `192.168.1.25` (puede variar) |

---

## Archivos de esta carpeta

```
samsung_a3/
├── server_a3.py   → Servidor HTTP Python 3.8, sin dependencias externas
├── chat.html      → Interfaz de chat dark-theme
├── start.sh       → Script de arranque en Termux
└── README.md      → Esta guía
```

---

## Requisitos previos (una sola vez)

### 1. Termux instalado en el móvil
- Versión legacy: `com.termux` v0.119.0-beta.3 (APK, no Play Store)
- Repo configurado: `packages-cf.termux.dev/apt/termux-main-21`

### 2. Paquetes instalados en Termux
```bash
pkg update && pkg install -y openssh python wget curl git
```

### 3. Contraseña SSH configurada en Termux
```bash
passwd
# Contraseña: <TU_PASSWORD_SSH>
```

### 4. ADB instalado en el Mac
```bash
# Verificar:
adb devices
# Debe mostrar: <DEVICE_SERIAL>   device
```

### 5. MAC: PATH correcto (restaurar si se rompe)
```bash
export PATH=/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:/Users/apliarte/Library/Android/sdk/platform-tools:/opt/homebrew/bin
```

---

## Clave Groq

| Nombre      | Clave                                                   |
|-------------|--------------------------------------------------------|
| APLIARTE ✅ | `<GROQ_API_KEY_1>` |
| CALCAAPP    | `<GROQ_API_KEY_2>` |
| TUTOGRATIS  | `<GROQ_API_KEY_3>` |

Modelo: `llama-3.1-8b-instant`

---

## Deploy — subir archivos al móvil (desde Mac)

```bash
export PATH=/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:/Users/apliarte/Library/Android/sdk/platform-tools:/opt/homebrew/bin

adb -s <DEVICE_SERIAL> shell mkdir -p /sdcard/clawmobil

adb -s <DEVICE_SERIAL> push server_a3.py /sdcard/clawmobil/server_a3.py
adb -s <DEVICE_SERIAL> push chat.html    /sdcard/clawmobil/chat.html
adb -s <DEVICE_SERIAL> push start.sh     /sdcard/clawmobil/start.sh
```

---

## Arrancar el servidor

### Opción A — Escribir en Termux directamente (más fiable)

Abrir Termux en el móvil y escribir:

```bash
termux-wake-lock
bash /sdcard/clawmobil/start.sh
```

El wake-lock evita que Android 6 mate los procesos en background.

### Opción B — Via ADB + SSH desde el Mac

```bash
# 1. Traer Termux al frente
adb -s <DEVICE_SERIAL> shell am start -n com.termux/.app.TermuxActivity
sleep 2

# 2. Escribir sshd en Termux via keyevents
adb -s <DEVICE_SERIAL> shell input text "sshd"
adb -s <DEVICE_SERIAL> shell input keyevent 66
sleep 6

# 3. Reenviar puerto SSH
adb -s <DEVICE_SERIAL> forward tcp:8022 tcp:8022

# 4. SSH y lanzar servidor
sshpass -p "<TU_PASSWORD_SSH>" ssh -o StrictHostKeyChecking=no -p 8022 localhost \
  "cp /sdcard/clawmobil/server_a3.py ~/clawmobil/ && \
   cp /sdcard/clawmobil/chat.html ~/clawmobil/ && \
   pkill -f server_a3.py 2>/dev/null; sleep 1 && \
   cd ~/clawmobil && \
   nohup python server_a3.py > server.log 2>&1 & sleep 3 && \
   curl -s http://localhost:8080/api/status"
```

---

## Verificar que el servidor funciona (desde el Mac)

```bash
# Status
curl -s http://192.168.1.25:8080/api/status

# Test chat
curl -s -X POST http://192.168.1.25:8080/api/chat \
  -H "Content-Type: application/json" \
  -d '{"text":"hola"}'
```

Respuesta esperada en `/api/status`:
```json
{"status": "ok", "model": "llama-3.1-8b-instant", "messages": 0}
```

---

## Acceder al chat

En el navegador del móvil (o cualquier dispositivo en la misma red WiFi):

```
http://localhost:8080
```
o
```
http://192.168.1.25:8080
```

> ⚠️ En Android 6 algunos navegadores no resuelven `localhost` — usar la IP directa si falla.

---

## Endpoints del servidor

| Método | Ruta           | Descripción                        |
|--------|----------------|------------------------------------|
| GET    | `/`            | Sirve `chat.html`                  |
| POST   | `/api/chat`    | `{"text": "..."}` → respuesta IA   |
| GET    | `/api/status`  | Estado y nº de mensajes            |
| GET    | `/api/history` | Historial completo                 |
| POST   | `/api/clear`   | Limpiar historial                  |

---

## Solución de problemas

### sshd se cae cuando Termux va al background

Android 6 mata procesos en background agresivamente. Soluciones:

1. **Wake-lock**: ejecutar `termux-wake-lock` en Termux antes de lanzar el servidor
2. **Pantalla encendida**: mantener la pantalla activa mientras el servidor corre
3. **Patrón de reconexión SSH** — siempre hacer esto antes de cada intento SSH:
   ```bash
   adb -s <DEVICE_SERIAL> shell am start -n com.termux/.app.TermuxActivity
   sleep 2
   adb -s <DEVICE_SERIAL> shell input text "sshd"
   adb -s <DEVICE_SERIAL> shell input keyevent 66
   sleep 6
   ```

### DNS "Could not resolve host" en Termux

```bash
echo "nameserver 8.8.8.8" > $PREFIX/etc/resolv.conf
echo "nameserver 1.1.1.1" >> $PREFIX/etc/resolv.conf
```

### Groq error 403 / 1010

- La clave está mal o expiró → usar la clave APLIARTE de la tabla de arriba
- Editar `server_a3.py` línea `GROQ_API_KEY = "..."` y re-hacer deploy

### El navegador muestra "página no disponible" en localhost

- El servidor no está corriendo → ejecutar `start.sh` desde Termux
- Probar con la IP directa: `http://192.168.1.25:8080`

### Comprobar si el servidor está corriendo desde el Mac

```bash
curl -s --max-time 5 http://192.168.1.25:8080/api/status; echo "Exit: $?"
# Exit 0 = servidor OK
# Exit 7 = no hay conexión (servidor caído)
# Exit 28 = timeout (IP incorrecta o sin WiFi)
```

### Ver logs del servidor en el móvil

```bash
# Via SSH
sshpass -p "<TU_PASSWORD_SSH>" ssh -o StrictHostKeyChecking=no -p 8022 localhost "tail -20 ~/clawmobil/server.log"
```

---

## Arquitectura

```
Samsung A3 (Android 6)
└── Termux (Python 3.8)
    └── server_a3.py  :8080
        ├── GET /  →  chat.html (UI)
        └── POST /api/chat
                └── HTTPS → api.groq.com → llama-3.1-8b-instant
                                               ↓
                                         respuesta IA
```

---

## Historial de lo que se instaló en Termux

```bash
pkg install openssh python wget curl git cmake make clang proot
```

También hay un rootfs Debian Trixie extraído en `~/debian38/debian-trixie-arm/`
con Python 3.11+ disponible via `~/start-debian.sh`, por si hace falta algo que
requiera Python >= 3.10 en el futuro.
