# Deploy al teléfono YesTeL

Enviar archivos o ejecutar acciones en el YesTeL Note 30 Pro vía ADB.

## Variables del dispositivo:
- Serial: `NOTE10PRO000400`
- SD Card: `/storage/8245-190E/`
- SSH: puerto 8022 (Termux)

## Operaciones disponibles:

### Enviar archivo al teléfono:
```bash
adb -s NOTE10PRO000400 push <archivo_local> /sdcard/<destino>
```

### Instalar APK:
```bash
adb -s NOTE10PRO000400 install -r <archivo.apk>
```

### Abrir URL en Fulguris:
```bash
adb -s NOTE10PRO000400 shell am start -a android.intent.action.VIEW -d "<URL>"
```

### Ejecutar comando en PRoot Debian:
```bash
ssh -p 8022 localhost "proot-distro login debian -- bash -c '<comando>'"
```

### Hacer captura de pantalla:
```bash
adb -s NOTE10PRO000400 shell screencap -p /sdcard/scr.png && adb -s NOTE10PRO000400 pull /sdcard/scr.png /tmp/scr.png
```

## Reglas:
- SIEMPRE usar `-s NOTE10PRO000400` con ADB
- Verificar conexión antes de cualquier operación
- Comandos Android (`am start`, `input tap`) → SOLO desde Termux nativo
- Comandos Linux (`apt`, `node`, `python`) → SOLO desde PRoot Debian
