# Plano de Refatoração - packages/core

## 🎯 Objetivo
Reduzir complexidade de arquivos grandes (>800 linhas) seguindo SOLID principles, especialmente Single Responsibility Principle (SRP).

## 📊 Arquivos Prioritários

### 1. enhanced_storage_service.dart (1146 linhas) - PRIORIDADE ALTA
**Responsabilidades Identificadas:**
- ✅ Gerenciamento de cache em memória
- ✅ Criptografia (encrypt/decrypt)
- ✅ Compressão de dados
- ✅ Backup/Restore
- ✅ Métricas e estatísticas
- ✅ Seleção de storage strategy (Hive/SharedPrefs/SecureStorage/File)

**Proposta de Refatoração:**
```
lib/src/infrastructure/services/storage/
├── enhanced_storage_service.dart (FACADE - 200 linhas)
├── storage_cache_manager.dart (gerenciamento cache - 150 linhas)
├── storage_encryption_service.dart (criptografia - 100 linhas)
├── storage_compression_service.dart (compressão - 80 linhas)
├── storage_backup_service.dart (backup/restore - 150 linhas)
├── storage_metrics_service.dart (métricas - 100 linhas)
└── storage_strategy_selector.dart (seleção storage - 120 linhas)
```

**Estratégia:**
- Manter interface pública atual (Facade Pattern)
- Services especializados injetados via composition
- Backward compatibility 100%
- Cada service testável isoladamente

**Esforço:** 6-8 horas
**Risco:** Médio (arquivo crítico)
**ROI:** Alto (melhora testabilidade e manutenibilidade)

---

### 2. sync_firebase_service.dart (1084 linhas) - PRIORIDADE ALTA
**Responsabilidades Identificadas:**
- Sincronização com Firestore
- Conflict resolution
- Throttling e rate limiting
- Queue management
- Retry logic
- Batch operations

**Proposta de Refatoração:**
```
lib/src/infrastructure/services/sync/
├── sync_firebase_service.dart (FACADE - 250 linhas)
├── firestore_sync_client.dart (comunicação Firestore - 200 linhas)
├── sync_conflict_resolver.dart (resolução conflitos - 150 linhas)
├── sync_queue_manager.dart (gerenciamento fila - 150 linhas)
├── sync_throttle_service.dart (throttling - 100 linhas)
└── sync_retry_handler.dart (retry logic - 120 linhas)
```

**Esforço:** 8-10 horas
**Risco:** Alto (serviço crítico de sincronização)
**ROI:** Alto (sync é core feature de vários apps)

---

### 3. unified_sync_manager.dart (997 linhas) - PRIORIDADE MÉDIA
**Responsabilidades Identificadas:**
- Orquestração de sync
- Multi-app sync coordination
- Offline/Online detection
- Sync state management
- Error handling

**Proposta de Refatoração:**
```
lib/src/sync/
├── unified_sync_manager.dart (ORCHESTRATOR - 300 linhas)
├── sync_coordinator.dart (coordenação - 200 linhas)
├── sync_state_machine.dart (state management - 150 linhas)
├── offline_sync_handler.dart (offline handling - 150 linhas)
└── sync_error_handler.dart (error handling - 120 linhas)
```

**Esforço:** 6-8 horas
**Risco:** Alto (orquestrador central)
**ROI:** Médio-Alto

---

### 4. enhanced_image_service_unified.dart (972 linhas) - PRIORIDADE MÉDIA
**Status:** CONSIDERAR REMOÇÃO
- Verificar se está sendo usado (grep retornou 0 em apps)
- Se não usado, pode ser candidato a remoção
- Se usado, refatorar similar ao enhanced_storage_service

**Ação Imediata:**
1. Verificar uso real em apps
2. Se não usado, adicionar @Deprecated e remover em próxima release
3. Se usado, criar plano de refatoração

**Esforço:** 2h (análise) + 6-8h (refatoração se necessário)
**Risco:** Baixo (candidato a remoção)

---

### 5. file_manager_service.dart (957 linhas) - PRIORIDADE BAIXA
**Responsabilidades Identificadas:**
- File operations (read/write/delete)
- Directory management
- Compression (zip/gzip)
- File watching
- Metadata extraction

