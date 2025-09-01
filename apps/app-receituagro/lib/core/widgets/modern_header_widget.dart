import 'package:flutter/material.dart';

class ModernHeaderWidget extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData leftIcon;
  final IconData? rightIcon;
  final VoidCallback? onRightIconPressed;
  final VoidCallback? onBackPressed;
  final bool showBackButton;
  final bool showActions;
  final bool isDark;
  final List<Widget>? additionalActions;

  const ModernHeaderWidget({
    super.key,
    required this.title,
    required this.subtitle,
    required this.leftIcon,
    this.rightIcon,
    this.onRightIconPressed,
    this.onBackPressed,
    this.showBackButton = false,
    this.showActions = false,
    required this.isDark,
    this.additionalActions,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(8, 6, 8, 4),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  const Color(0xFF2E7D32),
                  const Color(0xFF1B5E20),
                ]
              : [
                  const Color(0xFF4CAF50),
                  const Color(0xFF388E3C),
                ],
        ),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withValues(alpha: 0.2),
            blurRadius: 9,
            offset: const Offset(0, 3),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Row(
        children: [
          if (showBackButton)
            GestureDetector(
              onTap: onBackPressed,
              child: Container(
                padding: const EdgeInsets.all(9),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: const Icon(
                  Icons.arrow_back_ios_outlined,
                  color: Colors.white,
                  size: 17,
                ),
              ),
            )
          else
            Container(
              padding: const EdgeInsets.all(9),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(9),
              ),
              child: Icon(
                leftIcon,
                color: Colors.white,
                size: 19,
              ),
            ),

          const SizedBox(width: 13),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    height: 1.2,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 13,
                    height: 1.3,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          if (showActions) ...[
            const SizedBox(width: 13),

            if (additionalActions != null) ...[
              ...additionalActions!.map((action) => Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(9),
                      ),
                      child: action,
                    ),
                  )),
            ],

            if (rightIcon != null || onRightIconPressed != null)
              GestureDetector(
                onTap: onRightIconPressed,
                child: Container(
                  padding: const EdgeInsets.all(9),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: Icon(
                    rightIcon ?? Icons.more_vert,
                    color: Colors.white,
                    size: 17,
                  ),
                ),
              ),
          ],
        ],
      ),
    );
  }
}