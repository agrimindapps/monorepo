# Claude Code Configuration - Flutter Monorepo

## 🏢 Monorepo Structure

### **Apps (7 projects)**
- **app-gasometer**: Vehicle control (Hive + Analytics) - **Migrating to Riverpod**
- **app-plantis**: Plant care (Notifications + Scheduling) - **Gold Standard 10/10** → **Migrating to Riverpod**
- **app_taskolist**: Task management (Clean Architecture) - **Migrating to Riverpod**
- **app-receituagro**: Agricultural diagnostics (Static Data + Hive) - **Migrating to Riverpod**
- **app-petiveti**: Pet care management - **Migrating to Riverpod**
- **app_agrihurbi**: Agricultural management - **Standardizing to Riverpod**
- **receituagro_web**: Web platform - **Migrating to Riverpod**

### **Packages**
- **packages/core**: Shared services (Firebase, RevenueCat, Hive, Riverpod)

---

## 🎯 PADRÕES ESTABELECIDOS (Validados)

### **State Management**
- **PADRÃO ÚNICO**: Riverpod com code generation (`@riverpod`)
- **Status**: Migrando todos os apps para Riverpod
- **Referência**: `.claude/guides/MIGRATION_PROVIDER_TO_RIVERPOD.md`

### **Arquitetura**
- **Clean Architecture** (Presentation/Domain/Data)
- **Repository Pattern** (Hive local + Firebase remote)
- **SOLID Principles** com Specialized Services
- **Error Handling**: Either<Failure, T> (dartz) - **OBRIGATÓRIO**

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

---

## 🏆 Gold Standard de Qualidade

### **app-plantis: 10/10 Quality Score** (Arquitetura de Referência)

**Métricas:**
- ✅ 0 erros analyzer
- ✅ 0 critical warnings
- ✅ 13 testes unitários (100% pass rate)
- ✅ Clean Architecture rigorosa
- ✅ SOLID Principles (Specialized Services)
- ✅ Either<Failure, T> em toda camada de domínio
- ✅ README profissional com documentação completa

**Próximo passo**: Migrar para Riverpod mantendo qualidade 10/10

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

### **🔄 Migração Provider → Riverpod (Em Andamento)**

**Status**: Fase de preparação
- ✅ Agentes atualizados para padrão Riverpod-only
- ✅ Guia de migração criado (`.claude/guides/MIGRATION_PROVIDER_TO_RIVERPOD.md`)
- 🔄 Iniciando migração dos apps

**Ordem de Migração**:
1. app-taskolist (2h) - Menor esforço
2. app-petiveti (4-6h) - Consolidar padrão
3. app-receituagro (6-8h) - Aplicar aprendizados
4. app-gasometer (8-12h) - Médio/Grande porte
5. app-agrihurbi (6-8h) - Remover Provider misto
6. app-plantis (12-16h) - Gold Standard (migração cuidadosa)

**Tempo Total Estimado**: 40-50 horas (1-2 semanas)

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

### **Guias Técnicos**
- `.claude/guides/MIGRATION_PROVIDER_TO_RIVERPOD.md` - Guia completo de migração
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
# (Ver .claude/guides/MIGRATION_PROVIDER_TO_RIVERPOD.md - Fase 1)

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