---
description: Cómo instalar ClawMobil Chat en cualquier teléfono Android desde el Mac
---

# Instalar ClawMobil en cualquier teléfono

## Preparación (una vez)

// turbo
1. Copiar la APK al directorio demo:
```bash
cp /Users/apliarte/trabajo/ClawMobil/Mis_configuraciones_locales/dispositivos/yestel_server/chat_app/build/app/outputs/flutter-apk/app-release.apk /Users/apliarte/trabajo/ClawMobil/demo/ClawMobil-Chat.apk
```

## Instalación en cualquier teléfono

// turbo-all

1. Conectar el teléfono Android por USB al Mac
2. En el teléfono, aceptar "¿Permitir depuración USB?" si aparece
3. Ejecutar el instalador:
```bash
cd /Users/apliarte/trabajo/ClawMobil/demo && ./instalar_claw.sh
```
4. ¡Listo! La aplicación se abre automáticamente

## Si no tiene ADB instalado (ordenador de otra persona)

1. Instalar Homebrew (si no lo tiene):
```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

2. Instalar ADB:
```bash
brew install android-platform-tools
```

3. Copiar la carpeta `demo/` al ordenador (pendrive, AirDrop, etc.)

4. Ejecutar:
```bash
cd demo && ./instalar_claw.sh
```

## Activar Depuración USB en el teléfono

1. Ir a **Ajustes → Acerca del teléfono**
2. Pulsar 7 veces sobre **Número de compilación** → aparecerá "Ya eres desarrollador"
3. Ir a **Ajustes → Opciones de desarrollador**
4. Activar **Depuración USB**
5. Conectar cable USB y aceptar el popup

## Configurar el servidor de IA

Si el servidor Ollama está en otro dispositivo de la misma WiFi:
1. Abrir la App → ⚙️ Ajustes
2. Cambiar URL Local a `http://IP_DEL_SERVIDOR:11434`
3. Guardar
