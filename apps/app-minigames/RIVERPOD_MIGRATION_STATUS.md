# Migração GetIt → Riverpod: app-minigames

**Data de Início:** 24 de novembro de 2025  
**Status:** Em Progresso (21% completo)

---

## 📊 Resumo Executivo

Iniciada a migração do sistema de injeção de dependências de **GetIt/Injectable** para **Riverpod** no app-minigames, que possui 14 features de jogos.

### Progresso Geral
- ✅ **3/14 features** completamente migradas (21%)
- 🔄 **11/14 features** pendentes (79%)
- ✅ Core providers implementados
- ⚠️ GetIt/Injectable mantidos temporariamente para compatibilidade

---

## ✅ Features Migradas (Riverpod 100%)

### 1. **Game 2048** 
**Arquivos Criados:**
- `lib/features/game_2048/presentation/providers/game_2048_providers.dart`
- Gerado: `game_2048_providers.g.dart`

**Providers Criados:**
- `game2048LocalDataSourceProvider` → Data source local
- `game2048RepositoryProvider` → Repository
- `moveTilesUseCaseProvider` → Use case para movimento de tiles
- `spawnTileUseCaseProvider` → Use case para spawn de tiles
- `checkGameOverUseCaseProvider` → Use case para verificar game over
- `restartGameUseCaseProvider` → Use case para reiniciar jogo
- `loadHighScoreUseCaseProvider` → Use case para carregar high score
- `saveHighScoreUseCaseProvider` → Use case para salvar high score

**Arquivos Modificados:**
- `lib/features/game_2048/presentation/providers/game_2048_notifier.dart`
  - Removido: `import 'package:get_it/get_it.dart'`
  - Adicionado: `import 'game_2048_providers.dart'`
  - Substituído: `GetIt.instance<UseCase>()` → `ref.read(useCaseProvider)`

**Padrão de Migração:**
```dart
// ANTES (GetIt)
@override
GameStateEntity build() {
  final sl = GetIt.instance;
  _moveTilesUseCase = sl<MoveTilesUseCase>();
  // ...
}

Future<void> move(Direction direction) async {
  final moveResult = await _moveTilesUseCase(state, direction);
  // ...
}

// DEPOIS (Riverpod)
@override
GameStateEntity build() {
  // Sem inicialização de use cases
  return GameStateEntity.initial(boardSize: BoardSize.size4x4);
}

Future<void> move(Direction direction) async {
  final moveTilesUseCase = ref.read(moveTilesUseCaseProvider);
  final moveResult = await moveTilesUseCase(state, direction);
  // ...
}
```

---

### 2. **Memory**
**Arquivos Criados:**
- `lib/features/memory/presentation/providers/memory_providers.dart`
- Gerado: `memory_providers.g.dart`

**Providers Criados:**
- `memoryLocalDataSourceProvider` → Data source local
- `memoryRepositoryProvider` → Repository
- `generateCardsUseCaseProvider` → Use case para gerar cartas
- `flipCardUseCaseProvider` → Use case para virar carta
- `checkMatchUseCaseProvider` → Use case para verificar match
- `restartGameUseCaseProvider` → Use case para reiniciar jogo
- `loadHighScoreUseCaseProvider` → Use case para carregar high score
- `saveHighScoreUseCaseProvider` → Use case para salvar high score

**Arquivos Modificados:**
- `lib/features/memory/presentation/providers/memory_game_notifier.dart`
  - Removido: `import 'package:get_it/get_it.dart'`
  - Removidos: Providers duplicados no final do arquivo (movidos para `memory_providers.dart`)

---

### 3. **Soletrando**
**Arquivos Criados:**
- `lib/features/soletrando/presentation/providers/soletrando_providers.dart`
- Gerado: `soletrando_providers.g.dart`

**Providers Criados:**
- `soletrandoWordsDataSourceProvider` → Data source de palavras
- `soletrandoLocalDataSourceProvider` → Data source local (async)
- `soletrandoRepositoryProvider` → Repository (async)
- `generateWordUseCaseProvider` → Use case para gerar palavra (async)
- `skipWordUseCaseProvider` → Use case para pular palavra (async)
- `restartGameUseCaseProvider` → Use case para reiniciar jogo (async)

**Arquivos Modificados:**
- `lib/features/soletrando/presentation/providers/soletrando_game_notifier.dart`
  - Removido: `import 'package:get_it/get_it.dart'`
  - Removidos: Providers duplicados (movidos para `soletrando_providers.dart`)

