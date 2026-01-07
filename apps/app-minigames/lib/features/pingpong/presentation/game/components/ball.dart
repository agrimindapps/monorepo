import 'dart:math';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/particles.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../ping_pong_game.dart';
import 'paddle.dart';

class Ball extends PositionComponent with CollisionCallbacks, HasGameReference<PingPongGame> {
  final double radius;
  double speed;
  Vector2 velocity = Vector2.zero();
  double _trailTimer = 0;

  Ball({
    required Vector2 position,
    required this.radius,
    required this.speed,
  }) : super(position: position, size: Vector2(radius * 2, radius * 2), anchor: Anchor.center);

  @override
  Future<void> onLoad() async {
    add(CircleHitbox());
    reset(servingPlayer: true);
  }

  @override
  void update(double dt) {
    super.update(dt);
    position += velocity * dt;

    // Trail generation
    _trailTimer += dt;
    if (_trailTimer > 0.05) {
      _trailTimer = 0;
      _spawnTrail();
    }

    // Wall collisions (Top/Bottom)
    if (position.y - radius <= 0) {
      position.y = radius;
      velocity.y = -velocity.y;
      _spawnHitParticles(position + Vector2(radius, 0));
      HapticFeedback.lightImpact();
    } else if (position.y + radius >= game.size.y) {
      position.y = game.size.y - radius;
      velocity.y = -velocity.y;
      _spawnHitParticles(position + Vector2(radius, radius * 2));
      HapticFeedback.lightImpact();
    }
  }

  void _spawnTrail() {
    game.add(
      ParticleSystemComponent(
        particle: ComputedParticle(
          renderer: (canvas, particle) {
            final paint = Paint()
              ..color = Colors.white.withValues(alpha: (1 - particle.progress) * 0.5);
            canvas.drawCircle(Offset.zero, radius * (1 - particle.progress * 0.5), paint);
          },
          lifespan: 0.3,
        ),
        position: position + Vector2(radius, radius),
      ),
    );
  }

  void _spawnHitParticles(Vector2 pos) {
    final random = Random();
    game.add(
      ParticleSystemComponent(
        particle: Particle.generate(
          count: 8,
          lifespan: 0.4,
          generator: (i) {
            final speed = Vector2.random(random) - Vector2(0.5, 0.5);
            speed.multiply(Vector2(150, 150));
            
            return AcceleratedParticle(
              position: pos,
              speed: speed,
              child: CircleParticle(
                radius: 2,
                paint: Paint()..color = Colors.white,
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    final paint = Paint()..color = Colors.white;
    canvas.drawCircle(Offset(radius, radius), radius, paint);
    
    // Shine
    final shinePaint = Paint()..color = Colors.white.withValues(alpha: 0.5);
    canvas.drawCircle(Offset(radius * 0.7, radius * 0.7), radius * 0.3, shinePaint);
  }
  
  void reset({required bool servingPlayer}) {
    position = game.size / 2;
    
    // Random angle but generally towards the opponent
    final random = Random();
    final angle = (random.nextDouble() - 0.5) * pi / 3; // +/- 30 degrees
    
    final direction = servingPlayer ? 1 : -1;
    
    velocity = Vector2(cos(angle) * direction, sin(angle)) * speed;
  }
  
  @override
  void onCollisionStart(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollisionStart(intersectionPoints, other);
    
    if (other is Paddle) {
      // Calculate bounce angle based on where it hit the paddle
      final hitPoint = position.y - (other.position.y + other.size.y / 2);
      final normalizedHit = hitPoint / (other.size.y / 2);
      
      final bounceAngle = normalizedHit * (pi / 4); // Max 45 degrees
      
      final direction = other.isPlayer ? 1 : -1;
      
      // Increase speed slightly on each hit
      speed *= 1.05;
      
      velocity = Vector2(cos(bounceAngle) * direction, sin(bounceAngle)) * speed;
      
      // Push ball out of paddle to prevent sticking
      if (other.isPlayer) {
        position.x = other.position.x + other.size.x + radius + 1;
        _spawnHitParticles(position + Vector2(0, radius));
        HapticFeedback.selectionClick();
      } else {
        position.x = other.position.x - radius - 1;
        _spawnHitParticles(position + Vector2(radius * 2, radius));
        HapticFeedback.lightImpact();
      }
    }
  }
}
