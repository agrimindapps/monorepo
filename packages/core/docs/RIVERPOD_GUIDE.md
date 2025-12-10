# Guia de Uso do Riverpod

Este guia descreve os padrões adotados no monorepo para gerenciamento de estado utilizando **Riverpod** com **Code Generation**.

## 🎯 Visão Geral

Utilizamos o pacote `riverpod_generator` para criar providers de forma mais segura, concisa e com melhor suporte a hot-reload.

### Dependências Necessárias

Certifique-se de que o `pubspec.yaml` do seu módulo/app possui:

```yaml
dependencies:
  flutter_riverpod: ^2.x.x
  riverpod_annotation: ^2.x.x

dev_dependencies:
  riverpod_generator: ^2.x.x
  build_runner: ^2.x.x
```

## 🛠️ Criando Providers

### 1. Provider Simples (Functional Provider)

Para estados que não precisam de métodos para modificação (apenas leitura ou computados):

```dart
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'my_provider.g.dart';

@riverpod
String myLabel(MyLabelRef ref) {
  return 'Hello World';
}
```

### 2. FutureProvider (Assíncrono)

Ideal para chamadas de API ou banco de dados:

```dart
@riverpod
Future<List<User>> users(UsersRef ref) async {
  final repository = ref.watch(userRepositoryProvider);
  return repository.getUsers();
}
```

### 3. NotifierProvider (Estado Mutável Síncrono)

Para estados que podem ser alterados:

```dart
@riverpod
class Counter extends _$Counter {
  @override
  int build() => 0;

  void increment() => state++;
}
```

### 4. AsyncNotifierProvider (Estado Mutável Assíncrono)

Para estados complexos que envolvem carregamento inicial assíncrono e mutações:

```dart
@riverpod
class AuthController extends _$AuthController {
  @override
  FutureOr<User?> build() async {
    // Carregamento inicial
    return _getUserFromStorage();
  }

  Future<void> login(String email, String password) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final user = await _authRepository.login(email, password);
      return user;
    });
  }
}
```

## 📱 Consumindo Providers

### ConsumerWidget

A forma mais comum de ler providers na UI.

```dart
class MyWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final count = ref.watch(counterProvider);
    
    return Text('$count');
  }
}
```

### Lidando com AsyncValue

Para providers assíncronos (`FutureProvider`, `AsyncNotifier`), use o pattern matching do `when`:

```dart
class UserList extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usersAsync = ref.watch(usersProvider);

    return usersAsync.when(
      data: (users) => ListView(children: ...),
      loading: () => const CircularProgressIndicator(),
      error: (err, stack) => Text('Erro: $err'),
    );
  }
}
```

### Escutando Mudanças (Listeners)

Para ações como navegação ou mostrar Snackbars/Dialogs baseados em mudança de estado:

```dart
ref.listen<AsyncValue<void>>(
  authControllerProvider,
  (previous, next) {
    if (next.hasError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(next.error.toString())),
      );
    } else if (next.value != null) {
      context.go('/home');
    }
  },
);
```

## 🏗️ Integração com Clean Architecture

No nosso monorepo, seguimos este fluxo:

1.  **Data Layer**: Repositories e Data Sources são providos via Riverpod.
2.  **Domain Layer**: UseCases são providos via Riverpod, dependendo dos Repositories.
3.  **Presentation Layer**: Controllers/Notifiers dependem dos UseCases.

Exemplo:

```dart
// Data
@riverpod
AuthRepository authRepository(AuthRepositoryRef ref) {
  return AuthRepositoryImpl(ref.watch(authRemoteDataSourceProvider));
}

// Domain
@riverpod
LoginUseCase loginUseCase(LoginUseCaseRef ref) {
  return LoginUseCase(ref.watch(authRepositoryProvider));
}

// Presentation
@riverpod
class LoginController extends _$LoginController {
  @override
  FutureOr<void> build() {}

  Future<void> login() async {
    final useCase = ref.read(loginUseCaseProvider);
    // ...
  }
}
```

## 💡 Dicas e Boas Práticas

1.  **Evite `StateProvider` e `ChangeNotifier`**: Prefira sempre `Notifier` e `AsyncNotifier` gerados.
2.  **Use `ref.watch` no `build`**: Garante que o widget reconstrua quando o estado mudar.
3.  **Use `ref.read` em callbacks**: Em funções como `onPressed`, use `read` para obter o estado atual ou invocar métodos sem criar uma subscrição.
4.  **KeepAlive**: Se precisar que o estado persista mesmo quando não há ouvintes (ex: cache), use `@Riverpod(keepAlive: true)`.

```dart
@Riverpod(keepAlive: true)
Future<Config> appConfig(AppConfigRef ref) async { ... }
```

5.  **Famílias (Families)**: Para passar argumentos para o provider.

```dart
@riverpod
Future<User> user(UserRef ref, {required String id}) async {
  return repository.getUser(id);
}

// Uso
ref.watch(userProvider(id: '123'));
```
