# Claude Code Configuration - Flutter Monorepo

## 🏢 Monorepo Structure

### **Apps (8 projects)**
- **app-gasometer**: Vehicle control (Drift + Analytics) - **✅ Pure Riverpod** (~99% migrado)
- **app-plantis**: Plant care (Notifications + Scheduling) - **✅ Pure Riverpod** (~98% migrado)
- **app_taskolist**: Task management (Clean Architecture) - **✅ Pure Riverpod** (100% migrado)
- **app-receituagro**: Agricultural diagnostics (Static Data + Hive) - **✅ Pure Riverpod 3.0** (100% migrado)
- **app-petiveti**: Pet care management - **✅ Pure Riverpod** (~99% migrado)
- **app_agrihurbi**: Agricultural management - **⚠️ Riverpod Legacy** (ChangeNotifierProvider)
- **app_nebulalist**: Task/list management (Clean Arch + Offline-first) - **✅ Pure Riverpod** (9/10)
- **receituagro_web**: Web platform - **✅ Pure Riverpod** (100% migrado)

### **Packages**
- **packages/core**: Shared services (Firebase, RevenueCat, Drift, Riverpod)

---

## 🎯 PADRÕES ESTABELECIDOS (Validados)

### **State Management**
- **PADRÃO ÚNICO**: Riverpod com code generation (`@riverpod`)
- **Status**: Maioria dos apps migrados para Riverpod
- **Apps 100% Riverpod**: app-plantis, app-receituagro, app-nebulalist

### **Arquitetura**
- **Clean Architecture** (Presentation/Domain/Data)
- **Repository Pattern** (Drift local + Firebase remote)
- **SOLID Principles** com Specialized Services
- **Error Handling**: Either<Failure, T> (dartz) - **OBRIGATÓRIO**

### **Persistência Local**
- **PADRÃO ÚNICO**: Drift (SQLite type-safe)
- **Status**: ✅ Implementado em todos os apps
- **Referência**: `.claude/guides/DRIFT_IMPLEMENTATION_GUIDE.md`
- **Características**:
  - Type-safe queries
  - Reactive streams (watchAll, watchById)
  - Migrations automáticas
  - Result<T> error handling

### **Testing**
- **Mocktail** para mocking (padrão)
- **ProviderContainer** para testes sem widgets (Riverpod)
- **Cobertura mínima**: ≥80% para use cases
- **Testes por use case**: 5-7 testes (success + validations + failures)

### **Dependency Injection**
- GetIt + Injectable
- Riverpod providers para state management

### **Code Generation**
```bash
# Executar após mudanças em providers
dart run build_runner watch --delete-conflicting-outputs
```

### **Documentação Gerada (Markdown)**
- **Localização Obrigatória**: Toda documentação técnica deve ser salva em `apps/[app-name]/docs/`.
- **Regra**: Arquivos `.md` NÃO devem ficar na raiz do app (exceto README.md).
- **Organização sugerida**:
  - `docs/` - Documentação geral
  - `docs/features/` - Documentação por feature
  - `docs/issues/` - Tracking de issues por módulo
- **Ação**: Se a pasta `docs/` não existir, crie-a antes de salvar.

---

## 🏆 Gold Standard de Qualidade

### **app-plantis: 10/10 Quality Score** (Arquitetura de Referência)

**Métricas:**
- ✅ 0 erros analyzer
- ✅ 0 critical warnings
- ✅ ~98% migrado para Riverpod (314+ providers)
- ✅ Clean Architecture rigorosa
- ✅ SOLID Principles (Specialized Services)
- ✅ Either<Failure, T> em toda camada de domínio
- ✅ ConsumerWidgets em toda UI (72+)

**Status Riverpod**: Migração concluída. Nenhum uso de GetIt/Provider restante.

### **app-nebulalist: 9/10 Quality Score** (Pure Riverpod Implementation)

**Métricas:**
- ✅ 0 erros analyzer
- ✅ 0 warnings
- ✅ Clean Architecture completa (3-layer)
- ✅ Pure Riverpod com code generation (`@riverpod`)
- ✅ Either<Failure, T> em toda camada de domínio
- ✅ Offline-first com Hive + Firestore
- ✅ Repository Pattern (Local + Remote data sources)
- ✅ 15 use cases implementados
- ❌ Zero testes (blocker para 10/10)

**Características Especiais:**
- **Two-tier item system**: ItemMaster (templates) + ListItem (instances)
- **Best-effort sync**: Local-first, remote sync não-bloqueante
- **Free tier limits**: 10 lists, item quotas (RevenueCat pending)
- **GetIt + Injectable** para DI
- **Ownership verification**: Todas operações verificam userId

**Gaps Identificados:**
- ❌ Sync service incompleto (`lib/core/sync/` vazio)
- ❌ Zero testes (Mocktail instalado mas não usado)
- ⚠️ Premium feature mockado (RevenueCat pending)
- ⚠️ README minimal

**Próximos Passos:**
1. Implementar NebulalistSyncService (background sync)
2. Adicionar testes unitários (use cases priority)
3. README profissional
4. Integrar RevenueCat

---

