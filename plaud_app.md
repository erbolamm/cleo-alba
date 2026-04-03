# Plaud Assistant - Información de Funcionalidades

## 📋 Descripción General

**Plaud Assistant** es una aplicación Flutter de código abierto diseñada como asistente de IA personalizable para niños, con modo kiosco y configuración familiar. Compatible con OpenClaw y Groq API.

## 🎯 Propósito Principal

Crear un entorno seguro y educativo donde los niños puedan interactuar con IA adaptada específicamente a su edad, nombre familiar y contexto personal, manteniendo siempre el control parental y la privacidad de los datos.

## 🚀 Funcionalidades Principales

### 1. Chat IA Educativo
- **Adaptación por edad**: Respuestas ajustadas al desarrollo cognitivo del niño/a
- **Contexto personal**: Usa nombres reales de familia y situaciones familiares
- **Detección emocional**: Identifica frustración, rabietas o mal humor
- **Apoyo emocional**: Técnicas de respiración y redirección positiva
- **Contenido filtrado**: Sin contenido inapropiado ni respuestas no deseadas

### 2. Modo Kiosco Seguro
- **Bloqueo de salida**: Evita que el niño/a salga de la app accidentalmente
- **Acceso restringido**: Solo usuarios autorizados pueden usar la app
- **Control parental**: Acceso admin con contraseña oculta
- **Seguridad integrada**: Sin compras accidentales ni accesos no deseados

### 3. Interfaz Multi-modal
- **Chat por texto**: Mensajes escritos con respuestas rápidas
- **Chat por voz**: Reconocimiento de voz y síntesis de TTS
- **Respuestas habladas**: El asistente responde con voz natural
- **Emojis y elementos visuales**: Interfaz amigable y colorida

### 4. Configuración Personalizable
- **Nombres dinámicos**: ChildName, FamilyMembers configurables
- **Edad adaptable**: Prompts ajustados según edad del niño/a
- **API flexible**: Compatible con OpenClaw y Groq
- **Tokens seguros**: Configuración local sin subir a repositorios

## 🧠 Modos de Usuario

### Modo Niño/a
- **Prompts educativos**: Adaptados a edad y contexto familiar
- **Detección emocional**: Responde a frustración con técnicas de calma
- **Contenido apropiado**: Sin violencia, lenguaje adulto o temas complejos
- **Interacción lúdica**: Emojis, tono amigable, preguntas curiosas

### Modo Admin
- **Acceso técnico**: Información sobre configuración y diagnóstico
- **Control parental**: Cambios en configuración y ajustes
- **Soporte**: Ayuda para problemas comunes y troubleshooting
- **Seguridad**: Gestión de accesos y restricciones

## 🔧 Configuración Técnica

### Archivo Central de Configuración
`lib/config/app_config.dart` contiene todas las variables personalizables:

```dart
// Datos personales
static const String childName = 'Nombre';
static const List<String> familyMembers = ['Mamá', 'Papá'];
static const int childAge = 7;

// Configuración API
static const String apiUrl = 'https://servidor.com/agent/ask';
static const String apiToken = 'token';
static const String agentName = 'agente';

// Configuración Groq (opcional)
static const String groqApiKey = 'gsk_...';
```

### Servicio API Genérico
`lib/services/api_service.dart` maneja:
- **OpenClaw**: Formato `/agent/ask` con token y agent
- **Groq**: Formato `/chat/completions` con API key
- **Detección automática**: Identifica el tipo de API por URL
- **Manejo de errores**: Respuestas graceful ante fallos

### Generación Dinámica de Prompts
- `_generateChildPrompt()`: Crea prompts personalizados con nombre y edad
- `_generateAdminPrompt()`: Modo técnico y de soporte
- **Variables dinámicas**: `${AppConfig.childName}`, `${AppConfig.familyMembers}`
- **Contexto familiar**: Referencias a miembros reales de la familia

## 🌐 Compatibilidad de Servicios

### OpenClaw (Recomendado)
- **Ventajas**: Control total, sin costes, prompts personalizados
- **Configuración**: Servidor propio con endpoint `/agent/ask`
- **Formato**: `{agent, message, system_prompt, token}`
- **Privacidad**: Datos en servidor propio

### Groq API
- **Ventajas**: LLMs de alta calidad (Llama3, Mixtral)
- **Configuración**: Endpoint `/chat/completions` con API key
- **Formato**: `{model, messages, max_tokens, temperature}`
- **Coste**: Por token utilizado

## 📱 Requisitos del Sistema

### Mínimos
- **Android**: 6.0+ (API 23)
- **RAM**: 2GB+
- **Almacenamiento**: 100MB libres
- **Conexión**: Internet requerida

