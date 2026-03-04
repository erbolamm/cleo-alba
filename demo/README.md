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
No pasa nada. El script no modifica nada importante del teléfono. Si algo falla, desinstala la app desde Ajustes y empieza de nuevo.

---

## 🤖 ¿Quieres que un asistente lo haga por ti?

Si prefieres que una inteligencia artificial haga toda la instalación por ti (como un técnico virtual), puedes usar **Antigravity**:

1. Descarga **Cursor** (un editor de código con IA): https://cursor.com
2. Abre Cursor y clona este proyecto
3. Dile al agente: *"Lee demo/README.md y configura ClawMobil en el teléfono que tengo conectado"*
4. ¡El agente hace todo solo!

---

## 👨‍💻 ¿Quién hizo esto?

Creado con ❤️ por **Francisco** de [Apliarte](https://apliarte.com) 🇪🇸

Un proyecto para que la tecnología una a las personas, especialmente a las que más lo necesitan.

- 🌐 **Web**: https://apliarte.com
- 💻 **Código fuente**: https://github.com/erbolamm/ClawMobil
- 🦀 La IA se llama **Claw** y habla español

---

> *"La tecnología debería acercar a las personas, no alejarlas."*
