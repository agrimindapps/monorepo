# Settings Composite Pattern - Implementation Guide

## 📋 Overview

The Settings feature in app-receituagro now implements the **Composite Pattern** for unified settings management. This provides a single point of access to all settings repositories while maintaining individual repository responsibilities.

## 🏗️ Architecture

### Current Repository Structure

```
settings/
├── domain/
│   └── repositories/
│       ├── i_user_settings_repository.dart         # User preferences
│       ├── i_tts_settings_repository.dart         # Text-to-speech
│       ├── profile_repository.dart                # Profile image
│       └── i_settings_composite_repository.dart   # 🆕 Composite (unified)
└── data/
    └── repositories/
        ├── user_settings_repository_impl.dart
        ├── tts_settings_repository_impl.dart
        ├── profile_repository_impl.dart
        └── settings_composite_repository_impl.dart # 🆕 Implementation
```

## 🎯 Problem Solved

### Before (Multiple Repositories)

```dart
class SettingsController {
  final IUserSettingsRepository _userSettings;
  final ITTSSettingsRepository _ttsSettings;
  final ProfileRepository _profile;

  SettingsController(
    this._userSettings,    // 😫 Multiple injections
    this._ttsSettings,     // 😫 Hard to manage
    this._profile,         // 😫 Difficult to extend
  );

  Future<void> resetAll(String userId) async {
    // 😫 Must call each repository manually
    await _userSettings.resetToDefault(userId);
    await _ttsSettings.resetToDefault(userId);
    // What about error handling?
  }

  Future<Map<String, dynamic>> exportAll(String userId) async {
    // 😫 Manual aggregation
    final user = await _userSettings.exportSettings(userId);
    final tts = await _ttsSettings.getSettings(userId);
    // ... complex logic to combine
  }
}
```

### After (Composite Repository)

```dart
class SettingsController {
  final ISettingsCompositeRepository _settings; // ✅ Single injection

  SettingsController(this._settings);

  Future<void> resetAll(String userId) async {
    // ✅ Single call, unified operation
    final result = await _settings.resetAllSettings(userId);
    
    result.fold(
      (failure) => handleError(failure),
      (_) => showSuccess(),
    );
  }

  Future<Map<String, dynamic>> exportAll(String userId) async {
    // ✅ Built-in aggregation
    final result = await _settings.exportAllSettings(userId);
    
    return result.fold(
      (failure) => throw failure,
      (data) => data,
    );
  }
}
```

## 🔑 Key Interfaces

### Composite Repository Interface

```dart
abstract class ISettingsCompositeRepository {
  // Individual settings delegation
  Future<Either<Failure, UserSettingsEntity?>> getUserSettings(String userId);
  Future<Either<Failure, TTSSettingsEntity>> getTTSSettings(String userId);
  Future<Either<Failure, ProfileImageResult>> uploadProfileImage(File file);
  
  // Unified composite operations
  Future<Either<Failure, Unit>> resetAllSettings(String userId);
  Future<Either<Failure, Map<String, dynamic>>> exportAllSettings(String userId);
  Future<Either<Failure, Unit>> importAllSettings(String userId, Map data);
  Future<Either<Failure, SettingsSummary>> getSettingsSummary(String userId);
}
```

### Settings Summary (Aggregated Data)

```dart
class SettingsSummary {
  final bool hasUserSettings;
  final bool hasTTSSettings;
  final bool hasProfileImage;
  final int totalSettingsCount;
  final DateTime? lastUpdated;
}
```

## 💡 Usage Patterns

### Pattern 1: Individual Settings Access

```dart
// Access individual settings through composite
final userSettingsResult = await composite.getUserSettings(userId);
final ttsResult = await composite.getTTSSettings(userId);

// Update specific setting
await composite.updateUserSetting(userId, 'darkMode', true);
await composite.saveTTSSettings(userId, updatedTTS);
```

### Pattern 2: Unified Operations

```dart
// Reset everything at once
await composite.resetAllSettings(userId);

// Export all for backup
final exportResult = await composite.exportAllSettings(userId);
exportResult.fold(
  (failure) => print('Error: ${failure.message}'),
  (data) {
    // data contains:
    // - userSettings
    // - ttsSettings
    // - profile info
    // - metadata
  },
);

// Import all from backup
await composite.importAllSettings(userId, backupData);
```

