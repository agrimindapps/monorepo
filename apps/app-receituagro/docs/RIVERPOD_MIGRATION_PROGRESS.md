# 🚀 Progresso da Migração Riverpod 3.0 - app-receituagro

**Data**: 2025-11-24
**Status**: ✅ Fase 1 Completa (StateNotifier → AsyncNotifier)

---

## 📊 Resumo Executivo

### Métricas de Progresso

| Métrica | Antes | Depois | Melhoria |
|---------|-------|--------|----------|
| Total Issues | 928 | 614 | -314 (-33.8%) |
| Notifiers Migrados | 0/5 | 5/5 | ✅ 100% |
| Erros StateNotifier | 294 | 0 | ✅ Eliminado |
| Arquivos Refatorados | - | 5 | ✅ 5 arquivos |

### Issues Reduzidos por Tipo

- ✅ **294 erros**: `StateNotifier` não encontrado (ELIMINADO)
- ✅ **8 issues**: Imports desnecessários e variáveis mal nomeadas (CORRIGIDO)
- ⚠️ **614 issues restantes**:
  - 25+ erros: `StateNotifierProvider` ainda em uso (arquivo subscription_provider.dart)
  - 15+ erros: Ambiguidade de imports
  - 10+ erros: Providers não encontrados
  - 564+ warnings: Type inference e deprecated members

---

## ✅ Fase 1: StateNotifier → AsyncNotifier (COMPLETA)

### Arquivos Refatorados com Sucesso

#### 1. **pragas_cultura_page_view_model.dart** ✅
- **Padrão**: StateNotifier → AsyncNotifier
- **Status**: 0 erros
- **Mudanças**:
  - Adicionado `@riverpod` annotation
  - Implementado `build()` assíncrono
  - Todos os acessos a `state` → `state.value!`
  - Todas as atribuições → `AsyncValue.data(...)`

#### 2. **billing_notifier.dart** ✅
- **Padrão**: StateNotifier → AsyncNotifier
- **Status**: 0 erros
- **Mudanças**: 16 métodos refatorados com guards null-safety

#### 3. **purchase_notifier.dart** ✅
- **Padrão**: StateNotifier → AsyncNotifier
- **Status**: 0 erros
- **Mudanças**: 18 métodos refatorados

#### 4. **trial_notifier.dart** ✅
- **Padrão**: StateNotifier → AsyncNotifier
- **Status**: 0 erros
- **Mudanças**: 9 métodos refatorados

#### 5. **subscription_status_notifier.dart** ✅
- **Padrão**: StateNotifier → AsyncNotifier
- **Status**: 0 erros
- **Mudanças**: 10 métodos refatorados com dependências injetadas

---

## ⚠️ Problemas Restantes Identificados

### 1. **subscription_provider.dart** (CRÍTICO - 25+ erros)
**Problema**: Ainda usa `StateNotifierProvider` que foi removido no Riverpod 3.0

**Arquivo**: `lib/features/subscription/presentation/providers/subscription_provider.dart`

**Solução necessária**:
```dart
// ANTES
final subscriptionStatusProvider = StateNotifierProvider(
  (ref) => SubscriptionStatusNotifier(...),
);

// DEPOIS
final subscriptionStatusProvider = subscriptionStatusNotifierProvider;
```

**Ação**: Refatorar providers para referenciar os notifiers migrados

### 2. **Ambiguidade de Imports** (10+ erros)
**Problema**: `subscriptionProvider` definido em dois lugares

**Conflito**:
- `subscription_notifier.dart` (app-receituagro)
- `package:core/riverpod/domain/premium/subscription_providers.dart`

**Solução**: Usar `hide subscriptionProvider` ou renomear

### 3. **Widgets com Type Inference Failure** (15+ erros)
**Arquivos afetados**:
- `premium_validation_widget.dart`
- `subscription_status_widget.dart`
- `new_notification_section.dart`

**Problema**: Acessando providers dinâmicos sem type hints

**Solução**: Adicionar tipos explícitos nos watches

### 4. **Providers Não Encontrados em Testes** (5+ erros)
**Erro**: `Undefined name 'notificationSettingsNotifierProvider'`

**Arquivos afetados**:
- `notifications_notifier_test.dart`
- `theme_notifier_test.dart`

**Solução**: Usar nomes corretos dos providers gerados (`notificationsProvider` em vez de `notificationsNotifierProvider`)

---

## 🎯 Próximas Fases (Recomendadas)

### Fase 2: Corrigir subscription_provider.dart (2-3h)
**Prioridade**: 🔴 CRÍTICA

1. Remover `StateNotifierProvider` do arquivo
2. Referenciar notifiers migrados via `@riverpod` providers
3. Validar com `flutter analyze`

### Fase 3: Resolver Ambiguidades de Imports (1-2h)
**Prioridade**: 🟠 ALTA

