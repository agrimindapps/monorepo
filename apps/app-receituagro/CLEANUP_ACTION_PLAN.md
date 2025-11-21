# 🧹 Plano de Ação - Limpeza de Comentários app-receituagro

**Data de Criação**: 2025-11-21  
**Responsável**: Time de Desenvolvimento  
**Status**: 🔴 Pendente

---

## 📊 Situação Atual

### Números Críticos
- ⚠️ **267 @Deprecated** (27 lowercase + 240 uppercase)
- ⚠️ **135 TODOs** pendentes
- ⚠️ **104 referências Hive** (deveria ser Drift)
- ⚠️ **41 Mocks** em código de produção
- ⚠️ **15 Placeholders** ativos

### Arquivos Mais Problemáticos
1. `analytics_metrics_calculation_service.dart` - **19 TODOs**
2. `subscription_status_notifier.dart` - **11 TODOs**
3. `trial_notifier.dart` - **10 TODOs**
4. `purchase_notifier.dart` - **9 TODOs**
5. `billing_notifier.dart` - **8 TODOs**

---

## 🎯 Estratégia de Execução

### Fase 1: Triage (1 dia) ✅ CONCLUÍDO
- [x] Executar audit script
- [x] Gerar relatórios
- [x] Identificar padrões
- [x] Criar este plano de ação

### Fase 2: Quick Wins (2-3 dias) 🔵 PRÓXIMO
**Objetivo**: Reduzir números em 30% com ações simples

#### 2.1. Remover Comentários Redundantes
```bash
# Comentários que apenas repetem o nome do método
grep -r "/// Busca todos" lib --include="*.dart"
grep -r "/// Limpa todos" lib --include="*.dart"
grep -r "/// Remove todos" lib --include="*.dart"
```
**Estimativa**: 30-50 remoções, ~2 horas

#### 2.2. Atualizar Deprecated com Contexto
```dart
// ❌ ANTES
@deprecated
class DiagnosticosNotifier

// ✅ DEPOIS
/// ⚠️ DEPRECATED - Migrar até v3.0.0 (Jun 2024)
/// Usar: DiagnosticosListNotifier, DiagnosticosFilterNotifier
/// Issue: #1234
@Deprecated('Use specialized notifiers - Removal: v3.0.0')
class DiagnosticosNotifier
```
**Estimativa**: 20-30 atualizações, ~3 horas

#### 2.3. Resolver TODOs Simples
- Analytics mock data → Documentar como "Demo Mode"
- Hive references → Marcar para migração futura
- Simple placeholders → Implementar ou remover

**Estimativa**: 15-20 TODOs, ~4 horas

---

## 🚨 Fase 3: Críticos (1 semana)

### Sprint 3.1: Analytics Service (2 dias)
**Arquivo**: `analytics_metrics_calculation_service.dart`

**Problema**: 19 TODOs de "Replace with real Firebase Analytics"

**Decisão Necessária**:
- [ ] Implementar Firebase Analytics real?
- [ ] Documentar como "Analytics Demo Mode"?
- [ ] Criar feature flag para habilitar/desabilitar?

**Ação Recomendada**:
```dart
/// 📊 Analytics Demo Mode
/// 
/// Este serviço usa dados simulados para demonstração.
/// Para habilitar analytics real:
/// 1. Configurar Firebase Analytics no projeto
/// 2. Implementar AnalyticsRealDataProvider
/// 3. Ativar feature flag 'enable_real_analytics'
/// 
/// @see https://firebase.google.com/docs/analytics
class AnalyticsMetricsCalculationService {
  // Mock data for demonstration
  static const bool _useMockData = true;
  
  Future<double> getActiveUsers() async {
    if (_useMockData) {
      return _getMockActiveUsers(); // Clearly marked
    }
    return _getRealActiveUsers(); // To be implemented
  }
}
```

