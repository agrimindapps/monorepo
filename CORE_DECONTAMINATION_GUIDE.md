# Core Package Decontamination - Migration Guide

## 🎯 Overview

This guide outlines the architectural refactoring that eliminates app-specific contamination from the core package, implementing a clean architecture pattern with proper dependency inversion.

## ❌ Problem Identified

**CRITICAL**: The core package contained app-specific knowledge:

```dart
// ❌ CONTAMINATED: In core/lib/src/domain/repositories/i_local_storage_repository.dart
class HiveBoxes {
  static const String plantis = 'plantis';      // APP-SPECIFIC!
  static const String receituagro = 'receituagro'; // APP-SPECIFIC!
}

class LocalStorageKeys {
  static const String plantisSettings = 'plantis_settings';     // APP-SPECIFIC!
  static const String receitaAgroCache = 'receituagro_cache';   // APP-SPECIFIC!
}
```

**Impact:**
- Cross-app data contamination
- Security boundary violations
- Infinite loops due to accessing foreign data
- Tight coupling between independent apps

## ✅ Solution Implemented

### 1. Clean Core Package (Generic Only)

```dart
// ✅ CLEAN: Generic interfaces only
abstract class IBoxRegistryService {
  Future<Either<Failure, void>> registerBox(BoxConfiguration config);
  Future<Either<Failure, Box>> getBox(String boxName);
  bool canAppAccessBox(String boxName, String requestingAppId);
}

class BoxConfiguration {
  final String name;
  final String appId; // For app isolation
  final List<TypeAdapter>? customAdapters;
  final bool persistent;
  final EncryptionConfig? encryption;
}
```

### 2. App-Specific Storage Definitions

Each app now manages its own storage configuration:

```dart
// ✅ CLEAN: apps/app-receituagro/lib/core/storage/receituagro_boxes.dart
class ReceitaAgroBoxes {
  static const String receituagro = 'receituagro';
  static const String favoritos = 'receituagro_favoritos';
  
  static List<BoxConfiguration> getConfigurations() => [
    BoxConfiguration.basic(name: receituagro, appId: 'receituagro'),
    BoxConfiguration.basic(name: favoritos, appId: 'receituagro'),
  ];
}
```

## 📋 Migration Steps for Each App

### Step 1: Create App-Specific Storage Module

```bash
mkdir -p apps/[your-app]/lib/core/storage
```

Create `[your_app]_boxes.dart`:

```dart
import 'package:core/core.dart';

class YourAppBoxes {
  static const String main = 'your_app_main';
  static const String cache = 'your_app_cache';
  static const String settings = 'your_app_settings';
  
  static List<BoxConfiguration> getConfigurations() => [
    BoxConfiguration.basic(name: main, appId: 'your_app'),
    BoxConfiguration.basic(name: cache, appId: 'your_app'),
    BoxConfiguration.basic(name: settings, appId: 'your_app'),
  ];
  
  static class StorageKeys {
    static const String userPrefs = 'your_app_user_preferences';
    static const String appVersion = 'your_app_version';
    // Add other app-specific keys
  }
}
```

### Step 2: Create Storage Initializer

Create `[your_app]_storage_initializer.dart`:

```dart
import 'package:core/core.dart';
import 'your_app_boxes.dart';

class YourAppStorageInitializer {
  static Future<Either<Failure, void>> initialize(
    IBoxRegistryService boxRegistry,
  ) async {
    final configurations = YourAppBoxes.getConfigurations();
    
    for (final config in configurations) {
      final result = await boxRegistry.registerBox(config);
      if (result.isLeft()) return result;
    }
    
    return const Right(null);
  }
  
  static bool isInitialized(IBoxRegistryService boxRegistry) {
    return YourAppBoxes.getConfigurations()
        .every((config) => boxRegistry.isBoxRegistered(config.name));
  }
}
```

### Step 3: Update App Initialization

```dart
// In your app's main.dart or initialization code
Future<void> initializeApp() async {
  // Create services
  final boxRegistry = BoxRegistryService();
  final hiveStorage = HiveStorageService(boxRegistry);
  
  // Initialize storage
  await hiveStorage.initialize();
  
  // Register app-specific boxes
  final result = await YourAppStorageInitializer.initialize(boxRegistry);
  if (result.isLeft()) {
    throw Exception('Failed to initialize app storage');
  }
  
  // Register services with DI
  GetIt.instance.registerSingleton<IBoxRegistryService>(boxRegistry);
  GetIt.instance.registerSingleton<ILocalStorageRepository>(hiveStorage);
}
```

