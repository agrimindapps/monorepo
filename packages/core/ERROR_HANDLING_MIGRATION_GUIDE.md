# Error Handling Migration Guide

## 🎯 Objetivo

Padronizar error handling em **Either<Failure, T>** como padrão único para todo o monorepo.

---

## 📊 Estado Atual

| Pattern | Arquivos | Status | Ação |
|---------|----------|--------|------|
| **Either<Failure, T>** | 66 | ✅ Padrão | Manter |
| **Result<T>** | 20 | ⚠️ Deprecated | Migrar |
| **Null returns** | ~15 | ❌ Anti-pattern | Corrigir |
| **Direct throws** | ~10 | ❌ Não composable | Wrapper |

---

## ✅ Padrão Estabelecido: Either<Failure, T>

### Por que Either?

1. **Já dominante**: 66 arquivos vs 20 de Result
2. **Biblioteca madura**: dartz package (battle-tested)
3. **Functional programming**: Pattern matching, composability
4. **Type-safe**: Força tratamento de erros em compile-time
5. **Consistente**: Alinhado com Clean Architecture

### Estrutura

```dart
import 'package:dartz/dartz.dart';

// Either<Error, Success>
Either<Failure, User> result;

// Left = Error path
final error = Left<Failure, User>(AuthFailure('Invalid credentials'));

// Right = Success path
final success = Right<Failure, User>(user);
```

---

## 🔄 Migração: Result<T> → Either<Failure, T>

### Exemplo Completo

**Antes (Result):**
```dart
import '../../shared/utils/result.dart';
import '../../shared/utils/app_error.dart';

class UserService {
  Future<Result<User>> getUser(String id) async {
    try {
      final user = await _api.getUser(id);
      if (user == null) {
        return Result.error(
          AppError.notFound('User not found'),
        );
      }
      return Result.success(user);
    } catch (e, stackTrace) {
      return Result.error(
        AppError.unknown('Failed to get user', stackTrace: stackTrace),
      );
    }
  }

  // Uso:
  final result = await service.getUser('123');
  result.fold(
    (error) => print('Error: ${error.message}'),
    (user) => print('User: ${user.name}'),
  );
}
```

**Depois (Either):**
```dart
import 'package:dartz/dartz.dart';
import '../../shared/utils/failure.dart';

class UserService {
  Future<Either<Failure, User>> getUser(String id) async {
    try {
      final user = await _api.getUser(id);
      if (user == null) {
        return const Left(
          NotFoundFailure('User not found'),
        );
      }
      return Right(user);
    } on ApiException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure('Failed to get user: $e'));
    }
  }

  // Uso (idêntico!):
  final result = await service.getUser('123');
  result.fold(
    (failure) => print('Error: ${failure.message}'),
    (user) => print('User: ${user.name}'),
  );
}
```

### Mapeamento de Tipos

| Result | Either | Notes |
|--------|--------|-------|
| `Result<T>` | `Either<Failure, T>` | |
| `Result.success(data)` | `Right(data)` | |
| `Result.error(appError)` | `Left(failure)` | Ver mapeamento de erros abaixo |
| `result.data` | `result.fold((l) => null, (r) => r)` | Evitar! Use fold |
| `result.error` | `result.fold((l) => l, (r) => null)` | Evitar! Use fold |
| `result.isSuccess` | `result.isRight()` | |
| `result.isError` | `result.isLeft()` | |

### Mapeamento de Erros: AppError → Failure

```dart
// AppError (Result) → Failure (Either)
AppError.unknown() → UnknownFailure()
AppError.notFound() → NotFoundFailure()
AppError.network() → NetworkFailure()
AppError.unauthorized() → AuthFailure('Unauthorized')
AppError.validation() → ValidationFailure()
AppError.custom() → CustomFailure()
```

### Hierarquia de Failures

