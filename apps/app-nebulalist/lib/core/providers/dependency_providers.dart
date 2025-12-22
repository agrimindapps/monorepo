import 'package:core/core.dart';

import '../../features/items/data/datasources/item_master_local_datasource.dart';
import '../../features/items/data/datasources/item_master_remote_datasource.dart';
import '../../features/items/data/datasources/list_item_local_datasource.dart';
import '../../features/items/data/datasources/list_item_remote_datasource.dart';
import '../../features/items/data/repositories/item_master_repository.dart';
import '../../features/items/data/repositories/list_item_repository.dart';
import '../../features/items/domain/repositories/i_item_master_repository.dart';
import '../../features/items/domain/repositories/i_list_item_repository.dart';
import '../../features/items/domain/usecases/add_item_to_list_usecase.dart';
import '../../features/items/domain/usecases/check_item_limit_usecase.dart';
import '../../features/items/domain/usecases/create_item_master_usecase.dart';
import '../../features/items/domain/usecases/delete_item_master_usecase.dart';
import '../../features/items/domain/usecases/get_item_masters_usecase.dart';
import '../../features/items/domain/usecases/get_list_items_usecase.dart';
import '../../features/items/domain/usecases/remove_item_from_list_usecase.dart';
import '../../features/items/domain/usecases/toggle_item_completion_usecase.dart';
import '../../features/items/domain/usecases/update_item_master_usecase.dart';
import '../../features/items/domain/usecases/update_list_item_usecase.dart';
import '../../features/lists/data/datasources/list_local_datasource.dart';
import '../../features/lists/data/datasources/list_remote_datasource.dart';
import '../../features/lists/data/repositories/list_repository.dart';
import '../../features/lists/domain/repositories/i_list_repository.dart';
import '../../features/lists/domain/usecases/check_list_limit_usecase.dart';
import '../../features/lists/domain/usecases/create_list_usecase.dart';
import '../../features/lists/domain/usecases/delete_list_usecase.dart';
import '../../features/lists/domain/usecases/get_lists_usecase.dart';
import '../../features/lists/domain/usecases/update_list_usecase.dart';
import '../auth/auth_state_notifier.dart';
import '../../features/items/data/adapters/item_master_drift_sync_adapter.dart';
import '../../features/items/data/adapters/list_item_drift_sync_adapter.dart';
import '../../features/lists/data/adapters/list_drift_sync_adapter.dart';
import '../services/analytics_service.dart';
import '../services/background_sync_service.dart';
import '../services/nebulalist_sync_service.dart';
import '../services/notification_service.dart';
import '../services/share_service.dart';
import '../sync/basic_sync_service.dart';
import '../sync/nebulalist_sync_queue_service.dart';
import '../../features/subscription/presentation/providers/subscription_providers.dart';
import 'database_providers.dart';

// =============================================================================
// THIRD-PARTY PROVIDERS
// =============================================================================

/// Firebase Firestore instance
final firestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});

/// Firebase Auth instance
final firebaseAuthProvider = Provider<FirebaseAuth>((ref) {
  return FirebaseAuth.instance;
});

/// SharedPreferences instance (needs async initialization)
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('Must be overridden with ProviderScope');
});

/// AuthStateNotifier singleton
final authStateNotifierProvider = Provider<AuthStateNotifier>((ref) {
  return AuthStateNotifier.instance;
});

/// IAuthRepository from FirebaseAuthService (core package)
final authRepositoryProvider = Provider<IAuthRepository>((ref) {
  return FirebaseAuthService();
});

// =============================================================================
// CORE SERVICES PROVIDERS
// =============================================================================

/// Analytics Repository from core package
final analyticsRepositoryProvider = Provider<IAnalyticsRepository>((ref) {
  return FirebaseAnalyticsService();
});

/// OptimizedAnalyticsWrapper for efficient event logging
final analyticsWrapperProvider = Provider<OptimizedAnalyticsWrapper>((ref) {
  return OptimizedAnalyticsWrapper(ref.watch(analyticsRepositoryProvider));
});

/// Enhanced Notification Repository from core package
final notificationRepositoryProvider =
    Provider<IEnhancedNotificationRepository>((ref) {
  return EnhancedNotificationService();
});

/// BasicSyncService for manual sync operations (legacy - will be replaced)
final basicSyncServiceProvider = Provider<BasicSyncService>((ref) {
  return BasicSyncService.instance;
});

/// NebulalistSyncQueueService for offline sync queue management
final syncQueueServiceProvider = Provider<NebulalistSyncQueueService>((ref) {
  final db = ref.watch(nebulalistDatabaseProvider);
  return NebulalistSyncQueueService(db.syncQueueDao);
});

// =============================================================================
// SYNC ADAPTERS
// =============================================================================

