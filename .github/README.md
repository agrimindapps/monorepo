# 🤖 GitHub Copilot - Recursos Avançados para Monorepo Flutter

Este diretório contém configurações avançadas do GitHub Copilot para maximizar produtividade no desenvolvimento do monorepo.

## 📁 Estrutura

```
.github/
├── agents/              # Agentes especializados (@agent-name)
├── chatmodes/           # Modos de contexto especializados
├── prompts/             # Prompts reutilizáveis estruturados
├── workflows/           # GitHub Actions automatizados
├── COPILOT_GUIDE.md    # Guia completo de uso
└── README.md           # Este arquivo
```

## 🚀 Quick Start

### 1. **Chat Modes** - Contextos Especializados

Ative um chat mode para otimizar respostas do Copilot:

- 🧪 **Testing & TDD**: Criar testes, seguir TDD
- 🐛 **Debugging Expert**: Resolver bugs complexos
- ♻️ **Refactoring Specialist**: Melhorar código, aplicar patterns
- 📝 **Documentation Master**: Criar/melhorar docs
- ⚡ **Performance Optimizer**: Otimizar performance
- 🔒 **Security Auditor**: Auditar segurança
- 🏢 **Monorepo Orchestrator**: Operações cross-app
- 🔄 **Riverpod Migration**: Migrar Provider→Riverpod

**Como usar:**
1. Abra Copilot Chat
2. Clique no ícone de modo (📋)
3. Selecione o chat mode
4. Faça suas perguntas nesse contexto

---

### 2. **Agentes** - Especialistas Direcionados

Invoque agentes específicos via `@agent-name`:

- `@analyzer-fixer`: Corrigir analyzer warnings
- `@quick-fix-agent`: Fixes pontuais rápidos
- `@code-intelligence`: Análise de código (profunda/rápida)
- `@flutter-architect`: Decisões arquiteturais
- `@flutter-engineer`: Desenvolvimento completo
- `@feature-planner`: Planejamento ágil
- `@specialized-auditor`: Auditorias especializadas
- `@project-orchestrator`: Coordenação de workflows

**Como usar:**
```
@feature-planner Planejar feature de notificações push cross-app
```

---

### 3. **Prompts** - Templates Estruturados

Use prompts para tarefas estruturadas:

- 🏗️ `implementar_feature_completa`: Feature com Clean Architecture
- 🧪 `criar_testes_unitarios`: Testes completos com TDD
- 📦 `criar_package_compartilhado`: Novo package no monorepo
- ♻️ `refatorar_arquivo`: Refatoração segura

**Como usar:**
1. `Cmd+Shift+P` → "Copilot: Open Prompt Library"
2. Selecione prompt
3. Preencha informações
4. Siga guia

---

### 4. **Workflows** - Automação CI/CD

Workflows automatizados executam:

- ✅ `quality_gates.yml`: Valida qualidade em PRs
- 🧪 `automated_tests.yml`: Testes automáticos com coverage
- 📦 `dependency_updates.yml`: Updates semanais de deps
- 📊 `code_metrics.yml`: Métricas e quality tracking

---

## 💡 Casos de Uso Comuns

### Implementar Nova Feature

```
1. [Chat Mode: Monorepo Orchestrator]
   @feature-planner Planejar feature X

2. [Prompt: implementar_feature_completa]
   Seguir guia passo-a-passo

3. [Chat Mode: Testing & TDD]
   Criar testes unitários

4. Quality gates validam automaticamente no PR
```

---

### Resolver Bug

```
1. [Chat Mode: Debugging Expert]
   "Analisar stack trace: [colar]"

2. @code-intelligence Investigar módulo

3. @quick-fix-agent Aplicar correção

4. [Chat Mode: Testing & TDD]
   "Criar teste de regressão"
```

---

### Refatorar Código

```
1. @code-intelligence Analisar código atual

2. [Chat Mode: Refactoring Specialist]
   "Aplicar pattern X"

3. Validar com testes existentes

4. Quality gates garantem qualidade
```

---

### Migrar para Riverpod

```
1. [Chat Mode: Riverpod Migration]
   "Setup inicial para app X"

2. @project-orchestrator Coordenar migração incremental

3. Validação automática em cada fase
```

---

## 📊 Padrões do Monorepo

Todas as configurações seguem os padrões estabelecidos:

### Arquitetura
- **Clean Architecture** (domain/data/presentation)
- **Repository Pattern**
- **Specialized Services** (app-plantis gold standard)

### State Management
- **Riverpod** com code generation
- **AsyncValue<T>** para estados async
- **Either<Failure, T>** para error handling

### Testing
- **Mocktail** para mocking
- **Arrange-Act-Assert** pattern
- Coverage mínimo 70%

### Quality
- Max 500 linhas por arquivo
- Max 50 linhas por método
- 0 analyzer errors em produção

---

## 📚 Documentação Completa

Para guia detalhado, veja:

**[📖 COPILOT_GUIDE.md](COPILOT_GUIDE.md)**

Contém:
- Explicação detalhada de cada recurso
- Exemplos práticos
- Workflows recomendados
- Best practices
- Troubleshooting

---

## 🎯 Benefícios

### Antes
- ⏱️ Features levavam 3-5 dias
- 📉 Coverage ~50%
- 🐛 Muitos bugs
- 📝 Documentação incompleta
- ♻️ Código duplicado

### Com Copilot Otimizado
- ⚡ Features em 1-2 dias
- 📈 Coverage >80%
- 🎯 Menos bugs (testes + qualidade)
- 📚 Documentação completa
- 🔄 Reutilização via core package

---

## 🔄 Manutenção

### Adicionar Novo Chat Mode

```markdown
---
description: 'Descrição do modo'
tools: ['edit', 'search', 'runTests']
---

Instruções para o Copilot neste modo...
```

Salvar em `.github/chatmodes/Nome.chatmode.md`

---

### Adicionar Novo Agente

```markdown
---
name: agent-name
description: Breve descrição
---

Persona e instruções do agente...
```

Salvar em `.github/agents/agent-name.md`

---

### Adicionar Novo Prompt

```markdown
---
mode: agent
---

# Título do Prompt

Instruções estruturadas...
```

Salvar em `.github/prompts/nome_prompt.prompt.md`

---

### Adicionar Workflow

```yaml
name: Nome do Workflow
on: [push, pull_request]
jobs:
  # Definição dos jobs
```

Salvar em `.github/workflows/nome.yml`

---

## 🆘 Suporte

**Problemas ou dúvidas?**

1. Consulte [COPILOT_GUIDE.md](COPILOT_GUIDE.md)
2. Verifique documentação específica de cada recurso
3. Abra issue no repositório

---

## 📈 Roadmap

### Próximas Melhorias

- [ ] Chat mode para **Code Review Automation**
- [ ] Agente para **Migration Planning** (não só Riverpod)
- [ ] Prompt para **API Integration** (REST/GraphQL)
- [ ] Workflow para **Automated Release** com changelogs
- [ ] Chat mode para **Accessibility Audit**
- [ ] Agente para **i18n/l10n Management**

---

## 🎓 Recursos de Aprendizado

- [GitHub Copilot Docs](https://docs.github.com/copilot)
- [Flutter Best Practices](https://flutter.dev/docs/development/best-practices)
- [Clean Architecture Flutter](https://github.com/ResoCoder/flutter-tdd-clean-architecture)
- [Riverpod Documentation](https://riverpod.dev)

---

**Última atualização:** 2024  
**Versão:** 2.0  
**Mantido por:** Agrimind Solutions
