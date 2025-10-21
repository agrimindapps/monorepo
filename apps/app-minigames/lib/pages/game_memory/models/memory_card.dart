// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:app_minigames/constants/enums.dart';

class MemoryCard {
  final int id;
  final int pairId;
  final Color color;
  final IconData icon;
  CardState state;

  MemoryCard({
    required this.id,
    required this.pairId,
    required this.color,
    required this.icon,
    this.state = CardState.hidden,
  });

  // Clone the card with a new state
  MemoryCard copyWith({CardState? newState}) {
    return MemoryCard(
      id: id,
      pairId: pairId,
      color: color,
      icon: icon,
      state: newState ?? state,
    );
  }

  // Check if two cards match
  bool matches(MemoryCard other) {
    return pairId == other.pairId;
  }
}
