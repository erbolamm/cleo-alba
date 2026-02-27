# Auditoría Huawei P10 pre-directo (solo lectura)

Fecha: 2026-02-27
Dispositivo auditado: Huawei P10 (`VTR-L09`, serial `<DEVICE_SERIAL>`)

## Alcance y restricciones aplicadas

1. Solo lectura.
2. Sin `setprop`, sin reinicios, sin matar procesos.
3. Sin modificar configuración del sistema.

## Comando ejecutado

```bash
adb -s <DEVICE_SERIAL> shell "echo '[DEVICE]'; getprop ro.product.model; getprop ro.product.manufacturer; getprop ro.build.version.release; getprop ro.build.version.sdk; getprop ro.product.cpu.abi; echo '[BATTERY]'; dumpsys battery | sed -n '1,30p'; echo '[STORAGE]'; df -h /data /sdcard 2>/dev/null; echo '[MEMORY]'; cat /proc/meminfo | sed -n '1,8p'; echo '[PROCESSES]'; ps -A 2>/dev/null | grep -Ei 'openclaw|gateway|python|termux|http|file' | grep -v grep || true; echo '[NETSTAT]'; netstat -lnt 2>/dev/null || true"
```

## Resultados

### Identidad y plataforma

- Modelo: `VTR-L09`
- Fabricante: `HUAWEI`
- Android: `9`
- SDK: `28`
- ABI: `arm64-v8a`

### Estado de hardware

- Batería: `65%`, `AC powered: true`, `health: 2 (good)`, `temperature: 35.0C`
- Almacenamiento:
  - `/data`: `53G total`, `21G usado`, `31G libre` (`41%` uso)
  - `/sdcard` (`/storage/emulated`): `53G total`, `31G libre`
- Memoria:
  - `MemTotal`: `3804644 kB` (~3.8 GB)
  - `MemAvailable`: `1633756 kB` (~1.6 GB)

### Servicios y procesos activos observados

- `com.termux`
- `python3`
- `openclaw`
- `openclaw-gateway`
- procesos del sistema de archivos (`rfile`, `file-storage`)

### Puertos de servicio (listen)

- `127.0.0.1:18789` (gateway local)
- `127.0.0.1:18792` (servicio local auxiliar)
- `0.0.0.0:8080` (servidor HTTP/transferencia)
- `0.0.0.0:8022` (acceso SSH/Termux)

## Conclusión operativa

El Huawei P10 está en condiciones operativas para quedar como **backup del directo**:

1. Servicios clave levantados (`openclaw`, `openclaw-gateway`, `python3`, `termux`).
2. Recursos de hardware aceptables para contingencia en vivo.
3. Puertos esperados en escucha sin evidencia de conflicto crítico inmediato.

## Recomendación inmediata de uso en directo

1. Mantener este P10 sin cambios hasta finalizar el directo.
2. Usar el segundo dispositivo para toda la demostración modular.
3. Si hay caída en el segundo dispositivo, usar el P10 en modo fallback mostrando gateway activo + flujo básico de validación.
