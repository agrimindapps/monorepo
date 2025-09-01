import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class DefensivosEmptyStateWidget extends StatelessWidget {
  final bool isDark;
  final String? message;
  final String? subtitle;
  final bool isSearchResult;

  const DefensivosEmptyStateWidget({
    super.key,
    required this.isDark,
    this.message,
    this.subtitle,
    this.isSearchResult = false,
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
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.grey.shade800.withValues(alpha: 0.3)
                    : Colors.grey.shade100.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(20),
              ),
              child: FaIcon(
                isSearchResult ? FontAwesomeIcons.magnifyingGlass : FontAwesomeIcons.sprayCan,
                size: 48,
                color: isDark ? Colors.grey.shade500 : Colors.grey.shade400,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              message ?? (isSearchResult 
                  ? 'Nenhum defensivo encontrado'
                  : 'Nenhum defensivo disponível'),
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.grey.shade300 : Colors.grey.shade700,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              subtitle ?? (isSearchResult 
                  ? 'Tente ajustar os termos da busca'
                  : 'Os defensivos serão carregados em breve'),
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.grey.shade500 : Colors.grey.shade500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}