# 🦀 ClawMobil — Dale vida a tu teléfono viejo

## ¿Qué es esto?

**ClawMobil** convierte cualquier teléfono Android viejo en un **compañero de conversación inteligente** que funciona **sin internet**, **sin pagar nada**, y **sin que tus datos salgan del teléfono**.

Perfecto para:
- 👵 **Personas mayores** que se sienten solas
- 📱 **Teléfonos viejos** que ya no usas (a partir de 3GB de RAM)
- 🔒 **Privacidad total** — todo funciona dentro del teléfono

---

## ¿Qué necesitas?

1. 📱 Un **teléfono Android viejo** (con al menos 3GB de RAM)
2. 💻 Un **ordenador** (Mac, Linux o Windows)
3. 🔌 Un **cable USB** para conectar el teléfono al ordenador
4. 🌐 **Conexión a internet** (solo para la instalación, después ya no la necesita)

---

## Instalación paso a paso

### Paso 1: Prepara el teléfono

En el teléfono Android, necesitas activar las "Opciones de Desarrollador":

1. Abre **Ajustes** (la rueda dentada ⚙️)
2. Ve a **Acerca del teléfono** (suele estar al final)
3. Busca **"Número de compilación"** (o "Número de versión")
4. **Pulsa 7 veces** sobre ese número
5. ¡Te dirá **"Ya eres desarrollador"**! 🎉

Ahora activa la depuración:

6. Vuelve a **Ajustes**
7. Busca **Opciones de desarrollador** (a veces está dentro de "Sistema" o "Configuración adicional")
8. Activa **"Depuración USB"**
9. Conecta el cable USB del teléfono al ordenador
10. En el teléfono aparecerá un mensaje: **"¿Permitir depuración USB?"** → Pulsa **Aceptar** ✅

### Paso 2: Descarga el proyecto

En tu ordenador, abre la **Terminal**:
- **Mac**: Busca "Terminal" en Spotlight (Cmd + Espacio → escribe "Terminal")
- **Linux**: Busca "Terminal" en tus aplicaciones
- **Windows**: Usa "Git Bash" o "PowerShell"

Copia y pega este comando:

```bash
cd ~/Desktop && git clone https://github.com/erbolamm/ClawMobil.git && cd ClawMobil
```

> 💡 Esto descarga el proyecto a tu Escritorio. Si no tienes `git`, descárgalo desde https://git-scm.com

### Paso 3: Ejecuta el instalador

```bash
bash demo/instalar_claw.sh
```

El script hace todo por ti:
- ✅ Detecta tu teléfono
- ✅ Descarga lo que necesita
- ✅ Instala la app en el teléfono
- ✅ ¡La abre!

### Paso 4: Instalar el cerebro de la IA (Ollama)

Ahora necesitamos instalar la inteligencia artificial dentro del teléfono. Para esto usamos un programa llamado **Termux** (una terminal para Android) y **Ollama** (el cerebro de la IA).

En tu ordenador, ejecuta:

```bash
bash demo/setup_servidor.sh
```

Este script:
- ✅ Instala Termux en el teléfono
- ✅ Sube el cerebro de la IA al teléfono
- ✅ Te dice qué hacer en el siguiente paso

Después, en la pantalla del teléfono verás Termux (una pantalla negra con letras). Escribe:

```
bash /sdcard/setup_ollama.sh
```

Espera unos minutos. Cuando termine, escribe:

```
ollama serve &
ollama pull qwen2.5:0.5b
```

> ⏳ Esto descarga el modelo de IA (395MB). Tardará unos 5 minutos con WiFi.

### Paso 5: ¡Habla con Claw! 🦀

1. Abre la app **ClawMobil Chat** en el teléfono
2. Escribe: **"Hola, ¿cómo estás?"**
3. ¡Claw te responderá! 🎉

**No necesita internet.** Puedes desconectar el WiFi y seguirá funcionando.

---

## Preguntas frecuentes

### ¿Funciona sin internet?
**Sí.** Una vez instalado, no necesita internet para nada. Todo funciona dentro del teléfono.

### ¿Es gratis?
**Sí, 100% gratis y de código abierto.** No hay pagos, suscripciones, ni publicidad.

### ¿Mis conversaciones son privadas?
**Totalmente.** Nada sale del teléfono. No hay servidores externos, no se envían datos a ningún sitio.

### ¿Qué teléfonos valen?
Cualquier Android con **3GB de RAM o más**. Marcas como Samsung, Xiaomi, OPPO, Huawei, Motorola... Si tiene menos de 5 años, probablemente funcione.

### ¿Y si mi teléfono no tiene suficiente RAM?
Si tiene 2GB, puedes probar con el modelo `qwen2.5:0.5b` que es muy ligero. Si va lento, necesitarás un teléfono con más memoria.

### ¿Puedo usarlo con el ordenador como cerebro?
**Sí.** Si el teléfono es muy viejo, puedes ejecutar la IA en el ordenador:
1. Instala Ollama en el ordenador: https://ollama.com
2. Ejecuta `ollama serve` 
3. Conecta el teléfono al WiFi del ordenador
4. En la app → ⚙️ Ajustes → Cambia la URL a la IP de tu ordenador

---

## ¿Quién hizo esto?

Creado por **Francisco** de [Apliarte](https://apliarte.com) 🇪🇸

- 🌐 Web: https://apliarte.com
- 💻 Código: https://github.com/erbolamm/ClawMobil
- 🦀 La IA se llama **Claw** y habla español

---

## Para desarrolladores y agentes de IA

Si eres un agente de IA configurando esto automáticamente, lee:
- `Mis_configuraciones_locales/dispositivos/INSTRUCCIONES_AGENTE.md`

Si quieres usar un asistente de IA para hacer la instalación por ti:
- Descarga **Antigravity** (extensión para VS Code / Cursor): https://marketplace.cursorapi.com

---

> *"La tecnología debería acercar a las personas, no alejarlas."*
> — Francisco, Apliarte
