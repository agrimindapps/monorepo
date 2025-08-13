# Documentação do `FirebaseAnalyticsService`

O `FirebaseAnalyticsService` é uma implementação do serviço de análise de dados, utilizando o Firebase Analytics. Ele permite registrar eventos personalizados, definir propriedades de usuário, rastrear telas e registrar uma variedade de interações do usuário, fornecendo insights valiosos sobre o comportamento do aplicativo e do usuário.

## 1. Propósito

O principal objetivo do `FirebaseAnalyticsService` é:
- Coletar dados de uso do aplicativo para análise e otimização.
- Registrar eventos importantes e interações do usuário.
- Segmentar usuários com base em suas propriedades.
- Fornecer uma interface unificada para o envio de dados de analytics, abstraindo a complexidade do Firebase Analytics.
- Controlar o envio de dados de analytics com base na configuração do ambiente (debug/release).

## 2. Inicialização

O `FirebaseAnalyticsService` pode ser instanciado diretamente. Ele utiliza a instância padrão do `FirebaseAnalytics`.

```dart
import 'package:core/src/infrastructure/services/firebase_analytics_service.dart';
import 'package:firebase_analytics/firebase_analytics.dart';

// Instância padrão
final analyticsService = FirebaseAnalyticsService();

// Ou, para testes ou injeção de dependência, você pode passar uma instância mock/real
final analyticsServiceWithMock = FirebaseAnalyticsService(
  analytics: FirebaseAnalytics.instance, // ou um mock
);
```

## 3. Funcionalidades Principais

Todos os métodos que interagem com o Analytics retornam um `Future<Either<Failure, void>>`, indicando sucesso (`Right(null)`) ou falha (`Left(FirebaseFailure)`).

**Observação sobre o Modo Debug:**
Por padrão, o `FirebaseAnalyticsService` **não registra eventos no Firebase Analytics quando `EnvironmentConfig.enableAnalytics` é `false`** (geralmente em modo debug). Em vez disso, ele apenas loga a tentativa de registro no console, se `EnvironmentConfig.enableLogging` for `true`. Isso evita poluir seus dados de produção com dados de teste.

### 3.1. `logEvent(String eventName, {Map<String, dynamic>? parameters})`

Registra um evento personalizado com um nome e parâmetros opcionais. Este é o método fundamental para rastrear interações específicas.

**Parâmetros:**
- `eventName`: O nome do evento (ex: 'button_click', 'item_view').
- `parameters`: Um mapa de parâmetros adicionais para o evento (ex: {'item_id': '123', 'item_name': 'Produto X'}).

Exemplo:

```dart
await analyticsService.logEvent(
  'add_to_cart',
  parameters: {
    'item_id': 'SKU123',
    'item_name': 'Camiseta Azul',
    'quantity': 1,
    'price': 29.99,
  },
);
```

### 3.2. `setUserProperties({required Map<String, String> properties})`

Define propriedades de usuário que descrevem segmentos da sua base de usuários (ex: 'user_type', 'subscription_status').

Exemplo:

```dart
await analyticsService.setUserProperties({
  'user_type': 'premium',
  'subscription_status': 'active',
});
```

### 3.3. `setUserId(String? userId)`

Define um identificador para o usuário atual. Isso permite associar eventos e propriedades a um usuário específico em diferentes sessões.

Exemplo:

```dart
await analyticsService.setUserId('user_abc_123');
// Para deslogar o usuário do analytics (remover o ID)
// await analyticsService.setUserId(null);
```

### 3.4. `setCurrentScreen({required String screenName, String? screenClassOverride})`

Registra uma visualização de tela. Útil para rastrear o fluxo de navegação do usuário.

Exemplo:

```dart
await analyticsService.setCurrentScreen(
  screenName: 'ProductDetailScreen',
  screenClassOverride: 'ProductDetailView',
);
```

### 3.5. Métodos Específicos de Registro de Eventos

O serviço oferece métodos convenientes para registrar eventos comuns, pré-definindo nomes de eventos e parâmetros para facilitar o uso e garantir a consistência.

- **`logLogin({required String method})`**: Registra um evento de login.
- **`logLogout()`**: Registra um evento de logout.
- **`logSignUp({required String method})`**: Registra um evento de registro de conta.
- **`logPurchase({required String productId, required double value, required String currency, String? transactionId})`**: Registra um evento de compra.
- **`logCancelSubscription({required String productId, String? reason})`**: Registra o cancelamento de uma assinatura.
- **`logTrialStart({required String productId})`**: Registra o início de um período de teste.
- **`logTrialConversion({required String productId})`**: Registra a conversão de um período de teste em assinatura.
- **`logError({required String error, String? stackTrace, Map<String, dynamic>? additionalInfo})`**: Registra um erro no aplicativo.
- **`logSearch({required String searchTerm, String? category, int? resultCount})`**: Registra uma pesquisa realizada pelo usuário.
- **`logShare({required String contentType, required String contentId, String? method})`**: Registra um compartilhamento de conteúdo.
- **`logFeedback({required String type, required String content, double? rating})`**: Registra um feedback do usuário.
- **`logOnboardingComplete({int? stepsCompleted, int? totalSteps})`**: Registra a conclusão do processo de onboarding.
- **`logTutorialComplete({required String tutorialId})`**: Registra a conclusão de um tutorial.
- **`logSettingChanged({required String settingName, required dynamic oldValue, required dynamic newValue})`**: Registra uma alteração de configuração.

Exemplo de uso de um método específico:

```dart
// Login
await analyticsService.logLogin(method: 'email_password');

// Compra
await analyticsService.logPurchase(
  productId: 'premium_plan',
  value: 9.99,
  currency: 'BRL',
  transactionId: 'TRANS12345',
);

// Erro
await analyticsService.logError(
  error: 'Falha ao carregar dados do perfil',
  stackTrace: 'StackTrace aqui...',
  additionalInfo: {'user_id': 'abc'},
);
```

## 4. Métodos Auxiliares

### 4.1. `_sanitizeParameters(Map<String, dynamic>? parameters)`

Método interno que garante que os parâmetros enviados ao Firebase Analytics estejam em um formato compatível (strings, números ou booleanos) e que strings longas sejam truncadas para evitar erros.

## 5. Configuração de Ambiente

O comportamento do `FirebaseAnalyticsService` é influenciado pelas variáveis de ambiente definidas em `EnvironmentConfig`:

- **`EnvironmentConfig.enableAnalytics`**: Se `false`, os eventos não serão enviados ao Firebase Analytics. Útil para desabilitar o analytics em ambientes de desenvolvimento/teste.
- **`EnvironmentConfig.enableLogging`**: Se `true`, as chamadas de analytics serão logadas no console mesmo quando `enableAnalytics` for `false`, o que é útil para depuração.

Certifique-se de configurar essas variáveis de ambiente corretamente para o seu fluxo de desenvolvimento e produção.
