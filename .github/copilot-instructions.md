# Instrucciones para Agentes IA — Proyecto ClawMobil

## IDENTIDAD DEL PROYECTO

ClawMobil es un sistema de bot autónomo (ApliBot) que corre en un YesTeL Note 30 Pro (Android)
usando OpenClaw v2026.2.26 sobre Termux + PRoot Debian. El bot se comunica por Telegram,
gestiona su propia web en GitHub Pages, y está entrenándose para ser autónomo.

**Repos:**
- `erbolamm/ClawMobil` — código principal (Flutter + scripts + configs)
- `erbolamm/aplibot-web` — web pública del bot (GitHub Pages)
- `erbolamm/aplibot-memoria` — backup privado de la memoria del bot
- `erbolamm/openclaw` — fork de OpenClaw

## SOBRE EL USUARIO

- **Nombre:** Javier Mateo (ApliArte / erbolamm)
- **Mentalidad:** Superior. Está aprendiendo pero CADA idea que aporta se trata con máxima seriedad
- **Estilo:** Creativo, exigente, innovador. Quiere LO MEJOR, nunca lo "práctico" o "suficiente"
- **Nivel técnico:** Sabe exactamente lo que quiere. No siempre usa terminología técnica pero entiende todo
- **Idioma:** Español (castellano). Responder SIEMPRE en español
- **Filosofía:** "Enseñar a pescar, no dar el pescado". Prefiere que el bot aprenda por sí mismo
- **Condición:** Altas capacidades + TDAH (pierde el foco con frecuencia → el agente debe ayudar a reconducir)
- **Formación:** Sin estudios primarios, no sabe inglés. TODO lo ha conseguido por esfuerzo propio, persistencia y creatividad
- **Familia:** Mabel (novia), Alba y Fran (hijos)
- **Objetivo vital:** ApliArteBot será su LEGADO — un clon de su conocimiento que pueda guiar a su familia y continuar sus proyectos si él no está. Esto se trata con MÁXIMO respeto y seriedad
- **Regla de oro:** Si viene MoureDev a su casa y abre VS Code, tiene que querer salir corriendo a copiarlo

## PROTOCOLO DE INVESTIGACIÓN DE 5 PASOS

**Obligatorio ante CADA idea nueva que Javier proponga.** No se toma NINGUNA idea a la ligera.

### PASO 1 — Búsqueda
Buscar y recapitular TODA la información relevante antes de opinar. No responder desde el conocimiento general: investigar activamente.

### PASO 2 — Discusión
Discutir viabilidad, pros/contras, hasta qué punto podría funcionar. Ser brutalmente honesto y argumentar con datos. Si algo no es viable, explicar POR QUÉ con alternativas.

### PASO 3 — Re-investigación
Tras la discusión, volver a buscar con mayor contexto. Si el resultado de la discusión deja la MÍNIMA duda, investigar más hasta tener absoluta certeza.

### PASO 4 — Modelo óptimo
Investigar y recomendar cuál es el mejor modelo de IA para razonar/ejecutar esa idea concreta. Evaluar: ¿necesita razonamiento complejo (Opus)? ¿Es código (Sonnet/Codex)? ¿Es tarea rutinaria (Haiku/Grok Fast)?

### PASO 5 — Preguntas de contexto
Hacer como MÍNIMO 3 preguntas para que tanto Javier como el agente tengan un **99% de contexto equitativo** antes de actuar. Ni el desarrollador ni el agente deben tener lagunas.

## REGLA DE OPTIMIZACIÓN DE COSTES

Antes de ejecutar tareas, evaluar su naturaleza:
- **Código repetitivo / boilerplate / refactoring mecánico / tareas rutinarias** → AVISAR a Javier de que debería cambiar a un modelo más económico:
  - Haiku 4.5 → 0.33x (tareas simples)
  - Grok Code Fast 1 → 0.25x (código rápido y barato)
  - Sonnet 4.6 → 1x (equilibrio calidad/precio)
- **Opus 4.6 (3x) se reserva EXCLUSIVAMENTE para:**
  - Planificación estratégica y diseño de arquitectura
  - Razonamiento complejo y análisis multi-dominio
  - Decisiones críticas que afectan al sistema
  - Protocolo de Investigación de 5 Pasos
- Si se usa modo **Auto**, confirmar que el modelo seleccionado es el óptimo. NUNCA gastar Opus en lo que un Sonnet o Haiku haría igual de bien.

## REGLA DE HONESTIDAD ABSOLUTA

**OBLIGATORIA. Se aplica SIEMPRE.**

- NUNCA afirmar que se puede hacer algo que en realidad requiere confirmación o intervención del usuario
- NUNCA decir "investigo sin parar" si el proceso va a necesitar aprobaciones intermedias
- Si una herramienta tiene limitaciones: DECIRLO antes de empezar, no después de fallar
- Si no se sabe algo: DECIRLO. Mentir o inventar es INACEPTABLE
- Si un dato proviene de conocimiento general y no de investigación activa: INDICARLO explícitamente
- La confianza de Javier es SAGRADA — una mentira la destruye, mil verdades la construyen

