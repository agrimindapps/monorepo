# 📝 Guidelines de Comentários - app-receituagro

**Versão**: 1.0  
**Data**: 2025-11-21  
**Status**: 🔵 Em Implementação

---

## 🎯 Filosofia

> "Código bom é auto-explicativo. Comentários explicam O POR QUÊ, não o QUÊ."

**Princípios**:
1. **Menos é mais**: Prefira código limpo a comentários extensos
2. **Contexto sobre conteúdo**: Explique decisões, não implementação
3. **Manutenível**: Comentários desatualizados são piores que ausência de comentários
4. **Acionável**: TODOs devem ter responsável e prazo

---

## ✅ Quando Comentar

### Sempre Comentar

#### 1. APIs Públicas
```dart
/// 🏆 EXCELENTE
/// Calcula o preço total com desconto aplicado.
/// 
/// Retorna [Price] com valor final após aplicar [discountPercentage].
/// Lança [InvalidDiscountException] se desconto > 100%.
/// 
/// Exemplo:
/// ```dart
/// final price = calculateFinalPrice(100, 10); // R$ 90
/// ```
Price calculateFinalPrice(double basePrice, double discountPercentage) {
  if (discountPercentage > 100) throw InvalidDiscountException();
  return Price(basePrice * (1 - discountPercentage / 100));
}
```

#### 2. Decisões Arquiteturais
```dart
/// 🏆 EXCELENTE
/// Usamos singleton pattern aqui para garantir única instância do database.
/// 
/// **Decisão de Design**: Drift requer única conexão ativa por isolate.
/// **Alternativa considerada**: Factory pattern (rejeitada - complexidade extra)
/// **Trade-off**: Global state vs Type safety
/// 
/// @see https://drift.simonbinder.eu/docs/advanced-features/isolates/
class AppDatabase {
  static AppDatabase? _instance;
  
  factory AppDatabase() => _instance ??= AppDatabase._internal();
}
```

#### 3. Workarounds e Hacks
```dart
/// 🏆 EXCELENTE
/// ⚠️ WORKAROUND TEMPORÁRIO
/// 
/// **Problema**: Firebase Analytics não reporta eventos em debug mode
/// **Solução**: Mock data para desenvolvimento
/// **Issue**: #1234
/// **Remover em**: v3.0.0 quando migrarmos para Firebase Analytics v2
/// 
/// TODO(lucineilo, 2024-06-15): Migrar para Firebase Analytics v2
Future<int> getActiveUsers() async {
  if (kDebugMode) return _getMockActiveUsers(); // TEMPORARY
  return _getRealActiveUsers();
}
```

#### 4. Código Complexo
```dart
/// 🏆 EXCELENTE
/// Algoritmo de busca híbrido para melhor performance.
/// 
/// **Estratégia**:
/// 1. Busca em cache local (O(1) - rápido)
/// 2. Se não encontrado, busca no Drift (O(log n) - médio)
/// 3. Se não encontrado, busca remoto (O(n) - lento)
/// 
/// **Por quê não só remoto?**: Reduz latência em 80% (dados internos)
/// **Trade-off**: Complexidade vs Performance
Future<Diagnostico?> findDiagnostico(int id) async {
  // Step 1: Cache
  final cached = _cache[id];
  if (cached != null) return cached;
  
  // Step 2: Local DB
  final local = await _db.getDiagnostico(id);
  if (local != null) return _cacheAndReturn(local);
  
  // Step 3: Remote (última opção)
  return _fetchRemoteAndCache(id);
}
```

#### 5. Código Deprecated
```dart
/// 🏆 EXCELENTE
/// ⚠️ DEPRECATED - Migrar até v3.0.0 (Jun 2024)
/// 
/// **Status**: Em processo de migração
/// **Remoção planejada**: v3.0.0 (2024-06-01)
/// 
/// **Migrar para**:
/// - Lista: `DiagnosticosListNotifier`
/// - Filtros: `DiagnosticosFilterNotifier`
/// - Busca: `DiagnosticosSearchNotifier`
/// 
/// **Razão da deprecação**: Classe monolítica (violava SRP)
/// **Issue**: #5678
/// 
/// @see DiagnosticosListNotifier para alternativa
@Deprecated('Use specialized notifiers - Removal: v3.0.0')
class DiagnosticosNotifier extends StateNotifier<DiagnosticosState> {
  // ...
}
```

---

## ❌ Quando NÃO Comentar

### Nunca Comentar

#### 1. Código Auto-Explicativo
```dart
// ❌ RUIM - Comentário redundante
/// Retorna o nome do usuário
String getUserName() => user.name;

