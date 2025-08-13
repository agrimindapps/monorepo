# Documentação do `HiveStorageService`

O `HiveStorageService` é uma implementação do serviço de armazenamento local, utilizando a biblioteca Hive. Ele oferece uma interface para persistir e recuperar dados de forma eficiente, com suporte a diferentes "boxes" (equivalente a tabelas ou coleções), TTL (Time-To-Live) para dados com expiração, e funcionalidades para gerenciar dados offline e configurações de usuário.

## 1. Propósito

O principal objetivo do `HiveStorageService` é:
- Fornecer uma solução de armazenamento local rápida e fácil de usar para a aplicação.
- Abstrair a complexidade da biblioteca Hive, oferecendo uma API limpa e orientada a objetos.
- Suportar diferentes casos de uso de cache, como configurações de usuário, dados temporários e dados para sincronização offline.
- Gerenciar o ciclo de vida das "boxes" do Hive.

## 2. Inicialização

Para usar o `HiveStorageService`, você precisa primeiro instanciá-lo e, em seguida, chamar o método `initialize()` para configurar o Hive e abrir as boxes padrão.

```dart
import 'package:core/src/infrastructure/services/hive_storage_service.dart';
import 'package:core/src/infrastructure/services/hive_boxes.dart'; // Para os nomes das boxes

final localStorageService = HiveStorageService();

Future<void> main() async {
  // Certifique-se de que o Flutter esteja inicializado antes de chamar Hive.initFlutter()
  // WidgetsFlutterBinding.ensureInitialized(); // Se estiver no main.dart

  final result = await localStorageService.initialize();
  result.fold(
    (failure) => print('Erro ao inicializar o storage: ${failure.message}'),
    (_) => print('Storage local inicializado com sucesso!'),
  );

  runApp(MyApp());
}
```

**Observação:** O método `initialize()` já chama `Hive.initFlutter()` internamente. Se você tiver tipos customizados que precisam ser armazenados, você precisará registrar seus `TypeAdapter`s antes de chamar `initialize()`, ou modificar o método `_registerAdapters()` dentro do `HiveStorageService`.

## 3. Funcionalidades Principais

Todos os métodos que realizam operações de armazenamento retornam um `Future<Either<Failure, T>>`, onde `T` é o tipo de dado esperado em caso de sucesso, e `Failure` em caso de erro.

### 3.1. `initialize()`

Inicializa o Hive e abre as boxes padrão (`settings`, `cache`, `offline`, `plantis`, `receituagro`). Deve ser chamado uma única vez no início da aplicação.

```dart
final result = await localStorageService.initialize();
```

### 3.2. `save<T>({required String key, required T data, String? box})`

Salva um dado de tipo `T` associado a uma `key` em uma `box` específica. Se a `box` não for especificada, a `HiveBoxes.settings` será usada por padrão.

Exemplo:

```dart
// Salvar uma string na box de configurações
await localStorageService.save<String>(
  key: 'username',
  data: 'joao.silva',
  box: HiveBoxes.settings,
);

// Salvar um objeto complexo (se o adapter estiver registrado) na box de cache
// await localStorageService.save<MyObject>(
//   key: 'my_object_id',
//   data: myObjectInstance,
//   box: HiveBoxes.cache,
// );
```

### 3.3. `get<T>({required String key, String? box})`

Recupera um dado de tipo `T` associado a uma `key` de uma `box` específica. Retorna `null` se a chave não for encontrada.

Exemplo:

```dart
final usernameResult = await localStorageService.get<String>(
  key: 'username',
  box: HiveBoxes.settings,
);

usernameResult.fold(
  (failure) => print('Erro ao obter username: ${failure.message}'),
  (username) => print('Username: ${username ?? 'Não encontrado'}'),
);
```

### 3.4. `remove({required String key, String? box})`

Remove um dado associado a uma `key` de uma `box` específica.

Exemplo:

```dart
await localStorageService.remove(key: 'username', box: HiveBoxes.settings);
```

### 3.5. `clear({String? box})`

Limpa todos os dados de uma `box` específica. Se a `box` não for especificada, a `HiveBoxes.settings` será limpa.

Exemplo:

```dart
await localStorageService.clear(box: HiveBoxes.cache); // Limpa a box de cache
```

### 3.6. `contains({required String key, String? box})`

Verifica se uma `key` existe em uma `box` específica.

Exemplo:

```dart
final containsResult = await localStorageService.contains(key: 'username', box: HiveBoxes.settings);
containsResult.fold(
  (failure) => print('Erro: ${failure.message}'),
  (exists) => print('Username existe: $exists'),
);
```

### 3.7. `getKeys({String? box})`

Retorna uma lista de todas as chaves presentes em uma `box` específica.

### 3.8. `getValues<T>({String? box})`

Retorna uma lista de todos os valores de tipo `T` presentes em uma `box` específica.

### 3.9. `length({String? box})`

Retorna o número de entradas (pares chave-valor) em uma `box` específica.

### 3.10. `saveList<T>({required String key, required List<T> data, String? box})`

Salva uma lista de dados de tipo `T`.

### 3.11. `getList<T>({required String key, String? box})`

Recupera uma lista de dados de tipo `T`.

Exemplo de lista:

