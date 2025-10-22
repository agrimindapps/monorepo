import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/campo_minado_game_notifier.dart';
import '../widgets/game_header_widget.dart';
import '../widgets/minefield_widget.dart';
import '../widgets/game_over_dialog.dart';
import '../../domain/entities/enums.dart';

/// Main page for Campo Minado (Minesweeper) game
class CampoMinadoPage extends ConsumerStatefulWidget {
  const CampoMinadoPage({super.key});

  @override
  ConsumerState<CampoMinadoPage> createState() => _CampoMinadoPageState();
}

class _CampoMinadoPageState extends ConsumerState<CampoMinadoPage>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // Initialize local data source
    _initializeDataSource();
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
      final gameState = ref.read(campoMinadoGameNotifierProvider);
      if (gameState.isPlaying && !gameState.isPaused) {
        ref.read(campoMinadoGameNotifierProvider.notifier).togglePause();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Listen to game state for game over dialog
    ref.listen<GameStatus>(
      campoMinadoGameNotifierProvider.select((state) => state.status),
      (previous, next) {
        if (next.isGameOver && previous != next) {
          _showGameOverDialog(context, next);
        }
      },
    );

    return Scaffold(
      backgroundColor: const Color(0xFFC6C6C6),
      appBar: AppBar(
        title: const Text(
          'Campo Minado',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        backgroundColor: const Color(0xFFC6C6C6),
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: () => _showHelpDialog(context),
            tooltip: 'Como Jogar',
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => _showSettingsDialog(context),
            tooltip: 'Configurações',
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Game header with controls and info
              const GameHeaderWidget(),

              const SizedBox(height: 16),

              // Main minefield grid
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(
                        maxWidth: 600,
                        maxHeight: 800,
                      ),
                      child: const MinefieldWidget(),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showGameOverDialog(BuildContext context, GameStatus status) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => GameOverDialog(status: status),
    );
  }

  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Como Jogar'),
          content: const SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '🎯 Objetivo',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                SizedBox(height: 4),
                Text('Encontre todas as minas sem detonar nenhuma.'),
                SizedBox(height: 12),
                Text(
                  '🎮 Controles',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                SizedBox(height: 4),
                Text('• Toque para revelar uma célula'),
                Text('• Toque longo para marcar/desmarcar mina'),
                Text('• Toque duplo em números revelados para revelar vizinhos seguros'),
                SizedBox(height: 12),
                Text(
                  '💡 Dicas',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                SizedBox(height: 4),
                Text('• Números mostram quantas minas estão adjacentes'),
                Text('• Use bandeiras para marcar minas suspeitas'),
                Text('• Comece pelos cantos e bordas'),
                Text('• Use o toque duplo para jogar mais rápido'),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Entendi!'),
            ),
          ],
        );
      },
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
                      .read(campoMinadoGameNotifierProvider.notifier)
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
}