// ✅ BOM - Sem comentário (óbvio)
String getUserName() => user.name;
```

#### 2. Métodos Triviais
```dart
// ❌ RUIM
/// Define o valor do campo email
void setEmail(String value) {
  _email = value;
}

// ✅ BOM - Sem comentário (setter trivial)
void setEmail(String value) => _email = value;
```

#### 3. Código Morto
```dart
// ❌ RUIM - Código comentado
// void oldMethod() {
//   // implementação antiga
// }

// ✅ BOM - Deletar (use Git para histórico)
```

#### 4. Comentários Óbvios
```dart
// ❌ RUIM
int i = 0; // inicializa contador
i++; // incrementa contador

// ✅ BOM - Sem comentários
int processedCount = 0;
processedCount++;
```

---

## 📋 Formatos Padrão

### TODO Comments

#### Formato Obrigatório
```dart
// TODO(username, YYYY-MM-DD): Descrição clara do que fazer
// Issue: #1234
// Blocker: [opcional] O que está impedindo
```

#### Exemplos

```dart
// ✅ EXCELENTE
/// TODO(lucineilo, 2024-06-15): Implementar retry logic
/// Issue: #1234
/// Blocker: Aguardando API de retry do backend
Future<void> syncData() async {
  // implementação atual sem retry
}

// ❌ RUIM - Sem contexto
// TODO: fix this

// ❌ RUIM - Sem responsável
// TODO: Implementar retry

// ❌ RUIM - Sem data
// TODO(lucineilo): Implementar retry
```

### Deprecated Code

#### Formato Obrigatório
```dart
/// ⚠️ DEPRECATED - [Razão curta]
/// 
/// **Status**: [Em migração | Aguardando alternativa | Aguardando remoção]
/// **Remoção planejada**: v{version} (YYYY-MM-DD)
/// **Migrar para**: {Alternativa}
/// **Issue**: #{number}
@Deprecated('{Mensagem curta} - Removal: v{version}')
```

#### Exemplos

```dart
// ✅ EXCELENTE
/// ⚠️ DEPRECATED - Performance ruim em listas grandes
/// 
/// **Status**: Alternativa disponível
/// **Remoção planejada**: v3.0.0 (2024-06-01)
/// **Migrar para**: `getPaginatedList()`
/// **Razão**: O(n²) vs O(n) na nova implementação
/// **Issue**: #5678
@Deprecated('Use getPaginatedList() for better performance - Removal: v3.0.0')
List<Item> getAllItems() {
  return _items.toList(); // copia toda lista
}

// ❌ RUIM - Sem contexto
@deprecated
void oldMethod() {}

// ❌ RUIM - Sem timeline
@Deprecated('Use newMethod()')
void oldMethod() {}
```

### Migration TODOs

#### Formato para Migrações
```dart
/// 🔄 MIGRATION TODO - [Sistema antigo] → [Sistema novo]
/// 
/// **Status**: [Planejado | Em andamento | Bloqueado]
/// **Deadline**: YYYY-MM-DD
/// **Responsável**: @username
/// **Blocker**: [opcional]
/// **Issue**: #{number}
```

#### Exemplos

```dart
// ✅ EXCELENTE
/// 🔄 MIGRATION TODO - Hive → Drift
/// 
/// **Status**: Planejado para Q2 2024
/// **Deadline**: 2024-06-30
/// **Responsável**: @lucineilo
/// **Blocker**: Aguardando migração de FitossanitariosRepository
/// **Issue**: #9012
/// 
/// Após migração, remover:
/// - HivePragaModel
/// - PragaHiveAdapter
/// - Todos os imports de package:hive
Future<Praga?> getPraga(int id) async {
  // Implementação atual com Hive
  final box = await Hive.openBox<HivePragaModel>('pragas');
  return box.get(id);
}

