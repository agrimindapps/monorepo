# Sistema de Error Handling Consistente

Este sistema fornece tratamento de erro unificado, logging estruturado e mecanismos de retry para o aplicativo Gasometer.

## 📋 Componentes Principais

### 1. AppError - Hierarquia de Erros Tipados

```dart
// Erro básico
AppError error = NetworkError(
  message: 'Connection failed',
  userFriendlyMessage: 'Problemas de conexão. Verifique sua internet.',
);

// Erro de validação com campos específicos
ValidationError validationError = ValidationError(
  message: 'Form validation failed',
  fieldErrors: {
    'email': ['Email é obrigatório', 'Formato de email inválido'],
    'password': ['Senha deve ter pelo menos 8 caracteres'],
  },
);

// Erro de negócio
BusinessLogicError businessError = VehicleNotFoundError();
```

### 2. ErrorHandler - Execução com Retry

```dart
final errorHandler = ErrorHandler(ErrorLogger());

// Execução básica
final result = await errorHandler.execute(
  () => repository.getData(),
  operationName: 'loadData',
);

// Com política de retry personalizada
final result = await errorHandler.execute(
  () => repository.saveData(data),
  policy: RetryPolicy.critical,
  operationName: 'saveData',
);

// Com timeout
final result = await errorHandler.executeWithTimeout(
  () => repository.getData(),
  Duration(seconds: 30),
  operationName: 'loadDataWithTimeout',
);
```

### 3. Result Pattern - Tratamento Funcional

```dart
// Uso básico
final result = await operation.toResult();

result.fold(
  (error) => showError(error.displayMessage),
  (data) => showSuccess(data),
);

// Mapeamento e transformação
final transformedResult = result
  .map((data) => data.toUpperCase())
  .mapError((error) => BusinessLogicError(message: 'Transformed: ${error.message}'));

// Encadeamento
final chainedResult = result.flatMap((data) => 
  processData(data).toResult()
);
```

### 4. BaseProvider - Provider com Error Handling

```dart
class MyProvider extends BaseProvider {
  final MyRepository _repository;
  
  MyProvider(this._repository);

  // Execução automática com error handling
  Future<void> loadData() async {
    await executeOperation(
      () => _repository.getData(),
      operationName: 'loadData',
      onSuccess: (data) {
        // Processar dados
      },
    );
  }

  // Operação que retorna dados
  Future<MyData?> saveData(MyData data) async {
    return executeDataOperation(
      () => _repository.save(data),
      operationName: 'saveData',
      parameters: {'id': data.id},
    );
  }

  @override
  void onRetry() {
    // Implementar lógica de retry
    loadData();
  }
}
```

### 5. ErrorLogger - Logging Estruturado

```dart
final logger = ErrorLogger();

// Log de erro com contexto
logger.logError(
  error,
  stackTrace: stackTrace,
  additionalContext: {
    'userId': user.id,
    'operation': 'saveData',
  },
);

// Log de operações de provider
logger.logProviderStateChange(
  'ExpensesProvider',
  'loaded',
  {'itemCount': 50},
);

// Log de requisições de rede
logger.logNetworkRequest(
  'POST',
  '/api/expenses',
  201,
  Duration(milliseconds: 450),
);
```

## 🎯 Políticas de Retry

### Políticas Predefinidas

```dart
// Operações de rede (3 tentativas, backoff exponencial)
RetryPolicy.network

// Operações críticas (5 tentativas, backoff suave)
RetryPolicy.critical

// Ações do usuário (2 tentativas, delay curto)
RetryPolicy.userAction

// Sem retry
RetryPolicy.noRetry
```

### Política Personalizada

```dart
final customPolicy = RetryPolicy(
  maxAttempts: 4,
  initialDelay: Duration(seconds: 1),
  maxDelay: Duration(minutes: 2),
  backoffMultiplier: 1.5,
  retryCondition: (error) => 
    error is NetworkError || 
    (error is ServerError && error.statusCode == 503),
);
```

## 🎨 UI Error Handling

### Widget de Erro Aprimorado

```dart
// Uso básico
EnhancedErrorWidget(
  error: provider.error!,
  onRetry: () => provider.retry(),
)

// Direto do provider
EnhancedErrorWidget.fromProvider(
  provider,
  onRetry: () => customRetryLogic(),
  showGoBackButton: true,
)

// Builder de estado do provider
ProviderStateBuilder(
  provider: expensesProvider,
  loadingBuilder: (context) => CircularProgressIndicator(),
  emptyBuilder: (context) => EmptyStateWidget(),
  contentBuilder: (context) => ExpensesList(),
  errorBuilder: (context, error) => CustomErrorWidget(error),
)
```

### Estados de Loading com Error

```dart
LoadingWithErrorWidget(
  isLoading: provider.isLoading,
  error: provider.error,
  onRetry: () => provider.retry(),
  child: MyContentWidget(),
)
```

