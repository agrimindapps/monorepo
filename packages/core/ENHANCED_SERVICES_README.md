# Enhanced Services - Core Package

Este documento descreve os services aprimorados adicionados ao core package do monorepo Flutter.

## 🚀 Novos Services Implementados

### 1. **HttpClientService** - HTTP Client Otimizado
- **Arquivo**: `http_client_service.dart`
- **Funcionalidades**:
  - Cliente HTTP baseado em Dio com interceptors avançados
  - Cache automático de requests GET
  - Retry automático com backoff exponencial
  - Auth interceptor para tokens automáticos
  - Error handling padronizado com AppError
  - Upload/download de arquivos com progress
  - Timeout configurável por request
  - Logging estruturado para debugging

```dart
// Exemplo de uso
final httpService = HttpClientService(baseUrl: 'https://api.exemplo.com');
await httpService.initialize();

final result = await httpService.get<User>('/users/1', 
  transformer: (data) => User.fromJson(data)
);
```

### 2. **EnhancedImageService** - Manipulação Avançada de Imagens
- **Arquivo**: `enhanced_image_service.dart`
- **Funcionalidades**:
  - Seleção de imagens (câmera/galeria) com otimização automática
  - Cache inteligente (memória + disco)
  - Compressão e redimensionamento
  - Geração de thumbnails
  - Validação de formatos e tamanhos
  - Suporte a múltiplas seleções
  - Métricas de cache e performance

```dart
// Exemplo de uso
final imageService = EnhancedImageService();
await imageService.initialize();

final result = await imageService.pickFromCamera(
  maxWidth: 1920,
  maxHeight: 1920,
  imageQuality: 85,
);
```

### 3. **EnhancedStorageService** - Sistema Unificado de Armazenamento
- **Arquivo**: `enhanced_storage_service.dart`
- **Funcionalidades**:
  - Múltiplos backends (Hive, SharedPreferences, SecureStorage, FileSystem)
  - Estratégia automática baseada no tipo de dados
  - Memory cache para performance
  - Backup e restore automático
  - Criptografia transparente para dados sensíveis
  - Compressão de dados grandes
  - TTL (Time To Live) para dados temporários

```dart
// Exemplo de uso
final storageService = EnhancedStorageService();
await storageService.initialize();

// Armazenamento automático baseado no tipo/tamanho
await storageService.store('user_token', token, encrypt: true, ttl: Duration(hours: 24));

// Recuperação com fallback entre storages
final user = await storageService.retrieve<User>('current_user');
```

### 4. **EnhancedConnectivityService** - Monitoramento Avançado de Rede
- **Arquivo**: `enhanced_connectivity_service.dart`  
- **Funcionalidades**:
  - Monitoramento em tempo real da conectividade
  - Teste de conectividade real (ping)
  - Medição de qualidade da rede (latência)
  - Retry automático com espera por conectividade
  - Métricas de rede e uptime
  - Detecção de mudanças de tipo de conexão
  - Fallback para múltiplos hosts de teste

```dart
// Exemplo de uso
final connectivityService = EnhancedConnectivityService();
await connectivityService.initialize();

// Stream de mudanças de conectividade
connectivityService.onConnectivityChanged.listen((status) {
  print('Conectividade: ${status.isConnected}');
});

// Execução com retry automático
final result = await connectivityService.executeWithRetry(() async {
  return await apiCall();
});
```

### 5. **EnhancedLoggingService** - Sistema Estruturado de Logs
- **Arquivo**: `enhanced_logging_service.dart`
- **Funcionalidades**:
  - Múltiplos níveis (trace, debug, info, warning, error, critical)
  - Persistência local com rotação de arquivos
  - Formatação estruturada (JSON)
  - Performance profiling automático
  - Busca e filtros avançados
  - Export em múltiplos formatos
  - Categorização de logs
  - Memory buffer para logs recentes

```dart
// Exemplo de uso
final loggingService = EnhancedLoggingService();
await loggingService.initialize(minLevel: LogLevel.info);

await loggingService.info('Usuário logado', 
  category: 'AUTH',
  metadata: {'userId': user.id}
);

// Performance tracking
loggingService.startPerformanceTracking('api_call');
// ... operação ...
await loggingService.endPerformanceTracking('api_call');
```

### 6. **ValidationService** - Validação Completa de Dados
- **Arquivo**: `validation_service.dart`
- **Funcionalidades**:
  - Validadores comuns (email, CPF, CNPJ, telefone, URL)
  - Validadores compostos (combine, conditional)
  - Validação de formulários
  - Validação assíncrona (ex: email único)
  - Sanitização de dados
  - Mensagens internacionalizáveis
  - Builder pattern para validações complexas

