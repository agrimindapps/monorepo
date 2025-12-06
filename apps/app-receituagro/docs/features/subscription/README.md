# 💎 Subscription Feature

## 📋 Descrição

Feature de gerenciamento de assinaturas e recursos premium do app.

---

## 🎯 Regras de Negócio

### Planos
1. **Free**: Acesso básico com limites
2. **Premium**: Acesso completo a todas as features
3. **Trial**: Período de teste do premium

### Compras
1. **Provider**: RevenueCat (iOS/Android)
2. **Restore**: Restaurar compras em novo dispositivo
3. **Offline**: Cache local do status premium

### Limites (Free)
1. **Favoritos**: Limite de X itens
2. **Histórico**: Últimos Y acessos
3. **Funcionalidades**: Algumas bloqueadas

### Premium Guard
1. **Verificação**: Antes de acessar feature premium
2. **Paywall**: Exibido quando necessário
3. **Deep link**: Retorna à feature após compra

---

## 🏗️ Arquitetura

```
lib/features/subscription/
├── data/
│   └── repositories/
│       └── subscription_repository.dart
│
├── domain/
│   ├── entities/
│   │   └── subscription_status.dart
│   └── usecases/
│
├── presentation/
│   ├── pages/
│   │   └── subscription_page.dart
│   ├── providers/
│   │   ├── subscription_notifier.dart
│   │   ├── billing_notifier.dart
│   │   ├── purchase_notifier.dart
│   │   └── trial_notifier.dart
│   └── widgets/
│       └── paywall_widget.dart
```

---

## ✅ Estado Atual

**Health Score**: 8/10

### Migração Riverpod
- [x] subscription_notifier → AsyncNotifier
- [x] billing_notifier → AsyncNotifier
- [x] purchase_notifier → AsyncNotifier
- [x] trial_notifier → AsyncNotifier

---

## 📁 Arquivos Principais

- `lib/features/subscription/presentation/providers/subscription_notifier.dart`
- `lib/features/subscription/presentation/providers/billing_notifier.dart`
- `lib/core/navigation/premium_guards.dart`
- `lib/core/services/premium_service.dart` (⚠️ deprecated)
