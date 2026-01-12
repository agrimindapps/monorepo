import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/widgets/game_page_layout.dart';

class TicTacToeHighScoresPage extends ConsumerWidget {
  const TicTacToeHighScoresPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GamePageLayout(
      title: 'Estatísticas - Jogo da Velha',
      accentColor: const Color(0xFF2196F3),
      maxGameWidth: 600,
      child: Center(
        child: Text(
          'Estatísticas em desenvolvimento...\n\nJá temos persistência funcionando!',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 16),
        ),
      ),
    );
  }
}
