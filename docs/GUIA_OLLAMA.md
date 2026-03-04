# 🧠 Guía Ollama para ClawMobil

## ¿Qué es Ollama?

Un servidor de modelos IA que corre en local (en tu máquina, sin internet). Como tener tu propio ChatGPT privado.

**Ventajas para ClawMobil:**
- 🔒 **Privacidad total** — los datos nunca salen del dispositivo
- ✈️ **Funciona sin internet** — modo avión 100% funcional
- 💰 **Sin coste** — no gastas tokens ni API keys
- 🤝 **Compartible** — un teléfono puede servir IA a otros por WiFi

---

## Instalación rápida

| Plataforma | Cómo instalar |
|---|---|
| **Android (Termux)** | `pkg install ollama` |
| **Mac** | `brew install ollama` |
| **Linux** | `curl -fsSL https://ollama.com/install.sh \| sh` |
| **Docker** | `docker run -d -p 11434:11434 ollama/ollama` |

---

## Comandos básicos

```bash
# 1. Arrancar el servidor
ollama serve

# 2. Descargar un modelo (solo la primera vez)
ollama pull gemma2:2b          # Ligero (~1.4 GB RAM)
ollama pull llama3.2:3b        # Mejor calidad (~2 GB RAM)
ollama pull phi3:mini          # Microsoft, muy rápido

# 3. Chatear desde terminal
ollama run gemma2:2b

# 4. Ver modelos instalados
ollama list

# 5. Borrar un modelo
ollama rm gemma2:2b
```

---

## Modelos recomendados

| Modelo | RAM mínima | Mejor para |
|---|---|---|
| `qwen2.5:0.5b` | ~0.5 GB | Dispositivos muy limitados (2 GB RAM) |
| `llama3.2:1b` | ~1 GB | Dispositivos limitados (3 GB RAM) |
| `gemma2:2b` | ~1.4 GB | **Recomendado** para 4+ GB RAM |
| `phi3:mini` | ~2.3 GB | Respuestas rápidas (4+ GB RAM) |
| `llama3.2:3b` | ~2 GB | Mejor calidad (6+ GB RAM) |
| `qwen2.5:3b` | ~2 GB | Multiidioma (chino+inglés+español) |

> 💡 **Consejo**: El script `ollama_serve.sh` auto-detecta tu RAM y recomienda el modelo adecuado.

---

## Uso con ClawMobil

### Método 1: Automático (recomendado)

El script `start_bot.sh` ya arranca Ollama automáticamente si está instalado. No necesitas hacer nada especial.

```bash
# Arrancar todo (Termux)
bash start_bot.sh
```

### Método 2: Script dedicado

```bash
# Arrancar servidor Ollama
bash scripts/ollama_serve.sh start

# Ver estado y modelos
bash scripts/ollama_serve.sh status

# Descargar modelo recomendado para tu RAM
bash scripts/ollama_serve.sh pull

# Test rápido
bash scripts/ollama_serve.sh test
```

### Método 3: Flutter `--dart-define`

Al compilar la app Flutter, puedes configurar Ollama:

```bash
# Usar Ollama local
flutter run \
  --dart-define=OLLAMA_URL=http://127.0.0.1:11434 \
  --dart-define=OLLAMA_MODEL=gemma2:2b

# Usar Ollama de otro teléfono en la red
flutter run \
  --dart-define=OLLAMA_LAN_URL=http://192.168.1.42:11434 \
  --dart-define=OLLAMA_MODEL=gemma2:2b \
  --dart-define=GROQ_API_KEY=gsk_xxxx  # Fallback cloud
```

---

## 🤝 Modo servidor LAN (un teléfono sirve a otros)

Esta es la funcionalidad estrella: un teléfono con buena RAM puede servir IA a otros dispositivos de la red WiFi.

### Teléfono servidor (el que tiene buena RAM)

1. Instalar Ollama y descargar un modelo:

```bash
pkg install ollama
ollama pull gemma2:2b
```

2. En `claves.env` del dispositivo servidor:

```bash
OLLAMA_SERVE_LAN=true
OLLAMA_MODEL=gemma2:2b
```

3. El `start_bot.sh` arrancará Ollama escuchando en `0.0.0.0:11434` (accesible por red).

