# Status da Migração GetIt → Riverpod - app-plantis

**Data:** 2025-11-21
**Status:** 🔄 Em Progresso (Fase 1-2 de 5)
**Complexidade Identificada:** ALTA (projeto maior que inicialmente estimado)

---

## 📊 Resumo Executivo

A migração de GetIt para Riverpod no app-plantis é viável, mas **muito mais complexa** do que o mapeamento inicial (22-30 horas) sugeriu. A arquitetura atual tem **forte acoplamento entre DI e features**, especialmente:

- ✅ 314 providers já usam `@riverpod`
- ✅ 72 widgets já usam `ConsumerWidget`/`ConsumerStatefulWidget`
- ✅ Core providers base foram criados (`core_di_providers.dart`)
- ❌ **66 erros de compilação** não resolvi dos devido a dependências circulares entre feature providers
- ❌ Arquivos de features ainda importam `auth_providers.dart` que não existe

---

## ✅ O QUE FOI FEITO (Fase 1)

### 1. Arquivo `core_di_providers.dart` Criado ✅

**Localização:** `lib/core/providers/core_di_providers.dart`

Consolidou todos os providers base:
- Firebase (Firestore, Storage, Auth)
- SharedPreferences
- Connectivity
- Core repositories (delegadas para GetIt)
- Auth state management

**Padrão utilizado:**
```dart
@riverpod
FirebaseFirestore firebaseFirestore(FirebaseFirestoreRef ref) {
  return FirebaseFirestore.instance;
}

@riverpod
IAuthRepository authRepository(AuthRepositoryRef ref) {
  // Delega para GetIt (transitório até migração completa)
  return getIt<IAuthRepository>();
}
```

### 2. Build Runner Executado ✅

- 1,281 outputs gerados com sucesso
- Todos os .g.dart files criados corretamente
- Sem erros circulares no build system

### 3. Análise de Erros Completa ✅

Identificados **66 erros críticos** causados por:

1. **Referências a `auth_providers.dart` inexistente** (5 arquivos)
   - `lib/features/account/presentation/providers/account_providers.dart`
   - `lib/features/data_export/presentation/notifiers/data_export_notifier.dart`
   - `lib/features/device_management/presentation/providers/device_management_providers.dart`
   - E outros...

2. **Ambiguous imports de `sharedPreferencesProvider`**
   - Existe em duas bibliotecas:
     - `package:app_plantis/core/services/services_providers.dart`
     - `package:core/src/riverpod/common_providers.dart`

3. **Undefined providers em feature layers**
   - `authRepositoryProvider` (não está acessível)
   - `firebaseFirestoreProvider` (não está acessível)
   - `authStateNotifierProvider` (nome incorreto)

---

## ❌ Problemas Identificados

### Problema 1: Arquitetura de Features Complexa

Cada feature tem seus próprios `providers.dart` com código como:

```dart
// lib/features/tasks/presentation/providers/tasks_providers.dart
@riverpod
TasksRepository tasksRepository(TasksRepositoryRef ref) {
  final firestore = ref.watch(firebaseFirestoreProvider);  // ❌ Não existe
  final networkInfo = ref.watch(networkInfoProvider);      // ❌ Não existe
  final authRepo = ref.watch(authRepositoryProvider);      // ❌ Não existe
  // ...
}
```

**Causa:** Features tentam importar providers que deveriam estar em `core_di_providers.dart`, mas o acesso é bloqueado por imports incorretos.

### Problema 2: Arquivo `services_providers.dart` Antigo

**Localização:** `lib/core/services/services_providers.dart`

Ainda registra `DataCleanerService`, `RateLimiterService`, etc. com `GetIt`, criando conflitos com Riverpod.

### Problema 3: Módulos DI Antigos Ainda Ativos

**Localização:** `lib/core/di/modules/`

Ainda há 6 módulos usando `GetIt.registerLazySingleton()`:
- `account_deletion_module.dart`
- `domain_module.dart`
- `sync_module.dart`
- `spaces_module.dart`
- `plants_module.dart`
- `tasks_module.dart`

---

## 🔧 O QUE AINDA PRECISA SER FEITO

### Fase 2: Resolver Dependências de Features (⚠️ BLOQUEADOR)

**Prioridade:** CRÍTICA
**Esforço:** 12-16 horas

