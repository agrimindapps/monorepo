// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:get/get.dart';

// Project imports:
import '../../core/themes/manager.dart';

class GasometerHeaderWidget extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData icon;
  final List<Widget>? actions;
  final bool showBackButton;
  final VoidCallback? onBackPressed;
  final EdgeInsetsGeometry? outerPadding;

  const GasometerHeaderWidget({
    super.key,
    required this.title,
    this.subtitle,
    required this.icon,
    this.actions,
    this.showBackButton = false,
    this.onBackPressed,
    this.outerPadding,
  });

  @override
  Widget build(BuildContext context) {
    final padding = outerPadding ??
        const EdgeInsets.fromLTRB(
          8,
          0,
          8,
          8,
        );

    return PreferredSize(
      preferredSize: const Size.fromHeight(72),
      child: Padding(
        padding: padding,
        child: Obx(() {
          final isDark = ThemeManager().isDark.value;

          return Container(
            height: 72,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDark
                    ? [
                        const Color(0xFF2A2A2A),
                        const Color(0xFF1A1A1A),
                      ]
                    : [
                        Colors.grey.shade800,
                        Colors.grey.shade900,
                      ],
              ),
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: isDark ? Colors.black26 : Colors.grey.shade400,
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(6),
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
                            icon,
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
                      // Adaptar IconButtons para o tema escuro
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
          );
        }),
      ),
    );
  }
}
