// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:get/get.dart';

// Project imports:
import '../../core/themes/manager.dart';

class PageHeaderWidget extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final String? subtitle;
  final IconData icon;
  final List<Widget>? actions;
  final bool showBackButton;
  final VoidCallback? onBackPressed;
  final EdgeInsetsGeometry? outerPadding;

  const PageHeaderWidget({
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
  Size get preferredSize => const Size.fromHeight(72);

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
                        Colors.purple.shade800,
                        Colors.purple.shade900,
                      ]
                    : [
                        Colors.purple.shade700,
                        Colors.purple.shade800,
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
                  height: 36,
                  width: 36,
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: showBackButton
                      ? Padding(
                          padding: const EdgeInsets.fromLTRB(8, 0, 4, 0),
                          child: IconButton(
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
                          ),
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

class CustomLocalAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool centerTitle;
  final List<Widget>? actions;

  const CustomLocalAppBar({
    super.key,
    required this.title,
    this.centerTitle = true,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      centerTitle: centerTitle,
      title: Text(title),
      actions: actions,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class ContentCardWidget extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;

  const ContentCardWidget({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.margin = const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isDark = ThemeManager().isDark.value;

      return Container(
        margin: margin,
        padding: padding,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF222228) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(8), // 0.03 * 255 ≈ 8
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: child,
      );
    });
  }
}