### Pattern 3: Settings Summary

```dart
// Get aggregated information
final summaryResult = await composite.getSettingsSummary(userId);

summaryResult.fold(
  (failure) => showError(failure),
  (summary) {
    print('User has ${summary.totalSettingsCount} settings');
    print('Last updated: ${summary.lastUpdated}');
    print('Has profile image: ${summary.hasProfileImage}');
  },
);
```

## 🎨 Riverpod Integration

### Provider Setup

```dart
// Individual repositories (still available if needed)
@riverpod
IUserSettingsRepository userSettingsRepo(UserSettingsRepoRef ref) {
  return ref.watch(getIt<IUserSettingsRepository>());
}

// Composite repository (recommended)
@riverpod
ISettingsCompositeRepository settingsComposite(SettingsCompositeRef ref) {
  return ref.watch(getIt<ISettingsCompositeRepository>());
}

// Settings controller using composite
@riverpod
class SettingsController extends _$SettingsController {
  @override
  FutureOr<SettingsSummary> build(String userId) async {
    final composite = ref.read(settingsCompositeProvider);
    final result = await composite.getSettingsSummary(userId);
    
    return result.fold(
      (failure) => throw failure,
      (summary) => summary,
    );
  }

  Future<void> resetAll() async {
    state = const AsyncValue.loading();
    
    state = await AsyncValue.guard(() async {
      final userId = _getCurrentUserId();
      final composite = ref.read(settingsCompositeProvider);
      
      final result = await composite.resetAllSettings(userId);
      
      return result.fold(
        (failure) => throw failure,
        (_) async {
          // Reload summary
          final summaryResult = await composite.getSettingsSummary(userId);
          return summaryResult.fold(
            (failure) => throw failure,
            (summary) => summary,
          );
        },
      );
    });
  }

  Future<void> exportSettings() async {
    final userId = _getCurrentUserId();
    final composite = ref.read(settingsCompositeProvider);
    
    final result = await composite.exportAllSettings(userId);
    
    result.fold(
      (failure) => ref.read(snackbarProvider).showError(failure.message),
      (data) => _saveToFile(data),
    );
  }
}
```

### UI Integration

```dart
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userId = ref.watch(currentUserIdProvider);
    final summaryAsync = ref.watch(settingsControllerProvider(userId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Configurações'),
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: () => _exportSettings(ref),
          ),
          IconButton(
            icon: const Icon(Icons.restart_alt),
            onPressed: () => _resetAll(context, ref, userId),
          ),
        ],
      ),
      body: summaryAsync.when(
        data: (summary) => _buildSettingsList(context, summary),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => ErrorView(
          error: error,
          onRetry: () => ref.invalidate(settingsControllerProvider(userId)),
        ),
      ),
    );
  }

  Widget _buildSettingsList(BuildContext context, SettingsSummary summary) {
    return ListView(
      children: [
        SettingsSummaryCard(summary: summary),
        
        if (summary.hasUserSettings)
          UserSettingsSection(),
        
        if (summary.hasTTSSettings)
          TTSSettingsSection(),
        
        if (summary.hasProfileImage)
          ProfileImageSection(),
      ],
    );
  }

  Future<void> _resetAll(
    BuildContext context,
    WidgetRef ref,
    String userId,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => const ResetAllConfirmDialog(),
    );

    if (confirmed == true) {
      await ref
          .read(settingsControllerProvider(userId).notifier)
          .resetAll();
    }
  }

  Future<void> _exportSettings(WidgetRef ref) async {
    await ref.read(settingsControllerProvider.notifier).exportSettings();
  }
}
```

## ✅ Benefits

### 1. Single Point of Access
- One repository handles all settings operations
- Simplified dependency injection
- Easier to test with single mock

### 2. Composition Over Inheritance
- Delegates to specialized repositories
- Each repository maintains single responsibility
- No code duplication

### 3. Unified Operations
- `resetAllSettings()` - resets everything at once
- `exportAllSettings()` - creates complete backup
- `importAllSettings()` - restores from backup
- `getSettingsSummary()` - aggregated information

