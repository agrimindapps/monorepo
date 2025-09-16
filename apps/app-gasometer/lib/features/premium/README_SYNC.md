# Premium Subscription Sync - GasOMeter

Implementação avançada de sincronização cross-device para assinaturas premium no app-gasometer, baseada na análise do app-receituagro.

## 🚀 Melhorias Implementadas

### 1. **Webhook Processing**
- **Arquivo**: `data/datasources/premium_webhook_data_source.dart`
- **Funcionalidade**: Processa webhooks do RevenueCat em tempo real
- **Eventos Suportados**:
  - INITIAL_PURCHASE, RENEWAL, CANCELLATION
  - EXPIRATION, UNCANCELLATION, BILLING_ISSUE
  - SUBSCRIBER_ALIAS (migração de usuários)

### 2. **Firebase Sync**
- **Arquivo**: `data/datasources/premium_firebase_data_source.dart`
- **Funcionalidade**: Sincronização cross-device via Firebase
- **Features**:
  - Real-time listeners para mudanças
  - Cache distribuído com TTL
  - Resolução de conflitos automática
  - Sincronização periódica (15 min)

### 3. **Advanced Sync Service**
- **Arquivo**: `data/services/premium_sync_service.dart`
- **Funcionalidade**: Orquestra múltiplas fontes de dados
- **Features**:
  - Combinação RevenueCat + Firebase + Webhooks
  - Debounce para evitar múltiplas atualizações
  - Retry logic com backoff exponencial
  - Stream de eventos para monitoramento

### 4. **Enhanced Repository**
- **Arquivo**: `data/repositories/premium_repository_impl.dart`
- **Melhorias**:
  - Integração com PremiumSyncService
  - Métodos para força sincronização
  - Stream de eventos de sincronização
  - Processamento de webhooks

### 5. **UI Improvements**
- **Arquivo**: `presentation/widgets/premium_sync_status_widget.dart`
- **Features**:
  - Widget para monitorar sincronização
  - Indicador compacto para AppBar
  - Status em tempo real
  - Botão de sincronização manual

## 🏗️ Arquitetura

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   RevenueCat    │    │    Firebase     │    │    Webhooks     │
│   DataSource    │    │   DataSource    │    │   DataSource    │
└─────────┬───────┘    └─────────┬───────┘    └─────────┬───────┘
          │                      │                      │
          └──────────┬───────────┴──────────────────────┘
                     │
         ┌───────────▼───────────┐
         │  PremiumSyncService   │
         │  - Conflict Resolution │
         │  - Retry Logic        │
         │  - Event Streaming    │
         └───────────┬───────────┘
                     │
         ┌───────────▼───────────┐
         │ PremiumRepositoryImpl │
         └───────────┬───────────┘
                     │
         ┌───────────▼───────────┐
         │   PremiumProvider     │
         │   (UI Layer)          │
         └───────────────────────┘
```

## 🔄 Fluxo de Sincronização

### 1. **Inicialização**
1. Usuário faz login
2. Sync service carrega cache do Firebase
3. Inicia listeners para RevenueCat + Firebase
4. Força sync inicial

### 2. **Atualização em Tempo Real**
1. RevenueCat detecta mudança → Stream update
2. Firebase detecta mudança → Stream update
3. Webhook recebido → Schedule force sync
4. Sync service resolve conflitos
5. UI é notificada via Provider

### 3. **Resolução de Conflitos**
**Prioridade**: RevenueCat > Firebase > Local
- RevenueCat sempre tem prioridade máxima
- Firebase usado quando RevenueCat indisponível
- Local apenas como fallback

### 4. **Error Handling**
- Retry automático (3x) com backoff exponencial
- Fallback para cache local/Firebase
- Logs detalhados para debug
- Recovery automático em caso de conectividade

## 📱 Como Usar

### No Provider
```dart
// Força sincronização
await premiumProvider.syncAcrossDevices();

// Monitora status de sync
StreamBuilder<String>(
  stream: premiumProvider.syncStatus,
  builder: (context, snapshot) {
    return Text(snapshot.data ?? 'Sincronizado');
  },
);
```

### Na UI
```dart
// Widget completo de status
PremiumSyncStatusWidget()

