import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

// ─────────────────────────────────────────────────────────────────
// OllamaService — Servicio de IA con fallback inteligente
// ─────────────────────────────────────────────────────────────────
// Prioridad:
//   1. Ollama local (misma máquina)
//   2. Ollama en red LAN (servidor casero)
//   3. Groq Cloud (fallback si hay internet)
// ─────────────────────────────────────────────────────────────────

/// Resultado de una petición al servicio de IA.
class AiResponse {
  final String text;
  final String provider; // 'ollama-local', 'ollama-lan', 'groq'
  final int latencyMs;

  const AiResponse({
    required this.text,
    required this.provider,
    required this.latencyMs,
  });
}

/// Configuración de un endpoint de Ollama.
class OllamaEndpoint {
  final String name;
  final String baseUrl;
  final String model;
  final Duration timeout;

  const OllamaEndpoint({
    required this.name,
    required this.baseUrl,
    required this.model,
    this.timeout = const Duration(seconds: 30),
  });
}

/// Servicio central de IA con soporte multi-proveedor y fallback.
class OllamaService {
  // ── Endpoints configurables ────────────────────────────────────

  /// Lista de endpoints Ollama en orden de prioridad.
  final List<OllamaEndpoint> endpoints;

  /// API Key de Groq (fallback cloud).
  final String groqApiKey;

  /// Modelo de Groq a usar como fallback.
  final String groqModel;

  /// URL base de la API de Groq.
  final String groqBaseUrl;

  /// Caché del endpoint activo (para no hacer health-check en cada mensaje).
  OllamaEndpoint? _activeEndpoint;
  DateTime? _lastHealthCheck;
  static const _healthCheckInterval = Duration(minutes: 2);

  OllamaService({
    List<OllamaEndpoint>? endpoints,
    this.groqApiKey = '',
    this.groqModel = 'llama-3.1-8b-instant',
    this.groqBaseUrl = 'https://api.groq.com/openai/v1',
  }) : endpoints = endpoints ??
            [
              // Por defecto: localhost y la IP típica de red local
              const OllamaEndpoint(
                name: 'ollama-local',
                baseUrl: 'http://127.0.0.1:11434',
                model: 'gemma2:2b',
              ),
            ];

  // ── Health Check ───────────────────────────────────────────────

