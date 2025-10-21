# Migration Guide - app-minigames

## 📋 Current State

### ✅ Structure Created
- Flutter app structure complete
- Riverpod integration configured
- Core infrastructure ready (DI, Router, Theme)
- pubspec.yaml with all dependencies
- analysis_options.yaml configured
- .gitignore created

### 📂 Directory Structure

```
app-minigames/
├── lib/                          # NEW - Flutter app structure
│   ├── core/
│   │   ├── config/
│   │   │   └── firebase_options.dart    # TODO: Configure Firebase
│   │   ├── di/
│   │   │   └── injection.dart           # DI setup
│   │   ├── router/
│   │   │   └── app_router.dart          # go_router config
│   │   └── theme/
│   │       └── theme_providers.dart     # Riverpod theme (replaces Timer)
│   ├── pages/                   # TODO: Move from root
│   ├── models/                  # TODO: Move from root
│   ├── widgets/                 # TODO: Move from root
│   ├── main.dart                # ✅ Entry point
│   └── app_page.dart            # ✅ Root widget (Riverpod)
├── pages/                       # LEGACY - To be moved to lib/pages/
│   ├── mobile_page.dart
│   ├── desktop_page.dart
│   ├── game_home.dart
│   └── game_*/                  # 13 game folders
├── constants/                   # LEGACY - To be moved to lib/constants/
├── models/                      # LEGACY - To be moved to lib/models/
├── services/                    # LEGACY - To be moved to lib/services/
├── utils/                       # LEGACY - To be moved to lib/utils/
├── widgets/                     # LEGACY - To be moved to lib/widgets/
├── app-page.dart                # LEGACY - Replaced by lib/app_page.dart
├── pubspec.yaml                 # ✅ Created
├── analysis_options.yaml        # ✅ Created
├── .gitignore                   # ✅ Created
└── README.md                    # ✅ Created
```

## 🔄 Migration Steps

### Phase 1: Code Generation Setup (5 min)

```bash
cd /Users/lucineiloch/Documents/deveopment/monorepo/apps/app-minigames

# Install dependencies
flutter pub get

# Generate Injectable code
dart run build_runner build --delete-conflicting-outputs
```

**Expected output**: `lib/core/di/injection.config.dart` generated

### Phase 2: Move Existing Files (30 min)

**Priority Order:**
1. **Models** (no dependencies)
2. **Constants** (used by models)
3. **Utils** (helper functions)
4. **Widgets** (UI components)
5. **Services** (business logic)
6. **Pages** (depend on everything)

**Commands:**
```bash
# Move models
cp -r models/* lib/models/

# Move constants
cp -r constants/* lib/constants/

# Move utils
cp -r utils/* lib/utils/

# Move widgets
cp -r widgets/* lib/widgets/

# Move services
cp -r services/* lib/services/

# Move pages
cp -r pages/* lib/pages/
```

### Phase 3: Fix Imports (1-2 hours)

**Pattern to replace:**
```dart
# OLD (relative imports from root)
import '../models/game_info.dart';
import '../widgets/game_card.dart';

# NEW (package imports)
import 'package:app_minigames/models/game_info.dart';
import 'package:app_minigames/widgets/game_card.dart';
```

**Files requiring import fixes:**
- `lib/pages/mobile_page.dart` - 13+ game imports
- `lib/pages/desktop_page.dart` - Similar to mobile
- All game pages (13 games)
- All widget files
- All service files

### Phase 4: Remove Timer-based Theme (30 min)

**File**: Old `app-page.dart` (root)

**Issue**: Timer running every 100ms to poll ThemeManager
```dart
_timerTheme = Timer.periodic(const Duration(milliseconds: 100), (timer) {
  setState(() {
    currentTheme = ThemeManager().currentTheme;
  });
});
```

**Solution**: Already replaced in `lib/app_page.dart` with Riverpod theme providers

**TODO**: Update pages to use Riverpod theme:
```dart
// OLD
ThemeManager().currentTheme

// NEW
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_minigames/core/theme/theme_providers.dart';

class MyPage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context); // Works with Riverpod theme
    // Or toggle theme:
    ref.read(themeNotifierProvider.notifier).toggleTheme();
  }
}
```

### Phase 5: Configure Firebase (15 min)

**File**: `lib/core/config/firebase_options.dart`

**TODO**: Add Firebase project configuration
1. Go to Firebase Console
2. Create/select project
3. Add platforms (Android, iOS, Web)
4. Download config files:
   - Android: `google-services.json` → `android/app/`
   - iOS: `GoogleService-Info.plist` → `ios/Runner/`
   - Web: Copy config to `firebase_options.dart`

### Phase 6: Add Game Routes (30 min)

**File**: `lib/core/router/app_router.dart`

**TODO**: Add routes for each game:
```dart
GoRoute(
  path: '/game-2048',
  builder: (context, state) => const Game2048Page(),
),
GoRoute(
  path: '/game-snake',
  builder: (context, state) => const GameSnakePage(),
),
// ... 11 more games
```

### Phase 7: Test Build (15 min)

```bash
# Analyze code
flutter analyze

# Run tests (if any)
flutter test

# Build debug
flutter build apk --debug

# Run app
flutter run
```

## 🎯 Key Changes Summary

### State Management
- **OLD**: Provider with Timer-based theme polling
- **NEW**: Riverpod with reactive theme providers

### Navigation
- **OLD**: Direct MaterialApp with home widget
- **NEW**: go_router with route configuration

### Structure
- **OLD**: Flat structure with root-level folders
- **NEW**: Clean lib/ structure with core/ infrastructure

### Theme Management
- **OLD**: ThemeManager with Timer polling (100ms)
- **NEW**: Riverpod StateNotifier with reactive updates

## ⚠️ Known Issues to Address

### 1. GetX Usage
Found 2 GetX usages in codebase (needs review):
- Check if it's only for navigation
- Replace with go_router if possible

### 2. Provider Compatibility
- Provider package kept for backward compatibility
- Gradually migrate Provider usage to Riverpod

### 3. Theme Manager
- Old `ThemeManager` class location unknown
- Import in `app-page.dart`: `import '../core/themes/manager.dart';`
- Needs to be found and integrated or replaced

### 4. Assets
- `assets/` folder exists but not cataloged
- Add assets to `pubspec.yaml` after inventory

## 📊 Estimated Time

| Phase | Task | Time |
|-------|------|------|
| 1 | Code generation | 5 min |
| 2 | Move files | 30 min |
| 3 | Fix imports | 1-2 hours |
| 4 | Remove Timer theme | 30 min |
| 5 | Configure Firebase | 15 min |
| 6 | Add game routes | 30 min |
| 7 | Test build | 15 min |
| **Total** | | **3-4 hours** |

## 🚀 Next Actions

1. Run `flutter pub get`
2. Generate Injectable code
3. Move files from root to `lib/`
4. Fix all imports
5. Configure Firebase
6. Add game routes
7. Test run

---

**Status**: ✅ Structure complete, ready for migration
**Last Updated**: 2025-10-21
