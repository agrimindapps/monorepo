# Provider Mapping Reference - GetIt to Riverpod

## Quick Reference Table

| GetIt Type | Riverpod Provider | Location |
|-----------|------------------|----------|
| `ReceituagroDatabase` | `receituagrodatabaseProvider` | providers_setup.dart |
| `PragasRepository` | `pragasRepositoryProvider` | providers_setup.dart |
| `FitossanitariosRepository` | `fitossanitariosRepositoryProvider` | providers_setup.dart |
| `CulturasRepository` | `culturasRepositoryProvider` | providers_setup.dart |
| `DiagnosticoRepository` | `diagnosticoRepositoryProvider` | providers_setup.dart |
| `FavoritoRepository` | `favoritoRepositoryProvider` | providers_setup.dart |
| `ComentarioRepository` | `comentarioRepositoryProvider` | providers_setup.dart |
| `SyncQueue` | `syncQueueProvider` | providers_setup.dart |
| `SyncOperations` | `syncOperationsProvider` | providers_setup.dart |
| `ILocalStorageRepository` | `localStorageRepositoryProvider` | providers_setup.dart |
| `ReceitaAgroSyncService` | `receitaAgroSyncServiceProvider` | providers_setup.dart |
| `FirebaseDeviceService` | `firebaseDeviceServiceProvider` | providers_setup.dart |
| `NavigationConfigurationService` | `navigationConfigurationServiceProvider` | providers_setup.dart |
| `NavigationAnalyticsService` | `navigationAnalyticsServiceProvider` | providers_setup.dart |
| `FirebaseAnalyticsService` | `firebaseAnalyticsServiceProvider` | providers_setup.dart |
| `EnhancedNavigationService` | `enhancedNavigationServiceProvider` | providers_setup.dart |
| `UnifiedSyncManager` | `unifiedSyncManagerProvider` | providers_setup.dart |
| `ISubscriptionRepository` | `subscriptionRepositoryProvider` | providers_setup.dart |
| `IAppRatingRepository` | `appRatingRepositoryProvider` | providers_setup.dart |
| `DeviceIdentityService` | `deviceIdentityServiceProvider` | providers_setup.dart |
| `ReceitaAgroRemoteConfigService` | `remoteConfigServiceProvider` | providers_setup.dart |
| `ReceitaAgroCloudFunctionsService` | `cloudFunctionsServiceProvider` | providers_setup.dart |
| `IAppDataManager` | `appDataManagerProvider` | providers_setup.dart |
| `IAppDataCleaner` | `appDataCleanerProvider` | providers_setup.dart |
| `IReceitaAgroNotificationService` | `notificationServiceInterfaceProvider` | providers_setup.dart |
| `ReceitaAgroNotificationService` | `notificationServiceProvider` | providers_setup.dart |
| `ReceitaAgroFirebaseMessagingService` | `firebaseMessagingServiceProvider` | providers_setup.dart |
| `PromotionalNotificationManager` | `promotionalNotificationManagerProvider` | providers_setup.dart |
| `DiagnosticoIntegrationService` | `diagnosticoIntegrationServiceProvider` | providers_setup.dart |
| `AgriculturalNavigationExtension` | `agriculturalNavigationExtensionProvider` | providers_setup.dart |
| `ReceitaAgroNavigationService` | `receituagroNavigationServiceProvider` | providers_setup.dart |
| `FavoritosNavigationService` | `favoritosNavigationServiceProvider` | providers_setup.dart |
| `IPragasCulturaQueryService` | `pragasCulturaQueryServiceProvider` | providers_setup.dart |
| `IPragasCulturaSortService` | `pragasCulturaSortServiceProvider` | providers_setup.dart |
| `IPragasCulturaStatisticsService` | `pragasCulturaStatisticsServiceProvider` | providers_setup.dart |
| `IPragasCulturaDataService` | `pragasCulturaDataServiceProvider` | providers_setup.dart |
| `IPremiumService` | `premiumServiceMockProvider` | providers_setup.dart |
| `ReceitaAgroAnalyticsService` | `receituagroAnalyticsServiceProvider` | providers_setup.dart |
| `ReceitaAgroPremiumService` | `receituagroPremiumServiceProvider` | providers_setup.dart |
| `DefensivoGroupingStrategyRegistry` | `defensivoGroupingStrategyRegistryProvider` | providers_setup.dart |
| `DefensivoGroupingServiceV2` | `defensivoGroupingServiceV2Provider` | providers_setup.dart |
| `DefensivosGroupingService` | `defensivosGroupingServiceProvider` | providers_setup.dart |

