# Implementação de In-App Purchase - Plantis

**Documento de Análise e Roadmap de Implementação**
**Versão:** 1.0
**Data:** 07 de Outubro de 2025
**Status:** Em Desenvolvimento

---

## 📋 Índice

1. [Visão Geral](#visão-geral)
2. [Arquitetura Atual](#arquitetura-atual)
3. [Estado da Implementação](#estado-da-implementação)
4. [Funcionalidades Implementadas](#funcionalidades-implementadas)
5. [Gaps e Pendências](#gaps-e-pendências)
6. [Features Premium Específicas](#features-premium-específicas)
7. [Integração Firebase](#integração-firebase)
8. [Fluxo de Compra](#fluxo-de-compra)
9. [Sincronização Cross-Device](#sincronização-cross-device)
10. [Recomendações de Excelência](#recomendações-de-excelência)
11. [Roadmap de Implementação](#roadmap-de-implementação)
12. [Configuração e Setup](#configuração-e-setup)
13. [Atualizações e Tarefas](#atualizações-e-tarefas)

---

## 🎯 Visão Geral

O **Plantis Premium** é um sistema de assinatura in-app que desbloqueia recursos avançados para usuários do aplicativo de cuidado de plantas. A implementação utiliza **RevenueCat** como plataforma de gerenciamento de assinaturas e **Firebase** para sincronização cross-device.

### Objetivos

- ✅ Oferecer experiência premium com recursos avançados
- ✅ Sincronização automática entre dispositivos do mesmo usuário
- ✅ Suporte para múltiplas plataformas (iOS/Android)
- ✅ Analytics detalhado de conversão e uso
- ✅ Gerenciamento centralizado de assinaturas

### Stack Tecnológica

- **RevenueCat SDK**: `purchases_flutter ^9.2.1`
- **Firebase**: Firestore, Analytics, Auth
- **State Management**: Riverpod + ChangeNotifier (Provider legado)
- **Architecture**: Clean Architecture + Repository Pattern

---

## 🏗️ Arquitetura Atual

### Estrutura de Diretórios

```
apps/app-plantis/
├── lib/
│   ├── features/
│   │   ├── premium/                          # Feature completa de Premium
│   │   │   ├── data/
│   │   │   │   └── services/
│   │   │   │       └── subscription_sync_service.dart  # Sincronização Firebase
│   │   │   └── presentation/
│   │   │       ├── pages/
│   │   │       │   └── premium_subscription_page.dart  # Página principal
│   │   │       ├── providers/
│   │   │       │   └── premium_provider.dart           # State management
│   │   │       ├── notifiers/
│   │   │       │   └── premium_notifier.dart           # Riverpod notifiers
│   │   │       └── widgets/
│   │   │           ├── subscription_benefits_widget.dart
│   │   │           ├── subscription_plans_widget.dart
│   │   │           ├── payment_actions_widget.dart
│   │   │           └── sync_status_widget.dart
│   │   └── settings/                         # Configurações com link para Premium
│   │       └── presentation/
│   │           └── pages/
│   │               └── settings_page.dart    # Seção Premium em destaque
│   └── shared/
│       └── widgets/
│           └── premium_subscription_card.dart # Card reutilizável
│
packages/core/
└── lib/
    └── src/
        ├── domain/
        │   ├── entities/
        │   │   └── subscription_entity.dart           # Entidade compartilhada
        │   └── repositories/
        │       └── i_subscription_repository.dart     # Interface do repositório
        ├── infrastructure/
        │   └── services/
        │       ├── revenue_cat_service.dart           # Implementação RevenueCat
        │       └── revenuecat_cancellation_service.dart
        ├── riverpod/
        │   └── domain/
        │       └── premium/
        │           └── subscription_providers.dart     # Providers Riverpod
        └── services/
            ├── subscription_sync_service.dart         # Sync genérico
            └── simple_subscription_sync_service.dart  # Sync simplificado
```

### Camadas da Arquitetura

#### 1. **Domain Layer** (packages/core)

**Entidade Principal: `SubscriptionEntity`**

```dart
class SubscriptionEntity {
  final String id;
  final String productId;
  final SubscriptionStatus status;  // active, expired, cancelled, etc.
  final SubscriptionTier tier;      // free, premium, pro
  final DateTime? expirationDate;
  final DateTime? purchaseDate;
  final Store store;                // appStore, playStore
  final bool isInTrial;
  final bool isSandbox;

  // Propriedades computadas
  bool get isActive;
  bool get isExpired;
  bool get isTrialActive;
  int? get daysRemaining;
}
```

**Repository Interface: `ISubscriptionRepository`**

Métodos principais:
- `hasActiveSubscription()` - Verifica se há assinatura ativa
- `getCurrentSubscription()` - Obtém assinatura atual
- `purchaseProduct()` - Inicia compra
- `restorePurchases()` - Restaura compras anteriores
- `getAvailableProducts()` - Lista produtos disponíveis
- `getPlantisProducts()` - Produtos específicos do Plantis

#### 2. **Infrastructure Layer** (packages/core)

**RevenueCat Service**

Implementação completa do repositório usando SDK do RevenueCat:
- Configuração automática por ambiente
- Suporte web (disabled automaticamente)
- Listeners para atualizações em tempo real
- Mapeamento de erros específicos

**Subscription Sync Service**

Serviço avançado de sincronização:
- Sync cross-device com conflict resolution
- Processamento de webhooks RevenueCat
- Atualização de features específicas do Plantis
- Versionamento de sincronização

#### 3. **Presentation Layer** (app-plantis)

**PremiumSubscriptionPage**

Página principal com design inspirado no ReceitaAgro:
- Header com gradiente verde Plantis
- View para usuários premium (status ativo)
- View para não-assinantes (seleção de planos)
- Loading states gerenciados
- Snackbars para feedback

**Widgets Especializados**

1. **SubscriptionPlansWidget**: Exibição de planos disponíveis
2. **SubscriptionBenefitsWidget**: Lista de benefícios premium
3. **PaymentActionsWidget**: Botões de ação (comprar, restaurar)
4. **SyncStatusWidget**: Status de sincronização

---

## ✅ Estado da Implementação

### Funcionalidades 100% Implementadas

#### ✅ 1. Integração com RevenueCat

**Status:** Completo
**Localização:** `packages/core/lib/src/infrastructure/services/revenue_cat_service.dart`

- [x] Configuração automática do SDK
- [x] Detecção de ambiente (web/mobile)
- [x] Login de usuários no RevenueCat
- [x] Listeners de atualização em tempo real
- [x] Tratamento de erros específicos
- [x] Suporte a sandbox/produção

#### ✅ 2. UI de Assinatura

**Status:** Completo
**Localização:** `apps/app-plantis/lib/features/premium/presentation/pages/premium_subscription_page.dart`

- [x] Design moderno com gradiente Plantis
- [x] Separação visual premium vs free
- [x] Seleção de planos interativa
- [x] Lista de benefícios premium
- [x] Botões de ação (comprar/restaurar)
- [x] Loading states
- [x] Mensagens de feedback

#### ✅ 3. Acesso via Settings

**Status:** Completo
**Localização:** `apps/app-plantis/lib/features/settings/presentation/pages/settings_page.dart:249`

- [x] Card Premium em destaque na página de configurações
- [x] Gradiente visual atrativo
- [x] Navegação para página de assinatura
- [x] Ícone premium destacado

#### ✅ 4. State Management

**Status:** Completo (dual implementation)
**Localização:** `apps/app-plantis/lib/features/premium/presentation/providers/`

- [x] Provider legado (ChangeNotifier) funcional
- [x] Riverpod providers modernos
- [x] Estados de loading/error/success
- [x] Streams reativas de assinatura

#### ✅ 5. Sincronização Firebase

**Status:** Avançado (85%)
**Localização:** `apps/app-plantis/lib/features/premium/data/services/subscription_sync_service.dart`

- [x] Sincronização cross-device
- [x] Conflict resolution automático
- [x] Versionamento de sync
- [x] Histórico de sincronizações
- [x] Analytics de eventos
- [x] Processamento de webhooks RevenueCat

**Eventos Suportados:**
- INITIAL_PURCHASE
- RENEWAL
- CANCELLATION
- UNCANCELLATION
- EXPIRATION
- BILLING_ISSUE
- PRODUCT_CHANGE

### Funcionalidades Parcialmente Implementadas

#### ⚠️ 6. Features Premium Específicas

**Status:** 70% Implementado
**Pendências:**
- [ ] Implementação completa de plant identification
- [ ] Disease diagnosis integration
- [ ] Weather-based notifications
- [ ] Advanced analytics dashboard

**Implementado:**
```dart
List<String> premiumFeatures = [
  'unlimited_plants',           // ✅
  'advanced_reminders',         // ✅
  'export_data',                // ✅
  'custom_themes',              // ⚠️ Parcial
  'cloud_backup',               // ✅
  'detailed_analytics',         // ⚠️ Parcial
  'plant_identification',       // ❌ Não implementado
  'disease_diagnosis',          // ❌ Não implementado
  'weather_based_notifications',// ❌ Não implementado
  'care_calendar',              // ✅
  'plant_health_alerts',        // ✅
];
```

#### ⚠️ 7. Gerenciamento de Assinatura

**Status:** Placeholder (0%)
**Localização:** `premium_subscription_page.dart:310`

```dart
Future<void> _manageSubscription(PremiumProvider provider) async {
  _showInfoSnackBar('Redirecionando para gerenciamento...');
  // TODO: Implementar redirecionamento para App Store/Play Store
}
```

**Necessário:**
- [ ] URL de gerenciamento iOS (App Store)
- [ ] URL de gerenciamento Android (Play Console)
- [ ] Deep linking para páginas de assinatura

---

## 🚀 Funcionalidades Implementadas

### 1. Compra de Assinatura

**Fluxo Completo:**

```
Usuário → Seleciona Plano → purchaseProduct() →
RevenueCat SDK → App Store/Play Store → Confirmação →
Firebase Sync → Atualização UI
```

**Código:** `premium_subscription_page.dart:257-281`

**Features:**
- Loading contextual durante compra
- Validação de plano selecionado
- Feedback visual de sucesso/erro
- Atualização automática do estado

### 2. Restauração de Compras

**Fluxo:**

```
Usuário → Clica "Restaurar" → restorePurchases() →
RevenueCat verifica compras anteriores → Firebase Sync →
Atualização UI com status
```

**Código:** `premium_subscription_page.dart:283-308`

**Features:**
- Busca todas as compras do usuário
- Sincronização automática
- Mensagem diferenciada (encontrou/não encontrou)

### 3. Sincronização Cross-Device

**Arquitetura de Sync:**

```
Device A compra → RevenueCat → Firebase Cloud Functions (webhook) →
Firebase Firestore atualiza → Device B recebe atualização em tempo real
```

**Implementação:** `subscription_sync_service.dart`

**Características:**
- Conflict resolution (strategy: latest timestamp)
- Transações atômicas no Firebase
- Histórico completo de sincronizações
- Retry logic com backoff exponencial
- Stream reativo de eventos

**Coleções Firebase:**

```
users/{userId}/
├── subscriptions/
│   └── current/               # Status atual da assinatura
├── devices/
│   └── {deviceId}/            # Informações por dispositivo
├── sync_metadata/
│   └── version/               # Controle de versão
└── settings/
    ├── plant_limits/          # Limites premium/free
    ├── premium_features/      # Features habilitadas
    ├── notifications/         # Configurações de notificações
    └── cloud_backup/          # Configurações de backup

subscription_history/
└── {historyId}/               # Histórico de todas as sincronizações

purchase_events/
└── {eventId}/                 # Analytics de compras
```

### 4. Analytics

**Eventos Rastreados:**

```dart
// Eventos de Sincronização
'plantis_subscription_sync_started'
'plantis_subscription_sync_completed'
'plantis_sync_error'

// Eventos de Compra
'plantis_purchase_completed'
'plantis_initial_purchase'
'plantis_subscription_renewal'
'plantis_subscription_cancellation'

// Eventos de Conflito
'plantis_device_conflicts_detected'
'plantis_conflict_resolved'

// Eventos de Features
'plantis_features_processed'
'plantis_features_processing_failed'
```

### 5. Gestão de Limites Premium vs Free

**Limites por Tier:**

```dart
// FREE TIER
const freeLimits = {
  'plants': 5,                    // Máximo 5 plantas
  'care_reminders': 10,           // 10 lembretes
  'photo_storage': 20,            // 20 fotos
  'plant_identification': 3,      // 3 identificações/mês
  'custom_categories': false,
  'export_data': false,
  'cloud_backup': false,
};

// PREMIUM TIER
const premiumLimits = {
  'plants': -1,                   // Ilimitado
  'care_reminders': -1,           // Ilimitado
  'photo_storage': -1,            // Ilimitado
  'plant_identification': -1,     // Ilimitado
  'custom_categories': true,
  'export_data': true,
  'cloud_backup': true,
};
```

**Sincronização Automática:**

Quando status muda, o `SubscriptionSyncService` atualiza automaticamente:
- `_updatePlantLimits()`: Atualiza limites de plantas
- `_updatePremiumFeatures()`: Habilita/desabilita features
- `_enableAdvancedNotifications()`: Configura notificações avançadas
- `_configurePlantisCloudBackup()`: Ativa backup em nuvem

---

## ❌ Gaps e Pendências

### 🔴 Críticos (Impedem uso completo)

#### 1. Gerenciamento de Assinatura

**Problema:** Usuários não conseguem gerenciar/cancelar assinaturas pelo app

**Impacto:** Alto - Requisito da Apple/Google

**Solução Necessária:**

```dart
Future<void> _manageSubscription(PremiumProvider provider) async {
  final url = await _subscriptionRepository.getManagementUrl();

  url.fold(
    (failure) => _showErrorSnackBar('Erro ao abrir gerenciamento'),
    (managementUrl) async {
      if (managementUrl != null) {
        if (await canLaunchUrl(Uri.parse(managementUrl))) {
          await launchUrl(Uri.parse(managementUrl));
        }
      }
    },
  );
}
```

**Arquivos Afetados:**
- `premium_subscription_page.dart:310`
- `revenue_cat_service.dart` (adicionar implementação)

#### 2. Política de Privacidade e Termos de Uso

**Problema:** Links não implementados (placeholders apenas)

**Impacto:** Alto - Requisito legal e das lojas

**Solução Necessária:**

```dart
// Criar páginas ou URLs
const privacyPolicyUrl = 'https://plantis.app/privacy';
const termsOfServiceUrl = 'https://plantis.app/terms';

Future<void> _openPrivacyPolicy() async {
  final uri = Uri.parse(privacyPolicyUrl);
  if (await canLaunchUrl(uri)) {
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}
```

**Tarefas:**
- [ ] Criar documentos legais
- [ ] Hospedar em domínio oficial
- [ ] Implementar navegação
- [ ] Adicionar links no app

#### 3. Produtos RevenueCat não Configurados

**Problema:** Product IDs hardcoded, não configurados no RevenueCat

**Impacto:** Alto - Compras não funcionarão em produção

**Solução Necessária:**

1. **Configurar no RevenueCat Dashboard:**
   - Premium Monthly: `plantis_premium_monthly`
   - Premium Yearly: `plantis_premium_yearly`
   - Premium Lifetime: `plantis_premium_lifetime` (opcional)

2. **Configurar nas Lojas:**
   - App Store Connect (iOS)
   - Google Play Console (Android)

3. **Atualizar ofertas (Offerings):**
   ```dart
   // No RevenueCat Dashboard
   Offering: "default"
   Packages:
     - monthly ($plantis_premium_monthly)
     - yearly ($plantis_premium_yearly) [RECOMENDADO]
   ```

### 🟡 Importantes (Melhoram experiência)

#### 4. Testes Unitários

**Status:** 0% - Nenhum teste implementado

**Necessário:**

```dart
// test/features/premium/premium_provider_test.dart
void main() {
  group('PremiumProvider', () {
    test('should load available products on init', () async { });
    test('should purchase product successfully', () async { });
    test('should handle purchase errors', () async { });
    test('should restore purchases', () async { });
    test('should sync subscription status', () async { });
  });
}

// test/features/premium/subscription_sync_service_test.dart
void main() {
  group('SubscriptionSyncService', () {
    test('should sync subscription to Firebase', () async { });
    test('should resolve conflicts correctly', () async { });
    test('should process webhooks', () async { });
    test('should update premium features', () async { });
  });
}
```

**Cobertura Alvo:** ≥80% para services e providers críticos

#### 5. Webhooks RevenueCat

**Problema:** Endpoint não configurado para receber eventos em tempo real

**Benefícios:** Sincronização instantânea, detecção de fraudes, analytics

**Solução:**

```dart
// Firebase Cloud Function
exports.revenueCatWebhook = functions.https.onRequest(async (req, res) => {
  const webhookData = req.body;
  const userId = webhookData.event.app_user_id;

  const syncService = new SubscriptionSyncService(userId);
  await syncService.processRevenueCatWebhook(webhookData);

  res.status(200).send('OK');
});
```

**Configuração RevenueCat:**
- Webhook URL: `https://us-central1-{project}.cloudfunctions.net/revenueCatWebhook`
- Authorization: Bearer token

#### 6. Error Handling Aprimorado

**Status:** Básico implementado, pode melhorar

**Melhorias Necessárias:**

```dart
// Tipos de erro específicos
enum SubscriptionErrorType {
  network,           // Sem internet
  unauthorized,      // Usuário não autenticado
  paymentDeclined,   // Pagamento recusado
  productUnavailable,// Produto não disponível
  alreadyOwned,      // Já possui assinatura
  cancelled,         // Compra cancelada pelo usuário
  unknown,
}

class SubscriptionError extends Equatable {
  final SubscriptionErrorType type;
  final String message;
  final String? code;
  final dynamic details;

  // User-friendly messages
  String get userMessage {
    switch (type) {
      case SubscriptionErrorType.network:
        return 'Sem conexão. Verifique sua internet.';
      case SubscriptionErrorType.paymentDeclined:
        return 'Pagamento recusado. Verifique seu método de pagamento.';
      // ... etc
    }
  }
}
```

#### 7. Analytics Avançado

**Implementado:** Básico
**Faltando:**

- [ ] Funil de conversão (visualizou → selecionou → comprou)
- [ ] Taxa de churn (cancelamentos)
- [ ] Lifetime Value (LTV) por usuário
- [ ] A/B testing de preços/planos
- [ ] Cohort analysis

**Implementação Sugerida:**

```dart
// Analytics eventos de funil
await _analytics.logEvent('premium_page_viewed');
await _analytics.logEvent('premium_plan_selected', params: {'plan': planId});
await _analytics.logEvent('premium_purchase_initiated');
await _analytics.logEvent('premium_purchase_completed', params: {
  'plan': planId,
  'price': price,
  'currency': currency,
  'days_to_convert': daysSinceInstall,
});
```

### 🟢 Nice-to-Have (Funcionalidades extras)

#### 8. Trial Gratuito

**Status:** Suportado pela infraestrutura, não configurado

**Configuração Necessária:**

1. **RevenueCat Dashboard:** Ativar trial de 7 dias
2. **Lojas:** Configurar trial period
3. **UI:** Destacar trial na apresentação de planos

```dart
Widget _buildPlanCard(ProductInfo product) {
  return Card(
    child: Column(
      children: [
        if (product.hasFreeTrial)
          Container(
            color: Colors.green,
            child: Text('7 DIAS GRÁTIS'),
          ),
        Text(product.title),
        Text(product.priceString),
      ],
    ),
  );
}
```

#### 9. Promoções e Descontos

**Status:** Não implementado

**Casos de Uso:**
- Desconto para novos usuários
- Promoções sazonais
- Upgrade de plano com desconto
- Retenção (oferecer desconto antes do cancelamento)

**Implementação RevenueCat:**

```dart
// Ofertas promocionais
final offerings = await Purchases.getOfferings();
final promoOffering = offerings.getOffering('promo_spring_2025');

if (promoOffering != null) {
  // Exibir oferta especial
  _showPromoDialog(promoOffering);
}
```

#### 10. Paywalls Dinâmicos

**Status:** Estático atualmente

**Melhoria:**
- Diferentes paywalls para diferentes públicos
- Testes A/B de messaging
- Personalização baseada em uso do app

**Exemplo:**

```dart
// Paywall para usuários que atingiram limite
if (plantCount >= 5) {
  _showLimitReachedPaywall();
}

// Paywall para features bloqueadas
if (!isPremium && feature == 'plant_identification') {
  _showFeatureLockedPaywall(feature: 'Identificação de Plantas');
}
```

---

## 🌟 Features Premium Específicas

### Implementadas

#### 1. Unlimited Plants

**Status:** ✅ Completo
**Implementação:** `subscription_sync_service.dart:353`

```dart
await _updatePlantLimits(userId, isPremium);
// Firebase: users/{userId}/settings/plant_limits
{
  'maxPlants': isPremium ? -1 : 5,
  'canCreateCustomCategories': isPremium,
  'canImportPlantData': isPremium,
}
```

#### 2. Advanced Reminders

**Status:** ✅ Completo
**Implementação:** `subscription_sync_service.dart:391`

```dart
await _enableAdvancedNotifications(userId);
// Firebase: users/{userId}/notifications/settings
{
  'canScheduleCustomReminders': true,
  'canUseWeatherBasedNotifications': true,
  'canReceivePlantHealthAlerts': true,
  'maxCustomReminders': -1, // unlimited
}
```

#### 3. Export Data

**Status:** ✅ Disponível (feature genérica)

Usuários premium podem exportar:
- Lista de plantas em JSON/CSV
- Histórico de cuidados
- Fotos das plantas
- Notas e anotações

#### 4. Cloud Backup

**Status:** ✅ Habilitado
**Implementação:** `subscription_sync_service.dart:426`

```dart
await _configurePlantisCloudBackup(userId, isPremium);
// Firebase: users/{userId}/settings/cloud_backup
{
  'enabled': true,
  'canBackupPhotos': true,
  'canBackupNotes': true,
  'maxBackupSizeMB': 1000, // 1GB
  'autoBackupEnabled': true,
}
```

### Parcialmente Implementadas

#### 5. Custom Themes

**Status:** ⚠️ 40% - Estrutura pronta, temas não criados

**Necessário:**
- [ ] Criar temas alternativos (escuro premium, cores customizadas)
- [ ] UI de seleção de temas
- [ ] Persistência de preferência

#### 6. Detailed Analytics

**Status:** ⚠️ 50% - Analytics básico funciona

**Faltando:**
- [ ] Dashboard visual de crescimento das plantas
- [ ] Gráficos de histórico de cuidados
- [ ] Comparação entre plantas
- [ ] Insights IA-powered

### Não Implementadas

#### 7. Plant Identification

**Status:** ❌ 0%

**Requisitos:**
- Integração com API de identificação (Plant.id, Pl@ntNet)
- Câmera com captura otimizada
- UI de resultados com confiança
- Limite: 3 identificações/mês (free), ilimitado (premium)

**Estimativa:** 8-12 horas de desenvolvimento

#### 8. Disease Diagnosis

**Status:** ❌ 0%

**Requisitos:**
- Integração com API de diagnóstico
- Análise de fotos de folhas/plantas
- Sugestões de tratamento
- Base de conhecimento de doenças

**Estimativa:** 16-24 horas de desenvolvimento

#### 9. Weather-Based Notifications

**Status:** ❌ 0%

**Requisitos:**
- Integração com API de clima
- Lógica de recomendação baseada em clima
- Notificações inteligentes (ex: "Vai chover, não precisa regar")
- Geolocalização do usuário

**Estimativa:** 12-16 horas de desenvolvimento

---

## 🔥 Integração Firebase

### Estrutura de Dados

#### Collection: `users/{userId}/subscriptions/current`

```json
{
  "userId": "user123",
  "deviceId": "iOS_1234567890",
  "devicePlatform": "iOS",
  "appName": "plantis",
  "appVersion": "1.0.0",

  "isPremium": true,
  "productId": "plantis_premium_yearly",
  "status": "active",
  "tier": "premium",
  "isActive": true,
  "isInTrial": false,
  "willRenew": true,

  "purchaseDate": 1704672000000,
  "expirationDate": 1736208000000,
  "originalPurchaseDate": 1704672000000,
  "lastUpdated": 1704672000000,
  "lastSyncedAt": {".sv": "timestamp"},

  "store": "appStore",
  "isSandbox": false,

  "premiumFeatures": [
    "unlimited_plants",
    "advanced_reminders",
    "export_data",
    "custom_themes",
    "cloud_backup"
  ],

  "plantLimitOverride": -1,
  "canUseAdvancedReminders": true,
  "canExportData": true,
  "canUseCustomThemes": true,
  "canBackupToCloud": true,

  "syncVersion": 42,
  "conflictResolutionStrategy": "server_wins",
  "syncSource": "mobile_app"
}
```

#### Collection: `users/{userId}/devices/{deviceId}`

```json
{
  "deviceId": "iOS_1234567890",
  "platform": "iOS",
  "lastSyncAt": {".sv": "timestamp"},
  "subscriptionData": { /* nested subscription data */ }
}
```

#### Collection: `subscription_history/{historyId}`

```json
{
  "userId": "user123",
  "deviceId": "iOS_1234567890",
  "historyCreatedAt": {".sv": "timestamp"},
  "eventType": "sync",
  "subscriptionData": { /* snapshot of subscription */ }
}
```

### Security Rules

**Recomendação:**

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {

    // Users can only read/write their own subscription data
    match /users/{userId}/subscriptions/{document=**} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }

    // Users can only read/write their own devices
    match /users/{userId}/devices/{document=**} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }

    // Subscription history: read-only for users, write for server
    match /subscription_history/{historyId} {
      allow read: if request.auth != null;
      allow write: if false; // Only server can write
    }
  }
}
```

### Índices Necessários

```javascript
// Collection: subscription_history
{
  fields: ["userId", "historyCreatedAt"],
  order: "descending"
}

// Collection: users/{userId}/devices
{
  fields: ["lastSyncAt"],
  order: "descending"
}
```

---

## 🛒 Fluxo de Compra

### Diagrama de Sequência

```
┌────────┐         ┌──────────┐         ┌──────────┐         ┌──────────┐
│ User   │         │ App UI   │         │RevenueCat│         │ Firebase │
└───┬────┘         └────┬─────┘         └────┬─────┘         └────┬─────┘
    │                   │                    │                    │
    │ Taps "Comprar"    │                    │                    │
    ├──────────────────>│                    │                    │
    │                   │ purchaseProduct()  │                    │
    │                   ├───────────────────>│                    │
    │                   │                    │ Purchase Flow      │
    │                   │                    │ (App Store/Play)   │
    │                   │                    │◄──────────────────┐│
    │                   │                    │                   ││
    │                   │                    │ Success/Failure   ││
    │                   │                    │───────────────────┘│
    │                   │◄───────────────────┤                    │
    │                   │ SubscriptionEntity │                    │
    │                   │                    │                    │
    │                   │ syncSubscriptionStatus()                │
    │                   ├────────────────────────────────────────>│
    │                   │                    │                    │
    │                   │                    │  Save to Firestore │
    │                   │                    │◄──────────────────┤│
    │                   │                    │                   ││
    │                   │◄────────────────────────────────────────┤
    │                   │ Sync Complete      │                    │
    │                   │                    │                    │
    │   Success UI      │                    │                    │
    │◄──────────────────┤                    │                    │
    │                   │                    │                    │
```

### Estados da Compra

```dart
enum PurchaseState {
  idle,           // Nenhuma operação em andamento
  loading,        // Carregando produtos disponíveis
  selecting,      // Usuário selecionando plano
  purchasing,     // Compra em andamento
  processing,     // Processando resultado
  syncing,        // Sincronizando com Firebase
  success,        // Compra bem-sucedida
  failed,         // Compra falhou
  cancelled,      // Usuário cancelou
  restored,       // Compras restauradas
}
```

### Tratamento de Erros por Plataforma

#### iOS (App Store)

```dart
// Erros comuns
'PURCHASE_CANCELLED' → Usuário cancelou
'PRODUCT_NOT_AVAILABLE' → Produto não existe no App Store Connect
'PURCHASE_INVALID' → Pagamento recusado
'PURCHASE_NOT_ALLOWED' → Restrições parentais

// Tratamento
if (error.code == 'PURCHASE_CANCELLED') {
  // Não mostrar erro, apenas feedback suave
  showSnackbar('Compra cancelada');
} else {
  showErrorDialog(error.userFriendlyMessage);
}
```

#### Android (Play Store)

```dart
// Erros comuns
'ITEM_ALREADY_OWNED' → Já possui a assinatura
'ITEM_UNAVAILABLE' → Produto não publicado
'DEVELOPER_ERROR' → Configuração incorreta
'SERVICE_DISCONNECTED' → Play Store não disponível

// Tratamento especial para ITEM_ALREADY_OWNED
if (error.code == 'ITEM_ALREADY_OWNED') {
  // Tentar restaurar automaticamente
  await restorePurchases();
}
```

---

## 🔄 Sincronização Cross-Device

### Cenários de Conflito

#### Cenário 1: Compra em Device A, Device B desatualizado

```
Device A: Compra Premium → Firebase atualizado
Device B: Ainda mostra Free

Resolução:
- Device B ouve subscriptionStatus stream
- Recebe atualização automática via Firebase
- UI atualizada em tempo real
```

#### Cenário 2: Dois devices compram simultaneamente

```
Device A: Compra Monthly às 10:00:00
Device B: Compra Yearly às 10:00:05

Resolução (Latest Timestamp Wins):
- SubscriptionSyncService detecta conflito
- Compara timestamps: 10:00:05 > 10:00:00
- Aplica assinatura Yearly (mais recente)
- Device A recebe atualização
```

#### Cenário 3: Assinatura expira durante uso offline

```
Device A: Offline, assinatura expira
Device B: Online, detecta expiração via webhook

Resolução:
- Device B sincroniza status "expired"
- Quando Device A volta online:
  - Detecta lastUpdated > local
  - Aplica status "expired"
  - Desabilita features premium
```

### Auto-Sync Timer

```dart
// Sincronização automática a cada 15 minutos
subscriptionSyncService.startAutoSync(
  interval: Duration(minutes: 15),
);

// Para economizar bateria quando app em background
@override
void didChangeAppLifecycleState(AppLifecycleState state) {
  if (state == AppLifecycleState.paused) {
    subscriptionSyncService.stopAutoSync();
  } else if (state == AppLifecycleState.resumed) {
    subscriptionSyncService.startAutoSync();
  }
}
```

---

## 💎 Recomendações de Excelência

### 1. Performance

#### Otimização de Carregamento

```dart
// Carregar produtos em background durante splash screen
@override
void initState() {
  super.initState();
  // Não bloquear UI
  unawaited(_preloadSubscriptionData());
}

Future<void> _preloadSubscriptionData() async {
  await Future.wait([
    _loadAvailableProducts(),
    _checkCurrentSubscription(),
  ]);
}
```

#### Caching Inteligente

```dart
// Cache produtos por 1 hora
class ProductCache {
  static List<ProductInfo>? _cachedProducts;
  static DateTime? _cacheTime;

  static bool get isValid =>
    _cachedProducts != null &&
    _cacheTime != null &&
    DateTime.now().difference(_cacheTime!) < Duration(hours: 1);

  static List<ProductInfo>? get products =>
    isValid ? _cachedProducts : null;
}
```

### 2. UX/UI

#### Loading States Granulares

```dart
enum LoadingContext {
  initialLoad,     // Carregando produtos
  purchasing,      // Processando compra
  restoring,       // Restaurando compras
  syncing,         // Sincronizando com Firebase
}

// UI adapta mensagem ao contexto
Widget _buildLoadingMessage(LoadingContext context) {
  switch (context) {
    case LoadingContext.purchasing:
      return Text('Processando pagamento...');
    case LoadingContext.syncing:
      return Text('Sincronizando entre dispositivos...');
    // ...
  }
}
```

#### Skeleton Screens

```dart
// Placeholder enquanto produtos carregam
Widget _buildProductsSkeleton() {
  return Column(
    children: List.generate(3, (index) =>
      Shimmer.fromColors(
        child: Container(height: 100, color: Colors.grey),
      ),
    ),
  );
}
```

#### Feedback Imediato

```dart
// Haptic feedback na compra
HapticFeedback.mediumImpact();

// Animação de sucesso
await showDialog(
  context: context,
  builder: (_) => SuccessAnimationDialog(
    message: 'Bem-vindo ao Premium!',
  ),
);
```

### 3. Acessibilidade

```dart
// Semantics para leitores de tela
Semantics(
  label: 'Plano Premium Anual',
  hint: 'R$ 89,90 por ano. Toque duas vezes para selecionar',
  button: true,
  child: PlanCard(...),
);

// Tamanhos de fonte ajustáveis
Text(
  'Premium',
  style: Theme.of(context).textTheme.headline6?.copyWith(
    fontSize: MediaQuery.of(context).textScaleFactor * 18,
  ),
);
```

### 4. Segurança

#### Validação Server-Side

```dart
// Cloud Function para validar compras
exports.validatePurchase = functions.https.onCall(async (data, context) => {
  const userId = context.auth.uid;
  const purchaseToken = data.purchaseToken;

  // Validar com RevenueCat API
  const isValid = await revenueCat.validateReceipt(purchaseToken);

  if (isValid) {
    await admin.firestore()
      .collection('users')
      .doc(userId)
      .update({ isPremium: true });
  }

  return { success: isValid };
});
```

#### Detecção de Fraude

```dart
// Múltiplas verificações
final checks = [
  subscription?.isSandbox == false,           // Não é compra de teste
  subscription?.store != Store.promotional,    // Não é promocional
  expirationDate?.isAfter(DateTime.now()),    // Não expirada
  userId == currentAuthUser?.id,              // Mesmo usuário
];

if (!checks.every((c) => c)) {
  // Possível fraude, logar e bloquear
  await _analytics.logEvent('fraud_detected');
  return false;
}
```

### 5. Testes

#### Testes de Integração

```dart
testWidgets('Purchase flow completes successfully', (tester) async {
  await tester.pumpWidget(MyApp());

  // Navigate to premium page
  await tester.tap(find.text('Premium'));
  await tester.pumpAndSettle();

  // Select yearly plan
  await tester.tap(find.text('Anual'));
  await tester.pump();

  // Mock successful purchase
  when(mockSubscriptionRepo.purchaseProduct(any))
    .thenAnswer((_) async => Right(mockSubscription));

  // Tap purchase button
  await tester.tap(find.text('Comprar'));
  await tester.pumpAndSettle();

  // Verify success state
  expect(find.text('Premium Ativo'), findsOneWidget);
});
```

#### Testes de Webhook

```dart
test('Processes RENEWAL webhook correctly', () async {
  final webhookData = {
    'event': {
      'type': 'RENEWAL',
      'app_user_id': 'user123',
      'product_id': 'plantis_premium_yearly',
      'expiration_at_ms': 1736208000000,
    },
  };

  await syncService.processRevenueCatWebhook(webhookData);

  // Verify Firebase updated
  final doc = await firestore
    .collection('users/user123/subscriptions')
    .doc('current')
    .get();

  expect(doc.data()['status'], 'active');
});
```

---

## 🗺️ Roadmap de Implementação

### Fase 1: Fundação (Completo ✅)

**Duração:** 3 semanas
**Status:** 100%

- [x] Integração RevenueCat SDK
- [x] Entidades e repositórios
- [x] UI básica de assinatura
- [x] State management (Provider + Riverpod)
- [x] Link na página de configurações
- [x] Sincronização Firebase básica

### Fase 2: Completar Funcionalidades Críticas (Em Andamento)

**Duração Estimada:** 2 semanas
**Status:** 40%

**Prioridade Alta:**

- [ ] Implementar gerenciamento de assinatura (2-3h)
  - [ ] URLs de gerenciamento iOS/Android
  - [ ] Deep linking
  - [ ] Testes em dispositivos reais

- [ ] Política de Privacidade e Termos (4-6h)
  - [ ] Redigir documentos legais
  - [ ] Criar páginas web
  - [ ] Implementar navegação
  - [ ] Validar conformidade LGPD/GDPR

- [ ] Configurar Produtos RevenueCat (2-3h)
  - [ ] Criar produtos no Dashboard
  - [ ] Configurar em App Store Connect
  - [ ] Configurar no Google Play Console
  - [ ] Testar em sandbox

- [ ] Testes Unitários Core (8-10h)
  - [ ] RevenueCat Service: 5 testes
  - [ ] Premium Provider: 7 testes
  - [ ] Subscription Sync Service: 8 testes
  - [ ] Cobertura ≥80%

**Prioridade Média:**

- [ ] Webhooks RevenueCat (4-6h)
  - [ ] Cloud Function endpoint
  - [ ] Configurar no RevenueCat Dashboard
  - [ ] Testes de eventos
  - [ ] Monitoramento

- [ ] Error Handling Aprimorado (3-4h)
  - [ ] Tipos de erro específicos
  - [ ] Mensagens user-friendly
  - [ ] Retry logic melhorado
  - [ ] Logging estruturado

### Fase 3: Features Premium Avançadas

**Duração Estimada:** 4 semanas
**Status:** 0%

**Sprint 1 - Plant Identification (1 semana):**

- [ ] Pesquisar e escolher API (Plant.id vs Pl@ntNet)
- [ ] Integrar API escolhida
- [ ] UI de captura de foto otimizada
- [ ] Exibição de resultados com confiança
- [ ] Implementar limites (3/mês free, ilimitado premium)
- [ ] Testes

**Sprint 2 - Disease Diagnosis (1.5 semanas):**

- [ ] Integrar API de diagnóstico
- [ ] Análise de imagens de folhas
- [ ] Base de conhecimento de doenças comuns
- [ ] Sugestões de tratamento
- [ ] UI de resultados detalhados
- [ ] Testes

**Sprint 3 - Weather Integration (1 semana):**

- [ ] Integrar API de clima (OpenWeather)
- [ ] Lógica de recomendações baseadas em clima
- [ ] Notificações inteligentes
- [ ] Geolocalização do usuário
- [ ] Configurações de preferências
- [ ] Testes

**Sprint 4 - Analytics Dashboard (0.5 semana):**

- [ ] Dashboard visual de crescimento
- [ ] Gráficos de histórico
- [ ] Comparação entre plantas
- [ ] Export de relatórios
- [ ] Testes

### Fase 4: Otimização e Growth (Contínuo)

**Duração:** Contínua

- [ ] A/B Testing de Paywalls
  - [ ] Configurar framework (Firebase Remote Config)
  - [ ] Testar diferentes mensagens
  - [ ] Analisar conversão
  - [ ] Iterar

- [ ] Analytics Avançado
  - [ ] Funil de conversão completo
  - [ ] Cohort analysis
  - [ ] Churn prediction
  - [ ] LTV calculation

- [ ] Trial Gratuito
  - [ ] Configurar em RevenueCat
  - [ ] UI destacando trial
  - [ ] Notificações antes do fim do trial
  - [ ] Mensuring de conversão trial→paid

- [ ] Promoções e Ofertas
  - [ ] Sistema de cupons
  - [ ] Ofertas sazonais
  - [ ] Win-back campaigns
  - [ ] Referral program

---

## ⚙️ Configuração e Setup

### 1. RevenueCat

#### Dashboard Setup

1. **Criar Projeto:**
   ```
   Nome: Plantis
   Platform: iOS + Android
   ```

2. **Configurar API Keys:**
   ```env
   # .env
   REVENUE_CAT_API_KEY_IOS=appl_xxxxxxxxxxx
   REVENUE_CAT_API_KEY_ANDROID=goog_xxxxxxxxxxx
   ```

3. **Criar Produtos:**
   ```
   Product ID: plantis_premium_monthly
   Description: Assinatura Mensal Premium
   Duration: 1 month
   Price: R$ 9,90

   Product ID: plantis_premium_yearly
   Description: Assinatura Anual Premium
   Duration: 1 year
   Price: R$ 89,90
   Trial: 7 days (opcional)
   ```

4. **Criar Entitlement:**
   ```
   Entitlement ID: premium
   Products:
     - plantis_premium_monthly
     - plantis_premium_yearly
   ```

5. **Configurar Webhooks:**
   ```
   URL: https://us-central1-{project}.cloudfunctions.net/revenueCatWebhook
   Events: All
   Authorization: Bearer {token}
   ```

#### App Store Connect (iOS)

1. **In-App Purchases → Criar Assinaturas:**
   ```
   Reference Name: Plantis Premium Monthly
   Product ID: plantis_premium_monthly
   Price: R$ 9,90
   Duration: 1 Month
   ```

2. **Configurar Subscription Group:**
   ```
   Group Name: Plantis Premium
   Products: Monthly, Yearly
   ```

3. **StoreKit Configuration File** (para testes locais):
   ```swift
   // Configuration.storekit
   {
     "products": [
       {
         "id": "plantis_premium_monthly",
         "type": "auto-renewable",
         "price": 9.90,
         "duration": "P1M"
       }
     ]
   }
   ```

#### Google Play Console (Android)

1. **Monetize → Subscriptions → Create:**
   ```
   Product ID: plantis_premium_monthly
   Name: Premium Mensal
   Price: R$ 9,90
   Billing period: 1 month
   ```

2. **License Testing:**
   ```
   Add test emails for sandbox testing
   ```

### 2. Firebase

#### Firestore Setup

1. **Criar Collections:**
   ```javascript
   users/
   subscription_history/
   purchase_events/
   ```

2. **Indices:**
   ```javascript
   // Firestore Console → Indexes
   Collection: subscription_history
   Fields: userId (Ascending), historyCreatedAt (Descending)
   ```

3. **Security Rules:**
   ```javascript
   // Ver seção "Security Rules" acima
   ```

#### Cloud Functions

```bash
# Instalar Firebase CLI
npm install -g firebase-tools

# Inicializar Functions
firebase init functions

# Deploy
firebase deploy --only functions:revenueCatWebhook
```

#### Firebase Analytics

```dart
// Configurar eventos customizados no console
'plantis_subscription_sync_started' → Custom Event
'plantis_purchase_completed' → Purchase Event (e-commerce)
```

### 3. Ambiente de Desenvolvimento

#### .env Configuration

```env
# RevenueCat
REVENUE_CAT_API_KEY=appl_xxxxxxxxxxx
REVENUE_CAT_WEBHOOK_SECRET=whsec_xxxxxxxxxxx

# Firebase
FIREBASE_PROJECT_ID=plantis-prod
FIREBASE_API_KEY=AIzaxxxxxxxxxxxxxxxx

# Feature Flags
ENABLE_TRIAL=true
ENABLE_WEBHOOKS=true
ENABLE_ANALYTICS=true
```

#### Build Configurations

```yaml
# pubspec.yaml
dependencies:
  purchases_flutter: ^9.2.1
  firebase_core: ^latest
  firebase_firestore: ^latest
  firebase_analytics: ^latest
  url_launcher: ^latest  # Para gerenciamento de assinatura
```

---

## 📝 Atualizações e Tarefas

### Log de Atualizações

#### v1.0 - 07/10/2025
- ✅ Documento inicial criado
- ✅ Análise completa da implementação atual
- ✅ Identificação de gaps e pendências
- ✅ Roadmap de implementação definido
- ✅ Recomendações de excelência documentadas

---

### Tarefas Prioritárias

#### 🔴 Crítico (Fazer Esta Semana)

1. **[IAP-001] Implementar Gerenciamento de Assinatura**
   - **Estimativa:** 3 horas
   - **Responsável:** TBD
   - **Arquivos:** `premium_subscription_page.dart:310`, `revenue_cat_service.dart`
   - **Critério de Aceite:**
     - [ ] URLs funcionando iOS e Android
     - [ ] Redirecionamento correto para lojas
     - [ ] Testado em dispositivos reais

2. **[IAP-002] Criar Política de Privacidade e Termos**
   - **Estimativa:** 6 horas
   - **Responsável:** TBD + Jurídico
   - **Deliverables:**
     - [ ] Documentos legais redigidos
     - [ ] Páginas web criadas e hospedadas
     - [ ] Links implementados no app
     - [ ] Conformidade LGPD validada

3. **[IAP-003] Configurar Produtos no RevenueCat**
   - **Estimativa:** 3 horas
   - **Responsável:** TBD
   - **Subtarefas:**
     - [ ] Criar produtos no RevenueCat Dashboard
     - [ ] Configurar em App Store Connect
     - [ ] Configurar no Google Play Console
     - [ ] Criar offerings e packages
     - [ ] Testar em sandbox iOS
     - [ ] Testar em sandbox Android

#### 🟡 Importante (Próximas 2 Semanas)

4. **[IAP-004] Implementar Testes Unitários**
   - **Estimativa:** 10 horas
   - **Responsável:** TBD
   - **Cobertura Alvo:** ≥80%
   - **Arquivos:**
     - [ ] `revenue_cat_service_test.dart`
     - [ ] `premium_provider_test.dart`
     - [ ] `subscription_sync_service_test.dart`

5. **[IAP-005] Configurar Webhooks RevenueCat**
   - **Estimativa:** 5 horas
   - **Responsável:** TBD
   - **Subtarefas:**
     - [ ] Cloud Function criada
     - [ ] Endpoint configurado no RevenueCat
     - [ ] Testes de eventos
     - [ ] Logs e monitoramento

6. **[IAP-006] Melhorar Error Handling**
   - **Estimativa:** 4 horas
   - **Responsável:** TBD
   - **Objetivo:** Mensagens user-friendly para todos os erros

#### 🟢 Desejável (Próximo Mês)

7. **[IAP-007] Implementar Plant Identification**
   - **Estimativa:** 8-12 horas
   - **Responsável:** TBD
   - **Epic:** Features Premium Avançadas

8. **[IAP-008] Implementar Disease Diagnosis**
   - **Estimativa:** 16-24 horas
   - **Responsável:** TBD
   - **Epic:** Features Premium Avançadas

9. **[IAP-009] Analytics Avançado**
   - **Estimativa:** 6 horas
   - **Responsável:** TBD
   - **Objetivo:** Funil completo de conversão

10. **[IAP-010] Trial Gratuito**
    - **Estimativa:** 4 horas
    - **Responsável:** TBD
    - **Objetivo:** Aumentar conversão

---

### Backlog

- [ ] **[IAP-011]** Promoções e Descontos
- [ ] **[IAP-012]** Paywalls Dinâmicos
- [ ] **[IAP-013]** Custom Themes Completo
- [ ] **[IAP-014]** Weather-Based Notifications
- [ ] **[IAP-015]** Detailed Analytics Dashboard
- [ ] **[IAP-016]** A/B Testing Framework
- [ ] **[IAP-017]** Referral Program
- [ ] **[IAP-018]** Win-back Campaigns

---

### Questões em Aberto

1. **Preço dos Planos:**
   - Qual será o preço final de Monthly e Yearly?
   - Haverá plano Lifetime?
   - Desconto no Yearly comparado a 12x Monthly?

2. **Trial Gratuito:**
   - Oferecer trial de 7 dias?
   - Apenas no plano Yearly ou ambos?
   - Como destacar na UI?

3. **Priorização de Features Premium:**
   - Qual feature implementar primeiro: Plant ID ou Disease Diagnosis?
   - Weather integration é essencial para v1.0?

4. **Infraestrutura:**
   - Qual Cloud Functions pricing tier?
   - Limite de sincronizações por usuário?
   - Política de retenção de dados históricos?

---

### Métricas de Sucesso

#### KPIs Técnicos

- [ ] Cobertura de testes ≥80%
- [ ] Tempo de carregamento da página premium <2s
- [ ] Taxa de erro em compras <1%
- [ ] Latência de sync cross-device <5s
- [ ] 0 crashes relacionados a IAP

#### KPIs de Negócio

- [ ] Taxa de conversão free→premium: >5%
- [ ] Taxa de retenção mensal: >80%
- [ ] Churn rate: <5%/mês
- [ ] LTV médio: R$ 200+
- [ ] Trial→Paid conversion: >40%

---

## 📚 Referências

### Documentação Oficial

- [RevenueCat Docs](https://docs.revenuecat.com/)
- [Flutter In-App Purchase](https://pub.dev/packages/purchases_flutter)
- [Firebase Firestore](https://firebase.google.com/docs/firestore)
- [App Store Subscriptions](https://developer.apple.com/app-store/subscriptions/)
- [Google Play Billing](https://developer.android.com/google/play/billing)

### Arquivos do Projeto

- `packages/core/lib/src/domain/entities/subscription_entity.dart` - Entidade base
- `packages/core/lib/src/infrastructure/services/revenue_cat_service.dart` - Serviço RevenueCat
- `apps/app-plantis/lib/features/premium/presentation/pages/premium_subscription_page.dart` - UI principal
- `apps/app-plantis/lib/features/premium/data/services/subscription_sync_service.dart` - Sincronização

### Inspiração e Benchmarks

- **ReceitaAgro:** Implementação de referência no monorepo
- **Duolingo:** Paywalls eficazes
- **Headspace:** Trial gratuito bem implementado
- **Notion:** Gestão de limites free vs paid

---

**Documento Vivo:** Este documento será atualizado conforme o projeto evolui. Última atualização: 07/10/2025.