### Sprint 3.2: Subscription Notifiers (3 dias)
**Arquivos**: `subscription_status_notifier.dart`, `trial_notifier.dart`, `purchase_notifier.dart`, `billing_notifier.dart`

**Problema**: 38 TODOs combinados relacionados a integração com backend

**Decisão Necessária**:
- [ ] Backend já existe? Implementar integração
- [ ] Backend não existe? Documentar como "Local-only Mode"
- [ ] Criar mock backend para testes?

**Ação Recomendada**:
```dart
/// 💳 Subscription Management
/// 
/// **Current Mode**: Local Storage Only
/// **Backend Integration**: Pending - Issue #5678
/// 
/// TODOs são placeholders para futura integração com:
/// - RevenueCat webhook notifications
/// - Backend subscription sync
/// - Real-time subscription updates
/// 
/// Para desenvolvimento local, usar MockSubscriptionService
class SubscriptionStatusNotifier {
  Future<void> _syncWithBackend() async {
    // TODO: Implement backend sync when API is ready
    // For now, all state is managed locally
    _logger.info('Backend sync not available - using local state');
  }
}
```

### Sprint 3.3: Diagnostico Enrichment (1 dia)
**Arquivo**: `diagnostico_enrichment_drift_extension.dart`

**Problema**: 6 TODOs de "Implementar busca usando Repository"

**Ação**: Implementar queries Drift reais ou remover extensões

```dart
// ❌ ATUAL
Future<String?> getDefensivoNome() async {
  // TODO: Implementar busca usando FitossanitariosRepository
  return null;
}

// ✅ OPÇÃO 1: Implementar
Future<String?> getDefensivoNome() async {
  if (idFitossanitario == null) return null;
  
  final repo = getIt<FitossanitariosRepository>();
  final result = await repo.findById(idFitossanitario!);
  return result.fold((_) => null, (fito) => fito.nomeProduto);
}

// ✅ OPÇÃO 2: Remover se não usado
// Extensão removida - usar DiagnosticoEntityResolver em vez disso
```

---

## ⚙️ Fase 4: Migrações (2 semanas)

### Sprint 4.1: Hive → Drift (1 semana)
**Problema**: 104 referências a Hive

**Status Atual**:
- Database já migrado para Drift ✅
- Alguns DTOs ainda usam Hive models ⚠️
- Comentários desatualizados fazem referência a Hive ⚠️

**Ação**:
1. Identificar referências reais vs comentários
2. Atualizar comentários para mencionar Drift
3. Migrar DTOs remanescentes
4. Atualizar documentação

### Sprint 4.2: Deprecated Code (1 semana)
**Problema**: 267 @Deprecated

**Categorização**:
- **Tipo A**: Deprecated mas ainda usado (40%) → Decidir: manter ou remover
- **Tipo B**: Deprecated e não usado (30%) → Remover
- **Tipo C**: Deprecated sem alternativa clara (30%) → Documentar migração

**Ação por Categoria**:

#### Tipo A - Em Uso
```dart
// Adicionar timeline de remoção
@Deprecated('Será removido em v3.0.0 (Jun 2024). Use XYZ')
```

#### Tipo B - Não Usado
```bash
# Listar usos
dart analyze --no-fatal-warnings 2>&1 | grep "deprecated"

# Remover código morto
find lib -name "*.dart" -exec sed -i '' '/OLD_METHOD/d' {} \;
```

#### Tipo C - Sem Alternativa
```dart
/// ⚠️ LEGACY METHOD - Ainda não há alternativa completa
/// 
/// Este método está deprecated mas ainda é necessário para:
/// - Compatibilidade com versões antigas do banco
/// - Integração com sistema legado X
/// 
/// Planejamento de remoção:
/// - v2.8: Implementar alternativa (Q1 2024)
/// - v3.0: Deprecar completamente (Q2 2024)
/// - v3.5: Remover (Q3 2024)
@Deprecated('Use com cautela - Alternativa em desenvolvimento')
```

---

## 🔧 Fase 5: Standards & Guidelines (3 dias)