```dart
abstract class Failure {
  final String message;
  const Failure(this.message);
}

// Domain failures
class AuthFailure extends Failure {
  const AuthFailure(super.message);
}

class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}

// Infrastructure failures
class NetworkFailure extends Failure {
  const NetworkFailure(super.message);
}

class ServerFailure extends Failure {
  final int? statusCode;
  const ServerFailure(super.message, {this.statusCode});
}

// Data failures
class NotFoundFailure extends Failure {
  const NotFoundFailure(super.message);
}

class CacheFailure extends Failure {
  const CacheFailure(super.message);
}

// Generic
class UnknownFailure extends Failure {
  const UnknownFailure(super.message);
}
```

---

## 🛠️ Padrões de Conversão

### 1. Services/Repositories

```dart
// ❌ ANTES (Result)
class ProductRepository {
  Future<Result<List<Product>>> getAll() async {
    return ResultUtils.tryExecuteAsync(() async {
      final products = await _api.getProducts();
      return products;
    });
  }
}

// ✅ DEPOIS (Either)
class ProductRepository {
  Future<Either<Failure, List<Product>>> getAll() async {
    try {
      final products = await _api.getProducts();
      return Right(products);
    } on ApiException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure('Failed to get products: $e'));
    }
  }
}
```

### 2. Use Cases

```dart
// ❌ ANTES
abstract class ResultUseCase<Type, Params> {
  Future<Result<Type>> call(Params params);
}

class GetUserUseCase extends ResultUseCase<User, String> {
  @override
  Future<Result<User>> call(String userId) async {
    return await _repository.getUser(userId);
  }
}

// ✅ DEPOIS
abstract class UseCase<Type, Params> {
  Future<Either<Failure, Type>> call(Params params);
}

class GetUserUseCase extends UseCase<User, String> {
  @override
  Future<Either<Failure, User>> call(String userId) async {
    return await _repository.getUser(userId);
  }
}
```

### 3. Conversão Temporária (Gradual Migration)

Durante migração gradual, você pode converter Result → Either:

```dart
// Service antigo retorna Result<T>
Future<Result<User>> _oldGetUser(String id) async { ... }

// Wrapper que converte para Either
Future<Either<Failure, User>> getUser(String id) async {
  final result = await _oldGetUser(id);
  return result.toEither(); // Usa extensão já existente
}
```

Ou Either → Result (se necessário):

```dart
// Service novo retorna Either
Future<Either<Failure, User>> _newGetUser(String id) async { ... }

// Wrapper para código legado que espera Result
Future<Result<User>> getUserLegacy(String id) async {
  final either = await _newGetUser(id);
  return either.toResult(); // Usa extensão já existente
}
```

---

## ❌ Anti-Patterns para Corrigir

### 1. Null Returns Hiding Errors

```dart
// ❌ ERRADO: Null esconde o erro
T? safeRead<T>(WidgetRef ref, ProviderListenable<T> provider) {
  try {
    return ref.read(provider);
  } catch (e) {
    return null; // Error perdido!
  }
}

// ✅ CORRETO: Either expõe o erro
Either<Failure, T> safeRead<T>(
  WidgetRef ref,
  ProviderListenable<T> provider,
) {
  try {
    final value = ref.read(provider);
    return Right(value);
  } catch (e, stackTrace) {
    return Left(
      ProviderFailure(
        'Failed to read provider: $e',
        stackTrace: stackTrace,
      ),
    );
  }
}

// Uso:
final result = safeRead(ref, myProvider);
result.fold(
  (failure) => showError(failure.message),
  (value) => useValue(value),
);
```

### 2. Direct Throws (Not Composable)

```dart
// ❌ ERRADO: Throw quebra composability
Future<String> encrypt(String data) async {
  if (data.isEmpty) {
    throw ValidationException('Data cannot be empty');
  }
  return _doEncrypt(data);
}

// ✅ CORRETO: Either é composable
Future<Either<Failure, String>> encrypt(String data) async {
  if (data.isEmpty) {
    return const Left(ValidationFailure('Data cannot be empty'));
  }

  try {
    final encrypted = await _doEncrypt(data);
    return Right(encrypted);
  } catch (e) {
    return Left(EncryptionFailure(e.toString()));
  }
}

// Composability example:
final result = await encrypt(data)
    .then((either) => either.map(base64Encode))
    .then((either) => either.map(addChecksum));
```

