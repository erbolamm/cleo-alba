# Guion de directo ClawMobil (sin margen de error)

Fecha: 2026-02-27

## Objetivo

Demostrar que ClawMobil permite crear un clon funcional por dispositivo con flujo guiado, reversible y estable.

## Preparación previa (5 minutos)

1. Confirmar que el P10 queda como backup operativo.
2. Tener conectado el segundo dispositivo (demo principal).
3. Abrir en pantalla:
- `index.html`
- `empezar.html`
- terminal con repo abierto

## Parte 1 (2-3 min): Qué es ClawMobil y qué resuelve

1. Problema: móviles antiguos desaprovechados.
2. Solución: cada móvil como nodo IA modular.
3. Mensaje clave: personalización local en `Mis_configuraciones_locales` sin romper la base.

## Parte 2 (4-6 min): Generación de configuración en vivo

1. Abrir `empezar.html`.
2. Seleccionar perfil del segundo dispositivo.
3. Activar funciones: mensajería + STT/TTS + automatización.
4. Generar:
- `config_profile.json`
- prompt modular
- comando shell
5. Ejecutar comando generado en terminal.

Comandos a mostrar:

```bash
bash scripts/local_config_select.sh --json
bash scripts/local_config_evaluate.sh
```

## Parte 3 (3-4 min): Cambios y monitoreo en tiempo real

1. Ejecutar watcher:

```bash
bash scripts/local_config_watch.sh --loop --interval 2
```

2. Editar una nota local del dispositivo y mostrar detección automática.
3. Enseñar reporte generado en `Mis_configuraciones_locales/reportes/`.

## Parte 4 (3-4 min): Reversibilidad con snapshots

1. Crear snapshot:

```bash
bash scripts/local_config_lab.sh snapshot <dispositivo_demo>
```

2. Hacer un cambio visible.
3. Restaurar:

```bash
bash scripts/local_config_lab.sh restore <dispositivo_demo> <snapshot.tar.gz>
```

4. Verificar estado final con `local_config_evaluate.sh`.

## Preguntas probables del público (y respuesta corta)

1. "¿Esto rompe el repositorio principal?"
- No. Todo cambio local va a `Mis_configuraciones_locales`.

2. "¿Cómo compartes mejoras entre forks?"
- Con `local_config_discovery.sh` y promoción controlada con `local_config_promote.sh`.

3. "¿Qué pasa si una prueba sale mal?"
- Se revierte por snapshot con `local_config_lab.sh restore`.

4. "¿Qué dependencias externas necesito en vivo?"
- Ninguna para la parte modular local; solo scripts bash y el wizard local.

## Checklist final de 60 segundos

1. `bash scripts/prelive_direct_check.sh`
2. Huawei backup en verde (gateway + puertos activos)
3. Segundo dispositivo con wizard listo
4. Terminal con comandos copiados
