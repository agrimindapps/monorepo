# Core Package - Flutter Monorepo

[![Health Score](https://img.shields.io/badge/Health%20Score-8.5%2F10-brightgreen)]()
[![Flutter](https://img.shields.io/badge/Flutter-3.x-blue)]()
[![Architecture](https://img.shields.io/badge/Architecture-Clean%20Architecture-orange)]()
[![Documentation](https://img.shields.io/badge/Documentation-Complete-green)]()
[![Dependencies](https://img.shields.io/badge/Dependencies-50%2B-blue)]()

Shared core package containing common services, utilities, domain logic and infrastructure for all apps in the monorepo. Production-ready with 40+ specialized services, complete Firebase integration, ads monetization, and GDPR compliance.

## 📑 Table of Contents

- [What's Inside](#-whats-inside)
- [Features](#-features)
  - [Firebase Integration](#-firebase-integration)
  - [Storage & Persistence](#-storage--persistence)
  - [Data Migration System](#-data-migration-system)
  - [Google Mobile Ads](#-monetization)
  - [Security & Privacy (GDPR)](#-security--privacy)
  - [HTTP Client & Network](#-http-client--network)
- [Architecture](#️-architecture)
- [Getting Started](#-getting-started)
- [State Management (Riverpod)](#-state-management)
- [Dependencies](#-dependencies)
- [Documentation](#-documentation)
- [Quality & Standards](#-quality--standards)

## 📦 What's Inside

This package centralizes reusable functionality across 7 Flutter apps:
- **app-gasometer** - Vehicle control
- **app-plantis** - Plant care
- **app-taskolist** - Task management
- **app-receituagro** - Agricultural diagnostics
- **app-petiveti** - Pet care
- **app-agrihurbi** - Agricultural management
- **receituagro_web** - Web platform

---

## ✨ Features

### 🔥 Firebase Integration
- **Authentication** - Firebase Auth with social login (Google, Apple, Facebook)
  - Enhanced Firebase Auth Service
  - Monorepo Auth Cache (shared session across apps)
  - Social providers: Google, Apple, Facebook
  - Email/Password authentication
  - Anonymous authentication
- **Cloud Firestore** - Offline-first sync with conflict resolution
- **Cloud Storage** - File upload/download with caching
- **Analytics** - Event tracking and user properties
- **Crashlytics** - Error tracking and reporting
- **Cloud Functions** - Serverless backend integration
- **Remote Config** - Dynamic configuration
- **Firebase Messaging** - Push notifications (FCM)

### 💾 Storage & Persistence
- **Enhanced Storage Service** - Multi-strategy storage (Hive, SharedPreferences, SecureStorage, File System)
- **Hive** - Local database with box registry
- **Secure Storage** - Encrypted storage for sensitive data
- **File Management** - Complete file system operations with compression

### 🔄 Offline-First Sync
- **Unified Sync Manager** - Multi-app sync orchestration
- **Conflict Resolution** - Automatic and manual conflict handling
- **Queue Management** - Retry logic and throttling
- **Offline Capabilities** - Configurable per-app offline features
- **Sync Limits** - Free vs Premium tier management

### 🔄 Data Migration System
- **Data Migration Service** - Migrate anonymous data to authenticated accounts
- **Anonymous Data Cleaner** - GDPR-compliant cleanup of anonymous data
- **Conflict Resolution** - Automatic and manual conflict handling during migration
- **Hive to Firebase** - Seamless local-to-cloud data transfer
- **Progress Tracking** - Real-time migration progress monitoring

### 🎨 UI & Navigation
- **Enhanced Navigation Service** - Centralized navigation management with deep linking
- **Go Router Integration** - Declarative routing and navigation
- **Navigation Analytics** - Automatic screen tracking and user journey analytics
- **Navigation Configuration** - Dynamic route configuration per app
- **Theme System** - Base colors and typography
- **Widgets** - Reusable UI components (AdBannerWidget, Account Deletion, etc)
- **Shimmer Service** - Loading placeholders and skeletons

### 💰 Monetization
- **RevenueCat Integration** - Subscription management and premium features
- **Premium Features** - Feature gating based on subscription status
- **Cancellation Flow** - Subscription cancellation handling
- **Google Mobile Ads** - Complete ads integration (9 specialized services)
  - Banner, Interstitial, Rewarded, Rewarded Interstitial, App Open Ads
  - Automatic frequency capping (daily, session, hourly limits)
  - Premium user detection (no ads for subscribers)
  - Ad preloading for better UX
  - Analytics integration
  - See [Ads Documentation](lib/src/infrastructure/services/ads/README.md) for details

### 📊 Analytics & Monitoring
- **Enhanced Analytics** - Unified analytics across apps
- **Performance Monitoring** - App performance tracking
- **Logging Service** - Centralized logging with levels

### 🔔 Notifications
- **Local Notifications** - Scheduled and immediate notifications
- **Enhanced Notification Service** - Advanced notification features
- **Template Engine** - Notification templates

### 🖼️ Media & Images
- **Image Service** - Image picking, compression, and caching
- **Profile Image Service** - Avatar management with Firebase Storage
- **Optimized Image Service** - Performance-optimized image loading
- **Cached Network Image** - Network image caching and optimization
- **Image Compression** - Automatic image compression before upload

### 🌐 HTTP Client & Network
- **HTTP Client Service** - Dio-based HTTP client with interceptors
- **Request/Response Interceptors** - Logging, authentication, error handling
- **Timeout Management** - Configurable timeouts per request
- **Retry Logic** - Automatic retry for failed requests
- **Connectivity Service** - Network status monitoring (connectivity_plus)
- **Offline Detection** - Automatic offline mode detection

### 🔧 Platform Services
- **Platform Capabilities Service** - Platform-specific feature detection
- **Device Info Service** - Device information and capabilities
- **Version Manager Service** - App version management and updates
- **Package Info** - App metadata and build information
- **Permission Handler** - Runtime permission management

### 🔐 Security & Privacy
- **Enhanced Security Service** - Security utilities and best practices
- **Encryption** - Data encryption/decryption (AES, RSA)
- **Secure Storage** - Encrypted local storage for sensitive data
- **Local Authentication** - Biometric authentication support
- **Account Deletion System** - GDPR-compliant account deletion
  - Multi-layer deletion (Auth, Firestore, Storage, Hive, SecureStorage)
  - Rate limiting to prevent abuse
  - Confirmation flow with UI widgets
  - Firebase Functions integration for server-side cleanup
  - Automatic session termination
- **Monorepo Auth Cache** - Shared authentication cache across apps (prevents re-login)

---

## 🏗️ Architecture

### Clean Architecture Layers

```
lib/
├── domain/                    # Business logic & entities
│   ├── entities/             # Domain models
│   ├── repositories/         # Repository interfaces
│   └── usecases/            # Business use cases
├── infrastructure/           # External implementations
│   ├── services/            # Service implementations
│   └── models/              # Data models
├── presentation/            # UI layer
│   ├── widgets/            # Reusable widgets
│   └── theme/              # Theming
├── riverpod/               # State management
│   └── domain/             # Domain providers
├── shared/                 # Cross-cutting concerns
│   ├── di/                # Dependency injection
│   ├── services/          # Shared services
│   └── utils/             # Utilities
└── sync/                  # Sync system
    ├── config/           # Sync configuration
    ├── interfaces/       # Sync interfaces
    └── services/         # Sync services
```

### Design Patterns

- **Repository Pattern** - Data access abstraction
- **Facade Pattern** - Simplified interfaces for complex subsystems
- **Singleton Pattern** - Single instance services
- **Registry Pattern** - Dynamic configuration registration
- **Factory Pattern** - Object creation
- **Observer Pattern** - Reactive state management (Riverpod)

---

## 🚀 Getting Started

### Installation

Add to your `pubspec.yaml`:

```yaml
dependencies:
  core:
    path: ../../packages/core
```

### Initialization

```dart
import 'package:core/core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp();

  // Initialize core services
  await InjectionContainer.init();

  // Register app-specific sync configuration
  SyncConfigRegistry.registerSyncLimits(
    SyncLimitsConfig(
      appId: 'your-app',
      maxOfflineItems: 100,
      maxSyncFrequencyMinutes: 15,
      allowBackgroundSync: true,
      allowLargeFileSync: false,
    ),
  );

  runApp(MyApp());
}
```

### Basic Usage

#### Authentication

```dart
final authRepo = getIt<IAuthRepository>();

// Login with email
final result = await authRepo.signInWithEmailAndPassword(
  email: 'user@example.com',
  password: 'password',
);

result.fold(
  (failure) => print('Error: ${failure.message}'),
  (authResult) => print('User: ${authResult.user.uid}'),
);
```

#### Storage

```dart
final storage = EnhancedStorageService();

await storage.initialize();

// Save data
await storage.write('key', 'value');

// Read data
final result = await storage.read<String>('key');
```

#### Sync

```dart
final syncService = SyncFirebaseService<MyEntity>.getInstance(
  'my_collection',
  MyEntity.fromMap,
  (entity) => entity.toMap(),
);

// Sync all
await syncService.syncAll();

// Create with offline support
await syncService.create(myEntity);
```

#### Analytics

```dart
final analytics = getIt<IAnalyticsRepository>();

// Log event
await analytics.logEvent('button_clicked', parameters: {
  'button_name': 'save',
  'screen': 'profile',
});

// Log purchase
await analytics.logPurchase(
  currency: 'USD',
  value: 9.99,
  productId: 'premium_monthly',
);
```

#### Google Mobile Ads

```dart
import 'package:core/core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Initialize ads
final adsRepository = ref.read(adsRepositoryProvider);
await adsRepository.initialize(appId: 'YOUR_AD_MOB_APP_ID');

// Show banner
AdBannerWidget(
  adUnitId: 'YOUR_BANNER_AD_UNIT_ID',
  size: AdSize.banner,
)

// Show interstitial
await adsRepository.loadInterstitialAd(adUnitId: 'YOUR_INTERSTITIAL_ID');
await adsRepository.showInterstitialAd();

// Show rewarded ad
await adsRepository.loadRewardedAd(adUnitId: 'YOUR_REWARDED_ID');
await adsRepository.showRewardedAd();
```

See [Google Mobile Ads README](lib/src/infrastructure/services/ads/README.md) for complete documentation.

#### Data Migration

```dart
import 'package:core/core.dart';

// Migrate anonymous data to authenticated account
final migrationService = getIt<DataMigrationService>();

// Check if migration is needed
final hasAnonymousData = await migrationService.hasAnonymousData();

if (hasAnonymousData) {
  // Perform migration
  final result = await migrationService.migrateToAccount(
    userId: user.uid,
    onProgress: (progress) {
      print('Migration progress: ${progress * 100}%');
    },
  );

  result.fold(
    (failure) => print('Migration failed: ${failure.message}'),
    (success) => print('Migration completed successfully!'),
  );
}

// Clean anonymous data after migration
await migrationService.cleanAnonymousData();
```

#### Account Deletion (GDPR)

```dart
import 'package:core/core.dart';

// Delete user account (GDPR compliant)
final accountDeletionService = getIt<EnhancedAccountDeletionService>();

final result = await accountDeletionService.deleteAccount(
  userId: user.uid,
  onProgress: (stage, progress) {
    print('Deleting $stage: ${progress * 100}%');
  },
);

result.fold(
  (failure) {
    if (failure.code == 'RATE_LIMIT_EXCEEDED') {
      print('Please wait before trying again');
    } else {
      print('Deletion failed: ${failure.message}');
    }
  },
  (_) => print('Account deleted successfully'),
);
```

#### HTTP Client

```dart
import 'package:core/core.dart';

final httpClient = getIt<HttpClientService>();

// GET request
final response = await httpClient.get(
  'https://api.example.com/data',
  queryParameters: {'page': 1},
);

response.fold(
  (failure) => print('Request failed: ${failure.message}'),
  (data) => print('Data: $data'),
);

// POST request with retry
final postResult = await httpClient.post(
  'https://api.example.com/submit',
  data: {'name': 'John', 'email': 'john@example.com'},
  options: RequestOptions(
    timeout: Duration(seconds: 30),
    retryCount: 3,
  ),
);
```

#### Monorepo Auth Cache

```dart
import 'package:core/core.dart';

// Auth cache is automatically used across all apps
// User logs in once in app-plantis, stays logged in app-gasometer

final authCache = MonorepoAuthCache();

// Check if user is cached
final hasCachedUser = await authCache.hasCachedUser();

// Get cached user
final cachedUser = await authCache.getCachedUser();

// Clear cache (on logout)
await authCache.clearCache();
```

---

## 📚 Documentation

### Main Documentation
- **[REFACTORING_PLAN.md](REFACTORING_PLAN.md)** - Long-term refactoring roadmap
- **[QUALITY_IMPROVEMENTS.md](QUALITY_IMPROVEMENTS.md)** - Recent quality improvements
- **[CLAUDE.md](../../CLAUDE.md)** - Monorepo architecture and patterns

### Specialized Documentation
- **[Google Mobile Ads](lib/src/infrastructure/services/ads/README.md)** - Complete ads integration guide (545 lines)
  - 9 specialized services (SRP)
  - All ad types (Banner, Interstitial, Rewarded, App Open)
  - Frequency capping configuration
  - Premium integration
  - Testing and best practices

---

## 🎯 Quality & Standards

### Current Metrics (as of 2025-10-10)

- **Health Score**: 8.5/10 ⬆️ (was 8.0/10)
- **Compilation Errors**: 0 ✅
- **Critical Warnings**: 0 ✅
- **Test Coverage**: TBD
- **Code Duplication**: Low
- **Maintainability**: High
- **Documentation Coverage**: Complete ✅

### Recent Improvements

**2025-10-10:**
✅ Added complete Google Mobile Ads integration (9 specialized services)
✅ Comprehensive README documentation update
✅ Documented all 50+ dependencies with versions
✅ Added Data Migration System documentation
✅ Added Account Deletion (GDPR) documentation
✅ Documented Monorepo Auth Cache
✅ Added HTTP Client and Platform Services docs

**2025-10-08:**
✅ Removed 10 dead code files (~600 lines)
✅ Eliminated mock services from production
✅ Fixed premium integration (RevenueCat)
✅ Refactored hardcoded configs to registry pattern
✅ Added strategic TODOs for large files
✅ Created comprehensive refactoring plan

See [QUALITY_IMPROVEMENTS.md](QUALITY_IMPROVEMENTS.md) for details.

### Code Standards

- ✅ Clean Architecture strictly followed
- ✅ SOLID principles applied
- ✅ Either<Failure, T> for error handling
- ✅ Riverpod for state management
- ✅ GetIt + Injectable for DI
- ✅ 0 analyzer errors policy

---

## 🔧 State Management

### Riverpod Providers

The package uses Riverpod with code generation (`@riverpod` annotation) for state management:

**Provider Structure:**
```
lib/src/riverpod/domain/
├── ads/              # Ads providers
│   ├── adsRepositoryProvider
│   ├── shouldShowAdsProvider
│   ├── isAdReadyProvider
│   └── adFrequencyProvider
├── analytics/        # Analytics providers
│   ├── analyticsRepositoryProvider
│   └── analyticsServiceProvider
├── auth/            # Authentication providers
│   ├── authRepositoryProvider
│   ├── currentUserProvider
│   └── authStateProvider
├── device/          # Device providers
│   ├── deviceRepositoryProvider
│   └── deviceInfoProvider
├── premium/         # Premium/subscription providers
│   ├── isPremiumProvider
│   ├── subscriptionProvider
│   └── subscriptionStatusProvider
└── sync/            # Sync providers
    ├── syncLimitsProvider
    └── offlineCapabilitiesProvider
```

**Example Providers:**

```dart
// Authentication
@riverpod
Stream<User?> authState(AuthStateRef ref) {
  final authRepo = ref.watch(authRepositoryProvider);
  return authRepo.authStateChanges();
}

// Connectivity
@riverpod
Stream<ConnectivityResult> connectivityStatus(ConnectivityStatusRef ref) {
  return Connectivity().onConnectivityChanged;
}

// Premium Status
@riverpod
Future<bool> isPremium(IsPremiumRef ref) async {
  final revenueCat = ref.watch(revenueCatServiceProvider);
  return await revenueCat.isPremium();
}

// Ads
@riverpod
Future<bool> shouldShowAds(ShouldShowAdsRef ref, String placement) async {
  final adsRepo = ref.watch(adsRepositoryProvider);
  final result = await adsRepo.shouldShowAd(placement: placement);
  return result.fold((_) => false, (canShow) => canShow);
}
```

**Code Generation:**

```bash
# Generate providers
dart run build_runner watch --delete-conflicting-outputs
```

---

## 📦 Dependencies

### Core Dependencies

**Firebase Stack:**
- **firebase_core** (^4.0.0) - Firebase initialization
- **firebase_auth** (^6.0.1) - Authentication
- **cloud_firestore** (^6.0.0) - NoSQL database
- **firebase_storage** (^13.0.0) - File storage
- **firebase_analytics** (^12.0.0) - Analytics
- **firebase_crashlytics** (^5.0.0) - Crash reporting
- **firebase_performance** (^0.11.0) - Performance monitoring
- **firebase_remote_config** (^6.0.0) - Dynamic config
- **firebase_messaging** (^16.0.0) - Push notifications
- **cloud_functions** (^6.0.0) - Serverless backend

**State Management & DI:**
- **flutter_riverpod** (^2.6.1) - State management
- **riverpod_annotation** (^2.6.1) - Riverpod code generation
- **get_it** (^8.2.0) - Service locator
- **injectable** (^2.4.4) - DI code generation
- **dartz** (^0.10.1) - Functional programming (Either)

**Storage & Persistence:**
- **hive** (^2.2.3) - Fast local database
- **hive_flutter** (^1.1.0) - Hive Flutter extensions
- **shared_preferences** (^2.4.0) - Key-value storage
- **flutter_secure_storage** (^9.2.4) - Encrypted storage
- **path_provider** (^2.1.5) - File system paths

**Monetization:**
- **purchases_flutter** (^9.2.0) - RevenueCat subscriptions
- **google_mobile_ads** (^5.2.0) - Google Mobile Ads

**Network & HTTP:**
- **dio** (^5.9.0) - HTTP client
- **connectivity_plus** (^6.1.5) - Network connectivity
- **cached_network_image** (^3.4.1) - Image caching

**UI & Navigation:**
- **go_router** (^16.1.0) - Declarative routing
- **shimmer** (^3.0.0) - Loading skeletons
- **flutter_staggered_grid_view** (^0.7.0) - Grid layouts

**Authentication:**
- **google_sign_in** (^6.2.1) - Google Sign-In
- **sign_in_with_apple** (^6.1.2) - Apple Sign-In
- **flutter_facebook_auth** (^6.0.4) - Facebook Login

**Media & Files:**
- **image_picker** (^1.1.2) - Image/video picker
- **image** (^4.1.7) - Image processing
- **archive** (^4.0.7) - File compression
- **mime** (^2.0.0) - MIME type detection

**Notifications & Permissions:**
- **flutter_local_notifications** (^19.4.0) - Local notifications
- **permission_handler** (^12.0.1) - Runtime permissions
- **timezone** (^0.10.1) - Timezone support

**Security:**
- **local_auth** (^2.3.0) - Biometric authentication
- **crypto** (^3.0.6) - Cryptographic functions
- **encrypt** (^5.0.1) - Encryption utilities

**Platform Info:**
- **device_info_plus** (^11.5.0) - Device information
- **package_info_plus** (^8.1.3) - App metadata

**Other:**
- **rate_my_app** (2.2.0) - App rating prompts
- **url_launcher** (^6.3.2) - URL launching
- **share_plus** (^12.0.0) - Social sharing
- **font_awesome_flutter** (^10.7.0) - Icon library
- **intl** (>=0.19.0 <0.21.0) - Internationalization
- **uuid** (^4.5.1) - UUID generation
- **equatable** (^2.0.7) - Value equality

### Dev Dependencies

- **build_runner** (^2.4.13) - Code generation
- **injectable_generator** (^2.6.2) - DI code gen
- **hive_generator** (^2.0.1) - Hive adapters
- **riverpod_generator** (2.4.0) - Riverpod code gen
- **riverpod_lint** (^2.6.1) - Riverpod linting
- **custom_lint** (^0.6.0) - Custom linting
- **mockito** (^5.4.4) - Mocking for tests
- **bloc_test** (^10.0.0) - BLoC testing utilities

### Full List

See [pubspec.yaml](pubspec.yaml)

---

## 🧪 Testing

### Running Tests

```bash
# Run all tests
flutter test

# Run with coverage
flutter test --coverage

# Run specific test
flutter test test/domain/usecases/login_usecase_test.dart
```

### Test Structure

```
test/
├── domain/
│   └── usecases/          # Use case tests (≥80% coverage)
├── infrastructure/
│   └── services/          # Service tests
└── helpers/
    └── test_helpers.dart  # Test utilities
```

---

## 🔄 Sync System

### Configuration Registry

Apps register their sync configuration at startup:

```dart
// Register sync limits
SyncConfigRegistry.registerSyncLimits(
  SyncLimitsConfig(
    appId: 'my-app',
    maxOfflineItems: 100,
    maxSyncFrequencyMinutes: 15,
    allowBackgroundSync: true,
    allowLargeFileSync: false,
  ),
);

// Register offline capabilities
SyncConfigRegistry.registerOfflineCapabilities(
  OfflineCapabilitiesConfig(
    appId: 'my-app',
    hasOfflineSupport: true,
    canCreateOffline: true,
    canEditOffline: true,
    canDeleteOffline: true,
    offlineFeatures: {'feature1', 'feature2'},
  ),
);
```

### Sync Modes

- **Online-First** - Attempts online operations first, falls back to offline
- **Offline-First** - Saves locally first, syncs when online
- **Hybrid** - Mix of both based on feature requirements

---

## 🎨 Theming

### Base Theme

```dart
import 'package:core/core.dart';

final theme = ThemeData(
  colorScheme: ColorScheme.fromSeed(
    seedColor: BaseColors.primary,
    brightness: Brightness.light,
  ),
  textTheme: BaseTypography.textTheme,
);
```

### Custom Colors

- `BaseColors.primary`
- `BaseColors.secondary`
- `BaseColors.error`
- `BaseColors.success`
- `BaseColors.warning`

---

## 🛣️ Roadmap

### Completed ✅
- Core services implementation
- Firebase integration
- Offline-first sync
- RevenueCat integration
- Architecture cleanup (2025-10-08)

### In Progress 🚧
- Test coverage improvements
- Performance optimizations

### Planned 📋
- Refactor large files (see REFACTORING_PLAN.md)
- Migrate to Riverpod code generation
- Enhanced documentation
- Example apps

---

## 🤝 Contributing

### Code Style

Follow the established patterns:

1. **Clean Architecture** - Respect layer boundaries
2. **SOLID Principles** - Single responsibility per class
3. **Either for errors** - Use `Either<Failure, T>`
4. **Async operations** - Always return `Future` or `Stream`
5. **Documentation** - Add dartdoc comments to public APIs

### File Size Limits

- Services: **<500 lines** (target)
- Methods: **<50 lines** (target)
- Classes: **Single responsibility**

Files >500 lines should be flagged for refactoring.

### Before Submitting PR

```bash
# Format code
dart format .

# Analyze
flutter analyze

# Run tests
flutter test

# Check for TODOs
grep -r "TODO" lib/
```

---

## 📄 License

Internal package for monorepo use only.

---

## 📞 Support

For questions or issues:
- Check [CLAUDE.md](../../CLAUDE.md) for architecture guidance
- Review [REFACTORING_PLAN.md](REFACTORING_PLAN.md) for improvement plans
- Consult [QUALITY_IMPROVEMENTS.md](QUALITY_IMPROVEMENTS.md) for recent changes

---

**Last Updated**: 2025-10-10
**Version**: 1.0.0
**Maintained by**: Core Team

---

## 📈 Package Overview

- **Total Dependencies**: 50+ packages
- **Lines of Code**: ~15,000+ (estimated)
- **Services**: 40+ specialized services
- **Repositories**: 12+ repository interfaces
- **Riverpod Providers**: 30+ providers across 6 domains
- **Widgets**: 10+ reusable widgets
- **Supported Apps**: 7 Flutter applications
