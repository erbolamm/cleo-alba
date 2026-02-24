import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:webview_flutter/webview_flutter.dart';

class SmartDisplayScreen extends StatefulWidget {
  const SmartDisplayScreen({super.key});

  @override
  State<SmartDisplayScreen> createState() => _SmartDisplayScreenState();
}

class _SmartDisplayScreenState extends State<SmartDisplayScreen> {
  late final WebViewController _webController;
  String _apiBase = 'http://localhost:8080';

  @override
  void initState() {
    super.initState();
    _loadSettings();
    _webController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.black)
      ..setNavigationDelegate(
        NavigationDelegate(
          onWebResourceError: (WebResourceError error) {
            debugPrint('WebView Error: ${error.description}');
          },
        ),
      )
      ..loadRequest(Uri.parse('$_apiBase/display'));
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _apiBase = prefs.getString('api_base') ?? 'http://localhost:8080';
    });
    _webController.loadRequest(Uri.parse('$_apiBase/display'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Smart Display',
          style: TextStyle(color: Colors.cyanAccent, fontSize: 16),
        ),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.cyanAccent),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _webController.reload(),
          ),
        ],
      ),
      backgroundColor: Colors.black,
      body: WebViewWidget(controller: _webController),
    );
  }
}
