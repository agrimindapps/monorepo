# Sincronização Cross-Device de Assinaturas Premium

## 📋 Visão Geral

Implementação completa da sincronização de assinaturas premium entre dispositivos usando RevenueCat + Firebase Auth.

## 🎯 Objetivo

Permitir que usuários acessem sua assinatura premium em qualquer dispositivo ao fazer login com sua conta Firebase, independentemente da loja (App Store/Play Store) usada para comprar.

## 🔄 Fluxo de Sincronização

### Antes (Limitado)
```
Dispositivo A (Apple ID X) → Compra Premium
Dispositivo B (Apple ID Y + Firebase "user123") → ❌ Sem acesso
```
**Problema**: Assinatura vinculada apenas ao Apple ID/Google Play ID

### Depois (Cross-Device Completo)
```
Dispositivo A (Apple ID X + Firebase "user123") → Compra Premium → Vincula ao Firebase UID
Dispositivo B (Apple ID Y + Firebase "user123") → ✅ Acesso automático via Firebase UID
```
**Solução**: Assinatura vinculada ao Firebase UID via RevenueCat

## 🏗️ Arquitetura Implementada

### 1. **Vinculação Automática no Login**
**Arquivo**: `lib/core/providers/receituagro_auth_notifier.dart:575-605`

```dart
/// Sincroniza usuário com RevenueCat após login Firebase
Future<void> _syncSubscriptionUser(UserEntity user) async {
  final result = await _subscriptionRepository.setUser(
    userId: user.id,  // Firebase UID
    attributes: {
      'email': user.email,
      'displayName': user.displayName,
    },
  );
  // Logs + Analytics
}
```

**Chamada**: `receituagro_auth_notifier.dart:87`
```dart
if (!user.isAnonymous) {
  await _syncSubscriptionUser(user);  // ← NOVO
  await _handleDeviceLogin(user);
  await _triggerPostAuthSync(user, previousUser);
}
```

### 2. **Auto-Restore ao Inicializar**
**Arquivo**: `lib/core/providers/premium_notifier.dart:442-514`

```dart
/// Tenta restaurar assinaturas automaticamente
Future<void> _attemptAutoRestore() async {
  final result = await _subscriptionRepository.restorePurchases();

  // Se encontrar assinatura ativa, atualiza estado
  if (activeSubscription.isActive) {
    state = AsyncValue.data(currentState.copyWith(
      currentSubscription: activeSubscription,
      status: newStatus,
    ));
  }
}
```

**Chamada**: `premium_notifier.dart:130`
```dart
if (currentSubscription == null) {
  unawaited(_attemptAutoRestore());  // ← Background restore
}
```

### 3. **RevenueCat Service Integration**
**Arquivo**: `packages/core/lib/src/infrastructure/services/revenue_cat_service.dart:288-307`

```dart
@override
Future<Either<Failure, void>> setUser({
  required String userId,
  Map<String, String>? attributes,
}) async {
  await Purchases.logIn(userId);  // ← Vincula ao Firebase UID

  if (attributes != null) {
    await Purchases.setAttributes(attributes);
  }

  return const Right(null);
}
```

## 📊 Fluxo Completo

### Cenário 1: Primeira Compra
```
1. User faz login → Firebase UID: "user123"
2. Auth Notifier chama setUser("user123")
3. RevenueCat vincula compras ao UID "user123"
4. User compra premium → Salvo em RevenueCat com UID
5. Premium Notifier detecta via stream → Atualiza estado
```

### Cenário 2: Login em Novo Dispositivo
```
1. User faz login no Device B → Firebase UID: "user123"
2. Auth Notifier chama setUser("user123")
3. RevenueCat reconhece UID e recupera assinaturas
4. Premium Notifier: restorePurchases() → Encontra assinatura
5. Estado atualizado automaticamente → User é Premium
```

### Cenário 3: App Reinstalado
```
1. App inicializa → Premium Notifier: build()
2. Sem assinatura em cache → _attemptAutoRestore()
3. User faz login → setUser("user123")
4. restorePurchases() encontra assinatura no servidor
5. Premium restaurado automaticamente
```

## 🔐 Segurança e Validação

### RevenueCat Server
- Valida assinaturas com Apple/Google
- Previne fraude (compartilhamento indevido)
- Gerencia limite de dispositivos
- Detecta subscription sharing

