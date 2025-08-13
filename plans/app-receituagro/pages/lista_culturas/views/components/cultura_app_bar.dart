// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:icons_plus/icons_plus.dart';

// Project imports:
import '../../../../widgets/modern_header_widget.dart';

class CulturaAppBar extends StatelessWidget implements PreferredSizeWidget {
  final bool isDark;
  final bool isAscending;
  final VoidCallback onToggleSort;
  final VoidCallback onBackPressed;

  const CulturaAppBar({
    super.key,
    required this.isDark,
    required this.isAscending,
    required this.onToggleSort,
    required this.onBackPressed,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      toolbarHeight: 65,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      elevation: 0,
      flexibleSpace: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: ModernHeaderWidget(
            title: 'Culturas',
            subtitle: 'Plantas cultivadas e sua fitossanidade',
            leftIcon: FontAwesome.wheat_awn_solid,
            rightIcon: isAscending ? Icons.arrow_upward : Icons.arrow_downward,
            onRightIconPressed: onToggleSort,
            showBackButton: true,
            showActions: true,
            onBackPressed: onBackPressed,
            isDark: isDark,
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(65);
}
