# Advanced Subscription System - Core

Sistema avançado de sincronização de assinaturas com suporte a múltiplas fontes de dados.

## 📦 Arquitetura

```
AdvancedSubscriptionSyncService (Orquestrador)
├── ISubscriptionDataProvider (Interface)
│   ├── RevenueCatSubscriptionProvider (Priority: 100)
│   ├── FirebaseSubscriptionProvider (Priority: 80)
│   └── LocalSubscriptionProvider (Priority: 40)
├── SubscriptionConflictResolver (5 estratégias)
├── SubscriptionDebounceManager (Throttling)
├── SubscriptionRetryManager (Resilience)
└── SubscriptionCacheService (Performance)
```

## 🚀 Setup Rápido

### 1. Configurar Dependency Injection

```dart
import 'package:core/core.dart';
import 'package:injectable/injectable.dart';

@module
abstract class SubscriptionModule {
  @lazySingleton
  AdvancedSubscriptionSyncService advancedSyncService(
    ISubscriptionRepository subscriptionRepository,
    FirebaseFirestore firestore,
    IAuthRepository authRepository,
    SharedPreferences sharedPreferences,
  ) {
    // Create providers
    final revenueCatProvider = RevenueCatSubscriptionProvider(
      subscriptionRepository: subscriptionRepository,
    );
    
    final firebaseProvider = FirebaseSubscriptionProvider(
      firestore: firestore,
      authRepository: authRepository,
    );
    
    final localProvider = LocalSubscriptionProvider(
      sharedPreferences: sharedPreferences,
    );
    
    // Create support services
    final conflictResolver = SubscriptionConflictResolver(
      strategy: ConflictResolutionStrategy.priorityBased,
    );
    
    final debounceManager = SubscriptionDebounceManager();
    final retryManager = SubscriptionRetryManager();
    final cacheService = SubscriptionCacheService();
    
    // Create sync service
    return AdvancedSubscriptionSyncService(
      providers: [revenueCatProvider, firebaseProvider, localProvider],
      configuration: AdvancedSyncConfiguration.standard,
      conflictResolver: conflictResolver,
      debounceManager: debounceManager,
      retryManager: retryManager,
      cacheService: cacheService,
    );
  }
}
```

### 2. Inicializar

```dart
final syncService = getIt<AdvancedSubscriptionSyncService>();
await syncService.initialize();
```

### 3. Usar

```dart
// Listen to subscription changes
syncService.subscriptionStream.listen((subscription) {
  if (subscription?.isActive ?? false) {
    print('User has premium!');
  } else {
    print('User is free');
  }
});

// Force sync
await syncService.forceSync();

// Check status
final hasActive = syncService.hasActiveSubscription;

// Monitor sync events
syncService.syncEvents.listen((event) {
  if (event is SyncCompleted) {
    print('Sync completed from: ${event.source}');
  }
});
```

## ⚙️ Configurações

### Standard (Balanced)
```dart
AdvancedSyncConfiguration.standard
// - Debounce: 2s
// - Max retries: 3
// - Sync interval: 30min
// - Log level: info
```

### Aggressive (Frequent sync)
```dart
AdvancedSyncConfiguration.aggressive
// - No debounce
// - Max retries: 5
// - Sync interval: 10min
// - Log level: debug
```

### Conservative (Battery saving)
```dart
AdvancedSyncConfiguration.conservative
// - Debounce: 5s
// - Max retries: 2
// - Sync interval: 1h
// - Log level: warning
```

### Custom
```dart
AdvancedSyncConfiguration(
  conflictStrategy: ConflictResolutionStrategy.timestampBased,
  enableDebounce: true,
  debounceDuration: Duration(seconds: 3),
  enableRetry: true,
  maxRetryAttempts: 4,
  retryBackoffMultiplier: 2.5,
  enablePeriodicSync: true,
  syncInterval: Duration(minutes: 20),
  enableOfflineSupport: true,
  logLevel: SubscriptionSyncLogLevel.debug,
)
```

## 🔄 Estratégias de Resolução de Conflitos

### priorityBased (Padrão)
Fonte com maior prioridade vence:
- RevenueCat (100) → fonte da verdade
- Firebase (80) → cross-device sync
- Local (40) → fallback offline

### timestampBased
Subscription com `updatedAt` mais recente vence.

### mostPermissive
Se qualquer fonte diz premium, considera premium.

### mostRestrictive
Só considera premium se TODAS as fontes confirmarem.

### manualOverride
App implementa lógica customizada.

## 📊 Prioridades dos Providers

| Provider | Priority | Uso Principal | Latência |
|----------|----------|---------------|----------|
| RevenueCat | 100 | In-app purchases | Baixa |
| Firebase | 80 | Cross-device sync | Média |
| Local | 40 | Offline fallback | Instantâneo |

## 🎯 Benefícios

### Multi-Source Sync
- ✅ RevenueCat: fonte da verdade para purchases
- ✅ Firebase: sincronização cross-device em tempo real
- ✅ Local: suporte offline com cache

### Resiliência
- ✅ Retry automático com backoff exponencial
- ✅ Debounce para evitar sync excessivo
- ✅ Fallback para cache em caso de erro

### Performance
- ✅ Cache em memória com TTL
- ✅ Distinct stream (evita emissões duplicadas)
- ✅ Lazy initialization dos providers

### Observabilidade
- ✅ Stream de eventos de sync
- ✅ Logs configuráveis (none/error/warning/info/debug)
- ✅ Tracking de retry attempts

## 📱 Quando Usar?

### Use Advanced Sync Se:
- ✅ Precisa sincronização cross-device
- ✅ Tem múltiplos pontos de entrada (app + webhooks)
- ✅ Necessita alta resiliência
- ✅ Quer observabilidade detalhada

### Use Simple Sync Se:
- ✅ App simples com uma fonte (RevenueCat)
- ✅ Não precisa cross-device
- ✅ Quer simplicidade

## 🔧 Troubleshooting

### Ver logs detalhados
```dart
AdvancedSyncConfiguration(
  logLevel: SubscriptionSyncLogLevel.debug,
)
```

### Forçar sync manual
```dart
await syncService.forceSync();
```

### Verificar providers ativos
```dart
final enabled = syncService.enabledProviders;
print('Active providers: ${enabled.map((p) => p.name).join(", ")}');
```

### Monitorar sync events
```dart
syncService.syncEvents.listen((event) {
  switch (event) {
    case SyncStarted():
      print('Sync iniciado');
    case SyncCompleted(:final source):
      print('Sync completo: $source');
    case SyncFailed(:final error):
      print('Sync falhou: $error');
    case Updated(:final newSubscription, :final source):
      print('Atualizado de $source: ${newSubscription?.isActive}');
  }
});
```

## 📄 Próximos Passos

1. **Migrar GasOMeter**: Substituir serviços locais por Core
2. **Testar Multi-Device**: Validar sync cross-device
3. **Adicionar Webhook Provider**: Para notificações de pagamento
4. **Métricas**: Instrumentar com Firebase Analytics
5. **Testes**: Unit tests para conflict resolution

## 💡 Exemplos de Apps

### App Simples (ReceitaAgro)
```dart
// Continua usando SimpleSubscriptionSyncService
// Sem mudanças necessárias
```

### App Avançado (GasOMeter)
```dart
// Migrar para AdvancedSubscriptionSyncService
// Beneficia de multi-source sync + retry + debounce
```

### App Enterprise (Futuro)
```dart
// Adicionar WebhookSubscriptionProvider
// Estratégia: mostRestrictive (segurança máxima)
// Configuração: conservative (economia de bateria)
```
