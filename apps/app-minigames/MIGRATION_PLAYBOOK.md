# 📘 Migration Playbook: Pages → Clean Architecture + Riverpod

**Projeto**: app-minigames
**Data**: 2025-10-21
**Piloto**: game_tictactoe ✅ **COMPLETO**
**Padrão**: Gold Standard (app-plantis 10/10)

---

## 🎯 Objetivo

Migrar todos os 13 jogos de `lib/pages/game_*/` (arquitetura legada com ChangeNotifier) para `lib/features/*/` (Clean Architecture + Riverpod).

---

## 📊 Status de Migração

| Jogo | Status | Complexidade | Esforço | Data |
|------|--------|--------------|---------|------|
| **game_tictactoe** | ✅ **COMPLETO** | BAIXA | 2-3h | 2025-10-21 |
| **game_tower** | ✅ **COMPLETO** | MUITO BAIXA | 2h | 2025-10-21 |
| **game_quiz_image** | ✅ **COMPLETO** | BAIXA | 2h | 2025-10-21 |
| game_quiz | ⏳ Pendente | BAIXA | 3-4h | - |
| game_snake | ⏳ Pendente | BAIXA | 3-4h | - |
| game_caca_palavra | ⏳ Pendente | MÉDIA | 4-6h | - |
| game_campo_minado | ⏳ Pendente | MÉDIA | 4-6h | - |
| game_sudoku | ⏳ Pendente | MÉDIA | 6-8h | - |
| game_soletrando | ⏳ Pendente | MÉDIA | 6-8h | - |
| game_flappbird | ⏳ Pendente | MÉDIA | 6-8h | - |
| game_memory | ⏳ Pendente | ALTA | 8-12h | - |
| game_pingpong | ⏳ Pendente | ALTA | 8-12h | - |
| game_2048 | ⏳ Pendente | MUITO ALTA | 12-16h | - |

**Progresso**: 3/13 (23.1%) | **Esforço consumido**: 7h | **Esforço restante**: 73-105h

---

## 🏗️ Estrutura Padrão (Clean Architecture)

### Antes (Legado - pages/)
```
lib/pages/game_[name]/
├── controllers/           # ❌ ChangeNotifier
├── providers/             # ❌ Mixed patterns
├── models/                # ❌ No separation entities/DTOs
├── services/              # ❌ Static methods, not testable
├── constants/
└── widgets/
```

### Depois (Clean Architecture - features/)
```
lib/features/[game_name]/
├── data/
│   ├── datasources/       # SharedPreferences, Hive, Firebase
│   ├── models/            # JSON serialization (extends entities)
│   └── repositories/      # Repository implementations
├── domain/
│   ├── entities/          # Immutable, business objects
│   ├── repositories/      # Repository interfaces
│   └── usecases/          # Business logic, return Either<Failure, T>
└── presentation/
    ├── providers/         # Riverpod @riverpod notifiers
    ├── pages/             # ConsumerWidget pages
    └── widgets/           # Reusable UI components
```

---

## 📋 Checklist de Migração (Por Jogo)

Use este checklist para cada jogo migrado:

### 1. Preparação (30min)
- [ ] Analisar código atual (`controllers/`, `models/`, `services/`)
- [ ] Identificar funcionalidades críticas
- [ ] Listar dependências (Hive, SharedPreferences, Firebase, etc.)
- [ ] Identificar lógica de negócio vs UI state

### 2. Domain Layer (2-4h)
- [ ] **Entities** (`domain/entities/`)
  - [ ] Criar entities imutáveis (copyWith, Equatable)
  - [ ] Migrar enums (se específicos do jogo)
  - [ ] Definir value objects se necessário

- [ ] **Repository Interfaces** (`domain/repositories/`)
  - [ ] Definir interface do repository
  - [ ] Métodos retornam `Future<Either<Failure, T>>`

- [ ] **Use Cases** (`domain/usecases/`)
  - [ ] Criar use case para cada operação de negócio
  - [ ] Validação de inputs
  - [ ] Retornar `Either<Failure, T>`
  - [ ] Injetar repository via construtor
  - [ ] Anotar com `@injectable`

