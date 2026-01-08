import 'dart:async';
import 'dart:math' as math;
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame/particles.dart';
import 'package:flutter/material.dart';

import 'components/block.dart';
import 'components/background.dart';

enum TowerGameStatus {
  intro,
  playing,
  gameOver,
}

class TowerStackGame extends FlameGame with TapCallbacks {
  final VoidCallback? onGameOver;
  final ValueChanged<int>? onScoreChanged;
  final ValueChanged<int>? onComboChanged;

  TowerStackGame({
    this.onGameOver,
    this.onScoreChanged,
    this.onComboChanged,
  });

  TowerGameStatus status = TowerGameStatus.intro;
  int score = 0;
  
  // Game configuration
  final double blockHeight = 40.0;
  final double initialBlockWidth = 200.0;
  double currentBlockWidth = 200.0;
  double moveSpeed = 200.0;
  
  // State
  List<TowerBlock> stack = [];
  TowerBlock? currentBlock;
  bool movingRight = true;
  int combo = 0;
  
  // Camera target Y position
  double targetCameraY = 0;
  
  late TowerBackground _background;

  @override
  Future<void> onLoad() async {
    // Add background
    _background = TowerBackground(size: size);
    add(_background);
    
    // Initial setup
    resetGame();
  }

  void resetGame() {
    // Clear existing blocks
    children.whereType<TowerBlock>().forEach((b) => b.removeFromParent());
    stack.clear();
    
    score = 0;
    combo = 0;
    currentBlockWidth = initialBlockWidth;
    moveSpeed = 200.0;
    status = TowerGameStatus.intro;
    
    // Reset camera
    camera.viewfinder.position = size / 2;
    targetCameraY = size.y / 2;
    
    // Add base block
    final baseBlock = TowerBlock(
      position: Vector2(size.x / 2 - initialBlockWidth / 2, size.y - 100),
      size: Vector2(initialBlockWidth, blockHeight),
      color: Colors.grey.shade800,
      isBase: true,
    );
    add(baseBlock);
    stack.add(baseBlock);
    
    // Spawn first moving block
    spawnNextBlock();
    
    // Notify score change after build completes
    Future.microtask(() {
      if (onScoreChanged != null) onScoreChanged!(0);
      if (onComboChanged != null) onComboChanged!(0);
    });
  }
  
  void spawnNextBlock() {
    final prevBlock = stack.last;
    final yPos = prevBlock.position.y - blockHeight;
    
    // Determine spawn X (left or right side)
    final spawnX = movingRight ? -currentBlockWidth : size.x;
    
    // Generate color based on score/height
    final hue = (score * 5) % 360.0;
    final saturation = (0.6 + (combo * 0.05)).clamp(0.6, 1.0);
    final color = HSVColor.fromAHSV(1.0, hue, saturation, 0.9).toColor();
    
    currentBlock = TowerBlock(
      position: Vector2(spawnX, yPos),
      size: Vector2(currentBlockWidth, blockHeight),
      color: color,
    );
    add(currentBlock!);
    
    status = TowerGameStatus.playing;
  }

  @override
  void update(double dt) {
    super.update(dt);
    
    if (status != TowerGameStatus.playing || currentBlock == null) return;
    
    // Move current block
    if (movingRight) {
      currentBlock!.position.x += moveSpeed * dt;
      if (currentBlock!.position.x > size.x - currentBlockWidth + 50) {
        movingRight = false;
      }
    } else {
      currentBlock!.position.x -= moveSpeed * dt;
      if (currentBlock!.position.x < -50) {
        movingRight = true;
      }
    }
    
    // Update camera smoothly
    if (stack.length > 5) {
      final targetY = stack.last.position.y + size.y / 2 - 200;
      // Simple lerp for camera
      camera.viewfinder.position.y += (targetY - camera.viewfinder.position.y) * dt * 2;
    }
  }

  @override
  void onTapUp(TapUpEvent event) {
    if (status == TowerGameStatus.intro) {
      status = TowerGameStatus.playing;
      return;
    }
    
    if (status == TowerGameStatus.gameOver) {
      resetGame();
      return;
    }
    
    if (status == TowerGameStatus.playing && currentBlock != null) {
      placeBlock();
    }
  }
  
