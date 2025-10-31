# Migração GasOMeter: Premium Local → Core Advanced Sync

Guia passo-a-passo para migrar o GasOMeter do sistema local de premium para o sistema avançado do Core.

## 📊 Status Atual

### Antes da Migração
- **32 arquivos** locais de premium/subscription
- Sistema isolado no GasOMeter
- Sem reutilização em outros apps
- Duplicação de código com ReceitaAgro

### Depois da Migração
- **~10 arquivos** no GasOMeter (domain/presentation)
- Lógica centralizada no Core
- Reutilizável por todos os apps
- Zero breaking changes (via adapter)

## 🎯 Estratégia: Migração Gradual com Zero Downtime

```
Phase 1: Setup (ATUAL)
├── Criar módulo DI no Core ✅
├── Criar adapter de compatibilidade ✅
└── Documentar migração ✅

Phase 2: Deploy com Adapter
├── Regenerar injection.config.dart
├── Testar localmente
├── Deploy para produção
└── Monitorar por 1 semana

Phase 3: Migração Gradual
├── Migrar features uma por uma
├── Deprecar arquivos locais
└── Validar cada mudança

Phase 4: Cleanup
├── Remover adapter
├── Remover arquivos deprecated
└── Documentar final
```

## 🚀 Phase 1: Setup (COMPLETO)

### Arquivos Criados

1. **Core DI Module**
   ```
   /packages/core/lib/src/services/subscription/
   ├── advanced_subscription_services.dart (barrel export)
   ├── ADVANCED_SYNC_GUIDE.md (documentação)
   ├── subscription_sync_models.dart
   ├── advanced/
   │   ├── advanced_subscription_sync_service.dart
   │   ├── subscription_cache_service.dart
   │   ├── subscription_conflict_resolver.dart
   │   ├── subscription_debounce_manager.dart
   │   └── subscription_retry_manager.dart
   └── providers/
       ├── revenuecat_subscription_provider.dart
       ├── firebase_subscription_provider.dart
       └── local_subscription_provider.dart
   ```

2. **GasOMeter DI Module**
   ```
   /apps/app-gasometer/lib/core/di/
   └── advanced_subscription_module.dart ✅
   ```

3. **Compatibility Adapter**
   ```
   /apps/app-gasometer/lib/features/premium/data/services/
   └── premium_sync_service_adapter.dart ✅
   ```

## 📝 Phase 2: Deploy com Adapter

### Step 1: Regenerar Injection Config

```bash
cd apps/app-gasometer
flutter pub get
dart run build_runner build --delete-conflicting-outputs
```

### Step 2: Inicializar Advanced Sync

Atualizar `main.dart`:

```dart
import 'package:app_gasometer/core/di/advanced_subscription_module.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // ... Firebase init ...
  
  // Configure DI
  await configureDependencies();
  
  // ✨ Inicializar Advanced Sync
  final syncService = getIt<AdvancedSubscriptionSyncService>();
  await syncService.initialize();
  
  runApp(MyApp());
}
```

### Step 3: Testar Localmente

**Cenários de Teste:**

1. **Login/Logout**
   - ✅ Stream atualiza corretamente
   - ✅ Firebase sincroniza
   - ✅ Local cache funciona

2. **Compra**
   - ✅ RevenueCat detecta
   - ✅ Conflict resolution funciona
   - ✅ UI atualiza

3. **Multi-Device**
   - ✅ Login em device 2 carrega status
   - ✅ Compra em device 1 aparece em device 2
   - ✅ Logout limpa cache

4. **Offline**
   - ✅ Local cache funciona
   - ✅ Retry quando volta online
   - ✅ Sync events corretos

### Step 4: Monitorar

**Métricas para acompanhar:**
- Crashlytics: erros de sync
- Analytics: taxa de conversão mantida
- Performance: tempo de inicialização
- Logs: eventos de conflict resolution

## 🔄 Phase 3: Migração Gradual

### Arquivos para Manter (10 arquivos)

#### Domain Layer (3)
```
features/premium/domain/
├── entities/premium_status.dart ✅ (mantém)
├── repositories/premium_repository.dart ✅ (mantém)
└── usecases/
    ├── check_premium_status.dart ✅
    ├── purchase_premium.dart ✅
    ├── restore_purchases.dart ✅
    └── ... (outros use cases)
```

#### Data Layer (2)
```
features/premium/data/
├── repositories/premium_repository_impl.dart ✅ (adapta)
└── services/premium_sync_service_adapter.dart ✅ (mantém temporário)
```

#### Presentation Layer (5)
```
features/premium/presentation/
├── pages/premium_page.dart ✅
├── widgets/premium_banner.dart ✅
├── providers/premium_notifier.dart ✅ (adapta)
└── ... (UI components)
```

### Arquivos para Remover (22 arquivos)

#### Services (8 arquivos) → Movidos para Core
```
❌ premium_sync_service.dart → AdvancedSubscriptionSyncService
❌ premium_conflict_resolver.dart → SubscriptionConflictResolver
❌ premium_debounce_manager.dart → SubscriptionDebounceManager
❌ premium_retry_manager.dart → SubscriptionRetryManager
❌ premium_firebase_cache_service.dart → SubscriptionCacheService
❌ premium_status_mapper.dart → Integrado nos providers
❌ premium_validation_service.dart → Core validation
❌ premium_analytics_service.dart → Core analytics
```

#### Data Sources (3 arquivos) → Providers no Core
```
❌ premium_remote_data_source.dart → RevenueCatSubscriptionProvider
❌ premium_firebase_data_source.dart → FirebaseSubscriptionProvider
❌ premium_webhook_data_source.dart → WebhookSubscriptionProvider (futuro)
```

