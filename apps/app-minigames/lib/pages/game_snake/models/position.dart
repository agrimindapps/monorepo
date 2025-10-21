// Importa a enum Direction

// Project imports:
import 'package:app_minigames/constants/enums.dart';

/**
 * ✅ FIXED: Operação módulo com números negativos corrigida com _safeModulo
 * 
 * ✅ FIXED: Método getNewPosition agora trata bordas corretamente com wrap-around seguro
 * 
 * ✅ IMPLEMENTED: Operadores de igualdade (== e hashCode) implementados
 * 
 * TODO (prioridade: BAIXA): Adicionar método para calcular distância entre 
 * posições
 * 
 * REFACTOR (prioridade: MÉDIA): Tornar classe imutável com @immutable
 * 
 * REFACTOR (prioridade: BAIXA): Adicionar factory constructors para 
 * posições especiais (centro, cantos)
 * 
 * OPTIMIZE (prioridade: BAIXA): Usar const constructor para melhor 
 * performance
 * 
 * TEST (prioridade: ALTA): Adicionar testes para casos extremos de 
 * movimento nas bordas
 */

// Classe para representar uma posição no grid
class Position {
  final int x;
  final int y;

  const Position(this.x, this.y);

  // Verifica se duas posições são iguais
  bool isEqual(Position other) {
    return x == other.x && y == other.y;
  }
  
  // Implementação dos operadores padrão do Dart
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Position && other.x == x && other.y == y;
  }
  
  @override
  int get hashCode => Object.hash(x, y);

  // Cria uma nova posição baseada na direção com wrap-around seguro
  Position getNewPosition(Direction direction, int gridSize) {
    // Validação de entrada
    if (gridSize <= 0) {
      throw ArgumentError('gridSize deve ser maior que 0');
    }
    
    switch (direction) {
      case Direction.up:
        return Position(x, _safeModulo(y - 1, gridSize));
      case Direction.down:
        return Position(x, _safeModulo(y + 1, gridSize));
      case Direction.left:
        return Position(_safeModulo(x - 1, gridSize), y);
      case Direction.right:
        return Position(_safeModulo(x + 1, gridSize), y);
    }
  }
  
  // Método auxiliar para garantir módulo seguro com números negativos
  int _safeModulo(int value, int modulus) {
    return ((value % modulus) + modulus) % modulus;
  }

  @override
  String toString() => '($x, $y)';
}
