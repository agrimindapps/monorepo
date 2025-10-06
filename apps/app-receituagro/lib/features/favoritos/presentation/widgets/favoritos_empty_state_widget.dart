import 'package:core/core.dart';
import 'package:flutter/material.dart';

import '../../domain/entities/favorito_entity.dart';

/// Widget para estado vazio de favoritos
/// 
/// Responsabilidades:
/// - Exibir mensagem quando não há favoritos
/// - Ícone apropriado para o tipo
/// - Sugestões de ação para o usuário
/// - Design adaptado ao tema
class FavoritosEmptyStateWidget extends StatelessWidget {
  final String message;
  final String tipo;
  final bool isDark;

  const FavoritosEmptyStateWidget({
    super.key,
    required this.message,
    required this.tipo,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: _getTypeColor().withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _getTypeIcon(),
                size: 40,
                color: _getTypeColor(),
              ),
            ),
            
            const SizedBox(height: 24),
            Text(
              message,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 12),
            Text(
              _getActionSuggestion(),
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 32),
            _buildActionButton(context),
          ],
        ),
      ),
    );
  }

  /// Retorna a cor baseada no tipo
  Color _getTypeColor() {
    switch (tipo) {
      case TipoFavorito.defensivo:
        return Colors.blue;
      case TipoFavorito.praga:
        return Colors.red;
      case TipoFavorito.diagnostico:
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  /// Retorna o ícone baseado no tipo
  IconData _getTypeIcon() {
    switch (tipo) {
      case TipoFavorito.defensivo:
        return FontAwesomeIcons.shield;
      case TipoFavorito.praga:
        return FontAwesomeIcons.bug;
      case TipoFavorito.diagnostico:
        return FontAwesomeIcons.stethoscope;
      default:
        return FontAwesomeIcons.heart;
    }
  }

  /// Retorna sugestão de ação baseada no tipo
  String _getActionSuggestion() {
    switch (tipo) {
      case TipoFavorito.defensivo:
        return 'Explore a biblioteca de defensivos e salve os que mais utiliza';
      case TipoFavorito.praga:
        return 'Identifique pragas e salve as mais comuns na sua região';
      case TipoFavorito.diagnostico:
        return 'Realize diagnósticos e salve os resultados importantes';
      default:
        return 'Explore o conteúdo e salve seus favoritos';
    }
  }

  /// Constrói botão de ação
  Widget _buildActionButton(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () => _handleActionTap(context),
      icon: Icon(_getActionIcon()),
      label: Text(_getActionLabel()),
      style: ElevatedButton.styleFrom(
        backgroundColor: _getTypeColor(),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
      ),
    );
  }

  /// Retorna ícone da ação
  IconData _getActionIcon() {
    switch (tipo) {
      case TipoFavorito.defensivo:
        return Icons.search;
      case TipoFavorito.praga:
        return Icons.camera_alt;
      case TipoFavorito.diagnostico:
        return Icons.quiz;
      default:
        return Icons.explore;
    }
  }

  /// Retorna label da ação
  String _getActionLabel() {
    switch (tipo) {
      case TipoFavorito.defensivo:
        return 'Explorar Defensivos';
      case TipoFavorito.praga:
        return 'Identificar Pragas';
      case TipoFavorito.diagnostico:
        return 'Fazer Diagnóstico';
      default:
        return 'Explorar';
    }
  }

  /// Manipula tap na ação
  void _handleActionTap(BuildContext context) {
    switch (tipo) {
      case TipoFavorito.defensivo:
        break;
      case TipoFavorito.praga:
        break;
      case TipoFavorito.diagnostico:
        break;
    }
  }
}
