# ANALIZAR_AQUI — Prompt Maestro para Agentes IA

> **Instrucción OBLIGATORIA**: Cuando abras este proyecto en VS Code, lee este archivo COMPLETO antes de hacer nada.
> Después lee también `ESTADO.md` para tener el contexto completo del proyecto.
> El usuario (Javier Mateo / ErBolamm) ha dejado un proyecto en la carpeta `ANALIZAR_AQUI/` para que lo analices.

---

## 🧠 Quién es Javier (contexto para el agente)

- **Javier Mateo** (ErBolamm / ApliArte) — aprendió a programar solo desde el 4 de abril de 2023
- Tiene TDAH y altas capacidades — explicar con frases cortas, listas numeradas, cero rodeos
- No sabe inglés — TODO en español
- Muchos proyectos son prueba/error del aprendizaje → hay que filtrar qué vale y qué no
- Si es ejercicio de Dart/Flutter → puede valer como contenido para apliarte.com o tutograti.com
- Su app estrella: **CalcaApp** (5.6M+ descargas, 4.8★, 15 idiomas)
- Carrera carnavalesca: Escudo de Oro, Concha de Plata, futuro Hijo Honorífico de Marbella (6 ago 2026)
- **El universo completo de proyectos** está en `universe.json` (12 registrados, ~25 en total)
- **El grafo visual** está en https://erbolamm-hub.web.app (proyecto hermano en `/Users/apliarte/trabajo/erbolamm-hub`)

### Dominios del ecosistema (TODOS en Cloudflare)
| Dominio | Pilar | Qué es |
|---------|-------|--------|
| erbolamm.com | Hub | Web principal (este proyecto) |
| apliarte.com | Educación | Blog developer + hub aprendizaje |
| calcaapp.com | Creación | Blog de CalcaApp |
| elbolademarbella.com | Cultura | Blog Carnaval |
| lachirigotadelbola.com | Cultura | Blog chirigota |
| lacomparsadelbola.com | Cultura | Blog comparsa |
| tuaplicaciongratis.com | Educación | Apps no-code |
| tutograti.com | Educación | Tutoriales gratuitos |

---

## 🎯 Tu misión

Analizar el proyecto que hay en `ANALIZAR_AQUI/` y ayudar a Javier a decidir qué hacer con él.

---

## 📋 Paso 1 — Análisis automático

Nada más leer esto, analiza `ANALIZAR_AQUI/` y responde:

1. **¿Qué es?** (app Flutter, extensión VS Code, web HTML, ejercicio Dart, paquete pub.dev, otra cosa)
2. **¿Qué lenguaje/framework?** (Dart, Flutter, TypeScript, Python, HTML puro...)
3. **¿Está completo?** (funcional, a medias, solo un esqueleto, roto)
4. **¿Tiene algo aprovechable?** (código, diseño, lógica, assets)
5. **Resumen en 3 líneas** — qué hace, para qué sirve, estado actual

---

## 📋 Paso 2 — Preguntar a Javier

Después del análisis, hazle EXACTAMENTE estas preguntas:

1. "¿Qué quieres hacer con este proyecto?"
   - a) **Publicar** → pasa al Paso 3
   - b) **Fusionar** con otro proyecto existente → pregunta cuál
   - c) **Aprovechar partes** → indica qué partes y para qué proyecto
   - d) **Descartar** → confirmar y archivar
   - e) **Continuar desarrollando** → ayudar a terminarlo

2. "¿Hay algo de este proyecto que ya exista en tu universo?" (revisa `universe.json`)

---

## 📋 Paso 3 — Requisitos para publicar

Si Javier quiere publicar el proyecto, DEBE cumplir estos campos mínimos según su tipo:

### App móvil
| Campo | Obligatorio | Ejemplo |
|-------|-------------|---------|
| `name` | ✅ | CalcaApp |
| `description` | ✅ | Mesa de luz digital |
| `urls.playstore` | ✅ (si Android) | https://play.google.com/... |
| `urls.appstore` | ⬜ (si iOS) | https://apps.apple.com/... |
| `urls.landing` | ⬜ (recomendado) | https://calcaapp-landing.web.app |
| `urls.web` | ⬜ (blog) | https://calcaapp.com |

