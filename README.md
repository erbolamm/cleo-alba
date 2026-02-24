# ClawMobil 🦞

Convierte cualquier teléfono Android antiguo en un **servidor de IA personal** con [OpenClaw](https://github.com/erbolamm/openclaw). Sin cloud. Sin suscripciones. Tu propio cerebro digital de bolsillo.

**Web**: [ApliArte.com](https://apliarte.com) · **#ClawMobil**

---

## 🍜 Filosofía: El Wok

Este proyecto funciona como un **self-service**: tú descargas el proyecto (el buffet), creas tu carpeta personal, y vas cogiendo lo que necesitas — sin tocar nada del proyecto en sí.

| Carpeta | Qué es | ¿Se modifica? |
|---|---|---|
| `scripts/` | Scripts de instalación por pasos | ❌ No |
| `termux_scripts/` | Scripts que se suben al Android | ❌ No |
| `config/` | Plantilla de configuración | ❌ No (copiar y personalizar) |
| `empezar.html` | Generador de prompts de despliegue | ❌ No |
| **`Mis_configuraciones_locales/`** | **Tu bandeja personal** | ✅ Sí, solo esta |

> **Regla de oro**: si necesitas guardar una clave, un log, una nota, o cualquier cosa específica de tu setup → va dentro de `Mis_configuraciones_locales/`. El resto del proyecto se queda intacto.

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
3. Abre **`empezar.html`** en tu navegador.
4. Genera el prompt y pégalo en tu IDE con IA (Cursor, Windsurf, Gemini, etc.).
5. Tu asistente IA ejecutará los scripts automáticamente.

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
├── scripts/                  ← Scripts de instalación (01.sh → 16.sh)
├── termux_scripts/           ← Scripts que se suben al dispositivo
├── config/                   ← Plantilla de configuración
├── lib/                      ← App Flutter (cliente)
├── Mis_configuraciones_locales/  ← 🔒 TU carpeta (gitignored)
│   ├── claves_globales.env
│   └── dispositivos/
│       ├── _plantilla/       ← Copia esto para cada nuevo dispositivo
│       └── tu_dispositivo/
│           ├── claves.env    ← Tus API keys
│           ├── notas.md      ← Estado y documentación
│           └── ...
```

## 💖 Apoya el proyecto

Si ClawMobil te resulta útil, comparte tu experiencia en redes con **#ClawMobil** etiquetando a **@erbolamm**.

- **PayPal**: [paypal.me/erbolamm](https://www.paypal.com/paypalme/erbolamm)
- **Ko-fi**: [![Ko-fi](https://storage.ko-fi.com/cdn/kofi5.png?v=6)](https://ko-fi.com/C0C11TWR1K)

## 🛡️ Licencia

© 2026 [ApliArte](https://apliarte.com). Código abierto.
¡Transforma tus antiguos móviles en servidores IA!

---
**Hecho con ❤️ por [ApliArte](https://apliarte.com)** · [@erbolamm](https://github.com/erbolamm)