---

## 🎯 Plano de Migração

### Fase 1: Preparação (✅ Completa)
- [x] Deprecar Result<T> class
- [x] Criar guia de migração
- [x] Adicionar conversões bidirecionais (já existe)

### Fase 2: Arquivos Críticos (Em progresso)
Converter arquivos de alta prioridade:
- [ ] `lib/src/infrastructure/services/enhanced_storage_service.dart`
- [ ] `lib/src/infrastructure/services/enhanced_connectivity_service.dart`
- [ ] `lib/src/infrastructure/services/http_client_service.dart`

### Fase 3: Arquivos Restantes
- [ ] 17 arquivos restantes usando Result<T>
- [ ] Validar que todos usam Either<Failure, T>
- [ ] Remover Result<T> class (v2.0.0)

### Fase 4: Anti-patterns
- [ ] Corrigir null returns (15 casos)
- [ ] Wrapper throws em Either (10 casos)

---

## 📚 Recursos

### Documentação

- **dartz package**: https://pub.dev/packages/dartz
- **Functional Programming**: https://dart.academy/functional-programming-in-dart-with-dartz/
- **Either pattern**: Pattern matching em Dart 3

### Exemplos no Monorepo

**Arquivos usando Either corretamente:**
- `lib/src/infrastructure/services/firebase_auth_service.dart` (893 linhas, exemplar)
- `lib/src/infrastructure/services/hive_storage_service.dart`
- `lib/src/domain/usecases/auth/login_usecase.dart`

### Helpers

```dart
// Extension para simplificar uso
extension EitherExtensions<L, R> on Either<L, R> {
  /// Get right value or throw
  R getOrThrow() {
    return fold(
      (l) => throw Exception('Left value: $l'),
      (r) => r,
    );
  }

  /// Get right value or default
  R getOrElse(R defaultValue) {
    return fold((l) => defaultValue, (r) => r);
  }

  /// Map right value
  Either<L, R2> mapRight<R2>(R2 Function(R) mapper) {
    return map(mapper);
  }
}
```

---

## ❓ FAQ

### Q: Por que não manter Result<T> e Either<Failure, T>?

**A:** Dois padrões para a mesma coisa causam:
- Confusão para novos desenvolvedores
- Conversões desnecessárias
- Manutenção duplicada
- Inconsistência no codebase

### Q: Result<T> tem API melhor, por que não usar?

**A:** Either é mais maduro e alinhado com FP. Result foi criado antes da padronização.

### Q: Quando remover Result<T>?

**A:** Planejado para v2.0.0 (após migração completa).

### Q: Posso usar try-catch com Either?

**A:** Sim! Either não proíbe exceptions, apenas as encapsula:

```dart
Future<Either<Failure, T>> operation() async {
  try {
    final result = await riskyOperation();
    return Right(result);
  } on SpecificException catch (e) {
    return Left(SpecificFailure(e.message));
  } catch (e) {
    return Left(UnknownFailure(e.toString()));
  }
}
```

---

## 🎓 Conclusão

**Either<Failure, T>** é o padrão oficial para error handling no monorepo.

**Benefícios:**
- ✅ Type-safe error handling
- ✅ Composable operations
- ✅ Explicit error paths
- ✅ Consistência em 66+ arquivos
- ✅ Alinhado com Clean Architecture

**Próximos passos:**
1. Revisar este guia
2. Converter arquivos críticos
3. Validar em code reviews
4. Remover Result<T> em v2.0.0

---

**Dúvidas?** Consulte o time de arquitetura ou abra issue no monorepo.
