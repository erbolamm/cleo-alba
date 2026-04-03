# Plaud Assistant 🌟

Asistente IA personalizable para niños con modo kiosco y configuración familiar. Open source y compatible con OpenClaw + Groq.

## 🚀 Características

- **Chat IA educativo** adaptado a la edad del niño/a
- **Modo kiosco** seguro - solo el usuario designado puede usarlo
- **Acceso admin** con acceso secreto (mantener pulsado el engranaje 8 segundos)
- **Configuración personalizable** - nombres, familia, edad, etc.
- **Compatible con OpenClaw** y **Groq API**
- **Voz y texto** - habla con el asistente o escribe
- **Detección emocional** - responde adecuadamente a rabietas o frustración
- **Multi-idioma** prompts configurables

## 📱 Dispositivos compatibles

- **Mínimo**: Android 6.0+ (API 23)
- **Recomendado**: Android 7+ con 3GB+ RAM
- **Probado**: Samsung Galaxy A3 2015, dispositivos legacy

## 🛠️ Configuración rápida

### 1. Personalizar la app

Edita `lib/config/app_config.dart`:

```dart
static const String childName = 'Nombre del niño';
static const List<String> familyMembers = ['Mamá', 'Papá', 'Hermano'];
static const int childAge = 7;
static const String apiUrl = 'https://tu-servidor.com/agent/ask';
static const String apiToken = 'Tu token aquí';
```

### 2. Configurar API

**Opción A: OpenClaw**
```dart
static const String apiUrl = 'https://tu-servidor.com/agent/ask';
static const String apiToken = 'token_openclaw';
static const String agentName = 'nombre_agente';
```

**Opción B: Groq**
```dart
static const String apiUrl = 'https://api.groq.com/openai/v1/chat/completions';
static const String groqApiKey = 'gsk_...';
```

### 3. Compilar e instalar

```bash
flutter pub get
flutter build apk --release
adb install build/app/outputs/flutter-apk/app-release.apk
```

## 🧠 Modos de usuario

### Modo Niño/a
- Chat educativo adaptado a la edad
- Detección emocional y apoyo emocional
- Contenido filtrado y apropiado
- Respuestas cortas con emojis

### Modo Admin
- Acceso a configuración técnica
- Información sobre la app
- Diagnóstico y ayuda
- Control parental

## 🔧 Configuración avanzada

### Personalización de prompts

Los prompts se generan automáticamente desde la configuración:

- `_generateChildPrompt()` - Adaptado a la edad y nombre
- `_generateAdminPrompt()` - Modo técnico/administrativo
- Variables dinámicas para nombres familiares

### Modo Kiosco

Bloquea la app para evitar salidas accidentales:

1. Activar en configuración
2. Requiere contraseña admin para salir
3. Bloquea botones de sistema
4. Evita compras accidentales

## 🌐 Servicios compatibles

### OpenClaw
- Servidor propio con control total
- Sin costes por uso
- Prompts personalizados
- Respuestas rápidas

### Groq
- LLMs de alta calidad
- Models: Llama3, Mixtral, etc.
- Coste por token
- Setup rápido

## 📂 Estructura del proyecto

```
lib/
├── config/
│   └── app_config.dart          # Configuración central
├── services/
│   └── api_service.dart         # Conexión API genérica
├── screens/
│   ├── plaud_chat_screen.dart   # Chat principal
│   └── ...                      # Otras pantallas
└── main.dart                    # Entry point
```

## 🔒 Seguridad

- **Sin datos personales** en el código
- **Configuración local** - no subas a GitHub
- **Tokens cifrados** en tránsito
- **Modo kiosco** seguro
- **Control parental** integrado

## 🤝 Contribuir

1. Fork el proyecto
2. Crear feature branch
3. Hacer cambios
4. Test en dispositivo real
5. Pull request

## 🐛 Problemas comunes

**"Configuración requerida"**
- Edita `lib/config/app_config.dart`
- No uses valores por defecto

**"Error de conexión"**
- Verifica URL y token
- Revisa conectividad
- Prueba con curl/wget

**"TTS no funciona"**
- Instalar voces en español
- Revisar configuración de TTS
- Probar con diferentes voces

## 📖 Documentación adicional

- [Guía OpenClaw](docs/OPENCLAW_SETUP.md)
- [Guía Groq](docs/GROQ_SETUP.md)
- [Personalización avanzada](docs/CUSTOMIZATION.md)
- [Troubleshooting](docs/TROUBLESHOOTING.md)

---

## Autor
Javier Mateo (ApliArte) — github.com/erbolamm

