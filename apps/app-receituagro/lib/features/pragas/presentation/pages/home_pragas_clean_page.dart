import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/design/design_tokens.dart';
import '../../../../core/widgets/modern_header_widget.dart';
import '../providers/home_pragas_provider.dart';
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
/// - Integração com HomePragasProvider
class HomePragasCleanPage extends StatelessWidget {
  const HomePragasCleanPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => HomePragasProvider(),
      child: const _HomePragasContent(),
    );
  }
}

class _HomePragasContent extends StatelessWidget {
  const _HomePragasContent();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Consumer<HomePragasProvider>(
          builder: (context, provider, child) {
            return Column(
              children: [
                _buildHeader(context, isDark, provider),
                Expanded(
                  child: _buildBody(context, provider),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isDark, HomePragasProvider provider) {
    String subtitle = 'Carregando pragas...';
    
    if (provider.initializationFailed) {
      subtitle = 'Erro ao carregar dados';
    } else if (!provider.isLoading && provider.stats != null) {
      final stats = provider.stats;
      final total = (stats?.insetos ?? 0) + (stats?.doencas ?? 0) + (stats?.plantas ?? 0);
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

  Widget _buildBody(BuildContext context, HomePragasProvider provider) {
    // Estado de inicialização
    if (provider.isInitializing) {
      return _buildLoadingState(context);
    }

    // Estado de erro de inicialização
    if (provider.initializationFailed) {
      return HomePragasErrorWidget(
        errorMessage: provider.initializationError ?? 'Erro desconhecido',
        onRetry: provider.forceRefresh,
      );
    }

    // Conteúdo principal
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: ReceitaAgroSpacing.sm),
              
              // Grid de estatísticas/categorias
              HomePragasStatsWidget(provider: provider),
              
              const SizedBox(height: ReceitaAgroSpacing.lg),
              
              // Seção de sugestões com carrossel
              HomePragasSuggestionsWidget(provider: provider),
              
              const SizedBox(height: ReceitaAgroSpacing.lg),
              
              // Seção de últimos acessados
              HomePragasRecentWidget(provider: provider),
              
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