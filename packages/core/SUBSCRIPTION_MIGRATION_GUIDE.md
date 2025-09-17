# Subscription System Migration Guide

Esta documentação guia a migração dos apps do monorepo para usar o sistema unificado de subscription do Core Package.

## 🏗️ Sistema Unificado Criado

### Componentes Principais

1. **SubscriptionModel** (`packages/core/lib/src/domain/models/subscription_model.dart`)
   - Modelo unificado com suporte a sincronização offline-first
   - Compatível com todos os apps do monorepo
   - Integração com Firebase Firestore e cache local

2. **SubscriptionSyncService** (`packages/core/lib/src/services/subscription_sync_service.dart`)
   - Sincronização automática RevenueCat → Firebase → Local Storage
   - Conflict resolution e offline-first strategy
   - Periodic sync e real-time updates

3. **WebhookHandlerService** (`packages/core/lib/src/services/webhook_handler_service.dart`)
   - Processamento padronizado de webhooks do RevenueCat
   - Retry logic e idempotência
   - Rate limiting e security validation

4. **WebhookController & Endpoints**
   - Controllers e endpoints prontos para uso
   - Suporte a múltiplos frameworks (Shelf, Cloud Functions, etc.)
   - CORS, rate limiting e error handling

## 🔄 Migration Steps

### Step 1: Instalar Core Package Dependency

Em cada app (`pubspec.yaml`):

```yaml
dependencies:
  core:
    path: ../../packages/core
```

### Step 2: Atualizar Dependency Injection

Substitua a configuração de subscription existente:

```dart
// ❌ ANTES (app-específico)
sl.registerLazySingleton<ISubscriptionRepository>(
  () => RevenueCatService(),
);

// ✅ DEPOIS (unificado)
import 'package:core/core.dart';

// Registra dependências core
await di.init(); // Chama DI do core package

// Registra services unificados
sl.registerLazySingleton<SubscriptionSyncService>(
  () => SubscriptionSyncService(
    subscriptionRepository: sl<ISubscriptionRepository>(),
    localStorage: sl<ILocalStorageRepository>(),
    syncQueue: sl<SyncQueue>(),
    syncOperations: sl<SyncOperations>(),
  ),
);

sl.registerLazySingleton<WebhookHandlerService>(
  () => WebhookHandlerService(
    subscriptionSyncService: sl<SubscriptionSyncService>(),
    localStorage: sl<ILocalStorageRepository>(),
  ),
);
```

### Step 3: Inicializar Services

No `main.dart` de cada app:

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ... outras inicializações ...

  // Inicializa DI
  await di.init();

  // Inicializa subscription services
  final subscriptionSyncService = sl<SubscriptionSyncService>();
  await subscriptionSyncService.initialize();

  final webhookHandlerService = sl<WebhookHandlerService>();
  await webhookHandlerService.initialize();

  runApp(MyApp());
}
```

### Step 4: Substituir Usage nos Apps

#### Verificar Status da Assinatura

```dart
// ❌ ANTES (app-específico)
final subscriptionRepository = sl<ISubscriptionRepository>();
final result = await subscriptionRepository.getCurrentSubscription();

// ✅ DEPOIS (unificado)
final subscriptionSyncService = sl<SubscriptionSyncService>();

// Método 1: Status atual em cache (offline-first)
final hasActive = subscriptionSyncService.hasActiveSubscription;
final currentSubscription = subscriptionSyncService.currentSubscription;

// Método 2: Verificar para app específico
final result = await subscriptionSyncService.hasActiveSubscriptionForApp('plantis');

// Método 3: Stream reativo
subscriptionSyncService.subscriptionStatus.listen((subscription) {
  // Atualização em tempo real
});
```

#### Forçar Sincronização

```dart
// ✅ Força sincronização completa
final subscriptionSyncService = sl<SubscriptionSyncService>();
final result = await subscriptionSyncService.forceSync();