**Proposta de Refatoração:**
```
lib/src/infrastructure/services/file/
├── file_manager_service.dart (FACADE - 200 linhas)
├── file_operations_service.dart (CRUD - 150 linhas)
├── directory_manager.dart (directory ops - 100 linhas)
├── file_compression_service.dart (compression - 150 linhas)
├── file_watcher_service.dart (watching - 120 linhas)
└── file_metadata_service.dart (metadata - 100 linhas)
```

**Esforço:** 6-8 horas
**Risco:** Médio
**ROI:** Médio

---

### 6. analytics_providers.dart (923 linhas) - PRIORIDADE BAIXA
**Status:** Provider/Notifier file (diferente dos services)
**Ação:** Avaliar se faz sentido quebrar em múltiplos providers por domínio

**Esforço:** 4-6 horas
**Risco:** Baixo
**ROI:** Baixo-Médio

---

## 📋 Roadmap de Implementação

### Fase 1: Preparação (2h)
- [ ] Adicionar TODOs nos arquivos grandes
- [ ] Criar issues no GitHub/Jira para tracking
- [ ] Definir métricas de sucesso
- [ ] Setup branch de refatoração

### Fase 2: Refatoração Incremental (20-30h)
**Semana 1:**
- [ ] enhanced_storage_service.dart (6-8h)
- [ ] Testes para cada service extraído
- [ ] Validação em pelo menos 1 app

**Semana 2:**
- [ ] sync_firebase_service.dart (8-10h)
- [ ] Testes e validação
- [ ] Documentação

**Semana 3:**
- [ ] unified_sync_manager.dart (6-8h)
- [ ] Análise de enhanced_image_service_unified.dart (2h)
- [ ] Decisão sobre remoção/refatoração

**Semana 4:**
- [ ] file_manager_service.dart (6-8h)
- [ ] Revisão final e consolidação
- [ ] Atualização de documentação

### Fase 3: Validação e Release (4h)
- [ ] Testes de integração em todos apps
- [ ] Code review
- [ ] Atualização de README
- [ ] Merge para main

---

## ✅ Critérios de Sucesso

### Métricas de Qualidade
- [ ] Nenhum arquivo >500 linhas
- [ ] 100% backward compatibility
- [ ] Cobertura de testes >80% para cada service
- [ ] 0 erros no flutter analyze
- [ ] Documentação completa (dartdoc)

### Métricas de Manutenibilidade
- [ ] Cyclomatic complexity <10 por método
- [ ] Cada service com responsabilidade única clara
- [ ] Dependency Injection explícita
- [ ] Testável em isolamento

### Validação Funcional
- [ ] Todos os apps buildando sem erros
- [ ] Testes existentes passando
- [ ] Nenhuma regressão reportada

---

## 🚨 Riscos e Mitigações

### Risco 1: Breaking Changes Acidentais
**Mitigação:**
- Manter interfaces públicas atuais (Facade)
- Testes abrangentes antes de cada merge
- Feature flags para rollback rápido

### Risco 2: Complexidade da Refatoração
**Mitigação:**
- Refatoração incremental (1 arquivo por vez)
- Code review rigoroso
- Pair programming para arquivos críticos

### Risco 3: Tempo de Implementação
**Mitigação:**
- Priorização clara (Alta/Média/Baixa)
- Foco em quick wins primeiro
- Possibilidade de pausar entre fases

---

## 📚 Referências

### Padrões Aplicados
- **Facade Pattern**: Interface pública simplificada
- **Strategy Pattern**: Storage strategy selection
- **Composition over Inheritance**: Services especializados
- **Dependency Injection**: GetIt/Injectable
- **Single Responsibility Principle**: Cada service uma responsabilidade

### Documentação Relevante
- CLAUDE.md (arquitetura monorepo)
- .claude/guides/MIGRATION_PROVIDER_TO_RIVERPOD.md
- app-plantis/README.md (Gold Standard)

---

## 🎓 Aprendizados para Futuro

### O que Fazer
✅ Começar com services pequenos e focados
✅ Usar composition desde o início
✅ Testes desde o primeiro método
✅ Documentação inline clara

### O que Evitar
❌ Services "God Class" com múltiplas responsabilidades
❌ Hardcoded app-specific logic no core
❌ Métodos >50 linhas
❌ Dependências circulares

---

**Status:** 📋 PLANEJAMENTO
**Próximo Passo:** Adicionar TODOs nos arquivos alvo
**Owner:** TBD
**Última Atualização:** 2025-10-08