// Indicador compacto
PremiumSyncIndicator()

// Status compacto
PremiumSyncStatusWidget(compact: true)
```

### Para Debug
```dart
// Inicializar debug
await DebugPremiumSync.init();

// Executar testes
await DebugPremiumSync.runQuickTest();

// Monitorar eventos
DebugPremiumSync.startEventMonitoring();

// Status atual
DebugPremiumSync.printCurrentStatus();
```

## 🧪 Testes

### Teste Rápido
```dart
await DebugPremiumSync.runQuickTest();
```

### Teste Completo
```dart
await DebugPremiumSync.runCompleteTest();
```

### Testes Específicos
```dart
DebugPremiumSync.testSpecificFeatures();
DebugPremiumSync.printCurrentStatus();
```

## 🔧 Configuração

### 1. **Dependency Injection**
Certifique-se de que os novos serviços estão registrados em `injection_container.dart`:

```dart
import '../../features/premium/data/datasources/premium_firebase_data_source.dart';
import '../../features/premium/data/datasources/premium_webhook_data_source.dart';
import '../../features/premium/data/services/premium_sync_service.dart';
```

### 2. **Firebase Rules**
Configure regras do Firebase para a collection `user_subscriptions`:

```javascript
match /user_subscriptions/{userId} {
  allow read, write: if request.auth != null && request.auth.uid == userId;
}
```

### 3. **RevenueCat Webhooks**
Configure webhook endpoint para processar eventos:
- URL: `your-api.com/webhooks/revenuecat`
- Events: `INITIAL_PURCHASE`, `RENEWAL`, `CANCELLATION`, etc.

## 📊 Monitoramento

### Eventos de Sync
O sistema emite eventos que podem ser monitorados:
- `UserLoggedIn` / `UserLoggedOut`
- `StatusUpdated` (com fonte)
- `WebhookReceived`
- `SyncStarted` / `SyncCompleted` / `SyncFailed`
- `RetryScheduled`

### Métricas de Debug
- Status atual (isPremium, fonte, expiração)
- Acesso a funcionalidades específicas
- Limites de uso (veículos, abastecimentos)
- Histórico de sincronizações

## 🛡️ Segurança

### Validação de Webhooks
```dart
bool isValid = webhookDataSource.validateWebhook(
  payload: payload,
  signature: headers['signature'],
  secret: revenueCatSecret,
);
```

### Cache Seguro
- TTL de 30 minutos para cache premium
- Invalidação automática em caso de expiração
- Criptografia via core package (se disponível)

## 🔍 Debugging

### Logs Estruturados
```
[PremiumSyncService] RevenueCat atualizado: true
[FirebaseDataSource] Status sincronizado para user123
[WebhookDataSource] Assinatura ativada para user123
```

### Stream de Eventos
Monitore em tempo real o que está acontecendo:
```dart
_syncService.syncEvents.listen((event) {
  print('Sync Event: ${event.runtimeType}');
});
```

## 📈 Performance

### Otimizações Implementadas
- **Debounce**: Evita múltiplas atualizações (2s)
- **Cache Local**: Reduz calls para Firebase
- **Lazy Loading**: Serviços inicializados sob demanda
- **Stream Reuse**: Reutiliza conexões existentes

### Métricas
- Sync latency: < 2s (típico)
- Cache hit rate: > 80% (esperado)
- Error recovery: < 30s (máximo)

## 🚦 Estados de Sincronização

| Estado | Descrição | Ação |
|--------|-----------|------|
| `Sincronizado` | Dados atualizados | Nenhuma |
| `Sincronizando...` | Update em progresso | Aguardar |
| `Erro na sincronização` | Falha temporária | Retry automático |
| `Atualização recebida` | Webhook processado | Atualizar UI |

## 💡 Próximos Passos

1. **Analytics**: Métricas de usage das funcionalidades premium
2. **A/B Testing**: Diferentes strategies de sync
3. **Offline Support**: Queue de operações offline
4. **Push Notifications**: Notificar mudanças críticas
5. **Admin Dashboard**: Monitoramento centralized

---

**Desenvolvido com base na análise do app-receituagro e melhores práticas de sincronização cross-device.**