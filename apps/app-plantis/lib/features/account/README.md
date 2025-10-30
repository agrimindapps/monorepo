# Feature: Account (Conta de Usuário)

## 📋 Visão Geral

Feature responsável pelo gerenciamento da conta do usuário no app Plantis, incluindo visualização de informações, logout, limpeza de dados e exclusão de conta.

## 🏗️ Arquitetura Clean Architecture

Esta feature segue os princípios SOLID e Clean Architecture com separação clara de responsabilidades:

```
account/
├── domain/                    # Camada de Domínio (Regras de Negócio)
│   ├── entities/             # Entidades de negócio
│   │   └── account_info.dart
│   ├── repositories/         # Interfaces de repositórios
│   │   └── account_repository.dart
│   └── usecases/            # Casos de uso (lógica de negócio)
│       ├── get_account_info_usecase.dart
│       ├── logout_usecase.dart
│       ├── clear_data_usecase.dart
│       └── delete_account_usecase.dart
│
├── data/                      # Camada de Dados (Implementações)
│   ├── datasources/          # Fontes de dados (Firebase, Hive)
│   │   ├── account_remote_datasource.dart
│   │   └── account_local_datasource.dart
│   └── repositories/         # Implementações de repositórios
│       └── account_repository_impl.dart
│
└── presentation/             # Camada de Apresentação (UI)
    ├── providers/           # Riverpod providers
    │   └── account_providers.dart
    ├── pages/              # Páginas
    │   └── account_profile_page.dart
    ├── widgets/            # Widgets reutilizáveis
    │   ├── account_info_section.dart
    │   ├── account_details_section.dart
    │   ├── account_actions_section.dart
    │   ├── data_sync_section.dart
    │   └── device_management_section.dart
    ├── dialogs/            # Diálogos
    │   ├── account_deletion_dialog.dart
    │   ├── data_clear_dialog.dart
    │   └── logout_progress_dialog.dart
    └── utils/              # Utilitários de UI
        ├── text_formatters.dart
        └── widget_utils.dart
```

## 🎯 Princípios SOLID Aplicados

### 1. Single Responsibility Principle (SRP)
- Cada Use Case tem uma única responsabilidade
- `LogoutUseCase`: apenas logout
- `ClearDataUseCase`: apenas limpeza de dados
- `DeleteAccountUseCase`: apenas exclusão de conta

### 2. Open/Closed Principle (OCP)
- Repositórios usam interfaces abstratas
- Fácil adicionar novos data sources sem modificar código existente

### 3. Liskov Substitution Principle (LSP)
- Implementações podem ser substituídas sem quebrar funcionalidade
- `AccountRepositoryImpl` implementa `AccountRepository`

### 4. Interface Segregation Principle (ISP)
- Interfaces específicas para cada data source
- `AccountRemoteDataSource` vs `AccountLocalDataSource`

### 5. Dependency Inversion Principle (DIP)
- Use Cases dependem de abstrações (interfaces)
- Injeção de dependências via Riverpod

## 🔄 Fluxo de Dados (Either Pattern)

Toda comunicação entre camadas usa `Either<Failure, Success>`:

```dart
// Exemplo: Logout
UI (Widget) 
  → Provider (LogoutNotifier)
    → Use Case (LogoutUseCase)
      → Repository Interface (AccountRepository)
        → Repository Implementation (AccountRepositoryImpl)
          → Data Sources (Remote + Local)
            → Firebase / Hive

// Retorno
Either<Failure, void>
  → Left(AuthFailure) em caso de erro
  → Right(void) em caso de sucesso
```

## 📦 Uso dos Providers

### 1. Obter informações da conta

```dart
// No widget
final accountInfoAsync = ref.watch(accountInfoProvider);

accountInfoAsync.when(
  data: (accountInfo) => Text(accountInfo.displayName),
  loading: () => CircularProgressIndicator(),
  error: (error, stack) => Text('Erro: $error'),
);
```

### 2. Realizar Logout

```dart
// No widget
final logoutNotifier = ref.read(logoutNotifierProvider.notifier);

Future<void> handleLogout() async {
  final result = await logoutNotifier.logout();
  
  result.fold(
    (failure) {
      // Mostrar erro
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(failure.message)),
      );
    },
    (_) {
      // Navegar para tela de login
      context.go('/login');
    },
  );
}
```

### 3. Limpar Dados

```dart
final clearDataNotifier = ref.read(clearDataNotifierProvider.notifier);

Future<void> handleClearData() async {
  final result = await clearDataNotifier.clearData();
  
  result.fold(
    (failure) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro: ${failure.message}')),
      );
    },
    (count) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$count registros limpos!')),
      );
    },
  );
}
```

## 🔐 Tratamento de Erros

Todas as falhas são tipadas e herdam de `Failure`:

- `AuthFailure`: Erros de autenticação
- `ServerFailure`: Erros de servidor/Firebase
- `CacheFailure`: Erros de storage local
- `ValidationFailure`: Erros de validação
- `UnknownFailure`: Erros inesperados

```dart
// Exemplo de tratamento específico
result.fold(
  (failure) {
    if (failure is AuthFailure) {
      // Redirecionar para login
    } else if (failure is NetworkFailure) {
      // Mostrar mensagem de conexão
    } else {
      // Erro genérico
    }
  },
  (data) {
    // Sucesso
  },
);
```

## 🧪 Testabilidade

A arquitetura facilita testes unitários:

```dart
// Mock do repository
class MockAccountRepository extends Mock implements AccountRepository {}

// Teste do Use Case
test('LogoutUseCase deve retornar Right em caso de sucesso', () async {
  // Arrange
  final mockRepo = MockAccountRepository();
  when(mockRepo.logout()).thenAnswer((_) async => Right(null));
  final useCase = LogoutUseCase(mockRepo);
  
  // Act
  final result = await useCase(NoParams());
  
  // Assert
  expect(result, isA<Right>());
  verify(mockRepo.logout()).called(1);
});
```

## 📝 TODOs e Melhorias Futuras

- [ ] Implementar integração com RevenueCat para status premium
- [ ] Adicionar cache de informações da conta
- [ ] Implementar sincronização bidirecional (local ↔ remote)
- [ ] Adicionar testes unitários para todos os Use Cases
- [ ] Adicionar testes de integração para Repository
- [ ] Implementar feature flag para exclusão de conta
- [ ] Adicionar analytics para ações de conta

## 🔗 Dependências

- `core` package: Fornece `Failure`, `Either`, `UseCase`, services
- `riverpod_annotation`: Para geração de providers
- `equatable`: Para comparação de entities

## 📚 Referências

- [Clean Architecture (Uncle Bob)](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)
- [SOLID Principles](https://en.wikipedia.org/wiki/SOLID)
- [Riverpod Best Practices](https://riverpod.dev/docs/concepts/about_code_generation)
- [Either Pattern (Functional Programming)](https://dev.to/rohan_b/either-in-dart-2fhj)
