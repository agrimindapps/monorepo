import 'package:flutter/material.dart';

/// Extension para extrair metadados de navegação do RouteSettings
extension RouteSettingsExtension on RouteSettings {
  /// Indica se o BottomNavigationBar deve ser exibido nesta rota
  bool get showBottomNav {
    if (arguments is Map<String, dynamic>) {
      final value = (arguments as Map<String, dynamic>)['showBottomNav'];
      return value is bool ? value : true;
    }
    return true;
  }

  /// Retorna o índice da tab correspondente a esta rota
  /// Retorna null se a rota não corresponde a nenhuma tab principal
  int? get tabIndex {
    // Primeiro verifica se foi passado explicitamente
    if (arguments is Map<String, dynamic>) {
      final value = (arguments as Map<String, dynamic>)['tabIndex'];
      if (value is int) return value;
    }

    // Infere do nome da rota
    final routeName = name ?? '';
    return _inferTabIndexFromRoute(routeName);
  }

  /// Infere o índice da tab baseado no nome da rota
  static int? _inferTabIndexFromRoute(String routeName) {
    // Tabs principais
    const routeToIndex = <String, int>{
      '/': 0,
      '/home-defensivos': 0,
      '/defensivos': 0,
      '/defensivos-unificado': 0,
      '/defensivos-agrupados': 0,
      '/detalhe-defensivo': 0,
      '/home-pragas': 1,
      '/pragas': 1,
      '/praga-detail': 1,
      '/culturas': 1,
      '/favoritos': 2,
      '/comentarios': 3,
      '/settings': 4,
    };

    return routeToIndex[routeName];
  }
}
