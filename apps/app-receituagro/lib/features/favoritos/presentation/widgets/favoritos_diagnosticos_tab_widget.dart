import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/interfaces/i_premium_service.dart';
import '../../domain/entities/favorito_entity.dart';
import '../providers/favoritos_provider_simplified.dart';

/// Widget especializado para aba de Diagnósticos favoritos
/// Gerencia listagem e ações específicas para diagnósticos + verificação premium
class FavoritosDiagnosticosTabWidget extends StatelessWidget {
  final FavoritosProviderSimplified provider;
  final VoidCallback onReload;

  const FavoritosDiagnosticosTabWidget({
    super.key,
    required this.provider,
    required this.onReload,
  });

  @override
  Widget build(BuildContext context) {
    final premiumService = sl<IPremiumService>();
    final isPremium = premiumService.isPremium;
    
    if (!isPremium) {
      return _buildPremiumRequiredCard(context);
    }
    
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return _buildTabContent(
      context: context,
      provider: provider,
      viewState: provider.getViewStateForType(TipoFavorito.diagnostico),
      emptyMessage: provider.getEmptyMessageForType(TipoFavorito.diagnostico),
      items: provider.diagnosticos,
      itemBuilder: (diagnostico) => _buildDiagnosticoItem(context, diagnostico, provider),
      isDark: isDark,
    );
  }

