import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

// ─────────────────────────────────────────────────────────────────
//  ClawMobil — Panel de Control Mínimo
//  Auto-arranca OpenClaw al abrirse · Comandos copiables · Estado
// ─────────────────────────────────────────────────────────────────

class ControlPanelScreen extends StatefulWidget {
  const ControlPanelScreen({super.key});

  @override
  State<ControlPanelScreen> createState() => _ControlPanelScreenState();
}

class _ControlPanelScreenState extends State<ControlPanelScreen> {
  // Service status
  bool _bridgeOnline = false;
  bool _openclawOnline = false;
  bool _isChecking = true;
  bool _autoStartSent = false;
  String _lastLog = '';
  Timer? _pollTimer;

  // Commands users can copy-paste into Termux
  static const List<Map<String, String>> _commands = [
    {
      'title': '🦞 Arrancar OpenClaw',
      'cmd':
          'screen -dmS openclaw proot-distro login debian -- openclaw gateway run',
      'desc': 'Inicia OpenClaw en una sesión screen persistente',
    },
    {
      'title': '🐍 Arrancar Bridge Server',
      'cmd': 'python3 /sdcard/server.py &',
      'desc': 'Lanza el servidor bridge HTTP en segundo plano',
    },
    {
      'title': '📡 Arrancar SSH',
      'cmd': 'sshd',
      'desc': 'Inicia el servidor SSH en el puerto 8022',
    },
    {
      'title': '🔍 Ver sesiones screen',
      'cmd': 'screen -ls',
      'desc': 'Lista las sesiones activas (debería aparecer openclaw)',
    },
    {
      'title': '📋 Ver logs de OpenClaw',
      'cmd': 'proot-distro login debian -- openclaw status',
      'desc': 'Muestra estado completo del gateway',
    },
    {
      'title': '🔄 Reiniciar OpenClaw',
      'cmd':
          'screen -S openclaw -X quit; sleep 2; screen -dmS openclaw proot-distro login debian -- openclaw gateway run',
      'desc': 'Mata y vuelve a arrancar OpenClaw',
    },
    {
      'title': '🚀 TODO (un solo comando)',
      'cmd': 'bash /sdcard/clawmobil/start.sh',
      'desc': 'Arranca TODOS los servicios de un tirón',
    },
  ];

  @override
  void initState() {
    super.initState();
    _autoStart();
    _checkServices();
    // Poll every 15 seconds
    _pollTimer = Timer.periodic(const Duration(seconds: 15), (_) {
      _checkServices();
    });
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }

  // ──────────── AUTO-START via Termux Intent ────────────

  Future<void> _autoStart() async {
    if (_autoStartSent) return;
    _autoStartSent = true;
    setState(() {
      _lastLog = '🚀 Enviando intent a Termux...';
    });

    try {
      const platform = MethodChannel('com.aplibot/termux');
      await platform.invokeMethod('runCommand', {
        'path': '/data/data/com.termux/files/usr/bin/bash',
        'args': ['/sdcard/clawmobil/start.sh'],
        'background': true,
      });
      setState(() {
        _lastLog = '✅ Intent enviado a Termux. Esperando servicios...';
      });
    } catch (e) {
      setState(() {
        _lastLog = '⚠️ Termux no respondió. Usa los comandos de abajo.';
      });
    }

    // Wait a bit then check again
    await Future.delayed(const Duration(seconds: 8));
    _checkServices();
  }

  // ──────────── SERVICE CHECKS ────────────

  Future<void> _checkServices() async {
    if (!mounted) return;
    setState(() => _isChecking = true);

    // Check bridge server
    bool bridge = false;
    try {
      final resp = await http
          .get(Uri.parse('http://localhost:8080/api/status'))
          .timeout(const Duration(seconds: 3));
      bridge = resp.statusCode == 200;
    } catch (_) {}

    // Check OpenClaw gateway (port 18789)
    bool openclaw = false;
    try {
      final resp = await http
          .get(Uri.parse('http://localhost:18789/'))
          .timeout(const Duration(seconds: 3));
      openclaw = resp.statusCode == 200 || resp.statusCode == 401;
    } catch (_) {}

    if (mounted) {
      setState(() {
        _bridgeOnline = bridge;
        _openclawOnline = openclaw;
        _isChecking = false;
      });
    }
  }

