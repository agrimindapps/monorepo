import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/widgets/semantic_widgets.dart';

/// Unified header for record pages (Fuel, Expenses, Maintenance, Odometer)
/// 
/// Provides a consistent header design across all record listing pages with:
/// - Back button
/// - Icon with background
/// - Title and subtitle
/// - Optional action button
/// 
/// Example:
/// ```dart
/// RecordPageHeader(
///   title: 'Abastecimentos',
///   subtitle: 'Gerencie os abastecimentos do seu veículo',
///   icon: Icons.local_gas_station,
///   semanticLabel: 'Seção de abastecimentos',
///   semanticHint: 'Página principal para gerenciar abastecimentos',
///   actionButton: IconButton(...),
/// )
/// ```
class RecordPageHeader extends StatelessWidget {
  const RecordPageHeader({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    this.semanticLabel,
    this.semanticHint,
    this.actionButton,
    this.onBackPressed,
  });

  /// Main title of the page
  final String title;

  /// Subtitle/description
  final String subtitle;

  /// Icon to display
  final IconData icon;

  /// Accessibility label for the section
  final String? semanticLabel;

  /// Accessibility hint for the section
  final String? semanticHint;

  /// Optional action button (e.g., toggle stats)
  final Widget? actionButton;

  /// Custom back button callback (defaults to context.pop())
  final VoidCallback? onBackPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
      child: Container(
        margin: const EdgeInsets.fromLTRB(0, 0, 0, 0),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        decoration: BoxDecoration(
          color: theme.colorScheme.primary,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: theme.colorScheme.primary.withValues(alpha: 0.3),
              blurRadius: 9,
              offset: const Offset(0, 3),
              spreadRadius: 0,
            ),
          ],
        ),
        child: Row(
          children: [
            // Back button
            IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: onBackPressed ?? () => context.pop(),
              tooltip: 'Voltar',
            ),
            const SizedBox(width: 4),
            // Icon with background
            Semantics(
              label: semanticLabel ?? title,
              hint: semanticHint,
              child: Container(
                padding: const EdgeInsets.all(9),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Icon(
                  icon,
                  color: Colors.white,
                  size: 19,
                ),
              ),
            ),
            const SizedBox(width: 13),
            // Title and subtitle
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  SemanticText.heading(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 3),
                  SemanticText.subtitle(
                    subtitle,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                      height: 1.2,
                    ),
                  ),
                ],
              ),
            ),
            // Optional action button
            if (actionButton != null) actionButton!,
          ],
        ),
      ),
    );
  }
}
