import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'enums.dart';

class CardEntity extends Equatable {
  final String id;
  final int pairId;
  final Color color;
  final IconData icon;
  final CardState state;
  final int position;

  const CardEntity({
    required this.id,
    required this.pairId,
    required this.color,
    required this.icon,
    this.state = CardState.hidden,
    required this.position,
  });

  bool matches(CardEntity other) {
    return pairId == other.pairId && id != other.id;
  }

  bool get isFlipped => state.isFlipped;
  bool get isMatched => state.isMatched;
  bool get isHidden => state == CardState.hidden;

  CardEntity copyWith({
    String? id,
    int? pairId,
    Color? color,
    IconData? icon,
    CardState? state,
    int? position,
  }) {
    return CardEntity(
      id: id ?? this.id,
      pairId: pairId ?? this.pairId,
      color: color ?? this.color,
      icon: icon ?? this.icon,
      state: state ?? this.state,
      position: position ?? this.position,
    );
  }

  @override
  List<Object?> get props => [id, pairId, color, icon, state, position];

  @override
  String toString() =>
      'CardEntity(id: $id, pairId: $pairId, state: $state, position: $position)';
}
