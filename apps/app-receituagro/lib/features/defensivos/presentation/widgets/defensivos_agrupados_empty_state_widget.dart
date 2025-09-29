import 'package:core/core.dart';
import 'package:flutter/material.dart';

import '../../models/defensivos_agrupados_category.dart';

class DefensivosAgrupadosEmptyStateWidget extends StatelessWidget {
  final DefensivosAgrupadosCategory category;
  final bool isDark;
  final bool isSearching;
  final String searchText;
  final int navigationLevel;

  const DefensivosAgrupadosEmptyStateWidget({
    super.key,
    required this.category,
    required this.isDark,
    this.isSearching = false,
    this.searchText = '',
    this.navigationLevel = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildIcon(),
            const SizedBox(height: 24),
            _buildTitle(),
            const SizedBox(height: 12),
            _buildMessage(),
            const SizedBox(height: 32),
            _buildInfoCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildIcon() {
    final color = _getIconColor();
    final icon = isSearching && searchText.isNotEmpty 
        ? FontAwesomeIcons.magnifyingGlassMinus 
        : category.icon;
    
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(60),
        border: Border.all(
          color: color.withValues(alpha: 0.2),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Center(
        child: Icon(
          icon,
          size: 48,
          color: color.withValues(alpha: 0.6),
        ),
      ),
    );
  }

  Widget _buildTitle() {
    return Text(
      _getTitle(),
      style: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: isDark ? Colors.white : Colors.black87,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildMessage() {
    return Text(
      _getMessage(),
      style: TextStyle(
        fontSize: 16,
        color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
        height: 1.4,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildInfoCard() {
    final color = _getIconColor();
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.info_outline_rounded,
                size: 18,
                color: color,
              ),
              const SizedBox(width: 8),
              Text(
                _getInfoTitle(),
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            _getInfoMessage(),
            style: TextStyle(
              fontSize: 13,
              color: color,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Color _getIconColor() {
    if (isSearching && searchText.isNotEmpty) {
      return Colors.orange; // Cor para estado de busca sem resultados
    }
    
    switch (category) {
      case DefensivosAgrupadosCategory.fabricantes:
        return const Color(0xFF1976D2); // Azul
      case DefensivosAgrupadosCategory.classeAgronomica:
        return const Color(0xFF7B1FA2); // Roxo
      case DefensivosAgrupadosCategory.ingredienteAtivo:
        return const Color(0xFFD32F2F); // Vermelho
      case DefensivosAgrupadosCategory.modoAcao:
        return const Color(0xFFF57C00); // Laranja
      default:
        return const Color(0xFF2E7D32); // Verde
    }
  }

  String _getTitle() {
    if (isSearching && searchText.isNotEmpty) {
      return 'Nenhum resultado encontrado';
    }
    
    if (navigationLevel > 0) {
      return 'Nenhum item encontrado';
    }
    
    return category.emptyStateMessage;
  }

  String _getMessage() {
    if (isSearching && searchText.isNotEmpty) {
      return 'Não encontramos nenhum resultado para "$searchText".\nTente buscar com outros termos.';
    }
    
    if (navigationLevel > 0) {
      return 'Não há itens disponíveis\nneste grupo no momento.';
    }
    
    switch (category) {
      case DefensivosAgrupadosCategory.fabricantes:
        return 'Não há fabricantes registrados\nno banco de dados no momento.';
      case DefensivosAgrupadosCategory.classeAgronomica:
        return 'Não há classes agronômicas\nregistradas no momento.';
      case DefensivosAgrupadosCategory.ingredienteAtivo:
        return 'Não há ingredientes ativos\nregistrados no momento.';
      case DefensivosAgrupadosCategory.modoAcao:
        return 'Não há modos de ação\nregistrados no momento.';
      default:
        return 'Não há defensivos registrados\nno banco de dados no momento.';
    }
  }

  String _getInfoTitle() {
    if (isSearching && searchText.isNotEmpty) {
      return 'Dica de busca';
    }
    
    return 'Informação';
  }

  String _getInfoMessage() {
    if (isSearching && searchText.isNotEmpty) {
      return 'Tente usar termos mais gerais ou verifique a grafia.';
    }
    
    if (navigationLevel > 0) {
      return 'Volte para a categoria anterior ou tente uma busca diferente.';
    }
    
    switch (category) {
      case DefensivosAgrupadosCategory.fabricantes:
        return 'Os dados de fabricantes serão carregados quando estiverem disponíveis.';
      case DefensivosAgrupadosCategory.classeAgronomica:
        return 'As classes agronômicas são organizadas por tipo de defensivo.';
      case DefensivosAgrupadosCategory.ingredienteAtivo:
        return 'Os ingredientes ativos são os componentes principais dos defensivos.';
      case DefensivosAgrupadosCategory.modoAcao:
        return 'Os modos de ação definem como os defensivos atuam nas pragas.';
      default:
        return 'Os dados dos defensivos serão carregados quando estiverem disponíveis.';
    }
  }
}