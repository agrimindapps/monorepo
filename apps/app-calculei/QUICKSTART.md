# app-calculei Quick Start Guide

## 🚀 Getting Started (First Time Setup)

### 1. Firebase Configuration (REQUIRED)

Before running the app, you **MUST** configure Firebase:

```bash
# 1. Go to Firebase Console
open https://console.firebase.google.com/

# 2. Create or select project for app-calculei

# 3. Add platforms:
#    - Web app
#    - Android app
#    - iOS app (if needed)

# 4. Update lib/core/config/firebase_options.dart
#    Replace all 'YOUR_*' placeholders with actual values

# 5. Download platform-specific config files:
#    - android/app/google-services.json (Android)
#    - ios/Runner/GoogleService-Info.plist (iOS)
```

### 2. Install Dependencies

```bash
# Navigate to app directory
cd apps/app-calculei

# Get dependencies
flutter pub get

# Run code generation
dart run build_runner build --delete-conflicting-outputs
```

### 3. Run the App

```bash
# Run on connected device/emulator
flutter run

# Run on specific device
flutter devices
flutter run -d <device-id>

# Run on Chrome (web)
flutter run -d chrome
```

---

## 🏗️ Current Structure

```
app-calculei/
├── lib/
│   ├── core/                    # ✅ Core infrastructure (NEW)
│   │   ├── config/              # Firebase, environment
│   │   ├── di/                  # Dependency injection
│   │   ├── router/              # Navigation (go_router)
│   │   └── theme/               # Theme providers
│   ├── features/                # 📁 Clean Architecture (READY)
│   ├── main.dart                # ✅ App entry point (NEW)
│   └── app_page.dart            # ✅ Main app widget (NEW)
│
├── pages/                       # ⚠️  LEGACY - To be migrated
├── constants/                   # ⚠️  LEGACY - To be migrated
├── repository/                  # ⚠️  LEGACY - To be reviewed
├── services/                    # ⚠️  LEGACY - To be reviewed
└── widgets/                     # ⚠️  LEGACY - To be migrated
```

---

## 🎯 What's Working Now

### ✅ Infrastructure Ready
- Riverpod state management setup
- Firebase integration (needs config)
- GetIt dependency injection
- go_router navigation
- Theme providers (light/dark mode)
- Code generation configured

### ⏳ Legacy Code Still Active
- All 13 calculators in `pages/calc/`
- Constants in `constants/`
- Widgets in `widgets/`
- Old `app-page.dart` in root (will be removed)

---

## 🔧 Development Workflow

### Making Changes

```bash
# 1. Create/modify Riverpod providers
# (Files with @riverpod annotation)

# 2. Run code generation
dart run build_runner watch --delete-conflicting-outputs

# 3. Check for errors
flutter analyze

# 4. Run tests
flutter test
```

### Adding New Calculator

Follow this pattern (will be documented in detail later):

```
lib/features/[category]_calculators/
├── data/
│   ├── models/calculator_model.dart
│   └── repositories/calculator_repository_impl.dart
├── domain/
│   ├── entities/calculator_entity.dart
│   ├── repositories/calculator_repository.dart
│   └── usecases/calculate_usecase.dart
└── presentation/
    ├── providers/calculator_provider.dart     # Riverpod
    ├── pages/calculator_page.dart
    └── widgets/
        ├── calculator_form.dart
        └── calculator_result.dart
```

---

## 🐛 Troubleshooting

### Build Errors After Changes

```bash
# Clean build
flutter clean
flutter pub get
dart run build_runner build --delete-conflicting-outputs
```

### Firebase Initialization Error

```
Error: Firebase not initialized or invalid config
```

**Fix**: Update `lib/core/config/firebase_options.dart` with real Firebase credentials.

### Code Generation Issues

```bash
# Delete generated files and rebuild
find . -name "*.g.dart" -delete
find . -name "*.config.dart" -delete
dart run build_runner build --delete-conflicting-outputs
```

### Import Errors

If you see errors like:
```
Error: The name 'test' is defined in 'package:flutter_test' and 'package:injectable'
```

**Fix**: Add `hide` clause to imports:
```dart
import 'package:core/core.dart' hide test;
```

---

## 📚 Key Dependencies

### State Management
- `flutter_riverpod: ^2.6.1` - State management
- `riverpod_annotation: ^2.6.1` - Code generation annotations
- `riverpod_generator: ^2.6.1` (dev) - Code generator

### Dependency Injection
- `get_it: ^8.0.2` - Service locator
- `injectable: ^2.5.1` - DI annotations
- `injectable_generator: ^2.6.2` (dev) - DI generator

### Navigation
- `go_router: ^16.2.4` - Declarative routing

### Firebase
- `firebase_core` - Core Firebase
- `firebase_auth` - Authentication
- `cloud_firestore` - Database

### UI
- `fl_chart: ^0.69.0` - Charts
- `flutter_staggered_grid_view: ^0.7.0` - Grid layouts
- `mask_text_input_formatter: ^2.9.0` - Input formatting

---

## 📖 Next Steps

1. **Configure Firebase** (see MIGRATION_PLAN.md)
2. **Run dependencies** (`flutter pub get`)
3. **Test compilation** (`flutter run`)
4. **Review migration plan** (MIGRATION_PLAN.md)
5. **Start calculator migration** (follow Clean Architecture pattern)

---

## 🆘 Need Help?

- **Migration Guide**: See `MIGRATION_PLAN.md`
- **Architecture Docs**: See `README.md`
- **Monorepo Patterns**: See `.claude/guides/MIGRATION_PROVIDER_TO_RIVERPOD.md`
- **Reference App**: Check `apps/app-plantis` (Gold Standard 10/10)

---

**Status**: ✅ Structure ready, ⏳ Awaiting Firebase config & migration
**Last Updated**: 2024-10-21