  Future<void> _restartAll() async {
    setState(() {
      _autoStartSent = false;
      _lastLog = '🔄 Reiniciando todo...';
    });
    await _autoStart();
  }

  void _copyCommand(String cmd) {
    Clipboard.setData(ClipboardData(text: cmd));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
            '📋 Copiado: ${cmd.length > 40 ? '${cmd.substring(0, 40)}...' : cmd}'),
        backgroundColor: const Color(0xFF1E3A5F),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // ──────────── UI ────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF050B14),
      appBar: AppBar(
        title: const Text(
          'ClawMobil',
          style: TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 20,
            letterSpacing: 1,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF0A1120),
        elevation: 0,
        actions: [
          IconButton(
            icon: _isChecking
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.cyanAccent,
                    ),
                  )
                : const Icon(Icons.refresh, color: Colors.cyanAccent),
            onPressed: _isChecking ? null : _checkServices,
            tooltip: 'Verificar servicios',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Status Cards ──
            _buildStatusSection(),
            const SizedBox(height: 20),

            // ── Restart Button ──
            _buildRestartButton(),
            const SizedBox(height: 12),

            // ── Log ──
            if (_lastLog.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F172A),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.white10),
                ),
                child: Text(
                  _lastLog,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    fontFamily: 'monospace',
                  ),
                ),
              ),
            const SizedBox(height: 24),

            // ── Commands Section ──
            const Text(
              '📋 COMANDOS TERMUX',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w800,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Pulsa para copiar · Pega en Termux',
              style: TextStyle(color: Colors.white38, fontSize: 12),
            ),
            const SizedBox(height: 12),
            ..._commands.map((c) => _buildCommandCard(c)),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF0F172A),
            const Color(0xFF1E293B).withValues(alpha: 0.5),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        children: [
          const Text(
            'ESTADO DE SERVICIOS',
            style: TextStyle(
              color: Colors.white54,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatusIndicator(
                  icon: Icons.dns,
                  label: 'Bridge',
                  online: _bridgeOnline,
                  port: '8080',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatusIndicator(
                  icon: Icons.hub,
                  label: 'OpenClaw',
                  online: _openclawOnline,
                  port: '18789',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusIndicator({
    required IconData icon,
    required String label,
    required bool online,
    required String port,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: online
            ? Colors.green.withValues(alpha: 0.1)
            : Colors.red.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: online
              ? Colors.green.withValues(alpha: 0.3)
              : Colors.red.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: online ? Colors.greenAccent : Colors.redAccent,
            size: 28,
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 14,
            ),
          ),
          Text(
            online ? '✅ Online' : '❌ Offline',
            style: TextStyle(
              color: online ? Colors.greenAccent : Colors.redAccent,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            ':$port',
            style: const TextStyle(color: Colors.white38, fontSize: 10),
          ),
        ],
      ),
    );
  }

  Widget _buildRestartButton() {
    final allOnline = _bridgeOnline && _openclawOnline;
    return ElevatedButton.icon(
      onPressed: _restartAll,
      icon: const Icon(Icons.restart_alt, size: 22),
      label: Text(
        allOnline ? '🟢 TODO FUNCIONANDO · Reiniciar' : '🔴 ARRANCAR SERVICIOS',
        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor:
            allOnline ? const Color(0xFF065F46) : const Color(0xFF991B1B),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        elevation: 4,
      ),
    );
  }

  Widget _buildCommandCard(Map<String, String> cmd) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () => _copyCommand(cmd['cmd']!),
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xFF0F172A),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.white10),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      cmd['title']!,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      cmd['desc']!,
                      style: const TextStyle(
                        color: Colors.white38,
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      cmd['cmd']!,
                      style: const TextStyle(
                        color: Colors.cyanAccent,
                        fontSize: 10,
                        fontFamily: 'monospace',
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.copy, color: Colors.white30, size: 18),
            ],
          ),
        ),
      ),
    );
  }
}
