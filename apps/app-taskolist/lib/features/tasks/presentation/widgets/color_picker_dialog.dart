import 'package:flutter/material.dart';
import '../../../../core/theme/list_colors.dart';

class ColorPickerDialog extends StatelessWidget {
  final String selectedColorKey;
  final Function(String) onColorSelected;

  const ColorPickerDialog({
    super.key,
    required this.selectedColorKey,
    required this.onColorSelected,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Escolher Cor'),
      content: SizedBox(
        width: 300,
        child: GridView.builder(
          shrinkWrap: true,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemCount: ListColors.availableColors.length,
          itemBuilder: (context, index) {
            final colorEntry = ListColors.availableColors[index];
            final isSelected = colorEntry.key == selectedColorKey;

            return InkWell(
              onTap: () {
                onColorSelected(colorEntry.key);
                Navigator.pop(context);
              },
              borderRadius: BorderRadius.circular(24),
              child: Container(
                decoration: BoxDecoration(
                  color: colorEntry.value,
                  shape: BoxShape.circle,
                  border: isSelected
                      ? Border.all(color: Colors.white, width: 3)
                      : null,
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: colorEntry.value.withOpacity(0.5),
                            blurRadius: 8,
                            spreadRadius: 2,
                          )
                        ]
                      : null,
                ),
                child: isSelected
                    ? const Icon(Icons.check, color: Colors.white, size: 28)
                    : null,
              ),
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
      ],
    );
  }
}
