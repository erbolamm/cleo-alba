# Plan: Samsung A3 como Proyecto Independiente

> Documento creado tras estudio completo del workspace ClawMobil (130+ archivos).
> Objetivo: convertir `termux_scripts/samsung_a3/` en un proyecto Flutter autónomo que NO dependa de `lib/` de la raíz.

---

## 1. El Problema Actual

```
ClawMobil/                          ← PROYECTO FLUTTER (pubspec.yaml aquí)
├── lib/                             ← CÓDIGO DART compartido (11 screens)
│   ├── main.dart                    ← Entry point con rutas / y /alba
│   └── screens/
│       ├── welcome_screen.dart      ← Gatekeeper (conecta a localhost:8080)
│       ├── home_screen.dart         ← 5 tabs: Chat, Avatar, Display, Plaud, Mission
│       ├── chat_screen.dart         ← Chat general (speech_to_text + upload)
│       ├── avatar_screen.dart       ← Avatar neón con STT triple + ElevenLabs TTS
│       ├── alba_chat_screen.dart    ← Chat para Alba con Cleo (Groq directo)
│       ├── alba_admin_screen.dart   ← Panel admin padres
│       ├── mission_screen.dart      ← Dashboard OpenClaw (854 líneas)
│       ├── plaud_screen.dart        ← Motor grabación/análisis Plaud
│       ├── rescue_screen.dart       ← Modo rescate (WebView)
│       └── smart_display_screen.dart← WebView Smart Display
├── termux_scripts/samsung_a3/      ← SOLO scripts Termux + docs
│   ├── server_a3.py                ← Servidor Python (solo stdlib)
│   ├── chat.html                   ← Web chat standalone
│   ├── start.sh                    ← Arranque Termux
│   ├── LEEME.md, README.md         ← Documentación
│   └── INSTALACION_DESDE_CERO.md
└── android/app/build.gradle.kts    ← minSdk forzado a 23 (hack)
```

### ¿Por qué no funciona?

1. **La app Flutter compila con 11 pantallas** (avatar, mission, plaud, smart_display...) que necesitan OpenClaw, ElevenLabs, Brave Search, whisper.cpp, Ollama — **nada de eso existe en el A3** (1.4GB RAM, Android 6)
2. **El A3 solo corre `server_a3.py`** — un servidor HTTP mínimo con 3 endpoints (`/api/chat`, `/api/status`, `/api/history`)
3. **WelcomeScreen busca `/api/status`** → si encuentra el servidor, abre HomeScreen con 5 tabs → todas excepto Chat intentan features que el A3 no soporta
4. **La ruta `/alba`** (AlbaChatScreen) sí funciona en el A3 porque usa Groq API directamente, pero es una ruta alternativa, no la principal
5. **`minSdk = 23`** es un hack — varias dependencias (webview_flutter, url_launcher, shared_preferences) declaran minSdk=24 y se fuerzan con `tools:overrideLibrary`

### Conclusión

El APK que se instala en el A3 es **la misma app completa** del proyecto raíz, con todo el peso muerto de funcionalidades que no puede ejecutar. El Samsung A3 necesita su propio proyecto Flutter mínimo.

---

## 2. Lo Que Necesita el Samsung A3

### 2.1 Hardware y Limitaciones

| Spec | Valor | Impacto |
|---|---|---|
| Modelo | SM-A300FU (Galaxy A3 2015) | - |
| Android | 6.0.1 (API 23) | Flutter mínimo soportado = API 24. Requiere hack |
| RAM | 1.4 GB | Sin Ollama, sin whisper.cpp, sin modelos locales |
| CPU | Qualcomm MSM8916, armeabi-v7a 32-bit | Solo `--target-platform android-arm` |
| Almacenamiento | 16GB (7GB libres) | APK ≤ 20MB. Sin modelos de IA grandes |
| GPU | Adreno 306 | Sin aceleración ML |
| Serial | <DEVICE_SERIAL> | Para ADB |
| IP local | 192.168.1.25 | Red WiFi casa |

### 2.2 Stack Real del A3

```
Samsung A3
├── Termux v0.119.0-beta.3 (legacy ARM)
│   ├── Python 3.8 (stdlib solamente, sin pip)
│   ├── sshd (puerto 8022, pass <TU_PASSWORD_SSH>)
│   └── server_a3.py (puerto 8080)
│       ├── GET  /              → sirve chat.html
│       ├── POST /api/chat      → proxy a Groq API
│       ├── GET  /api/status    → {"status":"online"}
│       ├── GET  /api/history   → últimos 20 mensajes
│       ├── POST /api/clear     → limpiar historial
│       └── POST /api/shutdown  → apagar servidor
└── APK Flutter (dedicado)
    └── Solo 2 pantallas:
        ├── Alba Chat (Cleo)    → Groq API directo
        └── Admin padres        → ver estado + apagar
```