## 💬 Una nota personal del autor / A personal note from the author
ℹ️ Nota: El texto siguiente es un mensaje personal del autor, escrito en varios idiomas para que pueda leerlo gente de todo el mundo. Esto no implica que el proyecto tenga soporte funcional completo en esos idiomas.

ℹ️ Note: The text below is a personal message from the author, written in several languages so people around the world can read it. This does not imply full multilingual feature support in those languages.

<details>
<summary>🇪🇸 Español</summary>
Plaud Assistant nació de la necesidad de crear un asistente IA seguro y personalizable para mi hija Alba. Quería una app que pudiera adaptarse completamente a nuestra familia, con nuestros nombres, nuestras costumbres y nuestro cariño. Al hacerlo opensource, espero que otras familias puedan crear sus propios asistentes personalizados, manteniendo siempre el control de sus datos y la privacidad de sus hijos. Este proyecto es un regalo a la comunidad de padres y desarrolladores que creen en una tecnología más humana y respetuosa.
</details>

<details>
<summary>🇬🇧 English</summary>
Plaud Assistant was born from the need to create a safe and customizable AI assistant for my daughter Alba. I wanted an app that could be completely adapted to our family, with our names, our customs, and our love. By making it open source, I hope other families can create their own personalized assistants, always maintaining control of their data and their children's privacy. This project is a gift to the community of parents and developers who believe in more humane and respectful technology.
</details>

<details>
<summary>🇧🇷 Português</summary>
O Plaud Assistant nasceu da necessidade de criar um assistente de IA seguro e personalizável para minha filha Alba. Eu queria um aplicativo que pudesse ser completamente adaptado à nossa família, com nossos nomes, nossos costumes e nosso amor. Ao torná-lo open source, espero que outras famílias possam criar seus próprios assistentes personalizados, mantendo sempre o controle de seus dados e a privacidade de seus filhos. Este projeto é um presente para a comunidade de pais e desenvolvedores que acreditam em uma tecnologia mais humana e respeitosa.
</details>

<details>
<summary>🇫🇷 Français</summary>
Plaud Assistant est né du besoin de créer un assistant IA sûr et personnalisable pour ma fille Alba. Je voulais une application qui puisse être complètement adaptée à notre famille, avec nos noms, nos coutumes et notre amour. En le rendant open source, j'espère que d'autres familles pourront créer leurs propres assistants personnalisés, en maintenant toujours le contrôle de leurs données et la confidentialité de leurs enfants. Ce projet est un cadeau à la communauté de parents et développeurs qui croient en une technologie plus humaine et respectueuse.
</details>

<details>
<summary>🇩🇪 Deutsch</summary>
Plaud Assistant entstand aus dem Bedürfnis, einen sicheren und anpassbaren KI-Assistenten für meine Tochter Alba zu schaffen. Ich wollte eine App, die vollständig an unsere Familie angepasst werden konnte, mit unseren Namen, unseren Gewohnheiten und unserer Liebe. Indem ich sie Open Source mache, hoffe ich, dass andere Familien ihre eigenen personalisierten Assistenten erstellen können, wobei sie immer die Kontrolle über ihre Daten und die Privatsphäre ihrer Kinder behalten. Dieses Projekt ist ein Geschenk an die Gemeinschaft von Eltern und Entwicklern, die an eine menschlichere und respektvollere Technologie glauben.
</details>

<details>
<summary>🇮🇹 Italiano</summary>
Plaud Assistant è nato dall'esigenza di creare un assistente IA sicuro e personalizzabile per mia figlia Alba. Volevo un'app che potesse essere completamente adattata alla nostra famiglia, con i nostri nomi, le nostre abitudini e il nostro amore. Rendendola open source, spero che altre famiglie possano creare i propri assistenti personalizzati, mantenendo sempre il controllo dei propri dati e la privacy dei propri figli. Questo progetto è un regalo alla comunità di genitori e sviluppatori che credono in una tecnologia più umana e rispettosa.
</details>

## 💖 Apoya el proyecto
Herramienta gratuita y open source. Si te ahorra tiempo, un café ayuda a mantener el desarrollo.

