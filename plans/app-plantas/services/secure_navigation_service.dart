import 'package:flutter/material.dart';

import '../core/navigation/i_navigation_service.dart';

class SecureNavigationService implements INavigationService {
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  @override
  void navigateTo(String routeName, {dynamic arguments}) {
    _validateRoute(routeName);
    navigatorKey.currentState?.pushNamed(routeName, arguments: arguments);
  }

  @override
  void goBack({dynamic result}) {
    navigatorKey.currentState?.pop(result);
  }

  @override
  void replaceWith(String routeName, {dynamic arguments}) {
    _validateRoute(routeName);
    navigatorKey.currentState?.pushReplacementNamed(routeName, arguments: arguments);
  }

  @override
  void offAllTo(String routeName, {dynamic arguments}) {
    _validateRoute(routeName);
    navigatorKey.currentState?.pushNamedAndRemoveUntil(
      routeName, 
      (route) => false,
      arguments: arguments,
    );
  }

  @override
  bool canGoBack() {
    return navigatorKey.currentState?.canPop() ?? false;
  }

  /// Validar rota com segurança
  void _validateRoute(String routeName) {
    // Lógica de validação de rota
    if (routeName.isEmpty) {
      throw ArgumentError('Nome da rota não pode ser vazio');
    }

    // Exemplos de validações adicionais
    if (routeName.contains('..')) {
      throw const SecurityException('Rota inválida: caminho relativo não permitido');
    }
  }

  /// Criar animação de transição personalizada
  PageRouteBuilder createCustomRoute({
    required Widget page,
    RouteSettings? settings,
    Duration transitionDuration = const Duration(milliseconds: 300),
  }) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: transitionDuration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
            CurvedAnimation(parent: animation, curve: Curves.easeInOut),
          ),
          child: child,
        );
      },
      settings: settings,
    );
  }

  /// Método para obter contexto atual de navegação
  BuildContext? get currentContext => navigatorKey.currentContext;
}

/// Exceção de segurança para navegação
class SecurityException implements Exception {
  final String message;
  const SecurityException(this.message);

  @override
  String toString() => 'SecurityException: $message';
}