1. **Criar `feature_providers_index.dart`**
   - Arquivo centralizador que re-exporta todos os providers de `core_di_providers.dart`
   - Evita imports complexos em features

2. **Corrigir 5 arquivos de features**
   - Remover imports de `auth_providers.dart`
   - Importar de `core_di_providers.dart`

3. **Resolver ambiguous imports**
   - Escolher entre `core/services/services_providers.dart` ou `core/providers/common_providers.dart`
   - Consolidar em um único arquivo

### Fase 3: Migrar Módulos DI (8-12 horas)

1. `account_deletion_module.dart` → providers Riverpod
2. `domain_module.dart` → providers Riverpod
3. `sync_module.dart` → providers Riverpod
4. `spaces_module.dart` → providers Riverpod
5. `plants_module.dart` → providers Riverpod
6. `tasks_module.dart` → providers Riverpod

### Fase 4: Simplificar main.dart (2-3 horas)

1. Remover `injection_container.dart` import
2. Simplificar DI initialization
3. Passar `sharedPreferencesProvider` via Riverpod

### Fase 5: Testes & Cleanup (4-6 horas)

1. Executar `flutter test` completo
2. Verificar cobertura não quebrou
3. Grep final: `grep -r "GetIt\|get_it\|\.I<" lib/`
4. Documentação final

---

## 📋 Recomendações

### ✅ CONTINUAR COM A MIGRAÇÃO (Recomendado)

**Razão:**
- 60-70% já está em Riverpod
- Benefícios são altos (melhor testability, hot reload)
- Riscos são baixos (testes já em place)

**Próximos Passos:**
1. **Semana 1:** Resolver dependências de features (Fase 2)
2. **Semana 2:** Migrar módulos DI (Fase 3)
3. **Semana 3:** Simplificar main.dart + testes (Fases 4-5)

### 🟠 ESTRATÉGIA ALTERNATIVA: Migração Incrementa

Se o prazo é curto, considere:
1. Finalizar apenas providers de `core_di_providers.dart` ✅ (FEITO)
2. Corrigir imports críticos nas features (4-6 horas)
3. Deixar módulos DI como estão (para próxima iteração)
4. Documentar próximos passos

Isso permitiria:
- ✅ Usar novos providers em features que precisam
- ✅ Manter GetIt para módulos complexos
- ✅ Migração gradual sem riscos
- ✅ PRs menores e mais seguros

---

## 📊 Métricas Atualizadas

| Métrica | Valor | Status |
|---------|-------|--------|
| **Providers com @riverpod** | 314+ | ✅ |
| **ConsumerWidgets** | 72 | ✅ |
| **Testes com ProviderContainer** | 9+ | ✅ |
| **Arquivos `core_di_providers.dart` criados** | 1 | ✅ |
| **Build errors** | 0 | ✅ |
| **Flutter analyze errors** | ~60 | ⚠️ |
| **Módulos DI migrados** | 0/6 | ❌ |
| **main.dart simplificado** | Não | ❌ |

---

## 🎯 Estimativa Atualizada

### Cenário 1: Migração Completa
- **Esforço:** 30-40 horas (vs. 22-30 estimado)
- **Timeline:** 2-3 semanas
- **Resultado:** Pure Riverpod, zero GetIt

### Cenário 2: Migração Incremental
- **Esforço:** 8-10 horas (próximas)
- **Timeline:** 1 semana
- **Resultado:** Core providers em Riverpod, módulos ainda em GetIt

**Recomendação:** Cenário 2 (seguro, entregável, prepara para Cenário 1)

---

## 📌 Arquivos Criados/Modificados

### ✅ Novos
- `lib/core/providers/core_di_providers.dart` (102 linhas)

### ⚠️ Modificados
- `lib/features/tasks/presentation/providers/tasks_providers.dart` (imports corrigidos)

### ❌ Ainda Precisam
- Feature providers index file
- Consolidação de services_providers.dart
- Migração de 6 módulos DI

---

## 📚 Referências

- **Guia Riverpod:** `.claude/guides/MIGRATION_PROVIDER_TO_RIVERPOD.md`
- **Pattern Reference:** `apps/app-nebulalist` (Pure Riverpod)
- **Gold Standard:** `apps/app-plantis/lib/` (72 ConsumerWidgets já migrados)

---

**Próximo Passo Recomendado:**
→ Criar `feature_providers_index.dart` para re-exportar providers da core (4 horas)