| Plataforma | Enlace |
|-----------|--------|
| PayPal | [paypal.me/erbolamm](https://paypal.me/erbolamm) |
| Ko-fi | [ko-fi.com/C0C11TWR1K](https://ko-fi.com/C0C11TWR1K) |
| Twitch Tip | [streamelements.com/apliarte/tip](https://streamelements.com/apliarte/tip) |

🌐 [Sitio Oficial](https://erbolamm.github.io/cleo-alba/) · 📦 [GitHub](https://github.com/erbolamm/cleo-alba)

## Licencia
MIT — © 2026 ApliArte

## About
Plaud Assistant - Asistente IA personalizable para niños con modo kiosco, compatible con OpenClaw y Groq.

Este proyecto funciona como un **self-service**: tú descargas el proyecto (el buffet), creas tu carpeta personal, y vas cogiendo lo que necesitas — sin tocar nada del proyecto en sí.

| Carpeta | Qué es | ¿Se modifica? |
|---|---|---|
| `scripts/` | Scripts de instalación, evaluación y promoción | ❌ No |
| `termux_scripts/` | Scripts que se suben al Android | ❌ No |
| `config/` | Plantilla de configuración | ❌ No (copiar y personalizar) |
| `empezar.html` | Asistente web (prompt + perfil local) | ❌ No |
| **`Mis_configuraciones_locales/`** | **Tu bandeja personal** | ✅ Sí, solo esta |

> **Regla de oro**: si necesitas guardar una clave, un log, una nota, **o el código fuente de una App Flutter** (ej. un chat) que controla un dispositivo específico → va TODO dentro de `Mis_configuraciones_locales/dispositivos/<dispositivo>/`. El resto del proyecto madre se queda intacto. De esta manera, tu carpeta de dispositivo se convierte en un proyecto independiente que te puedes llevar a donde quieras.

---

## 🚀 Empezar (3 pasos)

### 1. Clona el proyecto
```bash
git clone https://github.com/erbolamm/ClawMobil.git
cd ClawMobil
```

### 2. Crea tu carpeta personal
```bash
mkdir -p Mis_configuraciones_locales/dispositivos/mi_dispositivo
cp Mis_configuraciones_locales/dispositivos/_plantilla/* \
   Mis_configuraciones_locales/dispositivos/mi_dispositivo/
```

Esta carpeta ya está en `.gitignore` — nada de lo que pongas ahí se sube al repo.

### 3. Conecta tu Android y despliega
1. Habilita **Depuración USB** en tu teléfono.
2. Conéctalo por cable al Mac/PC.
3. Abre **`index.html`** (entrada simplificada) y desde ahí entra a **`empezar.html`**.
4. Usa el **Asistente de Configuración Local** para generar:
   - `config_profile.json`
   - Prompt de despliegue
   - Comando para crear tu carpeta local.
5. Pega el prompt en tu IDE con IA (Cursor, Windsurf, Gemini, etc.).
6. Tu asistente IA ejecutará los scripts automáticamente.

## 🧭 Raíz simplificada para usuarios

Si vas a usar ClawMobil sin perfil técnico, en la raíz del proyecto céntrate solo en:

- `index.html` → flujo guiado para abrir VS Code y lanzar el asistente.
- `LEEME.md` → guía breve de operación modular.

El resto de carpetas/archivos existen para el funcionamiento interno del framework.

---

## 🧩 Modo Framework Local (fork/clon)

ClawMobil incluye un flujo modular para que cada fork o dispositivo trabaje con
su configuración local y, si descubre mejoras, pueda proponerlas a la plantilla:

```bash
# 1) Detectar configuración activa
bash scripts/local_config_select.sh

# 2) Evaluar completitud de perfiles locales
bash scripts/local_config_evaluate.sh

# 3) Detectar candidatos reutilizables vs _plantilla
bash scripts/local_config_discovery.sh

# 3.1) Detector automático de cambios locales
bash scripts/local_config_watch.sh

# 4) Promover una mejora de forma trazable
bash scripts/local_config_promote.sh <dispositivo> <ruta_relativa>

# 5) Crear snapshot/revertir pruebas
bash scripts/local_config_lab.sh snapshot <dispositivo>
bash scripts/local_config_lab.sh restore <dispositivo> <snapshot.tar.gz>

# 6) Prueba integral del flujo modular
bash scripts/local_config_selftest.sh

# 7) Smoke test del wizard (empezar.html)
bash scripts/wizard_local_smoketest.sh

# 8) Checklist pre-directo completo
bash scripts/prelive_direct_check.sh
```

Guía completa: [`docs/LOCAL_CONFIG_FRAMEWORK.md`](docs/LOCAL_CONFIG_FRAMEWORK.md)
Auditoría upstream: [`docs/AUDITORIA_OPENCLAW_ORIGINAL_2026-02-27.md`](docs/AUDITORIA_OPENCLAW_ORIGINAL_2026-02-27.md)
Guion directo: [`docs/GUION_DIRECTO_CLAWMOBIL_2026-02-27.md`](docs/GUION_DIRECTO_CLAWMOBIL_2026-02-27.md)

## 🔒 Dependencia OpenClaw prioritaria

Para estabilidad del framework, la referencia de motor se fija en el fork:

- <https://github.com/erbolamm/openclaw>

## 🔗 Vinculación ClawMobil ↔ fork OpenClaw

Este proyecto ClawMobil y el fork `erbolamm/openclaw` se están actualizando en paralelo para asegurar compatibilidad real con móviles antiguos reacondicionados.

Perfil de dispositivos validados en campo:

- Samsung (legacy)
- YesTeL Note series
- Huawei P10

En el fork se añadió un flujo reproducible de instalación para Android antiguos (Termux + ADB + SSH), pensado para que la comunidad pueda reutilizarlo sin depender de hardware nuevo:

- <https://github.com/erbolamm/openclaw/blob/main/docs/legacy-termux-android.md>
- <https://github.com/erbolamm/openclaw/blob/main/scripts/legacy/deploy-termux-via-adb.sh>

---

## 🛠️ ¿Qué consigues?

- **Chat por voz** — Habla con tu dispositivo y recibe respuestas inteligentes.
- **Visión IA** — La cámara del teléfono + IA = describe lo que ve.
- **IA 100% Offline** — Funciona sin internet con Ollama + Whisper.
- **Servidor 24/7** — Accesible por Telegram, API REST, o la app Flutter.
- **Smart Display** — Convierte el teléfono en una pantalla inteligente.
- **Avatar animado** — Cara de neón que reacciona a tus interacciones.

## 📋 Requisitos mínimos

- Android 7+ con al menos **3 GB de RAM** (4 GB+ para modo offline).
- **Restablecimiento de fábrica recomendado** — no uses tu teléfono principal.
- Cable USB y un Mac/PC para la configuración inicial.
- [Termux (F-Droid)](https://f-droid.org/packages/com.termux/) instalado en el Android.

## 📂 Estructura del proyecto

```
ClawMobil/
├── empezar.html              ← Generador de prompt de despliegue
├── index.html                ← Web pública del proyecto
├── scripts/                  ← Scripts de despliegue + framework local
├── termux_scripts/           ← Scripts que se suben al dispositivo
├── config/                   ← Plantilla de configuración
├── docs/                     ← Guías del framework (fork, local config)
├── lib/                      ← App Flutter (cliente)
├── Mis_configuraciones_locales/  ← 🔒 TU carpeta (gitignored)
│   ├── claves_globales.env
│   └── dispositivos/
│       ├── _plantilla/       ← Copia esto para cada nuevo dispositivo
│       └── tu_dispositivo/
│           ├── config_profile.json ← Perfil generado por wizard
│           ├── claves.env    ← Tus API keys
│           ├── notas.md      ← Estado y documentación
│           └── ...
```

## 💖 Apoya el proyecto

Si ClawMobil te resulta útil, comparte tu experiencia en redes con **#ClawMobil** etiquetando a **@erbolamm**.

- **PayPal**: [paypal.me/erbolamm](https://www.paypal.com/paypalme/erbolamm)
- **Ko-fi**: [![Ko-fi](https://storage.ko-fi.com/cdn/kofi5.png?v=6)](https://ko-fi.com/C0C11TWR1K)

## 🌐 ¿Quieres tu propio servidor para el bot?

ClawMobil funciona en un móvil viejo, pero si quieres un bot 24/7 en la nube (como @ApliArteBot), necesitas un VPS. Yo uso **Hostinger** y estoy encantado.

Mi consejo: abre tu IA favorita y dile exactamente esto:

> *"Quiero montar un servidor para un bot de Telegram con IA. Hazme 100 preguntas en bloques de 3 para entender exactamente qué necesito antes de recomendarme nada."*

Así te aseguras de que la IA entiende TU caso antes de recomendarte algo. Filosofía Steve Jobs: **Ganar-Ganar** — tú ganas el servidor perfecto para ti, yo gano una pequeña comisión que me ayuda a seguir manteniendo ClawMobil.

👉 **[Contratar Hostinger con mi referido](https://www.hostinger.com/es?REFERRALCODE=APLIARTE)** — Desde 2,99€/mes con VPS incluido.

## 🛡️ Licencia

© 2026 [ApliArte](https://apliarte.com). Código abierto.
¡Transforma tus antiguos móviles en servidores IA!

---
**Hecho con ❤️ por [ApliArte](https://apliarte.com)** · [@erbolamm](https://github.com/erbolamm)