### 3. Data Layer (1-2h)
- [ ] **Models** (`data/models/`)
  - [ ] Extend entities
  - [ ] Implementar fromJson/toJson
  - [ ] Converter entre Model ↔ Entity

- [ ] **DataSources** (`data/datasources/`)
  - [ ] Interface abstrata
  - [ ] Implementação concreta
  - [ ] Anotar com `@LazySingleton(as: Interface)`
  - [ ] Throw exceptions (CacheException, ServerException)

- [ ] **Repository Implementation** (`data/repositories/`)
  - [ ] Implementar interface do domain
  - [ ] Injetar data sources
  - [ ] Converter exceptions → failures
  - [ ] Anotar com `@LazySingleton(as: Interface)`

### 4. Presentation Layer (2-3h)
- [ ] **Providers** (`presentation/providers/`)
  - [ ] Criar notifier com `@riverpod`
  - [ ] Injetar use cases via GetIt
  - [ ] Gerenciar UI state
  - [ ] Handle AsyncValue (loading/data/error)

- [ ] **Pages** (`presentation/pages/`)
  - [ ] Converter para ConsumerWidget
  - [ ] Usar `ref.watch()` e `ref.read()`
  - [ ] Handle AsyncValue.when()

- [ ] **Widgets** (`presentation/widgets/`)
  - [ ] Migrar widgets reutilizáveis
  - [ ] Usar ConsumerWidget se precisar de ref
  - [ ] Manter stateless quando possível

### 5. Core (Se necessário)
- [ ] **Failures** (`lib/core/error/failures.dart`)
  - [ ] Adicionar novos Failure types se necessário

- [ ] **Exceptions** (`lib/core/error/exceptions.dart`)
  - [ ] Adicionar novos Exception types se necessário

### 6. Dependency Injection (30min)
- [ ] Executar code generation
  ```bash
  dart run build_runner build --delete-conflicting-outputs
  ```
- [ ] Validar registro automático com `@injectable`
- [ ] Testar injeção manual se necessário

### 7. Validação (1h)
- [ ] Executar `flutter analyze` - **0 errors**
- [ ] Build success
- [ ] Teste manual de todas funcionalidades
- [ ] Performance OK (sem regressão)
- [ ] Acessibilidade mantida

### 8. Limpeza (15min)
- [ ] Mover código antigo para backup (não deletar ainda)
- [ ] Atualizar imports no router
- [ ] Documentar mudanças específicas

---

## 🎓 Padrões Aprendidos (game_tictactoe)

### ✅ DO's (Faça)

#### 1. Use Cases: Uma Responsabilidade (SRP)
```dart
@injectable
class MakeMoveUseCase {
  final TicTacToeRepository repository;

  MakeMoveUseCase(this.repository);

  Future<Either<Failure, GameState>> call({
    required GameState currentState,
    required int row,
    required int col,
  }) async {
    // 1. Validação
    if (!currentState.isInProgress) {
      return Left(GameLogicFailure('Game is not in progress'));
    }

    if (!currentState.isCellEmpty(row, col)) {
      return Left(ValidationFailure('Cell is not empty'));
    }

    // 2. Lógica de negócio
    final newBoard = _executeMove(currentState.board, row, col, currentState.currentPlayer);

    // 3. Retorna novo estado
    return Right(currentState.copyWith(
      board: newBoard,
      currentPlayer: currentState.currentPlayer.opponent,
    ));
  }
}
```

#### 2. Entities: Imutáveis com copyWith
```dart
class GameState extends Equatable {
  final List<List<Player>> board;
  final Player currentPlayer;
  final GameResult result;

  const GameState({
    required this.board,
    required this.currentPlayer,
    required this.result,
  });

  // ✅ Helper methods OK (não lógica de negócio)
  bool isCellEmpty(int row, int col) => board[row][col] == Player.none;

  GameState copyWith({
    List<List<Player>>? board,
    Player? currentPlayer,
    GameResult? result,
  }) {
    return GameState(
      board: board ?? this.board,
      currentPlayer: currentPlayer ?? this.currentPlayer,
      result: result ?? this.result,
    );
  }

  @override
  List<Object?> get props => [board, currentPlayer, result];
}
```

