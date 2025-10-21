# Quick Commands - app-minigames

## 🚀 Initial Setup

```bash
# Navigate to app directory
cd /Users/lucineiloch/Documents/deveopment/monorepo/apps/app-minigames

# Install dependencies
flutter pub get

# Generate code (Injectable + Riverpod)
dart run build_runner build --delete-conflicting-outputs

# Watch for changes (auto-regenerate)
dart run build_runner watch --delete-conflicting-outputs
```

## 📦 File Migration Commands

```bash
# Create lib subdirectories
mkdir -p lib/constants lib/models lib/services lib/utils lib/widgets

# Move files (keep originals for now)
cp -r constants/* lib/constants/
cp -r models/* lib/models/
cp -r utils/* lib/utils/
cp -r widgets/* lib/widgets/
cp -r services/* lib/services/
cp -r pages/* lib/pages/

# Alternative: Move files (destructive)
# mv constants/* lib/constants/
# mv models/* lib/models/
# etc.
```

## 🔍 Analysis & Debugging

```bash
# Run analyzer
flutter analyze

# Check for outdated packages
flutter pub outdated

# Run tests
flutter test

# Run tests with coverage
flutter test --coverage

# Run custom lint (Riverpod)
dart run custom_lint
```

## 🏗️ Build Commands

```bash
# Clean build
flutter clean && flutter pub get

# Build APK (debug)
flutter build apk --debug

# Build APK (release)
flutter build apk --release

# Build App Bundle (release)
flutter build appbundle --release

# Build iOS (release)
flutter build ios --release

# Build Web (release)
flutter build web --release
```

## 🔥 Firebase Setup

```bash
# Install Firebase CLI (if not installed)
npm install -g firebase-tools

# Login to Firebase
firebase login

# Initialize Firebase project
firebase init

# Deploy to Firebase Hosting (web)
firebase deploy --only hosting
```

## 🔧 Maintenance Commands

```bash
# Update dependencies
flutter pub upgrade

# Get specific package
flutter pub add package_name

# Remove package
flutter pub remove package_name

# List all packages
flutter pub deps

# Check Flutter version
flutter --version

# Doctor check
flutter doctor -v
```

## 🧪 Testing Specific Features

```bash
# Test on specific device
flutter run -d device_id

# List available devices
flutter devices

# Run on Chrome
flutter run -d chrome

# Run on Android emulator
flutter run -d emulator-5554

# Run with hot reload
flutter run --hot
```

## 📊 Code Generation Specifics

```bash
# Generate only Injectable
dart run build_runner build --delete-conflicting-outputs --build-filter="lib/core/di/*.dart"

# Generate only Riverpod
dart run build_runner build --delete-conflicting-outputs --build-filter="lib/**/*_provider.dart"

# Clean generated files
find lib -name "*.g.dart" -type f -delete
find lib -name "*.freezed.dart" -type f -delete
```

## 🔍 Search & Replace (Import Fixes)

```bash
# Find all relative imports
grep -r "import '\.\." lib/

# Find specific pattern
grep -r "import '../models" lib/

# Replace with sed (macOS)
# Backup first!
find lib -name "*.dart" -type f -exec sed -i '' "s|import '\.\./models/|import 'package:app_minigames/models/|g" {} \;

# Count Dart files
find lib -name "*.dart" -type f | wc -l

# List all game pages
find lib/pages -name "*_page.dart" -type f
```

## 📝 Git Commands (After Migration)

```bash
# Check status
git status

# Stage all changes
git add .

# Commit with message
git commit -m "feat(app-minigames): setup Flutter structure with Riverpod"

# View changes
git diff

# View staged changes
git diff --staged

# Create branch for migration
git checkout -b feat/minigames-migration
```

## 🎮 Game-Specific Commands

```bash
# Count games
ls -d pages/game_* | wc -l

# List all games
ls -d pages/game_*

# Find game entry points
find pages -name "*_page.dart" -path "*/game_*/*" -type f

# Count total Dart files
find . -name "*.dart" -type f | wc -l
```

## 🔥 Emergency Cleanup

```bash
# Nuclear option - clean everything
flutter clean
rm -rf .dart_tool/
rm -rf build/
rm pubspec.lock
flutter pub get
dart run build_runner build --delete-conflicting-outputs

# Reset git changes (if needed)
git reset --hard HEAD
git clean -fd
```

## 📊 Project Statistics

```bash
# Count lines of code
find lib -name "*.dart" -type f -exec wc -l {} + | sort -n

# Find largest files
find lib -name "*.dart" -type f -exec wc -l {} + | sort -rn | head -10

# Count files by type
echo "Pages: $(find lib/pages -name "*_page.dart" | wc -l)"
echo "Models: $(find lib/models -name "*.dart" | wc -l)"
echo "Widgets: $(find lib/widgets -name "*.dart" | wc -l)"
```

## 🚨 Common Issues & Fixes

```bash
# Fix: "Pub get failed"
flutter clean && flutter pub get

# Fix: "Build runner stuck"
dart run build_runner clean
dart run build_runner build --delete-conflicting-outputs

# Fix: "Import errors"
# Check pubspec.yaml name matches: "name: app_minigames"
# Imports should be: "package:app_minigames/..."

# Fix: "Firebase not initialized"
# Check firebase_options.dart has correct config
# Verify Firebase.initializeApp() is called in main()

# Fix: "GetIt not configured"
# Ensure configureDependencies() is called in main()
# Check injection.config.dart is generated
```

---

**Quick Start After Setup**:
```bash
flutter pub get && \
dart run build_runner build --delete-conflicting-outputs && \
flutter run
```

**Monorepo Build (from root)**:
```bash
cd /Users/lucineiloch/Documents/deveopment/monorepo
melos run build:all:apk:debug
```
