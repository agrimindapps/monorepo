# 🤖 Guia Completo: GitHub Copilot para Monorepo Flutter

Este guia explica como utilizar todos os recursos do GitHub Copilot configurados para maximizar produtividade no desenvolvimento do monorepo.

## 📚 Índice

1. [Chat Modes](#chat-modes)
2. [Agentes Especializados](#agentes-especializados)
3. [Prompts Reutilizáveis](#prompts-reutilizáveis)
4. [Workflows Automatizados](#workflows-automatizados)
5. [Melhores Práticas](#melhores-práticas)

---

## 🎯 Chat Modes

Chat modes são contextos especializados que otimizam as respostas do Copilot para tarefas específicas.

### Como Usar

1. No VS Code, abra o painel do GitHub Copilot Chat
2. Clique no ícone de **modo** (📋)
3. Selecione o chat mode apropriado para sua tarefa
4. Faça suas perguntas nesse contexto

### Chat Modes Disponíveis

#### 🧪 Testing & TDD
**Quando usar:** Criar testes unitários, widget tests ou seguir TDD

**Exemplos de uso:**
```
"Criar testes para o VehicleRepository"
"Implementar TDD para a feature de favoritos"
"Como testar este Riverpod provider?"
```

**Ferramentas ativadas:** `edit`, `search`, `problems`, `runTests`

---

#### 🐛 Debugging Expert
**Quando usar:** Resolver bugs complexos, analisar stack traces

**Exemplos de uso:**
```
"Por que estou tendo null pointer exception aqui?"
"Analisar este stack trace do Firebase"
"App está com memory leak, como diagnosticar?"
```

**Ferramentas ativadas:** `edit`, `search`, `problems`, `runCommands`, `changes`

---

#### ♻️ Refactoring Specialist
**Quando usar:** Melhorar código, aplicar design patterns, seguir SOLID

**Exemplos de uso:**
```
"Refatorar este God Class para Specialized Services"
"Aplicar Repository Pattern neste código"
"Extrair este código duplicado para o core package"
```

**Ferramentas ativadas:** `edit`, `search`, `usages`, `runTests`, `problems`

---

#### 📝 Documentation Master
**Quando usar:** Criar ou melhorar documentação

**Exemplos de uso:**
```
"Documentar esta API com DartDoc"
"Criar README para este package"
"Gerar ADR para decisão de usar Riverpod"
```

**Ferramentas ativadas:** `edit`, `search`, `new`, `usages`

---

#### ⚡ Performance Optimizer
**Quando usar:** Otimizar performance, reduzir rebuilds, memory leaks

**Exemplos de uso:**
```
"Por que este widget está rebuilding sempre?"
"Otimizar esta ListView com 1000 itens"
"Reduzir uso de memória deste screen"
```

**Ferramentas ativadas:** `edit`, `search`, `problems`, `runCommands`

---

#### 🔒 Security Auditor
**Quando usar:** Auditar segurança, implementar práticas seguras

**Exemplos de uso:**
```
"Auditar segurança do AuthService"
"Como proteger API keys neste código?"
"Verificar se há dados sensíveis em logs"
```

**Ferramentas ativadas:** `edit`, `search`, `problems`, `usages`

---

#### 🏢 Monorepo Orchestrator
**Quando usar:** Operações cross-app, extrair para core, migração

**Exemplos de uso:**
```
"Extrair NotificationService para core package"
"Implementar feature cross-app de analytics"
"Coordenar migração Provider→Riverpod em todos apps"
```

**Ferramentas ativadas:** `edit`, `search`, `new`, `usages`, `runCommands`

---

#### 🔄 Riverpod Migration
**Quando usar:** Migrar de Provider para Riverpod

**Exemplos de uso:**
```
"Migrar VehicleProvider para Riverpod"
"Converter ChangeNotifier para AsyncNotifier"
"Setup Riverpod code generation"
```

**Ferramentas ativadas:** `edit`, `search`, `usages`, `runCommands`, `problems`

---

## 🤖 Agentes Especializados

Agentes são personas especializadas que você pode invocar diretamente via `@agent-name`.

### Como Usar

Digite `@` no Copilot Chat e selecione o agente desejado.

### Agentes Disponíveis

#### @analyzer-fixer
**Especialidade:** Correção rápida de warnings do flutter analyze

**Use quando:** Tiver muitos analyzer warnings para corrigir

**Exemplo:**
```
@analyzer-fixer Corrigir todos os prefer_const_constructors neste arquivo
```

---

#### @quick-fix-agent
**Especialidade:** Correções pontuais em arquivo único (syntax, imports, formatação)

**Use quando:** Precisar de fix rápido sem análise profunda

**Exemplo:**
```
@quick-fix-agent Otimizar imports e remover código não usado
```

---

#### @code-intelligence
**Especialidade:** Análise profunda ou rápida de código (auto-seleciona)

**Use quando:** Quiser entender código complexo ou fazer code review

**Exemplo:**
```
@code-intelligence Analisar este repository implementation
```

---

#### @flutter-architect
**Especialidade:** Decisões arquiteturais e planejamento estrutural

**Use quando:** Precisar planejar arquitetura de feature complexa

**Exemplo:**
```
@flutter-architect Como estruturar sistema de pagamentos com segurança?
```

---

#### @flutter-engineer
**Especialidade:** Desenvolvimento completo de features (end-to-end)

**Use quando:** Implementar feature completa do zero

**Exemplo:**
```
@flutter-engineer Implementar sistema de chat completo com WebSocket
```

---

#### @feature-planner
**Especialidade:** Planejamento ágil, quebra de tarefas, estimativas

**Use quando:** Quiser planejar implementação de feature

**Exemplo:**
```
@feature-planner Quebrar feature de favoritos em tarefas estimadas
```

---

#### @specialized-auditor
**Especialidade:** Auditoria especializada (security/performance/quality)

**Use quando:** Precisar de auditoria profunda

**Exemplo:**
```
@specialized-auditor Auditar segurança do payment flow
```

---

#### @project-orchestrator
**Especialidade:** Coordenação de workflows complexos e múltiplos agentes

**Use quando:** Tarefa complexa que requer múltiplos especialistas

**Exemplo:**
```
@project-orchestrator Migrar app-gasometer de Provider para Riverpod
```

---

## 📜 Prompts Reutilizáveis

Prompts são templates estruturados para tarefas comuns.

### Como Usar

1. Pressione `Cmd+Shift+P` (Mac) ou `Ctrl+Shift+P` (Windows/Linux)
2. Digite "Copilot: Open Prompt Library"
3. Selecione o prompt desejado
4. Preencha as informações solicitadas

### Prompts Disponíveis

#### 🏗️ implementar_feature_completa
**Descrição:** Guia completo para implementar feature com Clean Architecture

**Use quando:** Criar feature completa do zero

**O que faz:**
- Cria estrutura domain/data/presentation
- Implementa entities, repositories, use cases
- Cria providers Riverpod
- Gera testes unitários
- Segue padrões do monorepo

**Input necessário:**
- Nome da feature
- App target
- Complexidade

---

#### 🧪 criar_testes_unitarios
**Descrição:** Template para criar testes completos seguindo TDD

**Use quando:** Criar testes para código novo ou existente

**O que faz:**
- Cria testes com Mocktail
- Estrutura Arrange-Act-Assert
- Coverage de success e failure cases
- Testes de repository, use case e provider

---

#### 📦 criar_package_compartilhado
**Descrição:** Guia para criar package no packages/

**Use quando:** Extrair código reutilizável para package

**O que faz:**
- Cria estrutura de package
- Configura pubspec.yaml
- Setup de exports
- Documentação
- Integração com melos

---

#### ♻️ refatorar_arquivo
**Descrição:** Refatoração segura de arquivo único

**Use quando:** Melhorar código existente mantendo comportamento

**O que faz:**
- Melhora nomenclatura
- Extrai métodos
- Aplica patterns
- Mantém funcionalidade

---

## ⚙️ Workflows Automatizados

Workflows do GitHub Actions que rodam automaticamente.

### Workflows Configurados

#### 🚦 quality_gates.yml
**Trigger:** Push, PR
**O que faz:** Valida qualidade de código em todos apps

---

#### 🧪 automated_tests.yml
**Trigger:** Push, PR, Diário
**O que faz:**
- Roda testes em matriz (todos apps)
- Gera coverage report
- Valida threshold mínimo (70%)
- Upload para Codecov

---

#### 📦 dependency_updates.yml
**Trigger:** Semanal (Segunda 9h), Manual
**O que faz:**
- Verifica dependências desatualizadas
- Cria report semanal
- Auto-update minor versions
- Security audit

---

#### 📊 code_metrics.yml
**Trigger:** Push main/develop, Semanal (Sexta 18h)
**O que faz:**
- Gera métricas de código
- Analisa complexidade
- Tracking de quality trends
- Report semanal consolidado

---

## 🎯 Melhores Práticas

### 1. **Escolha o Contexto Certo**

❌ **Errado:**
```
"Como criar testes?" (contexto vago)
```

✅ **Correto:**
```
[Ativa Testing & TDD mode]
"Criar testes unitários para VehicleRepository com Mocktail"
```

---

### 2. **Use Agentes Específicos**

❌ **Errado:**
```
"Analisar e refatorar este código" (muito amplo)
```

✅ **Correto:**
```
@code-intelligence Analisar este código
[Depois]
@refactoring-specialist Refatorar baseado na análise
```

---

### 3. **Forneça Contexto**

❌ **Errado:**
```
"Implementar favoritos"
```

✅ **Correto:**
```
@feature-planner Planejar feature de favoritos para app-plantis
- Usuário pode favoritar plantas
- Listar favoritos
- Sincronizar com Firebase
- Complexity: Média
```

---

### 4. **Combine Chat Modes com Agentes**

```
[Ativa Monorepo Orchestrator mode]
@project-orchestrator Extrair NotificationService duplicado em 
app-plantis e app-gasometer para packages/core
```

---

### 5. **Use Prompts para Estrutura**

Para tarefas estruturadas, sempre prefira prompts:

```
1. Abrir prompt "implementar_feature_completa"
2. Preencher informações
3. Seguir guia passo-a-passo
4. Validar com quality gates
```

---

## 🚀 Workflows Recomendados

### Implementar Nova Feature

1. **Planejamento:**
   ```
   [Chat Mode: Monorepo Orchestrator]
   @feature-planner Planejar feature X
   ```

2. **Arquitetura:**
   ```
   @flutter-architect Revisar arquitetura proposta
   ```

3. **Implementação:**
   ```
   [Prompt: implementar_feature_completa]
   Seguir guia passo-a-passo
   ```

4. **Testes:**
   ```
   [Chat Mode: Testing & TDD]
   [Prompt: criar_testes_unitarios]
   ```

5. **Validação:**
   ```
   Quality gates automáticos no PR
   ```

---

### Resolver Bug Complexo

1. **Diagnóstico:**
   ```
   [Chat Mode: Debugging Expert]
   "Analisar stack trace: [colar stack trace]"
   ```

2. **Investigação:**
   ```
   @code-intelligence Analisar módulo onde ocorre o bug
   ```

3. **Fix:**
   ```
   @quick-fix-agent Aplicar correção pontual
   ```

4. **Prevenção:**
   ```
   [Chat Mode: Testing & TDD]
   "Criar teste de regressão para este bug"
   ```

---

### Migrar para Riverpod

1. **Preparação:**
   ```
   [Chat Mode: Riverpod Migration]
   "Setup inicial para migração do app-gasometer"
   ```

2. **Migração Incremental:**
   ```
   @project-orchestrator Coordenar migração bottom-up:
   1. Repositories
   2. Use Cases
   3. Providers
   4. UI
   ```

3. **Validação:**
   ```
   Testes automatizados validam cada fase
   ```

---

### Refatorar God Class

1. **Análise:**
   ```
   @code-intelligence Analisar PlantService (600 linhas)
   ```

2. **Planejamento:**
   ```
   [Chat Mode: Refactoring Specialist]
   "Quebrar em Specialized Services (app-plantis pattern)"
   ```

3. **Execução:**
   ```
   @refactoring-specialist Extrair services um por vez
   ```

4. **Validação:**
   ```
   @testing-tdd Criar testes para cada novo service
   ```

---

## 📈 Medindo Efetividade

### Métricas para Acompanhar

- ⏱️ **Tempo de desenvolvimento:** Feature agora leva X% menos tempo
- 🐛 **Bugs reduzidos:** Menos bugs em produção
- 📊 **Quality score:** Mantém/melhora score de qualidade
- 🧪 **Coverage:** Aumenta coverage de testes
- 📚 **Documentação:** Código melhor documentado

### Antes vs Depois

| Métrica | Antes | Com Copilot Otimizado |
|---------|-------|----------------------|
| Tempo para criar feature | 3-5 dias | 1-2 dias |
| Coverage de testes | 50% | 80%+ |
| Analyzer warnings | Muitos | Poucos |
| Código duplicado | Alto | Baixo (core package) |
| Documentação | Incompleta | Completa |

---

## 🆘 Troubleshooting

### Chat Mode não aparece
- Verifique se arquivo está em `.github/chatmodes/`
- Reinicie VS Code
- Atualize extensão do GitHub Copilot

### Agente não responde
- Verifique se arquivo está em `.github/agents/`
- Use sintaxe correta: `@agent-name` (sem espaços)

### Prompt não aparece
- Verifique se arquivo está em `.github/prompts/`
- Formato deve ser `.prompt.md`

### Workflow não executa
- Verifique sintaxe YAML
- Verifique permissões do repositório
- Ver logs em Actions tab

---

## 📞 Suporte

Para dúvidas ou problemas:

1. Consulte este guia primeiro
2. Veja documentação específica de cada chat mode/agente
3. Abra issue no repositório

---

**Última atualização:** 2024
**Versão:** 2.0
