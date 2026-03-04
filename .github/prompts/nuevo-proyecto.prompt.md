# Setup de proyecto nuevo

Cuando abres un proyecto nuevo o desconocido, sigue este protocolo:

## Paso 1: Reconocimiento
- Leer README.md y cualquier documentación
- Identificar el stack tecnológico (lenguaje, framework, dependencias)
- Buscar archivos de configuración existentes (.env, config.*, etc.)

## Paso 2: Verificar infraestructura de agentes
- ¿Existe `.github/copilot-instructions.md`? Si no → CREARLO
- ¿Existe `.vscode/settings.json`? Si no → CREARLO con config óptima
- ¿Existe `.vscode/tasks.json`? Si no → SUGERIR tareas relevantes
- ¿Existe `.vscode/extensions.json`? Si no → SUGERIR extensiones

## Paso 3: Crear `.github/copilot-instructions.md`
Incluir obligatoriamente:
1. Identidad del proyecto (qué es, para qué sirve)
2. Stack tecnológico
3. Reglas de estilo del usuario (español, exigente, quiere lo mejor)
4. Arquitectura relevante
5. Archivos importantes
6. Workflows comunes

## Paso 4: Optimizar `.vscode/settings.json`
Incluir:
- Instrucciones de Copilot para el proyecto
- Exclusiones de búsqueda (build, node_modules, etc.)
- Auto-approve de comandos seguros
- Perfiles de terminal relevantes

## Paso 5: Proponer tareas
Identificar las 5-10 operaciones más comunes del proyecto y crear tasks.json

## NUNCA:
- Asumir que es un proyecto ClawMobil
- Copiar configuraciones de otro proyecto sin adaptar
- Crear archivos sin verificar que no existen ya
