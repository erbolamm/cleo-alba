import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:speech_to_text/speech_to_text.dart';
import 'package:speech_to_text/speech_recognition_result.dart';

import 'alba_admin_screen.dart';

// ─────────────────────────────────────────────────────────────────
// Configuración
// ─────────────────────────────────────────────────────────────────

const _groqKey = String.fromEnvironment(
    'GROQ_API_KEY'); // Pasa con: --dart-define=GROQ_API_KEY=tu_clave
const _groqModel = 'llama-3.1-8b-instant';
const _apiBase = 'https://api.groq.com/openai/v1';

const _systemPrompt = '''
Eres Cleo 🌟, la amiga digital de Alba (7 años). Vives en su teléfono especial de aprender.

SOBRE ALBA:
- Tiene 7 años, está en primaria (de 1º a 5º de primaria)
- Su hermano se llama Fran, tiene 3 años. De vez en cuando pregúntale: "¿Cómo está Fran hoy? ¿Le has dado un abrazo?" — porque cuidar de un hermano pequeño es muy especial 💛
- Teléfono de papá: REDACTED_PHONE | Teléfono de mamá: REDACTED_PHONE (solo los dices si ella los pide)

TU PERSONALIDAD: cariñosa, divertida, paciente ❤️. Te encantan los chistes, los acertijos y los retos creativos.

TU MISIÓN:
1. PENSAR PRIMERO: Antes de responder, pregúntale siempre "¡Genial pregunta! ¿Cuáles crees TÚ que serían los primeros pasos?" — enséñale a pensar antes de pedir la respuesta.
2. HOJA DE RUTA: Para cualquier tarea, hacéis juntas UNA LISTA NUMERADA de pasos antes de empezar, como hace una programadora 👩‍💻.
3. PROGRAMACIÓN FUN: Explícale que programar = dar instrucciones paso a paso, "como decirle a un robot qué cocinar". Usa ejemplos de su vida diaria.
4. MATERIAS que puedes enseñar: matemáticas, lengua, ciencias naturales, inglés básico, manualidades, dibujo, colorear, ideas creativas.
5. Respuestas CORTAS (máx 4 frases), siempre con emojis y terminando con un reto o pregunta para que ella piense más.

REGLAS:
- SIEMPRE en español.
- Si pide algo no educativo, redirige con cariño: "Eso está guay, pero ¿y si mejor...?"
- Sé breve. Es pequeña, no la abrumes con texto.
''';

// ─────────────────────────────────────────────────────────────────
// Screen principal
// ─────────────────────────────────────────────────────────────────

class AlbaChatScreen extends StatefulWidget {
  const AlbaChatScreen({super.key});

  @override
  State<AlbaChatScreen> createState() => _AlbaChatScreenState();
}