#### 3. Models: fromJson/toJson + Extends Entity
```dart
class GameStatsModel extends GameStats {
  const GameStatsModel({
    required super.xWins,
    required super.oWins,
    required super.draws,
  });

  factory GameStatsModel.fromJson(Map<String, dynamic> json) {
    return GameStatsModel(
      xWins: json['xWins'] as int? ?? 0,
      oWins: json['oWins'] as int? ?? 0,
      draws: json['draws'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'xWins': xWins,
      'oWins': oWins,
      'draws': draws,
    };
  }
}
```

#### 4. DataSources: @LazySingleton + Throw Exceptions
```dart
@LazySingleton(as: TicTacToeLocalDataSource)
class TicTacToeLocalDataSourceImpl implements TicTacToeLocalDataSource {
  final SharedPreferences sharedPreferences;

  TicTacToeLocalDataSourceImpl(this.sharedPreferences);

  @override
  Future<GameStatsModel> getStats() async {
    try {
      final xWins = sharedPreferences.getInt(_xWinsKey) ?? 0;
      final oWins = sharedPreferences.getInt(_oWinsKey) ?? 0;
      final draws = sharedPreferences.getInt(_drawsKey) ?? 0;

      return GameStatsModel(xWins: xWins, oWins: oWins, draws: draws);
    } catch (e) {
      throw CacheException();  // ✅ Throw exception no data layer
    }
  }
}
```

#### 5. Repository: Convert Exceptions → Failures
```dart
@LazySingleton(as: TicTacToeRepository)
class TicTacToeRepositoryImpl implements TicTacToeRepository {
  final TicTacToeLocalDataSource localDataSource;

  TicTacToeRepositoryImpl(this.localDataSource);

  @override
  Future<Either<Failure, GameStats>> getStats() async {
    try {
      final stats = await localDataSource.getStats();
      return Right(stats);  // ✅ Success
    } on CacheException {
      return Left(CacheFailure());  // ✅ Exception → Failure
    }
  }
}
```

#### 6. Riverpod: @riverpod + AsyncValue
```dart
@riverpod
class TicTacToeGameNotifier extends _$TicTacToeGameNotifier {
  late final MakeMoveUseCase _makeMoveUseCase;
  late final LoadStatsUseCase _loadStatsUseCase;

  @override
  FutureOr<GameState> build() async {
    // ✅ Inject use cases via GetIt
    _makeMoveUseCase = getIt<MakeMoveUseCase>();
    _loadStatsUseCase = getIt<LoadStatsUseCase>();

    return GameState.initial();
  }

  Future<void> makeMove(int row, int col) async {
    final currentState = state.valueOrNull;
    if (currentState == null) return;

    state = const AsyncValue.loading();  // ✅ Loading state

    final result = await _makeMoveUseCase(
      currentState: currentState,
      row: row,
      col: col,
    );

    result.fold(
      (failure) => state = AsyncValue.error(failure, StackTrace.current),  // ✅ Error
      (newState) => state = AsyncValue.data(newState),  // ✅ Success
    );
  }
}
```

#### 7. UI: ConsumerWidget + AsyncValue.when()
```dart
class TicTacToePage extends ConsumerWidget {
  const TicTacToePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameState = ref.watch(ticTacToeGameNotifierProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Jogo da Velha')),
      body: gameState.when(
        data: (state) => GameBoardWidget(
          gameState: state,
          onCellTapped: (row, col) {
            ref.read(ticTacToeGameNotifierProvider.notifier).makeMove(row, col);
          },
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Erro: $error')),
      ),
    );
  }
}
```

### ❌ DON'Ts (Evite)

#### 1. ❌ Static Methods em Services
```dart
// ❌ ERRADO - Não testável, não injetável
class GameStorageService {
  static Future<Map<String, int>> loadStats() async {
    final prefs = await SharedPreferences.getInstance();
    return {...};
  }
}

// ✅ CORRETO - Injetável, testável
@LazySingleton(as: TicTacToeLocalDataSource)
class TicTacToeLocalDataSourceImpl implements TicTacToeLocalDataSource {
  final SharedPreferences sharedPreferences;

  TicTacToeLocalDataSourceImpl(this.sharedPreferences);

  Future<GameStatsModel> loadStats() async {
    return GameStatsModel(...);
  }
}
```

