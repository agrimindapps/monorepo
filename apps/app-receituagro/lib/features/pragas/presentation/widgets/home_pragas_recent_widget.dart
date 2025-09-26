import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/design/design_tokens.dart';
import '../../../../core/services/receituagro_navigation_service.dart';
import 'package:get_it/get_it.dart';
import '../../../../core/widgets/content_section_widget.dart';
import '../../../../core/widgets/praga_image_widget.dart';
import '../../domain/entities/praga_entity.dart';
import '../providers/home_pragas_provider.dart';

/// Widget para exibir seção de últimos acessados na home de pragas
/// 
/// Responsabilidades:
/// - Exibir lista de pragas acessadas recentemente
/// - Navegação para detalhes da praga
/// - Registro de novos acessos
/// - Estados vazio e loading
class HomePragasRecentWidget extends StatelessWidget {
  final HomePragasProvider provider;

  const HomePragasRecentWidget({
    super.key,
    required this.provider,
  });

  @override
  Widget build(BuildContext context) {
    return ContentSectionWidget(
      title: 'Últimos Acessados',
      actionIcon: Icons.history,
      onActionPressed: () {},
      isLoading: provider.isLoading,
      emptyMessage: 'Nenhuma praga acessada recentemente',
      isEmpty: provider.recentPragas.isEmpty,
      showCard: true,
      child: provider.recentPragas.isEmpty
          ? const SizedBox.shrink()
          : ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: provider.recentPragas.length,
              itemBuilder: (context, index) {
                final praga = provider.recentPragas[index];
                return _buildPragaItem(context, praga);
              },
              separatorBuilder: (context, index) => Divider(
                height: 1,
                thickness: 0.5,
                color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
              ),
            ),
    );
  }

  Widget _buildPragaItem(BuildContext context, PragaEntity praga) {
    final emojiAndType = _getEmojiAndType(praga.tipoPraga);
    final emoji = emojiAndType.emoji;
    final type = emojiAndType.type;
    
    return ContentListItemWidget(
      title: praga.nomeComum,
      subtitle: praga.nomeCientifico,
      category: type,
      leading: _buildPragaItemLeading(context, praga.nomeCientifico, type, emoji),
      onTap: () => _navigateToPragaDetails(context, praga.nomeComum, praga.nomeCientifico, praga),
    );
  }

  Widget _buildPragaItemLeading(BuildContext context, String nomeCientifico, String type, String emoji) {
    final categoryColor = _getColorForType(type, context);
    
    return PragaImageWidget(
      nomeCientifico: nomeCientifico,
      width: ReceitaAgroDimensions.itemImageSize,
      height: ReceitaAgroDimensions.itemImageSize,
      fit: BoxFit.cover,
      borderRadius: BorderRadius.circular(ReceitaAgroDimensions.itemImageSize / 2),
      errorWidget: Container(
        width: ReceitaAgroDimensions.itemImageSize,
        height: ReceitaAgroDimensions.itemImageSize,
        decoration: BoxDecoration(
          color: categoryColor.withValues(alpha: 0.1),
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Text(
            emoji,
            style: const TextStyle(fontSize: 24),
          ),
        ),
      ),
    );
  }

  _EmojiAndType _getEmojiAndType(String tipoPraga) {
    switch (tipoPraga) {
      case '1':
        return const _EmojiAndType('🐛', 'Inseto');
      case '2':
        return const _EmojiAndType('🦠', 'Doença');
      case '3':
        return const _EmojiAndType('🌿', 'Planta');
      default:
        return const _EmojiAndType('🐛', 'Inseto');
    }
  }

  Color _getColorForType(String type, BuildContext context) {
    final theme = Theme.of(context);
    switch (type.toLowerCase()) {
      case 'inseto':
        return theme.colorScheme.primary;
      case 'doença':
        return theme.colorScheme.tertiary;
      case 'planta':
        return theme.colorScheme.secondary;
      default:
        return theme.colorScheme.primary;
    }
  }

  void _navigateToPragaDetails(BuildContext context, String pragaName, String scientificName, PragaEntity praga) {
    // Registra o acesso através do provider
    provider.recordPragaAccess(praga);
    
    final navigationService = GetIt.instance<ReceitaAgroNavigationService>();
    navigationService.navigateToDetalhePraga(
      pragaName: pragaName,
      pragaId: praga.idReg, // Use ID for better precision
      pragaScientificName: scientificName,
    );
  }
}

/// Helper class to replace record syntax for Dart 2.x compatibility
class _EmojiAndType {
  final String emoji;
  final String type;
  
  const _EmojiAndType(this.emoji, this.type);
}