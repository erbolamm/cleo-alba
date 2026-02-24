#!/data/data/com.termux/files/usr/bin/bash
# camera_bridge.sh v5.2 — Comando único 'show' para pantalla y audio sincronizado.
TRIGGER="/sdcard/.cam_cmd"
RESULT="/sdcard/.cam_result"
STATE_FILE="/sdcard/.cam_state"
PHOTO_DIR="/sdcard/DCIM"
SEND_SCRIPT="/data/data/com.termux/files/home/send_to_telegram.sh"

mkdir -p "$PHOTO_DIR"
echo "idle" > "$STATE_FILE"

echo "📷 Camera Bridge v5.2 iniciado (Unified 'show' command)"

while true; do
    if [ -f "$TRIGGER" ]; then
        CMD=$(cat "$TRIGGER" | tr "[:upper:]" "[:lower:]" | xargs)
        rm -f "$TRIGGER"
        rm -f "$RESULT"
        
        case "$CMD" in
            foto|back)
                echo "foto" > "$STATE_FILE"
                FNAME="$PHOTO_DIR/openclaw_$(date +%Y%m%d_%H%M%S).jpg"
                termux-camera-photo -c 0 "$FNAME" 2>/dev/null
                bash "$SEND_SCRIPT" "$FNAME" "📸 Foto trasera" 2>/dev/null &
                echo "$FNAME" > "$RESULT"
                sleep 1
                echo "idle" > "$STATE_FILE"
                ;;
            selfie|front)
                echo "selfie" > "$STATE_FILE"
                FNAME="$PHOTO_DIR/selfie_$(date +%Y%m%d_%H%M%S).jpg"
                termux-camera-photo -c 1 "$FNAME" 2>/dev/null
                bash "$SEND_SCRIPT" "$FNAME" "🤳 Selfie" 2>/dev/null &
                echo "$FNAME" > "$RESULT"
                sleep 1
                echo "idle" > "$STATE_FILE"
                ;;
            grabar|audio)
                echo "recording" > "$STATE_FILE"
                FNAME="/sdcard/audio_$(date +%Y%m%d_%H%M%S).m4a"
                echo "recording:$FNAME" > "$RESULT"
                ( 
                    termux-microphone-record -l 10 -f "$FNAME" 2>/dev/null
                    sleep 10
                    if [ -s "$FNAME" ]; then
                        bash "$SEND_SCRIPT" "$FNAME" "🎙️ Audio (10s)" 2>/dev/null
                    fi
                    echo "idle" > "$STATE_FILE"
                ) &
                echo $! > /tmp/rec_pid
                ;;
            stop)
                termux-microphone-record -q 2>/dev/null
                if [ -f /tmp/rec_pid ]; then
                    kill $(cat /tmp/rec_pid) 2>/dev/null
                    rm -f /tmp/rec_pid
                fi
                echo "stopped" > "$RESULT"
                echo "idle" > "$STATE_FILE"
                ;;
            compartir:*)
                FILE="${CMD#*:}"
                echo "sharing" > "$STATE_FILE"
                if [ -f "$FILE" ]; then
                    bash "$SEND_SCRIPT" "$FILE" "📤 Compartido" 2>/dev/null &
                    echo "sent:$FILE" > "$RESULT"
                else
                    echo "error:no_file" > "$RESULT"
                fi
                sleep 2
                echo "idle" > "$STATE_FILE"
                ;;
            pantalla|display)
                # Abrir la App de ApliBot en la pestaña Avatar directamente
                am start -n com.apliarte.bot/com.apliarte.bot.MainActivity > /dev/null 2>&1 &
                echo "display_opened" > "$RESULT"
                # Volvemos a modo idle rápido para que esté lista
                echo "idle" > "$STATE_FILE"
                ;;
            play:*)
                FILE="${CMD#*:}"
                if [ -f "$FILE" ]; then
                    echo "playing" > "$STATE_FILE"
                    # Calculamos duracion basica si es posible, o mantenemos estado 5s
                    termux-media-player play "$FILE" 2>/dev/null &
                    echo "playing:$FILE" > "$RESULT"
                    # Un sleep demostrativo, lo ideal seria detectar cuando acaba,
                    # Termux no avisa facilmente cuando un audio asincrono termina.
                    # Asumimos una notificacion breve:
                    sleep 5
                    echo "idle" > "$STATE_FILE"
                else
                    echo "error:no_file" > "$RESULT"
                fi
                ;;
            show:*)
                TEXT="${CMD#*:}"
                echo "show:$TEXT" > "$STATE_FILE"
                # TTS Robusto: espeak -> WAV -> termux-media-player
                WAV="/sdcard/tts_temp.wav"
                espeak -v es "$TEXT" --stdout > "$WAV" 2>/dev/null
                termux-media-player play "$WAV" >/dev/null 2>&1 &
                PLAY_PID=$!
                
                # Esperamos a que el proceso de reproducción termine o timeout
                WAITED=0
                while kill -0 $PLAY_PID 2>/dev/null && [ $WAITED -lt 15 ]; do
                    sleep 1
                    WAITED=$((WAITED + 1))
                done
                
                echo "shown:$TEXT" > "$RESULT"
                sleep 1
                echo "idle" > "$STATE_FILE"
                ;;
            tts:*)
                TEXT="${CMD#*:}"
                echo "tts:$TEXT" > "$STATE_FILE"
                # Mismo sistema robusto
                WAV="/sdcard/tts_temp.wav"
                espeak -v es "$TEXT" --stdout > "$WAV" 2>/dev/null
                termux-media-player play "$WAV" >/dev/null 2>&1 &
                PLAY_PID=$!
                
                WAITED=0
                while kill -0 $PLAY_PID 2>/dev/null && [ $WAITED -lt 15 ]; do
                    sleep 1
                    WAITED=$((WAITED + 1))
                done
                
                echo "spoken:$TEXT" > "$RESULT"
                sleep 1
                echo "idle" > "$STATE_FILE"
                ;;
            *)
                echo "error:comando_desconocido" > "$RESULT"
                ;;
        esac
    fi
    sleep 0.5
done
