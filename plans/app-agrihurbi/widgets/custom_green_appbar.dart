// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../theme/agrihurbi_theme.dart';

class CustomGreenAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final String? subtitle;
  final IconData? leadingIcon;
  final List<Widget>? actions;
  final bool showBackButton;
  final VoidCallback? onBackPressed;
  final EdgeInsetsGeometry? outerPadding;

  const CustomGreenAppBar({
    super.key,
    required this.title,
    this.subtitle,
    this.leadingIcon,
    this.actions,
    this.showBackButton = true,
    this.onBackPressed,
    this.outerPadding,
  });

  @override
  Size get preferredSize => const Size.fromHeight(88);

  @override
  Widget build(BuildContext context) {
    final padding = outerPadding ??
        const EdgeInsets.fromLTRB(
          8,
          8,
          8,
          8,
        );

    return PreferredSize(
      preferredSize: const Size.fromHeight(88),
      child: SafeArea(
        child: Padding(
          padding: padding,
          child: Container(
            height: 72,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: AgrihurbiTheme.primaryGradient,
              borderRadius: AgrihurbiTheme.radiusLarge,
              boxShadow: AgrihurbiTheme.shadowMedium,
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: AgrihurbiTheme.radiusSmall,
                  ),
                  child: showBackButton
                      ? IconButton(
                          onPressed: onBackPressed ??
                              () => Navigator.of(context).pop(),
                          style: IconButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: const Size(18, 18),
                            maximumSize: const Size(18, 18),
                          ),
                          icon: const Icon(
                            Icons.arrow_back_ios,
                            color: Colors.white,
                            size: 16,
                          ),
                          tooltip: 'Voltar',
                        )
                      : Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: Icon(
                            leadingIcon ?? Icons.water_drop,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (subtitle != null && subtitle!.isNotEmpty) ...[
                        const SizedBox(height: 1),
                        Text(
                          subtitle!,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white.withValues(alpha: 0.8),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
                if (actions != null && actions!.isNotEmpty) ...[
                  const SizedBox(width: 10),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: actions!.map((action) {
                      if (action is IconButton) {
                        return IconButton(
                          icon: action.icon,
                          onPressed: action.onPressed,
                          tooltip: action.tooltip,
                          style: IconButton.styleFrom(
                            backgroundColor:
                                Colors.white.withValues(alpha: 0.2),
                            padding: const EdgeInsets.all(0),
                          ),
                          iconSize: 18,
                        );
                      }
                      return action;
                    }).toList(),
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
