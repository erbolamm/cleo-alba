# Diagnosticar el teléfono YesTeL Note 30 Pro

Ejecuta un diagnóstico completo del dispositivo YesTeL Note 30 Pro (serial: <TU_SERIAL_ADB>).

## Pasos obligatorios:

1. **Verificar conexión ADB:**
   ```
   adb -s <TU_SERIAL_ADB> get-state
   ```

2. **Estado de memoria y almacenamiento:**
   ```
   adb -s <TU_SERIAL_ADB> shell free -h
   adb -s <TU_SERIAL_ADB> shell df -h /data /sdcard
   ```

3. **Procesos más pesados:**
   ```
   adb -s <TU_SERIAL_ADB> shell top -n 1 -b | head -20
   ```

4. **Estado de Termux y PRoot:**
   - Verificar que SSH funciona: `ssh -p 8022 localhost "echo OK"`
   - Verificar PRoot: `ssh -p 8022 localhost "proot-distro login debian -- bash -c 'echo PRoot OK'"`

5. **Estado del Gateway OpenClaw:**
   ```
   ssh -p 8022 localhost "proot-distro login debian -- bash -c 'curl -s http://localhost:18789/health || echo GATEWAY_CAIDO'"
   ```

6. **Estado de la SD Card:**
   ```
   adb -s <TU_SERIAL_ADB> shell df -h /storage/8245-190E/
   ```

## Formato de respuesta:
Presentar un resumen en tabla con estado ✅/❌ de cada componente.
Si algo falla, proponer la solución antes de preguntar.