### Step 4: Update Repository Imports

```dart
// ❌ REMOVE: References to core HiveBoxes
import 'package:core/core.dart'; // Remove HiveBoxes usage

// ✅ ADD: Your app-specific boxes
import '../storage/your_app_boxes.dart';

class YourRepository {
  Future<void> saveData() async {
    // ❌ OLD: box: HiveBoxes.your_app
    // ✅ NEW: box: YourAppBoxes.main
    await storageService.save(
      key: 'data',
      data: value,
      box: YourAppBoxes.main, // App-specific box
    );
  }
}
```

## 🔧 Core Package Dependencies

Add to your app's `pubspec.yaml`:

```yaml
dependencies:
  core:
    path: ../../packages/core
  equatable: ^2.0.5  # Required by BoxConfiguration
```

## 🧪 Testing Migration

### Verify Clean Separation

```dart
void main() {
  test('app storage is isolated', () async {
    final boxRegistry = BoxRegistryService();
    await YourAppStorageInitializer.initialize(boxRegistry);
    
    // Should only see your app's boxes
    final yourBoxes = boxRegistry.getRegisteredBoxesForApp('your_app');
    expect(yourBoxes, isNotEmpty);
    
    // Should NOT see other app boxes
    final otherAppBoxes = boxRegistry.getRegisteredBoxesForApp('other_app');
    expect(otherAppBoxes, isEmpty);
  });
}
```

### Data Isolation Test

```dart
test('cannot access other app data', () async {
  final boxRegistry = BoxRegistryService();
  
  // Try to access another app's box
  expect(
    boxRegistry.canAppAccessBox('receituagro', 'your_app'), 
    isFalse,
  );
});
```

## 📊 Benefits Achieved

### ✅ Clean Architecture Compliance
- Core package contains ZERO app-specific references
- Proper dependency inversion (apps depend on core, not vice-versa)
- Clear separation of concerns

### ✅ Security & Isolation
- Apps cannot access each other's data
- Explicit app boundaries enforced
- No cross-contamination possible

### ✅ Scalability
- New apps can be added without modifying core
- Independent app development
- Easy to maintain and extend

### ✅ Maintainability
- Clear ownership of storage concerns
- Easier to debug storage issues
- Reduced coupling between components

## 🚨 Breaking Changes

### For Existing Apps:
1. **Import Changes**: Update imports to use app-specific boxes
2. **Box References**: Replace `HiveBoxes.app_name` with `YourAppBoxes.main`
3. **Initialization**: Add storage initialization to app startup
4. **DI Registration**: Register BoxRegistryService in your DI container

### Migration Timeline:
1. **Phase 1**: Core decontamination (✅ COMPLETED)
2. **Phase 2**: App-receituagro migration (✅ COMPLETED)
3. **Phase 3**: Remaining apps (app-gasometer, app-plantis, etc.)
4. **Phase 4**: Remove legacy compatibility layer

## 🔍 Troubleshooting

### Common Issues:

**1. Box not found errors:**
```dart
// Ensure storage is initialized before use
await YourAppStorageInitializer.initialize(boxRegistry);
```

**2. Data not persisting:**
```dart
// Check box name is correct
box: YourAppBoxes.main, // Not HiveBoxes.your_app
```

**3. DI resolution errors:**
```dart
// Register services in correct order
GetIt.instance.registerSingleton<IBoxRegistryService>(boxRegistry);
GetIt.instance.registerSingleton<ILocalStorageRepository>(hiveStorage);
```

## 📈 Next Steps

1. **Apply to remaining apps** (gasometer, plantis, task_manager, etc.)
2. **Remove legacy compatibility** once all apps are migrated
3. **Add monitoring** for box access patterns
4. **Implement encryption** for sensitive data boxes
5. **Add backup/restore** functionality per app

This architectural refactoring establishes a clean, scalable foundation that prevents future contamination issues while maintaining proper separation of concerns across the monorepo.