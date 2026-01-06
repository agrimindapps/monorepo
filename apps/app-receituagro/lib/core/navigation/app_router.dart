import 'package:core/core.dart' hide SubscriptionPage, analyticsServiceProvider;
import 'package:flutter/foundation.dart';
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
import 'widgets/scaffold_with_navbar.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  // 📊 Analytics Route Observer para tracking automático de telas
  final analyticsObserver = ref.read(
    analyticsRouteObserverFamilyProvider('receituagro_'),
  );

  return GoRouter(
    initialLocation: '/home-defensivos',
    debugLogDiagnostics: kDebugMode,
    observers: [analyticsObserver],
    routes: [
      GoRoute(
        path: '/',
        redirect: (context, state) => '/home-defensivos',
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return ScaffoldWithNavBar(navigationShell: navigationShell);
        },
        branches: [
          // ========== TAB 0: DEFENSIVOS ==========
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home-defensivos',
                name: '/home-defensivos',
                pageBuilder: (context, state) => const NoTransitionPage(
                  child: HomeDefensivosPage(),
                ),
                routes: [
                  GoRoute(
                    path: 'defensivos',
                    name: '/defensivos',
                    builder: (context, state) {
                      final args = state.extra as Map<String, dynamic>?;
                      return DefensivosUnificadoPage(
                        tipoAgrupamento: args?['categoria'] as String?,
                        textoFiltro: args?['textoFiltro'] as String?,
                        modoCompleto: true,
                        isAgrupados: false,
                      );
                    },
                  ),
                  GoRoute(
                    path: 'defensivos-unificado',
                    name: '/defensivos-unificado',
                    builder: (context, state) {
                      final args = state.extra as Map<String, dynamic>?;
                      return DefensivosUnificadoPage(
                        tipoAgrupamento: args?['tipoAgrupamento'] as String?,
                        textoFiltro: args?['textoFiltro'] as String?,
                        modoCompleto: args?['modoCompleto'] as bool? ?? false,
                        isAgrupados: args?['isAgrupados'] as bool? ?? false,
                      );
                    },
                  ),
                  GoRoute(
                    path: 'defensivos-agrupados',
                    name: '/defensivos-agrupados',
                    builder: (context, state) {
                      final args = state.extra as Map<String, dynamic>?;
                      return DefensivosUnificadoPage(
                        tipoAgrupamento: args?['tipoAgrupamento'] as String?,
                        textoFiltro: args?['textoFiltro'] as String?,
                        modoCompleto: args?['modoCompleto'] as bool? ?? false,
                        isAgrupados: true,
                      );
                    },
                  ),
                  GoRoute(
                    path: 'detalhe-defensivo',
                    name: '/detalhe-defensivo',
                    builder: (context, state) {
                      final args = state.extra as Map<String, dynamic>?;
                      final defensivoName =
                          args?['defensivoName'] as String? ?? '';
                      final fabricante = args?['fabricante'] as String? ?? '';
                      return DetalheDefensivoPage(
                        key: ValueKey(
                            'detalhe-defensivo-$defensivoName-$fabricante'),
                        defensivoName: defensivoName,
                        fabricante: fabricante,
                      );
                    },
                  ),
                  GoRoute(
                    path: 'detalhe-diagnostico',
                    name: '/detalhe-diagnostico',
                    builder: (context, state) {
                      final args = state.extra as Map<String, dynamic>?;
                      return DetalheDiagnosticoPage(
                        diagnosticoId: args?['diagnosticoId'] as String? ?? '',
                        nomeDefensivo: args?['nomeDefensivo'] as String? ?? '',
                        nomePraga: args?['nomePraga'] as String? ?? '',
                        cultura: args?['cultura'] as String? ?? '',
                      );
                    },
                  ),
                ],
              ),
            ],
          ),

          // ========== TAB 1: PRAGAS ==========
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home-pragas',
                name: '/home-pragas',
                pageBuilder: (context, state) => const NoTransitionPage(
                  child: HomePragasPage(),
                ),
                routes: [
                  GoRoute(
                    path: 'pragas',
                    name: '/pragas',
                    builder: (context, state) {
                      final args = state.extra as Map<String, dynamic>?;
                      return ListaPragasPage(
                        pragaType: args?['categoria'] as String?,
                      );
                    },
                  ),
                  GoRoute(
                    path: 'culturas',
                    name: '/culturas',
                    builder: (context, state) => const ListaCulturasPage(),
                  ),
                  GoRoute(
                    path: 'praga-detail',
                    name: '/praga-detail',
                    builder: (context, state) {
                      final args = state.extra as Map<String, dynamic>?;
                      return DetalhePragaPage(
                        pragaName: args?['pragaName'] as String? ?? '',
                        pragaId: args?['pragaId'] as String?,
                        pragaScientificName:
                            args?['pragaScientificName'] as String? ?? '',
                      );
                    },
                  ),
                ],
              ),
            ],
          ),

          // ========== TAB 2: FAVORITOS ==========
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/favoritos',
                name: '/favoritos',
                pageBuilder: (context, state) => const NoTransitionPage(
                  child: FavoritosPage(),
                ),
              ),
            ],
          ),

          // ========== TAB 3: COMENTÁRIOS ==========
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/comentarios',
                name: '/comentarios',
                pageBuilder: (context, state) => const NoTransitionPage(
                  child: ComentariosPage(),
                ),
              ),
            ],
          ),

          // ========== TAB 4: CONFIGURAÇÕES ==========
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/settings',
                name: '/settings',
                pageBuilder: (context, state) => const NoTransitionPage(
                  child: SettingsPage(),
                ),
                routes: [
                  GoRoute(
                    path: 'subscription',
                    name: '/subscription',
                    builder: (context, state) => const SubscriptionPage(),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('Erro: ${state.error}'),
      ),
    ),
  );
});