**Padrão Async:**
```dart
@riverpod
Future<SoletrandoRepository> soletrandoRepository(
  SoletrandoRepositoryRef ref,
) async {
  final localDataSource = await ref.watch(soletrandoLocalDataSourceProvider.future);
  final wordsDataSource = ref.watch(soletrandoWordsDataSourceProvider);
  
  return SoletrandoRepositoryImpl(
    localDataSource: localDataSource,
    wordsDataSource: wordsDataSource,
  );
}
```

---

## 🔄 Core Providers (100% Migrado)

**Arquivo:** `lib/core/providers/core_providers.dart`

**Providers Disponíveis:**
```dart
@Riverpod(keepAlive: true)
SharedPreferences sharedPreferences(SharedPreferencesRef ref) { ... }

@Riverpod(keepAlive: true)
FirebaseFirestore firebaseFirestore(FirebaseFirestoreRef ref) { ... }

@Riverpod(keepAlive: true)
FirebaseAuth firebaseAuth(FirebaseAuthRef ref) { ... }

@Riverpod(keepAlive: true)
Logger logger(LoggerRef ref) { ... }

@Riverpod(keepAlive: true)
Random random(RandomRef ref) { ... }
```

**Nota:** `sharedPreferencesProvider` deve ser overridden no `ProviderScope` em `main.dart`:
```dart
final sharedPrefs = await SharedPreferences.getInstance();
runApp(
  ProviderScope(
    overrides: [
      sharedPreferencesProvider.overrideWithValue(sharedPrefs),
    ],
    child: const App(),
  ),
);
```

---

## ⚠️ Features Pendentes (Ainda usam GetIt)

### Features que ainda precisam de migração:

1. **Caça Palavra** (`caca_palavra`)
   - Usa: `@module`, `@lazySingleton`, `@LazySingleton`
   - Services: `GridGeneratorService`, `WordDictionaryService`, `WordSelectionService`

2. **Campo Minado** (`campo_minado`)
   - Usa: `@lazySingleton`
   - Services: `FloodFillService`, `MineGeneratorService`, `NeighborCalculatorService`
   - **Observação:** Notifier já está em Riverpod, apenas services precisam migrar

3. **Flappbird**
   - Usa: `@module`, `@Singleton`, `@lazySingleton`
   - Services: `CollisionService`, `PhysicsService`, `PipeGeneratorService`

4. **Pingpong**
   - Usa: `@module`, `@lazySingleton`
   - Services: `AiPaddleService`, `BallPhysicsService`, `CollisionDetectionService`, `ScoreManagerService`
   - UseCases: Todos marcados com `@lazySingleton`

5. **Quiz**
   - Usa: `@LazySingleton`, `@injectable`
   - DataSource: `QuizLocalDataSourceImpl`
   - Repository: `QuizRepositoryImpl`
   - Services: `AnswerValidationService`, `LifeManagementService`, `QuestionManagerService`
   - UseCases: Todos marcados com `@injectable`

6. **Quiz Image**
   - Similar ao Quiz
   - Usa: `@LazySingleton`, `@injectable`

7. **Snake**
   - Usa: `@LazySingleton`, `@injectable`
   - DataSource: `SnakeLocalDataSourceImpl`
   - Repository: `SnakeRepositoryImpl`
   - Services: `CollisionDetectionService`, `FoodGeneratorService`, `GameStateManagerService`, `SnakeMovementService`
   - UseCases: Todos marcados com `@injectable`

8. **Sudoku**
   - Usa: `@module`, `@lazySingleton`, `@injectable`
   - Services: `ConflictManagerService`, `GridValidationService`, `HintGeneratorService`, `PuzzleGeneratorService`
   - UseCases: `GeneratePuzzleUseCase`, `ValidateMoveUseCase`

9. **TicTacToe**
   - Usa: `@LazySingleton`, `@lazySingleton`, `@injectable`
   - DataSource: `TicTacToeLocalDataSourceImpl`
   - Repository: `TicTacToeRepositoryImpl`
   - Services: `AIMoveStrategyService`, `GameResultValidationService`, `MoveCacheService`
   - UseCases: Todos marcados com `@injectable`

