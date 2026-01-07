import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

enum VehicleType { car, truck, motorcycle }

class Vehicle extends PositionComponent {
  final VehicleType type;
  final double speed;
  final double screenWidth;
  
  Vehicle({
    required Vector2 position,
    required this.type,
    required this.speed,
    required this.screenWidth,
  }) : super(
    position: position,
    size: _getSize(type),
  );
  
  static Vector2 _getSize(VehicleType type) {
    switch (type) {
      case VehicleType.car:
        return Vector2(50, 30);
      case VehicleType.truck:
        return Vector2(80, 30);
      case VehicleType.motorcycle:
        return Vector2(30, 25);
    }
  }
  
  Color get _color {
    switch (type) {
      case VehicleType.car:
        return Colors.red;
      case VehicleType.truck:
        return Colors.blue;
      case VehicleType.motorcycle:
        return Colors.yellow;
    }
  }
  
  @override
  Future<void> onLoad() async {
    await super.onLoad();
    
    // Vehicle body
    add(RectangleComponent(
      size: size,
      paint: Paint()..color = _color,
    ));
    
    // Windows
    if (type != VehicleType.motorcycle) {
      add(RectangleComponent(
        position: Vector2(size.x * 0.2, 4),
        size: Vector2(size.x * 0.3, size.y - 8),
        paint: Paint()..color = Colors.lightBlue.withValues(alpha: 0.7),
      ));
    }
    
    // Wheels
    add(CircleComponent(
      radius: 5,
      position: Vector2(8, size.y - 3),
      paint: Paint()..color = Colors.black,
    ));
    add(CircleComponent(
      radius: 5,
      position: Vector2(size.x - 8, size.y - 3),
      paint: Paint()..color = Colors.black,
    ));
    
    add(RectangleHitbox());
  }
  
  @override
  void update(double dt) {
    super.update(dt);
    
    position.x += speed * dt;
    
    // Wrap around screen
    if (speed > 0 && position.x > screenWidth) {
      position.x = -size.x;
    } else if (speed < 0 && position.x < -size.x) {
      position.x = screenWidth;
    }
  }
}
