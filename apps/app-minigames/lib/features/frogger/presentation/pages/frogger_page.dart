import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import '../../../../core/widgets/game_page_layout.dart';
import '../../game/frogger_game.dart';

class FroggerPage extends StatelessWidget {
  const FroggerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return GamePageLayout(
      title: 'Frogger',
      accentColor: const Color(0xFF4CAF50),
      instructions: 'Toque ou use as setas para mover o sapo.\n\n'
          '🚗 Evite os carros na rua\n'
          '🪵 Pule nos troncos no rio\n'
          '🎯 Chegue nas 5 metas no topo',
      maxGameWidth: 500,
      child: AspectRatio(
        aspectRatio: 0.7,
        child: GameWidget(
          game: FroggerGame(),
          backgroundBuilder: (context) => Container(
            color: const Color(0xFF1A1A2E),
          ),
        ),
      ),
    );
  }
}
