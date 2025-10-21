// Project imports:
import 'package:app_minigames/constants/enums.dart';
import 'position.dart';

/**
 * Classe que representa uma comida no jogo da cobra
 * 
 * Suporta diferentes tipos de comida com propriedades e efeitos únicos:
 * - Normal: Comida padrão (+1 ponto)
 * - Golden: Comida dourada (+2 pontos)
 * - Speed: Acelera temporariamente o jogo
 * - Shrink: Diminui o tamanho da cobra
 */
class Food {
  final Position position;
  final FoodType type;
  final DateTime createdAt;

  Food({
    required this.position,
    required this.type,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  /// Cria uma comida normal na posição especificada
  Food.normal(Position position) : this(
    position: position,
    type: FoodType.normal,
  );

  /// Cria uma comida dourada na posição especificada
  Food.golden(Position position) : this(
    position: position,
    type: FoodType.golden,
  );

  /// Cria uma comida de velocidade na posição especificada
  Food.speed(Position position) : this(
    position: position,
    type: FoodType.speed,
  );

  /// Cria uma comida que encolhe a cobra na posição especificada
  Food.shrink(Position position) : this(
    position: position,
    type: FoodType.shrink,
  );

  /// Gera um tipo de comida aleatório baseado nas probabilidades
  static FoodType generateRandomType() {
    final random = DateTime.now().millisecondsSinceEpoch % 1000 / 1000.0;
    double cumulativeProbability = 0.0;

    for (final foodType in FoodType.values) {
      cumulativeProbability += foodType.spawnProbability;
      if (random <= cumulativeProbability) {
        return foodType;
      }
    }

    // Fallback para comida normal
    return FoodType.normal;
  }

  /// Cria uma comida com tipo aleatório na posição especificada
  factory Food.random(Position position) {
    return Food(
      position: position,
      type: generateRandomType(),
    );
  }

  /// Retorna true se a comida tem efeito temporário
  bool get hasTemporaryEffect => type.effectDuration > Duration.zero;

  /// Retorna true se a comida tem efeito instantâneo
  bool get hasInstantEffect => type == FoodType.shrink;

  /// Retorna os pontos que esta comida vale
  int get points => type.points;

  /// Retorna a duração do efeito (se houver)
  Duration get effectDuration => type.effectDuration;

  /// Retorna true se duas comidas são iguais
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Food && 
           other.position == position && 
           other.type == type;
  }

  @override
  int get hashCode => Object.hash(position, type);

  @override
  String toString() => 'Food(position: $position, type: ${type.label})';
}
