import 'package:flutter/material.dart';
import 'screens/control_panel_screen.dart';
import 'screens/plaud_chat_screen.dart';
import 'screens/smart_display_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const PlaudAssistantApp());
}

class PlaudAssistantApp extends StatelessWidget {
  const PlaudAssistantApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Plaud Assistant',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF030712),
        primaryColor: const Color(0xFF7C3AED),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1A0E2E),
          elevation: 0,
        ),
      ),
      initialRoute: '/plaud',
      routes: {
        '/': (context) => const ControlPanelScreen(),
        '/plaud': (context) => const PlaudChatScreen(),
        '/display': (context) => const SmartDisplayScreen(),
      },
    );
  }
}