### 2.3 Lo Que NO Necesita

| Feature del proyecto raíz | ¿Necesario? | Por qué |
|---|---|---|
| `avatar_screen.dart` (674 líneas) | ❌ | Requiere ElevenLabs TTS, personas, eye tracking, auto-listen |
| `mission_screen.dart` (854 líneas) | ❌ | Dashboard OpenClaw — no hay OpenClaw en el A3 |
| `plaud_screen.dart` | ❌ | Motor Plaud — endpoints `/plaud/*` no existen en server_a3.py |
| `smart_display_screen.dart` | ❌ | WebView al endpoint `/display` — no existe en server_a3.py |
| `rescue_screen.dart` | ❌ | WebView a `/rescue` — no existe |
| `home_screen.dart` (5 tabs) | ❌ | Orquesta todas las pantallas de arriba |
| `welcome_screen.dart` (gatekeeper) | ❌ | Lógica de reconexión compleja innecesaria para un teléfono de niña |
| `webview_flutter` | ❌ | Smart Display + Rescue — eliminable |
| `file_picker` | ❌ | Upload de archivos al chat — Alba no necesita esto |
| `audioplayers` | ❌ | Solo se usaba para TTS ElevenLabs en avatar |
| `permission_handler` | ❌ | Simplificable — solo necesita micrófono |
| `android_intent_plus` | ❌ | Intent a Termux — simplificable |

---

## 3. Plan de Ejecución

### Fase 1: Crear proyecto Flutter independiente

**Ubicación**: `termux_scripts/samsung_a3/app/`

```
termux_scripts/samsung_a3/
├── app/                          ← NUEVO proyecto Flutter
│   ├── pubspec.yaml              ← Deps mínimas (http, shared_preferences, speech_to_text)
│   ├── lib/
│   │   ├── main.dart             ← Entry point → AlbaChatScreen
│   │   └── screens/
│   │       ├── alba_chat_screen.dart   ← Copiar + limpiar de lib/screens/
│   │       └── alba_admin_screen.dart  ← Copiar + limpiar de lib/screens/
│   ├── android/
│   │   └── app/
│   │       ├── build.gradle.kts  ← minSdk = 23 nativo (sin hack)
│   │       └── src/main/AndroidManifest.xml ← Permisos mínimos
│   ├── test/
│   └── .gitignore
├── server_a3.py                  ← Ya existe ✓
├── chat.html                     ← Ya existe ✓
├── start.sh                      ← Ya existe ✓
├── LEEME.md                      ← Ya existe ✓ (actualizar)
├── INSTALACION_DESDE_CERO.md     ← Ya existe ✓ (actualizar)
├── README.md                     ← Ya existe ✓ (actualizar)
└── ERRORES_CONOCIDOS.md          ← NUEVO: registro de errores y soluciones
```

### Fase 2: pubspec.yaml mínimo

```yaml
name: cleo_samsung_a3
description: App de Cleo para Alba — Samsung Galaxy A3 2015

publish_to: 'none'
version: 1.0.0+1

environment:
  sdk: '>=3.2.0 <4.0.0'

dependencies:
  flutter:
    sdk: flutter
  http: ^1.2.0
  shared_preferences: ^2.2.2
  speech_to_text: ^7.3.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.0
```

**Eliminados**: audioplayers, webview_flutter, permission_handler, file_picker, android_intent_plus, path_provider, flutter_launcher_icons

### Fase 3: Simplificar pantallas

**`alba_chat_screen.dart`** — cambios respecto al actual:
- Sin import de `android_intent_plus`
- Groq API key desde SharedPreferences (no hardcodeada)
- Mantener: kiosk mode, countdown 10s, speech_to_text, burbujas

**`alba_admin_screen.dart`** — cambios:
- Sin import de `android_intent_plus`
- Verificar servidor local (GET `/api/status`)
- Verificar Groq (GET a api.groq.com)
- Botón para cerrar app (`SystemNavigator.pop()`)
- Campo editable para API key Groq

### Fase 4: build.gradle.kts limpio

```kotlin
defaultConfig {
    applicationId = "com.apliarte.cleo"
    minSdk = 23    // Android 6 (A3)
    targetSdk = 36
    versionCode = 1
    versionName = "1.0.0"
}
```

Sin `tools:overrideLibrary`, sin hacks de `flutter.minSdkVersion`.

> **Nota**: si `shared_preferences_android` sigue declarando minSdk=24, se puede usar un `dependency_overrides` con una versión compatible, o directamente guardar la config en un JSON plano con `dart:io`.

