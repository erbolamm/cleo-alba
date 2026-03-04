# LEEME — SAMSUNG GALAXY A3 2015 — LEE ESTO ANTES DE EMPEZAR

## Misión de este dispositivo

Samsung SM-A300FU reconvertido en **asistente de IA para niños**.
La usuaria es **Alba (7 años)**, hija del dueño del repo. La app se llama **Cleo**.
El teléfono debe funcionar de forma autónoma: sin el Mac conectado, sin ADB, sin SSH.

---

## Hardware — ficha completa

| Campo             | Valor                          |
|-------------------|-------------------------------|
| Modelo            | Samsung SM-A300FU (a3ulte)    |
| Serial ADB        | `<DEVICE_SERIAL>`                    |
| Android           | 6.0.1 (API 23)                |
| Arquitectura      | armeabi-v7a (32-bit ARM)      |
| RAM               | 1.4 GB                        |
| Almacenamiento    | 16 GB interno + microSD       |
| CPU               | Quad-core 1.2 GHz Cortex-A53 |
| Pantalla          | 4.5" 540×960px                |

---

## Red y acceso remoto

| Dato              | Valor                          |
|-------------------|-------------------------------|
| IP WiFi           | `192.168.1.25` (puede cambiar) |
| Router/gateway    | `192.168.1.1`                 |
| Puerto SSH        | `8022` (Termux)               |
| Contraseña SSH    | `<TU_PASSWORD_SSH>`                    |
| Puerto servidor   | `8080`                        |

### Conectar por SSH desde el Mac

```bash
# 1. Restaurar PATH si falla adb o flutter:
export PATH=/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin
export PATH=$PATH:/Users/apliarte/Library/Android/sdk/platform-tools
export PATH=$PATH:/Users/apliarte/development/flutter/bin
export PATH=$PATH:/opt/homebrew/bin

# 2. Reenviar puerto SSH
adb -s <DEVICE_SERIAL> forward tcp:8022 tcp:8022

# 3. Conectar
sshpass -p "<TU_PASSWORD_SSH>" ssh -o StrictHostKeyChecking=no -p 8022 localhost

# IMPORTANTE: sshd muere cuando Termux va al background en Android 6
# Secuencia para relanzar sshd via ADB:
adb -s <DEVICE_SERIAL> shell am start -n com.termux/.app.TermuxActivity
sleep 2
adb -s <DEVICE_SERIAL> shell input text "sshd"
adb -s <DEVICE_SERIAL> shell input keyevent 66
sleep 6
```

---

## Termux — configuración instalada

| Paquete     | Versión          | Notas                            |
|-------------|------------------|----------------------------------|
| Termux APK  | v0.119.0-beta.3  | Legacy, NO del Play Store        |
| Python      | 3.8.0-1          | Único disponible en repo legacy  |
| openssh     | instalado        | sshd en puerto 8022              |
| wget/curl   | instalado        | Herramientas de red              |
| git         | instalado        |                                  |
| cmake/clang | instalado        |                                  |
| proot       | instalado        |                                  |

### Repositorio de Termux (repo legacy, NO el oficial)

```
deb https://packages-cf.termux.dev/apt/termux-main-21 stable main
```

> El repo `termux.dev` oficial no funciona. Siempre usar `packages-cf.termux.dev`.

### Fix DNS Termux (si no resuelve hostnames)

```bash
echo "nameserver 8.8.8.8" > $PREFIX/etc/resolv.conf
echo "nameserver 1.1.1.1" >> $PREFIX/etc/resolv.conf
```

### Extra: Debian Trixie rootfs

Para proyectos que requieran Python ≥3.10 (ej. openclaw):
- Rootfs extraído en: `~/debian38/debian-trixie-arm/`
- Script de acceso: `~/start-debian.sh`
- Python 3.11+ disponible dentro del chroot

---

## Archivos desplegados en el dispositivo

### En `/sdcard/clawmobil/` (accesible sin SSH, via ADB push)
```
server_a3.py   ← servidor HTTP Python (versión maestra para deploy)
chat.html      ← interfaz web del chat
start.sh       ← script de arranque completo
```

