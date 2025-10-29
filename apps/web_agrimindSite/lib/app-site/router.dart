import 'package:flutter/material.dart';

import 'pages/detalhes_defensivos_page.dart';
import 'pages/download_page.dart';
import 'pages/home_defensivos_page.dart';

class Routes {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return MaterialPageRoute(builder: (_) => DefensivosListarPage());
      case '/home':
        return MaterialPageRoute(builder: (_) => DefensivosListarPage());
      case '/defensivo':
        final args = settings.arguments as Map<String, dynamic>?;
        if (args == null || !args.containsKey('id')) {
          throw Exception('Argumentos inválidos para a rota /defensivo');
        }
        return MaterialPageRoute(
          builder: (_) => DefensivosDetalhesPage(id: args['id']),
        );

      // Quando em processo de atualizacao
      case '/desenvolvimento':
        return MaterialPageRoute(builder: (_) => const DesenvolvimentoPage());
      default:
        throw Exception('Rota desconhecida: ${settings.name}');
    }
  }
}
