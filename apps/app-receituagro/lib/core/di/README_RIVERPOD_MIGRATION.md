# ReceitaAgro DI System - GetIt to Riverpod Migration

## Overview

The app-receituagro DI system has been completely refactored from GetIt to Riverpod `@riverpod` providers. This document provides a comprehensive guide for the migration.

## Migration Status

✅ **COMPLETED**
- All core services migrated to Riverpod providers
- Database access via `@riverpod` providers
- All repositories via `@riverpod` providers
- Account deletion module → `account_deletion_providers.dart`
- Sync module → `sync_providers.dart`
- Legacy GetIt files deprecated with migration guides

## New File Structure

```
lib/core/di/
├── providers_setup.dart               # Main provider definitions
├── modules/
│   ├── account_deletion_providers.dart  # Account deletion services
│   └── sync_providers.dart              # Sync-related services
├── injection_container.dart            # DEPRECATED (kept for compatibility)
├── repositories_di.dart                # DEPRECATED (kept for compatibility)
└── modules/
    ├── account_deletion_module.dart    # DEPRECATED (kept for compatibility)
    └── sync_module.dart                # DEPRECATED (kept for compatibility)
```

## Provider Categories

### 1. Database & Core Infrastructure

```dart
// Database instance
final db = ref.watch(receituagrodatabaseProvider);
```

### 2. Repositories (Data Layer)

```dart
// Pragas data access
final pragasRepo = ref.watch(pragasRepositoryProvider);

// Fitossanitarios data access
final fitossanitariosRepo = ref.watch(fitossanitariosRepositoryProvider);

// Culturas data access
final culturasRepo = ref.watch(culturasRepositoryProvider);

// Diagnosticos data access
final diagnosticoRepo = ref.watch(diagnosticoRepositoryProvider);

// Favoritos data access
final favoritoRepo = ref.watch(favoritoRepositoryProvider);

// Comentarios data access
final comentarioRepo = ref.watch(comentarioRepositoryProvider);
```

### 3. Sync Infrastructure

```dart
// Sync queue for offline operations
final queue = ref.watch(syncQueueProvider);

// Sync operations manager
final syncOps = ref.watch(syncOperationsProvider);

// Drift storage adapter
final storage = ref.watch(localStorageRepositoryProvider);

// Main sync service
final syncService = ref.watch(receitaAgroSyncServiceProvider);
```

### 4. Core Services (from Core Package)

```dart
// Firebase services
final firebaseDevice = ref.watch(firebaseDeviceServiceProvider);
final analytics = ref.watch(firebaseAnalyticsServiceProvider);

// Navigation services
final navConfig = ref.watch(navigationConfigurationServiceProvider);
final navAnalytics = ref.watch(navigationAnalyticsServiceProvider);
final enhancedNav = ref.watch(enhancedNavigationServiceProvider);

// Subscription & Rating
final subscription = ref.watch(subscriptionRepositoryProvider);
final appRating = ref.watch(appRatingRepositoryProvider);

// Sync manager
final unifiedSync = ref.watch(unifiedSyncManagerProvider);
```

### 5. App-Specific Services

```dart
// Device & Identity
final deviceIdentity = ref.watch(deviceIdentityServiceProvider);

// Configuration
final remoteConfig = ref.watch(remoteConfigServiceProvider);
final cloudFunctions = ref.watch(cloudFunctionsServiceProvider);

// Data Management
final appDataManager = ref.watch(appDataManagerProvider);
final appDataCleaner = ref.watch(appDataCleanerProvider);

// Notifications
final notificationService = ref.watch(notificationServiceProvider);
final firebaseMessaging = ref.watch(firebaseMessagingServiceProvider);
final promotionalNotifications = ref.watch(promotionalNotificationManagerProvider);

// Integration
final diagnosticoIntegration = ref.watch(diagnosticoIntegrationServiceProvider);
```

### 6. Navigation Services

```dart
// Agricultural navigation extension
final agricNav = ref.watch(agriculturalNavigationExtensionProvider);

// ReceitaAgro navigation
final receituagroNav = ref.watch(receituagroNavigationServiceProvider);

// Favoritos navigation
final favoritosNav = ref.watch(favoritosNavigationServiceProvider);
```

### 7. Pragas por Cultura Services

```dart
// Query service
final queryService = ref.watch(pragasCulturaQueryServiceProvider);

// Sort service
final sortService = ref.watch(pragasCulturaSortServiceProvider);

// Statistics service
final statsService = ref.watch(pragasCulturaStatisticsServiceProvider);

// Data service
final dataService = ref.watch(pragasCulturaDataServiceProvider);
```