### 5.1. Criar Guia de Comentários
**Arquivo**: `docs/COMMENTING_GUIDELINES.md`

```markdown
# Guidelines de Comentários - app-receituagro

## Quando Comentar

✅ **SEMPRE comentar**:
- Métodos públicos em services/repositories
- Decisões arquiteturais não-óbvias
- Workarounds temporários (com TODO e data)
- Código deprecated (com alternativa e timeline)

❌ **NUNCA comentar**:
- Código auto-explicativo
- Métodos óbvios (getName, setName)
- Implementações triviais

## Formato de TODOs

```dart
// ✅ BOM
/// TODO(username, 2024-01-21): Implementar retry logic
/// Issue: #1234
/// Blocker: Aguardando API de retry do backend

// ❌ RUIM
// TODO: fix this
```

## Formato de Deprecated

```dart
// ✅ BOM
/// ⚠️ DEPRECATED - Remover em v3.0.0 (Jun 2024)
/// 
/// **Migrar para**: NewService.newMethod()
/// **Razão**: Performance melhorada e API mais limpa
/// **Issue**: #5678
@Deprecated('Use NewService.newMethod() - Removal: v3.0.0')

// ❌ RUIM
@deprecated // sem contexto
```
```

### 5.2. Setup de Linter Rules
**Arquivo**: `analysis_options.yaml`

```yaml
linter:
  rules:
    # Forçar documentação em APIs públicas
    public_member_api_docs: true
    
    # Alertar sobre TODOs em produção
    todo: warning
    
    # Avisar sobre deprecated sem mensagem
    provide_deprecation_message: true
```

### 5.3. Pre-commit Hook
**Arquivo**: `.git/hooks/pre-commit`

```bash
#!/bin/bash
# Verificar TODOs sem data/responsável
if grep -r "TODO:" lib --include="*.dart" | grep -v "TODO("; then
  echo "❌ TODOs sem responsável/data encontrados"
  echo "Formato: // TODO(username, YYYY-MM-DD): descrição"
  exit 1
fi

# Verificar @deprecated sem @Deprecated
if grep -r "@deprecated" lib --include="*.dart"; then
  echo "❌ Use @Deprecated('message') ao invés de @deprecated"
  exit 1
fi
```

---

## 📈 KPIs de Sucesso

### Métricas Iniciais (Baseline)
- @Deprecated: **267**
- TODOs: **135**
- Hive refs: **104**
- Mocks: **41**
- Placeholders: **15**

### Metas por Fase

| Fase | @Deprecated | TODOs | Hive | Mocks | Placeholders |
|------|-------------|-------|------|-------|--------------|
| Baseline | 267 | 135 | 104 | 41 | 15 |
| Fase 2 (Quick Wins) | 240 (-10%) | 115 (-15%) | 104 | 35 (-15%) | 10 (-33%) |
| Fase 3 (Críticos) | 200 (-25%) | 80 (-41%) | 95 (-9%) | 30 (-27%) | 5 (-67%) |
| Fase 4 (Migrações) | 100 (-63%) | 50 (-63%) | 20 (-81%) | 20 (-51%) | 3 (-80%) |
| Fase 5 (Standards) | 50 (-81%) | 30 (-78%) | 10 (-90%) | 10 (-76%) | 0 (-100%) |

### Meta Final (4 semanas)
- ✅ @Deprecated: < 50 (redução de 81%)
- ✅ TODOs: < 30 (redução de 78%)
- ✅ Hive refs: < 10 (redução de 90%)
- ✅ Mocks: < 10 (redução de 76%)
- ✅ Placeholders: 0 (redução de 100%)

---

## 🛠️ Ferramentas & Scripts

### Scripts Criados
1. ✅ `scripts/audit_comments.sh` - Auditoria completa
2. 🔵 `scripts/remove_redundant_comments.sh` - Remover comentários óbvios
3. 🔵 `scripts/update_deprecated.sh` - Atualizar formato deprecated
4. 🔵 `scripts/validate_todos.sh` - Validar formato de TODOs

