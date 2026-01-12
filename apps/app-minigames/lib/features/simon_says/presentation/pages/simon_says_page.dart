import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/widgets/game_page_layout.dart';
import '../providers/simon_says_controller.dart';
import '../widgets/simon_button.dart';
import 'simon_high_scores_page.dart';
import 'simon_settings_page.dart';

class SimonSaysPage extends ConsumerWidget {
  const SimonSaysPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(simonSaysControllerProvider);
    final notifier = ref.read(simonSaysControllerProvider.notifier);

    return GamePageLayout(
      title: 'Genius',
      accentColor: const Color(0xFFE91E63),
      instructions: 'Memorize e repita a sequência de cores!\n\n'
          '👀 Observe as cores acenderem\n'
          '🎯 Repita a sequência\n'
          '📈 Cada rodada adiciona uma cor',
      maxGameWidth: 400,
      actions: [
        IconButton(
          icon: const Icon(Icons.emoji_events_outlined),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const SimonHighScoresPage(),
              ),
            );
          },
          tooltip: 'High Scores',
        ),
        IconButton(
          icon: const Icon(Icons.settings_outlined),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const SimonSettingsPage(),
              ),
            );
          },
          tooltip: 'Configurações',
        ),
      ],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Score Display
            Text(
              'Score: ${state.score}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            
            // Status Message
            Text(
              _getStatusMessage(state.gameState),
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.7),
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 24),

            // Game Board
            SizedBox(
              width: 280,
              height: 280,
              child: GridView.count(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                padding: const EdgeInsets.all(8),
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  SimonButton(
                    index: 0,
                    color: Colors.green,
                    isActive: state.activeIndex == 0,
                    enabled: state.gameState == SimonGameState.waitingForInput,
                    onTap: () => notifier.handleInput(0),
                  ),
                  SimonButton(
                    index: 1,
                    color: Colors.red,
                    isActive: state.activeIndex == 1,
                    enabled: state.gameState == SimonGameState.waitingForInput,
                    onTap: () => notifier.handleInput(1),
                  ),
                  SimonButton(
                    index: 2,
                    color: Colors.yellow,
                    isActive: state.activeIndex == 2,
                    enabled: state.gameState == SimonGameState.waitingForInput,
                    onTap: () => notifier.handleInput(2),
                  ),
                  SimonButton(
                    index: 3,
                    color: Colors.blue,
                    isActive: state.activeIndex == 3,
                    enabled: state.gameState == SimonGameState.waitingForInput,
                    onTap: () => notifier.handleInput(3),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),

            // Controls
            if (state.gameState == SimonGameState.idle || 
                state.gameState == SimonGameState.gameOver)
              ElevatedButton(
                onPressed: () => notifier.startGame(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE91E63),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                ),
                child: Text(
                  state.gameState == SimonGameState.idle ? 'INICIAR' : 'TENTAR NOVAMENTE',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _getStatusMessage(SimonGameState state) {
    switch (state) {
      case SimonGameState.idle:
        return 'Toque em Iniciar para jogar';
      case SimonGameState.showingSequence:
        return 'Observe com atenção...';
      case SimonGameState.waitingForInput:
        return 'Sua vez!';
      case SimonGameState.gameOver:
        return 'Game Over!';
    }
  }
}
