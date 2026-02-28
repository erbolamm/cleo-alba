import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:webview_flutter/webview_flutter.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:screen_brightness/screen_brightness.dart';

// ─────────────────────────────────────────────────────────────────
//  SmartDisplay — Pantalla interactiva del agente OpenClaw
//  Muestra el estado visual: hablando, escuchando, foto, etc.
//  Carga smart_display.html que se conecta al bridge en :8080
// ─────────────────────────────────────────────────────────────────

class SmartDisplayScreen extends StatefulWidget {
  const SmartDisplayScreen({super.key});

  @override
  State<SmartDisplayScreen> createState() => _SmartDisplayScreenState();
}

class _SmartDisplayScreenState extends State<SmartDisplayScreen> {
  late final WebViewController _controller;
  bool _isLoaded = false;

  @override
  void initState() {
    super.initState();
    WakelockPlus.enable();
    _setMaxBrightness();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.black)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (url) {
            setState(() => _isLoaded = true);
          },
        ),
      );
    _loadHtml();
  }

  @override
  void dispose() {
    _restoreBrightness();
    WakelockPlus.disable();
    super.dispose();
  }

  Future<void> _setMaxBrightness() async {
    try {
      await ScreenBrightness.instance.setApplicationScreenBrightness(1.0);
    } catch (_) {}
  }

  Future<void> _restoreBrightness() async {
    try {
      await ScreenBrightness.instance.resetApplicationScreenBrightness();
    } catch (_) {}
  }

  Future<void> _loadHtml() async {
    final html = await rootBundle.loadString('assets/web/smart_display.html');
    _controller.loadHtmlString(html, baseUrl: 'http://localhost:8080');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          'Smart Display',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white70,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white54),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white38),
            onPressed: () {
              setState(() => _isLoaded = false);
              _loadHtml();
            },
            tooltip: 'Recargar',
          ),
        ],
        elevation: 0,
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (!_isLoaded)
            const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(color: Colors.cyanAccent),
                  SizedBox(height: 16),
                  Text(
                    'Cargando Smart Display...',
                    style: TextStyle(color: Colors.white38),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
