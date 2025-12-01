import 'package:core/core.dart' hide Column;
import 'package:flutter/material.dart';

import '../../../../core/widgets/praga_image_widget.dart';
import '../../domain/entities/favorito_entity.dart';

/// Widget responsável por renderizar um item de favorito
/// 
/// Responsabilidades:
/// - Exibir informações do favorito
/// - Imagem/ícone apropriado
/// - Botão de remoção
/// - Navegação para detalhes
/// - Suporte a diferentes tipos
class FavoritosItemWidget extends StatelessWidget {
  final FavoritoEntity favorito;
  final String tipo;
  final bool isDark;
  final VoidCallback onRemove;

  const FavoritosItemWidget({
    super.key,
    required this.favorito,
    required this.tipo,
    required this.isDark,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key('favorito_${favorito.id}'),
      direction: DismissDirection.endToStart,
      background: _buildSwipeBackground(),
      confirmDismiss: (direction) async {
        return await _showRemoveDialog(context);
      },
      onDismissed: (direction) {
        onRemove();
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 2),
        decoration: BoxDecoration(
          color: isDark ? Colors.grey.shade800 : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.all(12),
          leading: _buildLeading(),
          title: _buildTitle(),
          subtitle: _buildSubtitle(),
          trailing: Icon(
            Icons.chevron_right,
            color: isDark ? Colors.white30 : Colors.black12,
            size: 20,
          ),
          onTap: () => _handleTap(context),
        ),
      ),
    );
  }

  /// Constrói o leading (imagem ou ícone)
  Widget? _buildLeading() {
    switch (tipo) {
      case TipoFavorito.defensivo:
        return Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: Colors.blue.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.blue.withValues(alpha: 0.2),
              width: 1,
            ),
          ),
          child: const Icon(
            FontAwesomeIcons.shield,
            color: Colors.blue,
            size: 22,
          ),
        );
        
      case TipoFavorito.praga:
        return Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.green.withValues(alpha: 0.2),
              width: 1,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(11),
            child: PragaImageWidget(
              nomeCientifico: _getNomeCientifico(),
              width: 52,
              height: 52,
              fit: BoxFit.cover,
              errorWidget: DecoratedBox(
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: const Icon(
                  FontAwesomeIcons.bug,
                  color: Colors.red,
                  size: 22,
                ),
              ),
            ),
          ),
        );
        
      case TipoFavorito.diagnostico:
        return Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: Colors.green.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.green.withValues(alpha: 0.2),
              width: 1,
            ),
          ),
          child: const Icon(
            FontAwesomeIcons.stethoscope,
            color: Colors.green,
            size: 22,
          ),
        );
        
      default:
        return Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: Colors.grey.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.favorite,
            color: Colors.grey,
            size: 22,
          ),
        );
    }
  }

  /// Constrói o título
  Widget _buildTitle() {
    return Text(
      favorito.nomeDisplay,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: isDark ? Colors.white : Colors.black87,
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }

  /// Constrói o subtítulo
  Widget? _buildSubtitle() {
    String? subtitle;
    
    switch (tipo) {
      case TipoFavorito.defensivo:
        subtitle = 'Defensivo agrícola';
        break;
      case TipoFavorito.praga:
        subtitle = _getNomeCientifico().isNotEmpty
            ? _getNomeCientifico()
            : 'Praga agrícola';
        break;
      case TipoFavorito.diagnostico:
        subtitle = 'Diagnóstico salvo';
        break;
      default:
        subtitle = 'Item favoritado';
        break;
    }
    
    return Text(
      subtitle,
      style: TextStyle(
        fontSize: 14,
        color: isDark ? Colors.grey.shade300 : Colors.grey.shade600,
        fontStyle: tipo == TipoFavorito.praga ? FontStyle.italic : FontStyle.normal,
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }

  /// Constrói o background do swipe (efeito de arrastar)
  Widget _buildSwipeBackground() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: Colors.red.shade400,
        borderRadius: BorderRadius.circular(12),
      ),
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

  /// Manipula tap no item
  void _handleTap(BuildContext context) {
    
    switch (tipo) {
      case TipoFavorito.defensivo:
        break;
      case TipoFavorito.praga:
        break;
      case TipoFavorito.diagnostico:
        break;
    }
  }

  /// Mostra diálogo de confirmação para remoção
  Future<bool?> _showRemoveDialog(BuildContext context) async {
    return await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
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
                  text: '"${favorito.nomeDisplay}"',
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

  /// Obtém o nome científico se disponível, baseado no tipo específico
  String _getNomeCientifico() {
    if (favorito is FavoritoPragaEntity) {
      return (favorito as FavoritoPragaEntity).nomeCientifico;
    }
    return '';
  }
}
