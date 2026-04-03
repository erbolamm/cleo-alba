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
MIT — 2026 ApliArte

## About
Plaud Assistant - Asistente IA personalizable para niños con modo kiosco, compatible con OpenClaw y Groq.

Este proyecto funciona como un **self-service**: tú descargas el código, personalizas la configuración, y compilas tu APK personalizado.

| Carpeta | Qué es | ¿Se modifica? |
|---|---|---|
| `lib/config/` | Configuración central (app_config.dart) | ✅ Sí (obligatorio) |
| `lib/services/` | Servicio API genérico | ❌ No |
| `lib/screens/` | Interfaces de usuario | ❌ No |
| `docs/` | Landing page y documentación | ❌ No |
| `ANALIZAR_AQUI.md` | Prompt para analizar repos | ❌ No |

> **Regla de oro**: Solo modifica `lib/config/app_config.dart` con tus datos personales. Todo el resto del código funciona sin cambios.

---

## � Descarga e Instalación

### Opción 1: Descarga Directa (Recomendado)
1. Ve a [Releases](https://github.com/erbolamm/cleo-alba/releases)
2. Descarga el APK más reciente (`plaud-assistant-vX.X.X.apk`)
3. Instala en tu Android 6.0+

### Opción 2: Compilar desde Código
```bash
# 1. Clona el proyecto
git clone https://github.com/erbolamm/cleo-alba.git
cd cleo-alba

# 2. Personaliza la configuración
edita lib/config/app_config.dart

# 3. Compila e instala
flutter pub get
flutter build apk --release
# Instala el APK generado
```

### Opción 3: GitHub Actions (Automático)
- Las releases se generan automáticamente con cada tag `v*`
- Incluyen APK y App Bundle optimizados
- Listos para instalar o subir a Play Store

---

## ⚙️ Configuración Personalizada

### Paso 1: Personalizar Datos Familiares
Edita `lib/config/app_config.dart`:

```dart
class AppConfig {
  // 🏠 Datos personales
  static const String childName = 'Nombre del niño';
  static const List<String> familyMembers = ['Mamá', 'Papá', 'Abuela'];
  static const int childAge = 7;
  static const String assistantName = 'Plaud';
  
  // 🔗 Configuración API (elige una)
  
  // OpenClaw (servidor propio)
  static const String apiUrl = 'https://tu-servidor.com/agent/ask';
  static const String apiToken = 'token_seguro';
  
  // Groq API (alternativa)
  static const String groqApiKey = 'gsk_tu_api_key';
}
```

### Paso 2: Elegir Proveedor API

#### OpenClaw (Recomendado)
- ✅ Control total y privacidad
- ✅ Sin costes por uso
- ✅ Respuestas ultra rápidas
- ⚠️ Requiere servidor propio

#### Groq API
- ✅ Setup en 2 minutos
- ✅ LLMs de alta calidad
- ⚠️ Coste por token
- ⚠️ Datos en servidores Groq

### Paso 3: Probar y Compilar
```bash
flutter pub get
flutter build apk --release
```

---

## 📱 Requisitos

- **Android**: 6.0+ (API 23)
- **Flutter**: SDK reciente
- **API**: OpenClaw (servidor propio) o Groq (gratuito con límites)
- **Hardware**: Mínimo 2GB RAM, 100MB libres

---

## 🔧 Configuración API

### OpenClaw (Recomendado)
- Servidor propio con control total
- Sin costes por uso
- Privacidad absoluta

### Groq API
- Setup en 2 minutos
- LLMs de alta calidad (Llama3, Mixtral)
- Coste por token usado

Ver guía completa en [`API_SETUP.md`](API_SETUP.md)

---

## 🌐 Landing Page

Visita la landing page del proyecto: https://erbolamm.github.io/cleo-alba/

---

## 📚 Documentación

- [`plaud_app.md`](plaud_app.md) - Funcionalidades detalladas
- [`API_SETUP.md`](API_SETUP.md) - Guía OpenClaw + Groq  
- [`landing.md`](landing.md) - Contenido de landing page
- [`ANALIZAR_REPOSITORIO.md`](ANALIZAR_REPOSITORIO.md) - Analizador de repositorios