  void placeBlock() {
    final block = currentBlock!;
    final prevBlock = stack.last;
    
    // Calculate overlap
    final blockLeft = block.position.x;
    final blockRight = block.position.x + block.size.x;
    final prevLeft = prevBlock.position.x;
    final prevRight = prevBlock.position.x + prevBlock.size.x;
    
    // Check if missed completely
    if (blockRight < prevLeft || blockLeft > prevRight) {
      gameOver();
      return;
    }
    
    // Calculate cut
    double cutLeft = 0;
    double cutRight = 0;
    double newWidth = currentBlockWidth;
    double newX = blockLeft;
    
    // Increased tolerance for easier perfect drops
    final tolerance = 10.0;
    
    if ((blockLeft - prevLeft).abs() < tolerance && (blockRight - prevRight).abs() < tolerance) {
      // Perfect drop!
      newX = prevLeft;
      newWidth = prevBlock.size.x; // Match previous block exactly
      combo++;
      if (onComboChanged != null) onComboChanged!(combo);
      
      // Visual feedback for perfect drop
      _spawnPerfectEffect(block.position + Vector2(block.size.x / 2, block.size.y / 2));
      
      // Bonus points for perfect placement
      score += 5;
      
      // Grow block slightly if combo is high (bonus)
      if (combo >= 3) {
        newWidth = (newWidth + 5).clamp(50, initialBlockWidth);
      }
    } else {
      // Not perfect, reset combo
      combo = 0;
      if (onComboChanged != null) onComboChanged!(combo);
      
      if (blockLeft < prevLeft) {
        // Overhang on left
        cutLeft = prevLeft - blockLeft;
        newWidth -= cutLeft;
        newX = prevLeft;
      } else if (blockRight > prevRight) {
        // Overhang on right
        cutRight = blockRight - prevRight;
        newWidth -= cutRight;
        // X stays same
      } else {
        // Within bounds but not perfect - calculate actual overlap
        newX = blockLeft.clamp(prevLeft, prevRight);
        final overlapRight = blockRight.clamp(prevLeft, prevRight);
        newWidth = overlapRight - newX;
      }
    }
    
    // Check if block is too small
    if (newWidth < 30) {
      gameOver();
      return;
    }
    
    // Update block
    block.position.x = newX;
    block.size.x = newWidth;
    currentBlockWidth = newWidth;
    
    // Add falling debris for cut parts
    if (cutLeft > 0) {
      _spawnDebris(blockLeft, block.position.y, cutLeft, blockHeight, block.color);
    }
    if (cutRight > 0) {
      _spawnDebris(prevRight, block.position.y, cutRight, blockHeight, block.color);
    }
    
    // Success!
    stack.add(block);
    currentBlock = null;
    score++;
    if (onScoreChanged != null) onScoreChanged!(score);
    _background.updateScore(score);
    
    // Increase speed slightly (but cap it)
    moveSpeed = (moveSpeed + 8).clamp(200, 600);
    
    spawnNextBlock();
  }
  
  void _spawnPerfectEffect(Vector2 position) {
    // Add expanding rings
    for (int i = 0; i < 3; i++) {
      add(
        ParticleSystemComponent(
          position: position,
          particle: ComputedParticle(
            renderer: (canvas, particle) {
              final paint = Paint()
                ..color = Colors.yellowAccent.withValues(alpha: 1 - particle.progress)
                ..style = PaintingStyle.stroke
                ..strokeWidth = 3;
                
              canvas.drawCircle(
                Offset.zero,
                (50 + i * 20) * particle.progress,
                paint,
              );
            },
            lifespan: 0.5 + i * 0.1,
          ),
        ),
      );
    }
    
    // Add sparkle particles
    for (int i = 0; i < 8; i++) {
      final angle = (i / 8) * math.pi * 2;
      add(
        ParticleSystemComponent(
          position: position,
          particle: AcceleratedParticle(
            acceleration: Vector2(0, 200),
            speed: Vector2(50 * math.cos(angle), 50 * math.sin(angle)),
            child: CircleParticle(
              radius: 3,
              paint: Paint()..color = Colors.white,
            ),
            lifespan: 0.8,
          ),
        ),
      );
    }
  }
  
  void _spawnDebris(double x, double y, double w, double h, Color color) {
    final debris = TowerBlock(
      position: Vector2(x, y),
      size: Vector2(w, h),
      color: color,
      isDebris: true,
    );
    add(debris);
  }
  
  void gameOver() {
    status = TowerGameStatus.gameOver;
    
    // Make current block fall
    if (currentBlock != null) {
      currentBlock!.isDebris = true;
    }
    
    if (onGameOver != null) onGameOver!();
  }
}
