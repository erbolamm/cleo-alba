# PLAN INTEGRAL — Ecosistema de 3 Bots ApliArte

**Fecha:** 3 de marzo de 2026
**Autor:** Javier Mateo (ApliArte) + Copilot (Opus 4.6)
**Estado:** PLAN ESTRATÉGICO — requiere validación antes de implementar

---

## VISIÓN GENERAL

Tres bots de Telegram que trabajan juntos en un grupo compartido, cada uno con un rol específico. Se comunican entre ellos y con Javier desde cualquier lugar (móvil directo a @ApliArteBot, escritorio al grupo donde están los 3).

```text
┌─────────────────────────────────────────────────────┐
│            GRUPO TELEGRAM (los 3 bots)              │
│                                                     │
│  @ApliArteBot     @ApliMobilBot    @AutApliArteBot  │
│  (El Legado)      (Control Móvil)  (Automatizador)  │
│       │                │                 │          │
│       ▼                ▼                 ▼          │
│   VPS Docker      YesTeL Phone      VPS n8n         │
│   (OpenClaw)      (OpenClaw)        (ya existe)     │
└─────────────────────────────────────────────────────┘
```

---

## BOT 1: @ApliArteBot — EL LEGADO

### Misión
Clon del conocimiento de Javier Mateo. Asistente personal, coach, guardián de la familia. Si Javier no está, este bot guía a Mabel, Alba y Fran.

### Ubicación
**VPS Docker (Hostinger)** — uptime 24/7, independiente del teléfono

### Motor
**OpenClaw** (fork erbolamm/openclaw) desplegado en Docker junto al stack existente (n8n, Portainer, Uptime Kuma, Nginx Proxy Manager)

### Funcionalidades

#### A. Coach Proactivo (TDAH + 7 Hábitos + PNL)

- **Bloqueo progresivo si Javier pierde el foco:**
  - 1ª vez → advertencia amable + reconducción
  - 2ª vez → bloqueo de 1 hora (no responde excepto emergencias)
  - 3ª vez → bloqueo de 3 horas
  - 4ª+ → escalada a bloqueo de día/semana con notificación a Telegram
- **NO tolera mediocridad:** si Javier dice "ya está bien así", el bot desafía con alternativas mejores
- **Planificación semanal:** propone horario basado en ventana productiva (21:00–02:00)
- **Recordatorios contextuales:** sabe que Javier cuida niños de día, madre de Mabel, etc.

#### B. Memoria y Legado

- **Backup automático** a erbolamm/aplibot-memoria (GitHub privado)
- **Contexto persistente:** recuerda sesiones anteriores, decisiones, razones
- **Base de conocimiento indexada:** todo lo que Javier sabe sobre código, negocios, apps
- **Modo familia:** Mabel → Alba → Fran pueden preguntar y recibir guía personalizada
  - Contacto emergencia: <<EMAIL_EMERGENCIA>>
  - Google Inactive Account Manager ya configurado (3-6 meses → Mabel)

#### C. Experto en Prompts

- Ayuda a Javier a formular prompts óptimos para cualquier IA
- Sugiere qué modelo usar para cada tarea (Opus/Sonnet/Haiku/Grok)
- Traduce intenciones en español a prompts técnicos

#### D. Creador de Contenido

- Asiste con textos para apps (CalcaApp, MeLlaman, InEmSellar, Afinar guitarra con oídos)
- Redacta posts para redes
- Prepara guiones para directos/streaming

#### E. Investigador

- Brave Search integrado (key: TU_BRAVE_KEY_AQUI)
- Analiza competencia, mercado, tendencias
- Protocolo de Investigación de 5 Pasos aplicado a todo

### Configuración OpenClaw necesaria

```yaml
# .openclaw/config.yaml (en el VPS)
telegram:
  token: TU_TELEGRAM_TOKEN_AQUI
  allowed_users: [TU_ID_AQUI]   # Javier
  # Modo familia: añadir IDs de Mabel cuando esté listo

providers:
  - name: groq
    api_key: TU_GROQ_KEY_AQUI
    model: llama-3.1-8b-instant
  - name: gemini
    api_key: TU_GEMINI_KEY_AQUI
  - name: deepseek
    api_key: TU_DEEPSEEK_KEY_AQUI
  - name: cerebras
    api_key: TU_CEREBRAS_KEY_AQUI

memory:
  plugin: github  # o file-based, según lo que OpenClaw soporte
  repo: erbolamm/aplibot-memoria

tools:
  web_search: true
  brave_api_key: TU_BRAVE_KEY_AQUI
```