### 8. Premium Services

```dart
// Mock premium service (development)
final mockPremium = ref.watch(premiumServiceMockProvider);

// Analytics service
final receituagroAnalytics = ref.watch(receituagroAnalyticsServiceProvider);

// Main premium service
final premiumService = ref.watch(receituagroPremiumServiceProvider);
```

### 9. Defensivos Grouping (Strategy Pattern)

```dart
// Strategy registry
final strategyRegistry = ref.watch(defensivoGroupingStrategyRegistryProvider);

// Grouping service V2
final groupingV2 = ref.watch(defensivoGroupingServiceV2Provider);

// Legacy grouping service (backward compatibility)
final groupingLegacy = ref.watch(defensivosGroupingServiceProvider);
```

### 10. Account Deletion Module

```dart
// Import the account deletion providers
import 'package:app_receituagro/core/di/modules/account_deletion_providers.dart';

// Firestore deletion
final firestoreDeletion = ref.watch(firestoreDeletionServiceProvider);

// RevenueCat cancellation
final revenueCatCancellation = ref.watch(revenueCatCancellationServiceProvider);

// Rate limiter
final rateLimiter = ref.watch(accountDeletionRateLimiterProvider);

// Main deletion service
final deletionService = ref.watch(enhancedAccountDeletionServiceProvider);
```

### 11. Sync Module

```dart
// Import the sync providers
import 'package:app_receituagro/core/di/modules/sync_providers.dart';

// Initialize sync service
final initialized = await ref.read(initializeSyncServiceProvider.future);

// Perform initial sync
await ref.read(performInitialSyncProvider.future);

// Sync user data
await ref.read(syncUserDataProvider.future);

// Get statistics
final stats = await ref.read(syncStatisticsProvider.future);

// Clear sync data
await ref.read(clearSyncDataProvider.future);
```

## Migration Examples

### Example 1: Simple Service Access

**Before (GetIt):**
```dart
import 'package:get_it/get_it.dart';

class MyWidget extends StatelessWidget {
  final analyticsService = GetIt.instance<ReceitaAgroAnalyticsService>();

  void trackEvent() {
    analyticsService.logEvent('my_event');
  }
}
```

**After (Riverpod):**
```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_receituagro/core/di/providers_setup.dart';

class MyWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final analyticsService = ref.watch(receituagroAnalyticsServiceProvider);

    return ElevatedButton(
      onPressed: () => analyticsService.logEvent('my_event'),
      child: Text('Track Event'),
    );
  }
}
```

### Example 2: Repository in a Notifier

**Before (GetIt):**
```dart
import 'package:get_it/get_it.dart';

class PragasNotifier extends ChangeNotifier {
  final _repository = GetIt.instance<PragasRepository>();

  Future<void> loadData() async {
    final data = await _repository.getAllPragas();
    // ...
  }
}
```

**After (Riverpod):**
```dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:app_receituagro/core/di/providers_setup.dart';

part 'pragas_notifier.g.dart';

@riverpod
class PragasNotifier extends _$PragasNotifier {
  @override
  Future<List<Praga>> build() async {
    final repository = ref.watch(pragasRepositoryProvider);
    return repository.getAllPragas();
  }

  Future<void> refresh() async {
    final repository = ref.read(pragasRepositoryProvider);
    state = AsyncLoading();
    state = await AsyncValue.guard(() => repository.getAllPragas());
  }
}
```

### Example 3: Multiple Dependencies

**Before (GetIt):**
```dart
class FavoritosService {
  final _fitossanitarioRepo = GetIt.instance<FitossanitariosRepository>();
  final _pragasRepo = GetIt.instance<PragasRepository>();
  final _integrationService = GetIt.instance<DiagnosticoIntegrationService>();

  Future<void> processFavorite(String id) async {
    // Use repositories...
  }
}
```

**After (Riverpod):**
```dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:app_receituagro/core/di/providers_setup.dart';

part 'favoritos_service.g.dart';

@riverpod
FavoritosService favoritosService(FavoritosServiceRef ref) {
  return FavoritosService(
    fitossanitarioRepo: ref.watch(fitossanitariosRepositoryProvider),
    pragasRepo: ref.watch(pragasRepositoryProvider),
    integrationService: ref.watch(diagnosticoIntegrationServiceProvider),
  );
}

class FavoritosService {
  final FitossanitariosRepository _fitossanitarioRepo;
  final PragasRepository _pragasRepo;
  final DiagnosticoIntegrationService _integrationService;

  FavoritosService({
    required FitossanitariosRepository fitossanitarioRepo,
    required PragasRepository pragasRepo,
    required DiagnosticoIntegrationService integrationService,
  }) : _fitossanitarioRepo = fitossanitarioRepo,
       _pragasRepo = pragasRepo,
       _integrationService = integrationService;

  Future<void> processFavorite(String id) async {
    // Use repositories...
  }
}
```

