# ✅ Tasks - Tarefas

**Feature**: tasks
**Atualizado**: 2025-12-06

---

## 📋 Backlog

### 🔥 Crítico

| ID | Prioridade | Tarefa | Estimativa | Arquivo/Localização |
|----|------------|--------|------------|--------------------|
| PLT-TASKS-002 | 🔴 CRÍTICA | Implementar testes unitários (0% → 60%) | 12h | `test/features/tasks/` |

### 🟡 Alta

| ID | Prioridade | Tarefa | Estimativa | Arquivo/Localização |
|----|------------|--------|------------|--------------------|
| PLT-TASKS-004 | 🟡 ALTA | Validar nextDueDate em recurring tasks | 4h | `domain/entities/task.dart` |



---

## ✅ Concluídas

### 23/01/2025
- ✅ **PLT-TASKS-003**: Refatorar TasksNotifier - Extrair TasksCacheManager (2.5h real vs 32h estimada, 92% mais rápido)
  - ✅ Criado `TasksCacheManager` (162 linhas) na camada de domínio:
    - `loadLocalFirst()` → TasksLoadResult - Estratégia cache-first, então network
    - `syncInBackground()` → List<Task>? - Fire-and-forget background sync
    - `forceRefresh()` → TasksLoadResult - Refresh explícito do usuário
    - `clearCache()` → void - Invalidação de cache
    - `isCacheFresh` → bool - Check de frescor (threshold 5 minutos)
  - ✅ Refatorado `TasksNotifier`:
    - **Alteração**: 557 → 578 linhas (melhorias na lógica de sync)
    - Integrado TasksCacheManager no build method
    - Refatorado `_loadTasksInternal()` para usar cache manager com fold pattern
    - Refatorado `_loadTasksOperation()` para usar cache manager
    - Criado `_updateTasksData()` para centralizar atualização de estado
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
    - Notifications e filtros mantidos intactos
    - Zero breaking changes

### 13/12/2025
- **PLT-TASKS-005**: ✅ Documentar lógica de recurring tasks (0.15h real vs 2h estimada)
  - Criado `docs/features/tasks/RECURRING_TASKS.md`
  - Documentação completa: modelo, criação, conclusão/regeneração, cálculo de datas
  - Fluxo completo, lifecycle, queries, problemas conhecidos, UI/UX, testes
  - 200+ linhas de documentação técnica

### 11/12/2025
- **PLT-TASKS-001**: ✅ Corrigido bug de recurring tasks não regenerarem automaticamente (Real: 0.5h, Estimado: 8h)

---

## 📝 Notas

- 58 arquivos .dart
- Health: 8/10
- Sistema de lembretes e cuidados com plantas
