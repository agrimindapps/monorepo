import 'dart:math';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../centipede_game.dart';
import 'mushroom.dart';

/// Direction the centipede is moving
enum CentipedeDirection { left, right }

/// A segment of the centipede
class CentipedeSegment extends PositionComponent with CollisionCallbacks {
  final double cellSize;
  final bool isHead;
  int health = 1;
  
  // Visual animation
  double _animTime = 0;
  final double _animSpeed = 8.0;
  
  CentipedeSegment({
    required Vector2 position,
    required this.cellSize,
    this.isHead = false,
  }) : super(
    position: position,
    size: Vector2.all(cellSize * 0.9),
    anchor: Anchor.center,
  );

  @override
  Future<void> onLoad() async {
    add(CircleHitbox());
  }

  @override
  void update(double dt) {
    super.update(dt);
    _animTime += dt * _animSpeed;
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    
    final paint = Paint();
    
    // Body color - green with animation
    final hue = (120 + sin(_animTime) * 20).toDouble();
    paint.color = HSVColor.fromAHSV(1.0, hue, 0.8, 0.9).toColor();
    
    // Draw body circle
    canvas.drawCircle(
      Offset(size.x / 2, size.y / 2),
      size.x / 2,
      paint,
    );
    
    // Darker outline
    paint.color = const Color(0xFF004400);
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 2;
    canvas.drawCircle(
      Offset(size.x / 2, size.y / 2),
      size.x / 2,
      paint,
    );
    
    // Head features
    if (isHead) {
      paint.style = PaintingStyle.fill;
      
      // Eyes
      paint.color = Colors.white;
      canvas.drawCircle(
        Offset(size.x * 0.3, size.y * 0.35),
        size.x * 0.15,
        paint,
      );
      canvas.drawCircle(
        Offset(size.x * 0.7, size.y * 0.35),
        size.x * 0.15,
        paint,
      );
      
      // Pupils
      paint.color = Colors.black;
      canvas.drawCircle(
        Offset(size.x * 0.32, size.y * 0.35),
        size.x * 0.08,
        paint,
      );
      canvas.drawCircle(
        Offset(size.x * 0.72, size.y * 0.35),
        size.x * 0.08,
        paint,
      );
      
      // Antennae
      paint.color = const Color(0xFF00AA00);
      paint.style = PaintingStyle.stroke;
      paint.strokeWidth = 2;
      
      final path1 = Path();
      path1.moveTo(size.x * 0.3, 0);
      path1.quadraticBezierTo(size.x * 0.2, -size.y * 0.3, size.x * 0.1, -size.y * 0.2);
      canvas.drawPath(path1, paint);
      
      final path2 = Path();
      path2.moveTo(size.x * 0.7, 0);
      path2.quadraticBezierTo(size.x * 0.8, -size.y * 0.3, size.x * 0.9, -size.y * 0.2);
      canvas.drawPath(path2, paint);
    } else {
      // Body segment pattern
      paint.style = PaintingStyle.fill;
      paint.color = const Color(0xFF006600);
      canvas.drawCircle(
        Offset(size.x / 2, size.y / 2),
        size.x * 0.25,
        paint,
      );
    }
  }

  void takeDamage() {
    health--;
  }

  bool get isDead => health <= 0;
}

/// The complete centipede with multiple segments
class Centipede extends Component {
  final Vector2 startPosition;
  final int segmentCount;
  final double cellSize;
  final CentipedeGame gameRef;
  
  List<CentipedeSegment> segments = [];
  CentipedeDirection direction = CentipedeDirection.right;
  
  // Movement
  double moveSpeed = 80.0;
  double _moveTimer = 0;
  final double _moveInterval = 0.05;
  bool _isDescending = false;
  double _descendTarget = 0;
  
  Centipede({
    required this.startPosition,
    required this.segmentCount,
    required this.cellSize,
    required this.gameRef,
  });