## 📊 Tipos de Erro Disponíveis

| Tipo | Uso | Retry Automático | Severidade |
|------|-----|------------------|------------|
| `NetworkError` | Problemas de rede | ✅ | Error |
| `TimeoutError` | Timeout de operações | ✅ | Error |
| `ServerError` | Erros de servidor HTTP | ✅ (5xx apenas) | Error |
| `ValidationError` | Dados inválidos | ❌ | Warning |
| `BusinessLogicError` | Regras de negócio | ❌ | Warning |
| `AuthenticationError` | Autenticação | ❌ | Critical |
| `StorageError` | Problemas de armazenamento | ✅ | Error |
| `UnexpectedError` | Erros inesperados | ✅ | Fatal |

## 🔧 Configuração e Setup

### 1. Injeção de Dependência

Os serviços são automaticamente registrados no `injection_container.dart`:

```dart
// Error Handling Services
sl.registerLazySingleton<ErrorLogger>(() => ErrorLogger());
sl.registerLazySingleton<ErrorHandler>(() => ErrorHandler(sl()));
```

### 2. Provider Configuration

Atualize seus providers para estender `BaseProvider`:

```dart
class MyProvider extends BaseProvider {
  // Injete via construtor se necessário
  MyProvider({ErrorHandler? errorHandler, ErrorLogger? logger}) 
    : super(errorHandler: errorHandler, errorLogger: logger);
}
```

### 3. Repository Updates

Use o ErrorHandler em repositórios:

```dart
class MyRepositoryImpl implements MyRepository {
  final ErrorHandler _errorHandler;
  
  MyRepositoryImpl(this._errorHandler);
  
  @override
  Future<List<Data>> getData() async {
    final result = await _errorHandler.handleRepositoryOperation(
      () => _dataSource.getData(),
      repositoryName: 'MyRepository',
      methodName: 'getData',
    );
    
    return result.getOrThrow();
  }
}
```

## 🧪 Testes

### Executar Testes de Error Handling

```dart
import 'package:gasometer/core/error/error_handler_test.dart';

void main() {
  // Em modo debug, execute os testes
  runErrorHandlerTests();
}
```

### Testes Personalizados

```dart
final testSuite = ErrorHandlerTestSuite();
await testSuite.runAllTests();
await testSuite.testProviderIntegration();
```

## 📈 Métricas e Logging

### Logging em Produção

- Erros `Error`, `Critical` e `Fatal` são automaticamente enviados para crash reporting
- Logs estruturados em JSON para análise
- Contexto adicional incluído automaticamente

### Debug Mode

- Logs detalhados com stack traces
- Informações de estado do provider
- Métricas de retry e performance

## 🔄 Migração de Código Existente

### De try/catch para ErrorHandler

Antes:
```dart
Future<void> loadData() async {
  try {
    _isLoading = true;
    notifyListeners();
    
    final data = await repository.getData();
    _data = data;
    _error = null;
  } catch (e) {
    _error = 'Erro ao carregar dados: $e';
  } finally {
    _isLoading = false;
    notifyListeners();
  }
}
```

Depois:
```dart
Future<void> loadData() async {
  await executeListOperation(
    () => repository.getData(),
    operationName: 'loadData',
    onSuccess: (data) => _data = data,
  );
}
```

### De Provider simples para BaseProvider

1. Estenda `BaseProvider` em vez de `ChangeNotifier`
2. Remova gerenciamento manual de `_isLoading` e `_error`
3. Use `executeOperation` para operações
4. Implemente `onRetry()` se necessário

## 🚨 Boas Práticas

### ✅ Fazer

- Use tipos de erro específicos para diferentes cenários
- Implemente mensagens user-friendly
- Configure políticas de retry apropriadas
- Teste cenários de erro
- Use logging estruturado

### ❌ Evitar

- Capturar exceções genéricas sem contexto
- Ignorar erros silenciosamente
- Implementar retry manual sem política
- Mostrar mensagens técnicas para usuários
- Fazer log de informações sensíveis

## 📚 Exemplos Completos

Veja os arquivos de exemplo:
- `error_handler_test.dart` - Testes e exemplos de uso
- `expenses_provider_enhanced.dart` - Provider refatorado
- `enhanced_error_widget.dart` - Widgets de UI

## 🆘 Solução de Problemas

### Erro não está sendo logado
- Verifique se ErrorLogger está registrado no DI
- Confirme se está chamando `logError()` ou usando `BaseProvider`

### Retry não está funcionando
- Verifique se a política de retry permite o tipo de erro
- Confirme se `RetryPolicy.shouldRetry()` retorna true

### UI não mostra erro
- Verifique se está usando `ProviderStateBuilder` ou `EnhancedErrorWidget`
- Confirme se o provider está notificando listeners

### Performance impactada
- Use lazy providers quando possível
- Evite logging excessivo em produção
- Configure timeouts apropriados