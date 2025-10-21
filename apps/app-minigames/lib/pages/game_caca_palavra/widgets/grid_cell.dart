// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:app_minigames/constants/enums.dart';

class GridCellWidget extends StatelessWidget {
  final String letter;
  final int row;
  final int col;
  final bool isSelected;
  final bool isFoundWord;
  final VoidCallback onTap;

  const GridCellWidget({
    super.key,
    required this.letter,
    required this.row,
    required this.col,
    required this.isSelected,
    required this.isFoundWord,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: _getCellColor(),
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(4),
        ),
        alignment: Alignment.center,
        child: Text(
          letter,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: isFoundWord ? Colors.white : Colors.black87,
          ),
        ),
      ),
    );
  }

  // Determina a cor da célula com base no estado
  Color _getCellColor() {
    if (isFoundWord) {
      return GameColors.foundWord;
    } else if (isSelected) {
      return GameColors.selectedLetter;
    }
    return GameColors.gridBackground;
  }
}
