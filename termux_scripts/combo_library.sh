#!/data/data/com.termux/files/usr/bin/bash
# combo_library.sh v5.2 — Biblioteca simplificada con comando 'show' para ApliBot
# Uso: bash combo_library.sh <nombre_combo>
# Uso: bash combo_library.sh list  (ver todos los combos disponibles)
# Uso: bash combo_library.sh custom "🎯" "Texto personalizado"

CAM_CMD="/sdcard/.cam_cmd"

send_combo() {
    local emoji="$1"
    local text="$2"
    echo "show:${text} ${emoji}" > "$CAM_CMD"
    echo "✅ Enviado a pantalla: ${text} ${emoji}"
}

send_emoji() {
    local emoji="$1"
    echo "show:${emoji}" > "$CAM_CMD"
    echo "✅ Emoji enviado: ${emoji}"
}

send_tts() {
    local text="$1"
    echo "show:${text}" > "$CAM_CMD"
    echo "✅ TTS enviado: \"${text}\""
}

# ── BIBLIOTECA DE COMBOS ──────────────────────────────────────────

case "${1}" in

    # ❤️ AFECTIVOS
    te_quiero|love)
        send_combo "❤️" "Te quiero" ;;
    increible)
        send_combo "🥰" "Eres increíble" ;;
    beso)
        send_combo "😘" "Un beso grande" ;;
    animo|fuerza)
        send_combo "💪" "Tú puedes con todo" ;;
    abrazo)
        send_combo "🤗" "Un abrazo virtual para ti" ;;

    # ⏰ RUTINAS DIARIAS
    buenos_dias|gm)
        send_combo "☀️" "Buenos días, hora de levantarse" ;;
    buenas_noches|gn)
        send_combo "🌙" "Buenas noches, descansa bien" ;;
    cafe)
        send_combo "☕" "La hora del café, un descanso merecido" ;;
    comer|lunch)
        send_combo "🍽️" "Es hora de comer" ;;
    agua)
        send_combo "💧" "Recuerda beber agua" ;;
    descanso|break)
        send_combo "🧘" "Hora de un descanso, estira las piernas" ;;

    # 🔔 ALERTAS Y AVISOS
    bateria|battery)
        send_combo "🪫" "Batería baja, conecta el cargador" ;;
    movimiento|motion)
        send_combo "🚨" "Movimiento detectado en la sala" ;;
    mensaje|msg)
        send_combo "📬" "Tienes un mensaje nuevo en Telegram" ;;
    calor|hot)
        send_combo "🌡️" "Hace mucho calor, abre la ventana" ;;
    lluvia|rain)
        send_combo "🌧️" "Va a llover, recoge la ropa tendida" ;;
    wifi_caido)
        send_combo "📡" "Se ha caído la conexión WiFi" ;;
    wifi_ok)
        send_combo "📡" "Conexión a internet restaurada" ;;

    # 🤖 SISTEMA Y DEBUG
    ok|ready)
        send_combo "✅" "Todos los sistemas operativos" ;;
    reiniciando|restart)
        send_combo "🔄" "Reiniciando servicios, un momento" ;;
    pensando|thinking)
        send_combo "🧠" "Procesando solicitud, espera un segundo" ;;
    error)
        send_combo "❌" "Se ha detectado un error en el sistema" ;;
    actualizando|update)
        send_combo "⬆️" "Actualizando el sistema, no apagues" ;;
    backup)
        send_combo "💾" "Backup completado correctamente" ;;

    # 🎉 EVENTOS Y DIVERSIÓN
    felicidades|congrats)
        send_combo "🎉" "Felicidades, meta conseguida" ;;
    logro|achievement)
        send_combo "🏆" "Nuevo logro desbloqueado" ;;
    musica|music)
        send_combo "🎵" "Poniendo música para animar el ambiente" ;;
    risa|lol)
        send_combo "🤣" "Eso ha sido muy gracioso" ;;
    fiesta|party)
        send_combo "🥳" "Es hora de celebrar" ;;

    # 🖥️ OSC25 STAND
    bienvenida|welcome)
        send_combo "👋" "Bienvenido al stand de ApliBot, pregúntame lo que quieras" ;;
    soy_aplibot|intro)
        send_combo "🤖" "Soy ApliBot, vivo dentro de un móvil reciclado" ;;
    open_source|libre)
        send_combo "🐧" "Todo esto funciona con software libre" ;;
    demo)
        send_combo "🎪" "Esto es una demostración en vivo de ApliBot" ;;
    gracias|thanks)
        send_combo "🙏" "Gracias por visitar nuestro stand" ;;
    qr)
        send_combo "📱" "Escanea el código QR para más información" ;;

    # 🎭 SOLO EMOJI (sin voz)
    corazon)
        send_emoji "❤️" ;;
    fuego)
        send_emoji "🔥" ;;
    estrella)
        send_emoji "⭐" ;;
    ojo)
        send_emoji "👁️" ;;
    robot)
        send_emoji "🤖" ;;

    # 🛠️ PERSONALIZADO
    custom)
        if [ -z "$2" ] || [ -z "$3" ]; then
            echo "Uso: $0 custom \"<emoji>\" \"<texto>\""
            echo "Ej:  $0 custom \"🎯\" \"Objetivo cumplido\""
            exit 1
        fi
        send_combo "$2" "$3"
        ;;

    # TTS (solo voz, sin emoji)
    say|decir)
        if [ -z "$2" ]; then
            echo "Uso: $0 say \"texto a decir\""
            exit 1
        fi
        echo "show:$2" > "$CAM_CMD"
        echo "🔊 TTS enviado: \"$2\""
        ;;

    # 📋 LISTAR TODOS
    list|help|ayuda|"")
        echo "╔══════════════════════════════════════════════════╗"
        echo "║       🤖 ApliBot Combo Library v1.0             ║"
        echo "╠══════════════════════════════════════════════════╣"
        echo "║  Uso: bash combo_library.sh <comando>           ║"
        echo "╠══════════════════════════════════════════════════╣"
        echo "║                                                  ║"
        echo "║  ❤️  AFECTIVOS                                   ║"
        echo "║   te_quiero  love  increible  beso  animo  abrazo║"
        echo "║                                                  ║"
        echo "║  ⏰ RUTINAS                                      ║"
        echo "║   buenos_dias  buenas_noches  cafe  comer        ║"
        echo "║   agua  descanso                                 ║"
        echo "║                                                  ║"
        echo "║  🔔 ALERTAS                                      ║"
        echo "║   bateria  movimiento  mensaje  calor  lluvia    ║"
        echo "║   wifi_caido  wifi_ok                            ║"
        echo "║                                                  ║"
        echo "║  🤖 SISTEMA                                      ║"
        echo "║   ok  reiniciando  pensando  error               ║"
        echo "║   actualizando  backup                           ║"
        echo "║                                                  ║"
        echo "║  🎉 DIVERSIÓN                                    ║"
        echo "║   felicidades  logro  musica  risa  fiesta       ║"
        echo "║                                                  ║"
        echo "║  🖥️  OSC25 STAND                                 ║"
        echo "║   bienvenida  soy_aplibot  open_source  demo     ║"
        echo "║   gracias  qr                                    ║"
        echo "║                                                  ║"
        echo "║  🎭 SOLO EMOJI (sin voz)                         ║"
        echo "║   corazon  fuego  estrella  ojo  robot           ║"
        echo "║                                                  ║"
        echo "║  🛠️  PERSONALIZADO                               ║"
        echo "║   custom \"🎯\" \"Texto\"                            ║"
        echo "║   say \"Texto a decir\"                            ║"
        echo "╚══════════════════════════════════════════════════╝"
        ;;

    *)
        echo "❌ Combo desconocido: '$1'"
        echo "   Usa 'bash combo_library.sh list' para ver todos."
        exit 1
        ;;
esac
