import 'package:flutter/material.dart';
import 'screens/welcome_screen.dart';
import 'screens/alba_chat_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ApliBotApp());
}

class ApliBotApp extends StatelessWidget {
  const ApliBotApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ApliBot System',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF030712),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFD4AF37),
          secondary: Color(0xFF00E5FF),
          surface: Color(0xFF1F2937),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF0A1120),
          elevation: 0,
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const WelcomeScreen(),
        '/alba': (context) => const AlbaChatScreen(),
      },
    );
  }
}
