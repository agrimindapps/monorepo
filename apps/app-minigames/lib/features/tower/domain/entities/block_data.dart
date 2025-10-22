import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

/// Immutable entity representing a single block in the tower
class BlockData extends Equatable {
  final double width;
  final double height;
  final double posX;
  final Color color;

  const BlockData({
    required this.width,
    required this.height,
    required this.posX,
    required this.color,
  });

  @override
  List<Object?> get props => [width, height, posX, color];
}