### Fase 5: AndroidManifest.xml mínimo

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    <uses-permission android:name="android.permission.INTERNET"/>
    <uses-permission android:name="android.permission.RECORD_AUDIO"/>
    <!-- Solo 2 permisos -->
</manifest>
```

### Fase 6: Compilar y desplegar

```bash
cd termux_scripts/samsung_a3/app
flutter create . --org com.apliarte --project-name cleo_samsung_a3 --platforms android
# Copiar lib/, pubspec.yaml, build.gradle.kts, AndroidManifest.xml
flutter pub get
flutter build apk --target-platform android-arm --split-per-abi
adb -s <DEVICE_SERIAL> install -r build/app/outputs/flutter-apk/app-armeabi-v7a-release.apk
```

### Fase 7: Documentar errores conocidos

Crear `ERRORES_CONOCIDOS.md` con todo lo aprendido:

| Error | Causa | Solución |
|---|---|---|
| `INSTALL_FAILED_OLDER_SDK` | minSdk > API 23 | `minSdk = 23` en build.gradle.kts |
| `flutter.minSdkVersion = 24` | Flutter SDK lo fuerza | Usar variable local `val appMinSdk = 23` |
| Flutter sobreescribe build.gradle.kts | Mensaje "Upgrading build.gradle.kts" | No usar `flutter.minSdkVersion`, usar constante propia |
| `record` package incompatible | `record_linux` no implementa `startStream` | Usar `speech_to_text` en su lugar |
| `record: ^6.x` requiere API 24 | NDK 24 en manifest | No usar record en dispositivos < API 24 |
| `shared_preferences_android` minSdk=24 | Versión reciente requiere API 24 | `tools:overrideLibrary` o usar versión anterior |
| `speech_to_text` conflicto con `audioplayers` | Versiones cruzadas | `speech_to_text: ^7.3.0` + `audioplayers: ^6.5.1` |
| Groq API 403 | Key expirada o modelo cambiado | Rotar key, verificar modelo activo |
| SSH muere en background | Android mata proceso | Envolver en `nohup`, reopenar sesión |
| `localhost` no resuelve en WebView | Quirk de Android 6 | Usar `127.0.0.1` explícitamente |

### Fase 8: Actualizar documentación existente

- **LEEME.md** (raíz): Añadir que samsung_a3 es proyecto independiente
- **LEEME.md** (samsung_a3): Actualizar con referencia a `app/`
- **INSTALACION_DESDE_CERO.md**: Actualizar con nueva ruta de build
- **README.md** (samsung_a3): Actualizar tabla de archivos

---

## 4. OpenClaw — Contexto y Referencia

### 4.1 ¿Qué es OpenClaw?

OpenClaw es un **gateway IA multi-canal** (Node.js) que permite que un bot de IA se comunique por múltiples canales (Telegram, Matrix, Android) con un solo backend. El fork del usuario es: **https://github.com/erbolamm/openclaw**

### 4.2 ¿Para qué se usa en ClawMobil?

```
┌─────────────┐     ┌──────────────────┐     ┌─────────────┐
│ App Flutter  │────▶│ server.py (:8080) │────▶│ OpenClaw    │
│              │     │   (bridge)        │     │ (Debian)    │
└─────────────┘     └──────────────────┘     │ ├── Telegram  │
                                              │ ├── Groq API  │
                                              │ ├── Ollama    │
                                              │ └── Skills    │
                                              └─────────────┘