  /// Comprueba si un endpoint de Ollama está vivo.
  Future<bool> _isAlive(OllamaEndpoint ep) async {
    try {
      final resp = await http
          .get(Uri.parse('${ep.baseUrl}/api/tags'))
          .timeout(const Duration(seconds: 3));
      return resp.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  /// Encuentra el primer endpoint de Ollama disponible.
  Future<OllamaEndpoint?> _findActiveEndpoint({bool force = false}) async {
    // Usar la caché si es reciente
    if (!force &&
        _activeEndpoint != null &&
        _lastHealthCheck != null &&
        DateTime.now().difference(_lastHealthCheck!) < _healthCheckInterval) {
      return _activeEndpoint;
    }

    for (final ep in endpoints) {
      if (await _isAlive(ep)) {
        _activeEndpoint = ep;
        _lastHealthCheck = DateTime.now();
        return ep;
      }
    }
    _activeEndpoint = null;
    return null;
  }

  // ── API Pública ────────────────────────────────────────────────

  /// Devuelve el estado actual del servicio.
  Future<Map<String, dynamic>> getStatus() async {
    final results = <String, dynamic>{};

    for (final ep in endpoints) {
      final alive = await _isAlive(ep);
      Map<String, dynamic>? models;
      if (alive) {
        try {
          final resp = await http
              .get(Uri.parse('${ep.baseUrl}/api/tags'))
              .timeout(const Duration(seconds: 5));
          if (resp.statusCode == 200) {
            models = jsonDecode(resp.body) as Map<String, dynamic>;
          }
        } catch (_) {}
      }
      results[ep.name] = {
        'alive': alive,
        'url': ep.baseUrl,
        'model': ep.model,
        'available_models':
            models?['models']?.map((m) => m['name'])?.toList() ?? [],
      };
    }

    results['groq'] = {
      'configured': groqApiKey.isNotEmpty,
      'model': groqModel,
    };

    final active = await _findActiveEndpoint();
    results['active_provider'] =
        active?.name ?? (groqApiKey.isNotEmpty ? 'groq' : 'none');

    return results;
  }

  /// Envía un mensaje y obtiene respuesta (con fallback automático).
  Future<AiResponse> chat({
    required List<Map<String, String>> messages,
    int maxTokens = 250,
    double temperature = 0.75,
  }) async {
    final sw = Stopwatch()..start();

    // 1. Intentar con Ollama (endpoints en orden de prioridad)
    final ollamaEp = await _findActiveEndpoint();
    if (ollamaEp != null) {
      try {
        final result = await _chatOllama(
          endpoint: ollamaEp,
          messages: messages,
          maxTokens: maxTokens,
          temperature: temperature,
        );
        sw.stop();
        return AiResponse(
          text: result,
          provider: ollamaEp.name,
          latencyMs: sw.elapsedMilliseconds,
        );
      } catch (_) {
        // Ollama falló → invalidar caché y probar siguiente
        _activeEndpoint = null;
        _lastHealthCheck = null;
      }
    }

    // 2. Fallback: Groq Cloud
    if (groqApiKey.isNotEmpty) {
      try {
        final result = await _chatGroq(
          messages: messages,
          maxTokens: maxTokens,
          temperature: temperature,
        );
        sw.stop();
        return AiResponse(
          text: result,
          provider: 'groq',
          latencyMs: sw.elapsedMilliseconds,
        );
      } catch (e) {
        sw.stop();
        throw Exception('Todos los proveedores fallaron. Último error: $e');
      }
    }

    sw.stop();
    throw Exception(
      'No hay proveedores de IA disponibles. '
      'Configura Ollama local o una API key de Groq.',
    );
  }

  // ── Ollama Chat (API compatible OpenAI) ────────────────────────

  Future<String> _chatOllama({
    required OllamaEndpoint endpoint,
    required List<Map<String, String>> messages,
    required int maxTokens,
    required double temperature,
  }) async {
    // Ollama soporta /v1/chat/completions (compatible OpenAI)
    final resp = await http
        .post(
          Uri.parse('${endpoint.baseUrl}/v1/chat/completions'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'model': endpoint.model,
            'messages': messages,
            'max_tokens': maxTokens,
            'temperature': temperature,
            'stream': false,
          }),
        )
        .timeout(endpoint.timeout);

    if (resp.statusCode == 200) {
      final data = jsonDecode(utf8.decode(resp.bodyBytes));
      return (data['choices'][0]['message']['content'] as String).trim();
    }
    throw Exception('Ollama [${endpoint.name}] status: ${resp.statusCode}');
  }

  // ── Groq Chat ──────────────────────────────────────────────────

  Future<String> _chatGroq({
    required List<Map<String, String>> messages,
    required int maxTokens,
    required double temperature,
  }) async {
    final resp = await http
        .post(
          Uri.parse('$groqBaseUrl/chat/completions'),
          headers: {
            'Authorization': 'Bearer $groqApiKey',
            'Content-Type': 'application/json',
          },
          body: jsonEncode({
            'model': groqModel,
            'messages': messages,
            'max_tokens': maxTokens,
            'temperature': temperature,
          }),
        )
        .timeout(const Duration(seconds: 30));

    if (resp.statusCode == 200) {
      final data = jsonDecode(utf8.decode(resp.bodyBytes));
      return (data['choices'][0]['message']['content'] as String).trim();
    }
    throw Exception('Groq status: ${resp.statusCode}');
  }

  // ── Listar modelos de Ollama ───────────────────────────────────

  /// Obtiene la lista de modelos disponibles del primer endpoint activo.
  Future<List<String>> listModels() async {
    final ep = await _findActiveEndpoint();
    if (ep == null) return [];

    try {
      final resp = await http
          .get(Uri.parse('${ep.baseUrl}/api/tags'))
          .timeout(const Duration(seconds: 5));
      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body);
        final models = data['models'] as List? ?? [];
        return models.map<String>((m) => m['name'] as String).toList();
      }
    } catch (_) {}
    return [];
  }
}
