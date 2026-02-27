# Framework local de configuraciones (fork-ready)

Este documento define el flujo modular para que cada clon de ClawMobil use su
propia configuracion en `Mis_configuraciones_locales/` sin romper la base.

## 1) Contrato de carpetas

Cada dispositivo o variante vive en:

```text
Mis_configuraciones_locales/dispositivos/<nombre_dispositivo>/
```

Estructura recomendada minima:

```text
<nombre_dispositivo>/
├── config_profile.json      # Perfil generado por el asistente web
├── claves.env               # Secretos locales (no promover a plantilla)
├── notas.md                 # Contexto operativo del dispositivo
└── log_instalacion.md       # Historial de cambios e incidencias
```

## 2) Creacion guiada (wizard)

Usa `index.html` y luego `empezar.html` (seccion **Asistente de Configuracion Local**) para:

1. Elegir perfil de dispositivo y entorno.
2. Activar funcionalidades (mensajeria, STT/TTS, camara, automatizacion).
3. Definir idioma, permisos y limitaciones.
4. Generar:
   - `config_profile.json`
   - Prompt listo para pegar en tu agente local
   - Comando shell para crear la carpeta en `Mis_configuraciones_locales/`

## 3) Seleccion automatica de perfil activo

```bash
bash scripts/local_config_select.sh
```

Prioridad de deteccion:

1. `--device <nombre>`
2. variable `CLAWMOBIL_DEVICE`
3. archivo `Mis_configuraciones_locales/dispositivos/.active_device`
4. `DEVICE_NAME` en `config/config.sh`

Para usarlo en shell:

```bash
eval "$(bash scripts/local_config_select.sh)"
echo "$CLAWMOBIL_DEVICE_DIR"
```

## 4) Evaluacion y discovery de mejoras

Evaluacion de completitud:

```bash
bash scripts/local_config_evaluate.sh
```

Discovery de candidatos reutilizables respecto a `_plantilla`:

```bash
bash scripts/local_config_discovery.sh
```

Detector automatico (notifica cuando cambia algo y dispara discovery):

```bash
bash scripts/local_config_watch.sh
bash scripts/local_config_watch.sh --loop --interval 30
```

Ambos generan reportes en:

```text
Mis_configuraciones_locales/reportes/
```

## 5) Promocion controlada a plantilla

Cuando un ajuste local es valido para mas forks:

```bash
bash scripts/local_config_promote.sh <dispositivo> <ruta_relativa>
```

Caracteristicas:

- Hace backup de la version previa en `_plantilla/_historial/`
- Registra trazabilidad en `Mis_configuraciones_locales/reportes/promociones.log`
- Bloquea archivos sensibles (`claves.env`, claves privadas, etc.)

## 6) Laboratorio reversible (snapshots)

Crear snapshot:

```bash
bash scripts/local_config_lab.sh snapshot <dispositivo>
```

Listar snapshots:

```bash
bash scripts/local_config_lab.sh list <dispositivo>
```

Comparar con estado actual:

```bash
bash scripts/local_config_lab.sh diff <dispositivo> <snapshot.tar.gz>
```

Restaurar:

```bash
bash scripts/local_config_lab.sh restore <dispositivo> <snapshot.tar.gz>
```

## 7) Flujo recomendado para jurado/equipo

1. Crear perfil desde wizard.
2. Ejecutar despliegue local en dispositivo.
3. Ejecutar `evaluate` + `discovery`.
4. Revisar candidatos en reporte.
5. Promover solo lo reusable con `promote`.
6. Si algo falla, restaurar snapshot con `local_config_lab.sh`.

Prueba automatica de todo el flujo (sin hardware):

```bash
bash scripts/local_config_selftest.sh
bash scripts/wizard_local_smoketest.sh
```

Checklist para directo:

```bash
bash scripts/prelive_direct_check.sh
```

Con este esquema, cada dispositivo es unico, pero sus mejoras pueden subir a la
plantilla comun de manera controlada, reversible y auditable.
