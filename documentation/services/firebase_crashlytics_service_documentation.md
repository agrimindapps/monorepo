# Documentação do `FirebaseCrashlyticsService`

O `FirebaseCrashlyticsService` é uma implementação do serviço de relatórios de falhas e erros, utilizando o Firebase Crashlytics. Ele oferece funcionalidades para registrar erros fatais e não fatais, logs, informações de usuário e chaves personalizadas, além de categorizar diferentes tipos de erros (validação, rede, parsing, autenticação, permissão, etc.).

## 1. Propósito

O principal objetivo do `FirebaseCrashlyticsService` é:
- Capturar e reportar automaticamente falhas (crashes) e erros não fatais que ocorrem na aplicação.
- Fornecer contexto detalhado sobre os erros, incluindo logs, identificadores de usuário e dados personalizados.
- Ajudar na depuração e melhoria da estabilidade da aplicação, centralizando os relatórios de erros no Firebase Crashlytics.

## 2. Inicialização

O `FirebaseCrashlyticsService` pode ser instanciado diretamente. Ele utiliza a instância padrão do `FirebaseCrashlytics`.

```dart
import 'package:core/src/infrastructure/services/firebase_crashlytics_service.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

// Instância padrão
final crashlyticsService = FirebaseCrashlyticsService();

// Ou, para testes ou injeção de dependência, você pode passar uma instância mock/real
final crashlyticsServiceWithMock = FirebaseCrashlyticsService(
  crashlytics: FirebaseCrashlytics.instance, // ou um mock
);
```

## 3. Funcionalidades Principais

Todos os métodos que interagem com o Crashlytics retornam um `Future<Either<Failure, void>>`, indicando sucesso (`Right(null)`) ou falha (`Left(FirebaseFailure)`).

### 3.1. `recordError({required dynamic exception, required StackTrace stackTrace, String? reason, bool fatal = true, Map<String, dynamic>? additionalInfo})`

Registra um erro (exceção) no Crashlytics. Pode ser usado para erros fatais (padrão) ou não fatais.

**Parâmetros:**
- `exception`: A exceção ou erro que ocorreu.
- `stackTrace`: O stack trace do erro.
- `reason`: Uma descrição opcional do motivo do erro.
- `fatal`: Define se o erro é fatal (true) ou não fatal (false). Padrão é `true`.
- `additionalInfo`: Um mapa de informações adicionais para anexar ao relatório.

Exemplo:

```dart
try {
  throw StateError('Este é um erro fatal simulado!');
} catch (e, s) {
  await crashlyticsService.recordError(
    exception: e,
    stackTrace: s,
    reason: 'Erro crítico na inicialização',
    fatal: true,
    additionalInfo: {'user_id': 'abc-123', 'app_state': 'initialization'},
  );
}
```

### 3.2. `recordNonFatalError({required dynamic exception, required StackTrace stackTrace, String? reason, Map<String, dynamic>? additionalInfo})`

Um atalho para registrar erros não fatais. Internamente, chama `recordError` com `fatal: false`.

Exemplo:

```dart
try {
  // Alguma operação que pode falhar mas não deve derrubar o app
  int.parse('abc');
} catch (e, s) {
  await crashlyticsService.recordNonFatalError(
    exception: e,
    stackTrace: s,
    reason: 'Falha na conversão de string para int',
    additionalInfo: {'input_value': 'abc'},
  );
}
```

### 3.3. `log(String message)`

Adiciona uma mensagem de log ao relatório de falhas atual. Essas mensagens são úteis para fornecer um rastro de eventos que levaram a um erro.

Exemplo:

```dart
await crashlyticsService.log('Usuário clicou no botão de login.');
await crashlyticsService.log('Tentando autenticar com credenciais.');
```

### 3.4. `setUserId(String userId)`

Define um identificador de usuário para associar relatórios de falhas a um usuário específico. Isso ajuda a entender o impacto dos erros em diferentes segmentos de usuários.

Exemplo:

```dart
await crashlyticsService.setUserId('user_12345');
```

### 3.5. `setCustomKey({required String key, required dynamic value})`

Define uma chave e valor personalizados que serão incluídos em todos os relatórios de falhas subsequentes. Útil para adicionar contexto específico da aplicação.

Exemplo:

```dart
await crashlyticsService.setCustomKey(key: 'current_screen', value: 'DashboardPage');
await crashlyticsService.setCustomKey(key: 'user_role', value: 'admin');
```

### 3.6. `setCustomKeys({required Map<String, dynamic> keys})`

Define múltiplas chaves e valores personalizados de uma vez.

Exemplo:

```dart
await crashlyticsService.setCustomKeys(keys: {
  'last_action': 'fetch_data',
  'data_source': 'remote_api',
});
```

### 3.7. `isCrashlyticsCollectionEnabled()`

Verifica se a coleta de dados do Crashlytics está habilitada.

Exemplo:

```dart
final result = await crashlyticsService.isCrashlyticsCollectionEnabled();
result.fold(
  (failure) => print('Erro: ${failure.message}'),
  (isEnabled) => print('Coleta do Crashlytics habilitada: $isEnabled'),
);
```