// ❌ RUIM
// TODO: Migrar para Drift
```

### Placeholders e Mocks

#### Formato para Implementações Temporárias
```dart
/// 🚧 PLACEHOLDER - [Razão]
/// 
/// **Implementação real**: [Descrição]
/// **Blocker**: [O que falta]
/// **Issue**: #{number}
```

#### Exemplos

```dart
// ✅ EXCELENTE
/// 🚧 PLACEHOLDER - Backend não disponível ainda
/// 
/// **Implementação real**: Integrar com RevenueCat API
/// **Blocker**: Backend em desenvolvimento (ETA: 2024-07-01)
/// **Issue**: #3456
/// 
/// Por enquanto, retorna mock para desenvolvimento local
Future<Subscription> getCurrentSubscription() async {
  // TEMPORARY: Mock data
  return Subscription.mock(isPremium: true);
}

// ❌ RUIM
// TODO: Implement
Future<Subscription> getCurrentSubscription() async {
  return Subscription.mock();
}
```

---

## 🎨 Convenções de Estilo

### Emojis (Opcional mas Recomendado)

Use emojis para identificação visual rápida:

```dart
/// ⚠️  Deprecated / Warning
/// 🔄  Migration TODO
/// 🚧  Placeholder / Work in Progress
/// 🏆  Best Practice / Exemplo excelente
/// 📊  Dados / Estatísticas
/// 🎯  Objetivo / Meta
/// 💡  Ideia / Sugestão
/// 🐛  Bug conhecido
/// 🔥  Performance crítica
/// 🔒  Segurança
```

### Formatação

```dart
// ✅ BOM - Linha única para comentários curtos
/// Retorna o ID do usuário autenticado

// ✅ BOM - Múltiplas linhas para explicações
/// Calcula preço final com desconto.
/// 
/// Aplica desconto progressivo baseado no valor:
/// - 0-100: 5%
/// - 101-500: 10%
/// - 501+: 15%
```

### Seções em Arquivos Grandes

```dart
// ========== CONSTRUCTORS ==========

// ========== PUBLIC METHODS ==========

// ========== PRIVATE METHODS ==========

// ========== HELPER METHODS ==========

// ========== DEPRECATED METHODS ==========
```

---

## 🔍 Code Review Checklist

### Para Reviewers

Ao revisar PRs, verificar:

- [ ] TODOs têm formato `TODO(username, YYYY-MM-DD): descrição`
- [ ] @Deprecated tem mensagem e timeline de remoção
- [ ] Comentários explicam POR QUÊ, não O QUÊ
- [ ] Não há comentários redundantes
- [ ] Não há código comentado (usar Git)
- [ ] Decisões arquiteturais estão documentadas
- [ ] Workarounds têm issue e deadline

### Para Desenvolvedores

Antes de submeter PR:

```bash
# Verificar TODOs sem formato
grep -r "// TODO:" lib | grep -v "TODO("

# Verificar @deprecated sem @Deprecated
grep -r "@deprecated" lib --include="*.dart"

# Verificar código comentado
grep -r "^[\s]*//" lib | grep -E "^\s*//\s*(void|class|Future|const|final)"
```

---

## 🛠️ Ferramentas

### Linter Rules

Adicionar em `analysis_options.yaml`:

```yaml
linter:
  rules:
    # Forçar documentação em APIs públicas
    public_member_api_docs: true
    
    # Alertar sobre TODOs
    todo: warning
    
    # Avisar sobre deprecated sem mensagem
    provide_deprecation_message: true
    
    # Evitar comentários desnecessários
    unnecessary_brace_in_string_interps: true
```

### Pre-commit Hook

`.git/hooks/pre-commit`:

```bash
#!/bin/bash
# Verificar TODOs sem formato adequado
if grep -r "// TODO:" lib --include="*.dart" | grep -v "TODO("; then
  echo "❌ TODOs sem responsável/data encontrados"
  echo "Formato: // TODO(username, YYYY-MM-DD): descrição"
  exit 1
fi

# Verificar @deprecated lowercase
if grep -r "@deprecated" lib --include="*.dart"; then
  echo "❌ Use @Deprecated('message') ao invés de @deprecated"
  exit 1
