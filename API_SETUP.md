# Guía de Configuración API - OpenClaw + Groq

## 📋 Overview

Plaud Assistant es compatible con dos tipos de APIs:
- **OpenClaw**: Servidor propio con control total
- **Groq**: LLMs de alta calidad con coste por uso

## 🔧 OpenClaw Setup

### ¿Qué es OpenClaw?

OpenClaw es un servidor de IA de código abierto que te da control total sobre las respuestas, prompts y datos.

### Requisitos

- Servidor (VPS, dedicado, o local)
- Docker o Node.js instalado
- Acceso a firewall/ports

### Instalación Rápida

#### Opción 1: Docker (Recomendado)

```bash
# Clonar OpenClaw
git clone https://github.com/erbolamm/openclaw.git
cd openclaw

# Configurar variables
cp .env.example .env
nano .env

# Levantar contenedor
docker-compose up -d
```

#### Opción 2: Node.js

```bash
# Clonar y dependencias
git clone https://github.com/erbolamm/openclaw.git
cd openclaw
npm install

# Configurar
cp .env.example .env
nano .env

# Iniciar
npm start
```

### Configuración de OpenClaw

Edita `.env`:

```bash
# Puerto del servidor
PORT=3000

# Token de autenticación (elige uno seguro)
AUTH_TOKEN=tu_token_secreto_aqui

# Agentes disponibles
AGENTS=plaud,assistant,helper

# Modelo de IA (si usas local)
AI_MODEL=llama3
```

### Configurar Plaud Assistant para OpenClaw

Edita `lib/config/app_config.dart`:

```dart
// Configuración OpenClaw
static const String apiUrl = 'https://tu-servidor.com:3000/agent/ask';
static const String apiToken = 'tu_token_secreto_aqui';
static const String agentName = 'plaud';
static const String groqApiKey = ''; // Dejar vacío para OpenClaw
```

### Verificar Conexión

```bash
# Test del servidor
curl -X POST https://tu-servidor.com:3000/agent/ask \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer tu_token_secreto_aqui" \
  -d '{
    "agent": "plaud",
    "message": "Hola",
    "system_prompt": "Eres un asistente amigable"
  }'
```

## 🚀 Groq API Setup

### ¿Qué es Groq?

Groq es un servicio de LLMs de alta velocidad con modelos como Llama3, Mixtral, y más.

### Requisitos

- Cuenta en Groq Console
- API Key válida
- Conexión a internet

### Obtener API Key de Groq

