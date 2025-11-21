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
}