#### 2. ❌ Lógica de Negócio em Controllers/Notifiers
```dart
// ❌ ERRADO - Business logic no controller
class TicTacToeController extends ChangeNotifier {
  void makeMove(int row, int col) {
    if (result != GameResult.inProgress) return;  // ❌ Validation
    if (!isCellEmpty(row, col)) return;           // ❌ Validation

    board[row][col] = currentPlayer;              // ❌ Business logic
    _checkGameResult();                           // ❌ Business logic
    _nextPlayer();                                // ❌ Business logic

    notifyListeners();
  }
}

// ✅ CORRETO - Delega para use case
@riverpod
class TicTacToeGameNotifier extends _$TicTacToeGameNotifier {
  Future<void> makeMove(int row, int col) async {
    final result = await _makeMoveUseCase(  // ✅ Delegation
      currentState: state.valueOrNull!,
      row: row,
      col: col,
    );

    result.fold(
      (failure) => state = AsyncValue.error(failure, StackTrace.current),
      (newState) => state = AsyncValue.data(newState),
    );
  }
}
```

#### 3. ❌ ChangeNotifier (Provider Legado)
```dart
// ❌ ERRADO - Legacy Provider
class TicTacToeController extends ChangeNotifier {
  int _xWins = 0;

  void updateWins() {
    _xWins++;
    notifyListeners();  // ❌ Manual lifecycle
  }

  @override
  void dispose() {  // ❌ Manual dispose
    super.dispose();
  }
}

// ✅ CORRETO - Riverpod @riverpod
@riverpod
class TicTacToeStats extends _$TicTacToeStats {
  @override
  FutureOr<GameStats> build() async {  // ✅ Auto-dispose
    final result = await _loadStatsUseCase();
    return result.fold(
      (failure) => throw failure,
      (stats) => stats,
    );
  }

  // Sem dispose necessário ✅
}
```

#### 4. ❌ Throw Exceptions em Use Cases
```dart
// ❌ ERRADO - Throw exceptions
@injectable
class MakeMoveUseCase {
  Future<GameState> call(...) async {
    if (!currentState.isInProgress) {
      throw GameException('Game is not in progress');  // ❌ Throw
    }
    return newState;
  }
}

// ✅ CORRETO - Return Either<Failure, T>
@injectable
class MakeMoveUseCase {
  Future<Either<Failure, GameState>> call(...) async {
    if (!currentState.isInProgress) {
      return Left(GameLogicFailure('Game is not in progress'));  // ✅ Left
    }
    return Right(newState);  // ✅ Right
  }
}
```

#### 5. ❌ Lógica de Negócio em Entities
```dart
// ❌ ERRADO - Business logic na entity
class GameState extends Equatable {
  void makeMove(int row, int col) {  // ❌ Mutation
    board[row][col] = currentPlayer;
    _checkWinner();
    _switchPlayer();
  }
}

// ✅ CORRETO - Entity apenas dados + helpers
class GameState extends Equatable {
  bool isCellEmpty(int row, int col) => board[row][col] == Player.none;  // ✅ Helper
  bool get isInProgress => result == GameResult.inProgress;              // ✅ Computed

  GameState copyWith({...}) {...}  // ✅ Immutability
}
```

---

## 🔧 Comandos Úteis

### Code Generation
```bash
# Watch mode (desenvolvimento)
dart run build_runner watch --delete-conflicting-outputs

# Build único
dart run build_runner build --delete-conflicting-outputs
```

### Análise
```bash
# Analisar todo o app
flutter analyze

# Analisar feature específica
flutter analyze lib/features/tictactoe/

# Ver apenas errors/warnings
flutter analyze | grep -E "(error|warning)"
```

### Testes
```bash
# Todos os testes
flutter test

# Teste específico
flutter test test/features/tictactoe/

# Com coverage
flutter test --coverage
```

---

## 📊 Métricas de Qualidade

Para cada jogo migrado, validar:

| Métrica | Target | Piloto (tictactoe) |
|---------|--------|---------------------|
| Analyzer Errors | 0 | ✅ 0 |
| Analyzer Warnings (críticos) | 0 | ✅ 0 |
| ChangeNotifier usage | 0 | ✅ 0 |
| @riverpod providers | ≥1 | ✅ 1 |
| Use cases with Either<F,T> | 100% | ✅ 100% (8/8) |
| @injectable annotations | 100% | ✅ 100% |
| Code generation success | ✅ | ✅ *.g.dart gerado |
| Build success | ✅ | ✅ OK |
| Funcionalidades mantidas | 100% | ✅ 100% |

