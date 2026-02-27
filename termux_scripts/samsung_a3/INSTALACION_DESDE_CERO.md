# 📱 Guía de instalación desde cero — Samsung Galaxy A3 para Alba

**Objetivo**: Dejar el Samsung A3 2015 como tablet de aprendizaje para Alba (7 años),
con una app de chat de IA personalizada que no se puede cerrar accidentalmente.

---

## 📋 Requisitos previos en el Mac

```bash
# Verificar que tienes ADB
adb version

# Restaurar PATH si algo falla
export PATH=/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:/Users/apliarte/Library/Android/sdk/platform-tools:/opt/homebrew/bin
```

---

## FASE 1 — Preparar el Samsung A3

### 1.1 Activar opciones de desarrollador

1. Ajustes → Acerca del dispositivo → Información del software
2. Pulsar **7 veces** en "Número de compilación" hasta ver "Eres desarrollador"
3. Volver → Ajustes → Opciones de desarrollador → Activar
4. Activar **Depuración USB** (USB debugging)
5. Conectar el Samsung al Mac con cable USB
6. En el teléfono: confirmar "Permitir depuración USB" → Siempre permitir

```bash
# Verificar conexión
adb devices
# Debe salir: <DEVICE_SERIAL>   device
```

### 1.2 Conectar WiFi

Asegurarse de que el Samsung está conectado a la red WiFi del hogar.
IP asignada: `192.168.1.25` (puede variar — ver en Ajustes → WiFi → Red actual)

---

## FASE 2 — Instalar Termux

### 2.1 Descargar e instalar el APK

```bash
# Opción A: via ADB (si tienes el APK descargado)
adb -s <DEVICE_SERIAL> install termux-app_v0.119.0-beta.3+apt-android-7-github-debug_armeabi-v7a.apk

# Opción B: manual — descargar de GitHub
# https://github.com/termux/termux-app/releases/tag/v0.119.0-beta.3
# → termux-app_v0.119.0-beta.3+apt-android-7-github-debug_armeabi-v7a.apk
#   (importante: versión android-7 / armeabi-v7a para el A3)
```

### 2.2 Primera configuración de Termux

Abrir Termux en el teléfono y ejecutar:

```bash
# Configurar repositorio correcto (el repo por defecto está muerto)
mkdir -p ~/.termux/apt/soures.list.d/
cat > $PREFIX/etc/apt/sources.list << 'EOF'
deb https://packages-cf.termux.dev/apt/termux-main-21 stable main
EOF

# Fix DNS
echo "nameserver 8.8.8.8" > $PREFIX/etc/resolv.conf
echo "nameserver 1.1.1.1" >> $PREFIX/etc/resolv.conf

# Actualizar paquetes
pkg update -y && pkg upgrade -y

# Instalar paquetes esenciales
pkg install -y openssh python wget curl git
```

### 2.3 Configurar SSH

```bash
# Dentro de Termux en el teléfono:
passwd
# Introducir contraseña: <TU_PASSWORD_SSH> (dos veces)

# Iniciar el servidor SSH
sshd
```

### 2.4 Verificar SSH desde el Mac

```bash
# En el Mac:
adb -s <DEVICE_SERIAL> forward tcp:8022 tcp:8022
sshpass -p "<TU_PASSWORD_SSH>" ssh -o StrictHostKeyChecking=no -p 8022 localhost "echo OK"
# Debe salir: OK
```

---

## FASE 3 — Instalar el servidor ClawMobil (chat en el navegador)

### 3.1 Preparar la carpeta en el dispositivo

```bash
# Crear carpeta en la tarjeta
adb -s <DEVICE_SERIAL> shell mkdir -p /sdcard/clawmobil
```

### 3.2 Subir los archivos

Desde el Mac, en la carpeta `termux_scripts/samsung_a3/`:

```bash
cd /Users/apliarte/trabajo/ClawMobil/termux_scripts/samsung_a3

adb -s <DEVICE_SERIAL> push server_a3.py /sdcard/clawmobil/server_a3.py
adb -s <DEVICE_SERIAL> push chat.html    /sdcard/clawmobil/chat.html
adb -s <DEVICE_SERIAL> push start.sh     /sdcard/clawmobil/start.sh
```

