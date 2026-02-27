# Auditoría del repositorio original OpenClaw

Fecha de auditoría: **2026-02-27**

## 1) Alcance

Objetivo: revisar el repositorio upstream `openclaw/openclaw`, detectar funcionalidades útiles para ClawMobil y documentar riesgos críticos a considerar antes de integrar cambios en `erbolamm/openclaw`.

## 2) Fuentes primarias revisadas

- `README.md` upstream (raw): <https://raw.githubusercontent.com/openclaw/openclaw/main/README.md>
- `package.json` upstream (raw): <https://raw.githubusercontent.com/openclaw/openclaw/main/package.json>
- Página del repo upstream: <https://github.com/openclaw/openclaw>
- Docs de seguridad (gateway): <https://www.openclaw.dev/docs/gateway/security>
- Docs de troubleshooting: <https://www.openclaw.dev/docs/troubleshooting/common-issues>
- Docs de Telegram: <https://www.openclaw.dev/docs/channels/telegram>

## 3) Hallazgos útiles para portar al fork `erbolamm/openclaw`

1. **Onboarding CLI estructurado**
   - El flujo `openclaw onboard` y comandos de diagnóstico (`status`, `doctor`) están bien definidos para puesta en marcha rápida.
   - Recomendación: mantener exactamente ese flujo en el fork para usuarios no técnicos.

2. **Modelo de seguridad por gateway**
   - La documentación de seguridad del gateway enfatiza exposición controlada (bind local / autenticación).
   - Recomendación: fijar defaults seguros para ClawMobil (bind local + auth explícita cuando se abra red).

3. **Canales con reglas de acceso**
   - En Telegram, el concepto `dmPolicy`/aprobación de DM permite controlar quién puede activar el bot.
   - Recomendación: preconfigurar políticas de allowlist en plantillas de ClawMobil.

4. **Procedimientos de troubleshooting reutilizables**
   - La guía upstream tiene secuencia clara para logs/estado/diagnóstico.
   - Recomendación: incorporar esa secuencia en scripts locales (`audit`, `evaluate`, `watch`) para soporte guiado.

## 4) Problemas críticos detectados en upstream (impacto ClawMobil)

1. **Requisitos de runtime elevados**
   - En el `README` y `package.json` se observa foco en runtimes modernos (Node >= 22.12, paquete en versión alta).
   - Riesgo: dispositivos muy antiguos pueden sufrir inestabilidad o coste alto de mantenimiento.

2. **Alta volatilidad del upstream**
   - La página del repo muestra volumen alto de actividad y cola grande (issues/PR/security) en la fecha auditada.
   - Riesgo: cambios frecuentes pueden romper flujos de despliegue ya validados en ClawMobil.

3. **Superficie de plugins/habilidades**
   - El diseño modular habilita extensiones potentes, pero también aumenta riesgo operacional si se instalan componentes no auditados.
   - Riesgo: fuga de claves, permisos excesivos o regresiones por dependencias de terceros.

4. **Riesgo de exposición de gateway**
   - Upstream advierte sobre configuración de seguridad en red; mal configurado, el gateway queda demasiado expuesto.
   - Riesgo: acceso remoto no autorizado y abuso de recursos/API.

## 5) Recomendaciones de integración a `erbolamm/openclaw`

1. Mantener una **rama estable fijada por versión** para ClawMobil, con ventana de actualización controlada.
2. Publicar un **perfil "legacy Android"** (memoria baja, canales mínimos, herramientas limitadas).
3. Exigir en plantillas un **baseline de seguridad**:
   - bind local por defecto,
   - auth activa al exponer red,
   - allowlist de usuarios/canales.
4. Añadir **pruebas de compatibilidad** para comandos críticos (`onboard`, `status`, `doctor`, `gateway run`) antes de cada promoción.
5. Documentar un **changelog de portabilidad** upstream -> fork para saber qué se trae, por qué y con qué riesgo.

## 6) Estado de verificación del fork

- Se fijó en ClawMobil la referencia de repositorio prioritaria: `https://github.com/erbolamm/openclaw`.
- En este entorno no fue posible clonar repositorios externos por restricción de red del shell local.
- La auditoría técnica se basa en fuentes públicas upstream y se orienta a migrar mejoras al fork controlado.
