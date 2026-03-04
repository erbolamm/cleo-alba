# Enseñar al bot una nueva habilidad

Contexto: ApliBot es un bot autónomo que corre OpenClaw v2026.2.26 en un YesTeL Note 30 Pro.
Se comunica por Telegram. Está APRENDIENDO a ser autónomo.

## Filosofía OBLIGATORIA:
- "Enseñar a pescar, NO dar el pescado"
- Dar CONCEPTOS y CAMINOS, no código completo
- El bot debe descubrir la implementación por sí mismo
- Si falla, darle pistas progresivas, nunca la solución directa

## Formato del mensaje para Telegram:
⚠️ TEXTO PLANO — Sin markdown, sin backticks, sin bloques de código.

### Estructura del mensaje:
```
[NOMBRE DE LA HABILIDAD]

Que vas a aprender:
- Punto 1
- Punto 2

Conceptos clave:
- Concepto A: explicación breve
- Concepto B: explicación breve

Pasos para practicar:
1. Primero haz X
2. Luego intenta Y
3. Verifica con Z

Criterio de exito:
- Cuando logres [resultado], la habilidad está dominada

Si te atascas:
- Revisa [recurso]
- Prueba [alternativa]
```

## IMPORTANTE:
- Verificar que el mensaje NO tiene markdown antes de enviarlo
- El bot tiende a decir "hecho" sin verificar — incluir siempre "verifica ejecutando X"
- Indicar SIEMPRE desde qué entorno ejecutar (Termux nativo vs PRoot Debian)
