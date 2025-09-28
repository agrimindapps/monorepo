import 'package:flutter/material.dart';
import 'package:core/core.dart';

import '../../core/design/design_tokens.dart';
import '../../core/di/injection_container.dart';
import '../../core/models/fitossanitario_hive.dart';
import '../../core/services/receituagro_navigation_service.dart';

import '../../core/repositories/fitossanitario_hive_repository.dart';
import 'presentation/providers/home_defensivos_provider.dart';
import 'presentation/widgets/defensivos_error_state.dart';
import 'presentation/widgets/defensivos_new_items_section.dart';
import 'presentation/widgets/defensivos_recent_section.dart';
import 'presentation/widgets/defensivos_stats_grid.dart';
import 'presentation/widgets/home_defensivos_header.dart';

/// Página Home de Defensivos - Clean Architecture Orchestrator
///
/// Refactored for Phase 2.4 with component extraction:
/// - Header, Stats Grid, Recent/New sections extracted as specialized widgets
/// - Performance optimizations with RepaintBoundary on heavy components
/// - Single Responsibility Principle applied throughout
/// - Zero breaking changes paradigm maintained
///
/// Performance optimizations:
/// - Modular components with strategic RepaintBoundary placement
/// - Provider pattern with efficient state management
/// - Lazy loading and conditional rebuilds
class HomeDefensivosPage extends StatelessWidget {
  const HomeDefensivosPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<HomeDefensivosProvider>(
      create:
          (_) => HomeDefensivosProvider(
            repository: sl<FitossanitarioHiveRepository>(),
          )..loadData(),
      child: const _HomeDefensivosView(),
    );
  }
}

class _HomeDefensivosView extends StatefulWidget {
  const _HomeDefensivosView();

  @override
  State<_HomeDefensivosView> createState() => _HomeDefensivosViewState();
}

class _HomeDefensivosViewState extends State<_HomeDefensivosView> {
  @override
  void initState() {
    super.initState();
    // No manual data loading needed - Provider handles initialization
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
          child: Column(
            children: [
              // Header section with provider-based subtitle
              Consumer<HomeDefensivosProvider>(
                builder:
                    (context, provider, _) => HomeDefensivosHeader(
                      provider: provider,
                      isDark: isDark,
                    ),
              ),
              // Main content area
              Expanded(
                child: Consumer<HomeDefensivosProvider>(
                  builder: (context, provider, _) {
                    // Handle error state
                    if (provider.errorMessage != null) {
                      return DefensivosErrorState(
                        provider: provider,
                        onRetry: () {
                          provider.clearError();
                          provider.loadData();
                        },
                      );
                    }

                    return RefreshIndicator(
                      onRefresh: () => provider.refreshData(),
                      child: CustomScrollView(
                        slivers: [
                          SliverToBoxAdapter(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: ReceitaAgroSpacing.sm),
                                // Statistics grid with category navigation
                                DefensivosStatsGrid(
                                  provider: provider,
                                  onCategoryTap:
                                      (category) => _navigateToCategory(
                                        context,
                                        category,
                                      ),
                                ),
                                const SizedBox(height: ReceitaAgroSpacing.sm),
                                // Recent access section
                                DefensivosRecentSection(
                                  provider: provider,
                                  onDefensivoTap: _navigateToDefensivoDetails,
                                ),
                                const SizedBox(height: ReceitaAgroSpacing.sm),
                                // New items section
                                DefensivosNewItemsSection(
                                  provider: provider,
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
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Navigation methods - maintained for orchestration

  void _navigateToDefensivoDetails(
    String defensivoName,
    String fabricante,
    FitossanitarioHive defensivo,
  ) {
    // Register access for analytics (in background)
    final provider = context.read<HomeDefensivosProvider>();
    provider.recordDefensivoAccess(defensivo);

    final navigationService = GetIt.instance<ReceitaAgroNavigationService>();
    navigationService.navigateToDetalheDefensivo(
      defensivoName: defensivoName,
      extraData: {'fabricante': fabricante},
    );
  }

  void _navigateToCategory(BuildContext context, String category) {
    // Navigate based on category type
    final navigationService = GetIt.instance<ReceitaAgroNavigationService>();

    switch (category.toLowerCase()) {
      case 'defensivos':
        // Para defensivos, mantém navegação original (lista simples)
        navigationService.navigateToListaDefensivos();
        break;
      case 'fabricantes':
        // Para fabricantes, vai para lista agrupada por fabricante
        navigationService.navigateToDefensivosAgrupados(
          extraData: {'tipoAgrupamento': 'fabricantes'},
        );
        break;
      case 'modoacao':
        // Para modo de ação, vai para lista agrupada por modo de ação
        navigationService.navigateToDefensivosAgrupados(
          extraData: {'tipoAgrupamento': 'modoAcao'},
        );
        break;
      case 'ingredienteativo':
        // Para ingrediente ativo, vai para lista agrupada por ingrediente ativo
        navigationService.navigateToDefensivosAgrupados(
          extraData: {'tipoAgrupamento': 'ingredienteAtivo'},
        );
        break;
      case 'classeagronomica':
        // Para classe agronômica, vai para lista agrupada por classe
        navigationService.navigateToDefensivosAgrupados(
          extraData: {'tipoAgrupamento': 'classeAgronomica'},
        );
        break;
      default:
        navigationService.navigateToListaDefensivos();
    }
  }
}
