import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'avatar_screen.dart';
import 'smart_display_screen.dart';

const _kGold = Color(0xFFD4AF37);

class MissionDashboard extends StatefulWidget {
  const MissionDashboard({super.key});

  @override
  State<MissionDashboard> createState() => _MissionDashboardState();
}

class _MissionDashboardState extends State<MissionDashboard> {
  Map<String, dynamic> _config = {};
  Map<String, dynamic> _status = {};
  bool _loading = true;
  bool _restarting = false;
  String _restartMsg = '';
  String _apiBase = 'http://localhost:8080';
  bool _showLabels = true; // Control de visibilidad de textos
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _loadData();
    _refreshTimer = Timer.periodic(
      const Duration(seconds: 5),
      (_) => _loadData(),
    );
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  Future<void> _doRestart(String target) async {
    setState(() {
      _restarting = true;
      _restartMsg = target == 'openclaw'
          ? '🔄 Reiniciando OpenClaw...'
          : '🔄 Reiniciando todo el stack...';
    });
    try {
      final resp = await http
          .post(
            Uri.parse('$_apiBase/api/system/restart'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'target': target}),
          )
          .timeout(const Duration(seconds: 10));
      if (resp.statusCode == 200) {
        setState(() => _restartMsg = '✅ Reinicio iniciado. Espera ~10s...');
        // Después de 12 segundos volver a comprobar el estado
        await Future.delayed(const Duration(seconds: 12));
        await _loadData();
        setState(() {
          _restartMsg =
              _status.isNotEmpty ? '✅ Reconectado' : '⚠️ Sin respuesta aún...';
        });
      } else {
        setState(
          () => _restartMsg = '❌ Error del servidor (${resp.statusCode})',
        );
      }
    } catch (e) {
      setState(
        () => _restartMsg =
            '⚠️ Sin comunicación. ¿Está server.py caído?\nInicia server.py desde Termux manualmente.',
      );
    } finally {
      setState(() => _restarting = false);
    }
  }

  Future<void> _doStartApliBot() async {
    setState(() {
      _restarting = true;
      _restartMsg = '🚀 Lanzando AutoBoot...';
    });
    try {
      final resp = await http.post(
        Uri.parse('$_apiBase/api/system/start'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 10));
      if (resp.statusCode == 200) {
        setState(() => _restartMsg = '✅ Script lanzado. Reiniciando puente...');
        await Future.delayed(const Duration(seconds: 5));
        await _loadData();
      } else {
        setState(
          () => _restartMsg = '❌ Error (${resp.statusCode}): ${resp.body}',
        );
      }
    } catch (e) {
      setState(() => _restartMsg = '⚠️ Error: $e');
    } finally {
      setState(() => _restarting = false);
    }
  }

  Future<void> _loadData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _apiBase = prefs.getString('api_base') ?? 'http://localhost:8080';

      final futures = await Future.wait([
        http
            .get(Uri.parse('$_apiBase/api/config'))
            .timeout(const Duration(seconds: 5)),
        http
            .get(Uri.parse('$_apiBase/api/status'))
            .timeout(const Duration(seconds: 5)),
      ]);

      if (mounted) {
        setState(() {
          _config = jsonDecode(futures[0].body);
          _status = jsonDecode(futures[1].body);
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF050B14), Color(0xFF0A1120), Color(0xFF151E32)],
        ),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            spacing: 3,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color:
                          _status.isNotEmpty && (_status['agent_alive'] == true)
                              ? Colors.green
                              : Colors.red,
                      boxShadow: [
                        BoxShadow(
                          color: (_status.isNotEmpty &&
                                      (_status['agent_alive'] == true)
                                  ? Colors.green
                                  : Colors.red)
                              .withValues(alpha: 0.6),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _status.isNotEmpty && (_status['agent_alive'] == true)
                        ? 'ONLINE'
                        : 'OFFLINE',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 3,
                      color:
                          _status.isNotEmpty && (_status['agent_alive'] == true)
                              ? Colors.green
                              : Colors.red,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    _config['device_name'] ?? 'Device',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: Icon(
                      _showLabels
                          ? Icons.speaker_notes
                          : Icons.speaker_notes_off,
                      color: _showLabels ? Colors.cyanAccent : Colors.white38,
                      size: 20,
                    ),
                    onPressed: () => setState(() => _showLabels = !_showLabels),
                    tooltip: 'Mostrar/Ocultar textos',
                  ),
                  IconButton(
                    icon: const Icon(Icons.refresh,
                        color: Colors.white38, size: 20),
                    onPressed: _loadData,
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Status Cards
              if (_loading)
                const Center(
                  child: CircularProgressIndicator(color: Colors.blueAccent),
                )
              else ...[
                _glassCard(
                  'Servidor',
                  Icons.dns,
                  _status['server'] ?? 'Activo',
                  'v${_config['version'] ?? '?'}',
                  Colors.blueAccent,
                ),
                const SizedBox(height: 10),
                _glassCard(
                  'IA',
                  Icons.psychology,
                  (_config['hasGroq'] == true)
                      ? 'Groq Cloud ✓'
                      : 'Solo offline',
                  (_config['hasOllama'] == true)
                      ? 'Ollama disponible'
                      : 'Sin LLM local',
                  (_config['hasGroq'] == true) ? Colors.green : Colors.amber,
                ),
                const SizedBox(height: 10),
                _glassCard(
                  'STT',
                  Icons.mic,
                  (_config['hasGroq'] == true)
                      ? 'Groq Whisper ✓'
                      : 'whisper.cpp',
                  (_config['hasWhisperLocal'] == true)
                      ? 'Backup offline ✓'
                      : 'Solo online',
                  Colors.cyanAccent,
                ),
              ],

              const SizedBox(height: 16),

              const SizedBox(height: 16),

              // ── Botones de acción rápida ─────────────────────────────
              Row(
                children: [
                  Expanded(
                    child: SystemControlButton(
                      icon: Icons.restart_alt,
                      label: 'REINICIAR AGENTE',
                      desc: 'Solo OpenClaw',
                      color: Colors.orangeAccent,
                      showLabel: _showLabels,
                      onTap: _restarting ? null : () => _doRestart('openclaw'),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: SystemControlButton(
                      icon: Icons.power_settings_new,
                      label: 'RESET SISTEMA',
                      desc: 'Todo el stack',
                      color: Colors.redAccent,
                      showLabel: _showLabels,
                      onTap: _restarting ? null : () => _doRestart('all'),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: SystemControlButton(
                      icon: _loading ? Icons.sync_problem : Icons.refresh,
                      label: _loading ? 'Cargando...' : 'Verificar',
                      color: _loading ? Colors.grey : Colors.cyanAccent,
                      showLabel: _showLabels,
                      onTap: _restarting || _loading
                          ? null
                          : () async {
                              setState(() => _loading = true);
                              await _loadData();
                              if (!context.mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Estado actualizado ✓'),
                                  duration: Duration(seconds: 1),
                                ),
                              );
                            },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Expanded(
                    child: SystemControlButton(
                      icon: Icons.rocket_launch,
                      label: 'Comenzar ApliBot',
                      color: Colors.greenAccent,
                      showLabel: _showLabels,
                      onTap: _restarting ? null : _doStartApliBot,
                    ),
                  ),
                  const Spacer(),
                ],
              ),

              // Feedback de reinicio
              if (_restartMsg.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: _kGold.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: _kGold.withValues(alpha: 0.25)),
                    ),
                    child: Text(
                      _restartMsg,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.white70,
                        height: 1.5,
                      ),
                    ),
                  ),
                ),

              const SizedBox(height: 16),

              // ── Gestión del Avatar (NUEVO) ───────────────────────────
              Row(
                children: [
                  const Text(
                    'GESTIÓN DEL AVATAR',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 3,
                      color: Colors.purpleAccent,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Container(
                      height: 1,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.purpleAccent.withValues(alpha: 0.4),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Controles del Avatar trasplantados
              _avatarControlGrid(),

              const SizedBox(height: 16),

              // Logs
              Row(
                children: [
                  const Text(
                    'ACTIVIDAD',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 3,
                      color: _kGold,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Container(
                      height: 1,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            _kGold.withValues(alpha: 0.4),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              SizedBox(height: 200, child: _buildLiveLog()),

              // IP Footer
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Center(
                  child: Text(
                    _apiBase,
                    style: TextStyle(
                      fontSize: 10,
                      fontFamily: 'monospace',
                      color: Colors.white.withValues(alpha: 0.2),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _avatarControlGrid() {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        _missionToolBtn(
          icon: Icons.tv,
          label: 'Smart Display',
          desc: 'Abrir interfaz interactiva.',
          color: Colors.cyanAccent,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const SmartDisplayScreen(),
              ),
            );
          },
        ),
        _missionToolBtn(
          icon: Icons.psychology,
          label: 'Cambiar Persona',
          desc: 'Ajusta la personalidad del bot.',
          color: Colors.purpleAccent,
          onTap: () => _showPersonaDialog(),
        ),
        _missionToolBtn(
          icon: Icons.delete_sweep,
          label: 'Limpiar Chat',
          desc: 'Borra el historial del avatar.',
          color: Colors.redAccent,
          onTap: () => _showConfirmClearChat(),
        ),
        _missionToolBtn(
          icon: Icons.headset_mic,
          label: 'Escucha Activa',
          desc: 'Auto-escucha tras responder.',
          color: Colors.greenAccent,
          onTap: () => _toggleAutoListen(),
        ),
        _missionToolBtn(
          icon: Icons.visibility,
          label: 'Seguimiento Ocular',
          desc: 'Activa el movimiento de ojos.',
          color: Colors.blueAccent,
          onTap: () => _toggleEyeTracking(),
        ),
        _missionToolBtn(
          icon: Icons.power_settings_new,
          label: 'Modo Sueño',
          desc: 'Duerme o despierta al avatar.',
          color: Colors.amber,
          onTap: () => _toggleSleep(),
        ),
      ],
    );
  }

  Widget _missionToolBtn({
    required IconData icon,
    required String label,
    required String desc,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: _showLabels ? (MediaQuery.of(context).size.width - 42) / 2 : 44,
        padding: EdgeInsets.all(_showLabels ? 10 : 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          crossAxisAlignment: _showLabels
              ? CrossAxisAlignment.start
              : CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: _showLabels ? 20 : 24),
            if (_showLabels) ...[
              const SizedBox(height: 6),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                desc,
                style: const TextStyle(color: Colors.white54, fontSize: 9),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
      ),
    );
  }

  // Métodos de acción que se comunican con el estado del Avatar vía GlobalKey
  void _showPersonaDialog() {
    final state = AvatarScreen.avatarKey.currentState;
    if (state == null) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('💡 Seleccionar Persona'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: state.personas.keys.map((p) {
            return ListTile(
              title: Text(p),
              onTap: () {
                state.setPersona(p);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Avatar en modo: $p 🎭')),
                );
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showConfirmClearChat() {
    final state = AvatarScreen.avatarKey.currentState;
    if (state == null) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('⚠️ Limpiar Historial'),
        content: const Text(
          'Esto borrará la memoria reciente del avatar. ¿Continuar?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              state.clearHistory();
              Navigator.pop(context);
            },
            child: const Text('Limpiar'),
          ),
        ],
      ),
    );
  }

  void _toggleAutoListen() {
    final state = AvatarScreen.avatarKey.currentState;
    if (state == null) return;
    state.setState(() {
      state.autoListen = !state.autoListen;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          state.autoListen
              ? 'Escucha activa habilitada 🎧'
              : 'Escucha activa deshabilitada 🔇',
        ),
      ),
    );
    setState(() {}); // Forzar refresco local del dashboard
  }

  void _toggleEyeTracking() {
    final state = AvatarScreen.avatarKey.currentState;
    if (state == null) return;
    state.setState(() {
      state.eyeTracking = !state.eyeTracking;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          state.eyeTracking ? 'Mirada activada 👀' : 'Mirada desactivada 😶',
        ),
      ),
    );
    setState(() {}); // Forzar refresco local del dashboard
  }

  void _toggleSleep() {
    final state = AvatarScreen.avatarKey.currentState;
    if (state == null) return;
    state.setState(() {
      state.isAsleep = !state.isAsleep;
      if (state.isAsleep) {
        state.botText = 'Zzz... Durmiendo el sistema.';
      } else {
        state.botText = '¡Hola! Ya estoy despierto.';
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          state.isAsleep ? 'Avatar durmiendo 😴' : 'Avatar despierto ☀️',
        ),
      ),
    );
    setState(() {}); // Forzar refresco local del dashboard
  }

  Widget _glassCard(
    String title,
    IconData icon,
    String value,
    String sub,
    Color accent,
  ) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: accent.withValues(alpha: 0.15)),
        boxShadow: [
          BoxShadow(
            color: accent.withValues(alpha: 0.05),
            blurRadius: 12,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: accent.withValues(alpha: 0.2)),
            ),
            child: Icon(icon, color: accent, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 2,
                    color: Colors.white.withValues(alpha: 0.4),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                Text(
                  sub,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.white.withValues(alpha: 0.35),
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: accent,
              boxShadow: [
                BoxShadow(color: accent.withValues(alpha: 0.5), blurRadius: 6),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLiveLog() {
    final logs = <String>[];
    if (_status.isNotEmpty) {
      logs.add('[SYS] Server running on $_apiBase');
      if (_config['hasGroq'] == true) logs.add('[AI] Groq Cloud ready');
      if (_config['hasOllama'] == true) logs.add('[AI] Ollama fallback ready');
      if (_config['hasWhisperLocal'] == true) {
        logs.add('[STT] whisper.cpp ready');
      }
      if (_config['hasTelegram'] == true) logs.add('[BOT] Telegram connected');
      logs.add('[NET] Status: healthy');
    } else {
      logs.add('[ERR] Cannot reach server');
      logs.add('[NET] Check connection to $_apiBase');
    }

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      padding: const EdgeInsets.all(12),
      child: SingleChildScrollView(
        child: Text(
          logs.join('\n'),
          style: const TextStyle(
            fontFamily: 'monospace',
            fontSize: 11,
            color: Colors.greenAccent,
            height: 1.7,
          ),
        ),
      ),
    );
  }
}

class SystemControlButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? desc;
  final Color color;
  final VoidCallback? onTap;
  final double? width;
  final bool showLabel;

  const SystemControlButton({
    super.key,
    required this.icon,
    required this.label,
    this.desc,
    required this.color,
    this.onTap,
    this.width,
    this.showLabel = true,
  });

  @override
  Widget build(BuildContext context) {
    final disabled = onTap == null;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedOpacity(
        opacity: disabled ? 0.4 : 1.0,
        duration: const Duration(milliseconds: 200),
        child: Container(
          width: width,
          padding: EdgeInsets.symmetric(
              vertical: showLabel ? 12 : 10, horizontal: 8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: color.withValues(alpha: 0.3)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: desc != null && showLabel
                ? CrossAxisAlignment.start
                : CrossAxisAlignment.center,
            children: [
              Icon(icon,
                  color: color, size: (desc != null && showLabel) ? 20 : 24),
              if (showLabel) ...[
                const SizedBox(height: 8),
                Text(
                  label,
                  textAlign: desc != null ? TextAlign.left : TextAlign.center,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                    height: 1.2,
                  ),
                ),
                if (desc != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    desc!,
                    style: const TextStyle(color: Colors.white54, fontSize: 9),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ],
          ),
        ),
      ),
    );
  }
}
