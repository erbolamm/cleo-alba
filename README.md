# ClawMobil 🦞

Convierte cualquier teléfono Android antiguo en un **servidor de IA personal** con [OpenClaw](https://github.com/erbolamm/openclaw). Sin cloud. Sin suscripciones. Tu propio cerebro digital de bolsillo.

**Web**: [ApliArte.com](https://apliarte.com) · **#ClawMobil**

---

## 🍜 Filosofía: El Wok

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
