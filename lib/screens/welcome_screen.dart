import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'home_screen.dart';
import 'rescue_screen.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  bool _isChecking = false;
  String _statusMessage = '';
  bool _hasInternet = true;
  bool _serverOnline = false;

  // Gatekeeper Logic
  int _retryCount = 0;
  int _secondsLeft = 30;
  Timer? _countdownTimer;
  bool _isWaiting = false;

  final String _websiteUrl = 'https://github.com/erbolamm/plaud-assistant';

  @override
  void initState() {
    super.initState();
    _startSystemSequence();
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }

  Future<void> _startSystemSequence() async {
    await _checkInitialStatus();
  }

  Future<void> _checkInitialStatus() async {
    if (mounted) {
      setState(() {
        _isChecking = true;
        _isWaiting = false;
        _statusMessage = '🔍 Verificando servicios críticos...';
      });
    }

    // 1. Verificar Internet
    _hasInternet = await _checkInternetConnection();

    // 2. Verificar Servidor Local (Plaud Assistant / OpenClaw)
    _serverOnline = await _checkServerOnline();

    if (_serverOnline) {
      if (mounted) {
        setState(() {
          _isChecking = false;
          _retryCount = 0;
          _statusMessage = _hasInternet
              ? '✅ Sistema listo (Online)'
              : '⚠️ Sistema listo (Modo Offline - Ollama)';
        });
      }
    } else {
      // Falló la conexión: Iniciar ciclo de espera/reintento
      _handleRetryCycle();
    }
  }

  void _handleRetryCycle() {
    _retryCount++;
    if (_retryCount >= 3) {
      _showFatalErrorDialog();
    } else {
      _startWaitingPeriod();
    }
  }

  void _startWaitingPeriod() {
    // Intentar auto-arrancar antes de esperar
    _triggerAutoStart();

    setState(() {
      _isChecking = false;
      _isWaiting = true;
      _secondsLeft = 30;
      _statusMessage = '⏳ [Intento $_retryCount/3] Iniciando app...';
    });

    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          if (_secondsLeft > 0) {
            _secondsLeft--;
          } else {
            _countdownTimer?.cancel();
            _checkInitialStatus();
          }
        });
      }
    });
  }

  Future<void> _triggerAutoStart() async {
    // 1. Intentar arrancar mediante intent a Termux (funciona sin servidor)
    try {
      const platform = MethodChannel('com.plaude.assistant');
      await platform.invokeMethod('runCommand', {
        'path': '/data/data/com.termux/files/usr/bin/bash',
        'args': ['/sdcard/clawmobil/start.sh'],
        'background': true,
      });
      debugPrint('🚀 Intent de Termux enviado para arrancar servicios');
    } catch (e) {
      debugPrint('⚠️ Termux intent falló: $e — probando HTTP');
    }

    // 2. Fallback: intentar por HTTP si el bridge ya estaba corriendo
    try {
      final prefs = await SharedPreferences.getInstance();
      final String apiBase =
          prefs.getString('api_base') ?? 'http://localhost:8080';
      await http
          .post(
            Uri.parse('$apiBase/api/system/start'),
            headers: {'Content-Type': 'application/json'},
          )
          .timeout(const Duration(seconds: 5));
    } catch (_) {
      // Ignorar — el chequeo principal dirá si funcionó
    }
  }

  void _showFatalErrorDialog() {
    // Auto-cierre de la app tras 60 segundos si no hay acción
    Future.delayed(const Duration(seconds: 60), () {
      if (mounted) SystemNavigator.pop();
    });

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.redAccent),
            SizedBox(width: 10),
            Text('Error Crítico', style: TextStyle(color: Colors.white)),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'No se ha podido establecer conexión con los servicios del Plaud Assistant tras 3 intentos.',
              style: TextStyle(color: Colors.white70),
            ),
            SizedBox(height: 15),
            Text(
              'PROTOCOLOS RECOMENDADOS:',
              style: TextStyle(
                color: Colors.cyanAccent,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
            SizedBox(height: 5),
            Text(
              '1. Cierre la app y vuelva a abrirla en 5 minutos.',
              style: TextStyle(color: Colors.white70),
            ),
            Text(
              '2. Verifique que Termux esté ejecutando el servicio.',
              style: TextStyle(color: Colors.white70),
            ),
            Text(
              '3. Si el error persiste, REINICIE EL TELÉFONO.',
              style: TextStyle(
                color: Colors.white70,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const RescueScreen(
                    localPath: 'http://127.0.0.1:8080/rescue',
                  ),
                ),
              );
            },
            child: const Text(
              'MODO RESCATE (HTML)',
              style: TextStyle(color: Colors.cyanAccent),
            ),
          ),
          TextButton(
            onPressed: () => SystemNavigator.pop(),
            child: const Text(
              'CERRAR APLICACIÓN',
              style: TextStyle(color: Colors.redAccent),
            ),
          ),
        ],
      ),
    );
  }

  Future<bool> _checkInternetConnection() async {
    try {
      final response = await http
          .get(Uri.parse('https://1.1.1.1'))
          .timeout(const Duration(seconds: 3));
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  Future<bool> _checkServerOnline() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String apiBase =
          prefs.getString('api_base') ?? 'http://localhost:8080';
      final response = await http
          .get(Uri.parse('$apiBase/api/status'))
          .timeout(const Duration(seconds: 3));
      if (response.statusCode == 200) {
        // Si el bridge responde, consideramos que hay servidor.
        return true;
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  Future<void> _handleEnter() async {
    if (_serverOnline) {
      _navigateToHome(forceOffline: false);
      return;
    }
    // Si no está online, forzamos un chequeo ahora mismo si el usuario pulsa
    _checkInitialStatus();
  }

  void _navigateToHome({bool forceOffline = false}) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) =>
            HomeScreen(initialOfflineMode: forceOffline || !_hasInternet),
      ),
    );
  }

  Future<void> _launchWebsite() async {
    final Uri url = Uri.parse(_websiteUrl);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('No se pudo abrir $url')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF050B14),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF050B14), Color(0xFF0A1120), Color(0xFF151E32)],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24.0,
                  vertical: 20.0,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo
                    Container(
                      width: 150,
                      height: 150,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.cyanAccent.withValues(alpha: 0.2),
                            blurRadius: 30,
                            spreadRadius: 10,
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(30),
                        child: Image.asset(
                          'assets/logo.png',
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            // Fallback if image fails to load during Dev
                            return Container(
                              color: Colors.black,
                              child: const Icon(
                                Icons.smart_toy,
                                size: 80,
                                color: Colors.cyanAccent,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),

                    // Titulo
                    const Text(
                      'ApliBot',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Subtitulo
                    Text(
                      'Tu Asistente Táctico Multi-Modal',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.cyanAccent.withValues(alpha: 0.8),
                        fontSize: 14,
                        letterSpacing: 1,
                      ),
                    ),

                    const SizedBox(height: 30),

                    // Estado e Información
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: _serverOnline
                              ? (_hasInternet
                                    ? Colors.green.withValues(alpha: 0.3)
                                    : Colors.orange.withValues(alpha: 0.3))
                              : Colors.red.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Column(
                        children: [
                          if (_isChecking || _isWaiting)
                            Column(
                              children: [
                                const CircularProgressIndicator(
                                  color: Colors.cyanAccent,
                                  strokeWidth: 2,
                                ),
                                if (_isWaiting) ...[
                                  const SizedBox(height: 15),
                                  Text(
                                    '$_secondsLeft',
                                    style: const TextStyle(
                                      color: Colors.cyanAccent,
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const Text(
                                    'segundos para reintento',
                                    style: TextStyle(
                                      color: Colors.white54,
                                      fontSize: 10,
                                    ),
                                  ),
                                ],
                              ],
                            )
                          else ...[
                            Icon(
                              _serverOnline
                                  ? (_hasInternet
                                        ? Icons.cloud_done
                                        : Icons.cloud_off)
                                  : Icons.power_off,
                              color: _serverOnline
                                  ? (_hasInternet
                                        ? Colors.green
                                        : Colors.orange)
                                  : Colors.redAccent,
                              size: 32,
                            ),
                          ],
                          const SizedBox(height: 12),
                          Text(
                            _statusMessage,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          if (_isWaiting)
                            const Padding(
                              padding: EdgeInsets.only(top: 8.0),
                              child: Text(
                                'Por favor, espere, se está iniciando la app...',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.white54,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 30),

                    // Botón ARRANCAR SISTEMA (Principal)
                    ElevatedButton(
                      onPressed: (_isChecking || _isWaiting || !_serverOnline)
                          ? null
                          : _handleEnter,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _serverOnline
                            ? Colors.cyanAccent.withValues(alpha: 0.9)
                            : Colors.grey.withValues(alpha: 0.3),
                        foregroundColor: _serverOnline
                            ? Colors.black
                            : Colors.white24,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 18,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        elevation: _serverOnline ? 10 : 0,
                        shadowColor: Colors.cyanAccent.withValues(alpha: 0.5),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _serverOnline ? Icons.login : Icons.lock_outline,
                            size: 24,
                          ),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              _serverOnline
                                  ? 'ENTRAR AL SISTEMA'
                                  : 'ACCESO BLOQUEADO (OFFLINE)',
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.visible,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 15),

                    // Botón MODO OFFLINE (Secundario pero claro)
                    if (!_serverOnline)
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(color: Colors.white24),
                        ),
                        child: TextButton.icon(
                          onPressed: () => _navigateToHome(forceOffline: true),
                          icon: const Icon(
                            Icons.cloud_off,
                            color: Colors.white70,
                          ),
                          label: const Flexible(
                            child: Text(
                              'MODO LOCAL / OFFLINE',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white70,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 1,
                              ),
                            ),
                          ),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 15,
                            ),
                          ),
                        ),
                      ),

                    const SizedBox(height: 15),

                    // Enlace GitHub
                    TextButton.icon(
                      onPressed: _launchWebsite,
                      icon: const Icon(Icons.code, size: 18),
                      label: const Text(
                        'Ver en GitHub',
                        style: TextStyle(
                          color: Colors.white54,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