### 4. Backward Compatible
- Individual repositories still available
- Can use composite or individual as needed
- Gradual migration path

### 5. Easy to Extend
- Add new settings repository
- Update composite interface
- Update composite implementation
- Existing code doesn't break

## 🔄 Migration Guide

### Step 1: Update Existing Code (Optional)

```dart
// Old code (still works)
class OldController {
  final IUserSettingsRepository _userRepo;
  final ITTSSettingsRepository _ttsRepo;
  
  OldController(this._userRepo, this._ttsRepo);
}

// New code (recommended)
class NewController {
  final ISettingsCompositeRepository _settings;
  
  NewController(this._settings);
}
```

### Step 2: Use Composite for New Features

```dart
// For new features, prefer composite
@riverpod
class MyNewFeature extends _$MyNewFeature {
  @override
  FutureOr<void> build() async {
    // Use composite for settings
    final composite = ref.read(settingsCompositeProvider);
    await composite.resetAllSettings(userId);
  }
}
```

### Step 3: Refactor Complex Settings Operations

```dart
// Before: Complex manual aggregation
Future<Map<String, dynamic>> backup(String userId) async {
  final user = await _userRepo.exportSettings(userId);
  final tts = await _ttsRepo.getSettings(userId);
  
  // Manual error handling
  // Manual data combination
  // ...
}

// After: Built-in composite operation
Future<Map<String, dynamic>> backup(String userId) async {
  final result = await _composite.exportAllSettings(userId);
  return result.fold(
    (failure) => throw failure,
    (data) => data,
  );
}
```

## 🧪 Testing

### Testing Composite Repository

```dart
class MockUserSettingsRepo extends Mock implements IUserSettingsRepository {}
class MockTTSSettingsRepo extends Mock implements ITTSSettingsRepository {}
class MockProfileRepo extends Mock implements ProfileRepository {}

void main() {
  late SettingsCompositeRepositoryImpl composite;
  late MockUserSettingsRepo mockUserRepo;
  late MockTTSSettingsRepo mockTTSRepo;
  late MockProfileRepo mockProfileRepo;

  setUp(() {
    mockUserRepo = MockUserSettingsRepo();
    mockTTSRepo = MockTTSSettingsRepo();
    mockProfileRepo = MockProfileRepo();
    
    composite = SettingsCompositeRepositoryImpl(
      mockUserRepo,
      mockTTSRepo,
      mockProfileRepo,
    );
  });

  test('resetAllSettings should reset all repositories', () async {
    // Arrange
    when(() => mockUserRepo.resetToDefault(any()))
        .thenAnswer((_) async => Future.value());
    when(() => mockTTSRepo.resetToDefault(any()))
        .thenAnswer((_) async => const Right(unit));

    // Act
    final result = await composite.resetAllSettings('user-123');

    // Assert
    expect(result.isRight(), true);
    verify(() => mockUserRepo.resetToDefault('user-123')).called(1);
    verify(() => mockTTSRepo.resetToDefault('user-123')).called(1);
  });

  test('exportAllSettings should aggregate all settings', () async {
    // Arrange
    when(() => mockUserRepo.exportSettings(any()))
        .thenAnswer((_) async => {'user': 'data'});
    when(() => mockTTSRepo.getSettings(any()))
        .thenAnswer((_) async => Right(TTSSettingsEntity.defaults()));
    when(() => mockProfileRepo.hasProfileImage())
        .thenReturn(true);

    // Act
    final result = await composite.exportAllSettings('user-123');

    // Assert
    result.fold(
      (failure) => fail('Should not return failure'),
      (data) {
        expect(data['userSettings'], isNotNull);
        expect(data['ttsSettings'], isNotNull);
        expect(data['profile'], isNotNull);
        expect(data['metadata'], isNotNull);
      },
    );
  });
}
```

## 📚 References

- Composite Pattern: Design Patterns (Gang of Four)
- Clean Architecture: Robert C. Martin
- SOLID Principles: Single Responsibility maintained in individual repos
- Repository Pattern: Martin Fowler

## 🔍 See Also

- `COMPOSITE_PATTERN_USAGE.dart` - Complete usage examples
- `i_settings_composite_repository.dart` - Interface definition
- `settings_composite_repository_impl.dart` - Implementation
