# 📦 Recursos Termux — APKs de instalación

## ¿Qué hay aquí?

Los APKs de **Termux y sus complementos** listos para instalar vía ADB en cualquier dispositivo nuevo o reseteado.
No hace falta descargarlos de F-Droid ni de internet — están aquí en el repo.

## APKs disponibles

| APK | Versión | Para qué sirve |
|---|---|---|
| `com.termux_118.apk` | v118 | **Termux** — Terminal Linux en Android (el cerebro del bot) |
| `com.termux.boot_7.apk` | v7 | **Termux:Boot** — Auto-arranque de scripts al encender |
| `com.termux.api_51.apk` | v51 | **Termux:API** — Acceso a hardware: cámara, micro, batería, WiFi |

## Cómo instalar (desde Mac vía ADB)

```bash
# Instalar los tres de una vez:
adb install recursos_termux/com.termux_118.apk
adb install recursos_termux/com.termux.boot_7.apk
adb install recursos_termux/com.termux.api_51.apk

# Si hay un dispositivo específico:
adb -s <SERIAL> install recursos_termux/com.termux_118.apk
```

## ⚠️ Importante

- Estos APKs son de **F-Droid** (no de Play Store). Los de Play Store son legacy y no se actualizan.
- Después de instalar, **abre Termux al menos una vez** manualmente antes de que Termux:Boot funcione.
- Las tres apps deben venir de la **misma fuente** (F-Droid). Mezclar con Play Store causa errores de firma.

## Actualización

Para actualizar los APKs, descarga las versiones más recientes desde:
- https://f-droid.org/en/packages/com.termux/
- https://f-droid.org/en/packages/com.termux.boot/
- https://f-droid.org/en/packages/com.termux.api/
