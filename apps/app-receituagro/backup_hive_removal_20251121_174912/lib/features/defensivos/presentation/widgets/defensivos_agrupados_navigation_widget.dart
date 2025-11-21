import 'package:flutter/material.dart';

/// Widget de navegação hierárquica para Defensivos Agrupados
/// Gerencia breadcrumb e navegação entre níveis
class DefensivosAgrupadosNavigationWidget extends StatelessWidget {
  final int navigationLevel;
  final String categoryTitle;
  final String? groupTitle;
  final bool isDark;
  final VoidCallback? onNavigateBack;
  final VoidCallback? onNavigateToRoot;

  const DefensivosAgrupadosNavigationWidget({
    super.key,
    required this.navigationLevel,
    required this.categoryTitle,
    this.groupTitle,
    required this.isDark,
    this.onNavigateBack,
    this.onNavigateToRoot,
  });

  @override
  Widget build(BuildContext context) {
    if (navigationLevel == 0) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2A2A2E) : const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          if (onNavigateToRoot != null) ...[
            GestureDetector(
              onTap: onNavigateToRoot,
              child: Text(
                categoryTitle,
                style: TextStyle(
                  color: isDark ? Colors.blue.shade300 : Colors.blue.shade600,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Icon(
                Icons.keyboard_arrow_right,
                size: 16,
                color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
              ),
            ),
          ],
          Expanded(
            child: Text(
              groupTitle ?? 'Items',
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black87,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (onNavigateBack != null)
            GestureDetector(
              onTap: onNavigateBack,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey.shade700 : Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(
                  Icons.close,
                  size: 16,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
