import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/widgets/game_page_layout.dart';
import '../../../../core/widgets/esc_keyboard_wrapper.dart';
import '../providers/campo_minado_game_notifier.dart';
import '../widgets/game_header_widget.dart';
import '../game/minesweeper_game.dart';
import '../widgets/game_over_dialog_adapter.dart';
import '../widgets/achievements_dialog_adapter.dart';
import '../../domain/entities/enums.dart';

/// Main page for Campo Minado (Minesweeper) game
class CampoMinadoPage extends ConsumerStatefulWidget {
  const CampoMinadoPage({super.key});

  @override
  ConsumerState<CampoMinadoPage> createState() => _CampoMinadoPageState();
}

class _CampoMinadoPageState extends ConsumerState<CampoMinadoPage>
    with WidgetsBindingObserver {
  late MinesweeperGame _game;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // Initialize local data source
    _initializeDataSource();
    
    _game = MinesweeperGame(
      onCellTap: (row, col) {
        ref.read(campoMinadoGameProvider.notifier).revealCell(row, col);
      },
      onCellLongPress: (row, col) {
        ref.read(campoMinadoGameProvider.notifier).toggleFlag(row, col);
      },
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Future<void> _initializeDataSource() async {
    // This will be properly initialized via DI
    // For now, we'll handle it in the provider
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    // Auto-pause when app goes to background
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      final gameState = ref.read(campoMinadoGameProvider);
      if (gameState.isPlaying && !gameState.isPaused) {
        ref.read(campoMinadoGameProvider.notifier).togglePause();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final gameState = ref.watch(campoMinadoGameProvider);
    
    // Update game state
    _game.updateState(gameState);

    // Listen to game state for game over dialog
    ref.listen<GameStatus>(
      campoMinadoGameProvider.select((state) => state.status),
      (previous, next) {
        if (next.isGameOver && previous != next) {
          _showGameOverDialog(context, next);
        }
      },
    );

    return EscKeyboardWrapper(
      onEscPressed: () {
        ref.read(campoMinadoGameProvider.notifier).togglePause();
      },
      child: GamePageLayout(
        title: 'Campo Minado',
        accentColor: const Color(0xFF607D8B),
        instructions: 'Encontre todas as minas sem detonar!\n\n'
            '👆 Toque para revelar célula\n'
          '👆🏻 Toque longo para bandeira\n'
          '🔢 Números = minas adjacentes\n'
          '🚩 Marque todas as minas para vencer!',
      maxGameWidth: 600,
      actions: [
        IconButton(
          icon: const Icon(Icons.emoji_events, color: Colors.white),
          onPressed: () => _showAchievementsDialog(context),
          tooltip: 'Conquistas',
        ),
        IconButton(
          icon: const Icon(Icons.tune, color: Colors.white),
          onPressed: () => _showSettingsDialog(context),
          tooltip: 'Dificuldade',
        ),
      ],
      child: Column(
        children: [
          // Game header with controls and info
          const GameHeaderWidget(),

          const SizedBox(height: 16),

          // Main minefield grid
          Expanded(
            child: Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: GameWidget(game: _game),
              ),
            ),
          ),
        ],
      ),
      ),
    );
  }

  void _showGameOverDialog(BuildContext context, GameStatus status) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => CampoMinadoGameOverDialogAdapter(status: status),
    );
  }

  void _showSettingsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Dificuldade'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: Difficulty.values
                .where((d) => d != Difficulty.custom)
                .map((difficulty) {
              return ListTile(
                title: Text(difficulty.label),
                subtitle: Text(
                  '${difficulty.config.rows}x${difficulty.config.cols} - ${difficulty.config.mines} minas',
                ),
                onTap: () {
                  ref
                      .read(campoMinadoGameProvider.notifier)
                      .changeDifficulty(difficulty);
                  Navigator.of(context).pop();
                },
              );
            }).toList(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
          ],
        );
      },
    );
  }

  void _showAchievementsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => const CampoMinadoAchievementsDialogAdapter(),
    );
  }
}
