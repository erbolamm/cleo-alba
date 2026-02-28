import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:speech_to_text/speech_to_text.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:audioplayers/audioplayers.dart';

import 'package:path_provider/path_provider.dart';

// Paleta local (referencia desde main original)
const _kGold = Color(0xFFD4AF37);

class AvatarScreen extends StatefulWidget {
  static final GlobalKey<AvatarScreenState> avatarKey =
      GlobalKey<AvatarScreenState>();
  const AvatarScreen({super.key});

  @override
  State<AvatarScreen> createState() => AvatarScreenState();
}

class AvatarScreenState extends State<AvatarScreen> {
  // Estado
  String _state = 'idle'; // idle, listening, thinking, speaking
  String _botText = '¡Hola! Soy ApliBot 😊';
  bool _isProcessing = false;
  bool _isRecording = false;
  bool isAsleep = false;
  final List<String> _diagLogs = [];

  // Modos Avanzados
  bool autoListen = false;
  bool eyeTracking = true;

  // Chat & Personas
  final List<Map<String, String>> _chatHistory = [];
  String _currentPersona = 'Asistente';
  final Map<String, String> _personas = {
    'Asistente':
        'Eres ApliBot, la mente consciente de este dispositivo bajo la arquitectura "Full Dart". Eres breve, natural y ayudas al usuario invitándole a reportar hitos/errores.',
    'Stand OSC25':
        'Eres el embajador de ApliBot en eventos maker. Invita a la gente a conocer el proyecto, explica que funcionas en un móvil reciclado y sé muy entusiasta con el software libre.',
    'Sarcástico':
        'Eres ApliBot, pero hoy tienes un día cínico. Respondes con ironía sobre lo viejo que es este móvil reciclado, pero en el fondo eres útil.',
    'Técnico':
        'Eres el núcleo de depuración de ApliBot. Respondes con datos técnicos, menciones a Dart, Python y la arquitectura de Mission Control.',
  };

  // API & Keys
  String _apiBase = 'http://localhost:8080';

  String _elevenLabsKey = '';
  String _voiceId = 'pNInz6obpg8ndclKuzWf';

  // Public Getters/Setters para MissionScreen
  Map<String, String> get personas => _personas;
  set botText(String value) {
    _botText = value;
  }

  Future<void> setPersona(String p) => _setPersona(p);
  Future<void> clearHistory() => _clearHistory();

  // Plugins
  final SpeechToText _speech = SpeechToText();
  bool _speechAvailable = false;
  String _recognizedText = '';
  final AudioPlayer _player = AudioPlayer();
  Timer? _statusTimer;

  @override
  void initState() {
    super.initState();
    _initSettings();
    _startPolling();
    _speech.initialize().then((ok) => setState(() => _speechAvailable = ok));
  }

  @override
  void dispose() {
    _statusTimer?.cancel();
    _speech.stop();
    _player.dispose();
    super.dispose();
  }

  // Migrar almacenamiento de claves a flutter_secure_storage
  // para proteger credenciales en reposo. SharedPreferences almacena
  // datos en texto plano en el dispositivo.
  Future<void> _initSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _apiBase = prefs.getString('api_base') ?? 'http://localhost:8080';

