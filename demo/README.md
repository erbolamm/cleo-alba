# 🦀 ClawMobil — Dale vida a tu teléfono viejo

### Un compañero de conversación inteligente que funciona SIN internet

---

## 💛 ¿Para qué sirve?

¿Tienes un **teléfono Android viejo** en un cajón?

Con ClawMobil puedes convertirlo en un **compañero de conversación** para personas mayores, para ti, o para cualquiera que quiera tener con quién hablar.

- ✅ **Sin internet** — funciona sin WiFi ni datos
- ✅ **Gratis para siempre** — sin pagos, sin suscripciones
- ✅ **Totalmente privado** — nadie lee tus conversaciones
- ✅ **Funciona en teléfonos viejos** — a partir de 3GB de RAM

---

## 📋 ¿Qué necesitas?

Antes de empezar, asegúrate de tener:

| Lo que necesitas | ¿Lo tienes? |
|:---|:---|
| 📱 Un teléfono Android viejo (con al menos 3GB de RAM) | ☐ |
| 💻 Un ordenador (Mac, Linux o Windows) | ☐ |
| 🔌 Un cable USB para conectar el teléfono al ordenador | ☐ |
| 🌐 WiFi (solo para la instalación, después no lo necesita) | ☐ |

> 💡 **¿Cómo sé si mi teléfono tiene 3GB de RAM?**
> Ve a Ajustes → Acerca del teléfono → Busca "RAM" o "Memoria".
> Si pone 3GB, 4GB o más, ¡perfecto!

---

## 🔧 Instalación paso a paso

### 📱 PARTE 1: Preparar el teléfono

> No te preocupes, esto solo se hace una vez.

**1.1** Enciende el teléfono viejo y conéctalo al WiFi de casa.

**1.2** Abre la app de **Ajustes** (el icono de la rueda dentada ⚙️).

**1.3** Baja hasta el final y busca **"Acerca del teléfono"** (o "Sobre el teléfono"). Pulsa ahí.

**1.4** Busca donde pone **"Número de compilación"** (o "Número de versión" o "Build number").

**1.5** Ahora viene lo divertido: **pulsa 7 veces seguidas** sobre ese número. 

> 🎉 ¡Verás un mensaje que dice **"Ya eres desarrollador"**! No te asustes, es normal.

**1.6** Vuelve atrás a **Ajustes**.

**1.7** Busca **"Opciones de desarrollador"**.
> 💡 En algunos teléfonos está dentro de "Sistema" o "Configuración adicional".

**1.8** Dentro de Opciones de desarrollador, busca **"Depuración USB"** y actívala (ponla en azul/verde).

**1.9** Conecta el cable USB del teléfono al ordenador.

**1.10** En el teléfono aparecerá un mensaje: **"¿Permitir depuración USB?"** → Pulsa **"Aceptar"** o **"Permitir"** ✅

> 🎉 ¡El teléfono está listo!

---

### 💻 PARTE 2: Descargar el proyecto en el ordenador

**2.1** En tu ordenador, abre la **Terminal**:

| Tu ordenador | Cómo abrir la Terminal |
|:---|:---|
| 🍎 **Mac** | Pulsa `Cmd + Espacio`, escribe **Terminal** y pulsa Enter |
| 🐧 **Linux** | Busca "Terminal" en tus aplicaciones |
| 🪟 **Windows** | Busca "PowerShell" en el menú de inicio |

> 💡 La Terminal es esa ventana negra donde se escriben comandos. No tengas miedo, solo vas a copiar y pegar.

**2.2** Copia este texto y pégalo en la Terminal. Luego pulsa **Enter**:

```
cd ~/Desktop && git clone https://github.com/erbolamm/ClawMobil.git && cd ClawMobil
```

> 💡 Esto descarga el proyecto a tu Escritorio. Verás una carpeta nueva llamada "ClawMobil".
>
> ⚠️ Si dice "git: command not found", necesitas instalar Git primero:
> Ve a https://git-scm.com y descárgalo. Es gratis y seguro.

---

### 📲 PARTE 3: Instalar la app en el teléfono

**3.1** Con el teléfono conectado por USB, copia y pega este comando en la Terminal:

```
bash demo/instalar_claw.sh
```

**3.2** Verás mensajes de colores en la pantalla. El script hace todo solo:

```
🦀 ClawMobil - Instalador
📱 Dispositivo encontrado: Samsung Galaxy A3
✅ App instalada correctamente
✅ App abierta en el teléfono
```

> 🎉 ¡Ya tienes la app instalada en el teléfono! Pero aún no puede hablar — necesita su "cerebro".

---

### 🧠 PARTE 4: Instalar el cerebro de la IA

> Esta es la parte más importante. El "cerebro" es lo que hace que Claw pueda pensar y responder.

**4.1** Copia y pega este comando en la Terminal:

```
bash demo/setup_servidor.sh
```

**4.2** Espera a que termine (puede tardar 2-3 minutos). Verás:

```
🦀 ClawMobil - Setup Servidor IA
📱 Dispositivo: tu teléfono
[1/5] Instalando Termux... ✅
[2/5] Inicializando Termux... ✅
[3/5] Subiendo Ollama al teléfono... ✅
```

