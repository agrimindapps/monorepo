// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../styles/consulta_page_styles.dart';

class EmptyState extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final String? actionLabel;
  final VoidCallback? onAction;

  const EmptyState({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: ConsultaPageStyles.pagePadding,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: ConsultaPageStyles.largeIconSize * 3,
              color: ConsultaPageStyles.textSecondaryColor,
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: ConsultaPageStyles.titleStyle,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: ConsultaPageStyles.bodyStyle.copyWith(
                color: ConsultaPageStyles.textSecondaryColor,
              ),
              textAlign: TextAlign.center,
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: onAction,
                style: ConsultaPageStyles.primaryButtonStyle,
                child: Text(actionLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