## Account Deletion Module Mapping

| GetIt Type | Riverpod Provider | Location |
|-----------|------------------|----------|
| `FirestoreDeletionService` | `firestoreDeletionServiceProvider` | modules/account_deletion_providers.dart |
| `RevenueCatCancellationService` | `revenueCatCancellationServiceProvider` | modules/account_deletion_providers.dart |
| `AccountDeletionRateLimiter` | `accountDeletionRateLimiterProvider` | modules/account_deletion_providers.dart |
| `EnhancedAccountDeletionService` | `enhancedAccountDeletionServiceProvider` | modules/account_deletion_providers.dart |

## Sync Module Mapping

| GetIt Function | Riverpod Provider | Location |
|---------------|------------------|----------|
| `SyncDIModule.initializeSyncService()` | `initializeSyncServiceProvider` | modules/sync_providers.dart |
| `SyncDIModule.performInitialSync()` | `performInitialSyncProvider` | modules/sync_providers.dart |
| `SyncDIModule.syncUserData()` | `syncUserDataProvider` | modules/sync_providers.dart |
| `SyncDIModule.printSyncStatistics()` | `syncStatisticsProvider` | modules/sync_providers.dart |
| `SyncDIModule.clearSyncData()` | `clearSyncDataProvider` | modules/sync_providers.dart |

## Provider Dependencies

### Database Provider
```dart
@Riverpod(keepAlive: true)
ReceituagroDatabase receituagroDatabase(ReceituagrodatabaseRef ref) {
  final db = ReceituagroDatabase();
  ref.onDispose(() => db.close());
  return db;
}
```

**Dependencies:** None
**Dependent Providers:** All repository providers

### Repository Providers
```dart
@Riverpod(keepAlive: true)
PragasRepository pragasRepository(PragasRepositoryRef ref) {
  final db = ref.watch(receituagrodatabaseProvider);
  return PragasRepository(db);
}
```

**Dependencies:** `receituagrodatabaseProvider`
**Dependent Providers:** Navigation services, data services

### Sync Service Provider
```dart
@Riverpod(keepAlive: true)
ReceitaAgroSyncService receitaAgroSyncService(ReceitaAgroSyncServiceRef ref) {
  return ReceitaAgroSyncServiceFactory.create();
}
```

**Dependencies:** None
**Dependent Providers:** Sync operation providers

### Premium Service Provider
```dart
@Riverpod(keepAlive: true)
ReceitaAgroPremiumService receituagroPremiumService(
  ReceituagroPremiumServiceRef ref,
) {
  final analytics = ref.watch(receituagroAnalyticsServiceProvider);
  final cloudFunctions = ref.watch(cloudFunctionsServiceProvider);
  final remoteConfig = ref.watch(remoteConfigServiceProvider);
  final subscriptionRepo = ref.watch(subscriptionRepositoryProvider);

  final service = ReceitaAgroPremiumService(
    analytics: analytics,
    cloudFunctions: cloudFunctions,
    remoteConfig: remoteConfig,
    subscriptionRepository: subscriptionRepo,
  );

  ReceitaAgroPremiumService.setInstance(service);
  return service;
}
```

**Dependencies:**
- `receituagroAnalyticsServiceProvider`
- `cloudFunctionsServiceProvider`
- `remoteConfigServiceProvider`
- `subscriptionRepositoryProvider`

**Dependent Providers:** Premium-related features

