# Core Package - Flutter Monorepo

[![Health Score](https://img.shields.io/badge/Health%20Score-8.0%2F10-green)]()
[![Flutter](https://img.shields.io/badge/Flutter-3.x-blue)]()
[![Architecture](https://img.shields.io/badge/Architecture-Clean%20Architecture-orange)]()

Shared core package containing common services, utilities, domain logic and infrastructure for all apps in the monorepo.

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
- **Cloud Firestore** - Offline-first sync with conflict resolution
- **Cloud Storage** - File upload/download with caching
- **Analytics** - Event tracking and user properties
- **Crashlytics** - Error tracking and reporting
- **Cloud Functions** - Serverless backend integration

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

### 🎨 UI & Navigation
- **Navigation Service** - Centralized navigation with deep linking
- **Theme System** - Base colors and typography
- **Widgets** - Reusable UI components
- **Shimmer Service** - Loading placeholders

### 💰 Monetization
- **RevenueCat Integration** - Subscription management
- **Premium Features** - Feature gating based on subscription
- **Cancellation Flow** - Subscription cancellation handling

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
- **Profile Image Service** - Avatar management
- **Optimized Image Service** - Performance-optimized image loading

### 🔐 Security
- **Enhanced Security Service** - Security utilities
- **Encryption** - Data encryption/decryption
- **Account Deletion** - GDPR-compliant account deletion

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

---

## 📚 Documentation

- **[REFACTORING_PLAN.md](REFACTORING_PLAN.md)** - Long-term refactoring roadmap
- **[QUALITY_IMPROVEMENTS.md](QUALITY_IMPROVEMENTS.md)** - Recent quality improvements
- **[CLAUDE.md](../../CLAUDE.md)** - Monorepo architecture and patterns

---

## 🎯 Quality & Standards

### Current Metrics (as of 2025-10-08)

- **Health Score**: 8.0/10 ⬆️ (was 6.5/10)
- **Compilation Errors**: 0 ✅
- **Critical Warnings**: 0 ✅
- **Test Coverage**: TBD
- **Code Duplication**: Low
- **Maintainability**: High

### Recent Improvements

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

The package uses Riverpod with code generation for state management:

```dart
// Common providers
final connectivityStatusProvider = Provider<ConnectivityResult>(...);
final isConnectedProvider = Provider<bool>(...);
final currentUserProvider = FutureProvider<User?>(...);

// Premium providers
final isPremiumProvider = Provider<bool>(...);
final subscriptionProvider = StateNotifierProvider<SubscriptionNotifier, SubscriptionState>(...);

// Sync providers
final syncLimitsProvider = Provider.family<SyncLimits, String>(...);
final offlineCapabilitiesProvider = Provider.family<OfflineCapabilities, String>(...);
```

---

## 📦 Dependencies

### Main Dependencies

- **firebase_core** - Firebase initialization
- **firebase_auth** - Authentication
- **cloud_firestore** - Database
- **firebase_storage** - File storage
- **firebase_analytics** - Analytics
- **firebase_crashlytics** - Crash reporting
- **flutter_riverpod** - State management
- **get_it** - Dependency injection
- **injectable** - DI code generation
- **hive** - Local database
- **dartz** - Functional programming (Either)
- **purchases_flutter** - RevenueCat integration

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

**Last Updated**: 2025-10-08
**Version**: 1.0.0
**Maintained by**: Core Team
