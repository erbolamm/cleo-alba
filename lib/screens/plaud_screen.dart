import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';

const _kGold = Color(0xFFD4AF37);

class PlaudScreen extends StatefulWidget {
  const PlaudScreen({super.key});

  @override
  State<PlaudScreen> createState() => _PlaudScreenState();
}

class _PlaudScreenState extends State<PlaudScreen> {
  String _apiBase = 'http://localhost:8080';
  bool _isRecording = false;
  bool _isProcessing = false;
  String _statusMessage = 'Plaud Motor en Standby';
  List<Map<String, dynamic>> _history = [];
  String? _currentAudioFile;

  @override
  void initState() {
    super.initState();
    _loadSettings();
    _fetchHistory();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _apiBase = prefs.getString('api_base') ?? 'http://localhost:8080';
    });
  }

  Future<void> _fetchHistory() async {
    try {
      final response = await http
          .get(Uri.parse('$_apiBase/plaud/history'))
          .timeout(const Duration(seconds: 5));
      if (response.statusCode == 200) {
        setState(() {
          _history = List<Map<String, dynamic>>.from(
            jsonDecode(response.body)['history'],
          );
        });
      }
    } catch (e) {
      debugPrint('Plud history fetch error: $e');
    }
  }

  Future<void> _toggleRecord() async {
    if (_isRecording) {
      setState(() {
        _isRecording = false;
        _statusMessage = 'Finalizando grabación Plaud...';
      });
      try {
        final resp = await http.post(Uri.parse('$_apiBase/plaud/stop'));
        if (resp.statusCode == 200) {
          final data = jsonDecode(resp.body);
          setState(() {
            _statusMessage = 'Grabación guardada: ${data['file']}';
            _currentAudioFile = data['file'];
          });
          // Analizar automáticamente al parar
          _analyzeCurrent();
        } else {
          setState(() => _statusMessage = 'Error al detener grabación');
        }
      } catch (e) {
        setState(() => _statusMessage = 'Error de conexión');
      }
    } else {
      setState(() {
        _isRecording = true;
        _statusMessage = 'Grabando Plaud...';
        _currentAudioFile = null;
      });
      try {
        final resp = await http.post(Uri.parse('$_apiBase/plaud/start'));
        if (resp.statusCode != 200) {
          setState(() {
            _isRecording = false;
            _statusMessage = 'No se pudo iniciar Plaud';
          });
        }
      } catch (e) {
        setState(() {
          _isRecording = false;
          _statusMessage = 'Error de conexión Server';
        });
      }
    }
  }

  Future<void> _analyzeCurrent() async {
    if (_currentAudioFile == null) return;
    setState(() {
      _isProcessing = true;
      _statusMessage = 'Analizando audio... (DeepSeek + Whisper)';
    });
    try {
      final resp = await http.post(
        Uri.parse('$_apiBase/plaud/analyze'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'file': _currentAudioFile}),
      );
      if (resp.statusCode == 200) {
        setState(() => _statusMessage = 'Análisis completado');
        _fetchHistory();
      } else {
        setState(
          () => _statusMessage = 'Error en análisis (${resp.statusCode})',
        );
      }
    } catch (e) {
      setState(() => _statusMessage = 'Error conectando al motor analítico');
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  Future<void> _uploadAndAnalyze() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.audio,
        allowMultiple: false,
      );
      if (result == null || result.files.isEmpty) return;
      final path = result.files.first.path;
      if (path == null) return;

      setState(() {
        _isProcessing = true;
        _statusMessage = 'Subiendo y analizando archivo externo...';
      });

      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$_apiBase/plaud/upload_analyze'),
      );
      request.files.add(await http.MultipartFile.fromPath('audio', path));

      var streamedResponse = await request.send().timeout(
            const Duration(seconds: 180),
          );
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        setState(() => _statusMessage = 'Análisis externo completado');
        _fetchHistory();
      } else {
        setState(
          () => _statusMessage =
              'Error procesando archivo (${response.statusCode})',
        );
      }
    } catch (e) {
      setState(() => _statusMessage = 'Error subiendo archivo: $e');
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  void _showSummaryDetails(Map<String, dynamic> item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF0F172A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.8,
          builder: (context, scrollController) {
            return Padding(
              padding: const EdgeInsets.all(20),
              child: ListView(
                controller: scrollController,
                children: [
                  Text(
                    item['date'] ?? 'Fecha Desconocida',
                    style: const TextStyle(
                      color: _kGold,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Resumen Ejecutivo',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    item['summary'] ?? 'Sin resumen',
                    style: const TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                  const Divider(color: Colors.white24, height: 40),
                  const Text(
                    'Transcripción Completa',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    item['transcript'] ?? 'Sin transcripción',
                    style: const TextStyle(color: Colors.white54, fontSize: 12),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(color: Color(0xFF050B14)),
      child: Column(
        children: [
          // Header Plaud
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.black, _kGold.withValues(alpha: 0.1)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Plaud Note Engine',
                      style: TextStyle(
                        color: _kGold,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (_isProcessing)
                      const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: _kGold,
                        ),
                      )
                    else
                      IconButton(
                        icon: const Icon(
                          Icons.upload_file,
                          color: Colors.cyanAccent,
                        ),
                        onPressed: _uploadAndAnalyze,
                        tooltip: 'Subir audio externo',
                      ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  _statusMessage,
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                // Botón Gigante de Grabar
                GestureDetector(
                  onTap: _isProcessing ? null : _toggleRecord,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _isRecording ? Colors.red : Colors.transparent,
                      border: Border.all(
                        color: _isRecording ? Colors.redAccent : _kGold,
                        width: 4,
                      ),
                      boxShadow: _isRecording
                          ? [
                              BoxShadow(
                                color: Colors.red.withValues(alpha: 0.5),
                                blurRadius: 30,
                                spreadRadius: 10,
                              ),
                            ]
                          : [],
                    ),
                    child: Center(
                      child: Icon(
                        _isRecording ? Icons.stop : Icons.mic_none,
                        size: 50,
                        color: _isRecording ? Colors.white : _kGold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const Divider(color: Colors.white10, height: 1),

          // History Section
          Expanded(
            child: _history.isEmpty
                ? const Center(
                    child: Text(
                      'No hay notas procesadas',
                      style: TextStyle(color: Colors.white38),
                    ),
                  )
                : ListView.builder(
                    itemCount: _history.length,
                    padding: const EdgeInsets.all(10),
                    itemBuilder: (context, index) {
                      final item = _history[index];
                      return Card(
                        color: Colors.white.withValues(alpha: 0.05),
                        margin: const EdgeInsets.symmetric(vertical: 5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                          side: BorderSide(
                            color: _kGold.withValues(alpha: 0.2),
                          ),
                        ),
                        child: ListTile(
                          leading: const CircleAvatar(
                            backgroundColor: Colors.black45,
                            child: Icon(
                              Icons.description,
                              color: _kGold,
                              size: 20,
                            ),
                          ),
                          title: Text(
                            item['summary']?.split('\n').first ??
                                'Recorte sin título',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(color: Colors.white),
                          ),
                          subtitle: Text(
                            item['date'] ?? '',
                            style: const TextStyle(
                              color: Colors.white54,
                              fontSize: 11,
                            ),
                          ),
                          trailing: const Icon(
                            Icons.chevron_right,
                            color: Colors.white38,
                          ),
                          onTap: () => _showSummaryDetails(item),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
