# Build Runner Checklist - app-receituagro

## ⚠️ SDK Requirements

**Current**: Dart 3.8.1 / Flutter 3.8.1
**Required**: Dart ≥3.9.0 / Flutter ≥3.35.0

---

## 🔧 After SDK Update - Run These Commands

### 1. Update SDK

```bash
# Option 1: Global upgrade
flutter upgrade

# Option 2: FVM (recommended for monorepo)
fvm install 3.35.6
fvm use 3.35.6
```

### 2. Generate Code with Build Runner

```bash
cd apps/app-receituagro

# Clean previous generated files
flutter clean

# Regenerate code
dart run build_runner build --delete-conflicting-outputs

# Or watch mode (for development)
dart run build_runner watch --delete-conflicting-outputs
```

### 3. Uncomment Code in hive_adapter_registry.dart

After build_runner successfully generates `sync_queue_item.g.dart`, uncomment:

**File**: `lib/core/services/hive_adapter_registry.dart`

```dart
// Line 14: Uncomment import
import '../data/models/sync_queue_item.dart';

// Line 47: Uncomment adapter registration
Hive.registerAdapter(SyncQueueItemAdapter());
```

### 4. Verify No Errors

```bash
# Run analyzer
flutter analyze

# Expected: 0 critical errors
# Warnings about Result<T> deprecation are OK (P2 task)
```

### 5. Run Tests (if any)

```bash
flutter test
```

---

## 📋 Generated Files Expected

After running build_runner, these files should be created:

- ✅ `lib/core/data/models/sync_queue_item.g.dart` (SyncQueueItemAdapter)
- ✅ Other `.g.dart` files for Riverpod providers (if any)

---

## 🐛 Known Issues

### Issue: Build Runner Fails
**Solution**: Check `pubspec.yaml` dependencies versions, especially:
- `build_runner`
- `hive_generator`
- `riverpod_generator` (if using)

### Issue: Analyzer Still Shows Errors
**Solution**:
```bash
flutter pub get
flutter clean
dart run build_runner build --delete-conflicting-outputs
```

---

## 📊 Current Status

| Task | Status | Blocker |
|------|--------|---------|
| SDK Update | ⏸️ Pending | User action required |
| Build Runner | ⏸️ Pending | SDK version |
| Uncomment Code | ⏸️ Pending | Build runner |
| Analyzer Clean | ⏸️ Pending | Above steps |

---

**Last Updated**: 2025-10-22
**Created By**: Claude Code (P0+P1 Implementation)