1. Ve a [console.groq.com](https://console.groq.com)
2. Regístrate o inicia sesión
3. Ve a API Keys
4. Crea nueva API Key
5. Copia la key (empieza con `gsk_`)

### Configurar Plaud Assistant para Groq

Edita `lib/config/app_config.dart`:

```dart
// Configuración Groq
static const String apiUrl = 'https://api.groq.com/openai/v1/chat/completions';
static const String apiToken = ''; // No usado para Groq
static const String agentName = ''; // No usado para Groq
static const String groqApiKey = 'gsk_tu_api_key_aqui';
```

### Modelos Disponibles en Groq

| Modelo | Descripción | Límite tokens |
|--------|-------------|---------------|
| `llama3-70b-8192` | Llama 3 70B | 8192 |
| `llama3-8b-8192` | Llama 3 8B | 8192 |
| `mixtral-8x7b-32768` | Mixtral 8x7B | 32768 |
| `gemma-7b-it` | Gemma 7B | 8192 |

### Personalizar Modelo Groq

Edita `lib/services/api_service.dart`:

```dart
// En el método _sendGroqRequest
final body = {
  'model': 'llama3-70b-8192', // Cambia esto
  'messages': messages,
  'max_tokens': 500,
  'temperature': 0.7,
};
```

### Verificar Conexión Groq

```bash
# Test de API Groq
curl -X POST https://api.groq.com/openai/v1/chat/completions \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer gsk_tu_api_key" \
  -d '{
    "model": "llama3-70b-8192",
    "messages": [
      {"role": "system", "content": "Eres un asistente amigable"},
      {"role": "user", "content": "Hola"}
    ],
    "max_tokens": 100
  }'
```

## 🔐 Seguridad

### OpenClaw

- **HTTPS obligatorio**: Usa certificado SSL/TLS
- **Firewall**: Solo puerto necesario abierto
- **Token fuerte**: Usa string largo y aleatorio
- **Logs seguros**: Nunca guardes mensajes sensibles

### Groq

- **API Key privada**: Nunca en repositorios
- **Rotación regular**: Cambia API key periódicamente
- **Límites de uso**: Monitoriza consumo
- **Backup**: Ten API key secundaria

## 📊 Comparativa

| Característica | OpenClaw | Groq |
|----------------|----------|------|
| **Coste** | Gratis (servidor propio) | Por token |
| **Control** | Total (prompts propios) | Limitado (modelos predefinidos) |
| **Privacidad** | Datos en tu servidor | Datos en servidores Groq |
| **Velocidad** | Depende de tu hardware | Muy rápida |
| **Setup** | Requiere servidor | Solo API key |
| **Mantenimiento** | Tú responsable | Groq responsable |

## 🛠️ Troubleshooting

### OpenClaw Issues

**Error: Conexión rechazada**
```bash
# Verificar que el servidor está corriendo
docker ps | grep openclaw

# Verificar puerto
netstat -tlnp | grep 3000
```

**Error: Token inválido**
```bash
# Verificar token en .env
grep AUTH_TOKEN .env

# Test con curl
curl -H "Authorization: Bearer tu_token" ...
```

**Error: Agente no encontrado**
```bash
# Verificar agentes configurados
grep AGENTS .env

# Listar agentes disponibles
curl https://servidor.com:3000/agents
```

### Groq Issues

**Error: API Key inválida**
```bash
# Verificar API key
echo $GROQ_API_KEY

# Test con curl
curl -H "Authorization: Bearer gsk_tu_key" ...
```

**Error: Límite excedido**
```bash
# Verificar uso en Groq Console
# Esperar reset de límite o usar otro modelo
```

**Error: Modelo no disponible**
```bash
# Verificar modelos disponibles
curl -H "Authorization: Bearer gsk_key" \
  https://api.groq.com/openai/v1/models
```

## 🔄 Cambiar entre APIs

Para cambiar de OpenClaw a Groq (o viceversa):

1. **Editar configuración**:
   ```dart
   // Para OpenClaw
   static const String apiUrl = 'https://servidor.com/agent/ask';
   static const String apiToken = 'token_openclaw';
   static const String groqApiKey = '';
   
   // Para Groq
   static const String apiUrl = 'https://api.groq.com/openai/v1/chat/completions';
   static const String apiToken = '';
   static const String groqApiKey = 'gsk_key';
   ```

2. **Recompilar app**:
   ```bash
   flutter clean
   flutter pub get
   flutter build apk --release
   ```

3. **Instalar y testear**:
   ```bash
   adb install app-release.apk
   ```

## 📈 Optimización

### OpenClaw

- **CPU**: Múltiples cores para mejor rendimiento
- **RAM**: 8GB+ para modelos grandes
- **Almacenamiento**: SSD para respuestas rápidas
- **Red**: Ancho de banda suficiente

### Groq

- **Modelo**: Elige según complejidad (70B para calidad, 8B para velocidad)
- **Tokens**: Limita `max_tokens` para respuestas más rápidas
- **Temperature**: Ajusta según necesidad (0.7 para creatividad, 0.3 para precisión)
- **Batch**: Agrupa múltiples requests si es posible

## 🎯 Recomendaciones

### Para Principiantes
- **Empieza con Groq**: Más fácil de configurar
- **Modelo Llama3-8B**: Rápido y económico
- **Límites bajos**: 200-300 tokens por respuesta

### Para Avanzados
- **OpenClaw**: Control total y privacidad
- **Servidor dedicado**: Mejor rendimiento
- **Prompts personalizados**: Respuestas únicas

### Para Producción
- **OpenClaw**: Sin costes variables
- **Backup de API**: Tener ambas opciones
- **Monitorización**: Logs y métricas
- **SSL obligatorio**: Seguridad primero

---

## 📞 Soporte

### OpenClaw
- **GitHub Issues**: [github.com/erbolamm/openclaw](https://github.com/erbolamm/openclaw)
- **Documentación**: README del repositorio
- **Comunidad**: Discussions y forks

### Groq
- **Console**: [console.groq.com](https://console.groq.com)
- **Docs**: [docs.groq.com](https://docs.groq.com)
- **Status**: [status.groq.com](https://status.groq.com)

### Plaud Assistant
- **Issues**: Reportar problemas en GitHub
- **Docs**: Archivos `/docs` del repositorio
- **Community**: Discussions y feedback

---

**Nota**: Siempre mantén tus API keys y tokens seguros. Nunca los subas a repositorios públicos.