  Widget _buildTabContent<T extends FavoritoEntity>({
    required BuildContext context,
    required FavoritosProviderSimplified provider,
    required FavoritosViewState viewState,
    required String emptyMessage,
    required List<T> items,
    required Widget Function(T) itemBuilder,
    required bool isDark,
  }) {
    switch (viewState) {
      case FavoritosViewState.loading:
        return const Center(child: CircularProgressIndicator());
      
      case FavoritosViewState.error:
        return _buildErrorState(context, provider, isDark);
      
      case FavoritosViewState.empty:
        return _buildEmptyState(context, emptyMessage, isDark);
      
      case FavoritosViewState.loaded:
        return RefreshIndicator(
          onRefresh: () async {
            await provider.loadAllFavoritos();
          },
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: items.length,
            separatorBuilder: (context, index) => const Divider(
              height: 1,
              indent: 16,
              endIndent: 16,
            ),
            itemBuilder: (context, index) {
              return itemBuilder(items[index]);
            },
          ),
        );
      
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildDiagnosticoItem(
    BuildContext context, 
    FavoritoDiagnosticoEntity diagnostico, 
    FavoritosProviderSimplified provider
  ) {
    final theme = Theme.of(context);
    
    return Dismissible(
      key: Key('favorito_diagnostico_${diagnostico.id}'),
      direction: DismissDirection.endToStart,
      background: _buildSwipeBackground(),
      confirmDismiss: (direction) async {
        return await _showRemoveDialog(context, '${diagnostico.nomeDefensivo} → ${diagnostico.nomePraga}');
      },
      onDismissed: (direction) async {
        await _removeFavorito(context, provider, diagnostico);
      },
      child: InkWell(
        onTap: () => _navigateToDiagnosticoDetails(context, diagnostico),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF4CAF50).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  FontAwesomeIcons.magnifyingGlass,
                  color: Color(0xFF4CAF50),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${diagnostico.nomeDefensivo} → ${diagnostico.nomePraga}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurface,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (diagnostico.cultura.isNotEmpty == true) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Cultura: ${diagnostico.cultura}',
                        style: TextStyle(
                          fontSize: 12,
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    if (diagnostico.dosagem.isNotEmpty == true) ...[
                      const SizedBox(height: 2),
                      Text(
                        'Dosagem: ${diagnostico.dosagem}',
                        style: TextStyle(
                          fontSize: 11,
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Constrói o background do swipe (efeito de arrastar)
  Widget _buildSwipeBackground() {
    return Container(
      color: Colors.red.shade400,
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.only(right: 20),
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.delete_outline,
            color: Colors.white,
            size: 28,
          ),
          SizedBox(height: 4),
          Text(
            'Excluir',
            style: TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  /// Mostra diálogo de confirmação para remoção
  Future<bool?> _showRemoveDialog(BuildContext context, String itemName) async {
    return await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: const Row(
            children: [
              Icon(
                Icons.warning_amber_rounded,
                color: Colors.orange,
                size: 24,
              ),
              SizedBox(width: 8),
              Text('Confirmar Remoção'),
            ],
          ),
          content: RichText(
            text: TextSpan(
              style: TextStyle(
                fontSize: 16,
                color: isDark ? Colors.white : Colors.black87,
              ),
              children: [
                const TextSpan(text: 'Deseja remover '),
                TextSpan(
                  text: '"$itemName"',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                const TextSpan(text: ' dos seus favoritos?'),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(
                'Cancelar',
                style: TextStyle(
                  color: isDark ? Colors.grey.shade300 : Colors.grey.shade600,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Remover'),
            ),
          ],
        );
      },
    );
  }

  /// Remove o favorito e mostra feedback
  Future<void> _removeFavorito(
    BuildContext context,
    FavoritosProviderSimplified provider,
    FavoritoDiagnosticoEntity diagnostico,
  ) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final theme = Theme.of(context);
    
    try {
      final success = await provider.toggleFavorito(TipoFavorito.diagnostico, diagnostico.id);
      
      if (success) {
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text('🗑️ ${diagnostico.nomeDefensivo} → ${diagnostico.nomePraga} removido dos favoritos'),
            duration: const Duration(seconds: 2),
            backgroundColor: theme.colorScheme.primary,
          ),
        );
      } else {
        scaffoldMessenger.showSnackBar(
          const SnackBar(
            content: Text('❌ Erro ao remover dos favoritos'),
            duration: Duration(seconds: 2),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      scaffoldMessenger.showSnackBar(
        const SnackBar(
          content: Text('❌ Erro inesperado ao remover favorito'),
          duration: Duration(seconds: 2),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildPremiumRequiredCard(BuildContext context) {
    return Center(
      child: Container(
        width: 280,
        margin: const EdgeInsets.all(8.0),
        padding: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF3E0),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFFFFB74D),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.diamond,
              size: 48,
              color: Color(0xFFFF9800),
            ),
            const SizedBox(height: 16),
            const Text(
              'Diagnósticos Favoritos não disponíveis',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFFE65100),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'Este recurso está disponível apenas para assinantes do app.',
              style: TextStyle(
                fontSize: 16,
                color: Color(0xFFBF360C),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  final premiumService = sl<IPremiumService>();
                  premiumService.navigateToPremium();
                },
                icon: const Icon(
                  Icons.rocket_launch,
                  color: Colors.white,
                  size: 20,
                ),
                label: const Text(
                  'Desbloquear Agora',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF9800),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(
    BuildContext context,
    FavoritosProviderSimplified provider,
    bool isDark,
  ) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: isDark ? Colors.red.shade400 : Colors.red.shade600,
          ),
          const SizedBox(height: 16),
          Text(
            'Erro ao carregar diagnósticos',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          if (provider.errorMessage != null) ...[
            const SizedBox(height: 8),
            Text(
              provider.errorMessage!,
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEmptyState(
    BuildContext context,
    String emptyMessage,
    bool isDark,
  ) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.favorite_outline,
            size: 64,
            color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
          ),
          const SizedBox(height: 16),
          Text(
            emptyMessage,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToDiagnosticoDetails(BuildContext context, FavoritoDiagnosticoEntity diagnostico) {
    Navigator.pushNamed(
      context,
      '/detalhe-diagnostico',
      arguments: {
        'diagnosticoId': diagnostico.id,
        'nomeDefensivo': diagnostico.displayName,
        'nomePraga': diagnostico.nomePraga,
        'cultura': diagnostico.displayCultura,
      },
    );
  }
}