---

## 🚀 Próximos Passos

### Imediato (Próximos 7 dias)
1. ✅ **Validar piloto** - Teste manual game_tictactoe
2. ⏳ **Migrar game_tower** - Jogo mais simples (2-3h)
3. ⏳ **Migrar game_quiz_image** - Similar ao piloto (2-3h)
4. ⏳ **Documentar learnings** - Atualizar este playbook

### Curto prazo (2-4 semanas)
5. ⏳ Migrar 4 jogos médios (quiz, snake, caca_palavra, campo_minado)
6. ⏳ Extrair serviços compartilhados para `packages/core/`

### Médio prazo (1-2 meses)
7. ⏳ Migrar jogos complexos (sudoku, soletrando, flappbird, memory, pingpong, 2048)
8. ⏳ Remover Provider do pubspec.yaml
9. ⏳ Adicionar testes (≥80% coverage)

### Longo prazo (3 meses)
10. ⏳ Deletar código legacy (`lib/pages/`)
11. ⏳ Documentação profissional (README)
12. ⏳ Alcançar score 10/10 (igualar app-plantis)

---

## 📝 Notas de Implementação

### game_tictactoe (Piloto) ✅

**Data**: 2025-10-21
**Tempo**: ~3h
**Complexidade**: BAIXA

**Funcionalidades Migradas**:
- ✅ Jogo da velha 3x3
- ✅ Modo vs Jogador e vs Computador
- ✅ IA com 3 dificuldades (easy/medium/hard)
- ✅ Cache de IA com memoização
- ✅ Estatísticas (X wins, O wins, draws)
- ✅ Persistência (SharedPreferences)
- ✅ Acessibilidade (SemanticsService)

**Challenges**:
- IA com cache: Movida para use case `MakeAIMoveUseCase`
- Analytics: Preparado para futuro (GameAnalytics entity criada)
- Acessibilidade: Mantida no notifier

**Learnings**:
1. Use cases para lógica de IA ficam limpos e testáveis
2. Cache pode ser mantido como singleton no data layer
3. Accessibility announcements podem ir no notifier temporariamente

**Arquivos Criados**: 25 arquivos
- 8 use cases
- 5 entities
- 3 models
- 2 data sources
- 2 repositories
- 1 notifier + 1 .g.dart
- 4 widgets

---

## 🎓 Referências

- **Gold Standard**: `/apps/app-plantis/` (Score 10/10)
- **Guia de Migração**: `.claude/guides/MIGRATION_PROVIDER_TO_RIVERPOD.md`
- **Padrões Arquiteturais**: `.claude/agents/flutter-architect.md`
- **Código Piloto**: `/apps/app-minigames/lib/features/tictactoe/`

---

## ✅ Critérios de Sucesso Global

Migração será considerada 100% completa quando:

- [ ] Todos 13 jogos migrados para Clean Architecture
- [ ] 0 erros analyzer em todo o app
- [ ] Provider removido do pubspec.yaml
- [ ] Testes adicionados (≥80% coverage em use cases)
- [ ] Código legacy deletado (`lib/pages/`)
- [ ] README profissional criado
- [ ] Score 10/10 alcançado (igualar app-plantis)

**Estimativa de Conclusão**: 8-11 semanas (part-time 10h/semana)

---

---

## 📝 Notas de Implementação - game_tower ✅

**Data**: 2025-10-21
**Tempo**: ~2h
**Complexidade**: MUITO BAIXA

**Funcionalidades Migradas**:
- ✅ Jogo de empilhar blocos (Stack Tower)
- ✅ Movimento horizontal automático
- ✅ Sistema de overlap e precisão
- ✅ Sistema de combo (colocações perfeitas ≥90%)
- ✅ Pontuação com multiplicador de combo
- ✅ High score persistente (SharedPreferences)
- ✅ 3 dificuldades (easy/medium/hard com speedMultiplier)
- ✅ Pause/Resume
- ✅ Feedback háptico (light/medium/heavy)
- ✅ Game loop Timer (16ms - ~60 FPS)
- ✅ Animação de combo
- ✅ Background com nuvens animadas

