import 'package:flutter/material.dart';
import 'package:provider/provider.dart' as provider;

import '../../features/DetalheDefensivos/detalhe_defensivo_page.dart';
import '../../features/culturas/lista_culturas_page.dart';
import '../../features/defensivos/home_defensivos_page.dart';
import '../../features/defensivos/presentation/pages/defensivos_unificado_page.dart';
import '../../features/defensivos/presentation/providers/defensivos_unificado_provider.dart';
import '../../features/pragas/detalhe_praga_page.dart';
import '../../features/pragas/lista_pragas_page.dart';
import '../../features/subscription/presentation/pages/subscription_clean_page.dart';
import '../di/injection_container.dart';

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
        final args = arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => provider.ChangeNotifierProvider<DefensivosUnificadoProvider>(
            create: (_) => sl<DefensivosUnificadoProvider>(),
            child: DefensivosUnificadoPage(
              tipoAgrupamento: args?['categoria'] as String?,
              textoFiltro: args?['textoFiltro'] as String?,
              modoCompleto: true, // Lista completa de defensivos
              isAgrupados: false, // Lista simples, não agrupada
            ),
          ),
          settings: settings,
        );

      case '/defensivos-unificado':
        final args = arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => provider.ChangeNotifierProvider<DefensivosUnificadoProvider>(
            create: (_) => sl<DefensivosUnificadoProvider>(),
            child: DefensivosUnificadoPage(
              tipoAgrupamento: args?['tipoAgrupamento'] as String?,
              textoFiltro: args?['textoFiltro'] as String?,
              modoCompleto: args?['modoCompleto'] as bool? ?? false,
              isAgrupados: args?['isAgrupados'] as bool? ?? false,
            ),
          ),
          settings: settings,
        );

      case '/defensivos-agrupados':
        final args = arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => provider.ChangeNotifierProvider<DefensivosUnificadoProvider>(
            create: (_) => sl<DefensivosUnificadoProvider>(),
            child: DefensivosUnificadoPage(
              tipoAgrupamento: args?['tipoAgrupamento'] as String?,
              textoFiltro: args?['textoFiltro'] as String?,
              modoCompleto: args?['modoCompleto'] as bool? ?? false,
              isAgrupados: true, // Força modo agrupado
            ),
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

      case '/pragas':
        final args = arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => ListaPragasPage(
            pragaType: args?['categoria'] as String?,
          ),
          settings: settings,
        );

      case '/culturas':
        return MaterialPageRoute(
          builder: (_) => const ListaCulturasPage(),
          settings: settings,
        );

      case '/praga-detail':
        final args = arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => DetalhePragaPage(
            pragaName: args?['pragaName'] as String? ?? '',
            pragaId: args?['pragaId'] as String?,
            pragaScientificName: args?['pragaScientificName'] as String? ?? '',
          ),
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