# Flutter App Scaffold - Gold Standard Template

<div align="center">

![Quality](https://img.shields.io/badge/Quality-10%2F10-brightgreen?style=for-the-badge)
![Architecture](https://img.shields.io/badge/Architecture-Clean-blue?style=for-the-badge)
![Flutter](https://img.shields.io/badge/Flutter-3.29+-02569B?style=for-the-badge&logo=flutter)
![Dart](https://img.shields.io/badge/Dart-3.7.2+-0175C2?style=for-the-badge&logo=dart)

**Production-ready Flutter scaffold based on app-plantis (Gold Standard 10/10)**

[Quick Start](#-quick-start) •
[Architecture](#-architecture) •
[Features](#-features) •
[Documentation](#-documentation)

</div>

---

## Overview

This scaffold provides a complete, production-ready foundation for Flutter applications following Clean Architecture principles, SOLID design patterns, and modern Riverpod state management.

**Based on:** app-plantis (Quality Score: 10/10)

### What's Included

- Clean Architecture structure (Presentation/Domain/Data)
- Riverpod state management with code generation
- Complete CRUD example feature with tests
- Dependency Injection (GetIt + Injectable)
- Error handling with Either<Failure, T>
- Offline-first pattern (Hive + Firebase)
- Automated setup scripts
- Comprehensive documentation

---

## Quick Start

### Prerequisites

- Flutter 3.29 or higher
- Dart 3.7.2 or higher
- Firebase project configured

### Create New App (Automated)

```bash
# From monorepo root
cd scaffold

# Run setup script
./scripts/setup_new_app.sh my_awesome_app com.company.myapp "My Awesome App"

# Navigate to your new app
cd ../apps/my_awesome_app

# Install dependencies
flutter pub get

# Generate code
dart run build_runner build --delete-conflicting-outputs

# Run the app
flutter run
```

### Manual Setup

If you prefer manual setup, see [docs/SETUP_NEW_APP.md](docs/SETUP_NEW_APP.md)

---

## Architecture

### Clean Architecture Layers

```
lib/
├── core/                          # Infrastructure & shared code
│   ├── auth/                     # Authentication
│   ├── config/                   # App configuration
│   ├── di/                       # Dependency Injection
│   ├── providers/                # Global Riverpod providers
│   ├── router/                   # Navigation (GoRouter)
│   ├── storage/                  # Local storage setup
│   ├── sync/                     # Sync engine
│   ├── theme/                    # App theming
│   └── validation/               # Validators
│
├── features/                      # Feature modules
│   └── [feature]/
│       ├── data/                 # Data layer
│       │   ├── datasources/      # Local & Remote data sources
│       │   ├── models/           # Data models (Hive, JSON)
│       │   └── repositories/     # Repository implementations
│       ├── domain/                # Domain layer (pure business logic)
│       │   ├── entities/         # Business entities
│       │   ├── repositories/     # Repository interfaces
│       │   ├── services/         # Specialized services (SOLID)
│       │   └── usecases/         # Use cases
│       └── presentation/          # Presentation layer
│           ├── notifiers/        # State notifiers (Riverpod)
│           ├── pages/            # UI pages
│           ├── providers/        # Feature providers
│           └── widgets/          # UI components
│
├── shared/                        # Shared widgets & utilities
│   └── widgets/
│       ├── feedback/             # Snackbars, dialogs
│       └── loading/              # Loading indicators
│
└── main.dart                     # App entry point
```

### SOLID Principles

This scaffold follows SOLID principles rigorously:

**Single Responsibility:**
- Each service has ONE responsibility
- Use cases are isolated and focused

**Open/Closed:**
- Repository interfaces allow easy extension
- Strategy pattern for different data sources

**Liskov Substitution:**
- Mock implementations for testing
- Interface-based design

**Interface Segregation:**
- Focused repository interfaces
- Specialized service interfaces

**Dependency Inversion:**
- Use cases depend on repository abstractions
- Injectable dependency injection

---

## Features

### Example Feature (Complete CRUD)

The scaffold includes a complete example feature demonstrating:

- Full CRUD operations (Create, Read, Update, Delete)
- Validation in use cases
- Offline-first pattern
- Error handling with Either<Failure, T>
- Specialized services (SOLID)
- Riverpod state management
- Complete test coverage (7 tests per use case)

### Core Features

- **Authentication**: Firebase Auth integration
- **State Management**: Riverpod with code generation (@riverpod)
- **Local Storage**: Hive boxes with type adapters
- **Remote Storage**: Firebase Firestore
- **Navigation**: GoRouter with type-safe routes
- **Analytics**: Firebase Analytics ready
- **Error Handling**: Type-safe with Either<Failure, T>
- **Dependency Injection**: GetIt + Injectable

---

## Scripts

### setup_new_app.sh

Creates a new app from scaffold with proper configuration:

```bash
./scripts/setup_new_app.sh <app_name> <bundle_id> <display_name>
```

### generate_feature.sh

Generates a new feature with complete structure:

```bash
./scripts/generate_feature.sh <feature_name>
```

### run_checks.sh

Runs quality checks (analyze, test, format):

```bash
./scripts/run_checks.sh
```

---

## Documentation

Comprehensive documentation is available in the `docs/` directory:

- [ARCHITECTURE.md](docs/ARCHITECTURE.md) - Detailed architecture guide
- [PATTERNS.md](docs/PATTERNS.md) - Code patterns and conventions
- [TESTING.md](docs/TESTING.md) - Testing strategies
- [SETUP_NEW_APP.md](docs/SETUP_NEW_APP.md) - Step-by-step setup
- [MIGRATION.md](docs/MIGRATION.md) - Migration from other patterns
- [TROUBLESHOOTING.md](docs/TROUBLESHOOTING.md) - Common issues

---

## Quality Standards

This scaffold maintains the same quality standards as app-plantis:

- 0 analyzer errors
- 0 critical warnings
- Clean Architecture rigorously followed
- SOLID principles in all services
- ≥80% test coverage for use cases
- Type-safe error handling (Either<Failure, T>)

---

## Tech Stack

### Core

- **Flutter 3.29+** - UI framework
- **Dart 3.7.2+** - Language
- **Riverpod 2.6+** - State management (code generation)
- **GetIt + Injectable** - Dependency injection
- **Dartz** - Functional programming (Either)

### Backend & Storage

- **Firebase** - Auth, Firestore, Storage, Analytics
- **Hive** - Local database

### Navigation & Utils

- **GoRouter** - Type-safe routing
- **Equatable** - Value equality
- **UUID** - Unique identifiers
- **Intl** - Internationalization

### Testing

- **Mocktail** - Mocking framework
- **flutter_test** - Testing framework

---

## Commands

### Development

```bash
# Install dependencies
flutter pub get

# Generate code (run after provider changes)
dart run build_runner watch --delete-conflicting-outputs

# Run app
flutter run

# Run tests
flutter test

# Analyze code
flutter analyze

# Format code
dart format .
```

### Build

```bash
# Debug APK
flutter build apk --debug

# Release APK
flutter build apk --release

# Release App Bundle
flutter build appbundle --release
```

---

## Next Steps

1. Review the [example feature](lib/features/example/) to understand the patterns
2. Read [ARCHITECTURE.md](docs/ARCHITECTURE.md) for detailed architecture guide
3. Use `generate_feature.sh` to create your first feature
4. Follow the patterns established in the example
5. Maintain test coverage ≥80%

---

## License

Private - Proprietary to development team

---

## Support

- Documentation: `/docs`
- Monorepo Guide: `/CLAUDE.md`
- Issues: GitHub Issues

---

<div align="center">

**Built with the Gold Standard - Delivering excellence from day one**

![Quality](https://img.shields.io/badge/Quality-10%2F10-brightgreen?style=flat-square)
![Architecture](https://img.shields.io/badge/Architecture-Clean-blue?style=flat-square)
![Tests](https://img.shields.io/badge/Tests-Passing-success?style=flat-square)

</div>