### Comandos Úteis

```bash
# Auditar comentários
./scripts/audit_comments.sh

# Listar TODOs por idade (mais antigos primeiro)
git log --all --format="%H %ci" --grep="TODO" | sort

# Encontrar deprecated ainda em uso
dart analyze 2>&1 | grep -i deprecated

# Estatísticas de comentários
cloc lib --by-file --csv | grep -E '\.dart'

# Gerar relatório de progresso
./scripts/audit_comments.sh && \
  echo "Progresso desde baseline:" && \
  diff reports/SUMMARY.md reports/SUMMARY_BASELINE.md
```

---

## 📅 Cronograma

### Semana 1
- **Dia 1**: ✅ Triage e Planejamento
- **Dia 2-3**: Quick Wins (Fase 2)
- **Dia 4-5**: Analytics Service (Fase 3.1)

### Semana 2
- **Dia 1-3**: Subscription Notifiers (Fase 3.2)
- **Dia 4**: Diagnostico Enrichment (Fase 3.3)
- **Dia 5**: Review e testes

### Semana 3
- **Dia 1-5**: Hive → Drift Migration (Fase 4.1)

### Semana 4
- **Dia 1-5**: Deprecated Code Cleanup (Fase 4.2)

### Semana 5
- **Dia 1-3**: Standards & Guidelines (Fase 5)
- **Dia 4-5**: Documentação e treinamento

---

## 🎓 Treinamento do Time

### Sessão 1: Boas Práticas de Comentários (1h)
- Quando comentar vs quando não comentar
- Formato de TODOs efetivos
- Ciclo de vida de código deprecated

### Sessão 2: Ferramentas e Automação (30min)
- Como usar scripts de auditoria
- Configurar pre-commit hooks
- Interpretar relatórios

### Sessão 3: Code Review Guidelines (30min)
- Checklist de comentários em PRs
- Aprovar/rejeitar baseado em guidelines
- Dar feedback construtivo

---

## 🚀 Próximos Passos Imediatos

1. **HOJE** (21/11/2024):
   - [x] Revisar este plano com o time
   - [ ] Criar issue no GitHub/Jira
   - [ ] Definir responsável por cada fase
   - [ ] Salvar baseline dos relatórios

2. **AMANHÃ** (22/11/2024):
   - [ ] Iniciar Fase 2 (Quick Wins)
   - [ ] Criar branch `chore/cleanup-comments`
   - [ ] Setup de linter rules
   - [ ] Primeira sessão de treinamento

3. **ESTA SEMANA**:
   - [ ] Concluir Fase 2 e 3.1
   - [ ] Review com o time
   - [ ] Ajustar plano baseado em feedback

---

## 📞 Contatos & Responsabilidades

| Fase | Responsável | Reviewer | Status |
|------|-------------|----------|--------|
| Fase 2 | TBD | TBD | 🔵 Pendente |
| Fase 3.1 | TBD | TBD | ⚪ Não iniciado |
| Fase 3.2 | TBD | TBD | ⚪ Não iniciado |
| Fase 3.3 | TBD | TBD | ⚪ Não iniciado |
| Fase 4.1 | TBD | TBD | ⚪ Não iniciado |
| Fase 4.2 | TBD | TBD | ⚪ Não iniciado |
| Fase 5 | TBD | TBD | ⚪ Não iniciado |

---

## 📚 Recursos Adicionais

- [Relatório de Auditoria Completo](./COMMENT_AUDIT_REPORT.md)
- [Relatórios Detalhados](./reports/)
- [Guia de Migração Riverpod](./.claude/guides/MIGRATION_PROVIDER_TO_RIVERPOD.md)
- [CLAUDE.md - Padrões](./CLAUDE.md)

---

**Última Atualização**: 2025-11-21 17:30:00  
**Próxima Revisão**: 2025-11-28 (semanal)
