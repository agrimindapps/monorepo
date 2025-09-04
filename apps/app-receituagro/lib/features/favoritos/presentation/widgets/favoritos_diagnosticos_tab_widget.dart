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
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            itemCount: items.length + 1,
            itemBuilder: (context, index) {
              if (index == items.length) {
                return const SizedBox(height: 80);
              }
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
    
    return GestureDetector(
      onTap: () => _navigateToDiagnosticoDetails(context, diagnostico),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: theme.shadowColor.withValues(alpha: 0.1),
              spreadRadius: 1,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
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
                    maxLines: 2,
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
            IconButton(
              icon: const Icon(
                Icons.delete_outline,
                color: Colors.red,
                size: 20,
              ),
              onPressed: () async {
                await provider.toggleFavorito(TipoFavorito.diagnostico, diagnostico.id);
              },
            ),
          ],
        ),
      ),
    );
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