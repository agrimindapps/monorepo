import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/widgets/game_page_layout.dart';
import '../providers/simon_says_controller.dart';
import '../widgets/simon_button.dart';
import '../widgets/simon_game_options_dialog.dart';
import 'simon_high_scores_page.dart';

class SimonSaysPage extends ConsumerStatefulWidget {
  const SimonSaysPage({super.key});

  @override
  ConsumerState<SimonSaysPage> createState() => _SimonSaysPageState();
}

class _SimonSaysPageState extends ConsumerState<SimonSaysPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showOptionsDialog();
    });
  }

  void _showOptionsDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const SimonGameOptionsDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(simonSaysControllerProvider);
    final notifier = ref.read(simonSaysControllerProvider.notifier);

    return GamePageLayout(
      title: 'Genius',
      accentColor: const Color(0xFFE91E63),
      instructions: 'Memorize e repita a sequência de cores!\n\n'
          '👀 Observe as cores acenderem\n'
          '🎯 Repita a sequência\n'
          '📈 Cada rodada adiciona uma cor',
      maxGameWidth: 600, // Increased width
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
          onPressed: _showOptionsDialog,
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
                color: Colors.white.withOpacity(0.7),
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 24),

            // Game Board
            SizedBox(
              width: 360, // Increased size
              height: 360, // Increased size
              child: _buildBoard(state, notifier),
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

  Widget _buildBoard(SimonState state, SimonSaysController notifier) {
    // Colors map
    final colors = [
      Colors.green,
      Colors.red,
      Colors.yellow,
      Colors.blue,
      Colors.purple,
      Colors.orange,
    ];

    final count = state.colorCount;
    int crossAxisCount;
    
    if (count <= 2) {
      crossAxisCount = 2;
    } else if (count <= 4) {
      crossAxisCount = 2;
    } else {
      crossAxisCount = 3;
    }

    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.0,
      ),
      padding: const EdgeInsets.all(8),
      physics: const NeverScrollableScrollPhysics(),
      itemCount: count,
      itemBuilder: (context, index) {
        return SimonButton(
          index: index,
          color: colors[index % colors.length],
          isActive: state.activeIndex == index,
          enabled: state.gameState == SimonGameState.waitingForInput,
          onTap: () => notifier.handleInput(index),
        );
      },
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
