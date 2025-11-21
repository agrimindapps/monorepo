# 🏗️ Arquitetura do Monorepo

Este documento define a arquitetura padrão para todos os aplicativos do monorepo. A referência de implementação ("Gold Standard") é o **app-plantis**.

## 📐 Clean Architecture

Seguimos rigorosamente a Clean Architecture dividida em 3 camadas principais por feature:

```
lib/
├── core/                    # Infraestrutura compartilhada (Auth, DI, Network, etc)
├── features/                # Funcionalidades isoladas
│   ├── [feature_name]/
│   │   ├── domain/          # 🎯 Regras de Negócio (Pura Dart)
│   │   │   ├── entities/    # Objetos de domínio (sem dependências de framework)
│   │   │   ├── repositories/# Interfaces (contratos) dos repositórios
│   │   │   ├── usecases/    # Casos de uso (1 arquivo por ação)
│   │   │   └── services/    # Serviços de domínio (lógica pura)
│   │   │
│   │   ├── data/            # 💾 Implementação de Dados
│   │   │   ├── datasources/ # Fontes de dados (Local/Remote)
│   │   │   ├── models/      # DTOs (Data Transfer Objects) com fromJson/toJson
│   │   │   └── repositories/# Implementação dos contratos do domain
│   │   │
│   │   └── presentation/    # 📱 Interface e Estado
│   │       ├── pages/       # Telas (Widgets)
│   │       ├── widgets/     # Componentes menores
│   │       └── providers/   # Gerenciamento de Estado (Riverpod)
│   │
└── shared/                  # Widgets e utilitários compartilhados entre features
```

## 🔄 Regras de Dependência

1.  **Domain** não depende de NINGUÉM.
2.  **Data** depende de **Domain**.
3.  **Presentation** depende de **Domain**.
4.  **Presentation** NUNCA importa **Data** diretamente (exceto para injeção de dependência na raiz).

## 🧩 Padrões Específicos

### 1. State Management (Riverpod)
*   Usamos **Riverpod Generator** (`@riverpod`) para todos os novos providers.
*   Providers de UseCases servem como ponte para o GetIt.
*   Notifiers devem estender `_$NomeNotifier`.

### 2. Dependency Injection (GetIt + Injectable)
*   Usamos `injectable` para gerar o código de registro do `GetIt`.
*   Repositories são registrados como `@LazySingleton(as: IRepository)`.
*   UseCases são registrados como `@injectable`.

### 3. Error Handling
*   NUNCA lance exceções para a UI.
*   Use `Either<Failure, T>` do pacote `dartz`.
*   Repositories devem capturar exceções e converter para `Failure` (ex: `ServerFailure`, `CacheFailure`).

### 4. Datasources
*   **LocalDataSource**: Usa Drift (preferencial) ou Hive.
*   **RemoteDataSource**: Usa Firebase/Supabase/API.
*   **Repository**: Coordena a sincronização entre Local e Remote (Offline-first).
