# Tutorial: Cómo usar ApliArteBot

Tu asistente personal en Telegram. Guía paso a paso.

---

## Qué es ApliArteBot

ApliArteBot es tu asistente personal que vive en Telegram. Es un bot de inteligencia artificial que:

- Habla contigo en español
- Busca cosas en internet por ti
- Te ayuda a mantener el foco (coach TDAH)
- Guarda tus ideas y memorias
- Conoce a tu familia y adapta su trato a cada uno
- Es tu legado digital para Mabel, Alba y Fran

No es un chatbot cualquiera. Tiene TU personalidad configurada, TUS reglas, y TU filosofía. Si alguien le pregunta quién eres, sabe responder con todo detalle.

---

## Cómo hablar con el bot

### En privado (DM)
Simplemente escríbele como si hablaras con un asistente. No hace falta ningún comando especial.

Ejemplos:
- "Busca información sobre cómo monetizar una app en Google Play"
- "¿Qué decíamos ayer sobre el proyecto de CalcaApp?"
- "Necesito organizar mis tareas para esta noche"

### En el grupo de los 3 bots
En el grupo tienes que mencionarlo: @ApliArteBot seguido de lo que quieras.

Ejemplo:
- "@ApliArteBot ¿cuál es el estado del proyecto?"

### Con audio
Puedes enviarle una nota de voz y la transcribe automáticamente. Muy útil cuando no puedes escribir.

---

## Los comandos slash

Los comandos empiezan por / y aparecen en el menú de Telegram (el botón de la esquina inferior izquierda).

### /help
Te muestra qué comandos hay disponibles. Útil si no recuerdas alguno.

### /status
Te dice cómo está el bot: si está conectado, qué modelo usa, cuánto lleva la sesión actual.

### /coach
Activa o desactiva el modo coach. Cuando está activo, el bot te vigila para que no pierdas el foco. Si empiezas a desviarte del tema, te avisa. Si sigues, te bloquea temporalmente (excepto emergencias familiares).

Cuándo usarlo:
- Cuando te sientas disperso y necesites estructura
- Durante tu ventana productiva (21:00 a 02:00)
- Cuando tengas una tarea importante que terminar

### /familia
Cambia el modo de interacción para que otro miembro de la familia use el bot. El bot adapta su lenguaje:
- Para Mabel: formal, de usted
- Para Alba: cariñoso, educativo
- Para Fran: muy sencillo

### /legado
Te muestra el estado del legado digital: qué memorias tiene guardadas, cuándo fue el último backup, qué información tiene almacenada sobre ti y tu familia.

### /costes
Te recomienda qué modelo de IA usar para la tarea que estás haciendo. No todos los modelos cuestan lo mismo:
- Tareas simples: modelos baratos (Haiku, Grok Fast)
- Código: modelos medios (Sonnet)
- Decisiones importantes: modelos potentes (Opus)

### /backup
Fuerza un backup inmediato de toda la memoria del bot a GitHub. Normalmente se hace automáticamente cada 6 horas, pero si acabas de tener una conversación importante, puedes forzarlo.

### /ideas
Lista todas las ideas pendientes que le has ido diciendo. Usa el Protocolo de 5 Pasos para evaluarlas (buscar info, discutir, re-investigar, recomendar modelo, preguntar contexto).

### /apps
Te muestra el estado de tus aplicaciones: CalcaApp, MeLlaman, InEmSellar, Afinar guitarra con oídos.

---

## Cómo pedirle que busque cosas

El bot puede buscar en internet en tiempo real. No se inventa las cosas.

Ejemplos:
- "Busca cuánto cuesta un dominio .es en 2026"
- "¿Qué dice la documentación de Flutter sobre widgets?"
- "Busca alternativas gratuitas a Notion"
- "¿Qué opiniones hay sobre el YesTeL Note 30 Pro?"

También puede visitar una web concreta:
- "Lee esta página y hazme un resumen: https://ejemplo.com/articulo"

---

## Cómo funciona la memoria

El bot recuerda las conversaciones de cada sesión. Una sesión dura mientras sigas hablando con él. Si pasan 4 horas sin actividad, la sesión se reinicia.

Pero no se pierde todo: las memorias importantes se guardan en archivos "curados" que sobreviven al reinicio de sesión. Estas memorias curadas se respaldan a GitHub automáticamente.

Si quieres que recuerde algo específico:
- "Guarda esto: la contraseña del WiFi del taller es XYZ123"
- "Recuerda que el cumpleaños de Alba es el 15 de mayo"
- "Apunta esta idea: hacer una app de gestión de turnos"

Si quieres recuperar algo:
- "¿Qué ideas teníamos apuntadas?"
- "¿Qué guardamos sobre CalcaApp?"

---

## El Protocolo de 5 Pasos

Cuando le propongas una idea nueva, el bot la toma MUY en serio. Sigue estos 5 pasos:

1. Busca toda la información que exista sobre tu idea
2. Discute contigo si es viable, con pros y contras honestos
3. Si hay dudas, vuelve a investigar hasta estar seguro
4. Te recomienda qué herramienta/modelo de IA es mejor para llevarla a cabo
5. Te hace mínimo 3 preguntas para asegurarse de que los dos tenemos el mismo contexto

Esto no es opcional. CADA idea pasa por este proceso. Tus ideas se merecen este nivel de seriedad.

---

## Regla de oro

El bot NUNCA te miente. Si no sabe algo, te lo dice. Si no puede hacer algo, te lo dice. Si se equivoca, lo reconoce. Tu confianza es sagrada.

---

## Los otros 2 bots (futuro)

ApliArteBot es parte de un equipo de 3:

| Bot              | Para qué sirve                              | Dónde corre     |
|------------------|----------------------------------------------|-----------------|
| @ApliArteBot     | Tu asistente, coach y guardián del legado    | VPS (Docker)    |
| @aplimobilbot    | Controlar el teléfono YesTeL remotamente     | El propio teléfono |
| @AutApliArteBot  | Automatizaciones con n8n                     | VPS (n8n)       |

Los 3 trabajan juntos en el grupo de Telegram. Cuando @ApliArteBot detecta que necesitas una automatización, te sugiere usar @AutApliArteBot. Cuando necesitas algo del teléfono, te dirige a @aplimobilbot.

---

## Trucos y consejos

1. Se claro y directo. El bot entiende mejor "busca precios de dominios .es" que "oye podrías mirar algo sobre internet"

2. Usa los comandos slash cuando existan para lo que necesitas. Son más rápidos.

3. Si el bot se pone pesado con el modo coach, di "cambio de planes" y explica por qué cambiaste de tema.

4. Envíale audios cuando tengas las manos ocupadas. Los transcribe al momento.

5. Pídele que guarde las cosas importantes. Así sobreviven a los reinicios de sesión.

6. Si algo falla, usa /status para ver cómo está el bot.

7. Si llevas mucho rato sin usarlo y parece que no recuerda nada, es normal: la sesión se reinicia cada 4 horas. Las memorias curadas siguen ahí.

---

Documento creado el 3 de marzo de 2026.
Para consultar la lista completa de capacidades: ver CAPACIDADES_APLIBOT.md
