# 🚗 Gasometer - Vehicle Management & Expense Tracking

**A comprehensive vehicle management and expense tracking application built with Flutter, featuring offline-first architecture, real-time sync, and advanced analytics.**

[![Flutter](https://img.shields.io/badge/Flutter-3.35.0+-02569B?logo=flutter)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.9.0+-0175C2?logo=dart)](https://dart.dev)
[![Riverpod](https://img.shields.io/badge/Riverpod-2.6.1-00B4AB)](https://riverpod.dev)
[![License](https://img.shields.io/badge/License-Proprietary-red)]()
[![Quality](https://img.shields.io/badge/Quality-Production_Ready-brightgreen)]()
[![Analyzer](https://img.shields.io/badge/Analyzer_Errors-0-success)]()

---

## 📱 Overview

Gasometer is a production-ready vehicle management platform that helps users track fuel consumption, maintenance schedules, expenses, and vehicle analytics. Built with Clean Architecture and Pure Riverpod, it features sophisticated offline-first capabilities with multi-device synchronization.

### Key Highlights

- 🎯 **26 Feature Modules** with 850+ Dart files
- 🏗️ **Pure Riverpod Architecture** (~99% migrated, 184 providers)
- 💾 **Offline-First with Drift** (SQLite type-safe ORM)
- ☁️ **Firebase Integration** (Auth, Firestore, Analytics, Crashlytics)
- 🔄 **Multi-Device Sync** with conflict resolution
- 📊 **Advanced Analytics** with custom event tracking
- 💳 **Premium Subscriptions** via RevenueCat
- 🌍 **Internationalization** (PT-BR, EN-US)
- 🌓 **Light/Dark Themes**
- ⚡ **0 Analyzer Errors** - Production-ready code quality
- 🧪 **Comprehensive Testing** - Unit and integration tests

---

## ✨ Features

### Core Vehicle Management

#### 🚙 Vehicle Registry
- Complete vehicle profiles (brand, model, year, license plate)
- Fuel type tracking (gasoline, ethanol, diesel, CNG)
- Current odometer management
- Vehicle image storage
- Multi-vehicle support (2 free, unlimited premium)

#### ⛽ Fuel Supply Tracking
- Fuel refill logging with precise data
- Price per liter tracking
- Full tank indicator
- Odometer readings at refill
- Fuel efficiency calculations
- Historical fuel price trends

#### 🔧 Maintenance Management
- Scheduled and completed maintenance tracking
- Maintenance types: preventive, corrective, inspection, emergency
- Next service due date predictions
- Maintenance cost tracking
- Service history with detailed notes
- Odometer at service time

#### 💰 Expense Tracking
- Comprehensive expense categories (IPVA, insurance, fines, parking, etc.)
- Receipt image storage
- Date and amount tracking
- Category-based filtering
- Financial summaries and reports

#### 📏 Odometer Readings
- Periodic odometer snapshots
- Distance calculation between readings
- Historical odometer timeline
- Mileage trend analysis

### Advanced Features

#### 📊 Reports & Analytics
- Monthly and yearly reports
- Fuel efficiency analysis (km/L)
- Cost analysis (total, by category, by vehicle)
- Consumption patterns
- Financial forecasting
- Custom date range reports

#### 🔄 Data Synchronization
- **Offline-First Architecture** - Works without internet
- **Real-time Multi-Device Sync** - Changes sync across devices
- **Background Sync Service** - Automatic sync every 3+ minutes
- **Conflict Resolution** - Version-based conflict handling
- **Connectivity Monitoring** - Intelligent sync based on network

#### 📸 Image Management
- Vehicle photos with primary image selection
- Receipt image storage for fuel/maintenance
- Base64 and Firebase Storage integration
- Image compression and optimization
- Gallery view with sorting

#### 🔐 Authentication & Security
- Firebase Authentication (email/password, Google Sign-In)
- Anonymous authentication fallback
- Multi-user support with user ID tracking
- Secure data isolation per user
- Session tracking and analytics

#### 💳 Premium Features (RevenueCat)
- **Unlimited Vehicles** (Free: 2 max)
- **Unlimited Fuel Records** (Free: 50 max)
- **Unlimited Maintenance** (Free: 20 max)
- **Advanced Reports** with detailed charts
- **Data Export** (100MB limit)
- **Custom Categories**
- **Premium Themes**
- **Cloud Backup** (500MB storage)
- **Location History**
- **Advanced Analytics**
- **Cost Predictions**
- **Maintenance Alerts**
- **Fuel Price Alerts**
- **Premium Support**
- **Offline Mode**

#### 📱 Device Management
- Multi-device tracking
- Session management
- Device linking and revocation
- Activity timeline per device

#### 📝 Audit Trails
- Complete financial audit logs
- Before/after state tracking
- Event type classification
- Monetary value tracking
- Compliance-ready reporting

#### 🧮 Calculator Tools
- Fuel efficiency calculator
- Cost projection tools
- Maintenance scheduling calculator

### Secondary Features

- **Timeline View** - Activity timeline with all vehicle events
- **Data Export** - Export vehicle data in multiple formats
- **Settings & Profile** - User preferences, theme, language
- **Promo System** - Promotional features and pricing
- **Legal** - Terms of Service, Privacy Policy

---

## 🏗️ Architecture

### State Management: Pure Riverpod 3.0

```dart
// Example: Provider with code generation
@riverpod
class VehiclesNotifier extends _$VehiclesNotifier {
  @override
  Future<List<Vehicle>> build() async {
    final repository = ref.watch(vehicleRepositoryProvider);
    return repository.watchAllVehicles();
  }

  Future<void> addVehicle(Vehicle vehicle) async {
    final repository = ref.read(vehicleRepositoryProvider);
    await repository.insertVehicle(vehicle);
    ref.invalidateSelf();
  }
}
```

**Benefits:**
- Auto-dispose lifecycle management
- Type-safe provider dependencies
- AsyncValue for loading/error states
- 182+ providers across 26 features
- ConsumerWidget/ConsumerStatefulWidget for UI

### Clean Architecture (3-Layer)

```
lib/features/[feature]/
├── domain/
│   ├── entities/        # Business logic models (immutable)
│   ├── repositories/    # Abstract repository interfaces
│   └── usecases/        # Business logic orchestration
├── data/
│   ├── models/          # DTO models with JSON serialization
│   ├── datasources/     # Remote (Firestore) / Local (Drift)
│   └── repositories/    # Repository implementations
└── presentation/
    ├── pages/           # Full-screen widgets
    ├── widgets/         # Reusable UI components
    └── providers/       # Riverpod providers & notifiers
```

**Principles:**
- **SOLID Principles** - Single responsibility, specialized services
- **Either<Failure, T>** - Functional error handling with dartz
- **Validation in Use Cases** - Centralized business logic
- **Dependency Inversion** - Abstract interfaces in domain layer

### Database: Drift (SQLite)

**9 Core Tables:**
1. **Vehicles** - Vehicle registry with odometer tracking
2. **FuelSupplies** - Fuel refill records
3. **Maintenances** - Maintenance history
4. **Expenses** - General vehicle expenses
5. **OdometerReadings** - Periodic odometer snapshots
6. **VehicleImages** - Vehicle photos
7. **ReceiptImages** - Receipt/proof images (polymorphic)
8. **AuditTrail** - Financial compliance logs
9. **UserSubscriptions** - Local subscription cache

**Schema Features:**
- Type-safe queries with compile-time validation
- Reactive streams (`watchAll`, `watchById`)
- Automatic migrations
- Foreign keys with CASCADE delete
- Soft delete pattern (`isDeleted` flag)
- Sync fields: `firebaseId`, `lastSyncAt`, `isDirty`, `version`

**Example Table Definition:**
```dart
class Vehicles extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get userId => text()();
  TextColumn get firebaseId => text().nullable()();
  TextColumn get marca => text()();
  TextColumn get modelo => text()();
  IntColumn get ano => integer()();
  TextColumn get placa => text()();
  RealColumn get odometroAtual => real()();
  TextColumn get combustivel => text()();

  // Metadata
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  // Sync control
  DateTimeColumn get lastSyncAt => dateTime().nullable()();
  BoolColumn get isDirty => boolean().withDefault(const Constant(false))();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
  IntColumn get version => integer().withDefault(const Constant(1))();
}
```

### Sync Architecture

**Unified Sync Manager:**
- Pull-based queries with timestamp filtering
- Push-based dirty flag tracking
- Version-based conflict resolution
- Connectivity-aware sync (pauses offline)
- Background sync every 3+ minutes
- Real-time cross-device synchronization

**Sync Flow:**
```
Local Change → Mark as Dirty → Background Sync →
Push to Firebase → Pull Remote Changes →
Conflict Resolution → Update Local DB → Clear Dirty Flag
```

### Dependency Injection

```dart
// GetIt + Injectable
@module
abstract class AppModule {
  @singleton
  FirebaseFirestore get firestore => FirebaseFirestore.instance;

  @singleton
  GasometerDatabase get database => GasometerDatabase();
}

// Riverpod Providers
@riverpod
VehicleRepository vehicleRepository(Ref ref) {
  final database = ref.watch(databaseProvider);
  return VehicleRepositoryImpl(database);
}
```

---

## 🛠️ Tech Stack

### Core Framework
- **Flutter**: 3.35.0+
- **Dart**: 3.9.0+

### State Management
- **flutter_riverpod**: 2.6.1 (Pure Riverpod)
- **riverpod_annotation**: 2.6.1 (Code generation)
- **riverpod_generator**: 2.6.1 (Dev dependency)

### Database & Persistence
- **drift**: 2.20.0+ (SQLite ORM)
- **drift_dev**: 2.20.0+ (Code generation)

### Firebase Integration
- **firebase_core**: Latest
- **cloud_firestore**: Latest (remote sync)
- **firebase_auth**: Latest (authentication)
- **firebase_analytics**: Latest (event tracking)
- **firebase_crashlytics**: Latest (crash reporting)
- **firebase_performance**: Latest (performance monitoring)
- **firebase_storage**: Latest (image uploads)

### Navigation & UI
- **go_router**: Latest (advanced routing)
- **material_design**: Material 3
- **intl**: Internationalization (PT-BR, EN-US)

### Utilities
- **equatable**: Value equality
- **dartz**: Functional programming (Either, Option)
- **get_it**: Service locator
- **injectable**: DI code generation

### Development
- **build_runner**: Code generation orchestrator
- **mocktail**: Mocking for tests
- **analyzer**: Static analysis

---

## 📊 Project Statistics

| Metric | Value |
|--------|-------|
| **Total Dart Files** | 854 |
| **Features** | 26 modules |
| **Database Tables** | 9 (Drift) |
| **Repositories** | 10 Drift-based |
| **Riverpod Providers** | 184 (@riverpod) |
| **Pages** | 39+ |
| **Analyzer Errors** | 0 ✅ |
| **Riverpod Migration** | ~99% ✅ |
| **Architecture Score** | 9.5/10 |
| **State Management** | Riverpod 2.6.1 |

---

## 🚀 Getting Started

### Prerequisites

- Flutter SDK 3.35.0+
- Dart SDK 3.9.0+
- Firebase project configured
- RevenueCat account (for premium features)

### Installation

1. **Clone the repository:**
   ```bash
   cd /path/to/monorepo/apps/app-gasometer
   ```

2. **Install dependencies:**
   ```bash
   flutter pub get
   ```

3. **Run code generation:**
   ```bash
   dart run build_runner build --delete-conflicting-outputs
   ```

   Or watch for changes:
   ```bash
   dart run build_runner watch --delete-conflicting-outputs
   ```

4. **Configure Firebase:**
   - Add `google-services.json` (Android) to `android/app/`
   - Add `GoogleService-Info.plist` (iOS) to `ios/Runner/`
   - Update `firebase_options.dart`

5. **Run the app:**
   ```bash
   flutter run
   ```

### Build for Production

**Android:**
```bash
flutter build apk --release
flutter build appbundle --release
```

**iOS:**
```bash
flutter build ios --release
```

**Web:**
```bash
flutter build web
```

---

## 🧪 Testing

### Run Tests
```bash
flutter test
```

### Code Coverage
```bash
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
```

### Static Analysis
```bash
flutter analyze
```

### Riverpod Linting
```bash
dart run custom_lint
```

---

## 📁 Project Structure

```
lib/
├── core/
│   ├── database/              # Drift database configuration
│   ├── providers/             # Riverpod providers
│   ├── services/              # Core services (analytics, connectivity, storage)
│   ├── theme/                 # Design tokens, colors, typography
│   ├── router/                # GoRouter configuration
│   ├── validation/            # Validation rules
│   ├── constants/             # App constants
│   └── widgets/               # Shared UI components
│
├── database/
│   ├── tables/                # Drift table definitions (9 tables)
│   ├── repositories/          # 10 CRUD repositories
│   ├── sync/adapters/         # Sync adapters
│   └── gasometer_database.dart
│
├── features/                  # 26 feature modules
│   ├── vehicles/              # Vehicle CRUD
│   ├── fuel/                  # Fuel supply tracking
│   ├── maintenance/           # Maintenance tracking
│   ├── expenses/              # Expense tracking
│   ├── reports/               # Analytics & reporting
│   ├── odometer/              # Odometer readings
│   ├── premium/               # Premium subscriptions
│   ├── auth/                  # Authentication
│   ├── profile/               # User profile
│   ├── settings/              # App settings
│   ├── sync/                  # Sync orchestration
│   ├── timeline/              # Activity timeline
│   └── [22 more features]
│
├── app.dart                   # App widget with router
└── main.dart                  # App initialization
```

---

## 🎨 Design System

### Colors
- **Primary**: Blue (#2196F3)
- **Secondary**: Orange (#FF9800)
- **Accent**: Green (#4CAF50)
- **Error**: Red (#F44336)

### Themes
- Light Mode (default)
- Dark Mode

### Typography
- Material Design type scale
- Roboto font family

---

## 🔐 Security & Privacy

- **Firebase Authentication** with email/password and Google Sign-In
- **User Data Isolation** - All data scoped to userId
- **Secure Image Storage** - Base64 local + Firebase Storage remote
- **Audit Trails** - Complete financial compliance logs
- **Soft Delete** - Deleted records flagged, not removed
- **Offline Security** - Local SQLite encryption (optional)

---

## 📄 License

Proprietary - All rights reserved by AgriMind Soluções

---

## 👥 Contributors

Developed by **AgriMind Soluções**

---

## 📞 Support

For support, please contact: support@agrimind.com.br

---

## 🗺️ Roadmap

- [ ] RevenueCat integration completion
- [ ] Advanced charts and visualizations
- [ ] Location-based fuel price tracking
- [ ] Maintenance prediction with ML
- [ ] Multi-language support expansion
- [ ] Web dashboard
- [ ] API for third-party integrations

---

**Built with ❤️ using Flutter and Riverpod**
