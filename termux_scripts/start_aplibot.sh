#!/data/data/com.termux/files/usr/bin/bash
# ApliBot Master Start Script (v5.2 - Consolidated)
echo "[$(date)] Iniciando ApliBot Master Script v5.2..." > /sdcard/aplibot_start.log

# 0. Pequeña pausa para que el servidor responda "OK" a la App antes de morir
sleep 2

# 1. Limpieza Agresiva de procesos viejos (Evita "Address already in use")
echo "[$(date)] Matando procesos de ApliBot antiguos..." >> /sdcard/aplibot_start.log
# Buscar y matar cualquier Python/Bash que parezca de nuestro stack
for pid in $(pgrep -f "camera_bridge.sh|server.py|bridge_server.py|python3 /sdcard/server.py"); do
    echo "  -> Matando PID $pid" >> /sdcard/aplibot_start.log
    kill -9 $pid 2>/dev/null
done

# Limpiar puertos huérfanos forzosamente (8080 y 5000)
fuser -k -9 8080/tcp 2>/dev/null
fuser -k -9 5000/tcp 2>/dev/null

sleep 2 # Dar tiempo a que los sockets se liberen realmente

# 2. Iniciar Camera Bridge
if [ -f "/sdcard/camera_bridge.sh" ]; then
    echo "[$(date)] Iniciando Camera Bridge..." >> /sdcard/aplibot_start.log
    nohup bash /sdcard/camera_bridge.sh > /sdcard/camera_bridge.log 2>&1 &
    # Enviar comando genérico por defecto
    echo "show:ApliBot Master v5.2" > /sdcard/.cam_cmd
else
    echo "[$(date)] ERROR: camera_bridge.sh no encontrado en /sdcard/" >> /sdcard/aplibot_start.log
fi

# 3. Iniciar Servidor Unificado (Avatar + Uploads + Sync)
if [ -f "/sdcard/server.py" ]; then
    echo "[$(date)] Iniciando Servidor Unificado (server.py)..." >> /sdcard/aplibot_start.log
    cd /sdcard
    nohup python3 /sdcard/server.py > /sdcard/server.log 2>&1 &
else
    echo "[$(date)] ERROR: server.py no encontrado en /sdcard/" >> /sdcard/aplibot_start.log
fi

echo "[$(date)] Script Maestro completado." >> /sdcard/aplibot_start.log
