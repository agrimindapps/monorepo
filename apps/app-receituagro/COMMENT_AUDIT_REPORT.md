# 📋 Auditoria de Comentários - app-receituagro
**Data**: 2025-11-21
**Objetivo**: Identificar e categorizar comentários desatualizados

## 🚨 Prioridade CRÍTICA

### 1. Classes Deprecated Ainda em Uso

#### `DiagnosticosNotifier` (diagnosticos_notifier.dart)
- **Status**: @deprecated mas ainda usado extensivamente
- **Comentário**: "Esta classe será removida em uma futura versão"
- **Problema**: Sem data definida, usado em 10+ lugares
- **Ação**: Definir timeline de migração ou remover @deprecated

#### `DataIntegrityService` (data_integrity_service.dart)
- **Status**: @Deprecated com métodos stub
- **Comentário**: "Service removed. Use Drift instead."
- **Problema**: Retorna dados vazios mas não foi removido
- **Ação**: Remover completamente ou reimplementar com Drift

#### `IComentariosRepository` (i_comentarios_repository.dart)
- **Status**: @Deprecated('Use IComentariosReadRepository or IComentariosWriteRepository instead')
- **Comentário**: "This interface combines read and write operations for backward compatibility"
- **Problema**: Ainda usado em vários lugares
- **Ação**: Migrar todos os usos ou definir deadline

### 2. Deprecated em DI/Providers

#### `FavoritosDI.registerDependencies()`
- **Status**: @Deprecated('Use registerServices() - Repository agora via @LazySingleton')
- **Problema**: Método ainda é chamado em alguns módulos
- **Ação**: Verificar e remover todas as chamadas

#### `PremiumService.instance`
- **Status**: @Deprecated('Use constructor injection via GetIt or Provider instead')
- **Problema**: Singleton pattern deprecated mas ainda usado
- **Ação**: Migrar para DI em todas as ocorrências

## ⚠️ Prioridade ALTA

### 1. TODOs de Implementação Crítica

#### Firebase Analytics Mock Data (15+ ocorrências)
```dart
// TODO: Replace with real Firebase Analytics data in production
```
- **Arquivos**: analytics_metrics_calculation_service.dart
- **Problema**: Dados mockados em produção
- **Ação**: Implementar integração real ou documentar como feature preview

#### JSON Assets Loading (receituagro_database.dart:164)
```dart
// TODO: Implementar carregamento dos JSON assets
```
- **Problema**: Dados estáticos não são carregados automaticamente
- **Ação**: Implementar loader ou remover comentário se já existe alternativa

#### RevenueCat Integration (múltiplos arquivos)
```dart
// TODO: Integrar com RevenueCat para obter método real
// TODO: Substituir por chamada real ao repositório
```
- **Problema**: Placeholders em funcionalidades de pagamento
- **Ação**: Implementar ou marcar como "Demo Mode"

### 2. Migration TODOs (Hive → Drift)

#### Praga Entity Migration (detalhe_praga_notifier.dart)
```dart
// MIGRATION TODO: Replace legacy Hive types with Drift types
// MIGRATION TODO: Praga Drift model uses 'idPraga' not 'idReg'
```
- **Problema**: Migração incompleta causando bugs potenciais
- **Ação**: Concluir migração ou documentar incompatibilidades

#### Diagnostico Enrichment (diagnostico_enrichment_drift_extension.dart)
```dart
// TODO: Implementar busca usando FitossanitariosRepository (3 ocorrências)
```
- **Problema**: Extensions retornam dados vazios
- **Ação**: Implementar queries Drift ou remover métodos

## 📊 Prioridade MÉDIA

### 1. Comentários de Refactoring Antigos

#### "REFACTORED" sem contexto
```dart
/// REFACTORED: Now uses injected RecommendationService
/// REFACTORED (SOLID): Interface Segregation Principle applied
```
- **Problema**: Não indica QUANDO foi refatorado
- **Ação**: Adicionar datas ou remover se já é padrão

#### "Old/Legacy" sem timeline
```dart
/// @deprecated Legacy method - remove favorito sem userId (busca qualquer user)
/// DEPRECATED - As classes abaixo foram consolidadas
```
- **Problema**: Não define quando será removido
- **Ação**: Adicionar roadmap de remoção

### 2. Placeholders em Produção

#### Similarity Threshold (add_comentario_usecase.dart:294)
```dart
const similarityThreshold = 0.85; // Valor arbitrário
final inappropriateWords = ['spam', 'scam', 'hack']; // Lista básica
```
- **Problema**: Lógica simplista demais para produção
- **Ação**: Implementar sistema robusto ou documentar limitações

#### Auth Session Placeholder (receituagro_auth_notifier.dart:642)
```dart
// TODO: Implementar sincronização de perfil quando a box "users" for configurada
```
- **Problema**: Funcionalidade crítica não implementada
- **Ação**: Implementar ou remover comentário se já existe

## 📝 Prioridade BAIXA

### 1. Comentários Redundantes

#### Comentários óbvios
```dart
/// Busca todos os diagnósticos
Future<List<Diagnostico>> getAll()

/// Limpa todos os favoritos
Future<void> clearAll()
```
- **Ação**: Remover comentários que apenas repetem o nome do método

### 2. Comentários de Formatação

#### FontWeight.bold excessivo (200+ ocorrências)
```dart
style: TextStyle(fontWeight: FontWeight.bold) // Sem comentário explicativo
```
- **Problema**: Não é comentário, mas padrão visual repetitivo
- **Ação**: Criar token de design unificado

## 🎯 Plano de Ação Recomendado

### Sprint 1: Críticos (5 dias)
1. [ ] Remover ou finalizar migração DiagnosticosNotifier
2. [ ] Implementar ou remover DataIntegrityService
3. [ ] Resolver deprecated em IComentariosRepository
4. [ ] Implementar JSON assets loading ou remover TODO

### Sprint 2: Altos (3 dias)
1. [ ] Implementar Firebase Analytics ou documentar como mock
2. [ ] Finalizar migração Hive → Drift em PragaEntity
3. [ ] Implementar extensões de enrichment ou remover
4. [ ] Resolver placeholders de RevenueCat

### Sprint 3: Médios (2 dias)
1. [ ] Adicionar datas em comentários "REFACTORED"
2. [ ] Criar roadmap de remoção para "Legacy"
3. [ ] Revisar e melhorar lógica de validação
4. [ ] Documentar limitações conhecidas

### Sprint 4: Baixos (1 dia)
1. [ ] Remover comentários redundantes
2. [ ] Criar design tokens para estilos repetitivos
3. [ ] Padronizar formato de comentários

## 📈 Métricas

- **Total de arquivos analisados**: ~600 arquivos .dart
- **Comentários @deprecated**: 50+
- **TODOs pendentes**: 100+
- **Placeholders em produção**: 20+
- **Comentários de migração**: 15+

## 🔍 Ferramentas Recomendadas

1. **dart analyze** - Identificar deprecated warnings
2. **grep "TODO"** - Listar todos os TODOs
3. **grep "@deprecated"** - Listar deprecated code
4. **dart fix --dry-run** - Sugestões automáticas

## 📚 Referências

- `.claude/guides/MIGRATION_PROVIDER_TO_RIVERPOD.md`
- `CLAUDE.md` - Padrões estabelecidos
- Clean Architecture guidelines
- SOLID principles documentation
