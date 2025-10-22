# Campo Minado (Minesweeper)

Clean Architecture implementation of the classic Minesweeper game using Riverpod for state management.

## Architecture

### Domain Layer
- **Entities**: Immutable business objects
  - `GameState`: Complete game state with grid, status, timing
  - `CellData`: Individual cell state (mine, revealed, flagged)
  - `GameStats`: Player statistics and best times
  - `GameConfig`: Grid configuration (rows, cols, mines)
  - `Enums`: GameStatus, Difficulty, CellStatus

- **Repositories**: Abstract interfaces
  - `CampoMinadoRepository`: Stats persistence contract

- **Use Cases**: Business logic (9 total)
  - `RevealCellUseCase`: Cell reveal with flood-fill algorithm
  - `ToggleFlagUseCase`: Flag/question cell marking
  - `ChordClickUseCase`: Auto-reveal neighbors
  - `StartNewGameUseCase`: Initialize new game
  - `TogglePauseUseCase`: Pause/resume control
  - `UpdateTimerUseCase`: Game timer management
  - `LoadStatsUseCase`: Load player statistics
  - `SaveStatsUseCase`: Persist statistics
  - `UpdateStatsUseCase`: Update stats after game

### Data Layer
- **Models**: JSON serialization
  - `GameStatsModel`: Extends GameStats with fromJson/toJson

- **Data Sources**
  - `CampoMinadoLocalDataSource`: SharedPreferences storage

- **Repository Implementation**
  - `CampoMinadoRepositoryImpl`: Stats CRUD operations

### Presentation Layer (Riverpod)
- **Providers** (`campo_minado_game_notifier.dart`)
  - `campoMinadoGameNotifierProvider`: Main game state
  - `campoMinadoStatsProvider`: Statistics per difficulty
  - Derived providers: `isGameActive`, `canInteract`, etc.

- **Pages**
  - `CampoMinadoPage`: Main game page with lifecycle management

- **Widgets**
  - `GameHeaderWidget`: Timer, restart, mine counter
  - `MinefieldWidget`: Responsive grid layout
  - `CellWidget`: Individual cell with gestures
  - `GameOverDialog`: Victory/defeat screen

## Features

### Gameplay
- ✅ Classic minesweeper rules
- ✅ Three difficulty levels (Beginner, Intermediate, Expert)
- ✅ First-click safety (mines placed after first click)
- ✅ Flood-fill reveal for empty cells
- ✅ Flag/question marking (3-state toggle)
- ✅ Chord clicking (double-tap on numbers)
- ✅ Timer with pause functionality
- ✅ Auto-pause on app background

### UI/UX
- ✅ Responsive grid (adapts to screen size)
- ✅ Visual feedback (press states, colors)
- ✅ Touch gestures:
  - Single tap: Reveal cell
  - Long press: Toggle flag
  - Double tap: Chord click
- ✅ Game status indicators (emoji + colors)
- ✅ Help dialog with instructions

### Statistics
- ✅ Best time per difficulty
- ✅ Win/loss tracking
- ✅ Win rate percentage
- ✅ Current/best streak
- ✅ Persistent storage (SharedPreferences)

## Technical Highlights

### Clean Architecture
- ✅ Strict layer separation (Domain/Data/Presentation)
- ✅ Either<Failure, T> error handling
- ✅ Immutable entities with Equatable
- ✅ Use cases with centralized validation

### Riverpod Best Practices
- ✅ Code generation (@riverpod)
- ✅ AsyncValue<T> for async states
- ✅ ConsumerWidget/ConsumerStatefulWidget
- ✅ Provider composition (dependencies)
- ✅ Auto-dispose lifecycle

### Game Logic
- ✅ Recursive flood-fill algorithm
- ✅ Mine placement with safety zone
- ✅ Neighbor mine counting (8-directional)
- ✅ Win condition detection
- ✅ Timer management with pause

## Usage

```dart
// Navigate to game
context.go('/campo-minado');

// Programmatic access
final gameState = ref.watch(campoMinadoGameNotifierProvider);
final notifier = ref.read(campoMinadoGameNotifierProvider.notifier);

// Actions
await notifier.revealCell(row, col);
await notifier.toggleFlag(row, col);
await notifier.restartGame();
await notifier.changeDifficulty(Difficulty.expert);
```

## File Structure

```
lib/features/campo_minado/
├── domain/
│   ├── entities/
│   │   ├── cell_data.dart
│   │   ├── enums.dart
│   │   ├── game_state.dart
│   │   └── game_stats.dart
│   ├── repositories/
│   │   └── campo_minado_repository.dart
│   └── usecases/
│       ├── chord_click_usecase.dart
│       ├── load_stats_usecase.dart
│       ├── reveal_cell_usecase.dart
│       ├── save_stats_usecase.dart
│       ├── start_new_game_usecase.dart
│       ├── toggle_flag_usecase.dart
│       ├── toggle_pause_usecase.dart
│       ├── update_stats_usecase.dart
│       └── update_timer_usecase.dart
├── data/
│   ├── datasources/
│   │   └── campo_minado_local_data_source.dart
│   ├── models/
│   │   └── game_stats_model.dart
│   └── repositories/
│       └── campo_minado_repository_impl.dart
└── presentation/
    ├── pages/
    │   └── campo_minado_page.dart
    ├── providers/
    │   ├── campo_minado_game_notifier.dart
    │   └── campo_minado_game_notifier.g.dart
    └── widgets/
        ├── cell_widget.dart
        ├── game_header_widget.dart
        ├── game_over_dialog.dart
        └── minefield_widget.dart
```

## Testing

```bash
# Run tests
flutter test lib/features/campo_minado/

# Code generation
dart run build_runner watch --delete-conflicting-outputs
```

## Migration Notes

Migrated from legacy Provider implementation to:
- ✅ Clean Architecture (Domain/Data/Presentation)
- ✅ Riverpod state management
- ✅ Use case pattern
- ✅ Either<Failure, T> error handling
- ✅ Code generation
- ✅ 0 analyzer errors

Original location: `lib/pages/game_campo_minado/` (deprecated)
