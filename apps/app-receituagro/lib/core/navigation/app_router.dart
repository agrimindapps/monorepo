import 'package:flutter/material.dart';

import '../../features/DetalheDefensivos/detalhe_defensivo_page.dart';
import '../../features/pragas/detalhe_praga_page.dart';
import '../../features/navigation/main_navigation_page.dart';

/// App router for handling named routes
class AppRouter {
  /// Generate routes for the app
  static Route<dynamic>? generateRoute(RouteSettings settings) {
    final String routeName = settings.name ?? '';
    final Map<String, dynamic>? arguments = settings.arguments as Map<String, dynamic>?;

    switch (routeName) {
      case '/':
        return MaterialPageRoute(
          builder: (_) => const MainNavigationPage(),
          settings: settings,
        );

      case '/defensivo-detail':
        if (arguments != null) {
          final String? defensivoName = arguments['defensivoName'] as String?;
          final String? fabricante = arguments['fabricante'] as String?;
          
          if (defensivoName != null) {
            return MaterialPageRoute(
              builder: (_) => DetalheDefensivoPage(
                defensivoName: defensivoName,
                fabricante: fabricante ?? 'N/A',
              ),
              settings: settings,
            );
          }
        }
        // If missing arguments, show error page or navigate to home
        return _errorRoute(settings);

      case '/praga-detail':
        if (arguments != null) {
          final String? pragaName = arguments['pragaName'] as String?;
          final String? pragaId = arguments['pragaId'] as String?;
          final String? pragaScientificName = arguments['pragaScientificName'] as String?;
          
          if (pragaName != null || pragaId != null) {
            return MaterialPageRoute(
              builder: (_) => DetalhePragaPage(
                pragaName: pragaName ?? '',
                pragaId: pragaId,
                pragaScientificName: pragaScientificName ?? '',
              ),
              settings: settings,
            );
          }
        }
        // If missing arguments, show error page or navigate to home
        return _errorRoute(settings);

      default:
        return _errorRoute(settings);
    }
  }

  /// Error route when route is not found
  static Route<dynamic> _errorRoute(RouteSettings settings) {
    return MaterialPageRoute(
      builder: (context) => Scaffold(
        appBar: AppBar(
          title: const Text('Erro'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red,
              ),
              const SizedBox(height: 16),
              Text(
                'Página não encontrada',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                'Rota: ${settings.name}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pushNamedAndRemoveUntil(
                    '/',
                    (route) => false,
                  );
                },
                child: const Text('Voltar ao início'),
              ),
            ],
          ),
        ),
      ),
      settings: settings,
    );
  }
}