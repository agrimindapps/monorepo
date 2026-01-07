import 'dart:math';
import 'package:flame/components.dart';
import 'enemy.dart';

class EnemyManager extends Component {
  final Vector2 screenSize;
  final int wave;
  
  List<GalagaEnemy> enemies = [];
  double formationOffsetX = 0;
  double formationDirection = 1;
  double formationSpeed = 30;
  
  EnemyManager({
    required this.screenSize,
    required this.wave,
  });
  
  bool get allEnemiesDefeated => enemies.isEmpty || enemies.every((e) => e.isRemoved);
  
  @override
  Future<void> onLoad() async {
    await super.onLoad();
    _createFormation();
  }
  
  void _createFormation() {
    final rows = 4 + (wave ~/ 2).clamp(0, 2);
    final cols = 8;
    final startX = (screenSize.x - cols * 40) / 2;
    final startY = 80;
    
    final Random random = Random();
    
    for (int row = 0; row < rows; row++) {
      for (int col = 0; col < cols; col++) {
        EnemyType type;
        if (row == 0) {
          type = EnemyType.diver;
        } else if (row == 1) {
          type = EnemyType.shooter;
        } else {
          type = EnemyType.basic;
        }
        
        final formationX = startX + col * 40.0 + 20.0;
        final formationY = startY + row * 36.0;
        
        // Start from outside screen with delay
        final delay = (row * cols + col) * 0.1;
        final startX2 = screenSize.x / 2 + (random.nextDouble() - 0.5) * 200;
        
        final enemy = GalagaEnemy(
          type: type,
          row: row,
          col: col,
          formationX: formationX,
          formationY: formationY,
          position: Vector2(startX2, -50 - delay.toDouble() * 50),
        );
        
        enemies.add(enemy);
        add(enemy);
      }
    }
  }
  
  @override
  void update(double dt) {
    super.update(dt);
    
    // Move formation left and right
    formationOffsetX += formationDirection * formationSpeed * dt;
    
    if (formationOffsetX > 30 || formationOffsetX < -30) {
      formationDirection *= -1;
    }
    
    // Update enemy formation positions
    for (final enemy in enemies) {
      if (enemy.isInFormation && !enemy.isDiving && !enemy.isRemoved) {
        enemy.position.x = enemy.formationX + formationOffsetX;
      }
    }
    
    // Remove dead enemies from list
    enemies.removeWhere((e) => e.isRemoved);
  }
}
