// Flutter imports:
import 'package:flutter/material.dart';

class CalcAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final VoidCallback? onInfoPressed;

  const CalcAppBar({
    super.key,
    required this.title,
    this.onInfoPressed,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => Navigator.of(context).pop(),
      ),
      actions: [
        if (onInfoPressed != null)
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: onInfoPressed,
          ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