### Firebase Cloud Functions
**Arquivo**: `lib/core/services/cloud_functions_service.dart:283-332`

```dart
Future<Either<String, SubscriptionStatus>> syncRevenueCatPurchase({
  required String receiptData,
  required String productId,
  required String purchaseToken,
}) async {
  // Sincroniza com backend para validação adicional
  // Registra em Firestore para auditoria
}
```

## 📈 Analytics e Monitoring

### Eventos Rastreados

#### Auth Notifier
- `subscription_user_synced`: Usuário vinculado ao RevenueCat
- `subscription_user_sync_error`: Falha na vinculação
- `subscription_user_sync_exception`: Erro técnico

#### Premium Notifier
- `auto_restore`: Restore automático bem-sucedido
- `purchase_started`: Início da compra
- `purchased`: Compra concluída
- `restore`: Restore manual
- `subscription_viewed`: Assinatura visualizada

## 🧪 Testing Guide

### Teste 1: Vinculação no Login
```dart
// 1. Fazer login com conta Firebase
await authNotifier.signInWithEmailAndPassword(
  email: 'test@example.com',
  password: 'password',
);

// 2. Verificar logs
// Deve aparecer: "✅ Auth Notifier: Assinatura vinculada ao usuário Firebase"

// 3. Verificar no RevenueCat Dashboard
// User ID deve estar vinculado ao Firebase UID
```

### Teste 2: Cross-Device Recovery
```dart
// Device A:
// 1. Login + Compra Premium
// 2. Verificar status premium

// Device B (emulador ou device real):
// 1. Instalar app
// 2. Login com mesma conta
// 3. Aguardar 2-3 segundos
// 4. Verificar status premium automático
```

### Teste 3: Reinstalação
```dart
// 1. Desinstalar app
// 2. Reinstalar
// 3. Login
// 4. Premium deve ser restaurado automaticamente
```

## 🚀 Benefícios Implementados

### ✅ Para Usuários
1. **Acesso em qualquer device**: Login = Premium
2. **Sem perda de assinatura**: Troca de celular mantém premium
3. **Recuperação automática**: Reinstalação não perde acesso
4. **Cross-platform**: iPhone → Android (mesmo Firebase UID)

### ✅ Para Negócio
1. **Menos suporte**: Redução de tickets "perdi minha assinatura"
2. **Melhor conversão**: User confia que não vai perder compra
3. **Analytics robusto**: Track completo do ciclo de vida
4. **Auditoria**: Logs em Firestore + RevenueCat

### ✅ Técnico
1. **Desacoplado**: Firebase Auth ↔ RevenueCat limpo
2. **Resiliente**: Auto-restore em background
3. **Observável**: Analytics + Logs em todos os pontos
4. **Testável**: Fluxo claro e determinístico

## 🔧 Manutenção

### Verificar Sincronização
```dart
// RevenueCat Dashboard → Customers → Buscar por Firebase UID
// Firestore → subscriptions/{userId} → Verificar dados
```

### Debugging
```dart
// Ativar logs detalhados
// 1. RevenueCat: LogLevel.debug
// 2. kDebugMode logs no código
// 3. Firebase Analytics → DebugView
```

### Métricas Importantes
- `subscription_user_synced` count: Sucessos de vinculação
- `subscription_user_sync_error` count: Falhas (alertar se > 5%)
- `auto_restore` success rate: Deve ser > 90%
- Tempo médio para restore: < 3 segundos

## 📝 Changelog

### 2025-01-XX - v1.0.0
- ✅ Integração Firebase Auth + RevenueCat
- ✅ Auto-restore em background na inicialização
- ✅ Vinculação automática no login
- ✅ Analytics completo
- ✅ Cross-device sync funcionando

## 🔗 Referências

- [RevenueCat - Identifying Users](https://www.revenuecat.com/docs/user-ids)
- [RevenueCat - Restoring Purchases](https://www.revenuecat.com/docs/restoring-purchases)
- [Firebase Auth](https://firebase.google.com/docs/auth)
- [Cloud Functions - Subscription Validation](https://firebase.google.com/docs/functions)

---

**Status**: ✅ Implementação Completa e Testada
**Autor**: Claude Code Agent
**Data**: Janeiro 2025
