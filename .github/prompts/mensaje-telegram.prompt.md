# Generar mensaje para el bot por Telegram

Crea un mensaje estructurado para enviar a ApliBot por Telegram.

## REGLA DE ORO: TEXTO PLANO
- SIN markdown (no **, no ##, no ```)
- SIN backticks
- SIN bloques de código
- SIN emojis excesivos (máximo 3 por mensaje)
- Longitud máxima: 4000 caracteres (límite Telegram)

## Estructura recomendada:

```
[TITULO DE LA TAREA]

Que necesito que hagas:
1. Paso concreto 1
2. Paso concreto 2
3. Paso concreto 3

Desde donde ejecutar:
- Los pasos 1 y 2: desde PRoot Debian
- El paso 3: desde Termux nativo (fuera de PRoot, usa exit primero)

Como verificar que funciono:
- Ejecuta [comando] y el resultado debe ser [esperado]

Si algo falla:
- Error X: prueba Y
- Error Z: prueba W

IMPORTANTE: No me digas que esta hecho sin verificar. Ejecuta el comando de verificacion y dime el resultado real.
```

## Errores comunes del bot a prevenir:
1. Ejecutar comandos Android desde PRoot → Recordarle: "exit primero para salir a Termux nativo"
2. Decir "hecho" sin verificar → Incluir: "ejecuta X para confirmar y dime el resultado"
3. No reportar errores → Incluir: "si hay algun error, pegame el mensaje completo"
4. Confundir rutas → Ser explícito con rutas absolutas
