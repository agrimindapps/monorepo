import 'package:flutter/material.dart';
import '../enums/game_category.dart';

/// Entity representing a minigame
class GameEntity {
  final String id;
  final String name;
  final String description;
  final String route;
  final IconData icon;
  final Color primaryColor;
  final Color secondaryColor;
  final GameCategory category;
  final bool isNew;
  final bool isFeatured;
  final int playerCount; // 1 = single, 2 = multiplayer
  final int? highScore;
  final DateTime? lastPlayed;
  final String? assetPath;

  const GameEntity({
    required this.id,
    required this.name,
    required this.description,
    required this.route,
    required this.icon,
    required this.primaryColor,
    required this.secondaryColor,
    required this.category,
    this.isNew = false,
    this.isFeatured = false,
    this.playerCount = 1,
    this.highScore,
    this.lastPlayed,
    this.assetPath,
  });

  GameEntity copyWith({
    String? id,
    String? name,
    String? description,
    String? route,
    IconData? icon,
    Color? primaryColor,
    Color? secondaryColor,
    GameCategory? category,
    bool? isNew,
    bool? isFeatured,
    int? playerCount,
    int? highScore,
    DateTime? lastPlayed,
    String? assetPath,
  }) {
    return GameEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      route: route ?? this.route,
      icon: icon ?? this.icon,
      primaryColor: primaryColor ?? this.primaryColor,
      secondaryColor: secondaryColor ?? this.secondaryColor,
      category: category ?? this.category,
      isNew: isNew ?? this.isNew,
      isFeatured: isFeatured ?? this.isFeatured,
      playerCount: playerCount ?? this.playerCount,
      highScore: highScore ?? this.highScore,
      lastPlayed: lastPlayed ?? this.lastPlayed,
      assetPath: assetPath ?? this.assetPath,
    );
  }
}
