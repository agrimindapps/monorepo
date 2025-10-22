# Quiz Image Feature - Clean Architecture + Riverpod

Migração completa do `game_quiz_image` para Clean Architecture seguindo padrões Gold Standard (tictactoe/tower).

## Estrutura

```
lib/features/quiz_image/
├── data/
│   ├── datasources/
│   │   └── quiz_image_local_data_source.dart (15 questões hardcoded + SharedPreferences)
│   ├── models/
│   │   ├── high_score_model.dart
│   │   └── quiz_question_model.dart
│   └── repositories/
│       └── quiz_image_repository_impl.dart
├── domain/
│   ├── entities/
│   │   ├── enums.dart (GameDifficulty, GameStateEnum, AnswerState)
│   │   ├── game_state.dart (IMUTÁVEL - 8 propriedades)
│   │   ├── high_score.dart
│   │   └── quiz_question.dart (IMUTÁVEL)
│   ├── repositories/
│   │   └── quiz_image_repository.dart
│   └── usecases/
│       ├── generate_game_questions_usecase.dart (Seleciona 10 de 15 + ajusta opções)
│       ├── start_game_usecase.dart
│       ├── select_answer_usecase.dart
│       ├── handle_timeout_usecase.dart
│       ├── next_question_usecase.dart
│       ├── update_timer_usecase.dart
│       ├── restart_game_usecase.dart
│       ├── load_high_score_usecase.dart
│       └── save_high_score_usecase.dart
└── presentation/
    ├── pages/
    │   └── quiz_image_page.dart (ConsumerWidget)
    ├── providers/
    │   ├── quiz_image_notifier.dart (@riverpod com Timer)
    │   └── quiz_image_notifier.g.dart (gerado)
    └── widgets/
        ├── answer_option_widget.dart
        ├── question_card_widget.dart
        ├── results_widget.dart (com animação de celebração)
        └── timer_widget.dart

```

## Funcionalidades Preservadas

- ✅ 15 questões de bandeiras (URLs de imagens hardcoded)
- ✅ Seleção aleatória de 10 questões por jogo
- ✅ Timer por questão (easy=30s, medium=20s, hard=15s)
- ✅ Dificuldade altera opções (easy=2, medium=3, hard=4)
- ✅ Sistema de score (% de acertos)
- ✅ High score persistente (SharedPreferences)
- ✅ Estados: ready, playing, gameOver
- ✅ Resposta: unanswered, correct, incorrect
- ✅ Timeout automático (marca incorreta)
- ✅ Delay 2s após resposta antes de avançar
- ✅ Animação de celebração para score ≥70%

## Padrões Implementados

### Riverpod com Code Generation
```dart
@riverpod
class QuizImageNotifier extends _$QuizImageNotifier {
  Timer? _timer;
  int _highScore = 0;

  @override
  Future<QuizGameState> build(GameDifficulty difficulty) async {
    // Inject use cases via GetIt
    // Load high score
    // Generate questions
    // Setup cleanup
  }

  void startGame() { /* ... */ }
  void selectAnswer(String answer) { /* ... */ }
  void _handleTimeout() { /* ... */ }
  void _nextQuestion() { /* ... */ }
  void restartGame() { /* ... */ }
}
```

### Timer Management (Pattern tower)
- Timer.periodic(Duration(seconds: 1)) no notifier
- Cleanup automático via ref.onDispose
- Decremento via UpdateTimerUseCase
- Timeout automático quando timeLeft == 0

### Either<Failure, T> Pattern
Todos os use cases e repository retornam `Either<Failure, T>`:
```dart
Either<Failure, QuizGameState> call(QuizGameState currentState) {
  if (currentState.gameState != GameStateEnum.playing) {
    return const Left(GameLogicFailure('Game is not in playing state'));
  }
  // ...
  return Right(newState);
}
```

### Immutable Entities
```dart
class QuizGameState extends Equatable {
  final List<QuizQuestion> questions;
  final int currentQuestionIndex;
  final int timeLeft;
  final int correctAnswers;
  final GameStateEnum gameState;
  final GameDifficulty difficulty;
  final String? currentSelectedAnswer;
  final AnswerState currentAnswerState;

  const QuizGameState({...});

  QuizGameState copyWith({...}) { /* ... */ }

  @override
  List<Object?> get props => [...];
}
```

## Dependency Injection

Injectable + GetIt (já configurado em `core/di/injection.dart`):

```dart
// Use cases
@injectable
class GenerateGameQuestionsUseCase { /* ... */ }

// Repository
@LazySingleton(as: QuizImageRepository)
class QuizImageRepositoryImpl { /* ... */ }

// Data source
@LazySingleton(as: QuizImageLocalDataSource)
class QuizImageLocalDataSourceImpl { /* ... */ }
```

SharedPreferences já registrado manualmente no DI.

## Uso

```dart
// Na navegação ou roteamento
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (_) => QuizImagePage(difficulty: GameDifficulty.medium),
  ),
);

// Com Riverpod
final gameState = ref.watch(quizImageNotifierProvider(difficulty));
```

## Analyzer Status

```bash
flutter analyze lib/features/quiz_image/
# No issues found!
```

## Code Generation

```bash
dart run build_runner build --delete-conflicting-outputs
```

## Próximos Passos (Sugestões)

1. Adicionar testes unitários para use cases (cobertura ≥80%)
2. Adicionar widget tests para QuizImagePage
3. Implementar telas de seleção de dificuldade
4. Adicionar haptic feedback (como em tower)
5. Implementar sistema de conquistas/badges
6. Adicionar categorias de questões (geografia, história, etc.)

## Arquivos Legados (podem ser removidos após validação)

- `lib/pages/game_quiz_image/` (todo o diretório)
- `lib/models/question.dart` (se não usado em outros lugares)

## Migrado por

- Data: 2025-10-21
- Modelo: Claude Sonnet 4.5
- Status: ✅ COMPLETO - 0 analyzer errors