### Extensión VS Code
| Campo | Obligatorio | Ejemplo |
|-------|-------------|---------|
| `name` | ✅ | Key Master |
| `description` | ✅ | Gestión de claves API |
| `urls.github` | ✅ | https://github.com/erbolamm/... |
| `urls.marketplace` | ⬜ | https://marketplace.visualstudio.com/... |

### Paquete / Librería
| Campo | Obligatorio | Ejemplo |
|-------|-------------|---------|
| `name` | ✅ | apliarte_faq |
| `description` | ✅ | FAQ integrable para apps Flutter |
| `urls.github` | ✅ | https://github.com/erbolamm/... |
| `urls.pub` | ⬜ (si Dart) | https://pub.dev/packages/... |
| `urls.npm` | ⬜ (si JS/TS) | https://npmjs.com/package/... |

### Web / Blog
| Campo | Obligatorio | Ejemplo |
|-------|-------------|---------|
| `name` | ✅ | ApliArte |
| `description` | ✅ | Hub de Aprendizaje de Flutter |
| `urls.web` | ✅ | https://apliarte.com |

### Dispositivo / Hardware
| Campo | Obligatorio | Ejemplo |
|-------|-------------|---------|
| `name` | ✅ | ApliMemo |
| `description` | ✅ | Asistente Cognitivo de Bolsillo |
| `urls.landing` | ⬜ (cuando exista) | https://aplimemo.apliarte.com |

---

## 📋 Paso 3.5 — Regla obligatoria de README (GitHub o idea nueva)

Si el proyecto está publicado en GitHub **o** es un proyecto nuevo (solo idea inicial), el `README.md` debe quedar visualmente cuidado y **terminar siempre** con este bloque final (sin ninguna sección después):

```md
## Autor
Javier Mateo (ApliArte) — github.com/erbolamm

## 💬 Una nota personal del autor / A personal note from the author
ℹ️ Nota: El texto siguiente es un mensaje personal del autor, escrito en varios idiomas para que pueda leerlo gente de todo el mundo. Esto no implica que el proyecto tenga soporte funcional completo en esos idiomas.

ℹ️ Note: The text below is a personal message from the author, written in several languages so people around the world can read it. This does not imply full multilingual feature support in those languages.

<details>
<summary>🇪🇸 Español</summary>
[Mensaje completo adaptado al proyecto analizado: qué es, para qué sirve y por qué se comparte]
</details>

<details>
<summary>🇬🇧 English</summary>
[Full message adapted to the analyzed project: what it is, what it does, and why it is shared]
</details>

<details>
<summary>🇧🇷 Português</summary>
[Mensagem completa adaptada ao projeto analisado: o que é, para que serve e por que é compartilhado]
</details>

<details>
<summary>🇫🇷 Français</summary>
[Message complet adapté au projet analysé : ce que c'est, à quoi il sert et pourquoi il est partagé]
</details>

<details>
<summary>🇩🇪 Deutsch</summary>
[Vollständige Nachricht zum analysierten Projekt: was es ist, wofür es dient und warum es geteilt wird]
</details>

<details>
<summary>🇮🇹 Italiano</summary>
[Messaggio completo adattato al progetto analizzato: cos'è, a cosa serve e perché viene condiviso]
</details>

## 💖 Apoya el proyecto
Herramienta gratuita y open source. Si te ahorra tiempo, un café ayuda a mantener el desarrollo.

| Plataforma | Enlace |
|-----------|--------|
| PayPal | paypal.me/erbolamm |
| Ko-fi | ko-fi.com/C0C11TWR1K |
| Twitch Tip | streamelements.com/apliarte/tip |

🌐 Sitio Oficial · 📦 GitHub

## Licencia
MIT — © 2026 ApliArte

## About
[Descripción corta real del proyecto actual]
```

