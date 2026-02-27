import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

// ─────────────────────────────────────────────────────────────────
// Panel de administración para papá/mamá
// Accesible manteniendo pulsado el engranaje 8 segundos
// ─────────────────────────────────────────────────────────────────

class AlbaAdminScreen extends StatefulWidget {
  const AlbaAdminScreen({super.key});

  @override
  State<AlbaAdminScreen> createState() => _AlbaAdminScreenState();
}

class _AlbaAdminScreenState extends State<AlbaAdminScreen> {
  bool _serverRunning = false;
  bool _checking = false;
  bool _groqOk = false;
  String _statusMsg = 'Comprobando conexión...';
  String _serverStatus = 'Comprobando servidor local...';

  @override
  void initState() {
    super.initState();
    _runDiagnostics();
  }

  // ── Diagnóstico ────────────────────────────────────────────────

  Future<void> _runDiagnostics() async {
    setState(() => _checking = true);
    await Future.wait([_checkGroq(), _checkLocalServer()]);
    setState(() => _checking = false);
  }

  Future<void> _checkGroq() async {
    try {
      final resp = await http
          .get(Uri.parse('https://api.groq.com'))
          .timeout(const Duration(seconds: 5));
      setState(() {
        _groqOk = resp.statusCode < 500;
        _statusMsg = _groqOk
            ? '✅ Internet OK — Groq accesible'
            : '⚠️ Groq responde con error ${resp.statusCode}';
      });
    } catch (_) {
      setState(() {
        _groqOk = false;
        _statusMsg = '❌ Sin internet — Cleo no puede responder';
      });
    }
  }