  @override
  Future<void> onLoad() async {
    // Create segments in a line
    for (int i = 0; i < segmentCount; i++) {
      final segment = CentipedeSegment(
        position: startPosition - Vector2(i * cellSize, 0),
        cellSize: cellSize,
        isHead: i == 0,
      );
      segments.add(segment);
      gameRef.add(segment);
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    
    if (segments.isEmpty) return;
    
    _moveTimer += dt;
    if (_moveTimer >= _moveInterval) {
      _moveTimer = 0;
      _moveSegments();
    }
    
    // Check collision with player
    _checkPlayerCollision();
  }

  void _moveSegments() {
    if (segments.isEmpty) return;
    
    final head = segments.first;
    Vector2 targetPosition;
    
    if (_isDescending) {
      // Move down
      targetPosition = head.position + Vector2(0, cellSize * 0.5);
      
      if (head.position.y >= _descendTarget) {
        _isDescending = false;
        // Reverse direction after descending
        direction = direction == CentipedeDirection.right 
            ? CentipedeDirection.left 
            : CentipedeDirection.right;
      }
    } else {
      // Move horizontally
      final moveX = direction == CentipedeDirection.right ? moveSpeed * _moveInterval : -moveSpeed * _moveInterval;
      targetPosition = head.position + Vector2(moveX, 0);
      
      // Check for wall collision or mushroom
      bool shouldDescend = false;
      
      // Wall check
      if (targetPosition.x <= cellSize || targetPosition.x >= gameRef.size.x - cellSize) {
        shouldDescend = true;
      }
      
      // Mushroom check
      final mushroom = gameRef.getMushroomAt(targetPosition);
      if (mushroom != null) {
        shouldDescend = true;
      }
      
      if (shouldDescend) {
        _isDescending = true;
        _descendTarget = head.position.y + cellSize;
        return;
      }
    }
    
    // Move each segment to the position of the one in front of it
    Vector2? previousPosition;
    for (int i = 0; i < segments.length; i++) {
      final segment = segments[i];
      final oldPosition = segment.position.clone();
      
      if (i == 0) {
        segment.position = targetPosition;
      } else if (previousPosition != null) {
        // Follow the segment in front
        final diff = previousPosition - segment.position;
        if (diff.length > cellSize * 0.8) {
          segment.position += diff.normalized() * cellSize * 0.3;
        }
      }
      
      previousPosition = oldPosition;
    }
  }

  void _checkPlayerCollision() {
    for (final segment in segments) {
      if ((segment.position - gameRef.player.position).length < cellSize) {
        gameRef.playerHit();
        break;
      }
    }
  }

  /// Hit a segment and potentially split the centipede
  void hitSegment(int index) {
    if (index < 0 || index >= segments.length) return;
    
    final segment = segments[index];
    segment.takeDamage();
    
    if (segment.isDead) {
      // Create mushroom where segment died
      final mushroom = Mushroom(
        position: segment.position.clone(),
        cellSize: cellSize,
      );
      gameRef.mushrooms.add(mushroom);
      gameRef.add(mushroom);
      
      // Remove segment
      segment.removeFromParent();
      segments.removeAt(index);
      
      // Add score
      gameRef.addScore(segment.isHead ? 100 : 10);
      
      // If we hit a middle segment, split the centipede
      if (index > 0 && index < segments.length) {
        gameRef.splitCentipede(this, index);
      }
    }
  }

  /// Split this centipede at the given index, returning a new centipede
  Centipede? splitAt(int index) {
    if (index <= 0 || index >= segments.length) return null;
    
    // Get segments for new centipede
    final newSegments = segments.sublist(index);
    segments = segments.sublist(0, index);
    
    // Make first segment of new centipede a head
    if (newSegments.isNotEmpty) {
      final newCentipede = Centipede(
        startPosition: newSegments.first.position,
        segmentCount: 0, // We'll manually add segments
        cellSize: cellSize,
        gameRef: gameRef,
      );
      newCentipede.segments = newSegments;
      newCentipede.direction = direction == CentipedeDirection.right 
          ? CentipedeDirection.left 
          : CentipedeDirection.right;
      
      return newCentipede;
    }
    
    return null;
  }

  bool get isFullyDestroyed => segments.isEmpty;

  @override
  void onRemove() {
    // Clean up all segments
    for (final segment in segments) {
      segment.removeFromParent();
    }
    super.onRemove();
  }
}
