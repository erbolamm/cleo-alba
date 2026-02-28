import 'package:flutter/material.dart';
import 'screens/control_panel_screen.dart';
import 'screens/alba_chat_screen.dart';
import 'screens/smart_display_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ClawMobilApp());
}

class ClawMobilApp extends StatelessWidget {
  const ClawMobilApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ClawMobil',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF030712),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF005FA9),
          secondary: Color(0xFF5ECEF5),
          surface: Color(0xFF1F2937),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF0A1120),
          elevation: 0,
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const ControlPanelScreen(),
        '/alba': (context) => const AlbaChatScreen(),
        '/display': (context) => const SmartDisplayScreen(),
      },
    );
  }
}
