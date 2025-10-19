import 'package:flutter/material.dart';

import '../core/pages/atualizacao.dart';
import '../core/pages/in_app_purchase_page.dart';
import '../core/pages/sobre.dart';
import '../core/pages/tts_settings_page.dart';
import 'pages/config_page.dart';
import 'pages/comentarios_page.dart';
import 'pages/home_page.dart';
import 'pages/termos_page.dart';

class Routes {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return MaterialPageRoute(builder: (context) => const HomePage());
      case '/categorias':
        return MaterialPageRoute(builder: (context) => const HomePage());
      case '/termos':
        return MaterialPageRoute(
            builder: (context) => const TermosPage(favoritePage: false));
      case '/favoritos':
        return MaterialPageRoute(
            builder: (context) => const TermosPage(favoritePage: true));
      case '/comentarios':
        return MaterialPageRoute(builder: (context) => const ComentariosPage());

      case '/config':
        return MaterialPageRoute(builder: (context) => const ConfigPage());
      case '/config/tts':
        return MaterialPageRoute(builder: (context) => const TTsSettingsPage());
      case '/sobre':
        return MaterialPageRoute(builder: (context) => const SobrePage());
      case '/atualizacao':
        return MaterialPageRoute(builder: (context) => const AtualizacaoPage());
      case '/premium':
        return MaterialPageRoute(
            builder: (context) => const SubscriptionScreen());
      default:
        throw Exception('Rota desconhecida: ${settings.name}');
    }
  }
}
