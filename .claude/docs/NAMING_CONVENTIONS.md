# 🏷️ Convenções de Nomenclatura

A consistência nos nomes facilita a navegação e manutenção no monorepo. Siga estes padrões rigorosamente.

## Arquivos e Pastas
*   **Arquivos**: Sempre `snake_case` (ex: `user_profile_page.dart`).
*   **Pastas de Feature**: Plural (ex: `features/plants`, `features/auth`).
*   **Pastas de Camada**: Singular/Plural padrão (ex: `domain/usecases`, `data/repositories`).
*   **Documentação (.md)**: Sempre em `apps/[app]/docs/` (ex: `apps/app-plantis/docs/FEATURE_ANALYSIS.md`).

## Classes e Tipos (PascalCase)

### Domain Layer
*   **Entities**: `[Nome]Entity` ou apenas `[Nome]` (ex: `Plant`, `UserEntity`).
*   **Use Cases**: `[Verbo][Objeto]UseCase` (ex: `AddPlantUseCase`, `GetPlantsUseCase`).
*   **Repositories (Interface)**: `I[Nome]Repository` ou `[Nome]Repository` (ex: `PlantsRepository`).
*   **Failures**: `[Tipo]Failure` (ex: `ServerFailure`, `ValidationFailure`).

### Data Layer
*   **Models**: `[Nome]Model` (ex: `PlantModel`).
*   **Repositories (Impl)**: `[Nome]RepositoryImpl` (ex: `PlantsRepositoryImpl`).
*   **Data Sources**: `[Nome][Local|Remote]DataSource` (ex: `PlantsLocalDataSource`).

### Presentation Layer (Riverpod)
*   **Notifiers**: `[Nome]Notifier` (ex: `PlantsNotifier`). **NUNCA** use `Controller` para estado de Riverpod.
*   **States**: `[Nome]State` (ex: `PlantsState`).
*   **Providers**: `[nome]Provider` (camelCase, gerado automaticamente pelo Riverpod Generator).

### UI Widgets
*   **Pages/Screens**: `[Nome]Page` (ex: `PlantDetailsPage`).
*   **Widgets**: `[Nome]Widget` ou nome descritivo (ex: `PlantCard`, `CustomButton`).

## Variáveis e Métodos (camelCase)
*   **Booleanos**: Prefixos `is`, `has`, `can` (ex: `isLoading`, `hasError`).
*   **Streams**: Sufixo `Stream` (ex: `userStream`).
*   **Controllers (Flutter)**: Sufixo `Controller` (ex: `textEditingController`, `scrollController`).
*   **Private**: Prefixo `_` (ex: `_init()`).

## Constantes (SCREAMING_SNAKE_CASE)
*   Ex: `MAX_RETRY_ATTEMPTS`, `API_BASE_URL`.