### En `~/clawmobil/` (directorio de trabajo de Termux)
```
server_a3.py   ← copia activa (copiada por start.sh desde /sdcard)
chat.html      ← copia activa
start.sh       ← copia activa
server.log     ← log del servidor (tail -f para debug)
server.pid     ← PID del proceso del servidor
```

---

## Servidor Python (`server_a3.py`)

**Tecnología**: Python 3.8 stdlib pura — sin pip, sin dependencias externas.

| Endpoint       | Método | Descripción                                 |
|----------------|--------|---------------------------------------------|
| `/`            | GET    | Sirve `chat.html`                           |
| `/api/chat`    | POST   | `{"text":"..."}` → respuesta IA via Groq    |
| `/api/status`  | GET    | `{"status":"ok","model":"...","messages":N}`|
| `/api/history` | GET    | Historial completo en memoria               |
| `/api/clear`   | POST   | Limpia el historial                         |
| `/api/shutdown`| POST   | Apaga el servidor (para botón admin en app) |

### Clave Groq activa

```
<TU_CLAVE_GROQ_AQUI>  <!-- Configura en Mis_configuraciones_locales/dispositivos/tu_dispositivo/claves.env -->
```

Modelo: `llama-3.1-8b-instant`

---

## App Flutter (pantalla `/alba`)

### Archivos en el repo Flutter
```
lib/screens/alba_chat_screen.dart   ← chat principal (habla con Cleo)
lib/screens/alba_admin_screen.dart  ← panel padres (engranaje 8 segundos)
```

### Cómo compilar e instalar

```bash
export PATH=/Users/apliarte/development/flutter/bin:$PATH
export PATH=$PATH:/Users/apliarte/Library/Android/sdk/platform-tools

cd /Users/apliarte/trabajo/ClawMobil

flutter pub get

# APK solo para ARM 32-bit (el A3 es armeabi-v7a):
flutter build apk --target-platform android-arm --split-per-abi

# Instalar:
adb -s <DEVICE_SERIAL> install -r build/app/outputs/flutter-apk/app-armeabi-v7a-release.apk

# Lanzar pantalla de Alba directamente:
adb -s <DEVICE_SERIAL> shell am start -n com.apliarte.bot/.MainActivity
```

### Configuración crítica de Android

```kotlin
// android/app/build.gradle.kts
minSdk = 21   // NUNCA usar flutter.minSdkVersion (sería 24 y el A3 es API 23)
```

### Dependencias críticas y sus restricciones

| Paquete              | Versión fijada | Razón                                           |
|----------------------|----------------|-------------------------------------------------|
| `record`             | `5.0.5` exacta | v6+ requiere API 24; v4.x incompatible con AGP; v5.0.5 OK     |
| `android_intent_plus`| `^5.0.0`       | Para lanzar comandos en Termux                  |
| `permission_handler` | `^11.3.0`      | Permiso de micrófono                            |

---

## App de Alba — descripción funcional

**Usuaria**: Alba, 7 años, 1º-5º primaria
**Bot**: Cleo 🌟 — amiga de aprender, cariñosa, con personalidad
**Hermano**: Fran, 3 años (Cleo pregunta por él de vez en cuando)
**Teléfono papá**: `<CONFIGURAR_EN_CLAVES.ENV>` | **Teléfono mamá**: `<CONFIGURAR_EN_CLAVES.ENV>`

### Funciones
- Chat texto estilo WhatsApp (burbujas usuario/Cleo)
- Grabación voz hasta 10s con cuenta atrás grande visible → transcripción Groq Whisper
- Botón atrás **desactivado** (pantalla completa immersiveSticky)
- Engranaje arriba derecha: mantener **8 segundos** → panel de administración (padres)
- Panel admin: iniciar/apagar servidor Termux, limpiar historial, cerrar app

### System prompt de Cleo (resumen)
- Enseña a pensar por pasos antes de responder (hoja de ruta)
- Inculca pensamiento de programadora (instrucciones paso a paso)
- Materias: mates, lengua, ciencias, inglés, manualidades, dibujo
- Respuestas cortas (máx 4 frases), emojis, siempre termina con reto/pregunta
- Redirige temas no educativos con cariño

---

## Flujo de arranque diario (sin Mac)