  Future<void> _checkLocalServer() async {
    try {
      final resp = await http
          .get(Uri.parse('http://localhost:8080/api/status'))
          .timeout(const Duration(seconds: 4));
      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body);
        setState(() {
          _serverRunning = true;
          _serverStatus =
              '✅ Servidor local activo (${data['messages']} mensajes en historial)';
        });
      } else {
        setState(() {
          _serverRunning = false;
          _serverStatus = '⚠️ Servidor responde pero con error';
        });
      }
    } catch (_) {
      setState(() {
        _serverRunning = false;
        _serverStatus = '😴 Servidor local apagado (Termux/start.sh)';
      });
    }
  }

  // ── Servidor local (Termux) ────────────────────────────────────

  Future<void> _startServer() async {
    // Lanzar Termux y ejecutar start.sh via RUN_COMMAND intent
    const platform = MethodChannel('com.aplibot/termux');
    try {
      await platform.invokeMethod('runCommand', {
        'path': '/data/data/com.termux/files/usr/bin/bash',
        'args': ['/sdcard/clawmobil/start.sh'],
        'background': true,
      });
      _showSnack('📱 Enviado a Termux. Iniciando servidor...');
      await Future.delayed(const Duration(seconds: 6));
      await _checkLocalServer();
    } catch (_) {
      // Fallback: mostrar instrucciones manuales
      _showManualStartDialog();
    }
  }

  Future<void> _stopServerAndClose() async {
    // Intentar apagar el servidor Python si está corriendo
    try {
      await http
          .post(Uri.parse('http://localhost:8080/api/shutdown'))
          .timeout(const Duration(seconds: 4));
    } catch (_) {}
    // Cerrar la app
    SystemNavigator.pop();
  }

  Future<void> _clearHistory() async {
    try {
      await http
          .post(Uri.parse('http://localhost:8080/api/clear'))
          .timeout(const Duration(seconds: 4));
      _showSnack('🧹 Historial del servidor limpiado');
    } catch (_) {
      _showSnack('ℹ️ No hay servidor local activo');
    }
  }

  // ── Dialogs ────────────────────────────────────────────────────

  void _showManualStartDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        title: const Text(
          '📱 Iniciar servidor manualmente',
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Abre Termux y escribe:',
              style: TextStyle(color: Colors.white70, fontSize: 14),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFF0D0D1A),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const SelectableText(
                'bash /sdcard/clawmobil/start.sh',
                style: TextStyle(
                  color: Colors.greenAccent,
                  fontFamily: 'monospace',
                  fontSize: 13,
                ),
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              '⚠️ Para que funcione, antes habilita en Termux:\nAjustes → Allow External Apps',
              style: TextStyle(color: Colors.white38, fontSize: 12),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Entendido',
                style: TextStyle(color: Color(0xFF7C3AED))),
          ),
        ],
      ),
    );
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: const Color(0xFF3D2560),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  // ── Build ──────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A14),
      appBar: AppBar(
        backgroundColor: const Color(0xFF111122),
        title: const Text(
          '⚙️ Administración',
          style: TextStyle(color: Colors.white70, fontSize: 16),
        ),
        iconTheme: const IconThemeData(color: Colors.white54),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Título ──
            const Padding(
              padding: EdgeInsets.only(bottom: 16),
              child: Text(
                'Panel de papá y mamá 👨‍👩‍👧',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white54,
                  fontSize: 13,
                  letterSpacing: 0.5,
                ),
              ),
            ),

            // ── Estado Groq (internet) ──
            _buildStatusCard(
              icon: _groqOk ? Icons.wifi : Icons.wifi_off,
              iconColor: _groqOk ? Colors.greenAccent : Colors.redAccent,
              message: _statusMsg,
            ),

            const SizedBox(height: 10),

            // ── Estado servidor local ──
            _buildStatusCard(
              icon: _serverRunning ? Icons.dns : Icons.dns_outlined,
              iconColor: _serverRunning ? Colors.greenAccent : Colors.orange,
              message: _serverStatus,
            ),

            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (_checking)
                  const Padding(
                    padding: EdgeInsets.only(right: 8),
                    child: SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                TextButton.icon(
                  onPressed: _runDiagnostics,
                  icon: const Icon(Icons.refresh,
                      size: 16, color: Colors.white38),
                  label: const Text(
                    'Actualizar',
                    style: TextStyle(color: Colors.white38, fontSize: 12),
                  ),
                ),
              ],
            ),

            const Divider(color: Colors.white12, height: 24),

            // ── Botón: iniciar servidor ──
            _buildActionButton(
              icon: Icons.play_circle_outline,
              label: 'Despertar servidor (Termux)',
              subtitle: 'Inicia start.sh en segundo plano',
              color: Colors.greenAccent.shade700,
              onTap: _serverRunning ? null : _startServer,
            ),

            const SizedBox(height: 12),

            // ── Botón: limpiar historial ──
            _buildActionButton(
              icon: Icons.cleaning_services_outlined,
              label: 'Limpiar historial del chat',
              subtitle: 'Borra la memoria del servidor local',
              color: Colors.blueAccent.shade400,
              onTap: _clearHistory,
            ),

            const SizedBox(height: 12),

            // ── Botón: apagar y cerrar ──
            _buildActionButton(
              icon: Icons.power_settings_new,
              label: 'Apagar Cleo y cerrar app',
              subtitle: 'Detiene el servidor y cierra',
              color: Colors.redAccent,
              onTap: _stopServerAndClose,
            ),

            const SizedBox(height: 32),

            // ── Info ──
            const Text(
              'El chat usa Groq directamente desde la app.\n'
              'El servidor local (puerto 8080) es opcional y permite\n'
              'acceder al chat también desde el navegador.',
              textAlign: TextAlign.center,
              style:
                  TextStyle(color: Colors.white24, fontSize: 11, height: 1.6),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard({
    required IconData icon,
    required Color iconColor,
    required String message,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: iconColor.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(color: Colors.white70, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required String subtitle,
    required Color color,
    required VoidCallback? onTap,
  }) {
    return Material(
      color: onTap == null ? Colors.white12 : color.withOpacity(0.15),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: onTap == null ? Colors.white12 : color.withOpacity(0.4),
            ),
          ),
          child: Row(
            children: [
              Icon(icon,
                  color: onTap == null ? Colors.white24 : color, size: 22),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        color: onTap == null ? Colors.white24 : Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: onTap == null ? Colors.white12 : Colors.white38,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: onTap == null ? Colors.white12 : Colors.white38,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
