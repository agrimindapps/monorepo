// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../../../widgets/modern_header_widget.dart';
import '../../utils/praga_utils.dart';

class PragaAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String pragaType;
  final int totalRegistros;
  final bool isDark;
  final bool isAscending;
  final VoidCallback onToggleSort;
  final VoidCallback onBackPressed;

  const PragaAppBar({
    super.key,
    required this.pragaType,
    required this.totalRegistros,
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
            title: PragaUtils.getTitle(pragaType),
            subtitle: PragaUtils.getSubtitle(totalRegistros, pragaType),
            leftIcon: PragaUtils.getIconForPragaType(pragaType),
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
