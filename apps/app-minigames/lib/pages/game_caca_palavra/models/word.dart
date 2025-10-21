// Project imports:
import 'package:app_minigames/constants/enums.dart';
import 'position.dart';

class Word {
  final String text;
  final Direction direction;
  final List<Position> positions;
  bool isFound;
  bool isHighlighted;

  Word({
    required this.text,
    required this.direction,
    required this.positions,
    this.isFound = false,
    this.isHighlighted = false,
  });

  // Verifica se uma sequência de posições corresponde a esta palavra
  bool matchesPositions(List<Position> selectedPositions) {
    if (selectedPositions.length != positions.length) return false;

    // Verifica se ambos começam e terminam nos mesmos pontos (em qualquer direção)
    return (selectedPositions.first == positions.first &&
            selectedPositions.last == positions.last) ||
        (selectedPositions.first == positions.last &&
            selectedPositions.last == positions.first);
  }

  // Cria uma cópia da palavra com estado atualizado
  Word copyWith({
    bool? isFound,
    bool? isHighlighted,
  }) {
    return Word(
      text: text,
      direction: direction,
      positions: positions,
      isFound: isFound ?? this.isFound,
      isHighlighted: isHighlighted ?? this.isHighlighted,
    );
  }

  @override
  String toString() {
    return 'Word($text, $direction, found: $isFound)';
  }
}
