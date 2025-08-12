// Flutter imports:
import 'package:flutter/material.dart';

class CustomLocalAppBarVet extends StatelessWidget
    implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;

  const CustomLocalAppBarVet({
    super.key,
    required this.title,
    this.actions,
  });

  @override
  Size get preferredSize => const Size.fromHeight(60);

  @override
  Widget build(BuildContext context) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(60),
      child: Container(
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: Color.fromRGBO(213, 213, 213, 1),
              width: 0.5,
            ),
          ),
        ),
        child: AppBar(
          titleSpacing: 0,
          toolbarHeight: 60,
          leadingWidth: 80,
          centerTitle: true,
          automaticallyImplyLeading: false,
          leading: InkWell(
            onTap: () => Navigator.of(context).pop(),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(width: 8),
                Icon(
                  Icons.arrow_back_ios,
                  size: 18,
                  color: Colors.black54,
                ),
                Text(
                  'Voltar',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.black54,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          backgroundColor: Colors.white.withValues(alpha: 0.7),
          title: Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black,
            ),
          ),
          actions: actions,
        ),
      ),
    );
  }
}
