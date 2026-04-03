import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class RescueScreen extends StatefulWidget {
  final String localPath;
  const RescueScreen({super.key, required this.localPath});

  @override
  State<RescueScreen> createState() => _RescueScreenState();
}

class _RescueScreenState extends State<RescueScreen> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();
    String url = widget.localPath;
    if (!url.startsWith('http')) {
      url = 'file://$url';
    }
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..loadRequest(Uri.parse(url));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Modo Rescate (HTML)'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: WebViewWidget(controller: _controller),
    );
  }
}
