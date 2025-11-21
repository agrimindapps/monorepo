import 'package:core/core.dart' hide Column;
import 'package:flutter/material.dart';

class PragaCulturaEmptyStateWidget extends StatelessWidget {
  final String tipoPraga;
  final String culturaNome;
  final bool isDark;
  final bool hasSearchText;
  final String searchText;

  const PragaCulturaEmptyStateWidget({
    super.key,
    required this.tipoPraga,
    required this.culturaNome,
    required this.isDark,
    this.hasSearchText = false,
    this.searchText = '',
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
    final color = _getTypeColor();
    final icon = _getTypeIcon();

    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(60),
        border: Border.all(color: color.withValues(alpha: 0.2), width: 2),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Center(
        child: FaIcon(icon, size: 48, color: color.withValues(alpha: 0.6)),
      ),
    );
  }

  Widget _buildTitle() {
    return Text(
      _getEmptyStateTitle(),
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
      _getEmptyStateMessage(),
      style: TextStyle(
        fontSize: 16,
        color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
        height: 1.4,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildInfoCard() {
    final color = _getTypeColor();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.2), width: 1),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.info_outline_rounded, size: 18, color: color),
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
          if (_shouldShowTip()) ...[
            const SizedBox(height: 8),
            Text(
              _getEmptyStateTip(),
              style: TextStyle(fontSize: 13, color: color),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }

  bool _shouldShowTip() {
    return !hasSearchText && culturaNome.isNotEmpty;
  }

  Color _getTypeColor() {
    switch (tipoPraga) {
      case '1': // Insetos
        return const Color(0xFFE53935);
      case '2': // Doenças
        return const Color(0xFFFF9800);
      case '3': // Plantas Daninhas
        return const Color(0xFF4CAF50);
      default:
        return const Color(0xFF757575);
    }
  }

  IconData _getTypeIcon() {
    if (hasSearchText) {
      return FontAwesomeIcons.magnifyingGlassMinus;
    }

    switch (tipoPraga) {
      case '1': // Insetos
        return FontAwesomeIcons.bug;
      case '2': // Doenças
        return FontAwesomeIcons.virus;
      case '3': // Plantas Daninhas
        return FontAwesomeIcons.seedling;
      default:
        return FontAwesomeIcons.magnifyingGlass;
    }
  }

  String _getEmptyStateTitle() {
    if (hasSearchText) {
      return 'Nenhum resultado encontrado';
    }

    switch (tipoPraga) {
      case '1':
        return 'Nenhum inseto encontrado';
      case '2':
        return 'Nenhuma doença encontrada';
      case '3':
        return 'Nenhuma planta daninha encontrada';
      default:
        return 'Nenhuma praga encontrada';
    }
  }

  String _getEmptyStateMessage() {
    if (hasSearchText) {
      return 'Não encontramos nenhuma praga para "$searchText".\nTente buscar com outros termos.';
    }

    if (culturaNome.isNotEmpty) {
      final tipoPragaName = _getTipoPragaName();
      return 'Não há $tipoPragaName registrados\npara a cultura $culturaNome.';
    }

    switch (tipoPraga) {
      case '1':
        return 'Não há insetos registrados\nno momento.';
      case '2':
        return 'Não há doenças registradas\nno momento.';
      case '3':
        return 'Não há plantas daninhas registradas\nno momento.';
      default:
        return 'Não há pragas registradas\nno momento.';
    }
  }

  String _getTipoPragaName() {
    switch (tipoPraga) {
      case '1':
        return 'insetos';
      case '2':
        return 'doenças';
      case '3':
        return 'plantas daninhas';
      default:
        return 'pragas';
    }
  }

  String _getInfoTitle() {
    if (hasSearchText) {
      return 'Dica de busca';
    }
    return 'Informação';
  }

  String _getEmptyStateTip() {
    switch (tipoPraga) {
      case '1':
        return 'Esta cultura pode não ser atacada por insetos específicos ou os dados ainda não foram cadastrados.';
      case '2':
        return 'Esta cultura pode ser resistente a certas doenças ou os dados ainda não foram cadastrados.';
      case '3':
        return 'Esta cultura pode ter boa competitividade contra plantas invasoras específicas.';
      default:
        return 'Os dados podem ainda não ter sido cadastrados para esta cultura.';
    }
  }
}
