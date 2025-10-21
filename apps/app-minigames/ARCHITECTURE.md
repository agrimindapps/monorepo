# Architecture - app-minigames

## 🏗️ Application Architecture

### High-Level Overview

```
┌─────────────────────────────────────────────────────────────┐
│                         app-minigames                        │
│                    (Flutter Multi-Platform)                  │
└─────────────────────────────────────────────────────────────┘
                              │
                    ┌─────────┴─────────┐
                    │                   │
            ┌───────▼──────┐    ┌──────▼───────┐
            │   Mobile UI  │    │  Desktop UI  │
            │  (< 600px)   │    │  (≥ 600px)   │
            └───────┬──────┘    └──────┬───────┘
                    │                   │
                    └─────────┬─────────┘
                              │
                    ┌─────────▼─────────┐
                    │   Game Router     │
                    │   (go_router)     │
                    └─────────┬─────────┘
                              │
          ┌───────────────────┼───────────────────┐
          │                   │                   │
    ┌─────▼─────┐      ┌──────▼──────┐    ┌──────▼──────┐
    │  Puzzle   │      │   Action    │    │   Words     │
    │   Games   │      │   Games     │    │   Games     │
    │  (2048,   │      │  (Snake,    │    │  (Quiz,     │
    │  Sudoku,  │      │  Flappy,    │    │  Spelling,  │
    │  Minesweep│      │  PingPong)  │    │  WordSearch)│
    │  Memory)  │      │             │    │             │
    └─────┬─────┘      └──────┬──────┘    └──────┬──────┘
          │                   │                   │
          └───────────────────┼───────────────────┘
                              │
                    ┌─────────▼─────────┐
                    │   Riverpod State  │
                    │   Management      │
                    └─────────┬─────────┘
                              │
          ┌───────────────────┼───────────────────┐
          │                   │                   │
    ┌─────▼─────┐      ┌──────▼──────┐    ┌──────▼──────┐
    │  Game     │      │  Theme      │    │  Storage    │
    │  Logic    │      │  System     │    │  (Hive)     │
    └─────┬─────┘      └──────┬──────┘    └──────┬──────┘
          │                   │                   │
          └───────────────────┼───────────────────┘
                              │
                    ┌─────────▼─────────┐
                    │   Firebase        │
                    │   (Auth, Store,   │
                    │   Leaderboards)   │
                    └───────────────────┘
```

---

## 📱 Layer Architecture (Clean Architecture)

### Layer Diagram

```
┌───────────────────────────────────────────────────────────┐
│                    PRESENTATION LAYER                     │
│  ┌─────────────────────────────────────────────────────┐ │
│  │  Pages (StatelessWidget/ConsumerWidget)            │ │
│  │  - mobile_page.dart, desktop_page.dart              │ │
│  │  - game_*/game_*_page.dart (13 games)               │ │
│  └─────────────────┬───────────────────────────────────┘ │
│                    │ uses                                 │
│  ┌─────────────────▼───────────────────────────────────┐ │
│  │  Widgets (Reusable UI Components)                   │ │
│  │  - game_card.dart, appbar_widget.dart               │ │
│  │  - Game-specific widgets per game                   │ │
│  └─────────────────┬───────────────────────────────────┘ │
│                    │ consumes                             │
│  ┌─────────────────▼───────────────────────────────────┐ │
│  │  Riverpod Providers (State Management)              │ │
│  │  - themeNotifierProvider                            │ │
│  │  - gameStateProviders (per game)                    │ │
│  └─────────────────────────────────────────────────────┘ │
└─────────────────────────┬─────────────────────────────────┘
                          │
┌─────────────────────────▼─────────────────────────────────┐
│                      DOMAIN LAYER                         │
│  ┌─────────────────────────────────────────────────────┐ │
│  │  Models (Business Entities)                         │ │
│  │  - GameInfo, PlayerProfile, GameStatistics          │ │
│  │  - Game-specific models (Board, Position, etc.)     │ │
│  └─────────────────┬───────────────────────────────────┘ │
│                    │                                       │
│  ┌─────────────────▼───────────────────────────────────┐ │
│  │  Game Logic (Business Rules)                        │ │
│  │  - Scoring, validation, difficulty                  │ │
│  │  - Game-specific controllers                        │ │
│  └─────────────────────────────────────────────────────┘ │
└─────────────────────────┬─────────────────────────────────┘
                          │
┌─────────────────────────▼─────────────────────────────────┐
│                       DATA LAYER                          │
│  ┌─────────────────────────────────────────────────────┐ │
│  │  Services (Business Services)                       │ │
│  │  - TimerService, DialogManager                      │ │
│  │  - StorageService, PersistenceService               │ │
│  └─────────────────┬───────────────────────────────────┘ │
│                    │                                       │
│  ┌─────────────────▼───────────────────────────────────┐ │
│  │  Storage (Local Persistence)                        │ │
│  │  - Hive (game scores, settings)                     │ │
│  │  - SharedPreferences (user preferences)             │ │
│  └─────────────────┬───────────────────────────────────┘ │
│                    │                                       │
│  ┌─────────────────▼───────────────────────────────────┐ │
│  │  Remote (Backend Services)                          │ │
│  │  - Firebase Auth (user authentication)              │ │
│  │  - Firebase Firestore (leaderboards, cloud data)    │ │
│  │  - Firebase Analytics (usage tracking)              │ │
│  └─────────────────────────────────────────────────────┘ │
└───────────────────────────────────────────────────────────┘
```