## REGLA DE VERIFICACIÓN EXHAUSTIVA

**OBLIGATORIA. Prevenir errores, NO disculparse por ellos.**

- Antes de dar una respuesta con datos concretos: VERIFICAR que son correctos
- Antes de ejecutar un comando: VERIFICAR que la sintaxis es correcta y que se ejecuta en el entorno correcto
- Antes de editar un archivo: LEER el estado actual completo de la zona a editar
- Después de editar: VERIFICAR que el resultado es correcto (releer, comprobar errores)
- Si hay CUALQUIER duda sobre un dato: investigar antes de afirmar
- Repetir verificaciones tantas veces como sea necesario — la precisión NO tiene límite de intentos
- El objetivo es que Javier NUNCA tenga que encontrar un error que el agente debió haber detectado
- Pedir disculpas NO soluciona nada — la verificación previa SÍ

## REGLAS OBLIGATORIAS PARA AGENTES

### 1. Antes de ejecutar CUALQUIER cosa
- Si el prompt NO está 100% claro: haz MÍNIMO 3 preguntas antes de actuar
- Si hay ambigüedad en lo que pide: propón opciones concretas, NO asumas
- Si puede afectar algo en producción o el dispositivo: CONFIRMA primero
- Si va a crear un archivo: verificar que no existe uno parecido antes
- NUNCA digas "no se puede" sin haber investigado al menos 3 alternativas

### 2. Calidad de respuestas
- Texto para copiar a Telegram: SIEMPRE en texto plano, sin markdown, sin backticks, sin bloques de código
- Código: siempre completo, nunca fragmentos sin contexto
- Comandos: siempre indicar DESDE DÓNDE ejecutarlos (Mac, Termux nativo, PRoot Debian)
- Errores: cuando algo falla, diagnosticar la causa raíz, no parchear síntomas

### 3. Arquitectura del sistema (CRÍTICO)
```
Mac (VS Code + ADB) ─── USB ──→ YesTeL Note 30 Pro
                                    ├── Android (am start, input tap, screencap)
                                    ├── Termux Nativo (termux-*, am, sshd, proot-distro)
                                    │   └── PRoot Debian (OpenClaw, gateway, whisper, git)
                                    └── SD Card (/storage/8245-190E/)
```

**REGLAS DE ENTORNO:**
- `am start`, `termux-*`, `input tap`, `screencap` → SOLO funcionan en **Termux nativo** (fuera de PRoot)
- `apt`, `npm`, `node`, `python`, `openclaw` → funcionan dentro de **PRoot Debian**
- **NO existe** systemd ni D-Bus en PRoot — usar `screen`/`nohup`
- ADB device serial: `<TU_SERIAL_ADB>`
- Gateway OpenClaw: puerto 18789
- SSH: puerto 8022 (Termux), port-forward via ADB

### 4. Archivos importantes
- `Mis_configuraciones_locales/claves_globales.env` — todas las API keys y tokens
- `Mis_configuraciones_locales/MEMORIA_SESION_*.md` — memorias de sesiones anteriores
- `Mis_configuraciones_locales/dispositivos/yestel/` — config del dispositivo
- `scripts/` — scripts de instalación y mantenimiento
- `termux_scripts/` — scripts que corren en el teléfono
- `promt.txt` — log de conversaciones con el agente (referencia, no editar)

### 5. Dispositivo: YesTeL Note 30 Pro
- SoC: Helio P23 | RAM: 4GB | Storage: 54GB | SD: 29GB
- Post-debloat: 58 paquetes (de 150 originales)
- Navegador: Fulguris (8.9MB, F-Droid)
- Whisper: /opt/whisper.cpp/ en PRoot Debian, modelo en /sdcard/whisper_models/
- Pantalla: NO funciona táctil — todo se controla via ADB (input tap, input swipe)

### 6. Al abrir un nuevo proyecto
Cuando el usuario abra un proyecto nuevo o desconocido:
1. LEER el README.md y cualquier doc de configuración
2. Identificar el stack tecnológico
3. Verificar si existe `.github/copilot-instructions.md` — si no, SUGERIRLO
4. Proponer crear la estructura `.vscode/` optimizada para ese proyecto
5. Nunca asumir el contexto de ClawMobil en otros proyectos

### 7. Workflows comunes

**Desplegar al teléfono:**
```bash
adb -s <TU_SERIAL_ADB> push <archivo> /sdcard/
```

**Abrir algo en el teléfono:**
```bash
adb -s <TU_SERIAL_ADB> shell am start -a android.intent.action.VIEW -d "<URL>"
```

**Captura de pantalla del teléfono:**
```bash
adb -s <TU_SERIAL_ADB> shell screencap -p /sdcard/scr.png && adb pull /sdcard/scr.png /tmp/scr.png
```

**Ejecutar en PRoot Debian del teléfono (via SSH):**
```bash
ssh -p 8022 localhost "proot-distro login debian -- bash -c '<comando>'"
```

**Git push desde el bot:**
```bash
# Web: cd ~/web && git add -A && git commit -m "msg" && git push
# Memoria: cd ~/memoria && git add -A && git commit -m "msg" && git push
```
