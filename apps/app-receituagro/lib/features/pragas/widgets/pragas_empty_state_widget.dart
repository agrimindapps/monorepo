import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class PragasEmptyStateWidget extends StatelessWidget {
  final String pragaType;
  final bool isDark;

  const PragasEmptyStateWidget({
    super.key,
    required this.pragaType,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: _getTypeColor().withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(60),
                border: Border.all(
                  color: _getTypeColor().withValues(alpha: 0.2),
                  width: 2,
                ),
              ),
              child: Center(
                child: FaIcon(
                  _getEmptyStateIcon(),
                  size: 48,
                  color: _getTypeColor().withValues(alpha: 0.6),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              _getEmptyStateTitle(),
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              _getEmptyStateMessage(),
              style: TextStyle(
                fontSize: 16,
                color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: _getTypeColor().withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: _getTypeColor().withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    size: 18,
                    color: _getTypeColor(),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _getEmptyStateTip(),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: _getTypeColor(),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getTypeColor() {
    switch (pragaType) {
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

  IconData _getEmptyStateIcon() {
    switch (pragaType) {
      case '1': // Insetos
        return FontAwesomeIcons.bug;
      case '2': // Doenças
        return FontAwesomeIcons.virus;
      case '3': // Plantas Daninhas
        return FontAwesomeIcons.seedling;
      default:
        return FontAwesomeIcons.search;
    }
  }

  String _getEmptyStateTitle() {
    switch (pragaType) {
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
    switch (pragaType) {
      case '1':
        return 'Não há insetos registrados no momento.\nVerifique novamente em breve.';
      case '2':
        return 'Não há doenças registradas no momento.\nVerifique novamente em breve.';
      case '3':
        return 'Não há plantas daninhas registradas no momento.\nVerifique novamente em breve.';
      default:
        return 'Não há pragas registradas no momento.\nVerifique novamente em breve.';
    }
  }

  String _getEmptyStateTip() {
    switch (pragaType) {
      case '1':
        return 'Use a busca para encontrar insetos específicos';
      case '2':
        return 'Use a busca para encontrar doenças específicas';
      case '3':
        return 'Use a busca para encontrar plantas específicas';
      default:
        return 'Use a busca para encontrar pragas específicas';
    }
  }
}