### Navigation Service Provider
```dart
@Riverpod(keepAlive: true)
ReceitaAgroNavigationService receituagroNavigationService(
  ReceituagroNavigationServiceRef ref,
) {
  final coreService = ref.watch(enhancedNavigationServiceProvider);
  final agricExtension = ref.watch(agriculturalNavigationExtensionProvider);
  return ReceitaAgroNavigationService(
    coreService: coreService,
    agricExtension: agricExtension,
  );
}
```

**Dependencies:**
- `enhancedNavigationServiceProvider`
- `agriculturalNavigationExtensionProvider`

**Dependent Providers:** UI navigation logic

## Provider Lifecycle

### Keep Alive (Singleton)
Most providers use `@Riverpod(keepAlive: true)` to maintain state:

```dart
@Riverpod(keepAlive: true)
MyService myService(MyServiceRef ref) => MyService();
```

**Characteristics:**
- Created once on first access
- Never disposed automatically
- Similar to GetIt singletons
- Use for: Services, repositories, configuration

### Auto-Dispose (Default)
Some providers auto-dispose when no longer watched:

```dart
@riverpod
Future<Data> temporaryData(TemporaryDataRef ref) async {
  // Auto-disposed when no listeners
  return await fetchData();
}
```

**Characteristics:**
- Created when first watched
- Disposed when last listener removes
- Use for: Temporary data, API calls, disposable resources

## Type Hints for All Providers

### Database
```dart
ReceituagroDatabase db = ref.watch(receituagrodatabaseProvider);
```

### Repositories
```dart
PragasRepository pragasRepo = ref.watch(pragasRepositoryProvider);
FitossanitariosRepository fitossanitariosRepo = ref.watch(fitossanitariosRepositoryProvider);
CulturasRepository culturasRepo = ref.watch(culturasRepositoryProvider);
DiagnosticoRepository diagnosticoRepo = ref.watch(diagnosticoRepositoryProvider);
FavoritoRepository favoritoRepo = ref.watch(favoritoRepositoryProvider);
ComentarioRepository comentarioRepo = ref.watch(comentarioRepositoryProvider);
```

### Sync
```dart
SyncQueue queue = ref.watch(syncQueueProvider);
SyncOperations ops = ref.watch(syncOperationsProvider);
ILocalStorageRepository storage = ref.watch(localStorageRepositoryProvider);
ReceitaAgroSyncService sync = ref.watch(receitaAgroSyncServiceProvider);
```

### Core Services
```dart
FirebaseDeviceService firebaseDevice = ref.watch(firebaseDeviceServiceProvider);
NavigationConfigurationService navConfig = ref.watch(navigationConfigurationServiceProvider);
NavigationAnalyticsService navAnalytics = ref.watch(navigationAnalyticsServiceProvider);
FirebaseAnalyticsService analytics = ref.watch(firebaseAnalyticsServiceProvider);
EnhancedNavigationService enhancedNav = ref.watch(enhancedNavigationServiceProvider);
UnifiedSyncManager unifiedSync = ref.watch(unifiedSyncManagerProvider);
ISubscriptionRepository subscription = ref.watch(subscriptionRepositoryProvider);
IAppRatingRepository appRating = ref.watch(appRatingRepositoryProvider);
```

### App Services
```dart
DeviceIdentityService deviceIdentity = ref.watch(deviceIdentityServiceProvider);
ReceitaAgroRemoteConfigService remoteConfig = ref.watch(remoteConfigServiceProvider);
ReceitaAgroCloudFunctionsService cloudFunctions = ref.watch(cloudFunctionsServiceProvider);
IAppDataManager appDataManager = ref.watch(appDataManagerProvider);
IAppDataCleaner appDataCleaner = ref.watch(appDataCleanerProvider);
IReceitaAgroNotificationService notificationInterface = ref.watch(notificationServiceInterfaceProvider);
ReceitaAgroNotificationService notificationService = ref.watch(notificationServiceProvider);
ReceitaAgroFirebaseMessagingService firebaseMessaging = ref.watch(firebaseMessagingServiceProvider);
PromotionalNotificationManager promotionalNotifications = ref.watch(promotionalNotificationManagerProvider);
DiagnosticoIntegrationService diagnosticoIntegration = ref.watch(diagnosticoIntegrationServiceProvider);
```