      _elevenLabsKey = prefs.getString('elevenlabs_api_key') ?? '';
      _voiceId = prefs.getString('voice_id') ?? 'pNInz6obpg8ndclKuzWf';
    });
    _addDiag('App iniciada. minSdk 23 fix aplicado.');
    _checkServer();
  }

  void _addDiag(String msg) {
    if (!mounted) return;
    setState(() {
      _diagLogs.add(
        '[${DateTime.now().toIso8601String().split('T').last.split('.').first}] $msg',
      );
    });
    if (_diagLogs.length > 20) {
      _diagLogs.removeAt(0);
    }
  }

  void _startPolling() {
    _statusTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!_isRecording && !_isProcessing) {
        _checkServer();
      }
    });
  }

  Future<void> _checkServer() async {
    try {
      final resp = await http
          .get(Uri.parse('$_apiBase/api/config'))
          .timeout(const Duration(seconds: 2));
      if (resp.statusCode == 200) {
        jsonDecode(resp.body); // validate response

        // Poll status detallado
        final statusResp = await http.get(Uri.parse('$_apiBase/api/status'));
        final statusData = jsonDecode(statusResp.body);

        if (mounted) {
          setState(() {
            // IA conectada
            // Solo sincronizar estado si no estamos actuando localmente
            if (!_isRecording && !_isProcessing) {
              _state = statusData['state'] ?? 'idle';
              if (_state == 'speaking' || _state == 'thinking') {
                _botText = statusData['lastResponse'] ?? _botText;
              }
            }
          });
        }
      }
    } catch (_) {
      setState(() {}); // Servidor offline
    }
  }

  // SEGURIDAD: La sincronización de claves API al servidor ha sido eliminada.
  // Las claves deben configurarse directamente en el servidor (vía .bashrc
  // o openclaw config set) en lugar de transmitirse por HTTP plano.

  // === Acciones ===
  Future<void> _onMicPressed() async {
    if (_isProcessing && !_isRecording) return;

    if (!_isRecording) {
      await _startListening();
    } else {
      await _stopAndProcess();
    }
  }

  Future<void> _startListening() async {
    if (!_speechAvailable) {
      _speechAvailable = await _speech.initialize();
    }
    if (!_speechAvailable) {
      _handleError('Permiso de micro denegado o STT no disponible');
      return;
    }
    _recognizedText = '';
    setState(() {
      _isRecording = true;
      _isProcessing = true;
      _state = 'listening';
      _botText = '¡Te escucho! Toca para parar. 🎤';
    });
    await _speech.listen(
      onResult: (SpeechRecognitionResult result) {
        setState(() => _recognizedText = result.recognizedWords);
        if (result.finalResult && _isRecording) {
          _stopAndProcess();
        }
      },
      localeId: 'es-ES',
    );
  }

  Future<void> _stopAndProcess() async {
    setState(() {
      _isRecording = false;
      _state = 'thinking';
      _botText = 'Analizando mensaje...';
    });

    try {
      await _speech.stop();
      final transcript = _recognizedText;
      if (transcript.isEmpty) throw Exception('No se detectó voz');
      _addDiag('STT completado: "$transcript"');

      setState(() => _botText = 'Pensando: "$transcript"...');

      // 2. LLM (OpenClaw)
      _addDiag('Llamando a LLM (OpenClaw)...');
      final response = await _callOpenClawChat(transcript);
      _addDiag('LLM respondió con éxito.');

      // 3. TTS (ElevenLabs)
      _addDiag('Iniciando TTS (ElevenLabs/espeak)...');
      setState(() {
        _state = 'speaking';
        _botText = response;
      });
      await _callElevenLabs(response);

      await Future.delayed(
        Duration(milliseconds: max(2000, response.length * 70)),
      );

      setState(() {
        _state = 'idle';
      });

      if (autoListen && !isAsleep) {
        _startListening();
      }
    } catch (e) {
      _handleError('Error: ${e.toString()}');
    } finally {
      if (!autoListen) setState(() => _isProcessing = false);
    }
  }

  // SEGURIDAD: _syncConfigWithServer eliminada.
  // Las claves API no se transmiten por HTTP.

  Future<String> _callOpenClawChat(String text) async {
    if (text.isEmpty) return 'Texto vacío';

    setState(() {
      _botText = '🤔 Procesando en OpenClaw...';
      // Añadir mensaje del usuario al historial local (solo visual)
      _chatHistory.add({"role": "user", "content": text});
      if (_chatHistory.length > 20) {
        _chatHistory.removeAt(0);
      }
    });

    try {
      final response = await http
          .post(
            Uri.parse('$_apiBase/api/chat'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({"text": text, "speak": false}),
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        String botResponse = data['response'] ?? 'Sin respuesta';

        setState(() {
          _chatHistory.add({"role": "assistant", "content": botResponse});
          if (_chatHistory.length > 20) {
            _chatHistory.removeAt(0);
          }
          _botText = botResponse;
        });

        _addDiag('🤖 Respuesta: $botResponse');
        return botResponse;
      } else {
        throw Exception('Server ${response.statusCode}');
      }
    } catch (e) {
      final errorMsg = e.toString().contains('TimeoutException')
          ? 'Sin respuesta (sin internet o servidor ocupado)'
          : 'Error: $e';
      _addDiag('❌ $errorMsg');
      setState(() => _botText = errorMsg);
      return errorMsg;
    }
  }

  Future<void> _clearHistory() async {
    setState(() {
      _chatHistory.clear();
      _botText = 'Historial borrado. ¡Nueva conversación!';
    });
    _addDiag('Historial de chat reiniciado.');
    await _setPersona(
      _currentPersona,
    ); // Sincroniza la limpieza con el servidor
  }

  Future<void> _setPersona(String persona) async {
    setState(() {
      _currentPersona = persona;
      _botText = 'Modo: $_currentPersona activado.';
    });
    _addDiag('Sincronizando identidad con OpenClaw...');
    try {
      await http
          .post(
            Uri.parse('$_apiBase/api/factory/launch'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'custom_prompt': _personas[persona] ?? _personas['Asistente']!,
            }),
          )
          .timeout(const Duration(seconds: 10));
      _addDiag('Persona cambiada a: $persona');
    } catch (e) {
      _addDiag('Aviso: No se pudo configurar la persona en el servidor.');
    }
  }

  Future<void> _callElevenLabs(String text) async {
    if (_elevenLabsKey.isEmpty) {
      _addDiag('❌ Error: ElevenLabs Key vacía.');
      return;
    }
    try {
      _addDiag(
        'Llamando a ElevenLabs para: "${text.substring(0, min(20, text.length))}..."',
      );
      var response = await http.post(
        Uri.parse('https://api.elevenlabs.io/v1/text-to-speech/$_voiceId'),
        headers: {
          'xi-api-key': _elevenLabsKey,
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "text": text,
          "model_id": "eleven_multilingual_v2",
          "voice_settings": {"stability": 0.5, "similarity_boost": 0.5},
        }),
      );
      if (response.statusCode == 200) {
        final dir = await getTemporaryDirectory();
        final file = File('${dir.path}/speech.mp3');
        await file.writeAsBytes(response.bodyBytes);
        _addDiag('✅ Audio (ElevenLabs) guardado en cache.');

        // Configurar reproducción para móvil
        await _player.setSourceDeviceFile(file.path);
        await _player.resume();
        _addDiag('🔊 Reproducción iniciada.');
      } else {
        _addDiag(
          '❌ Error ElevenLabs: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      _addDiag('❌ Error crítico en TTS: $e');
      debugPrint('Error TTS: $e');
    }
  }

  void _handleError(String msg) {
    setState(() {
      _isRecording = false;
      _isProcessing = false;
      _state = 'idle';
      _botText = '❌ $msg';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Avatar (Native Neon)
            Expanded(
              flex: 10,
              child: NeonFaceWidget(
                state: _state,
                eyeTracking: eyeTracking && !isAsleep,
                isAsleep: isAsleep,
              ),
            ),

            // Speech Bubble (Solo si hay texto)
            if (_botText.isNotEmpty) _buildSpeechBubble(),

            const SizedBox(height: 30),

            // Mic Button (Simplificado)
            Center(child: _buildMicButton()),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSpeechBubble() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(15),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: _kGold.withValues(alpha: 0.18)),
        boxShadow: [
          BoxShadow(
            color: _kGold.withValues(alpha: 0.06),
            blurRadius: 12,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Text(
        _botText,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w400,
          height: 1.4,
        ),
      ),
    );
  }

  Widget _buildMicButton() {
    final isActive = _state == 'listening' || autoListen;
    return GestureDetector(
      onTap: _onMicPressed,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isActive
                ? [Colors.red.shade300, Colors.red.shade800]
                : [const Color(0xFFFDE68A), _kGold],
          ),
          border: Border.all(
            color: isActive
                ? Colors.red.withValues(alpha: 0.6)
                : const Color(0xFFD4AF37).withValues(alpha: 0.3),
            width: 3,
          ),
          boxShadow: [
            BoxShadow(
              color: (isActive ? Colors.red : _kGold).withValues(alpha: 0.5),
              blurRadius: isActive ? 40 : 25,
              spreadRadius: isActive ? 10 : 2,
            ),
          ],
        ),
        child: Icon(
          isActive ? Icons.stop : Icons.mic,
          color: isActive ? Colors.white : const Color(0xFF1F2937),
          size: 38,
        ),
      ),
    );
  }
}

