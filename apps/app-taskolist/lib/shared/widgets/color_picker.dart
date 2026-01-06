import 'package:flutter/material.dart';

import '../constants/task_list_colors.dart';

/// Widget para selecionar cor da lista
/// Exibe um grid de círculos coloridos
class ColorPicker extends StatelessWidget {
  final String selectedColor;
  final ValueChanged<String> onColorSelected;

  const ColorPicker({
    super.key,
    required this.selectedColor,
    required this.onColorSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: TaskListColors.options.map((colorOption) {
        final isSelected = colorOption.value == selectedColor;

        return GestureDetector(
          onTap: () => onColorSelected(colorOption.value),
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: colorOption.color,
              shape: BoxShape.circle,
              border: isSelected
                  ? Border.all(
                      color: Theme.of(context).colorScheme.primary,
                      width: 3,
                    )
                  : null,
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: colorOption.color.withValues(alpha: 0.4),
                        blurRadius: 8,
                        spreadRadius: 2,
                      ),
                    ]
                  : null,
            ),
            child: isSelected
                ? const Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 24,
                  )
                : null,
          ),
        );
      }).toList(),
    );
  }
}