### Navigation
```dart
AgriculturalNavigationExtension agricNav = ref.watch(agriculturalNavigationExtensionProvider);
ReceitaAgroNavigationService receituagroNav = ref.watch(receituagroNavigationServiceProvider);
FavoritosNavigationService favoritosNav = ref.watch(favoritosNavigationServiceProvider);
```

### Pragas por Cultura
```dart
IPragasCulturaQueryService queryService = ref.watch(pragasCulturaQueryServiceProvider);
IPragasCulturaSortService sortService = ref.watch(pragasCulturaSortServiceProvider);
IPragasCulturaStatisticsService statsService = ref.watch(pragasCulturaStatisticsServiceProvider);
IPragasCulturaDataService dataService = ref.watch(pragasCulturaDataServiceProvider);
```

### Premium
```dart
IPremiumService mockPremium = ref.watch(premiumServiceMockProvider);
ReceitaAgroAnalyticsService receituagroAnalytics = ref.watch(receituagroAnalyticsServiceProvider);
ReceitaAgroPremiumService premiumService = ref.watch(receituagroPremiumServiceProvider);
```

### Defensivos
```dart
DefensivoGroupingStrategyRegistry strategyRegistry = ref.watch(defensivoGroupingStrategyRegistryProvider);
DefensivoGroupingServiceV2 groupingV2 = ref.watch(defensivoGroupingServiceV2Provider);
DefensivosGroupingService groupingLegacy = ref.watch(defensivosGroupingServiceProvider);
```

### Account Deletion
```dart
FirestoreDeletionService firestoreDeletion = ref.watch(firestoreDeletionServiceProvider);
RevenueCatCancellationService revenueCatCancellation = ref.watch(revenueCatCancellationServiceProvider);
AccountDeletionRateLimiter rateLimiter = ref.watch(accountDeletionRateLimiterProvider);
EnhancedAccountDeletionService deletionService = ref.watch(enhancedAccountDeletionServiceProvider);
```

### Sync Operations (Async)
```dart
// All return Future, use .future suffix
Future<bool> initialized = ref.read(initializeSyncServiceProvider.future);
Future<void> initialSync = ref.read(performInitialSyncProvider.future);
Future<void> userSync = ref.read(syncUserDataProvider.future);
Future<Map<String, dynamic>> stats = ref.read(syncStatisticsProvider.future);
Future<void> clearSync = ref.read(clearSyncDataProvider.future);
```

## Usage Patterns

### In ConsumerWidget
```dart
class MyWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final service = ref.watch(myServiceProvider);
    return Text('Data: ${service.data}');
  }
}
```

### In ConsumerStatefulWidget
```dart
class MyWidget extends ConsumerStatefulWidget {
  @override
  ConsumerState<MyWidget> createState() => _MyWidgetState();
}

class _MyWidgetState extends ConsumerState<MyWidget> {
  @override
  Widget build(BuildContext context) {
    final service = ref.watch(myServiceProvider);
    return Text('Data: ${service.data}');
  }
}
```

### In Riverpod Notifier
```dart
@riverpod
class MyNotifier extends _$MyNotifier {
  @override
  Future<Data> build() async {
    final repository = ref.watch(myRepositoryProvider);
    return repository.getData();
  }

  Future<void> refresh() async {
    final repository = ref.read(myRepositoryProvider);
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => repository.getData());
  }
}
```

### In Callbacks (use ref.read)
```dart
ElevatedButton(
  onPressed: () {
    final service = ref.read(myServiceProvider);
    service.doSomething();
  },
  child: Text('Action'),
)
```

## Code Generation Command

```bash
# Run from app-receituagro directory
dart run build_runner watch --delete-conflicting-outputs
```

This generates all `.g.dart` files for providers.