```dart
// Exemplo de uso
// Validação simples
final emailValidator = ValidationService.combine([
  ValidationService.required(),
  ValidationService.email(),
]);

// Validação de formulário
final formData = {'email': 'user@example.com', 'password': '123456'};
final rules = {
  'email': [ValidationService.required(), ValidationService.email()],
  'password': [ValidationService.required(), ValidationService.strongPassword()],
};

final result = ValidationService.validateForm(formData, rules);
```

### 7. **EnhancedSecurityService** - Sistema Completo de Segurança
- **Arquivo**: `enhanced_security_service.dart`
- **Funcionalidades**:
  - Criptografia simétrica (AES-256)
  - Hash seguro de senhas (PBKDF2)
  - Geração de tokens e chaves seguros
  - Autenticação biométrica
  - Secure storage com criptografia adicional
  - Rate limiting e detecção de ataques
  - Sanitização e validação de inputs
  - Verificação de integridade de dados

```dart
// Exemplo de uso
final securityService = EnhancedSecurityService();
await securityService.initialize();

// Criptografia
final encrypted = await securityService.encrypt(sensitiveData);
final decrypted = await securityService.decrypt(encrypted.data!);

// Hash de senha
final hashedPassword = await securityService.hashPassword(password);
final isValid = await securityService.verifyPassword(password, hashedPassword.data!);

// Autenticação biométrica
final authResult = await securityService.authenticateWithBiometrics();
```

## 🔗 Integração com Apps Existentes

### Backward Compatibility
- Todos os services existentes continuam funcionando
- Os novos services são opcionais - apps podem adotar gradualmente
- Interfaces consistentes com padrões existentes (Result<T>)
- Mesma estratégia de error handling (AppError)

### Migration Path
1. **Imediato**: Apps podem usar novos services sem quebrar funcionalidade existente
2. **Gradual**: Migrar services específicos conforme necessário
3. **Futuro**: Deprecar services antigos após migração completa

### Configuração Mínima
```dart
// app/main.dart
import 'package:core/core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inicialização opcional dos services
  final httpService = HttpClientService(baseUrl: 'https://api.myapp.com');
  await httpService.initialize();
  
  final loggingService = EnhancedLoggingService();
  await loggingService.initialize();
  
  runApp(MyApp());
}
```

## 📊 Benefícios da Implementação

### Performance
- **Cache inteligente**: Reduz requests desnecessários
- **Compressão automática**: Otimiza armazenamento
- **Memory management**: Previne memory leaks
- **Async operations**: Não bloqueia UI thread

### Segurança
- **Criptografia transparente**: Protege dados sensíveis
- **Rate limiting**: Previne ataques
- **Input sanitization**: Previne XSS/injection
- **Biometric auth**: Autenticação forte

### Developer Experience
- **Consistent APIs**: Mesmo padrão em todos services
- **Rich error handling**: Errors tipados e detalhados
- **Comprehensive logging**: Debug facilitado
- **Type safety**: Leveraging Dart's type system

### Maintainability  
- **Single source of truth**: Funcionalidades centralizadas
- **Modular design**: Services independentes
- **Clean architecture**: Separação clara de responsabilidades
- **Testable code**: Interfaces mockáveis

## 🛠️ Services Prioritários por App

### Para Apps com Autenticação
- `EnhancedSecurityService`: Biometria + criptografia
- `ValidationService`: Validação de forms de login
- `EnhancedStorageService`: Tokens seguros

### Para Apps com Conectividade Crítica
- `HttpClientService`: Requests confiáveis  
- `EnhancedConnectivityService`: Monitoring de rede
- `EnhancedLoggingService`: Debug de network issues

### Para Apps com Mídia
- `EnhancedImageService`: Manipulação de imagens
- `HttpClientService`: Upload/download com progress

### Para Apps Offline-First
- `EnhancedStorageService`: Cache inteligente
- `EnhancedConnectivityService`: Sync quando online
- `EnhancedLoggingService`: Debug offline

## 📋 Próximos Passos

1. **Teste em ambiente de desenvolvimento** com um app piloto
2. **Gather feedback** da equipe sobre APIs e funcionalidades  
3. **Performance testing** com dados reais
4. **Gradual rollout** para outros apps do monorepo
5. **Monitoring e métricas** de adoption

## 📞 Suporte

Para dúvidas sobre implementação ou migration:
- Consulte os examples nos próprios arquivos dos services
- Verifique logs detalhados com `EnhancedLoggingService`
- Use o sistema de error handling padronizado (`Result<T>`)

---

*Implementado como parte da expansão do core package - Versão 1.0*
*Compatível com todos os apps existentes no monorepo*