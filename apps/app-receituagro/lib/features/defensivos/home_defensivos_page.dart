import 'package:core/core.dart' hide Column;
import 'package:flutter/material.dart';

import '../../core/services/receituagro_navigation_service.dart';
import '../../core/theme/design_tokens.dart';
import '../../database/receituagro_database.dart';
import 'presentation/providers/home_defensivos_notifier.dart';
import 'presentation/widgets/defensivos_error_state.dart';
import 'presentation/widgets/defensivos_new_items_section.dart';
import 'presentation/widgets/defensivos_recent_section.dart';
import 'presentation/widgets/defensivos_stats_grid.dart';
import 'presentation/widgets/home_defensivos_header.dart';

/// Página Home de Defensivos - Clean Architecture Orchestrator
///
/// Refactored for Riverpod migration:
/// - Migrated from Provider to Riverpod with ConsumerWidget
/// - Header, Stats Grid, Recent/New sections extracted as specialized widgets
/// - Performance optimizations with RepaintBoundary on heavy components
/// - Single Responsibility Principle applied throughout
/// - Zero breaking changes paradigm maintained
///
/// Performance optimizations:
/// - Modular components with strategic RepaintBoundary placement
/// - Riverpod pattern with efficient state management
/// - Lazy loading and conditional rebuilds
class HomeDefensivosPage extends ConsumerStatefulWidget {
  const HomeDefensivosPage({super.key});

  @override
  ConsumerState<HomeDefensivosPage> createState() => _HomeDefensivosPageState();
}

class _HomeDefensivosPageState extends ConsumerState<HomeDefensivosPage> {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final theme = Theme.of(context);
    final state = ref.watch(homeDefensivosNotifierProvider);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
          child: Column(
            children: [
              HomeDefensivosHeader(isDark: isDark),
              Expanded(
                child: state.when(
                  data: (data) {
                    if (data.errorMessage != null) {
                      return DefensivosErrorState(
                        onRetry: () {
                          ref
                              .read(homeDefensivosNotifierProvider.notifier)
                              .clearError();
                          ref
                              .read(homeDefensivosNotifierProvider.notifier)
                              .loadData();
                        },
                      );
                    }

                    return RefreshIndicator(
                      onRefresh: () => ref
                          .read(homeDefensivosNotifierProvider.notifier)
                          .refreshData(),
                      child: CustomScrollView(
                        slivers: [
                          SliverToBoxAdapter(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: ReceitaAgroSpacing.xs),
                                DefensivosStatsGrid(
                                  onCategoryTap: (category) =>
                                      _navigateToCategory(context, category),
                                ),
                                const SizedBox(height: ReceitaAgroSpacing.xs),
                                DefensivosRecentSection(
                                  onDefensivoTap: _navigateToDefensivoDetails,
                                ),
                                const SizedBox(height: ReceitaAgroSpacing.xs),
                                DefensivosNewItemsSection(
                                  onDefensivoTap: _navigateToDefensivoDetails,
                                ),
                                const SizedBox(
                                  height: ReceitaAgroSpacing.bottomSafeArea,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (error, _) => DefensivosErrorState(
                    onRetry: () {
                      ref
                          .read(homeDefensivosNotifierProvider.notifier)
                          .clearError();
                      ref
                          .read(homeDefensivosNotifierProvider.notifier)
                          .loadData();
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToDefensivoDetails(
    String defensivoName,
    String fabricante,
    Fitossanitario defensivo,
  ) {
    ref
        .read(homeDefensivosNotifierProvider.notifier)
        .recordDefensivoAccess(defensivo);

    final navigationService = GetIt.instance<ReceitaAgroNavigationService>();
    navigationService.navigateToDetalheDefensivo(
      defensivoName: defensivoName,
      extraData: {'fabricante': fabricante},
    );
  }

  void _navigateToCategory(BuildContext context, String category) {
    final navigationService = GetIt.instance<ReceitaAgroNavigationService>();

    switch (category.toLowerCase()) {
      case 'defensivos':
        navigationService.navigateToListaDefensivos();
        break;
      case 'fabricantes':
        navigationService.navigateToDefensivosAgrupados(
          extraData: {'tipoAgrupamento': 'fabricantes'},
        );
        break;
      case 'modoacao':
        navigationService.navigateToDefensivosAgrupados(
          extraData: {'tipoAgrupamento': 'modoAcao'},
        );
        break;
      case 'ingredienteativo':
        navigationService.navigateToDefensivosAgrupados(
          extraData: {'tipoAgrupamento': 'ingredienteAtivo'},
        );
        break;
      case 'classeagronomica':
        navigationService.navigateToDefensivosAgrupados(
          extraData: {'tipoAgrupamento': 'classeAgronomica'},
        );
        break;
      default:
        navigationService.navigateToListaDefensivos();
    }
  }
}