result.fold(
  (failure) => print('Sync failed: ${failure.message}'),
  (subscription) => print('Sync successful: $subscription'),
);
```

### Step 5: Implementar Webhook Endpoint (Opcional)

Para apps que precisam receber webhooks diretamente:

```dart
// webhook_server.dart
import 'package:core/core.dart';

Future<void> startWebhookServer() async {
  final webhookHandlerService = sl<WebhookHandlerService>();
  final endpoints = WebhookEndpointsFactory.create(
    webhookHandlerService: webhookHandlerService,
  );

  await ExampleWebhookServer.start(
    endpoints: endpoints,
    port: 8080,
  );
}
```

## 📱 App-Specific Migration

### App-Plantis

**Arquivos a serem atualizados:**
- `lib/core/di/injection_container.dart`
- `lib/main.dart`
- Remover subscription logic específico em controllers/providers

### App-ReceitaAgro

**Arquivos a serem atualizados:**
- `lib/core/di/injection_container.dart`
- `lib/main.dart`
- Migrar webhook handling existente

### App-Gasometer

**Status atual:** Não possui sistema de subscription implementado
**Ação:** Implementar usando sistema unificado desde o início

```dart
// Adicionar ao injection_container.dart
sl.registerLazySingleton<SubscriptionSyncService>(() => /* config */);

// Usar nos controllers
final subscriptionService = sl<SubscriptionSyncService>();
final hasSubscription = await subscriptionService.hasActiveSubscriptionForApp('gasometer');
```

### App-TaskOlist, App-PetiVeti, App-AgriHurbi

**Status:** Não possuem subscription implementado
**Ação:** Implementar usando sistema unificado quando necessário

## 🔧 Configuration por App

### Product IDs Mapping

O sistema identifica apps através do `productId`. Configure no RevenueCat:

```
- plantis_premium_monthly
- plantis_premium_yearly
- receituagro_pro_monthly
- receituagro_pro_yearly
- gasometer_premium_monthly
- etc.
```

### Firebase Firestore Structure

```
users/{userId}/subscriptions/{subscriptionId}
{
  "id": "sub_xxx",
  "user_id": "user_xxx",
  "product_id": "plantis_premium_monthly",
  "status": "active",
  "tier": "premium",
  "app_name": "Plantis",
  "expiration_date": "2024-01-01T00:00:00Z",
  // ... outros campos
}
```

## 🧪 Testing

### Unit Tests

```dart
// test/subscription_sync_service_test.dart
void main() {
  group('SubscriptionSyncService', () {
    test('should sync subscription from RevenueCat', () async {
      final service = SubscriptionSyncService(/* dependencies */);
      final result = await service.forceSync();
      expect(result.isRight(), true);
    });
  });
}
```

### Integration Tests

```dart
// integration_test/webhook_test.dart
void main() {
  testWidgets('webhook processing', (tester) async {
    // Simula webhook do RevenueCat
    // Verifica se subscription foi atualizada
    // Verifica se UI refletiu a mudança
  });
}
```

## 📈 Benefits

1. **Consistência**: Todos os apps usam a mesma lógica de subscription
2. **Maintenance**: Bugs fixes e features em um local central
3. **Offline-First**: Funciona sem conexão internet
4. **Real-time**: Updates automáticos via webhooks
5. **Scalability**: Fácil adicionar novos apps
6. **Testing**: Testabilidade melhorada com mocks centralizados

## ⚠️ Breaking Changes

- **Legacy subscription models**: Precisam ser migrados
- **Direct RevenueCat calls**: Devem usar SubscriptionSyncService
- **Custom webhook handling**: Deve usar WebhookHandlerService
- **Local subscription cache**: Substituído pelo sistema unificado

## 🚀 Next Steps

1. ✅ Sistema core implementado
2. ⏳ Migrar app-plantis (primeiro)
3. ⏳ Migrar app-receituagro
4. ⏳ Implementar em app-gasometer
5. ⏳ Testes end-to-end
6. ⏳ Deploy production

---

Este guia será atualizado conforme a implementação progride. Para dúvidas ou problemas durante a migração, consulte os exemplos nos testes unitários dos services.