**Challenges**:
- **Game Loop**: Timer.periodic 16ms movido para notifier (gerencia lifecycle)
- **Physics Logic**: Overlap/precisão/combo isolados no DropBlockUseCase
- **State Immutability**: GameState imutável com 14 propriedades + copyWith

**Learnings**:
1. **Timer no Notifier**: Game loops podem ser gerenciados em Riverpod notifiers com dispose
2. **Physics em Use Cases**: Lógica de física do jogo funciona perfeitamente isolada
3. **State Granular**: GameState detalhado facilita debugging (14 props vs mutations)
4. **Haptic Feedback**: Pode ser mantido no notifier após execução de use cases

**Arquivos Criados**: 23 arquivos
- 7 use cases (drop_block, update_moving, start_new, toggle_pause, change_difficulty, load/save score)
- 4 entities (GameState, BlockData, HighScore, enums)
- 1 model (HighScoreModel)
- 2 data sources (interface + impl)
- 2 repositories (interface + impl)
- 1 notifier + 1 .g.dart
- 5 widgets (game_board, block, clouds_background, game_over_dialog, pause_dialog)

**Diferenças vs tictactoe**:
- Tower tem game loop (Timer.periodic) vs tictactoe que é event-driven
- Tower tem física real-time vs tictactoe que é turn-based
- Tower tem 1 score vs tictactoe que tem stats (xWins, oWins, draws)

---

## 📝 Notas de Implementação - game_quiz_image ✅

**Data**: 2025-10-21
**Tempo**: ~2h
**Complexidade**: BAIXA

**Funcionalidades Migradas**:
- ✅ Quiz de bandeiras com imagens
- ✅ 15 questões hardcoded (URLs exatas preservadas)
- ✅ Seleção aleatória de 10 questões por jogo
- ✅ Timer por questão (easy=30s, medium=20s, hard=15s)
- ✅ Dificuldade altera número de opções (easy=2, medium=3, hard=4)
- ✅ Sistema de score (% de acertos)
- ✅ High score persistente
- ✅ Estados: ready → playing → gameOver
- ✅ Feedback visual (cores para correct/incorrect)
- ✅ Timeout automático (marca como incorreta)
- ✅ Delay de 2s após resposta antes de avançar
- ✅ Animação de celebração para scores ≥70%

**Challenges**:
- **QuizQuestion Imutável**: Entidade antes tinha estado mutável (answerState, timeSpent, selectedAnswer)
- **Estado Movido para GameState**: Estado da resposta atual agora vive em QuizGameState
- **Timer + Delay**: Combinar Timer de 1s + Delay de 2s sem conflitos
- **Questões Hardcoded**: 15 questões com URLs movidas para data source

**Learnings**:
1. **Entities Realmente Imutáveis**: QuizQuestion sem estado interno, tudo em GameState
2. **Data Source para Dados Estáticos**: Questões hardcoded pertencem ao data layer
3. **Timer + Future.delayed**: Podem coexistir no notifier sem problemas
4. **Adjust Logic no Use Case**: Lógica de ajustar opções por dificuldade isolada

**Arquivos Criados**: 25 arquivos
- 9 use cases (generate_questions, select_answer, handle_timeout, next_question, update_timer, start/restart, load/save score)
- 4 entities (QuizQuestion, QuizGameState, HighScore, enums)
- 2 models (QuizQuestionModel, HighScoreModel)
- 2 data sources (interface + impl com 15 questões)
- 2 repositories (interface + impl)
- 1 notifier + 1 .g.dart
- 5 widgets (question_card, answer_option, timer, results, page)

**Diferenças vs anteriores**:
- quiz_image trabalha com dados estáticos (15 questões hardcoded) vs tower/tictactoe que geram estado
- quiz_image tem delay após resposta (Future.delayed 2s) vs outros que são imediatos
- quiz_image tem Timer + Delay coexistindo vs tower que só tem Timer

---

**Última Atualização**: 2025-10-21 (Fase 3 Completa - 3/13 jogos)
**Mantido por**: Claude Code (flutter-engineer agent)
