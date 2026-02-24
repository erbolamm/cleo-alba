# 📖 Guía Maestra de Usuario: ClawMobil

¡Felicidades! Tienes en tus manos un nodo funcional de **ClawMobil**. Este manual te enseñará a dominarlo por completo.

## 🚀 Inicio Rápido
1. Abre la App **ClawMobil** en tu dispositivo.
2. Asegúrate de que el icono de red esté en verde (indica conexión con Groq/ElevenLabs).
3. Di "Hola Bot" para empezar.

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

## 🔧 Solución de Problemas
- **El bot no me oye**: Verifica los permisos de micrófono en Android.
- **Voz robótica**: Asegúrate de tener saldo en ElevenLabs o revisa la conexión a internet.
- **El panel web no carga**: Asegúrate de que el dispositivo y tu PC están en la misma red WiFi.

---
*Este proyecto es parte del movimiento Open Source para dar nueva vida al hardware vintage. Gracias por ser parte de ApliArte.*
