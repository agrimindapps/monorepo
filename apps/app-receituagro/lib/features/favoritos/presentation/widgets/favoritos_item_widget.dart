import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

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
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      elevation: isDark ? 4 : 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      color: isDark ? Colors.grey.shade800 : Colors.white,
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: _buildLeading(),
        title: _buildTitle(),
        subtitle: _buildSubtitle(),
        trailing: _buildTrailing(),
        onTap: () => _handleTap(context),
      ),
    );
  }

  /// Constrói o leading (imagem ou ícone)
  Widget? _buildLeading() {
    switch (tipo) {
      case TipoFavorito.defensivo:
        return Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: Colors.blue.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(
            FontAwesomeIcons.shield,
            color: Colors.blue,
            size: 24,
          ),
        );
        
      case TipoFavorito.praga:
        return SizedBox(
          width: 48,
          height: 48,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: PragaImageWidget(
              nomeCientifico: _getNomeCientifico(),
              width: 48,
              height: 48,
              fit: BoxFit.cover,
              errorWidget: DecoratedBox(
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  FontAwesomeIcons.bug,
                  color: Colors.red,
                  size: 24,
                ),
              ),
            ),
          ),
        );
        
      case TipoFavorito.diagnostico:
        return Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: Colors.green.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(
            FontAwesomeIcons.stethoscope,
            color: Colors.green,
            size: 24,
          ),
        );
        
      default:
        return Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: Colors.grey.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(
            Icons.favorite,
            color: Colors.grey,
            size: 24,
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
    
    if (subtitle == null) return null;
    
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

  /// Constrói o trailing (botão de remoção)
  Widget _buildTrailing() {
    return IconButton(
      onPressed: () => _showRemoveDialog(),
      icon: const Icon(
        Icons.delete_outline,
        color: Colors.red,
        size: 20,
      ),
      tooltip: 'Remover dos favoritos',
    );
  }

  /// Manipula tap no item
  void _handleTap(BuildContext context) {
    // TODO: Implementar navegação para página de detalhes
    // Usar o Navigator ou sistema de roteamento do app
    
    switch (tipo) {
      case TipoFavorito.defensivo:
        // Navigator.pushNamed(context, '/defensivo/${favorito.id}');
        break;
      case TipoFavorito.praga:
        // Navigator.pushNamed(context, '/praga/${favorito.id}');
        break;
      case TipoFavorito.diagnostico:
        // Navigator.pushNamed(context, '/diagnostico/${favorito.id}');
        break;
    }
  }

  /// Mostra diálogo de confirmação para remoção
  void _showRemoveDialog() {
    // TODO: Implementar diálogo de confirmação
    // Por ora, chama diretamente a remoção
    onRemove();
  }

  /// Obtém o nome científico se disponível, baseado no tipo específico
  String _getNomeCientifico() {
    if (favorito is FavoritoPragaEntity) {
      return (favorito as FavoritoPragaEntity).nomeCientifico;
    }
    return '';
  }
}