### 3.8. `setCrashlyticsCollectionEnabled({required bool enabled})`

Habilita ou desabilita a coleta de dados do Crashlytics. Pode ser útil para respeitar preferências de privacidade do usuário.

Exemplo:

```dart
// Desabilitar coleta
await crashlyticsService.setCrashlyticsCollectionEnabled(enabled: false);

// Habilitar coleta
await crashlyticsService.setCrashlyticsCollectionEnabled(enabled: true);
```

### 3.9. Métodos Específicos de Registro de Erros

O serviço oferece métodos especializados para registrar tipos comuns de erros, adicionando automaticamente contexto relevante e categorizando-os no Crashlytics.

- **`recordValidationError({required String field, required String message, Map<String, dynamic>? context})`**
  Registra erros de validação de formulário ou dados.

- **`recordNetworkError({required String url, required int statusCode, String? errorMessage, Map<String, dynamic>? context})`**
  Registra erros de requisições de rede.

- **`recordParsingError({required String dataType, required String errorMessage, String? rawData, Map<String, dynamic>? context})`**
  Registra erros ao fazer parsing de dados (JSON, XML, etc.).

- **`recordAuthError({required String authMethod, required String errorCode, required String errorMessage, Map<String, dynamic>? context})`**
  Registra erros relacionados à autenticação.

- **`recordPermissionError({required String permission, required String errorMessage, Map<String, dynamic>? context})`**
  Registra erros relacionados a permissões (ex: acesso à câmera, localização).

- **`recordAppError({required String appName, required String feature, required String errorType, required String errorMessage, Map<String, dynamic>? context})`**
  Registra erros específicos da lógica de negócio da aplicação.

Exemplo de uso de um método específico:

```dart
// Erro de rede
await crashlyticsService.recordNetworkError(
  url: 'https://api.example.com/data',
  statusCode: 404,
  errorMessage: 'Recurso não encontrado',
  context: {'request_id': 'xyz'},
);

// Erro de validação
await crashlyticsService.recordValidationError(
  field: 'email',
  message: 'Formato de e-mail inválido',
  context: {'input_value': 'invalid-email'},
);
```

### 3.10. `recordSessionInfo({required String appVersion, required String buildNumber, required String platform, String? deviceModel, String? osVersion, Map<String, dynamic>? additionalInfo})`

Registra informações importantes sobre a sessão atual do aplicativo, como versão, plataforma e modelo do dispositivo. Essas informações são adicionadas como chaves personalizadas.

Exemplo:

```dart
await crashlyticsService.recordSessionInfo(
  appVersion: '1.0.0',
  buildNumber: '1',
  platform: 'Android',
  deviceModel: 'Pixel 5',
  osVersion: 'Android 11',
  additionalInfo: {'user_type': 'premium'},
);
```

### 3.11. `recordBreadcrumb({required String message, String? category, BreadcrumbLevel level = BreadcrumbLevel.info, Map<String, dynamic>? data})`

Registra um "breadcrumb" (rastro de eventos) que fornece contexto sobre as ações do usuário ou do sistema antes de um erro. Isso ajuda a reconstruir a sequência de eventos.

**Parâmetros:**
- `message`: A mensagem do breadcrumb.
- `category`: Uma categoria opcional para o breadcrumb (ex: 'UI', 'API').
- `level`: O nível de severidade do breadcrumb (`info`, `warning`, `error`). Padrão é `info`.
- `data`: Dados adicionais para o breadcrumb.

Exemplo:

```dart
await crashlyticsService.recordBreadcrumb(
  message: 'Navegou para a tela de perfil',
  category: 'Navigation',
  level: BreadcrumbLevel.info,
);

await crashlyticsService.recordBreadcrumb(
  message: 'Falha ao carregar imagem',
  category: 'ImageLoading',
  level: BreadcrumbLevel.warning,
  data: {'image_url': 'http://example.com/bad.jpg'},
);
```

## 4. Exceções Customizadas

O serviço define várias classes de exceção personalizadas (`ValidationException`, `NetworkException`, `ParsingException`, `AuthException`, `PermissionException`, `AppSpecificException`) para categorizar e fornecer informações estruturadas sobre diferentes tipos de erros. Isso melhora a organização e a análise dos relatórios no Crashlytics.

Você pode lançar e capturar essas exceções em seu código e passá-las para os métodos `recordError` ou `recordNonFatalError` para um relatório mais detalhado.

Exemplo:

```dart
class UserService {
  Future<void> createUser(String email, String password) async {
    if (!email.contains('@')) {
      throw ValidationException(field: 'email', message: 'Email inválido');
    }
    // ... lógica de criação de usuário
  }
}

// No seu widget ou controller
try {
  await UserService().createUser('test', 'password');
} on ValidationException catch (e, s) {
  await crashlyticsService.recordValidationError(
    field: e.field,
    message: e.message,
    context: e.context,
  );
} catch (e, s) {
  await crashlyticsService.recordError(exception: e, stackTrace: s);
}
```
