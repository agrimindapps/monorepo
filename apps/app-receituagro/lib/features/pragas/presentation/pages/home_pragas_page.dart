import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/design_tokens.dart';
import '../../../../core/widgets/modern_header_widget.dart';
import '../../../../core/widgets/responsive_content_wrapper.dart';
import '../providers/home_pragas_notifier.dart';
import '../widgets/home_pragas_error_widget.dart';
import '../widgets/home_pragas_recent_widget.dart';
import '../widgets/home_pragas_stats_widget.dart';
import '../widgets/home_pragas_suggestions_widget.dart';

/// Página clean da Home de Pragas seguindo Clean Architecture
///
/// Responsabilidades:
/// - Layout principal da página
/// - Coordenação entre widgets especializados
/// - Gerenciamento de estados de loading/erro
/// - Integração com HomePragasNotifier (Riverpod)
class HomePragasPage extends ConsumerWidget {
  const HomePragasPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final asyncState = ref.watch(homePragasNotifierProvider);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
          child: ResponsiveContentWrapper(
            child: asyncState.when(
              data: (state) => Column(
                children: [
                  _buildHeader(context, isDark, state),
                  Expanded(
                    child: _buildBody(context, ref, state),
                  ),
                ],
              ),
              loading: () => _buildLoadingState(context),
              error: (error, stack) => HomePragasErrorWidget(
                errorMessage: error.toString(),
                onRetry: () => ref.refresh(homePragasNotifierProvider),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isDark, HomePragasState state) {
    String subtitle = 'Carregando pragas...';

    if (state.initializationFailed) {
      subtitle = 'Erro ao carregar dados';
    } else if (!state.isLoading && state.stats != null) {
      final stats = state.stats as Map<String, int>?;
      final insetos = stats?['insetos'] ?? 0;
      final doencas = stats?['doencas'] ?? 0;
      final plantas = stats?['plantas'] ?? 0;
      final total = insetos + doencas + plantas;
      subtitle = 'Identifique e controle $total pragas';
    }

    return ModernHeaderWidget(
      title: 'Pragas e Doenças',
      subtitle: subtitle,
      leftIcon: Icons.pest_control,
      showBackButton: false,
      showActions: false,
      isDark: isDark,
    );
  }

  Widget _buildBody(BuildContext context, WidgetRef ref, HomePragasState state) {
    if (state.isInitializing) {
      return _buildLoadingState(context);
    }
    if (state.initializationFailed) {
      return HomePragasErrorWidget(
        errorMessage: state.initializationError ?? 'Erro desconhecido',
        onRetry: () => ref.read(homePragasNotifierProvider.notifier).forceRefresh(),
      );
    }
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: ReceitaAgroSpacing.sm),
              HomePragasStatsWidget(state: state),

              const SizedBox(height: ReceitaAgroSpacing.sm),
              HomePragasSuggestionsWidget(state: state),

              const SizedBox(height: ReceitaAgroSpacing.sm),
              HomePragasRecentWidget(state: state),

              const SizedBox(height: ReceitaAgroSpacing.bottomSafeArea),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingState(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
          ),
          const SizedBox(height: ReceitaAgroSpacing.md),
          Text(
            'Carregando dados das pragas...',
            style: TextStyle(
              color: theme.colorScheme.onSurfaceVariant,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}