4. Averiguar la IP del servidor:

```bash
ifconfig | grep "inet " | grep -v 127.0.0.1
# Ejemplo resultado: 192.168.1.42
```

### Teléfono cliente (el que usa la IA del servidor)

En `claves.env` del dispositivo cliente:

```bash
OLLAMA_LAN_URL=http://192.168.1.42:11434
```

O al compilar la app Flutter:

```bash
flutter run --dart-define=OLLAMA_LAN_URL=http://192.168.1.42:11434
```

### Diagrama de red

```
📱 Servidor (4+ GB RAM)          📱 Cliente 1
┌────────────────────┐           ┌────────────────────┐
│  Ollama Server     │           │  ClawMobil App      │
│  gemma2:2b         │◀──WiFi──▶│  → Ollama LAN       │
│  0.0.0.0:11434     │           │  → Groq (fallback)  │
└────────────────────┘           └────────────────────┘
         ▲                                ▲
         │ WiFi                   WiFi    │
         ▼                                ▼
📱 Cliente 2                     💻 Mac (desarrollo)
┌────────────────────┐           ┌────────────────────┐
│  ClawMobil App     │           │  Puede usar el     │
│  → Ollama LAN      │           │  mismo servidor    │
│  → Groq (fallback) │           │  o su propio local │
└────────────────────┘           └────────────────────┘
```

---

## API (para desarrolladores)

El servidor Ollama escucha en `http://localhost:11434` y es compatible con la API de OpenAI:

```bash
# Endpoint compatible OpenAI
curl http://localhost:11434/v1/chat/completions \
  -H "Content-Type: application/json" \
  -d '{
    "model": "gemma2:2b",
    "messages": [{"role": "user", "content": "Hola"}]
  }'

# Endpoint nativo Ollama
curl http://localhost:11434/api/generate \
  -d '{"model": "gemma2:2b", "prompt": "Hola", "stream": false}'

# Health check
curl http://localhost:11434/api/tags
```

---

## Para OpenClaw

Si usas OpenClaw Gateway, puedes configurar Ollama como proveedor en `openclaw.json`:

```json
{
  "model": "ollama/gemma2:2b",
  "providers": {
    "ollama": {
      "api": "ollama",
      "baseUrl": "http://127.0.0.1:11434"
    }
  }
}
```

---

## Cómo funciona el fallback automático

La app ClawMobil tiene un sistema inteligente de fallback:

```
1️⃣ Ollama Local (127.0.0.1:11434)
   ↓ si no responde...
2️⃣ Ollama LAN (IP configurada)
   ↓ si no responde...
3️⃣ Groq Cloud (api.groq.com)
   ↓ si no hay API key...
❌ Error: "No hay proveedores disponibles"
```

**Indicadores visuales en el chat:**
- 🟢 **Local** — Respondió Ollama del mismo dispositivo
- 🟢 **LAN** — Respondió Ollama de otro dispositivo en la red
- 🌐 **Cloud** — Respondió Groq (necesita internet)

---

## Solución de problemas

| Problema | Solución |
|---|---|
| `Ollama no arranca` | Verificar RAM libre: `free -m`. Ollama necesita al menos 1 GB libre |
| `Modelo no responde` | ¿Está descargado? `ollama list`. Si no: `ollama pull gemma2:2b` |
| `Conexión LAN rechazada` | ¿Ollama escucha en 0.0.0.0? Verificar con `OLLAMA_HOST=0.0.0.0 ollama serve` |
| `Respuestas lentas` | Probar modelo más pequeño: `llama3.2:1b` o `qwen2.5:0.5b` |
| `Sin espacio en disco` | Mover modelos a SD: `export OLLAMA_MODELS=/sdcard/ollama_models` |

---

## Archivos relacionados

| Archivo | Descripción |
|---|---|
| `lib/services/ollama_service.dart` | Servicio Dart con fallback multi-proveedor |
| `scripts/ollama_serve.sh` | Script gestor del servidor Ollama |
| `scripts/15_install_ollama.sh` | Script de instalación remota via SSH |
| `start_bot.sh` | Arranque automático (incluye Ollama) |
| `Mis_configuraciones_locales/dispositivos/_plantilla/claves.env` | Variables de configuración |
