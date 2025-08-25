// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../../../../core/style/shadcn_style.dart';
import '../../../../../core/themes/manager.dart';

class InfoCardWidget extends StatelessWidget {
  final String title;
  final String description;
  final String? additionalInfo;
  final Color? backgroundColor;
  final Color? borderColor;
  final Color? iconColor;
  final IconData icon;
  final bool visible;
  final VoidCallback onClose;

  const InfoCardWidget({
    super.key,
    required this.title,
    required this.description,
    this.additionalInfo,
    this.backgroundColor,
    this.borderColor,
    this.iconColor,
    this.icon = Icons.info_outline,
    required this.visible,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = ThemeManager().isDark.value;
    final defaultBackgroundColor = isDark
        ? Colors.blue.shade900.withValues(alpha: 0.2)
        : Colors.blue.shade50;
    final defaultBorderColor = isDark
        ? Colors.blue.shade800.withValues(alpha: 0.3)
        : Colors.blue.shade200;
    final defaultIconColor =
        isDark ? Colors.blue.shade300 : Colors.blue.shade700;

    return Visibility(
      visible: visible,
      child: Card(
        clipBehavior: Clip.antiAliasWithSaveLayer,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: backgroundColor ?? defaultBackgroundColor,
            border: Border.all(
              color: borderColor ?? defaultBorderColor,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      icon,
                      color: iconColor ?? defaultIconColor,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: ShadcnStyle.textColor,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.close,
                        color: ShadcnStyle.mutedTextColor,
                        size: 20,
                      ),
                      onPressed: onClose,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 14,
                    color: ShadcnStyle.textColor,
                  ),
                ),
                if (additionalInfo != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    additionalInfo!,
                    style: TextStyle(
                      fontSize: 14,
                      color: ShadcnStyle.textColor,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