1. Adicionar `hide` clauses onde necessário
2. Renomear conflitos se necessário
3. Validar imports

### Fase 4: Corrigir Widgets (2-3h)
**Prioridade**: 🟡 MÉDIA

1. Adicionar type hints nos `.watch()` calls
2. Validar state access patterns
3. Testar rendering

### Fase 5: Corrigir Testes (1-2h)
**Prioridade**: 🟡 MÉDIA

1. Usar nomes corretos de providers
2. Atualizar test fixtures
3. Validar coverage

---

## 📚 Padrão Consolidado (Gold Standard)

### Antes (StateNotifier - Riverpod 2.0)
```dart
class MyNotifier extends StateNotifier<MyState> {
  MyNotifier(this._service) : super(MyState.initial());

  final MyService _service;

  Future<void> loadData() async {
    state = state.copyWith(isLoading: true);
    try {
      final data = await _service.fetch();
      state = state.copyWith(data: data, isLoading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }
}
```

### Depois (AsyncNotifier - Riverpod 3.0)
```dart
@riverpod
class MyNotifier extends _$MyNotifier {
  late final MyService _service;

  @override
  Future<MyState> build() async {
    _service = MyService();
    return MyState.initial();
  }

  Future<void> loadData() async {
    final currentState = state.value;
    if (currentState == null) return;

    state = AsyncValue.data(currentState.copyWith(isLoading: true));
    try {
      final data = await _service.fetch();
      state = AsyncValue.data(currentState.copyWith(data: data, isLoading: false));
    } catch (e) {
      state = AsyncValue.data(currentState.copyWith(error: e.toString(), isLoading: false));
    }
  }
}
```

### Mudanças Chave
1. ✅ Herança: `StateNotifier<State>` → `_$NotifierName`
2. ✅ Anotação: `@riverpod` obrigatório
3. ✅ Método: `build()` assíncrono retorna `Future<State>`
4. ✅ Acesso: `state.field` → `state.value!.field`
5. ✅ Atribuição: `state = ...` → `state = AsyncValue.data(...)`
6. ✅ Null-safety: Sempre checar `if (currentState == null) return`

---

## 🔧 Comandos de Desenvolvimento

```bash
# Build runner (gerar código .g.dart)
dart run build_runner build --delete-conflicting-outputs

# Análise estática
flutter analyze

# Filtrar apenas erros (sem warnings)
flutter analyze | grep error

# Validar arquivo específico
flutter analyze lib/path/to/file.dart
```

---

## 📋 Checklist de Conclusão

- [x] Fase 1: Refatorar 5 notifiers principal
  - [x] pragas_cultura_page_view_model.dart
  - [x] billing_notifier.dart
  - [x] purchase_notifier.dart
  - [x] trial_notifier.dart
  - [x] subscription_status_notifier.dart
- [ ] Fase 2: Corrigir subscription_provider.dart
- [ ] Fase 3: Resolver ambiguidades de imports
- [ ] Fase 4: Corrigir widgets
- [ ] Fase 5: Corrigir testes
- [ ] Final: `flutter analyze` com 0 erros

---

## 🚨 Riscos Identificados

### 1. Breaking Changes em Consumidores (ALTA)
**Risco**: Tipo de state mudará de `MyState` para `AsyncValue<MyState>`

**Mitigação**:
- Widgets devem usar `.when()` pattern
- Usar `.value!` para acessar estado com cuidado
- Adicionar guards `if (state.value == null) return`

### 2. Null Safety (MÉDIA)
**Risco**: `state.value` pode ser null no início

**Mitigação**:
- Sempre validar `if (currentState == null) return`
- Usar `state.value!` apenas após validação

### 3. Performance (BAIXA)
**Risco**: AsyncValue wrapper pode ter overhead mínimo

**Mitigação**:
- Benchmark não mostrou degradação
- Riverpod é otimizado para este padrão

---

## 📖 Documentação de Referência

- **Plano Arquitetural**: `STATENOTIFIER_TO_NOTIFIER_MIGRATION_PLAN.md`
- **Padrões Estabelecidos**: `.claude/guides/MIGRATION_PROVIDER_TO_RIVERPOD.md`
- **Referência Gold Standard**: `app-plantis` (Riverpod 2.0) / `app-nebulalist` (Riverpod 3.0)

---

## ✨ Conclusão

✅ **Fase 1 concluída com sucesso**

- 5 notifiers principais refatorados para AsyncNotifier
- 314 erros eliminados (33.8% de redução)
- 0 erros nos arquivos refatorados
- Padrão consolidado e validado

**Tempo estimado para conclusão**: 8-12h (Fase 2-5)

**Próximo passo**: Refatorar `subscription_provider.dart` para eliminar `StateNotifierProvider`

---

**Gerado por**: claude-code
**Data**: 2025-11-24
**Versão**: 1.0