---

## 🎯 State Management Flow (Riverpod)

### Theme Management

```
┌──────────────────┐
│   User Action    │
│  (Toggle Theme)  │
└────────┬─────────┘
         │
         ▼
┌──────────────────────────────────┐
│  themeNotifierProvider.notifier  │
│      .toggleTheme()              │
└────────┬─────────────────────────┘
         │
         ▼
┌──────────────────────────────────┐
│  ThemeNotifier                   │
│  state = !state                  │
│  (true/false)                    │
└────────┬─────────────────────────┘
         │
         ▼ (reactive update)
┌──────────────────────────────────┐
│  currentThemeModeProvider        │
│  computed: state ? Dark : Light  │
└────────┬─────────────────────────┘
         │
         ▼ (auto-rebuild)
┌──────────────────────────────────┐
│  MaterialApp.router              │
│  themeMode: themeMode            │
└──────────────────────────────────┘
```

**OLD vs NEW:**

```
╔═══════════════════════════════════════════════════════════╗
║  OLD: Timer-based polling (BAD)                           ║
╚═══════════════════════════════════════════════════════════╝

    ┌─────────────────┐
    │  Timer.periodic │
    │   (every 100ms) │
    └────────┬────────┘
             │
             ▼ (poll)
    ┌─────────────────┐
    │  ThemeManager() │
    │  .currentTheme  │
    └────────┬────────┘
             │
             ▼ (setState)
    ┌─────────────────┐
    │  Rebuild widget │
    │  (forced)       │
    └─────────────────┘

    Problems:
    ❌ CPU usage every 100ms
    ❌ Unnecessary rebuilds
    ❌ No reactive updates
    ❌ Hard to test

╔═══════════════════════════════════════════════════════════╗
║  NEW: Riverpod reactive (GOOD)                            ║
╚═══════════════════════════════════════════════════════════╝

    ┌─────────────────┐
    │  User Action    │
    └────────┬────────┘
             │
             ▼ (notify)
    ┌─────────────────┐
    │  StateNotifier  │
    └────────┬────────┘
             │
             ▼ (reactive)
    ┌─────────────────┐
    │  Only affected  │
    │  widgets rebuild│
    └─────────────────┘

    Benefits:
    ✅ No polling
    ✅ Targeted rebuilds
    ✅ Reactive by design
    ✅ Easy to test
```

### Game State Management

```
┌──────────────────┐
│   User Input     │
│  (Move, Click)   │
└────────┬─────────┘
         │
         ▼
┌──────────────────────────────────┐
│  GameNotifier                    │
│  (per game)                      │
│  - updateGameState()             │
│  - validateMove()                │
│  - calculateScore()              │
└────────┬─────────────────────────┘
         │
         ▼ (update state)
┌──────────────────────────────────┐
│  AsyncValue<GameState>           │
│  - loading: CircularProgress     │
│  - data: Game UI                 │
│  - error: Error message          │
└────────┬─────────────────────────┘
         │
         ▼ (persist if needed)
┌──────────────────────────────────┐
│  StorageService                  │
│  - saveGameState()               │
│  - saveHighScore()               │
└────────┬─────────────────────────┘
         │
         ▼ (optional sync)
┌──────────────────────────────────┐
│  Firebase Firestore              │
│  - syncLeaderboard()             │
└──────────────────────────────────┘
```

---

## 🧩 Module Structure (Per Game)

### Example: game_2048

