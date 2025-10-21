// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:app_minigames/core/theme/theme_providers.dart';

class PageHeaderWidget extends ConsumerWidget {
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
  Widget build(BuildContext context, WidgetRef ref) {
    // Detect if the device is mobile based on screen width
    final isMobile = MediaQuery.of(context).size.width < 600;

    // Use zero padding to eliminate any extra space contributing to overflow
    final padding = outerPadding ?? EdgeInsets.zero;

    // Watch theme state from Riverpod
    final isDark = ref.watch(themeNotifierProvider);

    return Padding(
      padding: padding,
      child: Builder(
        builder: (context) {

        return Material(
          color: isDark ? const Color(0xFF222228) : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(isMobile ? 8 : 10),
          elevation: 0,
          child: Container(
            width: double.infinity,
            constraints: const BoxConstraints(
              minHeight: kToolbarHeight,
              maxHeight: kToolbarHeight,
            ),
            padding: EdgeInsets.symmetric(
              horizontal: isMobile ? 4 : 8,
              vertical: 0,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(isMobile ? 8 : 10),
              border: Border.all(
                color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
                width: 1,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (showBackButton) ...[
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed:
                        onBackPressed ?? () => Navigator.of(context).pop(),
                    tooltip: 'Voltar',
                    style: IconButton.styleFrom(
                      backgroundColor:
                          isDark ? Colors.grey.shade800 : Colors.white,
                    ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(
                      minWidth: 32,
                      minHeight: 32,
                    ),
                    iconSize: isMobile ? 18 : 20,
                  ),
                  SizedBox(width: isMobile ? 4 : 6),
                ],
                Container(
                  padding: EdgeInsets.all(isMobile ? 6 : 8),
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.amber.withAlpha(26) // 0.1 * 255 ≈ 26
                        : Colors.green.shade50,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isDark
                          ? Colors.amber.shade800
                              .withAlpha(77) // 0.3 * 255 ≈ 77
                          : Colors.blue.shade200
                              .withAlpha(128), // 0.5 * 255 = 128
                      width: 2,
                    ),
                  ),
                  child: Icon(
                    icon,
                    size: isMobile ? 16 : 18,
                    color:
                        isDark ? Colors.amber.shade400 : Colors.blue.shade700,
                  ),
                ),
                SizedBox(width: isMobile ? 6 : 8),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        title,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: isMobile ? 14 : 16,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.grey.shade800,
                        ),
                      ),
                      if (subtitle != null && subtitle!.isNotEmpty)
                        Text(
                          subtitle!,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: isMobile ? 10 : 12,
                            color: isDark
                                ? Colors.grey.shade400
                                : Colors.grey.shade600,
                          ),
                        ),
                    ],
                  ),
                ),
                if (actions != null && actions!.isNotEmpty) ...[
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: actions!.map((action) {
                      // If the action is an IconButton, adapt it based on the device
                      if (action is IconButton) {
                        return IconButton(
                          icon: action.icon,
                          onPressed: action.onPressed,
                          tooltip: action.tooltip,
                          iconSize: isMobile ? 18 : 20,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(
                            minWidth: 32,
                            minHeight: 32,
                          ),
                        );
                      }
                      return action;
                    }).toList(),
                  ),
                ],
              ],
            ),
          ),
        );
        },
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

class ContentCardWidget extends ConsumerWidget {
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
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch theme state from Riverpod
    final isDark = ref.watch(themeNotifierProvider);

      return Container(
        width: double.infinity,
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
  }
}
