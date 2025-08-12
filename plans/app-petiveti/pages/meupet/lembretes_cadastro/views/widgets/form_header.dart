// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../styles/form_colors.dart';

class FormHeader extends StatelessWidget {
  final String title;
  final bool isLoading;
  final String? subtitle;
  final IconData? icon;

  const FormHeader({
    super.key,
    required this.title,
    this.isLoading = false,
    this.subtitle,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: LembreteFormColors.cardColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
        border: Border(
          bottom: BorderSide(
            color: LembreteFormColors.borderColor,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          if (icon != null) ...[
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: LembreteFormColors.primaryWithOpacity,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: LembreteFormColors.primaryColor,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: LembreteFormColors.textPrimary,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    subtitle!,
                    style: const TextStyle(
                      fontSize: 14,
                      color: LembreteFormColors.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (isLoading) ...[
            const SizedBox(width: 12),
            const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(
                  LembreteFormColors.primaryColor,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
