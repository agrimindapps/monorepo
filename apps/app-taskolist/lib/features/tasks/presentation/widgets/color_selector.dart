import 'package:flutter/material.dart';
import '../../../../core/theme/list_colors.dart';

class ColorSelector extends StatelessWidget {
  final String selectedColorKey;
  final Function(String) onColorSelected;
  final bool showLabel;
  final String label;

  const ColorSelector({
    super.key,
    required this.selectedColorKey,
    required this.onColorSelected,
    this.showLabel = true,
    this.label = 'Cor da Lista',
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showLabel)
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Text(
              label,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
        SizedBox(
          height: 56,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: ListColors.availableColors.length,
            itemBuilder: (context, index) {
              final colorEntry = ListColors.availableColors[index];
              final isSelected = colorEntry.key == selectedColorKey;

              return Padding(
                padding: const EdgeInsets.only(right: 12.0),
                child: InkWell(
                  onTap: () => onColorSelected(colorEntry.key),
                  borderRadius: BorderRadius.circular(28),
                  child: Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: colorEntry.value,
                      shape: BoxShape.circle,
                      border: isSelected
                          ? Border.all(color: Colors.white, width: 3)
                          : Border.all(
                              color: Colors.grey.withOpacity(0.3),
                              width: 1,
                            ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: colorEntry.value.withOpacity(0.4),
                                blurRadius: 8,
                                spreadRadius: 2,
                              )
                            ]
                          : [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              )
                            ],
                    ),
                    child: isSelected
                        ? const Icon(
                            Icons.check,
                            color: Colors.white,
                            size: 28,
                          )
                        : null,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