1. Encender el A3
2. Abrir Termux
3. Escribir: `termux-wake-lock` → Enter
4. Escribir: `bash /sdcard/clawmobil/start.sh` → Enter
5. Abrir la app "ApliBot" → pantalla de Cleo
6. (Opcional) Acceso al chat web desde cualquier dispositivo de la red: `http://192.168.1.25:8080`

---

## Flujo de deploy desde el Mac (actualizar archivos)

```bash
export PATH=/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin
export PATH=$PATH:/Users/apliarte/Library/Android/sdk/platform-tools
export PATH=$PATH:/Users/apliarte/development/flutter/bin

cd /Users/apliarte/trabajo/ClawMobil/termux_scripts/samsung_a3

# Subir archivos del servidor:
adb -s <DEVICE_SERIAL> push server_a3.py /sdcard/clawmobil/server_a3.py
adb -s <DEVICE_SERIAL> push chat.html    /sdcard/clawmobil/chat.html
adb -s <DEVICE_SERIAL> push start.sh     /sdcard/clawmobil/start.sh

# Reiniciar servidor vía SSH (si funciona):
adb -s <DEVICE_SERIAL> forward tcp:8022 tcp:8022
sshpass -p "<TU_PASSWORD_SSH>" ssh -o StrictHostKeyChecking=no -p 8022 localhost \
  "cp /sdcard/clawmobil/server_a3.py ~/clawmobil/ && pkill -f server_a3.py; sleep 1 && cd ~/clawmobil && nohup python server_a3.py > server.log 2>&1 &"

# Verificar:
curl -s --max-time 5 http://192.168.1.25:8080/api/status
# Exit 0 + JSON = OK | Exit 7 = servidor caído | Exit 28 = sin WiFi
```

---

## Problemas conocidos y soluciones

### sshd muere cuando Termux va al background
Android 6 mata agresivamente los procesos en background.
```bash
# Solución: siempre ejecutar termux-wake-lock antes de lanzar el servidor
# Y relanzar sshd vía ADB cuando muere:
adb -s <DEVICE_SERIAL> shell am start -n com.termux/.app.TermuxActivity && sleep 2
adb -s <DEVICE_SERIAL> shell input text "sshd" && adb -s <DEVICE_SERIAL> shell input keyevent 66
sleep 6
```

### PATH del Mac se rompe con heredocs
Los heredocs en zsh corrompen el PATH.
```bash
# Fix siempre necesario:
export PATH=/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin
export PATH=$PATH:/Users/apliarte/Library/Android/sdk/platform-tools
export PATH=$PATH:/Users/apliarte/development/flutter/bin
export PATH=$PATH:/opt/homebrew/bin
```

### `flutter.minSdkVersion` da INSTALL_FAILED_OLDER_SDK
El valor por defecto es 24; el A3 es API 23. Usar siempre `minSdk = 21` fijo.

### `record: ^6.x` da error de compilación
Requiere API 24. Usar exactamente `record: 5.0.5`.

### `record: 4.4.4` da namespace error en AGP
Demasiado antiguo para el AGP moderno. Usar `record: 5.0.5`.

### Groq error 403 / 1010 (Cloudflare)
La clave está inválida o la IP del dispositivo es bloqueada.
Probar con clave alternativa (ver tabla en LEEME.md raíz).

### `localhost` no funciona en el navegador del A3
Usar la IP directa: `http://192.168.1.25:8080`

---

## Estado actual del proyecto (fecha: febrero 2026)

- ✅ Termux instalado y configurado
- ✅ Python 3.8 + openssh + curl + wget instalados
- ✅ Debian Trixie rootfs disponible en `~/debian38/`
- ✅ `server_a3.py` + `chat.html` + `start.sh` en `/sdcard/clawmobil/`
- ✅ Servidor Python verificado funcionando en puerto 8080
- ✅ Chat web accesible en `http://localhost:8080` desde el navegador del A3
- ✅ `alba_chat_screen.dart` + `alba_admin_screen.dart` creados
- ⚠️ APK Flutter — compilando (error `record:` en resolución, fix aplicado → `record: 5.0.5`)
- ❌ APK Flutter — pendiente de verificar instalación exitosa en el A3
