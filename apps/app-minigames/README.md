# app-minigames

Aplicativo completo de **13 mini-jogos educativos e de entretenimento** desenvolvido em Flutter.

## 🎮 Jogos Disponíveis

### Puzzle & Lógica
- **2048** - Puzzle numérico clássico
- **Sudoku** - Quebra-cabeça de lógica
- **Campo Minado** - Minesweeper clássico
- **Memory** - Jogo da memória

### Palavras & Conhecimento
- **Caça-Palavra** - Word search
- **Soletrando** - Spelling game
- **Quiz** - Perguntas e respostas
- **Quiz Imagem** - Quiz visual

### Ação & Arcade
- **Snake** - Jogo da cobrinha
- **Flappy Bird** - Clone do clássico
- **Ping Pong** - Pong clássico
- **Tower** - Tower defense

### Estratégia
- **Tic-Tac-Toe** - Jogo da velha

## 🏗️ Arquitetura

- **State Management**: Riverpod (com coexistência Provider durante migração)
- **Navigation**: go_router
- **DI**: GetIt + Injectable
- **Backend**: Firebase (Auth, Firestore para leaderboards)
- **Storage**: Hive (local scores) + Firebase (cloud sync)

## 🚀 Getting Started

```bash
# Install dependencies
flutter pub get

# Run code generation
dart run build_runner build --delete-conflicting-outputs

# Run app
flutter run
```

## 📦 Structure

```
lib/
├── core/                # Core infrastructure
│   ├── config/          # Firebase, environment
│   ├── di/              # Dependency injection
│   ├── router/          # Navigation
│   └── theme/           # Theme providers
├── features/            # Feature modules (TODO)
├── pages/               # Pages (legacy structure)
│   ├── game_*/          # Individual game folders
│   ├── game_home.dart   # Games menu
│   ├── mobile_page.dart
│   └── desktop_page.dart
├── constants/           # App constants
├── models/              # Data models
├── services/            # Business services
├── utils/               # Utilities
└── widgets/             # Shared widgets
```

## 🎯 Features

- ✅ 13 jogos completos
- ✅ Responsive (mobile + desktop)
- ✅ Dark/Light theme
- 🔄 Leaderboards (Firebase - TODO)
- 🔄 Achievements (TODO)
- 🔄 Multiplayer (some games - TODO)

## 🔧 Development

- Follow monorepo patterns from `packages/core`
- Use Riverpod for new features
- Maintain Provider compatibility during migration

## 📝 Migration Notes

### Legacy Structure
- Old `app-page.dart` in root uses Timer-based theme management
- Need to migrate to Riverpod theme providers
- Provider state management coexists with Riverpod during transition

### Next Steps
1. Move existing pages to `lib/pages/`
2. Migrate Timer-based theme to Riverpod
3. Add game routes to `app_router.dart`
4. Configure Firebase options
5. Generate Injectable code: `dart run build_runner build`

---

**Monorepo**: `monorepo/apps/app-minigames`
**Status**: ✅ Structure setup, migrating to Clean Architecture
