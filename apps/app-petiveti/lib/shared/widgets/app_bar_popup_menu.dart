import 'package:flutter/material.dart';

/// Menu item model for PopupMenu
class MenuOption {
  final String value;
  final String label;
  final String? semanticLabel;
  final String? semanticHint;
  final IconData icon;
  final VoidCallback onSelected;

  const MenuOption({
    required this.value,
    required this.label,
    required this.icon,
    required this.onSelected,
    this.semanticLabel,
    this.semanticHint,
  });
}

/// Reusable popup menu component
///
/// **SRP**: Única responsabilidade de menu popup configurável
class AppBarPopupMenu extends StatelessWidget {
  final List<MenuOption> options;
  final String semanticLabel;
  final String semanticHint;

  const AppBarPopupMenu({
    super.key,
    required this.options,
    this.semanticLabel = 'Menu de opções',
    this.semanticHint = 'Abre menu com opções adicionais',
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticLabel,
      hint: semanticHint,
      button: true,
      child: PopupMenuButton<String>(
        onSelected: (value) {
          final option = options.firstWhere((o) => o.value == value);
          option.onSelected();
        },
        itemBuilder: (context) => options.map((option) {
          return PopupMenuItem(
            value: option.value,
            child: Semantics(
              label: option.semanticLabel ?? option.label,
              hint: option.semanticHint,
              button: true,
              child: Row(
                children: [
                  Icon(option.icon),
                  const SizedBox(width: 8),
                  Text(option.label),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