### Docker (añadir al docker-compose.yml de DockerHostinger)
```yaml
  apliarte-bot:
    image: openclaw:local  # o build desde el fork
    environment:
      HOME: /home/node
      TERM: xterm-256color
      OPENCLAW_GATEWAY_TOKEN: ${APLIARTE_GATEWAY_TOKEN}
    volumes:
      - ./apliarte-bot-config:/home/node/.openclaw
      - ./apliarte-bot-workspace:/home/node/.openclaw/workspace
    ports:
      - "18791:18789"  # Puerto diferente al OpenClaw del teléfono
    restart: unless-stopped
    command: ["node", "dist/index.js", "gateway", "--bind", "lan", "--port", "18789"]
    networks:
      - proxy-network
```

---

## BOT 2: @ApliMobilBot — CONTROL MÓVIL

### Misión
Controlador del parque de teléfonos. Ejecuta comandos en el dispositivo, gestiona streaming/directos, monitoriza hardware.

### Ubicación
**YesTeL Note 30 Pro** (y futuros dispositivos) — OpenClaw en PRoot Debian via Termux

### Motor
**OpenClaw** (el mismo fork, ya parcialmente instalado en el teléfono)

### Funcionalidades

#### A. Control del Dispositivo
- Ejecutar comandos via bridge scripts (ya creados en scripts/bridge_scripts/):
  - `hablar.sh` — TTS
  - `abrir_web.sh` — abrir URLs en Fulguris
  - `captura.sh` — screenshot via ADB
  - `foto.sh` — cámara
  - `grabar.sh` — grabar audio/video
  - `notificar.sh` — notificaciones
  - `vibrar.sh` — vibración
  - `bateria.sh` — estado batería
  - `linterna.sh` — encender/apagar linterna
- Telefonía: `termux-telephony-call`, `termux-sms-send` (SOLO Termux nativo)
- Navegación: `am start -a android.intent.action.VIEW -d "URL"`

#### B. Streaming / Directos
- Gestión del estado de directos (start/stop/pause)
- Captura de pantalla automática durante streaming
- Integración con @AutApliArteBot (N8n_directo:) para cambios de estado

#### C. Monitorización de Hardware
- Estado de batería, RAM, almacenamiento
- Alertas automáticas si batería <15% o temperatura >45°C
- Diagnóstico de salud del dispositivo

#### D. Whisper (Transcripción de Audio)
- Modelo: `/sdcard/whisper_models/ggml-base.bin`
- Binario: `/opt/whisper.cpp/build/bin/whisper-cli` (PRoot Debian)
- PENDIENTE: instalar ffmpeg + convertir OGG→WAV (instrucciones ya enviadas al bot)

### Reglas de Seguridad (CRÍTICAS)
- **NUNCA** insertar SIM en ningún teléfono del parque
- **NUNCA** iniciar sesión con cuentas reales (Google, etc.)
- **SOLO WiFi** — sin datos móviles
- **ApliArteBot debe recordar** estas reglas periódicamente

### Arquitectura en el Teléfono
```
YesTeL Note 30 Pro (Android)
├── Termux Nativo
│   ├── sshd (puerto 8022)
│   ├── bridge scripts (termux-*, am start, screencap)
│   └── proot-distro
│       └── Debian
│           ├── OpenClaw gateway (puerto 18789)
│           ├── whisper.cpp
│           ├── ffmpeg (PENDIENTE)
│           ├── git (repos ~/web, ~/memoria)
│           └── markitdown
└── SD Card (/storage/8245-190E/)
    └── whisper_models/, carpeta_capturas/, etc.
```

### Configuración OpenClaw (en el teléfono)
```
# Ya existe parcialmente en ~/.openclaw/
telegram:
  token: TU_TELEGRAM_TOKEN_AQUI
  allowed_users: [TU_ID_AQUI]
```

> **RESUELTO:** Token `<ID_BOT_APLIARTE>` va para @ApliArteBot (regenerado en BotFather). @ApliMobilBot tiene token nuevo: `<ID_BOT_APLIMOBIL>`.

---

## BOT 3: @AutApliArteBot — AUTOMATIZADOR