/// ListDriftSyncAdapter for Lists sync (push + pull)
final listSyncAdapterProvider = Provider<ListDriftSyncAdapter>((ref) {
  return ListDriftSyncAdapter(
    localDataSource: ref.watch(listLocalDataSourceProvider),
    remoteDataSource: ref.watch(listRemoteDataSourceProvider),
  );
});

/// ItemMasterDriftSyncAdapter for ItemMasters sync (push + pull)
final itemMasterSyncAdapterProvider =
    Provider<ItemMasterDriftSyncAdapter>((ref) {
  return ItemMasterDriftSyncAdapter(
    localDataSource: ref.watch(itemMasterLocalDataSourceProvider),
    remoteDataSource: ref.watch(itemMasterRemoteDataSourceProvider),
  );
});

/// ListItemDriftSyncAdapter for ListItems sync (push + pull)
final listItemSyncAdapterProvider = Provider<ListItemDriftSyncAdapter>((ref) {
  return ListItemDriftSyncAdapter(
    localDataSource: ref.watch(listItemLocalDataSourceProvider),
    remoteDataSource: ref.watch(listItemRemoteDataSourceProvider),
  );
});

/// NebulalistSyncService - implements ISyncService
/// Main sync orchestrator for Lists, ItemMasters, and ListItems
final nebulalistSyncServiceProvider = Provider<NebulalistSyncService>((ref) {
  return NebulalistSyncService(
    listRepository: ref.watch(listRepositoryProvider) as ListRepository,
    itemMasterRepository:
        ref.watch(itemMasterRepositoryProvider) as ItemMasterRepository,
    listItemRepository:
        ref.watch(listItemRepositoryProvider) as ListItemRepository,
    authRepository: ref.watch(authRepositoryProvider),
    listSyncAdapter: ref.watch(listSyncAdapterProvider),
    itemMasterSyncAdapter: ref.watch(itemMasterSyncAdapterProvider),
    listItemSyncAdapter: ref.watch(listItemSyncAdapterProvider),
  );
});

/// BackgroundSyncService for periodic auto-sync
/// Runs sync every 15 minutes when app is active
final backgroundSyncServiceProvider = Provider<BackgroundSyncService>((ref) {
  final syncService = ref.watch(nebulalistSyncServiceProvider);
  return BackgroundSyncService(
    syncService: syncService,
    intervalMinutes: 15, // Sync every 15 minutes
  );
});

// =============================================================================
// APP SERVICES PROVIDERS
// =============================================================================

/// Provider for app-specific AnalyticsService
final appAnalyticsServiceProvider = Provider<AnalyticsService>((ref) {
  return AnalyticsService(ref.watch(analyticsWrapperProvider));
});

/// Provider for ShareService
final shareServiceProvider = Provider<ShareService>((ref) {
  return ShareService();
});

/// Provider for app-specific NotificationService
final appNotificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService(ref.watch(notificationRepositoryProvider));
});

// =============================================================================
// LISTS FEATURE - DATA SOURCES (DRIFT)
// =============================================================================

/// Local data source for lists (using Drift)
final listLocalDataSourceProvider = Provider<IListLocalDataSource>((ref) {
  final db = ref.watch(nebulalistDatabaseProvider);
  return ListLocalDataSourceImpl(db);
});

/// Remote data source for lists
final listRemoteDataSourceProvider = Provider<IListRemoteDataSource>((ref) {
  return ListRemoteDataSourceImpl(ref.watch(firestoreProvider));
});

// =============================================================================
// LISTS FEATURE - REPOSITORY
// =============================================================================

/// List repository
final listRepositoryProvider = Provider<IListRepository>((ref) {
  return ListRepository(
    ref.watch(listLocalDataSourceProvider),
    ref.watch(listRemoteDataSourceProvider),
    ref.watch(authStateNotifierProvider),
    ref.watch(syncQueueServiceProvider),
    ref.watch(getSubscriptionStatusProvider),
  );
});

// =============================================================================
// LISTS FEATURE - USE CASES
// =============================================================================

/// Get lists use case
final getListsUseCaseProvider = Provider<GetListsUseCase>((ref) {
  return GetListsUseCase(ref.watch(listRepositoryProvider));
});

/// Create list use case
final createListUseCaseProvider = Provider<CreateListUseCase>((ref) {
  return CreateListUseCase(ref.watch(listRepositoryProvider));
});

/// Update list use case
final updateListUseCaseProvider = Provider<UpdateListUseCase>((ref) {
  return UpdateListUseCase(ref.watch(listRepositoryProvider));
});

/// Delete list use case
final deleteListUseCaseProvider = Provider<DeleteListUseCase>((ref) {
  return DeleteListUseCase(ref.watch(listRepositoryProvider));
});

/// Check list limit use case
final checkListLimitUseCaseProvider = Provider<CheckListLimitUseCase>((ref) {
  return CheckListLimitUseCase(ref.watch(listRepositoryProvider));
});

