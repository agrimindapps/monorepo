# app-calculei

Aplicativo completo de **calculadoras financeiras e trabalhistas** desenvolvido em Flutter.

## 📱 Features

### Calculadoras Financeiras
- **Juros Compostos** - Cálculo de juros compostos com visualização gráfica
- **Valor Futuro** - Projeção de investimentos e rendimentos
- **Vista vs Parcelado** - Comparação de formas de pagamento
- **Reserva de Emergência** - Planejamento de reserva financeira
- **Orçamento Regra 30-50** - Gestão de orçamento pessoal
- **Independência Financeira** - Cálculo de FIRE (Financial Independence, Retire Early)
- **Custo Efetivo Total (CET)** - Análise de custos reais de crédito
- **Custo Real de Crédito** - Comparação de modalidades de crédito

### Calculadoras Trabalhistas
- **Salário Líquido** - Cálculo de descontos e salário líquido
- **13º Salário (Décimo Terceiro)** - Cálculo proporcional e descontos
- **Férias** - Cálculo de férias e adicional
- **Horas Extras** - Cálculo de horas extras e adicionais
- **Seguro Desemprego** - Simulação de parcelas e valores

## 🏗️ Arquitetura

- **State Management**: Riverpod (com coexistência Provider durante migração)
- **Navigation**: go_router
- **DI**: GetIt + Injectable
- **Backend**: Firebase (Auth, Firestore)
- **Storage**: Hive (local) + Firebase (cloud)
- **Charts**: fl_chart para visualizações gráficas

## 🚀 Getting Started

### Prerequisites
- Flutter SDK >=3.3.0
- Dart SDK >=3.4.0
- Firebase project configured

### Installation

```bash
# Navigate to app directory
cd apps/app-calculei

# Install dependencies
flutter pub get

# Run code generation
dart run build_runner build --delete-conflicting-outputs

# Run app
flutter run
```

### Firebase Setup

1. Create a Firebase project at [Firebase Console](https://console.firebase.google.com/)
2. Add apps for each platform (Web, Android, iOS)
3. Update `lib/core/config/firebase_options.dart` with your Firebase configuration
4. Download `google-services.json` (Android) and `GoogleService-Info.plist` (iOS)

## 📦 Structure

```
lib/
├── core/                    # Core infrastructure
│   ├── config/              # Firebase, environment
│   ├── di/                  # Dependency injection (GetIt + Injectable)
│   ├── router/              # Navigation (go_router)
│   └── theme/               # Theme providers (Riverpod)
├── features/                # Feature modules (TODO: Clean Architecture migration)
├── pages/                   # Calculator pages (current structure)
│   ├── calc/
│   │   ├── financeiro/      # Financial calculators
│   │   └── trabalhistas/    # Labor calculators
│   ├── promo/               # Promo/landing pages
│   ├── mobile_page.dart     # Mobile layout
│   └── desktop_page.dart    # Desktop layout
├── constants/               # App constants (config, database, etc)
├── repository/              # Data repositories
├── services/                # Business services
├── widgets/                 # Shared widgets
└── app_page.dart            # Main app widget
```

## 🎨 Calculator Structure Pattern

Each calculator follows this structure:

```
pages/calc/[category]/[calculator_name]/
├── index.dart                        # Main calculator page
├── models/                           # Data models
│   └── [calculator]_model.dart
├── controllers/                      # Business logic (Provider/Riverpod)
│   └── [calculator]_controller.dart
├── widgets/                          # UI components
│   ├── [calculator]_form_widget.dart
│   └── [calculator]_result_widget.dart
├── services/                         # Calculator logic
│   ├── calculation_service.dart
│   ├── formatting_service.dart
│   └── validation_service.dart
└── constants/                        # Calculator constants
    └── calculation_constants.dart
```

## 🔧 Development

### Code Generation

```bash
# Watch mode (auto-rebuild on changes)
dart run build_runner watch --delete-conflicting-outputs

# One-time build
dart run build_runner build --delete-conflicting-outputs
```

### Testing

```bash
# Run all tests
flutter test

# Run with coverage
flutter test --coverage
```

### Linting

```bash
# Run analyzer
flutter analyze

# Run custom lints (Riverpod)
dart run custom_lint
```

## 📚 Tech Stack

### Core Dependencies
- **flutter_riverpod** (^2.6.1) - State management
- **go_router** (^16.2.4) - Navigation
- **get_it** (^8.0.2) - Dependency injection
- **injectable** (^2.5.1) - DI code generation
- **dartz** (^0.10.1) - Functional programming

### Firebase
- **firebase_core** - Firebase initialization
- **firebase_auth** - Authentication
- **cloud_firestore** - Cloud database

### UI/UX
- **fl_chart** (^0.69.0) - Chart visualizations
- **flutter_staggered_grid_view** (^0.7.0) - Grid layouts
- **mask_text_input_formatter** (^2.9.0) - Input formatting
- **icons_plus** - Extended icon sets

### Storage
- **hive** - Local NoSQL database
- **shared_preferences** - Key-value storage

## 🎯 Development Roadmap

### Current Status
- ✅ 8 financial calculators implemented
- ✅ 5 labor calculators implemented
- ✅ Responsive layout (mobile + desktop)
- ✅ Firebase integration
- ⏳ Migrating to Riverpod state management
- ⏳ Implementing Clean Architecture

### Next Steps
1. **State Management Migration**
   - Replace Provider with Riverpod in all calculators
   - Implement code generation (`@riverpod`)
   - Add unit tests for all providers

2. **Clean Architecture Refactoring**
   - Create feature modules under `lib/features/`
   - Implement Repository Pattern
   - Add use cases for business logic
   - Implement Either<Failure, T> error handling

3. **Testing**
   - Add unit tests for all calculators (≥80% coverage)
   - Add widget tests for critical paths
   - Implement integration tests

4. **Features**
   - User authentication and profiles
   - Calculator history and favorites
   - Share results functionality
   - Export to PDF/Excel

## 🤝 Monorepo Integration

This app is part of a Flutter monorepo. It uses:
- **packages/core** - Shared services (Firebase, RevenueCat, Analytics, Hive)
- **Riverpod** as standard state management
- **Clean Architecture** patterns
- **Either<Failure, T>** for error handling

Follow monorepo patterns from `.claude/guides/MIGRATION_PROVIDER_TO_RIVERPOD.md`

## 📄 License

Copyright © 2024. All rights reserved.

---

**Monorepo**: `monorepo/apps/app-calculei`
**Status**: ✅ Structure setup, 🔄 Migrating to Clean Architecture + Riverpod
