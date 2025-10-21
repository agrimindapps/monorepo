# Setup Checklist - app-minigames

## ✅ Phase 1: Structure Setup (COMPLETED)

- [x] Create `pubspec.yaml` with dependencies
- [x] Create `lib/main.dart` entry point
- [x] Create `lib/app_page.dart` (Riverpod version)
- [x] Create `lib/core/di/injection.dart` (DI setup)
- [x] Create `lib/core/theme/theme_providers.dart` (replaces Timer)
- [x] Create `lib/core/router/app_router.dart` (go_router)
- [x] Create `lib/core/config/firebase_options.dart` (placeholder)
- [x] Create `analysis_options.yaml`
- [x] Create `.gitignore`
- [x] Create `build.yaml`
- [x] Create `README.md`
- [x] Create `MIGRATION_GUIDE.md`

## 🔄 Phase 2: Dependencies & Code Generation

- [ ] Run `flutter pub get`
- [ ] Run `dart run build_runner build --delete-conflicting-outputs`
- [ ] Verify `lib/core/di/injection.config.dart` is generated

## 📦 Phase 3: Move Legacy Files to lib/

### Constants
- [ ] Move `constants/*` to `lib/constants/`
- [ ] Fix imports in constant files

### Models
- [ ] Move `models/*` to `lib/models/`
- [ ] Fix imports in model files

### Utils
- [ ] Move `utils/*` to `lib/utils/`
- [ ] Fix imports in util files

### Widgets
- [ ] Move `widgets/*` to `lib/widgets/`
- [ ] Fix imports in widget files

### Services
- [ ] Move `services/*` to `lib/services/`
- [ ] Fix imports in service files

### Pages
- [ ] Move `pages/mobile_page.dart` to `lib/pages/`
- [ ] Move `pages/desktop_page.dart` to `lib/pages/`
- [ ] Move `pages/game_home.dart` to `lib/pages/`
- [ ] Move `pages/game_2048/*` to `lib/pages/game_2048/`
- [ ] Move `pages/game_caca_palavra/*` to `lib/pages/game_caca_palavra/`
- [ ] Move `pages/game_campo_minado/*` to `lib/pages/game_campo_minado/`
- [ ] Move `pages/game_flappbird/*` to `lib/pages/game_flappbird/`
- [ ] Move `pages/game_memory/*` to `lib/pages/game_memory/`
- [ ] Move `pages/game_pingpong/*` to `lib/pages/game_pingpong/`
- [ ] Move `pages/game_quiz/*` to `lib/pages/game_quiz/`
- [ ] Move `pages/game_quiz_image/*` to `lib/pages/game_quiz_image/`
- [ ] Move `pages/game_snake/*` to `lib/pages/game_snake/`
- [ ] Move `pages/game_soletrando/*` to `lib/pages/game_soletrando/`
- [ ] Move `pages/game_sudoku/*` to `lib/pages/game_sudoku/`
- [ ] Move `pages/game_tictactoe/*` to `lib/pages/game_tictactoe/`
- [ ] Move `pages/game_tower/*` to `lib/pages/game_tower/`

## 🔧 Phase 4: Fix Imports

### Pattern to Replace
```dart
# Before (relative paths)
import '../models/game_info.dart';
import '../widgets/game_card.dart';

# After (package imports)
import 'package:app_minigames/models/game_info.dart';
import 'package:app_minigames/widgets/game_card.dart';
```

### Files Requiring Import Fixes
- [ ] `lib/pages/mobile_page.dart`
- [ ] `lib/pages/desktop_page.dart`
- [ ] All 13 game page files
- [ ] All widget files
- [ ] All service files
- [ ] All model files

## 🎨 Phase 5: Theme Migration

- [ ] Find and review old `ThemeManager` class
- [ ] Update pages using `ThemeManager()` to use Riverpod providers
- [ ] Convert StatefulWidget to ConsumerWidget where needed
- [ ] Test theme toggle functionality
- [ ] Remove old Timer-based theme updates

## 🔥 Phase 6: Firebase Configuration

- [ ] Create Firebase project (if not exists)
- [ ] Add Android app to Firebase
- [ ] Download `google-services.json` → `android/app/`
- [ ] Add iOS app to Firebase
- [ ] Download `GoogleService-Info.plist` → `ios/Runner/`
- [ ] Add Web app to Firebase
- [ ] Copy config to `lib/core/config/firebase_options.dart`

## 🗺️ Phase 7: Router Configuration

- [ ] Add route for game_2048
- [ ] Add route for game_caca_palavra
- [ ] Add route for game_campo_minado
- [ ] Add route for game_flappbird
- [ ] Add route for game_memory
- [ ] Add route for game_pingpong
- [ ] Add route for game_quiz
- [ ] Add route for game_quiz_image
- [ ] Add route for game_snake
- [ ] Add route for game_soletrando
- [ ] Add route for game_sudoku
- [ ] Add route for game_tictactoe
- [ ] Add route for game_tower

## 🧪 Phase 8: Testing & Validation

- [ ] Run `flutter analyze` (0 errors expected)
- [ ] Run `flutter test` (if tests exist)
- [ ] Run `flutter run` and verify app launches
- [ ] Test navigation to each game
- [ ] Test theme toggle
- [ ] Test on Android
- [ ] Test on iOS
- [ ] Test on Web

## 📱 Phase 9: Assets Configuration

- [ ] Inventory assets folder
- [ ] Add asset paths to `pubspec.yaml`
- [ ] Verify all images load correctly
- [ ] Verify all fonts load correctly (if any)

## 🧹 Phase 10: Cleanup

- [ ] Delete old root `app-page.dart`
- [ ] Delete old root folders (pages, models, etc.) after verification
- [ ] Update README with final structure
- [ ] Commit changes to git

---

## 📊 Progress Tracker

**Overall Progress**: 12/100+ tasks completed (12%)

**Phase Status**:
- ✅ Phase 1: Complete (12/12 tasks)
- ⏸️ Phase 2: Not started
- ⏸️ Phase 3: Not started
- ⏸️ Phase 4: Not started
- ⏸️ Phase 5: Not started
- ⏸️ Phase 6: Not started
- ⏸️ Phase 7: Not started
- ⏸️ Phase 8: Not started
- ⏸️ Phase 9: Not started
- ⏸️ Phase 10: Not started

---

**Last Updated**: 2025-10-21
**Status**: Ready for Phase 2 (Dependencies & Code Generation)
