import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:record/record.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';

// Paleta local (referencia)
const _kGold = Color(0xFFD4AF37);

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();
  final List<Map<String, dynamic>> _messages = [];
  bool _isTyping = false;
  bool _isRecording = false;
  String _apiBase = 'http://localhost:8080';
  final AudioRecorder _recorder = AudioRecorder();

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _apiBase = prefs.getString('api_base') ?? 'http://localhost:8080';
    });
  }

  @override
  void dispose() {
    _recorder.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _toggleRecording() async {
    if (_isRecording) {
      final path = await _recorder.stop();
      setState(() => _isRecording = false);
      if (path != null) {
        _uploadFile(path, 'audio_message.m4a', isVoice: true);
      }
    } else {
      if (await _recorder.hasPermission()) {
        final dir = await getTemporaryDirectory();
        final path =
            '${dir.path}/chat_voice_${DateTime.now().millisecondsSinceEpoch}.m4a';
        await _recorder.start(const RecordConfig(), path: path);
        setState(() => _isRecording = true);
      }
    }
  }

  Future<void> _pickFile() async {
    try {
      final result = await FilePicker.platform.pickFiles();
      if (result == null || result.files.isEmpty) return;

      final file = result.files.first;
      final path = file.path;
      if (path == null) return;

      await _uploadFile(path, file.name);
    } catch (e) {
      _addLocalMessage('assistant', 'Error seleccionando archivo: $e');
    }
  }

  void _addLocalMessage(
    String role,
    String content, {
    String? filePath,
    bool isVoice = false,
  }) {
    setState(() {
      _messages.add({
        'role': role,
        'content': isVoice ? '🎤 Nota de voz' : content,
        'filePath': filePath,
        'isImage': filePath != null &&
            (filePath.toLowerCase().endsWith('.jpg') ||
                filePath.toLowerCase().endsWith('.png') ||
                filePath.toLowerCase().endsWith('.jpeg')),
        'isVoice': isVoice,
      });
    });
    _scrollToBottom();
  }

  Future<void> _uploadFile(
    String path,
    String name, {
    bool isVoice = false,
  }) async {
    _addLocalMessage(
      'user',
      isVoice ? '🎤 Enviando nota de voz...' : '📎 Archivo: $name',
      filePath: path,
      isVoice: isVoice,
    );

    setState(() => _isTyping = true);
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$_apiBase/api/upload'),
      );
      request.files.add(await http.MultipartFile.fromPath('file', path));
      request.fields['filename'] = name;

      var streamedResponse = await request.send().timeout(
            const Duration(seconds: 60),
          );
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        _addLocalMessage(
          'assistant',
          data['response'] ?? 'Archivo recibido y procesado.',
        );
      } else {
        _addLocalMessage(
          'assistant',
          'Error subiendo archivo: ${response.statusCode}',
        );
      }
    } catch (e) {
      _addLocalMessage('assistant', 'Error de conexión (upload): $e');
    } finally {
      setState(() => _isTyping = false);
    }
  }

  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    _addLocalMessage('user', text);
    _controller.clear();
    setState(() => _isTyping = true);

    try {
      final response = await http
          .post(
            Uri.parse('$_apiBase/api/chat'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({"text": text, "speak": false}),
          )
          .timeout(const Duration(seconds: 60));

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        final botReply = data['response'] ?? 'Sin respuesta';
        _addLocalMessage('assistant', botReply);
      } else {
        _addLocalMessage('assistant', 'Error: ${response.statusCode}');
      }
    } catch (e) {
      _addLocalMessage('assistant', 'Error de conexión: $e');
    } finally {
      setState(() => _isTyping = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      resizeToAvoidBottomInset: true,
      body: Column(
        children: [
          // Lista de Mensajes
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                final isUser = msg['role'] == 'user';
                final hasImage = msg['isImage'] == true;
                final filePath = msg['filePath'] as String?;

                return Align(
                  alignment:
                      isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.75,
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: isUser
                          ? _kGold
                          : Colors.white.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(15).copyWith(
                        bottomRight: isUser ? const Radius.circular(0) : null,
                        bottomLeft: !isUser ? const Radius.circular(0) : null,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (hasImage && filePath != null)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.file(
                                File(filePath),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        SelectableText(
                          msg['content'] ?? '',
                          style: TextStyle(
                            color: isUser ? Colors.black : Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          if (_isTyping)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
              child: LinearProgressIndicator(
                backgroundColor: Colors.transparent,
                color: _kGold,
                minHeight: 1,
              ),
            ),
          // Entrada de Texto
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.add_circle_outline, color: _kGold),
                  onPressed: _pickFile,
                ),
                Expanded(
                  child: TextField(
                    controller: _controller,
                    focusNode: _focusNode,
                    autofocus: true,
                    style: const TextStyle(color: Colors.white),
                    maxLines: 5, // Muestra hasta 5 líneas expandibles
                    minLines: 1,
                    keyboardType: TextInputType.multiline,
                    onTap: () {
                      FocusScope.of(context).requestFocus(_focusNode);
                    },
                    decoration: InputDecoration(
                      hintText: 'Pega aquí el código/texto...',
                      hintStyle: const TextStyle(color: Colors.white54),
                      filled: true,
                      fillColor: Colors.white.withValues(alpha: 0.05),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  backgroundColor: _isRecording ? Colors.red : _kGold,
                  child: IconButton(
                    icon: Icon(
                      _isRecording ? Icons.stop : Icons.mic,
                      color: Colors.black,
                    ),
                    onPressed: _toggleRecording,
                  ),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  backgroundColor: _kGold,
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.black),
                    onPressed: _sendMessage,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
