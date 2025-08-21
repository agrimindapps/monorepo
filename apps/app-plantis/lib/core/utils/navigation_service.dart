import 'package:flutter/material.dart';

class NavigationService {
  static final NavigationService _instance = NavigationService._internal();
  factory NavigationService() => _instance;
  NavigationService._internal();

  static NavigationService get instance => _instance;

  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  // Controle para evitar múltiplas mensagens de acesso negado
  DateTime? _lastAccessDeniedMessage;

  BuildContext? get currentContext => navigatorKey.currentContext;

  void showAccessDeniedMessage() {
    final context = currentContext;
    final now = DateTime.now();

    // Evita mostrar a mensagem se já foi mostrada nos últimos 5 segundos
    if (_lastAccessDeniedMessage != null &&
        now.difference(_lastAccessDeniedMessage!).inSeconds < 5) {
      return;
    }

    _lastAccessDeniedMessage = now;

    if (context != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.lock_outlined, color: Colors.white, size: 20),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Acesso restrito! Faça login para continuar.',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          backgroundColor: Colors.red.shade600,
          duration: const Duration(seconds: 4),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          margin: const EdgeInsets.all(16),
          action: SnackBarAction(
            label: 'Entrar',
            textColor: Colors.white,
            onPressed: () {
              // O usuário já será redirecionado para login
            },
          ),
        ),
      );
    }
  }

  void showMessage({
    required String message,
    Color? backgroundColor,
    IconData? icon,
    Duration duration = const Duration(seconds: 3),
  }) {
    final context = currentContext;
    if (context != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              if (icon != null) ...[
                Icon(icon, color: Colors.white, size: 20),
                const SizedBox(width: 12),
              ],
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                ),
              ),
            ],
          ),
          backgroundColor: backgroundColor ?? Colors.green.shade600,
          duration: duration,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          margin: const EdgeInsets.all(16),
        ),
      );
    }
  }
}
