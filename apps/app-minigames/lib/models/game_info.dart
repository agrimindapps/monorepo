// Flutter imports:
import 'package:flutter/material.dart';

class GameInfo {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final Widget page;

  GameInfo({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.page,
  });
}