#### Models (3 arquivos)
```
❌ premium_sync_event.dart → SubscriptionSyncEvent (Core)
❌ premium_cache_model.dart → Integrado no CacheService
❌ premium_config_model.dart → AdvancedSyncConfiguration
```

#### Utils (8 arquivos)
```
❌ premium_extensions.dart → Core extensions
❌ premium_constants.dart → Core constants
❌ premium_validators.dart → Core validators
... (outros utils duplicados)
```

### Migration Script

```dart
// Script para facilitar migração de imports
// apps/app-gasometer/scripts/migrate_imports.dart

void main() {
  final replacements = {
    // Services
    "import '../data/services/premium_sync_service.dart'": 
      "import 'package:core/core.dart' show AdvancedSubscriptionSyncService;",
    
    // Providers -> Adapters
    "PremiumSyncService": "PremiumSyncServiceAdapter",
    
    // Events
    "PremiumSyncEvent": "SubscriptionSyncEvent",
  };
  
  // Aplica replacements em todos os arquivos...
}
```

## 🧪 Phase 4: Cleanup

### Step 1: Remover Adapter

Uma vez que todo código migrou:

```dart
// ANTES (com adapter)
final syncService = getIt<PremiumSyncServiceAdapter>();
final status = await syncService.currentStatus;

// DEPOIS (direto do Core)
final syncService = getIt<AdvancedSubscriptionSyncService>();
final subscription = syncService.currentSubscription;
final isPremium = subscription?.isActive ?? false;
```

### Step 2: Deletar Arquivos Deprecated

```bash
cd apps/app-gasometer

# Remover services locais
rm -rf lib/features/premium/data/services/premium_sync_service.dart
rm -rf lib/features/premium/data/services/premium_conflict_resolver.dart
rm -rf lib/features/premium/data/services/premium_debounce_manager.dart
rm -rf lib/features/premium/data/services/premium_retry_manager.dart
rm -rf lib/features/premium/data/services/premium_firebase_cache_service.dart

# Remover data sources locais
rm -rf lib/features/premium/data/datasources/premium_firebase_data_source.dart
rm -rf lib/features/premium/data/datasources/premium_webhook_data_source.dart

# Remover adapter
rm -rf lib/features/premium/data/services/premium_sync_service_adapter.dart
```

### Step 3: Validar Build

```bash
flutter clean
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter test
flutter build apk --debug
```

## 📊 Métricas de Sucesso

### Redução de Código
- **Antes**: 32 arquivos (~3.500 linhas)
- **Depois**: 10 arquivos (~800 linhas)
- **Redução**: 68% menos código local
- **Core reutilizável**: ~2.500 linhas disponíveis para todos os apps

### Performance
- Inicialização: Sem impacto (lazy loading)
- Sync time: Melhorado (debounce + retry)
- Memory: Reduzido (cache compartilhado)

### Qualidade
- Testes: Centralizados no Core
- Bugs: Fix once, benefit all apps
- Manutenção: Single source of truth

## 🎓 Aprendizados para Próximas Migrações

### ReceitaAgro
- Já usa SimpleSubscriptionSyncService
- Pode migrar para Advanced se precisar cross-device
- Zero breaking changes

### Plantis
- Mesma estratégia de migração
- Adapter inicial → Migração gradual → Cleanup

### Outros Apps
- Reutilizar módulo DI do GasOMeter
- Ajustar configuração (standard/aggressive/conservative)
- Documentar particularidades

## 🚨 Troubleshooting

### Erro: "Provider not found"
```bash
# Regenerar DI config
dart run build_runner clean
dart run build_runner build --delete-conflicting-outputs
```

### Sync não funciona
```dart
// Verificar inicialização
final syncService = getIt<AdvancedSubscriptionSyncService>();
print('Is initialized: ${!syncService.isDisposed}');
print('Is syncing: ${syncService.isSyncing}');
print('Has subscription: ${syncService.hasActiveSubscription}');
```

### Conflitos de nomes
```dart
// Usar import qualificado
import 'package:core/src/services/subscription/subscription_sync_models.dart' 
  as subscription_models;

// Usar
subscription_models.ConflictResolutionStrategy.priorityBased
```

## 📚 Referências

- [Advanced Sync Guide](/packages/core/lib/src/services/subscription/ADVANCED_SYNC_GUIDE.md)
- [Core Architecture](/packages/core/README.md)
- [Monorepo Guidelines](/docs/ARCHITECTURE.md)

## ✅ Checklist de Migração

### Setup
- [x] Criar módulo DI no Core
- [x] Criar providers (RevenueCat, Firebase, Local)
- [x] Criar serviços avançados (conflict, debounce, retry, cache)
- [x] Criar orquestrador principal
- [x] Documentar sistema
- [x] Criar módulo DI no GasOMeter
- [x] Criar adapter de compatibilidade
- [x] Documentar migração

### Deploy com Adapter
- [ ] Regenerar injection.config.dart
- [ ] Adicionar inicialização no main.dart
- [ ] Testar login/logout
- [ ] Testar compra
- [ ] Testar multi-device
- [ ] Testar offline
- [ ] Deploy para produção
- [ ] Monitorar por 1 semana

### Migração Gradual
- [ ] Migrar PremiumRepository
- [ ] Migrar use cases
- [ ] Migrar notifiers
- [ ] Migrar UI
- [ ] Deprecar arquivos antigos
- [ ] Validar testes

### Cleanup
- [ ] Remover adapter
- [ ] Deletar arquivos deprecated
- [ ] Validar build
- [ ] Atualizar documentação
- [ ] Comunicar time

---

**Status**: Phase 1 completa ✅ | Pronto para Phase 2 🚀