// =============================================================================
// ITEMS FEATURE - DATA SOURCES (DRIFT)
// =============================================================================

/// Local data source for item masters (using Drift)
final itemMasterLocalDataSourceProvider =
    Provider<ItemMasterLocalDataSource>((ref) {
  final db = ref.watch(nebulalistDatabaseProvider);
  return ItemMasterLocalDataSource(db);
});

/// Remote data source for item masters
final itemMasterRemoteDataSourceProvider =
    Provider<ItemMasterRemoteDataSource>((ref) {
  return ItemMasterRemoteDataSource(ref.watch(firestoreProvider));
});

/// Local data source for list items (using Drift)
final listItemLocalDataSourceProvider =
    Provider<ListItemLocalDataSource>((ref) {
  final db = ref.watch(nebulalistDatabaseProvider);
  return ListItemLocalDataSource(db);
});

/// Remote data source for list items
final listItemRemoteDataSourceProvider =
    Provider<ListItemRemoteDataSource>((ref) {
  return ListItemRemoteDataSource(ref.watch(firestoreProvider));
});

// =============================================================================
// ITEMS FEATURE - REPOSITORIES
// =============================================================================

/// Item master repository
final itemMasterRepositoryProvider = Provider<IItemMasterRepository>((ref) {
  return ItemMasterRepository(
    ref.watch(itemMasterLocalDataSourceProvider),
    ref.watch(itemMasterRemoteDataSourceProvider),
    ref.watch(authStateNotifierProvider),
    ref.watch(syncQueueServiceProvider),
  );
});

/// List item repository
final listItemRepositoryProvider = Provider<IListItemRepository>((ref) {
  return ListItemRepository(
    ref.watch(listItemLocalDataSourceProvider),
    ref.watch(listItemRemoteDataSourceProvider),
    ref.watch(listRepositoryProvider),
    ref.watch(authStateNotifierProvider),
    ref.watch(syncQueueServiceProvider),
  );
});

// =============================================================================
// ITEMS FEATURE - USE CASES (ITEM MASTERS)
// =============================================================================

/// Get item masters use case
final getItemMastersUseCaseProvider = Provider<GetItemMastersUseCase>((ref) {
  return GetItemMastersUseCase(ref.watch(itemMasterRepositoryProvider));
});

/// Create item master use case
final createItemMasterUseCaseProvider =
    Provider<CreateItemMasterUseCase>((ref) {
  return CreateItemMasterUseCase(ref.watch(itemMasterRepositoryProvider));
});

/// Update item master use case
final updateItemMasterUseCaseProvider =
    Provider<UpdateItemMasterUseCase>((ref) {
  return UpdateItemMasterUseCase(ref.watch(itemMasterRepositoryProvider));
});

/// Delete item master use case
final deleteItemMasterUseCaseProvider =
    Provider<DeleteItemMasterUseCase>((ref) {
  return DeleteItemMasterUseCase(ref.watch(itemMasterRepositoryProvider));
});

/// Check item limit use case
final checkItemLimitUseCaseProvider = Provider<CheckItemLimitUseCase>((ref) {
  return CheckItemLimitUseCase(ref.watch(itemMasterRepositoryProvider));
});

// =============================================================================
// ITEMS FEATURE - USE CASES (LIST ITEMS)
// =============================================================================

/// Get list items use case
final getListItemsUseCaseProvider = Provider<GetListItemsUseCase>((ref) {
  return GetListItemsUseCase(ref.watch(listItemRepositoryProvider));
});

/// Add item to list use case
final addItemToListUseCaseProvider = Provider<AddItemToListUseCase>((ref) {
  return AddItemToListUseCase(
    ref.watch(listItemRepositoryProvider),
    ref.watch(itemMasterRepositoryProvider),
  );
});

/// Update list item use case
final updateListItemUseCaseProvider = Provider<UpdateListItemUseCase>((ref) {
  return UpdateListItemUseCase(ref.watch(listItemRepositoryProvider));
});

/// Remove item from list use case
final removeItemFromListUseCaseProvider =
    Provider<RemoveItemFromListUseCase>((ref) {
  return RemoveItemFromListUseCase(ref.watch(listItemRepositoryProvider));
});

/// Toggle item completion use case
final toggleItemCompletionUseCaseProvider =
    Provider<ToggleItemCompletionUseCase>((ref) {
  return ToggleItemCompletionUseCase(ref.watch(listItemRepositoryProvider));
});

// =============================================================================
// SUBSCRIPTION FEATURE - PROVIDERS
// =============================================================================

/// Subscription Repository from core package (RevenueCat)
final subscriptionRepositoryProvider = Provider<ISubscriptionRepository>((ref) {
  return RevenueCatService();
});

