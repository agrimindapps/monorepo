import 'package:flutter/material.dart';

import '../../features/comentarios/comentarios_page.dart';
import '../../features/culturas/lista_culturas_page.dart';
import '../../features/defensivos/home_defensivos_page.dart';
import '../../features/defensivos/presentation/pages/defensivos_unificado_page.dart';
import '../../features/defensivos/presentation/pages/detalhe_defensivo_page.dart';
import '../../features/diagnosticos/presentation/pages/detalhe_diagnostico_page.dart';
import '../../features/favoritos/favoritos_page.dart';
import '../../features/pragas/lista_pragas_page.dart';
import '../../features/pragas/presentation/pages/detalhe_praga_page.dart';
import '../../features/pragas/presentation/pages/home_pragas_page.dart';
import '../../features/settings/settings_page.dart';
import '../../features/subscription/presentation/pages/subscription_page.dart';
import 'widgets/navigation_shell.dart';

/// Classe responsável por gerenciar o roteamento da aplicação
/// Implementa padrão Clean Architecture para navegação
abstract final class AppRouter {
  /// Private constructor para prevenir instanciação
  const AppRouter._();

  /// Helper para criar rotas com metadata (showBottomNav, tabIndex)
  /// ⚠️ IMPORTANTE: Envolve páginas com NavigationShell para bottom nav persistente
  static Route<T> _buildRoute<T>({
    required Widget page,
    required RouteSettings settings,
    bool showBottomNav = true,
    int? tabIndex,
  }) {
    // Combina argumentos existentes com metadata
    final Map<String, dynamic> combinedArgs = {
      if (settings.arguments is Map<String, dynamic>)
        ...(settings.arguments as Map<String, dynamic>),
      'showBottomNav': showBottomNav,
      if (tabIndex != null) 'tabIndex': tabIndex,
    };

    return MaterialPageRoute<T>(
      // ✅ Envolve com NavigationShell para bottom nav persistente
      builder: (_) => NavigationShell(child: page),
      settings: RouteSettings(
        name: settings.name,
        arguments: combinedArgs,
      ),
    );
  }

