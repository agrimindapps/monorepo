import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class EmptyStateWidget extends StatelessWidget {
  final bool isDark;
  final String? message;
  final String? subtitle;

  const EmptyStateWidget({
    super.key,
    required this.isDark,
    this.message,
    this.subtitle,
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
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.grey.shade800.withValues(alpha: 0.3)
                    : Colors.grey.shade100.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(20),
              ),
              child: FaIcon(
                FontAwesomeIcons.magnifyingGlass,
                size: 48,
                color: isDark ? Colors.grey.shade500 : Colors.grey.shade400,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              message ?? 'Nenhuma cultura encontrada',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.grey.shade300 : Colors.grey.shade700,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              subtitle ?? 'Tente ajustar os termos da busca',
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