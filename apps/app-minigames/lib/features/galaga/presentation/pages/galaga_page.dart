import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import '../../../../core/widgets/game_page_layout.dart';
import '../../game/galaga_game.dart';

class GalagaPage extends StatelessWidget {
  const GalagaPage({super.key});

  @override
  Widget build(BuildContext context) {
    return GamePageLayout(
      title: 'Galaga',
      accentColor: const Color(0xFF00BCD4),
      instructions: 'Arraste para mover a nave.\n'
          'Toque para atirar.\n\n'
          '🟢 Inimigo básico: 50pts\n'
          '🟡 Atirador: 100pts\n'
          '🔴 Mergulhador: 150pts',
      maxGameWidth: 500,
      child: AspectRatio(
        aspectRatio: 0.65,
        child: GameWidget(
          game: GalagaGame(),
          backgroundBuilder: (context) => Container(
            color: const Color(0xFF000011),
          ),
        ),
      ),
    );
  }
}
