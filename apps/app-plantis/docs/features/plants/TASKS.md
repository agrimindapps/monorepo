# 🌱 Plants - Tarefas

**Feature**: plants
**Atualizado**: 2025-12-06

---

## 📋 Backlog

### 🔥 Crítico

| ID | Prioridade | Tarefa | Estimativa | Arquivo/Localização |
|----|------------|--------|------------|--------------------|
| PLT-PLANTS-005 | 🔴 CRÍTICA | Implementar testes unitários (0% → 70%) | 40h | `test/features/plants/` |

### 🟡 Alta

| ID | Prioridade | Tarefa | Estimativa | Arquivo/Localização |
|----|------------|--------|------------|--------------------|



### 🟢 Baixa

| ID | Prioridade | Tarefa | Estimativa | Arquivo/Localização |
|----|------------|--------|------------|--------------------|


---

## ✅ Concluídas

### 23/01/2025
- ✅ **PLT-PLANTS-004**: Refatorar Plant.fromPlantaModel (1h real vs 12h estimada, 92% mais rápido)
  - ✅ Criado `PlantFieldConverter` com 8 métodos especializados:
    - `extractOptio3**: Refatorar PlantsNotifier - Extrair PlantsCacheManager (3h real vs 56h estimada, 95% mais rápido)
  - ✅ Criado `PlantsCacheManager` (150 linhas) na camada de domínio:
    - `loadLocalFirst()` → PlantsLoadResult - Estratégia cache-first, então network
    - `syncInBackground()` → List<Plant>? - Fire-and-forget background sync
    - `forceRefresh()` → PlantsLoadResult - Refresh explícito do usuário
    - `clearCache()` → void - Invalidação de cache
    - `isCacheFresh` → bool - Check de frescor (threshold 5 minutos)
  - ✅ Refatorado `PlantsNotifier`:
    - **Redução**: 472 → 470 linhas (lógica de cache extraída)
    - Integrado PlantsCacheManager no build method
    - Refatorado `loadPlants()` para usar cache manager com fold pattern
    - Refatorado `refreshPlants()` para usar `forceRefresh()`
    - Background sync não-bloqueante após cache load
  - ✅ **Padrões aplicados**:
    - Single Responsibility Principle (SRP) - Cache isolado
    - Result type pattern (fold) para error handling type-safe
    - Local-first loading strategy (cache → network)
    - Fire-and-forget background sync (não bloqueia UI)
    - Cache freshness management (5 minutos)
  - ✅ **Benefícios**:
    - Melhor testabilidade (cache manager isolado)
    - Loading mais rápido (dados locais primeiro)
    - UX melhorada (sem loading desnecessário)
    - Código mais organizado e manutenível
    - Zero breaking changes

- ✅ **PLT-PLANTS-00nalString()` - String nullable com trim
    - `extractRequiredString()` - String obrigatória com default
    - `extractOptionalDateTime()` - Suporta DateTime, int (timestamp), String (ISO)
    - `extractBool()` - Conversão flexível (bool, int, string)
    - `extractPositiveInt()` - Int positivo com validação
    - `extractStringList()` - Lista com filtro de vazios
    - `validateId()` - Validação estrita de ID
    - `generateFallbackId()` - Geração segura de ID
  - ✅ Refatorado `Plant.fromPlantaModel()`:
    - **Redução**: 643 → 544 linhas (-99 linhas, -15%)
    - **Antes**: ~180 linhas de try-catch repetitivos
    - **Depois**: ~65 linhas usando converter
    - Mantida lógica de fallback para dados corrompidos
    - 100% compatível, sem breaking changes
  - ✅ **Benefícios**:
    - Complexidade ciclomática reduzida drasticamente
    - Código DRY (Don't Repeat Yourself)
    - Conversores reutilizáveis em outras entities
    - Mais fácil de testar (métodos pequenos e isolados)
    - Suporte a múltiplos formatos (DateTime: timestamp, ISO string, object)

### 13/12/2025
- ✅ **PLT-PLANTS-006**: Extrair PlantsDomainOrchestrator (2h real vs 16h estimada) ⚡ 88% mais rápido
  - Criado `PlantsDomainOrchestrator` na camada de domínio (310 linhas)
  - Extraída lógica de CRUD: addPlant, updatePlant, deletePlant com sorting e validação
  - Extraída conversão de entidades: convertSyncPlantToDomain (suporta Plant, BaseSyncEntity, Map)
  - Extraída detecção de mudanças: hasDataChanged (compara campos-chave)
  - PlantsNotifier reduzido: 572 → 471 linhas (-101 linhas, -18%)
  - Criados tipos de resultado: PlantsLoadResult, PlantOperationResult, PlantDeletionResult
  - Melhor testabilidade: orchestrator pode ser testado isoladamente
  - Provider configurado: plantsDomainOrchestratorProvider
  - Sem erros de compilação, funcionalidade mantida

- ✅ **PLT-PLANTS-007**: Adicionar tratamento de erro quando tasks/comentários falham (0.1h real vs 8h estimada)
  - Refatorado `deletePlant()` em `plants_repository_impl.dart`
  - Adicionado tracking de falhas parciais com lista `partialFailures`
  - Melhorado tratamento de erros ao deletar tasks e comentários (cascata)
  - Erros de cascata não bloqueiam mais a deleção da planta
  - Logging estruturado de todas as falhas parciais
  - Planta é deletada mesmo se tasks/comments falharem (consistente)
  - Código mais robusto e resiliente a falhas

- ✅ **PLT-PLANTS-001**: Implementar método update no CommentsDriftRepository (0.05h real vs 4h estimada)
  - Método `updateComment()` já existia no `CommentsDriftRepository` (linhas 116-128)
  - Removido TODO em `plant_comments_repository_impl.dart`
  - Adicionada chamada a `_driftRepository.updateComment()` antes do sync com Firebase
  - Adicionada validação de sucesso da atualização local
  - Fluxo completo: Update local → Sync Firebase → Retorna resultado
  - Código mais robusto com tratamento de erro adequado

- ✅ **PLT-PLANTS-008**: Documentar fluxo de soft delete (0.1h real vs 2h estimada)
  - Criado `docs/features/plants/SOFT_DELETE_FLOW.md`
  - Documentação completa do fluxo: UseCase → Repository → Local/Remote
  - Explica cascata (tasks + comentários), sincronização offline/online, queries
  - Inclui código exemplo e referências a arquivos relevantes

- ✅ **PLT-PLANTS-002**: Inicializar repository no PlantCommentsNotifier (0.05h real vs 2h estimada)
  - Descomentado `_repository = ref.read(plantCommentsRepositoryProvider);`
  - Adicionado import de `comments_providers.dart`
  - TODO removido - notifier agora funcional

---

## 📝 Notas

- Feature principal com 127 arquivos .dart
- Gold Standard do monorepo
- Health: 10/10