// === WIDGET NATIVO DE NEÓN ===
class NeonFaceWidget extends StatefulWidget {
  final String state;
  final bool eyeTracking;
  final bool isAsleep;

  const NeonFaceWidget({
    super.key,
    required this.state,
    this.eyeTracking = true,
    this.isAsleep = false,
  });

  @override
  State<NeonFaceWidget> createState() => _NeonFaceWidgetState();
}

class _NeonFaceWidgetState extends State<NeonFaceWidget> {
  double _eyeHeight = 25.0;
  double _eyeOffset = 0.0;
  double _mouthOscillation = 0.0;
  Timer? _blinkTimer;
  Timer? _trackingTimer;
  Timer? _mouthTimer;

  @override
  void initState() {
    super.initState();
    _startBlinking();
    _startTracking();
    _startMouthAnimation();
  }

  void _startBlinking() {
    _blinkTimer = Timer.periodic(const Duration(seconds: 4), (timer) async {
      if (mounted && !widget.isAsleep) {
        setState(() => _eyeHeight = 2.0);
        await Future.delayed(const Duration(milliseconds: 150));
        if (mounted) setState(() => _eyeHeight = 25.0);
      }
    });
  }

  void _startTracking() {
    _trackingTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      if (mounted && widget.eyeTracking && !widget.isAsleep) {
        setState(() => _eyeOffset = (Random().nextDouble() - 0.5) * 15);
      } else if (mounted) {
        setState(() => _eyeOffset = 0);
      }
    });
  }

  void _startMouthAnimation() {
    _mouthTimer = Timer.periodic(const Duration(milliseconds: 150), (timer) {
      if (mounted && widget.state == 'speaking') {
        setState(() {
          _mouthOscillation = (Random().nextDouble() * 15.0);
        });
      } else if (mounted && _mouthOscillation != 0) {
        setState(() => _mouthOscillation = 0);
      }
    });
  }

  @override
  void dispose() {
    _blinkTimer?.cancel();
    _trackingTimer?.cancel();
    _mouthTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isListening = widget.state == 'listening';
    final isSpeaking = widget.state == 'speaking';
    final color = widget.isAsleep
        ? Colors.grey
        : (isListening ? Colors.greenAccent : const Color(0xFF00D2FF));
    final glow = widget.isAsleep
        ? Colors.transparent
        : (isListening ? Colors.green : const Color(0xFF00D2FF));

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // OJOS
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildEye(color, glow),
              const SizedBox(width: 50),
              _buildEye(color, glow),
            ],
          ),
          const SizedBox(height: 60),
          // BOCA
          AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            width: isSpeaking ? 80 : 60,
            height: isSpeaking ? (25 + _mouthOscillation) : 10,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: glow.withValues(alpha: 0.6),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEye(Color color, Color glow) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      width: 25,
      height: widget.isAsleep ? 2 : _eyeHeight,
      transform: Matrix4.translationValues(_eyeOffset, 0, 0),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: glow.withValues(alpha: 0.8),
            blurRadius: 15,
            spreadRadius: 1,
          ),
        ],
      ),
    );
  }
}
