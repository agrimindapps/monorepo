// Flutter imports:
import 'package:flutter/material.dart';

class OptionsGrid extends StatelessWidget {
  final List<String> options;
  final Function(String) onOptionSelected;

  const OptionsGrid({
    super.key,
    required this.options,
    required this.onOptionSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      alignment: WrapAlignment.center,
      children: options.map((option) {
        return SizedBox(
          width: 200,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.all(16),
              backgroundColor: Colors.blue,
            ),
            onPressed: () => onOptionSelected(option),
            child: Text(
              option,
              style: const TextStyle(fontSize: 18),
            ),
          ),
        );
      }).toList(),
    );
  }
}