```
pages/game_2048/
├── game_2048_page.dart           # Main game page (ConsumerWidget)
├── models/
│   ├── board.dart                # Game board state
│   ├── tile.dart                 # Tile entity
│   └── game_state.dart           # Game state model
├── widgets/
│   ├── board_widget.dart         # Visual board
│   ├── tile_widget.dart          # Single tile UI
│   ├── score_display.dart        # Score/controls
│   └── game_over_dialog.dart     # End game dialog
├── controllers/
│   └── game_2048_controller.dart # Game logic (Riverpod notifier)
└── services/
    ├── board_generator.dart      # Generate random tiles
    └── move_calculator.dart      # Calculate moves/merges
```

**Data Flow:**

```
User Swipe
    │
    ▼
game_2048_page.dart (ConsumerWidget)
    │
    ├── watches: game2048StateProvider
    │
    └── calls: ref.read(game2048NotifierProvider.notifier).move(direction)
            │
            ▼
        game_2048_controller.dart (Notifier)
            │
            ├── validateMove()
            ├── updateBoard()
            ├── calculateScore()
            │
            └── state = AsyncValue.data(newGameState)
                    │
                    ▼
                board_widget.dart rebuilds
```

---

## 🔥 Firebase Integration

### Architecture

```
┌───────────────────────────────────────────────────────────┐
│                      Flutter App                          │
└─────────────────────┬─────────────────────────────────────┘
                      │
                      ▼
          ┌───────────────────────┐
          │  Firebase SDK         │
          │  (from core package)  │
          └───────────┬───────────┘
                      │
        ┌─────────────┼─────────────┐
        │             │             │
        ▼             ▼             ▼
┌───────────┐  ┌──────────┐  ┌──────────┐
│   Auth    │  │ Firestore│  │ Analytics│
│           │  │          │  │          │
│ - Login   │  │ - Scores │  │ - Events │
│ - Signup  │  │ - Boards │  │ - Timing │
│ - Profile │  │ - Prefs  │  │ - Errors │
└───────────┘  └──────────┘  └──────────┘
```

### Data Structure (Firestore)

```
minigames/
├── users/
│   └── {userId}/
│       ├── profile/
│       │   ├── displayName
│       │   ├── email
│       │   └── createdAt
│       └── gameStats/
│           ├── game_2048/
│           │   ├── highScore
│           │   ├── gamesPlayed
│           │   └── lastPlayed
│           ├── game_snake/
│           └── ... (13 games)
├── leaderboards/
│   ├── game_2048/
│   │   └── {scoreId}/
│   │       ├── userId
│   │       ├── score
│   │       └── timestamp
│   └── ... (13 games)
└── achievements/
    └── {userId}/
        └── {achievementId}/
```

---

## 🛣️ Navigation Flow (go_router)

### Route Tree

```
/ (root)
├── ResponsivePage (mobile < 600px, desktop ≥ 600px)
│   └── GameHomePage (grid of 13 games)
│
├── /game-2048
│   └── Game2048Page
│
├── /game-caca-palavra
│   └── GameCacaPalavraPage
│
├── /game-campo-minado
│   └── CampoMinadoPage
│
├── /game-flappbird
│   └── GameFlappbirdPage
│
├── /game-memory
│   └── GameMemoryPage
│
├── /game-pingpong
│   └── PingpongPage
│
├── /game-quiz
│   └── GameQuizPage
│
├── /game-quiz-image
│   └── GameQuizImagePage
│
├── /game-snake
│   └── GameSnakePage
│
├── /game-soletrando
│   └── GameSoletrandoPage
│
├── /game-sudoku
│   └── GameSudokuPage
│
├── /game-tictactoe
│   └── GameTictactoePage
│
├── /game-tower
│   └── GameTowerPage
│
├── /settings
│   └── SettingsPage (theme, sound, notifications)
│
└── /profile
    └── ProfilePage (stats, achievements)
```

### Deep Linking

```
Examples:

https://minigames.app/                  → Home
https://minigames.app/game-2048         → Direct to 2048
https://minigames.app/profile           → User profile
https://minigames.app/leaderboard/snake → Snake leaderboard
```

---

## 🧪 Testing Architecture

### Test Pyramid

```
                    ┌──────────────┐
                    │  E2E Tests   │  (Few)
                    │  (Flutter    │
                    │   Driver)    │
                    └──────────────┘
                          │
              ┌───────────┴───────────┐
              │   Integration Tests   │  (Some)
              │   (Widget tests)      │
              └───────────┬───────────┘
                          │
          ┌───────────────┴───────────────┐
          │      Unit Tests               │  (Many)
          │  (Logic, Models, Controllers) │
          └───────────────────────────────┘
```

