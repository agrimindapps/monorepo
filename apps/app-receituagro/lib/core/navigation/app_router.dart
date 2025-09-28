import 'package:flutter/material.dart';

import '../../features/defensivos/home_defensivos_page.dart';
import '../../features/defensivos/presentation/pages/defensivos_unificado_page.dart';
import '../../features/DetalheDefensivos/detalhe_defensivo_page.dart';
import '../../features/subscription/presentation/pages/subscription_clean_page.dart';

/// Classe responsável por gerenciar o roteamento da aplicação
/// Implementa padrão Clean Architecture para navegação
class AppRouter {
  /// Gera rotas baseadas nas configurações fornecidas
  static Route<dynamic> generateRoute(RouteSettings settings) {
    final String routeName = settings.name ?? '/';
    final dynamic arguments = settings.arguments;

    switch (routeName) {
      case '/':
        return MaterialPageRoute(
          builder: (_) => const HomeDefensivosPage(),
          settings: settings,
        );

      case '/defensivos':
        return MaterialPageRoute(
          builder: (_) => const HomeDefensivosPage(),
          settings: settings,
        );

      case '/defensivos-unificado':
        final args = arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => DefensivosUnificadoPage(
            tipoAgrupamento: args?['tipoAgrupamento'] as String?,
            textoFiltro: args?['textoFiltro'] as String?,
            modoCompleto: args?['modoCompleto'] as bool? ?? false,
            isAgrupados: args?['isAgrupados'] as bool? ?? false,
          ),
          settings: settings,
        );

      case '/detalhe-defensivo':
        final args = arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => DetalheDefensivoPage(
            defensivoName: args?['defensivoName'] as String? ?? '',
            fabricante: args?['fabricante'] as String? ?? '',
          ),
          settings: settings,
        );

      case '/subscription':
        return MaterialPageRoute(
          builder: (_) => const SubscriptionCleanPage(),
          settings: settings,
        );

      default:
        return MaterialPageRoute(
          builder: (_) => const _RouteNotFoundPage(),
          settings: settings,
        );
    }
  }
}

/// Página exibida quando uma rota não é encontrada
class _RouteNotFoundPage extends StatelessWidget {
  const _RouteNotFoundPage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Página não encontrada'),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              'Página não encontrada',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'A página que você está procurando não existe.',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}