### 3.3 Dar permisos de ejecución al script

```bash
sshpass -p "<TU_PASSWORD_SSH>" ssh -o StrictHostKeyChecking=no -p 8022 localhost \
  "chmod +x /sdcard/clawmobil/start.sh"
```

### 3.4 Habilitar "Allow External Apps" en Termux

En el teléfono: Abrir Termux → menú hamburguesa → **Ajustes → Allow External Apps → Activar**

Esto permite que la app de Alba lance el servidor desde el botón del panel de administración.

### 3.5 Arrancar el servidor (primera vez)

Abrir Termux en el teléfono y escribir:

```bash
termux-wake-lock
bash /sdcard/clawmobil/start.sh
```

### 3.6 Verificar servidor

```bash
# Desde el Mac:
curl -s http://192.168.1.25:8080/api/status
# Respuesta esperada: {"status": "ok", "model": "llama-3.1-8b-instant", "messages": 0}

# Test de chat:
curl -s -X POST http://192.168.1.25:8080/api/chat \
  -H "Content-Type: application/json" \
  -d '{"text":"hola"}'
```

**Acceso web** (desde el navegador del A3 o de cualquier dispositivo en la red):
```
http://192.168.1.25:8080
```

---

## FASE 4 — Instalar la app de Alba (Flutter)

### 4.1 Prerrequisitos en el Mac

```bash
# Verificar Flutter
flutter --version
# Se necesita Flutter 3.x o superior

# Instalar dependencias
cd /Users/apliarte/trabajo/ClawMobil
flutter pub get
```

### 4.2 Compilar el APK para armeabi-v7a (Android 6)

```bash
cd /Users/apliarte/trabajo/ClawMobil

# Compilar APK específico para armeabi-v7a (el A3 es 32-bit)
flutter build apk --target-platform android-arm --split-per-abi

# El APK estará en:
# build/app/outputs/flutter-apk/app-armeabi-v7a-release.apk
```

### 4.3 Instalar el APK en el Samsung

```bash
adb -s <DEVICE_SERIAL> install build/app/outputs/flutter-apk/app-armeabi-v7a-release.apk

# Si ya estaba instalada (actualizar):
adb -s <DEVICE_SERIAL> install -r build/app/outputs/flutter-apk/app-armeabi-v7a-release.apk
```

### 4.4 Lanzar la app de Alba directamente

```bash
# Lanzar la pantalla de Alba (ruta /alba):
adb -s <DEVICE_SERIAL> shell am start \
  -n com.example.aplibot_system/.MainActivity \
  --es "route" "/alba"
```

O desde la app: ir a la pantalla de Alba manualmente.

---

## FASE 5 — Configurar el teléfono para Alba

### 5.1 App de Alba como launcher (pantalla de inicio)

Para que al encender el teléfono abra directamente el chat:

1. Instalar un launcher simple (ej. **Square Home** o **Kiosk Launcher** desde APK)
2. O usar el modo de "anclaje de pantalla" de Android:
   - Ajustes → Seguridad → Anclaje de pantalla → Activar
   - Abrir la app de Alba → botón de recientes → icono del candado

### 5.2 Permisos necesarios para la app

Al abrir la app por primera vez, aceptar:
- **Micrófono** → imprescindible para el audio

### 5.3 Quitar aplicaciones no necesarias

```bash
# Deshabilitar navegador predeterminado (para que no pueda salir al navegador)
adb -s <DEVICE_SERIAL> shell pm disable-user com.android.browser

# Deshabilitar Play Store si no se quiere que descargue apps
adb -s <DEVICE_SERIAL> shell pm disable-user com.android.vending
```

---

## FASE 6 — Uso diario

### Para papá/mamá — Cómo gestionar el servidor

**Iniciar Cleo (servidor):**
1. Abrir Termux
2. Escribir: `termux-wake-lock && bash /sdcard/clawmobil/start.sh`

**O desde el panel de admin de la app:**
- Mantener pulsado el ⚙️ engranaje (arriba derecha) durante **8 segundos**
- Panel de administración → "Despertar servidor"

**Apagar Cleo:**
- Desde el panel admin → "Apagar Cleo y cerrar app" (apaga servidor + cierra app)

### Para Alba — Cómo usar el chat