### Example 4: Initialization in main.dart

**Before (GetIt):**
```dart
import 'package:app_receituagro/core/di/injection_container.dart' as di;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await di.init(); // Initialize all services

  runApp(MyApp());
}
```

**After (Riverpod):**
```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // No manual initialization needed!
  // Providers are lazy-loaded when first accessed

  runApp(
    ProviderScope(
      child: MyApp(),
    ),
  );
}
```

### Example 5: Sync Operations

**Before (GetIt):**
```dart
import 'package:app_receituagro/core/di/modules/sync_module.dart';
import 'package:app_receituagro/core/di/injection_container.dart' as di;

Future<void> initializeSync() async {
  SyncDIModule.init(di.sl);
  await SyncDIModule.initializeSyncService(di.sl);
  await SyncDIModule.performInitialSync(di.sl);
}
```

**After (Riverpod):**
```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_receituagro/core/di/modules/sync_providers.dart';

// In a ConsumerWidget or provider
Future<void> initializeSync(WidgetRef ref) async {
  final initialized = await ref.read(initializeSyncServiceProvider.future);
  if (initialized) {
    await ref.read(performInitialSyncProvider.future);
  }
}
```

## Code Generation

After creating or modifying `@riverpod` providers, run:

```bash
# From app-receituagro directory
dart run build_runner watch --delete-conflicting-outputs
```

This will generate the necessary `.g.dart` files for all providers.

## Provider Types

### keepAlive: true (Singleton)
Most services use `@Riverpod(keepAlive: true)` to create singleton-like behavior:

```dart
@Riverpod(keepAlive: true)
MyService myService(MyServiceRef ref) {
  return MyService();
}
```

### Auto-dispose (Default)
For temporary data or operations, use default `@riverpod`:

```dart
@riverpod
Future<Data> fetchData(FetchDataRef ref) async {
  // Will be disposed when no longer watched
  return await someAsyncOperation();
}
```

## Testing

### Before (GetIt):
```dart
void main() {
  setUp(() {
    GetIt.instance.registerSingleton<MyService>(MockMyService());
  });

  tearDown(() {
    GetIt.instance.reset();
  });
}
```

### After (Riverpod):
```dart
void main() {
  test('my test', () {
    final container = ProviderContainer(
      overrides: [
        myServiceProvider.overrideWithValue(MockMyService()),
      ],
    );

    final service = container.read(myServiceProvider);
    // Test service...

    container.dispose();
  });
}
```

## Benefits of Migration

1. **Type Safety**: Riverpod provides compile-time type safety
2. **No GetIt.instance**: Direct provider access via `ref.watch()`
3. **Auto-dispose**: Memory management handled automatically
4. **Testability**: Easy provider overrides for testing
5. **Hot Reload**: Better hot reload support
6. **Code Generation**: Reduced boilerplate with `@riverpod`
7. **Dependency Graph**: Clear dependency relationships
8. **No Manual Init**: Lazy initialization built-in

## Common Pitfalls

### 1. Forgetting ProviderScope
```dart
// ❌ Wrong
runApp(MyApp());

// ✅ Correct
runApp(ProviderScope(child: MyApp()));
```

### 2. Using ref.watch in async callbacks
```dart
// ❌ Wrong
onPressed: () async {
  final service = ref.watch(myServiceProvider); // Can cause rebuild loops
}

// ✅ Correct
onPressed: () async {
  final service = ref.read(myServiceProvider);
}
```

### 3. Not running code generation
```bash
# Always run after adding @riverpod providers
dart run build_runner watch --delete-conflicting-outputs
```

## Next Steps

1. ✅ All core DI migrated to Riverpod
2. 🔄 Migrate UI layer to ConsumerWidget/ConsumerStatefulWidget
3. 🔄 Remove GetIt dependency from pubspec.yaml
4. 🔄 Delete deprecated GetIt files
5. 🔄 Update tests to use ProviderContainer

## Support

For questions or issues during migration:
- See examples in `providers_setup.dart`
- Check Riverpod documentation: https://riverpod.dev
- Review migration guides in deprecated files
