// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:icons_plus/icons_plus.dart';

// Project imports:
import '../../models/cultura_model.dart';

class CulturaListItem extends StatelessWidget {
  final CulturaModel cultura;
  final bool isDark;
  final VoidCallback onTap;
  final int index;

  const CulturaListItem({
    super.key,
    required this.cultura,
    required this.isDark,
    required this.onTap,
    this.index = 0,
  });


  @override
  Widget build(BuildContext context) {
    final avatarColor =
        isDark ? Colors.green.withValues(alpha: 0.2) : Colors.green.shade50;
    const culturaIcon = FontAwesome.seedling_solid;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: ListTile(
          contentPadding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
          leading: Container(
            width: 45,
            height: 45,
            decoration: BoxDecoration(
              color: avatarColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDark
                    ? Colors.green.shade800.withValues(alpha: 0.3)
                    : Colors.green.shade200,
                width: 1,
              ),
            ),
            child: Icon(
              culturaIcon,
              color: isDark
                  ? Colors.green.shade300
                  : Colors.green.shade700,
              size: 18,
            ),
          ),
          title: Text(
            cultura.cultura,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: isDark
                  ? Colors.grey.shade300
                  : Colors.grey.shade800,
            ),
          ),
          trailing: Icon(
            Icons.arrow_forward_ios,
            size: 14,
            color: isDark
                ? Colors.grey.shade600
                : Colors.grey.shade400,
          ),
        ),
      ),
    );
  }
}
