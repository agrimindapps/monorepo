// Flutter imports:
import 'package:flutter/material.dart';

class SudokuCellWidget extends StatelessWidget {
  final int value;
  final bool isSelected;
  final bool isEditable;
  final bool hasConflict;
  final Set<int> notes;
  final VoidCallback onTap;
  final Color borderColor;
  final double borderWidth;

  const SudokuCellWidget({
    super.key,
    required this.value,
    required this.isSelected,
    required this.isEditable,
    required this.hasConflict,
    required this.notes,
    required this.onTap,
    required this.borderColor,
    required this.borderWidth,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: _getCellColor(),
          border: Border.all(
            color: borderColor,
            width: borderWidth,
          ),
        ),
        child: Stack(
          children: [
            // Número principal
            if (value != 0)
              Center(
                child: Text(
                  value.toString(),
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight:
                        isEditable ? FontWeight.normal : FontWeight.bold,
                    color: isEditable ? Colors.blue[800] : Colors.black87,
                  ),
                ),
              ),

            // Anotações (quando não há número principal)
            if (value == 0 && notes.isNotEmpty)
              Positioned.fill(
                child: GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    childAspectRatio: 1.0,
                  ),
                  itemCount: 9,
                  itemBuilder: (context, index) {
                    final noteNum = index + 1;
                    return Center(
                      child: notes.contains(noteNum)
                          ? Text(
                              noteNum.toString(),
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.grey[700],
                              ),
                            )
                          : null,
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  Color _getCellColor() {
    if (hasConflict) {
      return Colors.red.withValues(alpha: 0.3);
    } else if (isSelected) {
      return Colors.blue.withValues(alpha: 0.3);
    } else if (isEditable) {
      return Colors.white;
    } else {
      return Colors.grey[200]!;
    }
  }
}
