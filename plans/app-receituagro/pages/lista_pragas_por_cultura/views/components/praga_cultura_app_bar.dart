// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:icons_plus/icons_plus.dart';

// Project imports:
import '../../../../widgets/modern_header_widget.dart';
import '../../utils/praga_cultura_utils.dart';

class PragaCulturaAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String culturaNome;
  final int totalRegistros;
  final bool isDark;
  final VoidCallback onBackPressed;

  const PragaCulturaAppBar({
    super.key,
    required this.culturaNome,
    required this.totalRegistros,
    required this.isDark,
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
            title: culturaNome,
            subtitle: PragaCulturaUtils.formatSubtitle(totalRegistros),
            leftIcon: FontAwesome.seedling_solid,
            showBackButton: true,
            showActions: false,
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