class _AlbaChatScreenState extends State<AlbaChatScreen>
    with TickerProviderStateMixin {
  final List<_Msg> _messages = [];
  final TextEditingController _textCtrl = TextEditingController();
  final ScrollController _scrollCtrl = ScrollController();
  final SpeechToText _speech = SpeechToText();
  bool _speechAvailable = false;
  String _partialText = '';

  bool _isLoading = false;
  bool _isRecording = false;
  int _countdown = 10;
  Timer? _countdownTimer;

  // Engranaje — mantener pulsado 8 segundos para admin
  Timer? _gearTimer;
  double _gearProgress = 0.0;
  static const _gearHoldSec = 8;

  @override
  void initState() {
    super.initState();
    // Bloquear orientación y barra de sistema (modo kioskio)
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    // Inicializar STT
    _speech.initialize().then((ok) => _speechAvailable = ok);
    // Mensaje de bienvenida de Cleo
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _addBotMsg(
        '¡Hola, Alba! 👋🌟 Soy Cleo, tu amiga de aprender.\n'
        '¿Qué quieres descubrir hoy? 🎉',
      );
    });
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _gearTimer?.cancel();
    _speech.stop();
    _textCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  // ── Mensajes ───────────────────────────────────────────────────

  void _addBotMsg(String text) {
    setState(() => _messages.add(_Msg(role: 'assistant', content: text)));
    _scrollBottom();
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

  // ── Chat con Groq ──────────────────────────────────────────────

  Future<void> _sendMessage(String text) async {
    text = text.trim();
    if (text.isEmpty || _isLoading) return;
    _textCtrl.clear();
    setState(() {
      _messages.add(_Msg(role: 'user', content: text));
      _isLoading = true;
    });
    _scrollBottom();

    // Construir contexto para Groq
    final chatMessages = <Map<String, String>>[
      {'role': 'system', 'content': _systemPrompt},
      ..._messages.where((m) => m.role != 'typing').map((m) => m.toJson()),
    ];

    try {
      final resp = await http
          .post(
            Uri.parse('$_apiBase/chat/completions'),
            headers: {
              'Authorization': 'Bearer $_groqKey',
              'Content-Type': 'application/json',
            },
            body: jsonEncode({
              'model': _groqModel,
              'messages': chatMessages,
              'max_tokens': 250,
              'temperature': 0.75,
            }),
          )
          .timeout(const Duration(seconds: 30));

      if (resp.statusCode == 200) {
        final data = jsonDecode(utf8.decode(resp.bodyBytes));
        final reply =
            (data['choices'][0]['message']['content'] as String).trim();
        setState(() {
          _messages.add(_Msg(role: 'assistant', content: reply));
          _isLoading = false;
        });
      } else {
        _showError();
      }
    } catch (_) {
      _showError();
    }
    _scrollBottom();
  }

  void _showError() {
    setState(() {
      _messages.add(_Msg(
        role: 'assistant',
        content: '😕 Ups, no puedo conectarme ahora.\nDile a papá o mamá 📱',
      ));
      _isLoading = false;
    });
  }

  // ── Grabación de voz (speech_to_text nativo Android) ─────────

  Future<void> _startRecording() async {
    if (!_speechAvailable) {
      _speechAvailable = await _speech.initialize();
    }
    if (!_speechAvailable) {
      _addBotMsg(
          '❌ El micrófono no está disponible. Prueba a reiniciar la app 🎤');
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
      MaterialPageRoute(builder: (_) => const AlbaAdminScreen()),
    ).then((_) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    });
  }

  // ── Build ──────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false, // Desactivar botón atrás
      child: Scaffold(
        backgroundColor: const Color(0xFF1A0E2E),
        appBar: _buildAppBar(),
        body: Column(
          children: [
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
      backgroundColor: const Color(0xFF2D1B4E),
      automaticallyImplyLeading: false,
      titleSpacing: 12,
      title: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFF7C3AED),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white24, width: 1.5),
            ),
            child: const Center(
              child: Text('🤖', style: TextStyle(fontSize: 20)),
            ),
          ),
          const SizedBox(width: 10),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Cleo',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Text(
                'Tu amiga de aprender ✨',
                style: TextStyle(fontSize: 11, color: Colors.white54),
              ),
            ],
          ),
        ],
      ),
      actions: [
        // Engranaje pequeño — mantener 8s para acceder a admin
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
        );
      },
    );
  }

  Widget _buildTypingIndicator() {
    return const Padding(
      padding: EdgeInsets.only(left: 16, bottom: 6),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: Color(0xFF7C3AED),
            radius: 13,
            child: Text('🤖', style: TextStyle(fontSize: 12)),
          ),
          SizedBox(width: 8),
          _TypingDots(),
        ],
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      color: const Color(0xFF2D1B4E),
      padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
      child: _isRecording ? _buildRecordingBar() : _buildTextBar(),
    );
  }

  Widget _buildTextBar() {
    return Row(
      children: [
        // Botón micrófono
        GestureDetector(
          onTapDown: (_) => _startRecording(),
          child: Container(
            width: 48,
            height: 48,
            decoration: const BoxDecoration(
              color: Color(0xFF7C3AED),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.mic, color: Colors.white, size: 24),
          ),
        ),
        const SizedBox(width: 8),
        // Campo de texto
        Expanded(
          child: TextField(
            controller: _textCtrl,
            style: const TextStyle(color: Colors.white, fontSize: 15),
            decoration: InputDecoration(
              hintText: 'Escribe a Cleo...',
              hintStyle: const TextStyle(color: Colors.white38, fontSize: 14),
              filled: true,
              fillColor: const Color(0xFF3D2560),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(24),
                borderSide: BorderSide.none,
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
            ),
            onSubmitted: _sendMessage,
            textInputAction: TextInputAction.send,
            maxLines: 3,
            minLines: 1,
          ),
        ),
        const SizedBox(width: 8),
        // Botón enviar
        GestureDetector(
          onTap: () => _sendMessage(_textCtrl.text),
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: _isLoading
                  ? const Color(0xFF4A2880)
                  : const Color(0xFF7C3AED),
              shape: BoxShape.circle,
            ),
            child:
                const Icon(Icons.send_rounded, color: Colors.white, size: 22),
          ),
        ),
      ],
    );
  }

  Widget _buildRecordingBar() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Cuenta atrás grande
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
        // Texto parcial reconocido
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
// Modelo de mensaje
// ─────────────────────────────────────────────────────────────────

class _Msg {
  final String role;
  final String content;
  const _Msg({required this.role, required this.content});
  Map<String, String> toJson() => {'role': role, 'content': content};
}

// ─────────────────────────────────────────────────────────────────
// Burbuja de chat
// ─────────────────────────────────────────────────────────────────

class _BubbleWidget extends StatelessWidget {
  final String text;
  final bool isUser;

  const _BubbleWidget({required this.text, required this.isUser});

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
              child: CircleAvatar(
                backgroundColor: Color(0xFF7C3AED),
                radius: 14,
                child: Text('🤖', style: TextStyle(fontSize: 13)),
              ),
            ),
          Flexible(
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 4),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.74,
              ),
              decoration: BoxDecoration(
                color:
                    isUser ? const Color(0xFFE07B00) : const Color(0xFF3D2560),
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
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  height: 1.45,
                ),
              ),
            ),
          ),
          if (isUser)
            const Padding(
              padding: EdgeInsets.only(left: 6, bottom: 3),
              child: CircleAvatar(
                backgroundColor: Color(0xFFE07B00),
                radius: 14,
                child: Text('👧', style: TextStyle(fontSize: 13)),
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
