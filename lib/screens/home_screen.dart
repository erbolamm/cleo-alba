import 'package:flutter/material.dart';
import 'chat_screen.dart';
import 'avatar_screen.dart';
import 'mission_screen.dart';
import 'plaud_screen.dart';
import 'smart_display_screen.dart';

class HomeScreen extends StatefulWidget {
  final bool initialOfflineMode;

  const HomeScreen({super.key, this.initialOfflineMode = false});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late bool _isOffline;

  @override
  void initState() {
    super.initState();
    _isOffline = widget.initialOfflineMode;
  }

  @override
  Widget build(BuildContext context) {
    // Definir pestañas dinámicamente
    final List<Map<String, dynamic>> tabs = [
      {'icon': Icons.chat, 'text': 'Chat', 'view': const ChatScreen()},
      {'icon': Icons.face, 'text': 'Avatar', 'view': const AvatarScreen()},
      if (!_isOffline)
        {
          'icon': Icons.monitor,
          'text': 'Pantalla',
          'view': const SmartDisplayScreen()
        },
      {'icon': Icons.mic, 'text': 'Plaud', 'view': const PlaudScreen()},
      {
        'icon': Icons.dashboard,
        'text': 'Misión',
        'view': const MissionDashboard()
      },
    ];

    return DefaultTabController(
      length: tabs.length,
      child: Scaffold(
        bottomNavigationBar: Container(
          color: const Color(0xFF0A1120),
          child: TabBar(
            isScrollable: false, // Forzar a ocupar el ancho total sin scroll
            labelPadding: EdgeInsets.zero, // Reducir espacio entre iconos
            tabs: tabs
                .map((t) => Tab(
                      icon: Icon(t['icon'], size: 20), // Icono más pequeño
                      child: Text(
                        t['text'],
                        style: const TextStyle(fontSize: 9), // Fuente pequeña
                        overflow: TextOverflow.ellipsis,
                      ),
                    ))
                .toList(),
            indicatorColor: Colors.cyanAccent,
            labelColor: Colors.cyanAccent,
            unselectedLabelColor: Colors.white54,
          ),
        ),
        body: TabBarView(
          children: tabs.map<Widget>((t) => t['view'] as Widget).toList(),
        ),
      ),
    );
  }
}