1. El chat abre directamente con Cleo saludando
2. Escribir en el campo de texto o pulsar el 🎤 micrófono
3. Con el micrófono: cuenta atrás de 10 segundos — hablar claramente
4. Cleo responde siempre en español con emojis

### El botón de atrás no funciona (diseño intencionado)
Solo los padres pueden salir de la app via el panel de admin (engranaje 8s).

---

## 🔑 Datos importantes

| Dato                 | Valor                                              |
|----------------------|----------------------------------------------------|
| Serial ADB           | `<DEVICE_SERIAL>`                                         |
| IP WiFi Samsung      | `192.168.1.25`                                     |
| Puerto del servidor  | `8080`                                             |
| Contraseña SSH       | `<TU_PASSWORD_SSH>`                                         |
| Clave Groq (APLIARTE)| `<GROQ_API_KEY_1>` — configura en claves.env |
| Clave Groq backup    | `<GROQ_API_KEY_2>` — configura en claves.env |
| Modelo de IA         | `llama-3.1-8b-instant`                             |
| Modelo de voz (STT)  | `whisper-large-v3-turbo`                           |

---

## 🔧 Solución de problemas

### "No tengo internet / Cleo no responde"
```bash
# Verificar servidor
curl -s --max-time 5 http://192.168.1.25:8080/api/status; echo "Exit: $?"
# Exit 0 = OK | Exit 7 = servidor caído | Exit 28 = sin WiFi
```

### sshd se cae (Android 6 mata procesos en background)
```bash
# Desde el Mac — reiniciar sshd:
adb -s <DEVICE_SERIAL> shell am start -n com.termux/.app.TermuxActivity
sleep 2
adb -s <DEVICE_SERIAL> shell input text "sshd"
adb -s <DEVICE_SERIAL> shell input keyevent 66
sleep 6
```

### DNS Termux no resuelve
```bash
# En Termux:
echo "nameserver 8.8.8.8" > $PREFIX/etc/resolv.conf
```

### La clave Groq da error 403
Cambiar la clave en `server_a3.py` (línea `GROQ_API_KEY`) y en `alba_chat_screen.dart`
(constante `_groqKey`). Las claves de reserva están en la tabla de arriba.

### El APK no se instala ("versión incompatible")
```bash
# Compilar para ARM 32-bit específicamente:
flutter build apk --target-platform android-arm --split-per-abi
# No usar app-release.apk universal — usar app-armeabi-v7a-release.apk
```

### La app no compila en Flutter
```bash
cd /Users/apliarte/trabajo/ClawMobil
flutter clean
flutter pub get
flutter build apk --target-platform android-arm --split-per-abi
```

---

## 📁 Estructura de archivos relevantes

```
ClawMobil/
├── lib/
│   ├── main.dart                        # Rutas principales (/ y /alba)
│   └── screens/
│       ├── alba_chat_screen.dart        # Chat de Alba con Cleo
│       └── alba_admin_screen.dart       # Panel de administración
├── termux_scripts/
│   └── samsung_a3/
│       ├── server_a3.py                 # Servidor Python para el navegador
│       ├── chat.html                    # Chat web (navegador)
│       ├── start.sh                     # Script de arranque en Termux
│       ├── README.md                    # Referencia técnica
│       └── INSTALACION_DESDE_CERO.md   # Esta guía
└── android/
    └── app/src/main/AndroidManifest.xml # Permisos (RECORD_AUDIO, Termux)
```

---

## ✅ Checklist de verificación final

- [ ] `adb devices` muestra `<DEVICE_SERIAL>   device`
- [ ] WiFi conectado, IP `192.168.1.25` (o la IP actual)
- [ ] `curl http://192.168.1.25:8080/api/status` responde `{"status": "ok", ...}`
- [ ] APK instalado: `adb shell pm list packages | grep aplibot`
- [ ] Micrófono permitido en la app
- [ ] Cleo saluda al abrir el chat
- [ ] Enviar "hola" de texto → Cleo responde
- [ ] Grabar audio → se transcribe y Cleo responde
- [ ] Botón atrás NO cierra la app
- [ ] Mantener engranaje 8s → entra al panel admin
- [ ] Panel admin: "Apagar Cleo y cerrar app" cierra la app