```

- **En el Huawei P10** (4GB RAM): OpenClaw funciona completo — Telegram, Groq, Ollama (llama3.2:1b), whisper.cpp, skills de cámara/web search
- **En el Samsung A3** (1.4GB RAM): OpenClaw **NO se usa** — insuficiente RAM para Node.js + Debian/proot

### 4.3 ¿Dónde se usa OpenClaw en el código?

| Archivo | Uso |
|---|---|
| `scripts/fix_openclaw_config.sh` | Configuración: modelo, Telegram, gateway, MCP, Brave Search |
| `scripts/audit_openclaw.sh` | Auditoría de binarios, procesos, configs, logs |
| `scripts/restart_all.sh` | Reinicio de gateway (`openclaw gateway run`) |
| `scripts/repara.sh` | Reparación completa del stack |
| `scripts/diagnostico.sh` | Verifica procesos openclaw/node |
| `termux_scripts/start-openclaw.sh` | Autostart con Termux:Boot |
| `termux_scripts/boot_autostart.sh` | Boot alternativo con bind 127.0.0.1 |
| `termux_scripts/OPENCLAW_TOOLS_MANUAL.md` | Manual de tools para el agente |
| `avatar_screen.dart` | Llama `/api/chat` (va a OpenClaw vía bridge) |
| `mission_screen.dart` | Dashboard de control OpenClaw |
| `Informacion_de_funcionalidades/conversacion_fork.md` | Discusión fork/licencia |

### 4.4 Configuración típica de OpenClaw

```bash
# Dentro de Debian/proot en Termux:
openclaw config set provider groq
openclaw config set model groq/llama-3.3-70b-versatile
openclaw config set telegram.botToken "7687752283:AAE..."
openclaw config set telegram.allowedUsers "[\"1234567890\"]"
openclaw config set gateway.port 18789
openclaw config set gateway.bind "127.0.0.1"
openclaw gateway run  # Arranca el gateway
```

### 4.5 Relevancia para el Samsung A3

**Ninguna directa.** El A3 usa `server_a3.py` (Python stdlib) que hace proxy directo a Groq API sin pasar por OpenClaw. Pero la documentación de OpenClaw sigue siendo relevante como referencia para:
- Futuros dispositivos con más RAM
- Entender la arquitectura completa del ecosistema
- El Huawei P10 que sí lo usa

---

## 5. Estructura Final Propuesta

```
termux_scripts/samsung_a3/
├── app/                              ← Proyecto Flutter independiente
│   ├── pubspec.yaml                  ← 3 deps: http, shared_preferences, speech_to_text
│   ├── analysis_options.yaml
│   ├── lib/
│   │   ├── main.dart                 ← MaterialApp → AlbaChatScreen
│   │   └── screens/
│   │       ├── alba_chat_screen.dart ← Chat Cleo (Groq directo)
│   │       └── alba_admin_screen.dart← Panel admin padres
│   ├── android/
│   │   ├── app/
│   │   │   ├── build.gradle.kts     ← minSdk=23, targetSdk=36
│   │   │   └── src/main/
│   │   │       └── AndroidManifest.xml ← INTERNET + RECORD_AUDIO
│   │   ├── build.gradle.kts
│   │   ├── gradle.properties
│   │   └── settings.gradle.kts
│   ├── test/
│   │   └── basic_test.dart
│   └── .gitignore
│
├── server_a3.py                      ← Servidor Python (ya existe)
├── chat.html                         ← Chat web standalone (ya existe)
├── start.sh                          ← Script arranque Termux (ya existe)
│
├── LEEME.md                          ← Contexto para agentes IA (actualizar)
├── README.md                         ← Referencia técnica (actualizar)
├── INSTALACION_DESDE_CERO.md         ← Guía instalación (actualizar)
├── ERRORES_CONOCIDOS.md              ← NUEVO: todos los errores + soluciones
├── OPENCLAW_REFERENCIA.md            ← NUEVO: qué es, cómo se usa, fork erbolamm
└── SERVICIOS_Y_ENDPOINTS.md          ← NUEVO: mapa completo de servicios
```

---

## 6. Checklist de Implementación

- [ ] **Fase 1**: `flutter create` dentro de `termux_scripts/samsung_a3/app/`
- [ ] **Fase 2**: Escribir `pubspec.yaml` mínimo (3 deps)
- [ ] **Fase 3**: Copiar y limpiar `alba_chat_screen.dart` y `alba_admin_screen.dart`
- [ ] **Fase 4**: Configurar `build.gradle.kts` con `minSdk = 23`
- [ ] **Fase 5**: AndroidManifest.xml con solo INTERNET + RECORD_AUDIO
- [ ] **Fase 6**: Compilar APK → verificar que el APK marca `sdkVersion:'23'` con aapt
- [ ] **Fase 7**: Instalar en A3 (`adb -s <DEVICE_SERIAL> install -r`)
- [ ] **Fase 8**: Crear `ERRORES_CONOCIDOS.md`
- [ ] **Fase 9**: Crear `OPENCLAW_REFERENCIA.md`
- [ ] **Fase 10**: Crear `SERVICIOS_Y_ENDPOINTS.md`
- [ ] **Fase 11**: Actualizar `LEEME.md`, `README.md`, `INSTALACION_DESDE_CERO.md`
- [ ] **Fase 12**: Actualizar `LEEME.md` de la raíz indicando que samsung_a3 es proyecto independiente

---

## 7. Reducción Estimada

| Métrica | App actual (raíz) | App dedicada A3 |
|---|---|---|
| Pantallas | 11 | 2 |
| Líneas de Dart | ~4500+ | ~700 |
| Dependencias | 9 | 3 |
| APK size | 16.7 MB | ~8-10 MB (estimado) |
| minSdk hacks | 3 (variable, overrideLibrary, comment) | 0 |
| Endpoints consumidos | 15+ | 4 (`/api/chat`, `/api/status`, `/api/clear`, `/api/shutdown`) |
| Features muertos | 8 pantallas sin backend | 0 |

---

*Plan generado tras análisis completo de 130+ archivos del workspace ClawMobil.*
*Fecha: 27 de febrero de 2026*
