# 📖 Guía Maestra de Usuario: ClawMobil

¡Felicidades! Tienes en tus manos un nodo funcional de **ClawMobil**. Este manual te enseñará a dominarlo por completo.

## 🚀 Inicio Rápido
1. En tu ordenador, abre `index.html` para seguir el flujo guiado sin programar.
2. Desde `index.html`, abre `empezar.html` y genera tu `config_profile.json`.
3. Ejecuta los comandos sugeridos del wizard para activar tu dispositivo local.
4. En la app ClawMobil, verifica que el icono de red esté en verde y di "Hola Bot".

## 🎙️ Modos de Escucha
- **Modo Manual (Pulse & Speak)**: Pulsa el icono del micro, habla, y pulsa de nuevo. Ideal para entornos ruidosos.
- **Modo Auto-Interact**: Actívalo en el menú lateral. El bot detectará el fin de tus frases automáticamente. *Tip: Úsalo cuando estés concentrado trabajando.*

## 👁️ Eye-Tracking & Presencia
Tu bot no solo te escucha, te **mira**:
- **Cara de Despierto**: Te ha detectado y está listo para la acción.
- **Cara de Sueño / Parpadeo**: Está en modo ahorro. Míralo directamente para que se active.
- **Neon Glow**: El color de su cara indica su estado:
    - **Azul**: Escuchando / Idle.
    - **Púrpura**: Pensando (Llamando a Groq).
    - **Verde**: Hablando (TTS activo).

## 🛠️ Mission Control (Dashboard)
Desde cualquier navegador en tu red local, entra en:
`http://[IP-DEL-MÓVIL]:8080`
- **Dashboard Inteligente**: Verás la batería del dispositivo y si servicios como OpenClaw o WakeLock están activos.
- **Consola de Comandos**: Copia y pega comandos de emergencia si algo falla.

## 🐞 El Sistema de Reportes "Hitos"
Hemos diseñado este bot para que aprenda de su propia creación. 
- Cuando el bot detecte una configuración exitosa o un error raro, te pedirá permiso para generar un reporte.
- Ve a **Ajustes > 🐞 Reportar Hito/Error**.
- El bot generará un archivo Markdown con logs y contexto.
- **Copia y envía a info@apliarte.com**. ¡Esto ayuda a construir la Factory!

## 🧩 Modo Modular por Dispositivo
Para crear un clon/fork con límites propios por dispositivo:
1. Abre `index.html` y entra a `empezar.html`.
2. Genera `config_profile.json` para tu dispositivo.
3. Guarda el dispositivo activo en `Mis_configuraciones_locales/dispositivos/.active_device`.
4. Ejecuta:
   - `bash scripts/local_config_select.sh --json`
   - `bash scripts/local_config_evaluate.sh`
   - `bash scripts/local_config_discovery.sh`
5. Si una mejora local sirve para todos, promuévela con:
   - `bash scripts/local_config_promote.sh <dispositivo> <ruta_relativa>`

## 🔧 Solución de Problemas
- **El bot no me oye**: Verifica los permisos de micrófono en Android.
- **Voz robótica**: Asegúrate de tener saldo en ElevenLabs o revisa la conexión a internet.
- **El panel web no carga**: Asegúrate de que el dispositivo y tu PC están en la misma red WiFi.

---
*Este proyecto es parte del movimiento Open Source para dar nueva vida al hardware vintage. Gracias por ser parte de ApliArte.*