fi
```

### VS Code Snippets

`.vscode/dart.code-snippets`:

```json
{
  "TODO Format": {
    "prefix": "todo",
    "body": [
      "/// TODO(${1:username}, ${CURRENT_YEAR}-${CURRENT_MONTH}-${CURRENT_DATE}): ${2:description}",
      "/// Issue: #${3:number}"
    ]
  },
  "Deprecated Method": {
    "prefix": "deprecated",
    "body": [
      "/// ⚠️ DEPRECATED - ${1:reason}",
      "/// ",
      "/// **Status**: ${2:status}",
      "/// **Remoção planejada**: v${3:version} (${4:date})",
      "/// **Migrar para**: ${5:alternative}",
      "/// **Issue**: #${6:number}",
      "@Deprecated('${7:message} - Removal: v${3:version}')"
    ]
  }
}
```

---

## 📚 Exemplos Reais do Projeto

### Caso 1: Analytics Service

#### ❌ ANTES (Confuso)
```dart
// TODO: Replace with real Firebase Analytics data in production
Future<double> getActiveUsers() async {
  return Random().nextDouble() * 100;
}
```

#### ✅ DEPOIS (Claro)
```dart
/// 📊 Analytics Demo Mode
/// 
/// Retorna dados simulados para desenvolvimento.
/// 
/// **Implementação real**: Firebase Analytics SDK
/// **Blocker**: Aguardando configuração de produção
/// **Issue**: #1234
/// **Remover em**: v3.0.0 quando Firebase estiver configurado
/// 
/// TODO(lucineilo, 2024-06-30): Implementar Firebase Analytics real
/// Feature flag: 'enable_real_analytics'
Future<double> getActiveUsers() async {
  if (_useMockData) {
    // TEMPORARY: Mock data for development
    return Random().nextDouble() * 100;
  }
  
  // Real implementation (to be implemented)
  return _firebaseAnalytics.getActiveUsers();
}
```

### Caso 2: Deprecated Notifier

#### ❌ ANTES (Sem contexto)
```dart
@deprecated
class DiagnosticosNotifier extends StateNotifier<DiagnosticosState> {
  // 500+ linhas de código
}
```

#### ✅ DEPOIS (Com roadmap)
```dart
/// ⚠️ DEPRECATED - Notifier monolítico refatorado
/// 
/// **Status**: Em processo de migração gradual
/// **Remoção planejada**: v3.0.0 (2024-06-01)
/// **Progresso**: 60% migrado (3/5 features)
/// 
/// **Migrar para** (por funcionalidade):
/// - Lista de diagnósticos → `DiagnosticosListNotifier`
/// - Filtros → `DiagnosticosFilterNotifier`
/// - Busca → `DiagnosticosSearchNotifier`
/// - Recomendações → `DiagnosticosRecommendationsNotifier`
/// - Estatísticas → `DiagnosticosStatsNotifier`
/// 
/// **Razão da refatoração**:
/// - Violava Single Responsibility Principle
/// - Difícil de testar (god class)
/// - Performance ruim (rebuild excessivo)
/// 
/// **Issue**: #5678
/// **Guia de migração**: docs/migration/diagnosticos-notifier.md
/// 
/// @see DiagnosticosListNotifier
@Deprecated('Use specialized notifiers - Removal: v3.0.0 - See migration guide')
class DiagnosticosNotifier extends StateNotifier<DiagnosticosState> {
  // Implementation...
}
```

---

## 🎓 Treinamento

### Sessão 1: Introdução (30min)
1. Por que comentários importam
2. Quando comentar vs quando não
3. Impacto de comentários desatualizados

### Sessão 2: Formatos (30min)
1. TODOs efetivos
2. Deprecated code
3. Migration TODOs
4. Placeholders

### Sessão 3: Ferramentas (20min)
1. Linter rules
2. Pre-commit hooks
3. VS Code snippets
4. Scripts de auditoria

### Sessão 4: Code Review (20min)
1. Checklist de review
2. Dar feedback construtivo
3. Aprovar/rejeitar baseado em guidelines

---

## 📞 Dúvidas e Feedback

- **Slack**: #code-quality
- **Email**: dev-team@receituagro.com
- **Issues**: https://github.com/receituagro/monorepo/issues

**Mantenedor**: @lucineilo  
**Última atualização**: 2025-11-21