### Recomendados
- **Android**: 7.0+ con 3GB+ RAM
- **Procesador**: ARMv7 o ARM64
- **Pantalla**: 4.7" o mayor
- **Audio**: Altavoz y micrófono funcionales

## 🔒 Medidas de Seguridad

### Privacidad de Datos
- **Sin datos personales** en el código fuente
- **Configuración local** en `app_config.dart`
- **Tokens cifrados** en tránsito (HTTPS)
- **No tracking** ni analytics integrados

### Control Parental
- **Modo kiosco** con bloqueo de salida
- **Acceso admin** secreto (mantener engranaje 8s)
- **Sin compras** integradas ni anuncios
- **Contenido filtrado** y apropiado

### Seguridad del Código
- **Open source** con revisión comunitaria
- **Sin dependencias** sospechosas
- **Código auditable** y transparente
- **Licencia MIT** para uso libre

## 🎨 Características de UX/UI

### Interfaz Infantil
- **Colores vibrantes** pero no saturados
- **Botones grandes** y fáciles de tocar
- **Texto claro** y legible
- **Emojis y elementos** visuales amigables

### Accesibilidad
- **TTS integrado** para respuestas habladas
- **Reconocimiento de voz** para entrada sin teclado
- **Modo alto contraste** opcional
- **Tamaño de texto** ajustable

### Modo Kiosco
- **Pantalla completa** sin barras de navegación
- **Bloqueo de botones** sistema
- **Salida controlada** solo por admin
- **Indicadores visuales** de modo seguro

## 📊 Flujo de Usuario

### 1. Configuración Inicial
1. Editar `lib/config/app_config.dart`
2. Configurar API (OpenClaw o Groq)
3. Compilar e instalar APK
4. Primer arranque con verificación de configuración

### 2. Uso Diario (Modo Niño/a)
1. Abrir app (modo kiosco activado)
2. Interactuar por voz o texto
3. Recibir respuestas educativas
4. Detección automática de emociones
5. Apoyo emocional si es necesario

### 3. Mantenimiento (Modo Admin)
1. Acceder manteniendo engranaje 8s
2. Verificar configuración API
3. Revisar logs o diagnóstico
4. Actualizar prompts si es necesario
5. Salir del modo kiosco si se requiere

## 🔄 Ciclo de Vida del Proyecto

### Desarrollo
- **Código abierto** en GitHub
- **Contribuciones** de la comunidad
- **Issues y PRs** bienvenidos
- **Documentación** continua

### Mantenimiento
- **Actualizaciones** de seguridad
- **Compatibilidad** con nuevas versiones
- **Nuevas funcionalidades** basadas en feedback
- **Soporte** a la comunidad

### Evolución
- **Más APIs** compatibles (Claude, Gemini)
- **Modos adicionales** (juegos, cuentos)
- **Personalización** avanzada
- **Multi-idioma** completo

## 🎯 Casos de Uso

### Para Padres
- **Control total** de la experiencia IA
- **Seguridad** garantizada para sus hijos
- **Personalización** familiar real
- **Sin costes ocultos** ni sorpresas

### Para Desarrolladores
- **Base sólida** para proyectos similares
- **Código modular** y reutilizable
- **Patrones** de configuración seguros
- **Integración** con múltiples APIs

### Para Educadores
- **Herramienta** educativa personalizable
- **Contenido** adaptado por edad
- **Seguridad** en entorno escolar
- **Escalabilidad** para múltiples usuarios

## 📈 Métricas de Éxito

### Técnicas
- **Tiempo de respuesta** < 3 segundos
- **Disponibilidad** > 99%
- **Compatibilidad** con 95% de dispositivos Android 6+
- **Consumo** de datos < 50MB/hora

### de Usuario
- **Satisfacción** infantil > 90%
- **Facilidad** de configuración > 85%
- **Retención** de usuarios > 80%
- **Feedback** positivo de padres

---

## 📝 Notas Importantes

1. **Configuración obligatoria**: La app no funcionará sin configurar `app_config.dart`
2. **Privacidad**: Nunca subir archivos con datos personales a repositorios
3. **Seguridad**: Mantener tokens y API keys en local
4. **Actualizaciones**: Revisar regularmente nuevas versiones y parches de seguridad
5. **Comunidad**: Participar en el desarrollo y reportar issues

## 🤝 Cómo Contribuir

1. **Fork** el repositorio
2. **Crear** feature branch
3. **Desarrollar** con pruebas
4. **Documentar** cambios
5. **Pull Request** con descripción clara

## 📞 Soporte

- **GitHub Issues**: Reportar bugs y solicitar funcionalidades
- **Documentación**: Guías detalladas en `/docs`
- **Comunidad**: Discusiones y consejos en issues y discussions
- **Email**: Para consultas privadas o comerciales

---

**Plaud Assistant** - Tecnología humana para el aprendizaje infantil.