Reglas adicionales de esta sección final:
1. Debe ser el cierre real del README (no añadir nada después de `About`).
2. Mantener exactamente el orden de secciones del bloque.
3. Se permite mejorar estilo visual (tablas, enlaces Markdown, detalles plegables), sin romper el contenido mínimo.
4. En `About`, adaptar solo la descripción al proyecto concreto que se está publicando.
5. Los idiomas deben ir en formato desplegable con `<details><summary>...</summary>...</details>` como en `corrector-vscode`.
6. El texto de cada idioma debe hablar del proyecto actual (nombre, utilidad, propósito y estado), no copiar literalmente el mensaje de otro repositorio.

---

## 📋 Paso 4 — Registrar en el universo

Si el proyecto cumple los requisitos mínimos, **añádelo a `universe.json`** con esta estructura:

```json
{
  "id": "nombre-en-kebab-case",
  "name": "Nombre Visible",
  "pillar": "creacion|educacion|cultura|herramientas|hardware",
  "type": "app|web|extension|package|device|client",
  "description": "Descripción corta",
  "urls": { ... },
  "status": "published|wip|archived"
}
```

### Pilares disponibles:
- `creacion` (rosa #ff4e83) — Apps y productos creativos
- `educacion` (azul #1976D2) — Enseñanza, tutoriales, aprendizaje
- `cultura` (verde #388E3C) — Carnaval, música, identidad cultural
- `herramientas` (naranja #FF8F00) — Extensiones, paquetes, tools de dev
- `hardware` (dorado #FFB300) — Dispositivos físicos, IoT

---

## ⚠️ Reglas obligatorias

1. **NUNCA borrar nada** sin confirmación de Javier
2. **NUNCA mover archivos fuera** de `ANALIZAR_AQUI/` sin permiso
3. Si el proyecto tiene secretos o API keys → AVISAR, no imprimir
4. Si dudas del pilar → pregunta
5. Después de analizar, **vaciar `ANALIZAR_AQUI/`** solo cuando Javier confirme
6. **NUNCA SMS Auth** — Javier perdió 1600€ por esto en CalcaApp
7. Si el proyecto usa Firebase → verificar si ya hay un proyecto Firebase existente en el ecosistema
8. Escribir respuestas en **español**, frases cortas, listas numeradas

---

## 📊 Pilares del ecosistema (referencia rápida)

| Pilar | Color | Emoji | Ejemplos |
|-------|-------|-------|----------|
| `creacion` | Rosa `#ff4e83` | ✏️ | CalcaApp, diseños, vídeos |
| `educacion` | Azul `#1976D2` | 🎓 | ApliArte, TutoGrati, TuAplicacionGratis |
| `cultura` | Verde `#388E3C` | 🎭 | ElBolaDeMarbella, chirigotas, comparsas |
| `herramientas` | Naranja `#FF8F00` | 🔧 | Key Master, Corrector VS Code, apliarte_faq |
| `hardware` | Dorado `#FFB300` | 🤖 | ApliMemo (Asistente Cognitivo de Bolsillo) |

---

## 🏗️ Patrón estándar por app

Cada app del ecosistema sigue este patrón:
1. **Landing** (Flutter Web + Firebase Hosting)
2. **Blog** (Blogger, ya existente)
3. **App** (móvil: Flutter/Dart, pub en Play Store / App Store)

La web principal (erbolamm-com) es la excepción: React + Vite (no Flutter).

---

## 📚 Archivos clave del proyecto que debes conocer

| Archivo | Qué contiene | Prioridad de lectura |
|---------|-------------|---------------------|
| `ESTADO.md` | Estado completo del proyecto, tareas pendientes, decisiones | 🔴 LEE PRIMERO |
| `universe.json` | Base de datos de todos los proyectos (fuente de verdad) | 🔴 LEE SEGUNDO |
| `ANALIZAR_AQUI.md` | Este archivo — instrucciones de análisis | 🟡 Ya lo estás leyendo |
| `lib/main.dart` | Entry point Flutter | 🟢 Solo si vas a tocar código |
| `lib/config/app_config.dart` | Configuración central | 🟢 Solo si vas a tocar código |
| `README.md` | Documentación principal | 🟢 Solo si vas a tocar código |