### Test Structure (Per Game)

```
test/
├── unit/
│   ├── models/
│   │   └── game_2048_test.dart
│   ├── controllers/
│   │   └── game_2048_controller_test.dart
│   └── services/
│       └── board_generator_test.dart
├── widget/
│   └── game_2048_page_test.dart
└── integration/
    └── game_2048_flow_test.dart
```

**Riverpod Testing Example:**

```dart
test('should update game state on move', () async {
  // Arrange
  final container = ProviderContainer(
    overrides: [
      game2048RepositoryProvider.overrideWithValue(mockRepository),
    ],
  );

  // Act
  final notifier = container.read(game2048NotifierProvider.notifier);
  await notifier.move(Direction.up);

  // Assert
  final state = container.read(game2048NotifierProvider);
  expect(state.value?.board, isNotNull);
  expect(state.value?.score, greaterThan(0));
});
```

---

## 🎨 Theme System

### Theme Architecture

```
┌───────────────────────────────────────────────────────────┐
│                     Material3 Design                      │
└─────────────────────┬─────────────────────────────────────┘
                      │
          ┌───────────┴───────────┐
          │                       │
    ┌─────▼─────┐         ┌──────▼──────┐
    │   Light   │         │    Dark     │
    │   Theme   │         │    Theme    │
    └─────┬─────┘         └──────┬──────┘
          │                       │
          │   ColorScheme.fromSeed│
          │   (seedColor: purple) │
          │                       │
          └───────────┬───────────┘
                      │
          ┌───────────▼───────────┐
          │   Theme Extensions    │
          │  (game-specific)      │
          └───────────┬───────────┘
                      │
          ┌───────────▼───────────┐
          │  Component Themes     │
          │  - AppBar             │
          │  - Button             │
          │  - Card               │
          └───────────────────────┘
```

---

## 📊 Performance Considerations

### Optimization Strategies

1. **Widget Optimization**
   - Use `const` constructors
   - Minimize rebuilds (Riverpod select)
   - ListView.builder for long lists

2. **State Management**
   - ✅ Riverpod (reactive, no polling)
   - ❌ Timer-based (removed)
   - Selective listening (select, family)

3. **Asset Loading**
   - Image caching
   - Lazy loading for game assets
   - Precaching for critical assets

4. **Game Loop**
   - Ticker for smooth animations
   - RequestAnimationFrame (web)
   - Game state batching

5. **Memory Management**
   - Dispose controllers properly
   - Clear game resources on exit
   - Monitor with DevTools

---

## 🔐 Security

### Security Layers

```
┌───────────────────────────────────────────────────────────┐
│  App Layer                                                │
│  - Input validation                                       │
│  - XSS prevention                                         │
└─────────────────────┬─────────────────────────────────────┘
                      │
┌─────────────────────▼─────────────────────────────────────┐
│  Firebase Layer                                           │
│  - Authentication (Email, Google)                         │
│  - Firestore security rules                               │
│  - API key restrictions                                   │
└─────────────────────┬─────────────────────────────────────┘
                      │
┌─────────────────────▼─────────────────────────────────────┐
│  Network Layer                                            │
│  - HTTPS only                                             │
│  - Certificate pinning (optional)                         │
└───────────────────────────────────────────────────────────┘
```

---

## 🚀 Deployment Pipeline

### Build & Deploy Flow

```
┌──────────────┐
│  Git Commit  │
└──────┬───────┘
       │
       ▼
┌──────────────┐
│  CI/CD       │
│  (GitHub     │
│   Actions)   │
└──────┬───────┘
       │
       ├────────────────┬────────────────┐
       ▼                ▼                ▼
┌──────────────┐ ┌──────────────┐ ┌──────────────┐
│   Android    │ │     iOS      │ │     Web      │
│   (APK/AAB)  │ │   (IPA)      │ │   (build/)   │
└──────┬───────┘ └──────┬───────┘ └──────┬───────┘
       │                │                │
       ▼                ▼                ▼
┌──────────────┐ ┌──────────────┐ ┌──────────────┐
│ Google Play  │ │  App Store   │ │  Firebase    │
│   Console    │ │   Connect    │ │   Hosting    │
└──────────────┘ └──────────────┘ └──────────────┘
```

---

**Last Updated**: 2025-10-21
**Version**: 1.0.0
**Status**: Architecture defined, ready for implementation