### Misión
Mano derecha de automatizaciones. Ejecuta flujos n8n mediante comandos de texto simples con prefijo. Monitoriza servicios. Publica contenido programado.

### Ubicación
**VPS Docker (Hostinger)** — n8n (ya funcionando parcialmente)

### Motor
**n8n** puro (NO OpenClaw). Trigger: Telegram → Switch por prefijo → acción.

### Funcionalidades (comandos actuales y planificados)

#### Comandos YA implementados
| Comando | Acción | Estado |
|---------|--------|--------|
| `N8n_display:` | Publica contenido con imagen a canal/grupo | ✅ Funcionando |

#### Comandos PLANIFICADOS
| Comando | Acción | Prioridad |
|---------|--------|-----------|
| `N8n_status:` | Cambia estado de algo (streaming, servicio, etc.) | Alta |
| `N8n_directo:` | Gestión de directos (start/stop/schedule) | Alta |
| `N8n_correo:` | Envía email via SMTP (<TU_EMAIL_GIT>) | Alta |
| `N8n_monitor:` | Consulta estado de Uptime Kuma (7 monitores) | Media |
| `N8n_deploy:` | Despliega/actualiza servicio en Docker | Media |
| `N8n_backup:` | Fuerza backup de memoria/web a GitHub | Media |
| `N8n_post:` | Publica en blog/redes programado | Media |
| `N8n_stats:` | Estadísticas de uso de los bots | Baja |
| `N8n_alert:` | Configura alertas personalizadas | Baja |

#### Automatizaciones sin comando (programadas)
- **Cron:** Post automático semanal en redes (Tutograti, CalcaApp, etc.)
- **Monitor:** Alerta si algún servicio cae (Uptime Kuma → Telegram grupo `<ID_GRUPO_TELEGRAM>`)
- **Backup:** Backup diario de memoria a GitHub a las 04:00
- **Health:** Ping diario al teléfono (verificar que @ApliMobilBot responde)

### Arquitectura n8n (ya en docker-compose del VPS)
```
Telegram Trigger (@AutApliArteBot)
    │
    ▼
Switch (mode: Rules, por prefijo del texto)
    ├── N8n_display: → Nodo HTTP/Telegram → publica contenido
    ├── N8n_status:  → Nodo Function → cambia estados
    ├── N8n_directo: → Nodos combinados → gestión de directo
    ├── N8n_correo:  → Nodo Email (SMTP Gmail) → envía correo
    ├── N8n_monitor: → Nodo HTTP → consulta Uptime Kuma API
    ├── N8n_deploy:  → Nodo SSH/Docker → despliega servicio
    ├── N8n_backup:  → Nodo Git → push a repos
    └── default      → Responde "Comando no reconocido"
```

### SMTP ya configurado
```
Host: smtp.gmail.com
Puerto: 587
User: <TU_EMAIL_GIT>
Pass: <TU_GMAIL_APP_PASSWORD>
```

---

## COMUNICACIÓN ENTRE BOTS

Los 3 bots conviven en el grupo de Telegram (ID: `<ID_GRUPO_TELEGRAM>`). La comunicación es via mensajes de texto en el grupo.

### Flujos de comunicación

```
@ApliArteBot ──"N8n_display: Nuevo post CalcaApp..."──→ @AutApliArteBot
    (pide publicar)                                      (ejecuta en n8n)

@ApliMobilBot ──"batería 12%"──→ @ApliArteBot
    (alerta)                       (decide acción)

@ApliArteBot ──"captura pantalla"──→ @ApliMobilBot
    (pide)                            (ejecuta en teléfono)

@AutApliArteBot ──"servicio n8n caído"──→ @ApliArteBot
    (monitoriza)                           (notifica a Javier)
```

### Regla clave
- **Javier desde móvil** → habla directo con @ApliArteBot (1 a 1)
- **Javier desde escritorio** → usa el grupo donde están los 3
- **Los bots entre sí** → se hablan en el grupo usando prefijos reconocibles

---

## ORDEN DE IMPLEMENTACIÓN

### FASE 1 — @ApliArteBot (PRIORIDAD MÁXIMA)
1. Crear token con @BotFather para @ApliArteBot (o confirmar cuál de los 3 tokens ya creados le corresponde)
2. Buildear OpenClaw desde el fork erbolamm/openclaw en Docker
3. Configurar providers (Groq + Gemini + DeepSeek + Cerebras)
4. Configurar memoria persistente (GitHub aplibot-memoria)
5. Configurar búsqueda web (Brave Search)
6. Implementar sistema prompt del bot (personalidad, reglas, coach mode)
7. Deploy en docker-compose junto al stack existente
8. Configurar Uptime Kuma para monitorizar
9. Test exhaustivo