**4.3** Ahora mira la pantalla del teléfono. Verás una **pantalla negra con letras** (es Termux). Escribe en el teléfono:

```
bash /sdcard/setup_ollama.sh
```

> 💡 Puedes escribirlo con el teclado del teléfono. Pulsa Enter cuando termines.

**4.4** Espera unos 2-3 minutos. Cuando veas que vuelve a aparecer el cursor (`~ $`), escribe:

```
ollama serve &
```

Pulsa Enter. Luego escribe:

```
ollama pull qwen2.5:0.5b
```

Pulsa Enter.

> ⏳ Esto descarga el cerebro de Claw (395MB). Con WiFi normal, tarda unos **5 minutos**.
> Cuando veas "success", ¡el cerebro está instalado!

---

### 🎉 PARTE 5: ¡Habla con Claw!

**5.1** Abre la app **ClawMobil Chat** en el teléfono (el icono del cangrejo 🦀).

**5.2** Escribe: **"Hola, ¿cómo estás?"**

**5.3** ¡**Claw te responderá**! 🦀💬

> 🔌 **Ahora puedes desconectar el WiFi.** Claw seguirá funcionando sin internet.
> Es tu compañero, siempre disponible, en tu teléfono.

## 🦀 ¿Qué puede hacer Claw?

Una vez instalado, Claw puede:

| Función | Ejemplo de lo que puedes decirle |
|:---|:---|
| 💬 **Conversar** | "Cuéntame algo bonito" o "¿Qué tal el día?" |
| 📅 **Agenda** | "Recuérdame que mañana tengo médico a las 10" |
| 📝 **Notas** | "Apunta que el número del fontanero es 612 345 678" |
| 🛒 **Listas** | "Haz una lista de la compra: leche, pan, huevos" |
| ❓ **Preguntas** | "¿Cuál es la capital de Francia?" |
| 😊 **Compañía** | "Me siento solo" → Claw siempre está ahí |

> 💡 Claw habla español y se adapta a ti. Si eres una persona mayor, te hablará con frases cortas y claras.

---

## ❓ Preguntas frecuentes

### ¿De verdad funciona sin internet?
**Sí.** Una vez instalado, puedes apagar el WiFi, quitar la tarjeta SIM, y Claw seguirá conversando contigo. Todo funciona dentro del teléfono.

### ¿Es realmente gratis?
**Sí, 100%.** No hay pagos, no hay trampa. Es código abierto: cualquiera puede verlo y mejorarlo.

### ¿Alguien puede leer mis conversaciones?
**No.** Tus conversaciones nunca salen del teléfono. No hay servidores, no hay nubes, no hay empresas detrás.

### ¿Qué teléfonos sirven?
Cualquier Android con **3GB de RAM o más**: Samsung, Xiaomi, OPPO, Huawei, Motorola, Realme, OnePlus...

### ¿Puedo dejar Claw siempre encendido?
Sí. Mantén el teléfono cargado y Claw estará siempre disponible para charlar.

### ¿Y si algo sale mal?
No pasa nada. El script no modifica nada importante del teléfono. Lee la sección "Borrar todo" más abajo.

---

## 🤖 ¿Quieres que una IA lo haga por ti?

> **¡No necesitas saber nada de tecnología!** Puedes pedirle a un asistente virtual que haga toda la instalación por ti.

### Cómo hacerlo:

**1.** Descarga **Cursor** (es gratis) — un programa con inteligencia artificial integrada:

> 🔗 **https://cursor.com** — Descárgalo e instálalo en tu ordenador.

**2.** Abre Cursor y clona este proyecto (Cursor te ayudará a hacerlo).

**3.** Conecta el teléfono Android por USB al ordenador.

**4.** Escribe en el chat de Cursor:

> *"Lee demo/README.md y configura ClawMobil en el teléfono que tengo conectado por USB"*

**5.** ¡**La IA hace todo sola!** Verás cómo va ejecutando cada paso automáticamente.

> 💡 Esto es **Antigravity** — una IA que programa por ti. Es como tener un técnico dentro del ordenador.

---

## 🗑️ Borrar todo (desinstalar)

Si quieres eliminar todo del teléfono y dejarlo como estaba:

### Desinstalar la app ClawMobil Chat
1. Ve a **Ajustes → Apps** en el teléfono
2. Busca **ClawMobil Chat**
3. Pulsa **Desinstalar**

### Desinstalar el cerebro (Termux + Ollama)
1. Ve a **Ajustes → Apps** en el teléfono
2. Busca **Termux**
3. Pulsa **Desinstalar**

> ✅ ¡Listo! El teléfono queda completamente limpio. No se ha modificado nada del sistema.

### Desinstalar desde el ordenador (con cable USB)
```
adb uninstall com.apliarte.clawmobil
adb uninstall com.termux
```

---

## 👨‍💻 ¿Quién hizo esto?

Creado con ❤️ por **Francisco** de [Apliarte](https://apliarte.com) 🇪🇸

Un proyecto para que la tecnología una a las personas, especialmente a las que más lo necesitan.

- 🌐 **Web**: https://apliarte.com
- 💻 **Código fuente**: https://github.com/erbolamm/ClawMobil
- 🦀 La IA se llama **Claw** y habla español

---

> *"La tecnología debería acercar a las personas, no alejarlas."*