  /// Gera rotas baseadas nas configurações fornecidas
  static Route<dynamic> generateRoute(RouteSettings settings) {
    final String routeName = settings.name ?? '/';
    final dynamic arguments = settings.arguments;

    switch (routeName) {
      // ========== PÁGINAS PRINCIPAIS (BottomNav) ==========
      case '/':
      case '/home-defensivos':
        return _buildRoute(
          page: const HomeDefensivosPage(),
          settings: settings,
          showBottomNav: true,
          tabIndex: 0,
        );

      case '/home-pragas':
        return _buildRoute(
          page: const HomePragasPage(),
          settings: settings,
          showBottomNav: true,
          tabIndex: 1,
        );

      case '/favoritos':
        return _buildRoute(
          page: const FavoritosPage(),
          settings: settings,
          showBottomNav: true,
          tabIndex: 2,
        );

      case '/comentarios':
        return _buildRoute(
          page: const ComentariosPage(),
          settings: settings,
          showBottomNav: true,
          tabIndex: 3,
        );

      case '/settings':
        return _buildRoute(
          page: const SettingsPage(),
          settings: settings,
          showBottomNav: true,
          tabIndex: 4,
        );

      // ========== PÁGINAS DE LISTAGEM ==========

      case '/defensivos':
        final defArgs = arguments as Map<String, dynamic>?;
        return _buildRoute(
          page: DefensivosUnificadoPage(
            tipoAgrupamento: defArgs?['categoria'] as String?,
            textoFiltro: defArgs?['textoFiltro'] as String?,
            modoCompleto: true,
            isAgrupados: false,
          ),
          settings: settings,
          showBottomNav: true,
          tabIndex: 0,
        );

      case '/defensivos-unificado':
        final uniArgs = arguments as Map<String, dynamic>?;
        return _buildRoute(
          page: DefensivosUnificadoPage(
            tipoAgrupamento: uniArgs?['tipoAgrupamento'] as String?,
            textoFiltro: uniArgs?['textoFiltro'] as String?,
            modoCompleto: uniArgs?['modoCompleto'] as bool? ?? false,
            isAgrupados: uniArgs?['isAgrupados'] as bool? ?? false,
          ),
          settings: settings,
          showBottomNav: true,
          tabIndex: 0,
        );

      case '/defensivos-agrupados':
        final agrArgs = arguments as Map<String, dynamic>?;
        return _buildRoute(
          page: DefensivosUnificadoPage(
            tipoAgrupamento: agrArgs?['tipoAgrupamento'] as String?,
            textoFiltro: agrArgs?['textoFiltro'] as String?,
            modoCompleto: agrArgs?['modoCompleto'] as bool? ?? false,
            isAgrupados: true,
          ),
          settings: settings,
          showBottomNav: true,
          tabIndex: 0,
        );

      case '/pragas':
        final pragasArgs = arguments as Map<String, dynamic>?;
        return _buildRoute(
          page: ListaPragasPage(
            pragaType: pragasArgs?['categoria'] as String?,
          ),
          settings: settings,
          showBottomNav: true,
          tabIndex: 1,
        );

      case '/culturas':
        return _buildRoute(
          page: const ListaCulturasPage(),
          settings: settings,
          showBottomNav: true,
          tabIndex: 1,
        );

      // ========== PÁGINAS DE DETALHES (sem bottom nav) ==========

      case '/detalhe-defensivo':
        final detDefArgs = arguments as Map<String, dynamic>?;
        return _buildRoute(
          page: DetalheDefensivoPage(
            defensivoName: detDefArgs?['defensivoName'] as String? ?? '',
            fabricante: detDefArgs?['fabricante'] as String? ?? '',
          ),
          settings: settings,
          showBottomNav: false,
          tabIndex: 0, // Mantém referência à tab de Defensivos
        );

      case '/detalhe-diagnostico':
        final detDiagArgs = arguments as Map<String, dynamic>?;
        return _buildRoute(
          page: DetalheDiagnosticoPage(
            diagnosticoId: detDiagArgs?['diagnosticoId'] as String? ?? '',
            nomeDefensivo: detDiagArgs?['nomeDefensivo'] as String? ?? '',
            nomePraga: detDiagArgs?['nomePraga'] as String? ?? '',
            cultura: detDiagArgs?['cultura'] as String? ?? '',
          ),
          settings: settings,
          showBottomNav: false,
          tabIndex: detDiagArgs?['tabIndex'] as int? ?? 0, // Preserva tab de origem
        );

      case '/praga-detail':
        final pragaDetArgs = arguments as Map<String, dynamic>?;
        return _buildRoute(
          page: DetalhePragaPage(
            pragaName: pragaDetArgs?['pragaName'] as String? ?? '',
            pragaId: pragaDetArgs?['pragaId'] as String?,
            pragaScientificName:
                pragaDetArgs?['pragaScientificName'] as String? ?? '',
          ),
          settings: settings,
          showBottomNav: false,
          tabIndex: 1, // Mantém referência à tab de Pragas
        );

      // ========== OUTRAS PÁGINAS ==========

      case '/subscription':
        return _buildRoute(
          page: const SubscriptionPage(),
          settings: settings,
          showBottomNav: true,
          tabIndex: 4, // Config tab
        );

      default:
        // Rota não encontrada: redireciona para a página inicial
        debugPrint('⚠️ Rota não encontrada: $routeName - Redirecionando para home');
        return _buildRoute(
          page: const _RouteNotFoundRedirect(),
          settings: settings,
          showBottomNav: true,
        );
    }
  }
}

/// Widget que redireciona automaticamente para a página inicial
/// quando uma rota não existe
class _RouteNotFoundRedirect extends StatefulWidget {
  const _RouteNotFoundRedirect();

  @override
  State<_RouteNotFoundRedirect> createState() => _RouteNotFoundRedirectState();
}

class _RouteNotFoundRedirectState extends State<_RouteNotFoundRedirect> {
  @override
  void initState() {
    super.initState();
    // Redireciona para home após o build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Mostra um loading enquanto redireciona
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text(
              'Redirecionando...',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