### FASE 2 — @ApliMobilBot (después de Fase 1)
1. Decidir token (reusar el actual `<ID_BOT_APLIARTE>` o crear nuevo)
2. Reset YesTeL + reinstalar Termux + PRoot Debian
3. Instalar OpenClaw desde el fork
4. Configurar bridge scripts
5. Instalar ffmpeg + arreglar Whisper
6. Completar los 8 bloques de práctica del ROADMAP
7. Test de control remoto desde Mac via ADB

### FASE 3 — @AutApliArteBot (en paralelo con Fase 2)
1. Completar las routing rules que faltan en n8n
2. Implementar N8n_correo (SMTP ya configurado)
3. Implementar N8n_monitor (Uptime Kuma API)
4. Implementar N8n_backup (git push programado)
5. Implementar N8n_directo (gestión streaming)
6. Configurar crons automáticos
7. Test de comunicación entre los 3 bots en el grupo

### FASE 4 — Integración completa
1. Los 3 bots en el grupo de Telegram
2. Test de comunicación inter-bot
3. Implementar modo familia en @ApliArteBot
4. Documentar todo en aplibot-memoria
5. Configurar Google Inactive Account Manager activado

---

## RECURSOS NECESARIOS

### Tokens de Telegram (3 en total)
| Bot | Token | Ubicación |
|-----|-------|--------|
| @ApliArteBot | `TU_TOKEN_REDACTADO` | VPS Docker (OpenClaw) |
| @aplimobilbot | `TU_TOKEN_REDACTADO` | YesTeL (OpenClaw) |
| @AutApliArteBot | `TU_TOKEN_REDACTADO` | VPS n8n |

### Providers de IA
| Provider | Modelo | Uso principal |
|----------|--------|---------------|
| Groq (8 keys) | llama-3.1-8b-instant | Conversación rápida, tareas rutinarias |
| Cerebras | llama-3.3-70b | Razonamiento más profundo |
| DeepSeek | deepseek-chat | Código y análisis |
| Gemini (4 keys) | gemini-2.0 | Multimodal (imágenes, audio) |
| Ollama | phi3:mini | Offline/local (cuando esté) |

### Infraestructura
| Componente | Ubicación | Estado |
|------------|-----------|--------|
| VPS Hostinger | Docker stack | ✅ Funcionando |
| n8n | VPS :5678 | ✅ Funcionando (98.32% uptime) |
| Portainer | VPS | ✅ Funcionando (98.7% uptime) |
| Uptime Kuma | VPS | ✅ Funcionando |
| Nginx Proxy Manager | VPS | ✅ Funcionando (98.43% uptime) |
| YesTeL Note 30 Pro | Local (USB→Mac) | ⚠️ Necesita reset tras crash |
| Huawei P10 | Local | ⚠️ Necesita reset y revaluación |

---

## COSTES DE DESARROLLO (modelos IA recomendados)

| Tarea | Modelo recomendado | Coste |
|-------|-------------------|-------|
| Este plan + diseño de arquitectura | Opus 4.6 | 3x ✅ justificado |
| Escribir docker-compose + configs | Sonnet 4.6 | 1x |
| Implementar bridge scripts | Haiku 4.5 o Grok Fast | 0.25-0.33x |
| Configurar n8n workflows | Sonnet 4.6 | 1x |
| Prompt engineering del bot | Opus 4.6 | 3x (es estratégico) |
| Debug/troubleshooting | Sonnet 4.6 | 1x |
| Documentación | Haiku 4.5 | 0.33x |

---

## PREGUNTAS PENDIENTES PARA JAVIER

1. ~~¿Cuáles son los 3 tokens?~~ ✅ RESUELTO (3 de marzo 2026)
2. ~~¿El token actual se reasigna?~~ ✅ RESUELTO — `<ID_BOT_APLIARTE>` → @ApliArteBot (regenerado)
3. **¿El teléfono YesTeL ya se reseteó o sigue sin funcionar tras el crash?**
4. **¿Empezamos hoy con @ApliArteBot en el VPS?**
