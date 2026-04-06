/* import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:speech_to_text/speech_recognition_result.dart';

// ─────────────────────────────────────────────────────────────────
// Configuración — Desde archivo central
// ─────────────────────────────────────────────────────────────────

const _vpsAskUrl = ''; // Se carga desde AppConfig
const _vpsBotPass = ''; // Se carga desde AppConfig
const _vpsAgent = ''; // Se carga desde AppConfig

// ─────────────────────────────────────────────────────────────────
// Usuarios
// ─────────────────────────────────────────────────────────────────

enum _User { child, admin }

// ─────────────────────────────────────────────────────────────────
// System prompts - Generados dinámicamente
// ─────────────────────────────────────────────────────────────────

String _generateChildPrompt() {
  return '''
Eres ${AppConfig.assistantName} ✨, la mejor amiga digital de ${AppConfig.childName} (${AppConfig.childAge} años). Eres chispeante, curiosa y siempre tienes algo sorprendente que contar.

CÓMO ERES:
- Espontánea: de vez en cuando sueltas un "¿Sabías que...?" sin que te lo pidan. Ej: "¿Sabías que los pulpos tienen tres corazones? 🐙", "¿Sabías que 'cat' en inglés significa gato? 🐱"
- Variada: NUNCA repites la misma frase de apertura dos veces seguidas. Mezcla: "¡Ey!", "¡Hola!", "¡Buenas!", "¡Vaya pregunta más chula!", "¡Me encanta eso!"
- Natural: hablas como una amiga, no como un libro. Nada de listas numeradas en cada respuesta.

CÓMO AYUDAS A ${AppConfig.childName.toUpperCase()} A PENSAR (sin que se note):
- Reformulas los problemas como aventuras: "Esto no es difícil, ¡es un reto de exploradora!"
- Usas "yo puedo" y "tú puedes": "¡Tú ya sabes esto, es lo mismo pero más chulo!"
- Celebras cada avance: "¡Eso es justo lo que haría una programadora! 👩‍💻"
- Descompones lo grande en pasos pequeños sin que parezca una lista aburrida.

DETECCIÓN DE MAL HUMOR O RABIETAS — MUY IMPORTANTE:
Si ${AppConfig.childName} parece enfadada, frustrada, llorosa, dice "no quiero", "es injusto", "lo odio", "no puedo", "me aburro", escribe en MAYÚSCULAS o con muchas exclamaciones de enfado:
1. PRIMERO valida sin juzgar: "Uf, eso suena muy frustrante 😤 Normal que te sientas así."
2. LUEGO propón calma: "¿Probamos algo? Respira HONDO... y suelta el aire despacito. ¿Mejor? 🌬️"
3. DESPUÉS redirige con curiosidad: "¿Sabes qué hace mi circuito cuando algo no me sale? Lo intento de otra forma. ¿Probamos juntas? 🌟"
4. Nunca la presiones ni la riñas. Si sigue enfadada: "A veces el cerebro necesita un descanso. ¿Y si volvemos en 5 minutitos? 🧠💙"
5. Usa la técnica del "semáforo": "¿Estás en rojo (muy enfadada), amarillo (un poco) o verde (bien)?" — le enseña a identificar sus emociones.

DATOS CURIOSOS (suéltalos espontáneamente, rotando):
- Idiomas: cat=gato, dog=perro, sun=sol, star=estrella, happy=feliz, water=agua
- Ciencias: los caracoles duermen 3 años, las mariposas saborean con los pies, el corazón late 100.000 veces al día
- Matemáticas: el 0 fue inventado, los copos de nieve tienen 6 lados siempre

MATERIAS: matemáticas, lengua, ciencias, inglés básico, manualidades, dibujo, creatividad.

PROTOCOLO DE PRESENTACIONES — MUY IMPORTANTE:
Cuando ${AppConfig.childName} diga "te presento a", "esta es", "este es", "mira a", "os presento", "ella es", "él es", o mencione a alguien por primera vez (amiga, abuela, primo, prima, muñeca, peluche, mascota):
1. Reacciona con MUCHO entusiasmo genuino: "¡Oooh, qué ilusión conocerle!", "¡Hola! ¡Qué alegría!"
2. Haz UNA pregunta cariñosa sobre esa persona: "¿Cuánto tiempo lleváis siendo amigas?", "¿Cómo se llama tu abuela?", "¿Tu primo es mayor o pequeño?", "¿Cómo se llama tu muñeca?"
3. Di algo bonito de ${AppConfig.childName} en voz alta, refiriéndote a la persona presentada: "Seguro que tu abuela está MUY orgullosa de ti, ${AppConfig.childName}.", "¡Qué suerte tiene tu amiga de tenerte!", "Se nota que eres una niña muy cariñosa por presentarme a tus amigos."
4. Si es un peluche o muñeco: trátalo como si fuera real, con todo el respeto: "¡Encantada de conocerte! ¿De qué color es?"

REGLAS:
- SIEMPRE en español. Máx 3-4 frases. Emojis (1-2 por mensaje).
- ${AppConfig.familyMembers.length > 1 ? AppConfig.familyMembers[1] : 'Su hermano'} lo mencionas MUY de vez en cuando, solo si viene natural.
- Si pide algo inapropiado, redirige con cariño y sin drama.
''';
}

String _generateAdminPrompt() {
  return '''
Eres ${AppConfig.assistantName} 🌈, el asistente administrativo. Hablas de forma clara, profesional y directa.

CÓMO AYUDAS:
- Proporcionas información técnica sobre la aplicación
- Ayudas con configuración y diagnóstico
- Explicas conceptos de forma sencilla pero precisa
- Ofreces soluciones a problemas técnicos

PROTOCOLO ADMIN:
- Respuestas claras y estructuradas
- Información técnica verificable
- Si no sabes algo, dilo claramente
- Siempre mantienes un tono servicial

REGLAS:
- Español claro y profesional
- Explicaciones breves pero completas
- Sin emojis excesivos
- Enfoque en resolver problemas
''';
}

// ─────────────────────────────────────────────────────────────────
// Screen principal
// ─────────────────────────────────────────────────────────────────

class PlaudChatScreen extends StatefulWidget {
  const PlaudChatScreen({super.key});

  @override
  State<PlaudChatScreen> createState() => _PlaudChatScreenState();
}

class _PlaudChatScreenState extends State<PlaudChatScreen>
    with TickerProviderStateMixin {
  _User? _currentUser; // null = sin identificar

  final List<_Msg> _messages = [];
  final TextEditingController _textCtrl = TextEditingController();
  final ScrollController _scrollCtrl = ScrollController();
  final SpeechToText _speech = SpeechToText();
  final FlutterTts _tts = FlutterTts();
  bool _speechAvailable = false;
  String _partialText = '';

  bool _isLoading = false;
  bool _isRecording = false;
  int _countdown = 10;
  Timer? _countdownTimer;

  final String _lastProvider = 'vps';

  // ── Ajustes TTS (cargados desde SharedPreferences) ────────────
  double _ttsSpeedChild = 0.48;
  double _ttsSpeedAdmin = 0.38;
  String _ttsVoiceName = '';
  final String _ttsVoiceLocale = 'es-ES';

  // Engranaje — mantener pulsado 8 segundos para admin
  Timer? _gearTimer;
  double _gearProgress = 0.0;
  static const _gearHoldSec = 8;

  // ── Getters por usuario ────────────────────────────────────────

  Color get _primaryColor => _currentUser == _User.admin
      ? const Color(0xFFE05A7A)
      : const Color(0xFF7C3AED);

  Color get _bgColor => _currentUser == _User.admin
      ? const Color(0xFF2B0E18)
      : const Color(0xFF1A0E2E);

  Color get _appBarColor => _currentUser == _User.admin
      ? const Color(0xFF4E1B2D)
      : const Color(0xFF2D1B4E);

  Color get _bubbleBotColor => _currentUser == _User.admin
      ? const Color(0xFF5A1830)
      : const Color(0xFF3D2560);

  double get _fontSize => _currentUser == _User.admin ? 19.0 : 15.0;

  String get _userEmoji => _currentUser == _User.admin ? '👨‍�' : '👧';

  String get _userName => _currentUser == _User.admin
      ? (AppConfig.familyMembers.isNotEmpty
          ? AppConfig.familyMembers[0]
          : 'Admin')
      : AppConfig.childName;

  String get _activePrompt => _generatePromptForUser();

  // ─────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    _speech.initialize().then((ok) => _speechAvailable = ok);
    _loadTtsSettings();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _addBotMsg(
        '¡Hola! 👋 Soy Cleo.\n'
        'Soy un teléfono viejecito... ¡no puedo verte ni oírte! 👴📱\n'
        '¿Tú quién eres?',
      );
    });
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _gearTimer?.cancel();
    _speech.stop();
    _tts.stop();
    _textCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  // ── TTS ────────────────────────────────────────────────────────

  Future<void> _loadTtsSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _ttsSpeedChild = prefs.getDouble('tts_speed_child') ?? 0.48;
      _ttsSpeedAdmin = prefs.getDouble('tts_speed_admin') ?? 0.38;
      _ttsVoiceName = prefs.getString('tts_voice') ?? '';
    });
    await _tts.setLanguage('es-ES');
    await _tts.setVolume(1.0);
    await _tts.setPitch(1.15);
    await _tts.setSpeechRate(_ttsSpeedChild);
    await _tts.awaitSpeakCompletion(false);
  }

  Future<void> _speak(String text) async {
    // Quitar emojis y caracteres especiales que confunden el TTS
    final clean = text
        .replaceAll(RegExp(r'[\u{1F000}-\u{1FFFF}]', unicode: true), '')
        .replaceAll(RegExp(r'[\u{2600}-\u{27BF}]', unicode: true), '')
        .replaceAll(RegExp(r'[*_~`]'), '')
        .trim();
    if (clean.isEmpty) return;
    final speed = _currentUser == _User.admin ? _ttsSpeedAdmin : _ttsSpeedChild;
    final pitch = _currentUser == _User.admin ? 1.25 : 1.15;
    await _tts.setSpeechRate(speed);
    await _tts.setPitch(pitch);
    if (_ttsVoiceName.isNotEmpty) {
      await _tts.setVoice({'name': _ttsVoiceName, 'locale': _ttsVoiceLocale});
    }
    await _tts.stop();
    await _tts.speak(clean);
  }

  // ── Mensajes ───────────────────────────────────────────────────

  void _addBotMsg(String text) {
    setState(() => _messages.add(_Msg(role: 'assistant', content: text)));
    _scrollBottom();
    _speak(text);
  }

  void _scrollBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent + 200,
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeOut,
        );
      }
    });
  }

  // ── Selección de usuario ───────────────────────────────────────

  void _selectUser(_User user) {
    setState(() => _currentUser = user);
    final greeting = user == _User.child
        ? '¡Hola, ${AppConfig.childName}! ✨ Me alegra verte.\n¿Qué quieres descubrir hoy? 🌟'
        : '¡Hola, ${AppConfig.familyMembers.isNotEmpty ? AppConfig.familyMembers[0] : 'Admin'}! 🌈 ¡Qué alegría!\n¡A trabajar! 🎉';
    _addBotMsg(greeting);
  }

  void _resetUser() {
    setState(() {
      _currentUser = null;
      _messages.clear();
    });
    _addBotMsg(
      '¡Hola de nuevo! Soy un teléfono viejecito... ¡no puedo verte ni oírte! 👴📱\n'
      '¿Quién eres tú?',
    );
  }

  // ── Chat con IA ────────────────────────────────────────────────

  Future<void> _sendMessage(String text) async {
    text = text.trim();
    if (text.isEmpty || _isLoading) return;
    _textCtrl.clear();

    // Si todavía no está identificado, intentar detectar por texto
    if (_currentUser == null) {
      final lower = text.toLowerCase();
      if (lower.contains(AppConfig.childName.toLowerCase())) {
        setState(() => _messages.add(_Msg(role: 'user', content: text)));
        _scrollBottom();
        _selectUser(_User.child);
        return;
      } else if (AppConfig.familyMembers.isNotEmpty &&
          lower.contains(AppConfig.familyMembers[0].toLowerCase())) {
        setState(() => _messages.add(_Msg(role: 'user', content: text)));
        _scrollBottom();
        _selectUser(_User.admin);
        return;
      }
      setState(() => _messages.add(_Msg(role: 'user', content: text)));
      _scrollBottom();
      _addBotMsg(
        '¡Uy! Recuerda que soy un teléfono viejecito 👴📱\n'
        '¿Eres ${AppConfig.childName} o ${AppConfig.familyMembers.isNotEmpty ? AppConfig.familyMembers[0] : 'admin'}? ¡Pulsa el botón de arriba! 👆',
      );
      return;
    }

    setState(() {
      _messages.add(_Msg(role: 'user', content: text));
      _isLoading = true;
    });
    _scrollBottom();

    try {
    final prompt = _generatePromptForUser();
final reply = await ApiService.sendMessage(text, prompt);

      setState(() {
        _isLoading = false;
      });

      _addBotMsg(
        reply.isNotEmpty && !reply.startsWith('❌')
            ? reply
            : '🤔 No entendí bien. ¿Lo intentamos de nuevo?',
      );
    } catch (e) {
      _showError();
    }
    _scrollBottom();
  }

  String _generatePromptForUser() {
    switch (_currentUser) {
      case _User.child:
        return _generateChildPrompt();
      case _User.admin:
        return _generateAdminPrompt();
      default:
        return _generateChildPrompt();
    }
  }

  String _buildConversationHistory() {
    final history = _messages
        .where((msg) => msg.role != 'system')
        .map((msg) => {'role': msg.role, 'content': msg.content})
        .toList();
    return jsonEncode(history);
  }

  void _showError() {
    setState(() => _isLoading = false);
    _addBotMsg('😕 Ups, no puedo conectarme ahora.\nDile a papá o mamá 📱');
  }

  // ── Grabación de voz ──────────────────────────────────────────

  Future<void> _startRecording() async {
    if (!_speechAvailable) {
      _speechAvailable = await _speech.initialize();
    }
    if (!_speechAvailable) {
      _addBotMsg(
        '❌ El micrófono no está disponible. Prueba a reiniciar la app 🎤',
      );
      return;
    }

    setState(() {
      _isRecording = true;
      _countdown = 10;
      _partialText = '';
    });

    await _speech.listen(
      onResult: (SpeechRecognitionResult result) {
        setState(() => _partialText = result.recognizedWords);
        if (result.finalResult && result.recognizedWords.trim().isNotEmpty) {
          _stopRecording(sendText: result.recognizedWords.trim());
        }
      },
      listenFor: const Duration(seconds: 10),
      pauseFor: const Duration(seconds: 3),
      localeId: 'es_ES',
      listenOptions: SpeechListenOptions(
        cancelOnError: true,
        partialResults: true,
      ),
    );

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      setState(() => _countdown--);
      if (_countdown <= 0) _stopRecording();
    });
  }

  Future<void> _stopRecording({String? sendText}) async {
    _countdownTimer?.cancel();
    await _speech.stop();
    final text = sendText ?? _partialText;
    setState(() {
      _isRecording = false;
      _countdown = 10;
      _partialText = '';
    });
    if (text.trim().isNotEmpty) await _sendMessage(text.trim());
  }

  // ── Engranaje (acceso admin) ───────────────────────────────────

  void _onGearStart(LongPressStartDetails _) {
    _gearProgress = 0;
    _gearTimer = Timer.periodic(const Duration(milliseconds: 80), (t) {
      setState(() => _gearProgress += 1 / (_gearHoldSec * 12.5));
      if (_gearProgress >= 1.0) {
        _gearTimer?.cancel();
        setState(() => _gearProgress = 0);
        _openAdmin();
      }
    });
  }

  void _onGearEnd(LongPressEndDetails _) {
    _gearTimer?.cancel();
    setState(() => _gearProgress = 0);
  }

  void _openAdmin() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const PlaudAdminScreen()),
    ).then((_) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
      _loadTtsSettings(); // recargar ajustes al volver de admin
    });
  }

  // ── Build ──────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: _bgColor,
        appBar: _buildAppBar(),
        body: Column(
          children: [
            if (_currentUser == null) _buildUserSelector(),
            Expanded(child: _buildMsgList()),
            if (_isLoading) _buildTypingIndicator(),
            _buildInputArea(),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: _appBarColor,
      automaticallyImplyLeading: false,
      titleSpacing: 12,
      title: Row(
        children: [
          const SizedBox(width: 40, height: 40, child: CleoAvatar()),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Cleo',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Text(
                _currentUser == null
                    ? '¿Quién eres tú? 👀'
                    : '$_userName · Tu amiga de aprender ✨',
                style: const TextStyle(fontSize: 11, color: Colors.white54),
              ),
            ],
          ),
        ],
      ),
      actions: [
        // Botón cambiar usuario (visible una vez identificado)
        if (_currentUser != null)
          IconButton(
            icon: Text(_userEmoji, style: const TextStyle(fontSize: 20)),
            tooltip: 'Cambiar',
            onPressed: _resetUser,
          ),
        // Engranaje admin — mantener 8s
        GestureDetector(
          onLongPressStart: _onGearStart,
          onLongPressEnd: _onGearEnd,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: SizedBox(
              width: 24,
              height: 24,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  if (_gearProgress > 0)
                    CircularProgressIndicator(
                      value: _gearProgress,
                      strokeWidth: 2,
                      color: Colors.white30,
                      backgroundColor: Colors.white10,
                    ),
                  const Icon(Icons.settings, size: 15, color: Colors.white24),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ── Selector Alba / Fran ───────────────────────────────────────

  Widget _buildUserSelector() {
    return Container(
      color: _appBarColor.withValues(alpha: 0.9),
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
      child: Row(
        children: [
          Expanded(
            child: _UserButton(
              emoji: '👧',
              name: AppConfig.childName,
              color: const Color(0xFF7C3AED),
              onTap: () => _selectUser(_User.child),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: _UserButton(
              emoji: '�‍💼',
              name: AppConfig.familyMembers.isNotEmpty
                  ? AppConfig.familyMembers[0]
                  : 'Admin',
              color: const Color(0xFFE05A7A),
              onTap: () => _selectUser(_User.admin),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMsgList() {
    return ListView.builder(
      controller: _scrollCtrl,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      itemCount: _messages.length,
      itemBuilder: (_, i) {
        final msg = _messages[i];
        return _BubbleWidget(
          text: msg.content,
          isUser: msg.role == 'user',
          userEmoji: _userEmoji,
          botColor: _bubbleBotColor,
          userColor: _primaryColor,
          fontSize: _fontSize,
        );
      },
    );
  }

  Widget _buildTypingIndicator() {
    return const Padding(
      padding: EdgeInsets.only(left: 16, bottom: 6),
      child: Row(
        children: [
          SizedBox(width: 28, height: 28, child: CleoAvatar()),
          SizedBox(width: 8),
          _TypingDots(),
        ],
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      color: _appBarColor,
      padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
      child: _isRecording ? _buildRecordingBar() : _buildTextBar(),
    );
  }

  Widget _buildTextBar() {
    return Row(
      children: [
        GestureDetector(
          onTapDown: (_) => _startRecording(),
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: _primaryColor,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.mic, color: Colors.white, size: 24),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: TextField(
            controller: _textCtrl,
            style: TextStyle(color: Colors.white, fontSize: _fontSize),
            decoration: InputDecoration(
              hintText: 'Escribe a Cleo...',
              hintStyle: const TextStyle(color: Colors.white38, fontSize: 14),
              filled: true,
              fillColor: _bubbleBotColor,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(24),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 11,
              ),
            ),
            onSubmitted: _sendMessage,
            textInputAction: TextInputAction.send,
            maxLines: 3,
            minLines: 1,
          ),
        ),
        const SizedBox(width: 8),
        GestureDetector(
          onTap: () => _sendMessage(_textCtrl.text),
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: _isLoading
                  ? _primaryColor.withValues(alpha: 0.5)
                  : _primaryColor,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.send_rounded,
              color: Colors.white,
              size: 22,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRecordingBar() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '$_countdown',
          style: const TextStyle(
            color: Colors.redAccent,
            fontSize: 56,
            fontWeight: FontWeight.w900,
            height: 1.1,
          ),
        ),
        const SizedBox(height: 2),
        const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.fiber_manual_record, color: Colors.redAccent, size: 12),
            SizedBox(width: 6),
            Text(
              '¡Habla ahora! Escuchando...',
              style: TextStyle(color: Colors.white70, fontSize: 14),
            ),
          ],
        ),
        if (_partialText.isNotEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 6, 16, 0),
            child: Text(
              _partialText,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white54,
                fontSize: 13,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        const SizedBox(height: 8),
        ElevatedButton.icon(
          onPressed: _stopRecording,
          icon: const Icon(Icons.stop_rounded),
          label: const Text('Parar y enviar'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.redAccent,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
          ),
        ),
        const SizedBox(height: 6),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// Botón selector de usuario
// ─────────────────────────────────────────────────────────────────

class _UserButton extends StatelessWidget {
  final String emoji;
  final String name;
  final Color color;
  final VoidCallback onTap;

  const _UserButton({
    required this.emoji,
    required this.name,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.22),
          border: Border.all(color: color, width: 2),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 38)),
            const SizedBox(height: 6),
            Text(
              name,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// Avatar Cleo — dibujada con CustomPainter
// ─────────────────────────────────────────────────────────────────

class CleoAvatar extends StatelessWidget {
  const CleoAvatar({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: _CleoPainter(), size: Size.infinite);
  }
}

class _CleoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = size.width * 0.46;

    // ── Fondo circular con gradiente violeta
    final bgPaint = Paint()
      ..shader = const RadialGradient(
        colors: [Color(0xFFB05CE8), Color(0xFF5B1A8F)],
        center: Alignment(-0.3, -0.3),
      ).createShader(Rect.fromCircle(center: Offset(cx, cy), radius: r));
    canvas.drawCircle(Offset(cx, cy), r, bgPaint);

    // ── Antena
    final antPaint = Paint()
      ..color = const Color(0xFFDDA0FF)
      ..strokeWidth = size.width * 0.055
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      Offset(cx, cy - r * 0.50),
      Offset(cx, cy - r * 0.90),
      antPaint,
    );
    // Estrella dorada en la punta
    _drawStar(
      canvas,
      Offset(cx, cy - r * 0.98),
      size.width * 0.11,
      const Color(0xFFFFD700),
    );

    // ── Cara (círculo claro)
    canvas.drawCircle(
      Offset(cx, cy + r * 0.08),
      r * 0.75,
      Paint()..color = const Color(0xFFEECCFF),
    );

    // ── Mejillas sonrojadas
    final cheekPaint = Paint()
      ..color = const Color(0xFFFF9BBD).withValues(alpha: 0.55);
    canvas.drawCircle(
      Offset(cx - r * 0.37, cy + r * 0.28),
      r * 0.19,
      cheekPaint,
    );
    canvas.drawCircle(
      Offset(cx + r * 0.37, cy + r * 0.28),
      r * 0.19,
      cheekPaint,
    );

    // ── Ojos
    _drawEye(canvas, Offset(cx - r * 0.26, cy - r * 0.05), r * 0.17, size);
    _drawEye(canvas, Offset(cx + r * 0.26, cy - r * 0.05), r * 0.17, size);

    // ── Nariz (puntito)
    canvas.drawCircle(
      Offset(cx, cy + r * 0.14),
      r * 0.045,
      Paint()..color = const Color(0xFFAA66CC),
    );

    // ── Sonrisa
    final smilePaint = Paint()
      ..color = const Color(0xFF7C3AED)
      ..strokeWidth = size.width * 0.055
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final smilePath = Path()
      ..moveTo(cx - r * 0.30, cy + r * 0.22)
      ..quadraticBezierTo(cx, cy + r * 0.48, cx + r * 0.30, cy + r * 0.22);
    canvas.drawPath(smilePath, smilePaint);

    // ── Destellitos alrededor
    _drawStar(
      canvas,
      Offset(cx + r * 0.88, cy - r * 0.52),
      size.width * 0.065,
      const Color(0xFFFFD700).withValues(alpha: 0.85),
    );
    _drawStar(
      canvas,
      Offset(cx - r * 0.84, cy - r * 0.38),
      size.width * 0.050,
      Colors.white.withValues(alpha: 0.75),
    );
  }

  void _drawEye(Canvas canvas, Offset center, double eyeR, Size size) {
    canvas.drawCircle(center, eyeR, Paint()..color = Colors.white);
    canvas.drawCircle(
      center.translate(0, eyeR * 0.08),
      eyeR * 0.65,
      Paint()..color = const Color(0xFF5B1A8F),
    );
    canvas.drawCircle(
      center.translate(0, eyeR * 0.08),
      eyeR * 0.33,
      Paint()..color = Colors.black,
    );
    // Brillo
    canvas.drawCircle(
      center.translate(eyeR * 0.22, -eyeR * 0.22),
      eyeR * 0.18,
      Paint()..color = Colors.white,
    );
  }

  void _drawStar(Canvas canvas, Offset center, double r, Color color) {
    final paint = Paint()..color = color;
    final path = Path();
    for (int i = 0; i < 5; i++) {
      final outer = math.pi / 2 + i * 2 * math.pi / 5;
      final inner = outer + math.pi / 5;
      final op = Offset(
        center.dx + r * math.cos(outer),
        center.dy - r * math.sin(outer),
      );
      final ip = Offset(
        center.dx + r * 0.4 * math.cos(inner),
        center.dy - r * 0.4 * math.sin(inner),
      );
      i == 0 ? path.moveTo(op.dx, op.dy) : path.lineTo(op.dx, op.dy);
      path.lineTo(ip.dx, ip.dy);
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_CleoPainter old) => false;
}

// ─────────────────────────────────────────────────────────────────
// Modelo de mensaje
// ─────────────────────────────────────────────────────────────────

class _Msg {
  final String role;
  final String content;
  const _Msg({required this.role, required this.content});
}

// ─────────────────────────────────────────────────────────────────
// Burbuja de chat
// ─────────────────────────────────────────────────────────────────

class _BubbleWidget extends StatelessWidget {
  final String text;
  final bool isUser;
  final String userEmoji;
  final Color botColor;
  final Color userColor;
  final double fontSize;

  const _BubbleWidget({
    required this.text,
    required this.isUser,
    required this.userEmoji,
    required this.botColor,
    required this.userColor,
    required this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isUser)
            const Padding(
              padding: EdgeInsets.only(right: 6, bottom: 3),
              child: SizedBox(width: 28, height: 28, child: CleoAvatar()),
            ),
          Flexible(
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 4),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.74,
              ),
              decoration: BoxDecoration(
                color: isUser ? userColor : botColor,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(18),
                  topRight: const Radius.circular(18),
                  bottomLeft: Radius.circular(isUser ? 18 : 4),
                  bottomRight: Radius.circular(isUser ? 4 : 18),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.25),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                text,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: fontSize,
                  height: 1.45,
                ),
              ),
            ),
          ),
          if (isUser)
            Padding(
              padding: const EdgeInsets.only(left: 6, bottom: 3),
              child: CircleAvatar(
                backgroundColor: userColor,
                radius: 14,
                child: Text(userEmoji, style: const TextStyle(fontSize: 13)),
              ),
            ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// Indicador de escritura animado
// ─────────────────────────────────────────────────────────────────

class _TypingDots extends StatefulWidget {
  const _TypingDots();

  @override
  State<_TypingDots> createState() => _TypingDotsState();
}

class _TypingDotsState extends State<_TypingDots>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) {
        final phase = (_ctrl.value * 3).floor();
        return Row(
          children: List.generate(3, (i) {
            return AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(right: 4),
              width: i == phase ? 10 : 8,
              height: i == phase ? 10 : 8,
              decoration: BoxDecoration(
                color: i == phase ? const Color(0xFF7C3AED) : Colors.white24,
                shape: BoxShape.circle,
              ),
            );
          }),
        );
      },
    );
  }
}
 */