# 🗺️ ClawMobil — Roadmap

## Estado actual (v1.0)
- ✅ Panel de control con estado de servicios
- ✅ Comandos Termux copiables
- ✅ SmartDisplay local (WebView)
- ✅ Backup/restore de configuraciones
- ✅ OpenClaw como motor de IA (chat + búsqueda web + memoria)
- ✅ STT con Groq Whisper

## Próximas mejoras

### 🔗 Integración Notion (Prioridad: Alta)
Sincronizar tareas y proyectos entre el bot y Notion.
- Evaluar Notion API para lectura/escritura
- Crear bridge de datos OpenClaw ↔ Notion

### 📊 n8n → Telegram (Prioridad: Alta)
Alarmas, recordatorios y agenda gestionadas por n8n (Hostinger):
- Cron diarios (agenda del día)
- Recordatorios de tareas pendientes
- Reportes semanales automáticos

### 🧠 Memoria por proyectos (Prioridad: Alta)
Que el bot organice su memoria por proyecto:
- 53 grupos de carnaval
- 32+ apps nocode → Flutter
- Proyectos personales
- Gestión de publicidad (AdSense, AdMob, etc.)

### 📺 SmartDisplay en Hostinger (Prioridad: Media)
API Docker en VPS para display web embebible en Blogger:
- Endpoint POST/GET para texto
- Widget HTML para gadget Blogger
- Siempre activo, independiente del móvil

### 🔊 Audio TTS configurable (Prioridad: Baja)
Opción para usuarios que quieran TTS por altavoz:
- Activable/desactivable por dispositivo
- Compatible con ElevenLabs y alternativas locales

### 📱 SmartDisplay local como opción (Prioridad: Baja)
Para usuarios con monitor/TV en tienda:
- Modo quiosco con texto personalizable
- Control desde el panel de la app

### 💰 Gestión de publicidad (Prioridad: Futura)
Cuando el bot esté entrenado:
- AdSense, AdMob, Google Ads, Apple Ads
- Gestión de suscripciones
- Reportes por voz

### 🔄 Backup automático (Prioridad: Media)
Bot recuerda hacer backup, usuario lo ejecuta con cable:
- Recordatorio periódico vía n8n
- Script de backup completo
- Nunca automático (siempre supervisado)
