// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'l10n/soletrando_strings.dart';
import 'services/dependency_injection.dart';
import 'services/dialog_service.dart';
import 'theme/soletrando_theme.dart';
import 'viewmodels/soletrando_view_model.dart';
import 'widgets/letters_keyboard.dart';
import 'widgets/score_lives_display.dart';
import 'widgets/timer_display.dart';
import 'widgets/word_display.dart';

class GameSoletrandoPage extends StatefulWidget {
  const GameSoletrandoPage({super.key});

  @override
  State<GameSoletrandoPage> createState() => _GameSoletrandoPageState();
}

class _GameSoletrandoPageState extends State<GameSoletrandoPage>
    with WidgetsBindingObserver, SingleTickerProviderStateMixin {
  late SoletrandoViewModel _viewModel;
  late DependencyInjection _di;
  late DialogService _dialogService;
  late AnimationController _animationController;

  // Estado de lifecycle
  AppLifecycleState? _lastLifecycleState;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // Inicializar AnimationController
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    // Configurar injeção de dependências
    _di = DependencyInjection.instance;
    _di.registerSoletrandoDependencies();

    // Obter serviços
    _dialogService = _di.get<DialogService>();
    _viewModel = _di.get<SoletrandoViewModel>();

    // Configurar callbacks da ViewModel
    _viewModel.onGameOver = _handleGameOver;
    _viewModel.onTimeOut = _handleTimeOut;

    // Registrar contexto para diálogos
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _dialogService.registerContext(context);
    });
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _animationController.dispose();
    WidgetsBinding.instance.removeObserver(this);
    _dialogService.unregisterContext(context);
    _viewModel.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    // Gerenciar lifecycle do jogo baseado no estado do app
    switch (state) {
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
        _viewModel.pauseGame();
        break;
      case AppLifecycleState.resumed:
        // Só retomar se o jogo estava pausado automaticamente
        if (_lastLifecycleState == AppLifecycleState.paused) {
          _viewModel.resumeGame();
        }
        break;
      case AppLifecycleState.inactive:
        // App perdeu foco (ex: chamada recebida)
        _viewModel.pauseGame();
        break;
    }

    _lastLifecycleState = state;
  }

  // Callbacks da ViewModel
  void _handleGameOver(bool won) async {
    final result = await _dialogService.showGameOverDialog(
      won: won,
      currentWord: _viewModel.currentWord,
      score: _viewModel.score,
    );

    if (result.confirmed && result.data == true) {
      await _viewModel.startNewGame();
    }
  }

  void _handleTimeOut() async {
    final result = await _dialogService.showTimeOutDialog(
      currentWord: _viewModel.currentWord,
      lives: _viewModel.lives,
    );

    if (result.confirmed && result.data == true) {
      await _viewModel.startNewGame();
    }
  }

  // Debouncing para evitar múltiplas chamadas rápidas
  Timer? _debounceTimer;

  void _checkLetter(String letter) async {
    // Cancela timer anterior se existir
    _debounceTimer?.cancel();

    // Debounce de 100ms para evitar cliques duplos
    _debounceTimer = Timer(const Duration(milliseconds: 100), () async {
      await _viewModel.checkLetter(letter);
    });
  }

  void _useHint() {
    _viewModel.useHint();
  }

  // Dialogs are now handled by DialogService via ViewModel callbacks

  void _showCategoryDialog() async {
    final result = await _dialogService.showCategorySelectionDialog(
      categoryProgress: _viewModel.categoryProgress,
      wordCategories: _viewModel.game.wordCategories,
    );

    if (result.confirmed && result.data != null) {
      await _viewModel.changeCategory(result.data!);
    }
  }

  void _showSettingsDialog() async {
    await _dialogService.showSettingsDialog(
      currentDifficulty: _viewModel.difficulty,
      enableAnimations: _viewModel.enableAnimations,
      enableSounds: _viewModel.enableSounds,
      onDifficultyChanged: (difficulty) =>
          _viewModel.changeDifficulty(difficulty),
      onAnimationsChanged: (enabled) => _viewModel.setAnimations(enabled),
      onSoundsChanged: (enabled) => _viewModel.setSounds(enabled),
      onResetProgress: () => _viewModel.resetProgress(),
    );
  }

  // Reset confirmation is now handled within DialogService

  @override
  Widget build(BuildContext context) {
    return DialogContextProvider(
      child: DependencyProvider(
        di: _di,
        child: Scaffold(
          appBar: AppBar(
            title: const Text(SoletrandoStrings.gameTitle),
            actions: [
              IconButton(
                icon: const Icon(Icons.category),
                onPressed: _showCategoryDialog,
              ),
              IconButton(
                icon: const Icon(Icons.settings),
                onPressed: _showSettingsDialog,
              ),
            ],
          ),
          body: AnimatedBuilder(
            animation: _viewModel,
            builder: (context, child) {
              // Handle error state
              if (_viewModel.hasError) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error, size: 64, color: Colors.red),
                      const SizedBox(height: 16),
                      Text(
                        'Erro: ${_viewModel.error}',
                        style: const TextStyle(fontSize: 16),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => _viewModel.retry(),
                        child: const Text('Tentar Novamente'),
                      ),
                    ],
                  ),
                );
              }

              // Handle loading state
              if (_viewModel.isLoading) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text('Carregando...'),
                    ],
                  ),
                );
              }

              // Main game interface
              return Stack(
                children: [
                  SingleChildScrollView(
                    child: ResponsiveContainer(
                      child: Column(
                        children: [
                          // Status do jogo (pontos e vidas) - Rebuilds seletivos
                          ValueListenableBuilder<int>(
                            valueListenable: _ScoreNotifier(_viewModel),
                            builder: (context, _, __) => ScoreLivesDisplay(
                              score: _viewModel.score,
                              lives: _viewModel.lives,
                            ),
                          ),

                          const SizedBox(height: 16),

                          // Temporizador - Rebuilds seletivos
                          ValueListenableBuilder<int>(
                            valueListenable: _TimerNotifier(_viewModel),
                            builder: (context, _, __) => TimerDisplay(
                              currentTime: _viewModel.timeRemaining,
                              maxTime: _viewModel.difficulty.timeInSeconds,
                            ),
                          ),

                          const SizedBox(height: 16),

                          // Exibição da palavra - Rebuilds seletivos
                          ValueListenableBuilder<String>(
                            valueListenable: _WordNotifier(_viewModel),
                            builder: (context, _, __) => WordDisplayPanel(
                              displayWord: _viewModel.displayWord,
                              hint: _viewModel.currentCategory.hint,
                              showHint: _viewModel.showHint,
                            ),
                          ),

                          const SizedBox(height: 16),

                          // Botão de dica - Rebuilds seletivos
                          ValueListenableBuilder<int>(
                            valueListenable: _HintNotifier(_viewModel),
                            builder: (context, _, __) => ElevatedButton.icon(
                              icon: const Icon(Icons.lightbulb_outline),
                              label: Text(
                                  '${SoletrandoStrings.hintCategory}(${_viewModel.hintCount})'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.amber,
                              ),
                              onPressed:
                                  _viewModel.canUseHint ? _useHint : null,
                            ),
                          ),

                          const SizedBox(height: 16),

                          // Teclado de letras - Rebuilds seletivos
                          ValueListenableBuilder<Map<String, Color>>(
                            valueListenable: _KeyboardNotifier(_viewModel),
                            builder: (context, _, __) => LettersKeyboard(
                              letters: _viewModel.availableLetters,
                              letterColors: _viewModel.letterColors,
                              onLetterPressed: _checkLetter,
                              isGameOver: _viewModel.game.isGameOver(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Overlay para estado pausado
                  if (_viewModel.isPaused)
                    Container(
                      color: Colors.black54,
                      child: Center(
                        child: Card(
                          child: Padding(
                            padding: const EdgeInsets.all(24.0),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.pause_circle, size: 64),
                                const SizedBox(height: 16),
                                const Text(
                                  'Jogo Pausado',
                                  style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 8),
                                const Text('Toque para continuar'),
                                const SizedBox(height: 16),
                                ElevatedButton(
                                  onPressed: () => _viewModel.resumeGame(),
                                  child: const Text('Continuar'),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

// Classes para gerenciar rebuilds seletivos
class _ScoreNotifier extends ValueNotifier<int> {
  final SoletrandoViewModel _viewModel;

  _ScoreNotifier(this._viewModel) : super(_viewModel.score) {
    _viewModel.addListener(_updateValue);
  }

  void _updateValue() {
    if (value != _viewModel.score) {
      value = _viewModel.score;
    }
  }

  @override
  void dispose() {
    _viewModel.removeListener(_updateValue);
    super.dispose();
  }
}

class _TimerNotifier extends ValueNotifier<int> {
  final SoletrandoViewModel _viewModel;

  _TimerNotifier(this._viewModel) : super(_viewModel.timeRemaining) {
    _viewModel.addListener(_updateValue);
  }

  void _updateValue() {
    if (value != _viewModel.timeRemaining) {
      value = _viewModel.timeRemaining;
    }
  }

  @override
  void dispose() {
    _viewModel.removeListener(_updateValue);
    super.dispose();
  }
}

class _WordNotifier extends ValueNotifier<String> {
  final SoletrandoViewModel _viewModel;

  _WordNotifier(this._viewModel) : super(_viewModel.displayWord.join()) {
    _viewModel.addListener(_updateValue);
  }

  void _updateValue() {
    final newValue = _viewModel.displayWord.join();
    if (value != newValue) {
      value = newValue;
    }
  }

  @override
  void dispose() {
    _viewModel.removeListener(_updateValue);
    super.dispose();
  }
}

class _HintNotifier extends ValueNotifier<int> {
  final SoletrandoViewModel _viewModel;

  _HintNotifier(this._viewModel) : super(_viewModel.hintCount) {
    _viewModel.addListener(_updateValue);
  }

  void _updateValue() {
    if (value != _viewModel.hintCount) {
      value = _viewModel.hintCount;
    }
  }

  @override
  void dispose() {
    _viewModel.removeListener(_updateValue);
    super.dispose();
  }
}

class _KeyboardNotifier extends ValueNotifier<Map<String, Color>> {
  final SoletrandoViewModel _viewModel;

  _KeyboardNotifier(this._viewModel)
      : super(Map.from(_viewModel.letterColors)) {
    _viewModel.addListener(_updateValue);
  }

  void _updateValue() {
    final newValue = Map<String, Color>.from(_viewModel.letterColors);
    if (!_mapsEqual(value, newValue)) {
      value = newValue;
    }
  }

  bool _mapsEqual(Map<String, Color> a, Map<String, Color> b) {
    if (a.length != b.length) return false;
    for (final key in a.keys) {
      if (a[key] != b[key]) return false;
    }
    return true;
  }

  @override
  void dispose() {
    _viewModel.removeListener(_updateValue);
    super.dispose();
  }
}
