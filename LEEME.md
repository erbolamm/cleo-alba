# LEEME — Punto de entrada de ClawMobil

Este repositorio se usa como framework modular para convertir Android antiguos en nodos de IA personalizados.

## Si eres usuario no técnico, sigue solo esto

1. Abre [`index.html`](index.html).
2. Haz clic en **Abrir asistente (`empezar.html`)**.
3. En el wizard genera tu perfil local (`config_profile.json`) y copia el comando sugerido.
4. Guarda todo en `Mis_configuraciones_locales/dispositivos/<tu_dispositivo>/`.
5. Valida con:

```bash
bash scripts/local_config_select.sh --json
bash scripts/local_config_evaluate.sh
bash scripts/local_config_discovery.sh
```

## Regla de colaboración

- Todo lo experimental va en `Mis_configuraciones_locales/`.
- Solo se promueve a plantilla lo reutilizable y sin secretos.
- Si algo falla, revierte con snapshots (`scripts/local_config_lab.sh`).

## Estructura mínima que debes entender

```text
ClawMobil/
├── index.html                     # Entrada sencilla para humanos
├── LEEME.md                       # Guía rápida principal
├── empezar.html                   # Wizard de configuración local
├── scripts/local_config_*.sh      # Evaluar / descubrir / promover / revertir
└── Mis_configuraciones_locales/   # Tu fork local (gitignored)
```

## Fuente de OpenClaw prioritaria

ClawMobil debe operar tomando como referencia el fork:

- <https://github.com/erbolamm/openclaw>

La auditoría del repositorio original y sugerencias para portar mejoras está en:

- `docs/AUDITORIA_OPENCLAW_ORIGINAL_2026-02-27.md`
