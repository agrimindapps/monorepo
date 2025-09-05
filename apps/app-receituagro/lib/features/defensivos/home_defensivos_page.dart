import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/design/design_tokens.dart';
import '../../core/di/injection_container.dart';
import '../../core/models/fitossanitario_hive.dart';
import '../../core/navigation/app_navigation_provider.dart';
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
      create: (_) => HomeDefensivosProvider(
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
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              // Header section with provider-based subtitle
              Consumer<HomeDefensivosProvider>(
                builder: (context, provider, _) => HomeDefensivosHeader(
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
                                  onCategoryTap: (category) => _navigateToCategory(context, category),
                                ),
                                const SizedBox(height: 24),
                                // Recent access section
                                DefensivosRecentSection(
                                  provider: provider,
                                  onDefensivoTap: _navigateToDefensivoDetails,
                                ),
                                const SizedBox(height: 32),
                                // New items section
                                DefensivosNewItemsSection(
                                  provider: provider,
                                  onDefensivoTap: _navigateToDefensivoDetails,
                                ),
                                const SizedBox(height: ReceitaAgroSpacing.bottomSafeArea),
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


  void _navigateToDefensivoDetails(String defensivoName, String fabricante, FitossanitarioHive defensivo) {
    // Register access for analytics (in background)
    final provider = context.read<HomeDefensivosProvider>();
    provider.recordDefensivoAccess(defensivo);
    
    context.read<AppNavigationProvider>().navigateToDetalheDefensivo(
      defensivoName: defensivoName,
      fabricante: fabricante,
    );
  }

  void _navigateToCategory(BuildContext context, String category) {
    // Navigate based on category type
    final navigationProvider = context.read<AppNavigationProvider>();
    
    switch (category.toLowerCase()) {
      case 'defensivos':
        navigationProvider.navigateToListaDefensivos();
        break;
      case 'fabricantes':
        navigationProvider.navigateToListaDefensivos();
        break;
      case 'modoacao':
        navigationProvider.navigateToListaDefensivos();
        break;
      case 'ingredienteativo':
        navigationProvider.navigateToListaDefensivos();
        break;
      case 'classeagronomica':
        navigationProvider.navigateToListaDefensivos();
        break;
      default:
        navigationProvider.navigateToListaDefensivos();
    }
  }
}