import 'package:flutter/material.dart';
import 'screens/alba_chat_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const CleoApp());
}

class CleoApp extends StatelessWidget {
  const CleoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cleo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.dark(
          primary: const Color(0xFF7C3AED),
          surface: const Color(0xFF1A0E2E),
        ),
        scaffoldBackgroundColor: const Color(0xFF1A0E2E),
        useMaterial3: true,
      ),
      home: const AlbaChatScreen(),
    );
  }
}
