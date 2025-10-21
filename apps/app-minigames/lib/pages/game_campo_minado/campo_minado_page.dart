// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:provider/provider.dart';

// Project imports:
import 'constants/game_constants.dart' as constants;
import 'providers/game_state_provider.dart';
import 'services/logger_service.dart';
import 'widgets/game_overlay.dart';
import 'widgets/minefield_grid.dart';

/// Main page for the Campo Minado (Minesweeper) game
class CampoMinadoPage extends StatefulWidget {
  const CampoMinadoPage({super.key});

  @override
  State<CampoMinadoPage> createState() => _CampoMinadoPageState();
}

class _CampoMinadoPageState extends State<CampoMinadoPage> with WidgetsBindingObserver {
  late GameStateProvider _gameProvider;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _gameProvider = GameStateProvider();
    LoggerService.info('Campo Minado page initialized');
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _gameProvider.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    
    // Auto-pause when app goes to background
    if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
      if (_gameProvider.isGameActive && !_gameProvider.gameState.isPaused) {
        _gameProvider.togglePause();
        LoggerService.info('Game auto-paused due to app lifecycle change');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _gameProvider,
      child: Scaffold(
        backgroundColor: constants.GameColors.background,
        appBar: AppBar(
          title: const Text(
            'Campo Minado',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: constants.GameSizes.headerFontSize,
            ),
          ),
          backgroundColor: constants.GameColors.background,
          elevation: 0,
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.help_outline),
              onPressed: () => _showHelpDialog(context),
              tooltip: 'How to Play',
            ),
          ],
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(constants.Layout.gridPadding),
            child: Column(
              children: [
                // Game overlay with controls and info
                const GameOverlay(),
                
                const SizedBox(height: constants.Layout.elementSpacing),
                
                // Main game grid
                Expanded(
                  child: Center(
                    child: SingleChildScrollView(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(
                          maxWidth: constants.Layout.maxGridWidth,
                          maxHeight: constants.Layout.maxGridHeight,
                        ),
                        child: const MinefieldGrid(),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('How to Play'),
          content: const SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '🎯 Goal',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                SizedBox(height: 4),
                Text('Find all mines without detonating any of them.'),
                SizedBox(height: 12),
                
                Text(
                  '🎮 Controls',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                SizedBox(height: 4),
                Text('• Tap to reveal a cell'),
                Text('• Long press to flag/unflag a mine'),
                Text('• Double tap on revealed numbers to auto-reveal safe neighbors'),
                SizedBox(height: 12),
                
                Text(
                  '💡 Tips',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                SizedBox(height: 4),
                Text('• Numbers show how many mines are adjacent'),
                Text('• Use flags to mark suspected mines'),
                Text('• Start from corners and edges'),
                Text('• Use the chord (double-tap) feature for speed'),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Got it!'),
            ),
          ],
        );
      },
    );
  }
}