```dart
// Salvar uma lista de strings
await localStorageService.saveList<String>(
  key: 'recent_searches',
  data: ['Flutter', 'Dart', 'Hive'],
);

// Obter a lista
final searchesResult = await localStorageService.getList<String>(key: 'recent_searches');
searchesResult.fold(
  (failure) => print('Erro ao obter buscas: ${failure.message}'),
  (searches) => print('Buscas recentes: $searches'),
);
```

### 3.12. `addToList<T>({required String key, required T item, String? box})`

Adiciona um item a uma lista existente associada a uma `key`.

### 3.13. `removeFromList<T>({required String key, required T item, String? box})`

Remove um item de uma lista existente associada a uma `key`.

### 3.14. `saveWithTTL<T>({required String key, required T data, required Duration ttl, String? box})`

Salva um dado com um tempo de vida (Time-To-Live - TTL). O dado será automaticamente considerado expirado após a duração `ttl`.

Exemplo:

```dart
await localStorageService.saveWithTTL<String>(
  key: 'temporary_token',
  data: 'my_secret_token',
  ttl: const Duration(minutes: 5),
  box: HiveBoxes.cache,
);
```

### 3.15. `getWithTTL<T>({required String key, String? box})`

Recupera um dado salvo com TTL. Se o dado estiver expirado, ele será removido e `null` será retornado.

Exemplo:

```dart
final tokenResult = await localStorageService.getWithTTL<String>(
  key: 'temporary_token',
  box: HiveBoxes.cache,
);

tokenResult.fold(
  (failure) => print('Erro ao obter token: ${failure.message}'),
  (token) => print('Token: ${token ?? 'Expirado ou não encontrado'}'),
);
```

### 3.16. `cleanExpiredData({String? box})`

Percorre uma `box` (padrão: `HiveBoxes.cache`) e remove todos os dados que foram salvos com TTL e já expiraram.

Exemplo:

```dart
await localStorageService.cleanExpiredData(box: HiveBoxes.cache);
print('Dados expirados da cache limpos.');
```

### 3.17. `saveUserSetting({required String key, required dynamic value})`

Salva uma configuração de usuário na `HiveBoxes.settings`.

### 3.18. `getUserSetting<T>({required String key, T? defaultValue})`

Recupera uma configuração de usuário. Pode-se fornecer um `defaultValue` caso a chave não seja encontrada.

### 3.19. `getAllUserSettings()`

Retorna um mapa com todas as configurações de usuário salvas na `HiveBoxes.settings`.

Exemplo de configurações de usuário:

```dart
await localStorageService.saveUserSetting(key: 'theme_mode', value: 'dark');
await localStorageService.saveUserSetting(key: 'notifications_enabled', value: true);

final theme = await localStorageService.getUserSetting<String>(key: 'theme_mode', defaultValue: 'light');
print('Modo do tema: $theme');

final allSettings = await localStorageService.getAllUserSettings();
print('Todas as configurações: $allSettings');
```

### 3.20. `saveOfflineData<T>({required String key, required T data, DateTime? lastSync})`

Salva dados na `HiveBoxes.offline` para gerenciamento de sincronização. Inclui metadados como `createdAt` e `lastSync`.

### 3.21. `getOfflineData<T>({required String key})`

Recupera dados offline, encapsulados em um objeto `OfflineData<T>` que inclui os metadados de sincronização.

### 3.22. `markAsSynced({required String key})`

Atualiza o `lastSync` de um dado offline para o momento atual, marcando-o como sincronizado.

### 3.23. `getUnsyncedKeys()`

Retorna uma lista das chaves de todos os dados na `HiveBoxes.offline` que ainda não foram sincronizados (`isSynced` é `false`).

Exemplo de dados offline:

```dart
// Salvar um item para ser sincronizado depois
await localStorageService.saveOfflineData<Map<String, dynamic>>(
  key: 'pending_post_1',
  data: {'title': 'Meu Post Offline', 'content': 'Conteúdo...'},
);

// Obter dados não sincronizados
final unsynced = await localStorageService.getUnsyncedKeys();
print('Itens não sincronizados: $unsynced');

// Marcar um item como sincronizado
await localStorageService.markAsSynced(key: 'pending_post_1');
```

## 4. Métodos Auxiliares e Gerenciamento

### 4.1. `_registerAdapters()`

Método interno para registrar `TypeAdapter`s do Hive. **É crucial registrar adapters para qualquer classe customizada que você deseja armazenar no Hive.**

```dart
// Exemplo de como seria o registro de um adapter para uma classe MyObject
// void _registerAdapters() {
//   Hive.registerAdapter(MyObjectAdapter());
// }
```

### 4.2. `dispose()`

Fecha todas as boxes abertas e limpa o cache interno. Deve ser chamado ao finalizar o uso do serviço (ex: ao fechar o aplicativo ou em testes) para liberar recursos.

```dart
await localStorageService.dispose();
print('HiveStorageService descartado.');
```

## 5. `HiveBoxes`

O arquivo `hive_boxes.dart` (não incluído aqui, mas referenciado) define as constantes para os nomes das boxes utilizadas pelo serviço:

- `HiveBoxes.settings`: Para configurações de usuário.
- `HiveBoxes.cache`: Para dados de cache geral.
- `HiveBoxes.offline`: Para dados que precisam ser sincronizados.
- `HiveBoxes.plantis`: Box específica para o aplicativo Plantis.
- `HiveBoxes.receituagro`: Box específica para o aplicativo Receituagro.
