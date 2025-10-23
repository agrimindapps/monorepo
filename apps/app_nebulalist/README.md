# ✨ NebulaList - Task & List Management

<div align="center">

![Quality](https://img.shields.io/badge/Quality-9%2F10-success?style=for-the-badge)
![Tests](https://img.shields.io/badge/Tests-0-red?style=for-the-badge)
![Architecture](https://img.shields.io/badge/Architecture-Clean%20Arch-blue?style=for-the-badge)
![State](https://img.shields.io/badge/State-Pure%20Riverpod-blueviolet?style=for-the-badge)
![Flutter](https://img.shields.io/badge/Flutter-3.24+-02569B?style=for-the-badge&logo=flutter)
![Dart](https://img.shields.io/badge/Dart-3.5.0+-0175C2?style=for-the-badge&logo=dart)

**Aplicativo profissional de gerenciamento de tarefas e listas com arquitetura offline-first**

[Características](#-características) •
[Arquitetura](#-arquitetura) •
[Qualidade](#-métricas-de-qualidade) •
[Como Usar](#-como-usar) •
[Roadmap](#-roadmap)

</div>

---

## 🏆 Pure Riverpod Implementation

Este aplicativo é uma **implementação pura de Riverpod** no monorepo, atingindo **nota 9/10** com arquitetura moderna e clean code.

### ⭐ Por Que 9/10?

- ✅ **Zero erros** no analyzer
- ✅ **Zero warnings**
- ✅ **Clean Architecture** completa (3-layer)
- ✅ **Pure Riverpod** com code generation (`@riverpod`)
- ✅ **Offline-first** com Hive + Firestore
- ✅ **Repository Pattern** (Local + Remote data sources)
- ✅ **Either<Failure, T>** para error handling
- ✅ **15 use cases** implementados
- ❌ **Zero testes** (blocker para 10/10)

---

## 📊 Métricas de Qualidade

```
┌─────────────────────────────────────────────────┐
│ Métrica              Valor        Status        │
├─────────────────────────────────────────────────┤
│ Analyzer Errors      0            ✅ Perfeito   │
│ Analyzer Warnings    0            ✅ Perfeito   │
│ Dead Code            0            ✅ Limpo      │
│ Unit Tests           0            ❌ Pendente   │
│ Architecture         Clean Arch   ✅ Excelente  │
│ State Management     Riverpod     ✅ Moderno    │
│ Code Quality         9/10         🟢 Muito Bom  │
└─────────────────────────────────────────────────┘
```

### Code Statistics
- **Total Files:** 111 Dart files
- **Lines of Code:** ~17,684 lines
- **Riverpod Providers:** 37 providers with code generation
- **Use Cases:** 15 use cases (5 Lists + 10 Items)

---

## ✨ Características

### 📋 Funcionalidades Principais

- **Gestão de Listas**
  - Criar, editar, arquivar e restaurar listas
  - Organização com tags e categorias
  - Favoritos para acesso rápido
  - Free tier: 10 listas ativas

- **Sistema Two-Tier de Itens**
  - **ItemMaster**: Templates reutilizáveis (seu "banco pessoal" de itens)
  - **ListItem**: Instâncias em listas específicas
  - Prioridade (baixa, normal, alta, urgente)
  - Tracking de completude e quantidade
  - Notas personalizadas por item

- **Offline-First**
  - Hive para storage local (rápido e eficiente)
  - Firestore para sync remoto (best-effort)
  - Funciona 100% offline
  - Sync não-bloqueante em background

- **Recursos Premium** 🚧
  - Listas ilimitadas
  - Itens ilimitados
  - Compartilhamento de listas (planejado)
  - Temas customizados (planejado)

### 🔒 Segurança & Privacidade

- **Ownership Verification**: Todas operações verificam userId
- **Firebase Auth** para autenticação segura
- **Last Write Wins (LWW)** para resolução de conflitos
- **Dados locais** criptografados via Hive encryption

---

## 🏗️ Arquitetura

### Clean Architecture + Riverpod

```
lib/
├── core/
│   ├── auth/                 # Auth state notifier
│   ├── config/               # App config, constants
│   ├── di/                   # GetIt + Injectable DI
│   ├── providers/            # Riverpod service providers
│   ├── router/               # GoRouter + auth guards
│   ├── services/             # Analytics, Notifications, Share
│   ├── storage/              # Hive boxes setup
│   ├── sync/                 # BasicSyncService (stub mode)
│   ├── theme/                # Material Design theming
│   └── validation/           # Input validators
├── features/
│   ├── auth/                 # Authentication
│   │   ├── domain/           # Login, Signup, Reset use cases
│   │   └── presentation/     # Auth UI + Riverpod providers
│   ├── lists/                # Lists Management (FULL CLEAN ARCH)
│   │   ├── data/
│   │   │   ├── datasources/  # Local (Hive) + Remote (Firestore)
│   │   │   ├── models/       # ListModel (HiveObject + JSON)
│   │   │   └── repositories/ # ListRepository implementation
│   │   ├── domain/
│   │   │   ├── entities/     # ListEntity (Freezed)
│   │   │   ├── repositories/ # IListRepository (interface)
│   │   │   └── usecases/     # 5 use cases (Create, Get, Update, Delete, CheckLimit)
│   │   └── presentation/
│   │       ├── pages/        # Lists UI screens
│   │       ├── providers/    # Riverpod state management
│   │       └── widgets/      # Reusable list widgets
│   ├── items/                # Items Management (FULL CLEAN ARCH)
│   │   ├── data/
│   │   │   ├── datasources/  # ItemMaster + ListItem datasources
│   │   │   ├── models/       # Models com Hive + JSON
│   │   │   └── repositories/ # 2 repositories (ItemMaster, ListItem)
│   │   ├── domain/
│   │   │   ├── entities/     # ItemMasterEntity, ListItemEntity
│   │   │   ├── repositories/ # Interfaces
│   │   │   └── usecases/     # 10 use cases
│   │   └── presentation/
│   │       ├── pages/        # Items UI
│   │       ├── providers/    # Riverpod providers
│   │       └── widgets/      # Item widgets
│   ├── premium/              # Premium subscription (mockado)
│   ├── promo/                # Promotional content
│   └── settings/             # Settings & preferences
└── shared/
    └── widgets/              # Shared UI components
```

### SOLID Principles

**Single Responsibility Principle (SRP):**
- ✅ Use cases focados em uma única operação
- ✅ Data sources separados (Local vs Remote)
- ✅ Repositories isolados por entidade

**Open/Closed Principle (OCP):**
- ✅ Interfaces em domain layer
- ✅ Implementations em data layer
- ✅ Easy to extend without modification

**Liskov Substitution Principle (LSP):**
- ✅ Repository interfaces substituíveis
- ✅ Either<Failure, T> padronizado

**Interface Segregation Principle (ISP):**
- ✅ Repositories com métodos específicos
- ✅ Sem interfaces gordas

**Dependency Inversion Principle (DIP):**
- ✅ Domain não depende de data
- ✅ Presentation não depende de data
- ✅ Inversão via interfaces + DI

---

## 🎯 Padrões Implementados

### Repository Pattern (Offline-First)

```dart
// Interface (Domain Layer)
abstract class IListRepository {
  Future<Either<Failure, List<ListEntity>>> getLists();
  Future<Either<Failure, void>> createList(ListEntity list);
  Future<Either<Failure, void>> updateList(ListEntity list);
  Future<Either<Failure, void>> deleteList(String listId);
  Future<Either<Failure, bool>> canCreateList();
}

// Implementation (Data Layer)
class ListRepository implements IListRepository {
  final ListLocalDataSource _localDataSource;
  final ListRemoteDataSource _remoteDataSource;

  @override
  Future<Either<Failure, List<ListEntity>>> getLists() async {
    try {
      // 1. Always read from local first (offline-first)
      final models = await _localDataSource.getLists();

      // 2. Best-effort remote sync (non-blocking)
      _remoteDataSource.syncLists().catchError((_) {});

      final entities = models.map((m) => m.toEntity()).toList();
      return Right(entities);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }
}
```

### Riverpod State Management

```dart
// Use case provider (GetIt → Riverpod bridge)
@riverpod
GetListsUseCase getListsUseCase(GetListsUseCaseRef ref) {
  return getIt<GetListsUseCase>();
}

// State notifier with AsyncValue
@riverpod
class ListsNotifier extends _$ListsNotifier {
  @override
  Future<List<ListEntity>> build() async {
    final useCase = ref.read(getListsUseCaseProvider);
    final result = await useCase();

    return result.fold(
      (failure) => throw failure,
      (lists) => lists.where((l) => !l.isArchived).toList(),
    );
  }

  Future<void> createList(ListEntity list) async {
    final useCase = ref.read(createListUseCaseProvider);
    final result = await useCase(list);

    result.fold(
      (failure) => throw failure,
      (_) => ref.invalidateSelf(),
    );
  }
}

// UI consumption
class ListsPage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final listsAsync = ref.watch(listsNotifierProvider);

    return listsAsync.when(
      data: (lists) => ListView.builder(...),
      loading: () => CircularProgressIndicator(),
      error: (error, stack) => ErrorWidget(error),
    );
  }
}
```

### Error Handling (Either<Failure, T>)

```dart
// Use case retorna Either
class CreateListUseCase {
  Future<Either<Failure, void>> call(ListEntity list) async {
    // Validations
    if (list.name.trim().isEmpty) {
      return const Left(ValidationFailure('Nome não pode estar vazio'));
    }

    // Check limit
    final canCreate = await _repository.canCreateList();
    return canCreate.fold(
      (failure) => Left(failure),
      (allowed) {
        if (!allowed) {
          return const Left(
            QuotaExceededFailure('Limite de listas atingido. Assine Premium!'),
          );
        }
        return _repository.createList(list);
      },
    );
  }
}
```

---

## 🧪 Testes

### Status Atual: ❌ Zero testes

**Blocker para nota 10/10**. Testes são essenciais para produção.

### Testes Planejados:

**Unit Tests (Priority):**
- [ ] Lists use cases (5 tests × 5-7 scenarios = ~30 tests)
- [ ] Items use cases (10 tests × 5-7 scenarios = ~60 tests)
- [ ] Auth use cases (3 tests × 5-7 scenarios = ~20 tests)
- [ ] Repositories (mock data sources)

**Widget Tests:**
- [ ] ListCard widget
- [ ] ItemCard widget
- [ ] Create list dialog
- [ ] Create item dialog

**Integration Tests:**
- [ ] E2E: Create list → Add items → Mark complete
- [ ] E2E: Offline mode → Sync when online
- [ ] E2E: Free tier limits

**Target Coverage:** ≥80% para use cases

---

## 🚀 Como Usar

### Pré-requisitos

- Flutter 3.24.0 ou superior
- Dart 3.5.0 ou superior
- Firebase project configurado

### Setup

```bash
# 1. Clone o monorepo
git clone <monorepo-url>
cd monorepo/apps/app_nebulalist

# 2. Install dependencies
flutter pub get

# 3. Code generation (Riverpod + Hive + Injectable + Freezed)
dart run build_runner build --delete-conflicting-outputs

# 4. Run
flutter run
```

### Firebase Setup

1. Criar projeto no [Firebase Console](https://console.firebase.google.com/)
2. Adicionar app Flutter
3. Download `google-services.json` (Android) e `GoogleService-Info.plist` (iOS)
4. Colocar nos diretórios apropriados
5. Habilitar Firebase Auth e Firestore

---

## 📦 Dependencies

### Core
- **core** package: Shared services (Firebase, Riverpod, Hive, GetIt, Injectable, dartz)

### State Management
- **flutter_riverpod**: State management
- **riverpod_annotation**: Code generation

### Dependency Injection
- **get_it**: Service locator
- **injectable**: Code generation for DI

### Functional Programming
- **dartz**: Either<L, R> for error handling

### Local Storage
- **hive** + **hive_flutter**: NoSQL local database
- **path_provider**: File system paths

### Firebase
- **firebase_core**, **firebase_auth**, **cloud_firestore**, **firebase_storage**, **firebase_analytics**

### Navigation
- **go_router**: Declarative routing

### Code Generation
- **build_runner**, **riverpod_generator**, **injectable_generator**, **hive_generator**, **freezed**, **json_serializable**

### Testing
- **mocktail**: Mocking (installed but not used yet)

---

## 🗺️ Roadmap

### Phase 1: Quality ✅ (Completed)
- [x] Fix SDK version in pubspec.yaml
- [x] Run flutter analyze and fix all warnings
- [x] Add to CLAUDE.md
- [x] Create BasicSyncService (stub mode)
- [x] Register sync service in DI
- [x] Create professional README

### Phase 2: Testing 🚧 (Next Priority)
- [ ] Setup test infrastructure
- [ ] Unit tests for Lists use cases (80% coverage)
- [ ] Unit tests for Items use cases (80% coverage)
- [ ] Mock repositories with Mocktail
- [ ] CI/CD with automated tests

### Phase 3: Sync Service 🚧
- [ ] Implement full sync logic in BasicSyncService
- [ ] Background periodic sync
- [ ] Network status listener
- [ ] Sync queue for offline operations
- [ ] UI indicators for sync state

### Phase 4: Premium Features 🚧
- [ ] Integrate RevenueCat for subscriptions
- [ ] Implement unlimited lists for premium
- [ ] Implement unlimited items for premium
- [ ] Premium-only features (themes, sharing)

### Phase 5: Collaboration 📅 (Future)
- [ ] Share lists with other users
- [ ] Real-time collaboration
- [ ] Comments and mentions
- [ ] Activity log

---

## 🐛 Known Issues

1. **No Tests**: Zero test coverage (blocker for production)
2. **Sync Incomplete**: `lib/core/sync/` has BasicSyncService in stub mode
3. **Premium Mocked**: RevenueCat not integrated yet
4. **README Was Minimal**: Now updated with full documentation ✅

---

## 📄 License

Copyright © 2024. All rights reserved.

---

## 🤝 Contributing

Este é um projeto do monorepo. Para contribuir:

1. Seguir padrões estabelecidos em CLAUDE.md
2. Manter Clean Architecture
3. Usar Pure Riverpod com code generation
4. Either<Failure, T> para error handling
5. ≥80% test coverage em use cases
6. 0 analyzer errors/warnings

---

<div align="center">

**Mantido com ❤️ | Quality Score: 9/10**

[⬆ Voltar ao topo](#-nebulalist---task--list-management)

</div>