10. **Tower**
    - Usa: `@LazySingleton`, `@lazySingleton`, `@injectable`
    - DataSource: `TowerLocalDataSourceImpl`
    - Repository: `TowerRepositoryImpl`
    - Services: `BlockGenerationService`, `OverlapCalculationService`, `PhysicsService`, `ScoringService`
    - UseCases: Todos marcados com `@injectable`

11. **Soletrando** (Services ainda com `@lazySingleton`)
    - Services pendentes: `GameStateManagerService`, `HintManagerService`, `LetterValidationService`, `ScoreCalculationService`

---

## 📝 Dependências Atuais

**pubspec.yaml:**
```yaml
dependencies:
  flutter_riverpod: any
  riverpod_annotation: any
  
  # Legacy DI - TODO: Remove after completing full Riverpod migration
  # Currently used by 11 features still pending migration
  injectable: ^2.6.0
  get_it: ^9.1.0

dev_dependencies:
  build_runner: ^2.4.12
  riverpod_generator: ^2.4.0
  
  # Legacy - TODO: Remove after completing full Riverpod migration
  injectable_generator: ^2.7.0
```

---

## 🎯 Próximos Passos

### Prioridade Alta (P1)
1. **Campo Minado** - Notifier já migrado, apenas services
2. **Quiz** - Feature popular, 9 use cases
3. **Snake** - 7 use cases, estrutura similar ao já migrado

### Prioridade Média (P2)
4. **TicTacToe** - 8 use cases
5. **Sudoku** - 2 use cases principais
6. **Tower** - 7 use cases

### Prioridade Baixa (P3)
7-11. Demais features (menos complexas)

---

## 📋 Checklist por Feature

Para cada feature pendente, seguir os passos:

- [ ] Criar `[feature]_providers.dart` com providers Riverpod
- [ ] Migrar data sources para providers
- [ ] Migrar repositories para providers
- [ ] Migrar services para providers (se houver)
- [ ] Migrar use cases para providers
- [ ] Atualizar notifier para usar `ref.read()` em vez de `GetIt.instance`
- [ ] Remover imports de `get_it` e `injectable`
- [ ] Remover arquivo `di/[feature]_injection.dart`
- [ ] Executar `dart run build_runner build --delete-conflicting-outputs`
- [ ] Testar feature

---

## ⚙️ Comandos Úteis

```bash
# Gerar código Riverpod
cd /Users/lucineiloch/Documents/deveopment/monorepo/apps/app-minigames
dart run build_runner build --delete-conflicting-outputs

# Analisar código
flutter analyze

# Testar web build
flutter build web --release

# Limpar build artifacts
flutter clean && flutter pub get
```

---

## 📊 Estimativas de Tempo

| Feature | Complexidade | Tempo Estimado | Status |
|---------|-------------|----------------|---------|
| Game 2048 | Média | 2-3h | ✅ Completo |
| Memory | Média | 2-3h | ✅ Completo |
| Soletrando | Média | 2-3h | ✅ Completo |
| Campo Minado | Baixa | 1-2h | ⏳ Pendente |
| Quiz | Alta | 3-4h | ⏳ Pendente |
| Quiz Image | Alta | 3-4h | ⏳ Pendente |
| Snake | Média | 2-3h | ⏳ Pendente |
| TicTacToe | Média | 2-3h | ⏳ Pendente |
| Sudoku | Baixa | 1-2h | ⏳ Pendente |
| Tower | Média | 2-3h | ⏳ Pendente |
| Pingpong | Média | 2-3h | ⏳ Pendente |
| Flappbird | Média | 2-3h | ⏳ Pendente |
| Caça Palavra | Baixa | 1-2h | ⏳ Pendente |

**Total Estimado Restante:** ~22-32 horas

---

## ✅ Conclusão Parcial

A migração das 3 primeiras features demonstrou que o padrão funciona perfeitamente:

1. **Providers Riverpod** são mais declarativos que `GetIt.registerLazySingleton()`
2. **Type-safety** melhorada - erros de tipo detectados em compile-time
3. **Hot-reload** funciona melhor com Riverpod
4. **Testabilidade** facilitada - `ProviderContainer` vs `GetIt.reset()`

As features migradas **coexistem pacificamente** com as features legadas (GetIt), permitindo migração incremental sem quebrar o app.

---

**Última Atualização:** 24 de novembro de 2025  
**Build Runner:** Executado com sucesso (warnings sobre dependências não registradas são esperados durante transição)
**Compilação:** ✅ Passou