## 🤖 Agent Usage Patterns

### **Specialists Diretos**
- **flutter-architect**: Decisões arquiteturais e planejamento estrutural (Riverpod + Clean Arch)
- **flutter-engineer**: Desenvolvimento end-to-end com Riverpod
- **code-intelligence**: Análise de código (auto-selects Sonnet/Haiku)
- **task-intelligence**: Execução de tarefas (auto-selects baseado em complexidade)
- **specialized-auditor**: Auditorias específicas (security/performance/quality)
- **flutter-ux-designer**: Melhorias de UX/UI
- **feature-planner**: Planejamento rápido de features

### **Orquestração Complexa**
- **project-orchestrator**: Workflows multi-step, coordenação de especialistas

**Regra**: Use especialista direto para tarefas específicas, orchestrator para workflows complexos.

---

## 📋 Active Context

### **✅ Migração Riverpod - Status Atual**

| App | Status | Observação |
|-----|--------|------------|
| app-plantis | ✅ ~98% | 314+ providers, 0 erros |
| app-gasometer | ✅ ~99% | 182+ providers, 0 erros, código morto removido |
| app-receituagro | ✅ 100% | Pure Riverpod 3.0 |
| app-nebulalist | ✅ 100% | Pure Riverpod |
| app-taskolist | ✅ 100% | Pure Riverpod, 0 erros |
| app-petiveti | ✅ ~99% | 1 ChangeNotifier (wrapper válido), 0 erros |
| app-agrihurbi | ⚠️ ~85% | 9 providers migrados, 17 ChangeNotifierProvider restantes, 0 erros |

---

## 🔧 Development Commands

### **Análise e Build**
```bash
# Análise estática
flutter analyze

# Testes
flutter test

# Code generation (Riverpod + Injectable + Hive)
dart run build_runner watch --delete-conflicting-outputs

# Build debug
flutter build apk --debug

# Build release
flutter build apk --release
flutter build appbundle --release
```

### **Riverpod Linting**
```bash
dart run custom_lint
```

### **Monorepo Tools**
```bash
# Build all apps
melos run build:all:apk:debug
```

---

## 🎯 Quality Standards

### **Código**
- 0 analyzer errors
- 0 critical warnings
- Clean Architecture rigorosamente seguida
- SOLID Principles em services
- Either<Failure, T> para operações que podem falhar

### **Testes**
- ≥80% coverage para use cases
- 5-7 testes por use case (success + validations + failures)
- Mocktail para mocking
- ProviderContainer para testes Riverpod (sem widgets)

### **State Management (Riverpod)**
- Code generation com `@riverpod`
- AsyncValue<T> para states assíncronos
- ConsumerWidget/ConsumerStatefulWidget para UI
- Auto-dispose (lifecycle gerenciado automaticamente)

### **Arquitetura**
- Specialized Services (SOLID - SRP)
- Repository Pattern (Hive + Firebase)
- Validation centralizada em use cases
- Imutabilidade (copyWith pattern)

---

## 📚 Documentação

### **Documentação Técnica (IA Context)**
Para garantir consistência e qualidade, consulte estes documentos antes de gerar código:
- **[Arquitetura & Camadas](.claude/docs/ARCHITECTURE.md)**: Estrutura de pastas e regras de dependência.
- **[Padrões de Código](.claude/docs/CODE_PATTERNS.md)**: Snippets "Gold Standard" (UseCase, Repository, Riverpod).
- **[Nomenclatura](.claude/docs/NAMING_CONVENTIONS.md)**: Regras de nomes para arquivos, classes e métodos.
- **[Padrões de Testes](.claude/docs/TESTING_STANDARDS.md)**: Como testar usando Mocktail e AAA.
- **[Definition of Done](.claude/docs/DEFINITION_OF_DONE.md)**: Checklist antes de finalizar tarefas.
- **[Tech Stack](.claude/docs/TECH_STACK.md)**: Versões e pacotes permitidos.

### **Guias Técnicos**
- `.claude/guides/DRIFT_IMPLEMENTATION_GUIDE.md` - Guia de implementação Drift (SQLite)
- `.claude/agents/flutter-architect.md` - Padrões arquiteturais Riverpod
- `.claude/agents/flutter-engineer.md` - Padrões de desenvolvimento Riverpod

### **Referências**
- **app-plantis/README.md** - Documentação Gold Standard
- **app-plantis/test/** - Exemplos de testes com Mocktail
- **packages/core** - Services compartilhados

---

## 🚀 Quick Start para Novos Apps

```bash
# 1. Criar app
flutter create --org com.yourorg app-name

# 2. Adicionar dependências Riverpod
flutter pub add flutter_riverpod riverpod_annotation
flutter pub add dev:riverpod_generator dev:build_runner

# 3. Seguir arquitetura app-plantis
# lib/
# ├── core/
# ├── features/
# │   └── [feature]/
# │       ├── data/
# │       ├── domain/
# │       └── presentation/
# └── shared/

# 4. Usar flutter-architect para planejamento
# 5. Usar flutter-engineer para implementação
```

---

**Objetivo**: Base sólida e escalável para crescimento sustentável dos apps 🚀