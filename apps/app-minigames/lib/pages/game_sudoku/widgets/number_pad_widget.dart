// Flutter imports:
import 'package:flutter/material.dart';

class NumberPadWidget extends StatelessWidget {
  final Function(int) onNumberSelected;
  final bool isNoteMode;

  const NumberPadWidget({
    super.key,
    required this.onNumberSelected,
    required this.isNoteMode,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 9,
          childAspectRatio: 1.0,
          crossAxisSpacing: 4.0,
          mainAxisSpacing: 4.0,
        ),
        itemCount: 9,
        itemBuilder: (context, index) {
          final number = index + 1;
          return InkWell(
            onTap: () => onNumberSelected(number),
            child: Container(
              decoration: BoxDecoration(
                color: isNoteMode
                    ? Colors.amber.withValues(alpha: 0.2)
                    : Colors.white,
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(4.0),
              ),
              child: Center(
                child: Text(
                  number.toString(),
                  style: const TextStyle(fontSize: 20),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
