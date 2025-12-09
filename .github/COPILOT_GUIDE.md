# 🤖 Guia Completo - GitHub Copilot para Monorepo Flutter

Este guia ensina como maximizar sua produtividade usando os recursos avançados do GitHub Copilot configurados neste monorepo.

## 📚 Índice

1. [Visão Geral](#-visão-geral)
2. [Chat Modes](#-chat-modes---contextos-especializados)
3. [Agentes Especializados](#-agentes-especializados)
4. [Prompts Estruturados](#-prompts-estruturados)
5. [Workflows Recomendados](#-workflows-recomendados)
6. [Casos de Uso Práticos](#-casos-de-uso-práticos)
7. [Dicas Avançadas](#-dicas-avançadas)
8. [Troubleshooting](#-troubleshooting)

---

## 🎯 Visão Geral

O repositório possui 4 tipos de recursos do GitHub Copilot:

### 🎭 **Chat Modes** (8 modos)
Contextos especializados que otimizam as respostas do Copilot para tarefas específicas.

### 🤖 **Agentes** (5 agentes custom)
Especialistas que podem ser invocados diretamente via `@agent-name`.

### 📝 **Prompts** (4 templates)
Guias estruturados passo-a-passo para tarefas complexas.

### ⚙️ **Workflows** (GitHub Actions)
Automações de CI/CD que validam qualidade e executam testes.

---

## 🎭 Chat Modes - Contextos Especializados

Chat modes mudam o comportamento do Copilot para se especializar em determinadas tarefas.

### Como Usar Chat Modes

1. **Abra o GitHub Copilot Chat** (VS Code: `Cmd/Ctrl + Shift + I`)
2. **Clique no ícone de modo** (📋 no topo do chat)
3. **Selecione o chat mode** apropriado
4. **Faça suas perguntas** - o Copilot responderá com contexto especializado

---

### 1. 🧪 Testing & TDD

**Quando usar:**
- Criar testes unitários, widgets ou de integração
- Seguir Test-Driven Development (TDD)
- Aumentar cobertura de testes
- Debugar testes que falharam

**O que ele faz:**
- Sugere estrutura de testes (Arrange-Act-Assert)
- Usa Mocktail para mocking (padrão do monorepo)
- Garante cobertura adequada (>80%)
- Nomeia testes descritivamente

**Exemplo de uso:**
```
[Ative: Testing & TDD Mode]

"Criar testes unitários para o use case GetPlantById em app-plantis"

→ Copilot criará testes com:
  - Setup de mocks
  - Casos de sucesso
  - Casos de erro
  - Validações
  - Coverage adequado
```

**Comandos úteis:**
- `flutter test` - Rodar todos os testes
- `flutter test --coverage` - Gerar relatório de cobertura
- `flutter test test/path/file_test.dart` - Rodar teste específico

---

### 2. 🐛 Debugging Expert

**Quando usar:**
- Investigar bugs complexos
- Analisar stack traces
- Entender comportamentos inesperados
- Resolver crashes

**O que ele faz:**
- Analisa stack traces detalhadamente
- Identifica causas raiz
- Sugere soluções específicas
- Propõe testes de regressão

**Exemplo de uso:**
```
[Ative: Debugging Expert Mode]

"Analisando este stack trace:
[colar stack trace aqui]

Aplicação crasheia ao salvar planta com imagem"

→ Copilot analisará:
  - Linha exata do problema
  - Causa provável (ex: null pointer, async issue)
  - Solução passo-a-passo
  - Como prevenir no futuro
```

---

### 3. ♻️ Refactoring Specialist

**Quando usar:**
- Melhorar código existente
- Aplicar design patterns
- Eliminar code smells
- Reduzir complexidade

**O que ele faz:**
- Identifica oportunidades de refatoração
- Sugere patterns apropriados
- Mantém comportamento existente
- Garante backwards compatibility

**Exemplo de uso:**
```
[Ative: Refactoring Specialist Mode]

"Refatorar este provider legado para usar Riverpod code generation:
[colar código aqui]"

→ Copilot gerará:
  - Código migrado para @riverpod
  - Mantendo mesma funcionalidade
  - Seguindo padrões do monorepo
  - Com type safety melhorado
```

---

### 4. 📝 Documentation Master

**Quando usar:**
- Criar documentação de código
- Escrever READMEs
- Documentar features
- Criar guias técnicos

**O que ele faz:**
- Gera documentação clara e completa
- Segue padrões do monorepo
- Inclui exemplos práticos
- Adiciona diagramas quando apropriado

**Exemplo de uso:**
```
[Ative: Documentation Master Mode]

"Criar documentação completa para a feature de sistema de favoritos em app-plantis"

→ Copilot criará:
  - README.md na pasta da feature
  - Descrição de regras de negócio
  - Diagramas de arquitetura
  - Exemplos de uso
  - Salva em apps/app-plantis/docs/features/favorites/
```

---

### 5. ⚡ Performance Optimizer

**Quando usar:**
- Otimizar código lento
- Reduzir uso de memória
- Melhorar responsividade da UI
- Eliminar rebuilds desnecessários

**O que ele faz:**
- Identifica gargalos de performance
- Sugere otimizações específicas
- Propõe uso de memoization/caching
- Recomenda profiling tools

**Exemplo de uso:**
```
[Ative: Performance Optimizer Mode]

"Lista de plantas está lenta com 100+ itens. Como otimizar?"

→ Copilot sugerirá:
  - ListView.builder ao invés de Column
  - Image caching adequado
  - Provider optimization (autoDispose)
  - Lazy loading
  - Profiling com DevTools
```

---

### 6. 🔒 Security Auditor

**Quando usar:**
- Auditar código para vulnerabilidades
- Validar inputs do usuário
- Revisar implementações de auth
- Checar exposição de dados sensíveis

**O que ele faz:**
- Identifica vulnerabilidades de segurança
- Sugere sanitização de inputs
- Valida implementações de auth
- Recomenda best practices

**Exemplo de uso:**
```
[Ative: Security Auditor Mode]

"Auditar este código de login:
[colar código aqui]"

→ Copilot verificará:
  - Armazenamento seguro de credenciais
  - Validação de inputs
  - Proteção contra injection
  - Uso correto de Firebase Auth
```

---

### 7. 🏢 Monorepo Orchestrator

**Quando usar:**
- Operações que afetam múltiplos apps
- Extrair código para core package
- Coordenar features cross-app
- Migrations em larga escala

**O que ele faz:**
- Entende estrutura do monorepo (10+ apps)
- Coordena mudanças cross-app
- Identifica código duplicado
- Sugere abstrações para core package

**Exemplo de uso:**
```
[Ative: Monorepo Orchestrator Mode]

"Implementar sistema de notificações push que será usado em app-plantis, app-gasometer e app-petiveti"

→ Copilot planejará:
  - Service no packages/core
  - Interface comum
  - Implementação por app
  - Coordenação da integração
```

---

### 8. 🔄 Riverpod Migration

**Quando usar:**
- Migrar código legado para Riverpod
- Converter ChangeNotifier → Riverpod
- Atualizar providers antigos
- Aplicar code generation

**O que ele faz:**
- Converte providers legados
- Aplica @riverpod annotation
- Gera código com build_runner
- Mantém funcionalidade existente

**Exemplo de uso:**
```
[Ative: Riverpod Migration Mode]

"Migrar este ChangeNotifierProvider para Riverpod code generation:
[colar código aqui]"

→ Copilot migrará:
  - ChangeNotifier → @riverpod class
  - StateProvider → @riverpod
  - Gera .g.dart files
  - Atualiza widgets para Consumer
```

---

## 🤖 Agentes Especializados

Agentes são especialistas que você invoca diretamente via `@agent-name` no chat do Copilot.

### Como Usar Agentes

```
@agent-name sua pergunta ou comando aqui
```

**Diferença entre Chat Modes e Agentes:**
- **Chat Modes**: Mudam o contexto geral do chat
- **Agentes**: São invocados pontualmente para tarefas específicas

---

### Agentes Disponíveis

#### 1. `@flutter-architect`
**Especialidade:** Arquitetura e planejamento estrutural

**Quando usar:**
- Decisões arquiteturais importantes
- Planejamento de features complexas
- Estruturação de módulos
- Refatorações arquiteturais

**Exemplo:**
```
@flutter-architect 

Preciso implementar um sistema de pagamentos com RevenueCat que será usado em 5 apps do monorepo. Como estruturar a arquitetura?
```

**Resposta esperada:**
- Estrutura de pastas
- Separação de responsabilidades
- Interfaces e abstrações
- Plano de implementação

---

#### 2. `@flutter-code-fixer`
**Especialidade:** Correção de código e analyzer warnings

**Quando usar:**
- Corrigir analyzer warnings
- Fixes pontuais e rápidos
- Ajustes de qualidade
- Limpeza de código

**Exemplo:**
```
@flutter-code-fixer

Tenho 15 analyzer warnings no app-gasometer relacionados a tipos nullable. Corrigir todos.
```

**Resposta esperada:**
- Identificação dos warnings
- Correção automática
- Validação com analyzer
- Relatório de qualidade

---

#### 3. `@flutter-ux-designer`
**Especialidade:** UX/UI e design de interfaces

**Quando usar:**
- Melhorias de usabilidade
- Design de telas
- Acessibilidade
- Design responsivo

**Exemplo:**
```
@flutter-ux-designer

Avaliar a tela de lista de plantas e sugerir melhorias de UX. Foco em usabilidade mobile.
```

**Resposta esperada:**
- Análise de usabilidade
- Sugestões de melhorias
- Material Design best practices
- Código de implementação

---

#### 4. `@monorepo-orchestrator`
**Especialidade:** Coordenação cross-app

**Quando usar:**
- Features que afetam múltiplos apps
- Extrações para core package
- Migrations coordenadas
- Consistência entre apps

**Exemplo:**
```
@monorepo-orchestrator

Extrair lógica de autenticação dos 3 apps para o core package, mantendo compatibilidade.
```

**Resposta esperada:**
- Plano de extração
- Impacto em cada app
- Timeline de implementação
- Testes de validação

---

## 📝 Prompts Estruturados

Prompts são guias passo-a-passo para tarefas complexas. Eles ficam na biblioteca de prompts do Copilot.

### Como Usar Prompts

1. **Abra a biblioteca de prompts:**
   - VS Code: `Cmd/Ctrl + Shift + P`
   - Digite: "Copilot: Open Prompt Library"

2. **Selecione o prompt** desejado

3. **Preencha as informações** solicitadas

4. **Siga o guia** passo-a-passo

---

### Prompts Disponíveis

#### 1. 📦 `implementar_feature_completa`

**Descrição:** Guia completo para implementar feature com Clean Architecture

**Quando usar:**
- Criar nova feature do zero
- Seguir Clean Architecture rigorosamente
- Implementação end-to-end

**O que ele pede:**
- Nome da feature
- App target
- Descrição
- Complexidade (Simples/Média/Alta)
- Cross-app? (S/N)

**O que ele gera:**
- Estrutura completa de pastas
- Domain layer (entities, repositories, use cases)
- Data layer (models, datasources, repository impl)
- Presentation layer (providers, pages, widgets)
- Testes unitários
- Configuração de DI

**Exemplo de uso:**
```
[Prompt: implementar_feature_completa]

Nome da Feature: Sistema de Favoritos
App Target: app-plantis
Descrição: Permitir usuários favoritarem plantas
Complexidade: Média
Cross-App: N

→ Gerará todos os arquivos necessários com código completo
```

---

#### 2. 🧪 `criar_testes_unitarios`

**Descrição:** Criar testes unitários completos com TDD

**Quando usar:**
- Adicionar testes a código existente
- Seguir TDD
- Aumentar cobertura

**O que ele pede:**
- Arquivo/classe a testar
- Tipo de teste (unit/widget/integration)
- Coverage desejado

**O que ele gera:**
- Arquivo de teste estruturado
- Setup de mocks com Mocktail
- Casos de teste (success + failures)
- Assertions apropriadas
- Coverage report

---

#### 3. 📦 `criar_package_compartilhado`

**Descrição:** Criar novo package no monorepo

**Quando usar:**
- Código será usado em 2+ apps
- Criar abstração compartilhada
- Extrair funcionalidade comum

**O que ele pede:**
- Nome do package
- Descrição
- Apps que usarão

**O que ele gera:**
- Estrutura de package
- pubspec.yaml configurado
- README.md
- Exemplo de uso
- Testes básicos

---

#### 4. ♻️ `refatorar_arquivo`

**Descrição:** Refatoração segura e estruturada

**Quando usar:**
- Melhorar código existente
- Aplicar patterns
- Reduzir complexidade

**O que ele pede:**
- Arquivo a refatorar
- Objetivo da refatoração
- Patterns a aplicar

**O que ele gera:**
- Código refatorado
- Mantém funcionalidade
- Testes de validação
- Diff das mudanças

---

## 🔄 Workflows Recomendados

Sequências otimizadas de uso dos recursos para tarefas comuns.

### Workflow 1: Implementar Nova Feature

```
┌─────────────────────────────────────────┐
│ 1. Planejamento                         │
├─────────────────────────────────────────┤
│ Chat Mode: Monorepo Orchestrator        │
│ Comando: "Planejar feature X"           │
│                                         │
│ OU                                      │
│                                         │
│ Agent: @flutter-architect               │
│ Comando: "Arquitetura para feature X"   │
└─────────────────────────────────────────┘
                ↓
┌─────────────────────────────────────────┐
│ 2. Implementação                        │
├─────────────────────────────────────────┤
│ Prompt: implementar_feature_completa    │
│ - Preencher informações                 │
│ - Seguir guia passo-a-passo            │
│ - Gerar código                          │
└─────────────────────────────────────────┘
                ↓
┌─────────────────────────────────────────┐
│ 3. Testes                               │
├─────────────────────────────────────────┤
│ Chat Mode: Testing & TDD                │
│ Comando: "Criar testes para feature X"  │
│                                         │
│ OU                                      │
│                                         │
│ Prompt: criar_testes_unitarios         │
└─────────────────────────────────────────┘
                ↓
┌─────────────────────────────────────────┐
│ 4. Validação                            │
├─────────────────────────────────────────┤
│ - flutter analyze                       │
│ - flutter test                          │
│ - Quality gates (PR automático)         │
└─────────────────────────────────────────┘
```

---

### Workflow 2: Resolver Bug

```
┌─────────────────────────────────────────┐
│ 1. Investigação                         │
├─────────────────────────────────────────┤
│ Chat Mode: Debugging Expert             │
│ Comando: "Analisar stack trace: [colar]"│
└─────────────────────────────────────────┘
                ↓
┌─────────────────────────────────────────┐
│ 2. Análise de Código                    │
├─────────────────────────────────────────┤
│ Agent: @flutter-code-fixer              │
│ Comando: "Investigar módulo X"          │
└─────────────────────────────────────────┘
                ↓
┌─────────────────────────────────────────┐
│ 3. Correção                             │
├─────────────────────────────────────────┤
│ Agent: @flutter-code-fixer              │
│ Comando: "Aplicar correção"             │
└─────────────────────────────────────────┘
                ↓
┌─────────────────────────────────────────┐
│ 4. Teste de Regressão                   │
├─────────────────────────────────────────┤
│ Chat Mode: Testing & TDD                │
│ Comando: "Criar teste de regressão"     │
└─────────────────────────────────────────┘
```

---

### Workflow 3: Refatoração

```
┌─────────────────────────────────────────┐
│ 1. Análise                              │
├─────────────────────────────────────────┤
│ Comando: "Analisar código atual"        │
│ Identificar code smells                 │
└─────────────────────────────────────────┘
                ↓
┌─────────────────────────────────────────┐
│ 2. Planejamento                         │
├─────────────────────────────────────────┤
│ Chat Mode: Refactoring Specialist       │
│ Comando: "Planejar refatoração"         │
└─────────────────────────────────────────┘
                ↓
┌─────────────────────────────────────────┐
│ 3. Execução                             │
├─────────────────────────────────────────┤
│ Prompt: refatorar_arquivo               │
│ - Definir objetivo                      │
│ - Aplicar patterns                      │
└─────────────────────────────────────────┘
                ↓
┌─────────────────────────────────────────┐
│ 4. Validação                            │
├─────────────────────────────────────────┤
│ - Rodar testes existentes               │
│ - Verificar comportamento               │
│ - Quality gates                         │
└─────────────────────────────────────────┘
```

---

### Workflow 4: Migração Riverpod

```
┌─────────────────────────────────────────┐
│ 1. Setup                                │
├─────────────────────────────────────────┤
│ Chat Mode: Riverpod Migration           │
│ Comando: "Setup inicial para app X"     │
└─────────────────────────────────────────┘
                ↓
┌─────────────────────────────────────────┐
│ 2. Análise                              │
├─────────────────────────────────────────┤
│ Identificar providers legados           │
│ Planejar ordem de migração              │
└─────────────────────────────────────────┘
                ↓
┌─────────────────────────────────────────┐
│ 3. Migração Incremental                 │
├─────────────────────────────────────────┤
│ Para cada módulo:                       │
│ - Migrar providers                      │
│ - Rodar build_runner                    │
│ - Validar com testes                    │
└─────────────────────────────────────────┘
                ↓
┌─────────────────────────────────────────┐
│ 4. Validação Final                      │
├─────────────────────────────────────────┤
│ - 0 analyzer errors                     │
│ - Todos testes passando                 │
│ - Performance mantida                   │
└─────────────────────────────────────────┘
```

---

## 💡 Casos de Uso Práticos

### Caso 1: "Preciso criar uma feature de notificações"

**Objetivo:** Implementar sistema de notificações push

**Workflow sugerido:**

1. **Planejamento:**
```
@flutter-architect

Implementar sistema de notificações push que será usado em app-plantis (lembretes de rega), app-gasometer (manutenção) e app-petiveti (veterinário). Como estruturar?
```

2. **Implementação Core:**
```
[Prompt: criar_package_compartilhado]
Nome: notifications_service
Descrição: Service compartilhado para notificações push
Apps: app-plantis, app-gasometer, app-petiveti
```

3. **Implementação por App:**
```
[Prompt: implementar_feature_completa]
Feature: Sistema de Notificações
App: app-plantis
Cross-app: Sim (usa notifications_service)
```

4. **Testes:**
```
[Chat Mode: Testing & TDD]
Criar testes unitários para NotificationsService
```

---

### Caso 2: "App está lento, preciso otimizar"

**Objetivo:** Melhorar performance da aplicação

**Workflow sugerido:**

1. **Análise:**
```
[Chat Mode: Performance Optimizer]

App-plantis está lento ao carregar lista de 200+ plantas. Logs mostram múltiplos rebuilds. Como diagnosticar?
```

2. **Profiling:**
```
[Seguir recomendações do Copilot]
- Usar DevTools
- Identificar rebuilds
- Medir tempo de build
```

3. **Otimização:**
```
[Chat Mode: Performance Optimizer]

Otimizar PlantsListPage:
[colar código atual]

Problemas identificados:
- Column ao invés de ListView
- Imagens sem cache
- Provider sem autoDispose
```

4. **Validação:**
```
[Chat Mode: Testing & TDD]
Criar testes de performance para garantir <100ms de render
```

---

### Caso 3: "Preciso migrar código legado"

**Objetivo:** Migrar ChangeNotifier para Riverpod

**Workflow sugerido:**

1. **Setup:**
```
[Chat Mode: Riverpod Migration]

Setup dependencies para migração em app-agrihurbi:
- riverpod_annotation
- build_runner
- riverpod_generator
```

2. **Análise:**
```
[Chat Mode: Riverpod Migration]

Analisar providers legados em app-agrihurbi:
- Quantos ChangeNotifierProvider?
- Ordem de migração recomendada?
- Riscos identificados?
```

3. **Migração:**
```
[Para cada provider]
[Chat Mode: Riverpod Migration]

Migrar este ChangeNotifierProvider:
[colar código]
```

4. **Validação:**
```
flutter analyze
flutter test
dart run custom_lint
```

---

### Caso 4: "Código tem muitos warnings"

**Objetivo:** Limpar analyzer warnings

**Workflow sugerido:**

1. **Identificação:**
```
flutter analyze > warnings.txt
```

2. **Correção Automática:**
```
@flutter-code-fixer

Tenho estes warnings:
[colar conteúdo de warnings.txt]

Corrigir todos automaticamente, priorizando:
1. Null safety
2. Unused imports
3. Type issues
```

3. **Validação:**
```
flutter analyze
→ 0 issues found ✅
```

---

## 🎓 Dicas Avançadas

### 1. Combine Recursos

**Exemplo:** Feature complexa cross-app

```
1. @flutter-architect - Planejamento arquitetural
2. [Chat Mode: Monorepo Orchestrator] - Coordenação
3. [Prompt: implementar_feature_completa] - Implementação
4. [Chat Mode: Testing & TDD] - Testes
5. @flutter-ux-designer - Polish UI
```

### 2. Use Contexto Adequado

**Bom:** ✅
```
[Chat Mode: Testing & TDD]
Criar testes para GetPlantById use case
```

**Melhor:** ✅✅
```
[Chat Mode: Testing & TDD]
Criar testes para GetPlantById use case em app-plantis.

Contexto:
- Use case retorna Either<Failure, Plant>
- Repository usa Drift + Firebase
- Preciso testar cache fallback
- Usar Mocktail para mocks

Casos esperados:
1. Success - planta existe local
2. Success - planta existe remoto
3. Failure - network error
4. Failure - planta não existe
```

### 3. Aproveite Code Generation

Após usar prompts ou agents que geram código Riverpod:

```bash
# Sempre rodar após gerar providers
dart run build_runner build --delete-conflicting-outputs

# Ou em modo watch durante desenvolvimento
dart run build_runner watch --delete-conflicting-outputs
```

### 4. Valide Sempre

Checklist após usar recursos:

```bash
# 1. Analyzer
flutter analyze

# 2. Testes
flutter test

# 3. Custom Lint (Riverpod)
dart run custom_lint

# 4. Formatação
flutter format .

# 5. Build (se aplicável)
flutter build apk --debug
```

### 5. Documente Decisões

Use Documentation Master para registrar:

```
[Chat Mode: Documentation Master]

Documentar decisão arquitetural:
- Feature: Sistema de Pagamentos
- Decisão: Usar RevenueCat via core package
- Razão: Compartilhamento entre 5 apps
- Alternativas consideradas: In-app billing direto
- Trade-offs: Custo adicional vs tempo economizado

Salvar em: docs/architecture-decisions/
```

---

## 🐛 Troubleshooting

### Problema: "Chat Mode não está funcionando como esperado"

**Solução:**
1. Verifique se selecionou o modo correto (ícone 📋)
2. Modo ativo aparece no topo do chat
3. Reinicie o chat se necessário
4. Forneça contexto adicional na pergunta

---

### Problema: "Agente não está respondendo"

**Solução:**
1. Verifique sintaxe: `@agent-name` (com @)
2. Confira se agente existe (veja lista acima)
3. Forneça contexto claro e completo
4. Seja específico no comando

**Exemplo ruim:** ❌
```
@flutter-architect ajuda
```

**Exemplo bom:** ✅
```
@flutter-architect

Preciso implementar autenticação com Firebase Auth e Biometria em app-plantis. Como estruturar a arquitetura seguindo Clean Architecture?

Requisitos:
- Login com email/senha
- Login biométrico
- Recuperação de senha
- Remember me
- Logout
```

---

### Problema: "Prompt não aparece na biblioteca"

**Solução:**
1. Verifique em `.github/prompts/`
2. Arquivo deve ter extensão `.prompt.md`
3. Deve ter frontmatter correto:
```markdown
---
mode: agent
---
```
4. Reinicie VS Code se necessário

---

### Problema: "Código gerado não compila"

**Solução:**
1. Rode build_runner:
```bash
dart run build_runner build --delete-conflicting-outputs
```

2. Verifique imports:
```bash
flutter analyze
```

3. Limpe e reconstrua:
```bash
flutter clean
flutter pub get
```

4. Se usar Riverpod, verifique annotations:
```dart
// ✅ Correto
@riverpod
class MyNotifier extends _$MyNotifier {
  // ...
}

// ❌ Errado
class MyNotifier extends StateNotifier<State> {
  // ...
}
```

---

### Problema: "Testes não estão passando"

**Solução:**
1. Use Testing & TDD Mode para diagnosticar:
```
[Chat Mode: Testing & TDD]

Estes testes estão falhando:
[colar output do flutter test]

Código sendo testado:
[colar código]
```

2. Verifique mocks:
```dart
// Setup correto de mock
when(() => mockRepository.getPlant(any()))
    .thenAnswer((_) async => Right(tPlant));
```

3. Verifique async/await:
```dart
// ✅ Correto
test('should work', () async {
  final result = await useCase(params);
  expect(result, expectedValue);
});

// ❌ Errado
test('should work', () {
  final result = useCase(params); // Faltou await
  expect(result, expectedValue);
});
```

---

### Problema: "Quality gates falharam no PR"

**Solução:**
1. Veja logs do workflow no GitHub Actions
2. Corrija localmente antes de push:
```bash
# Analyzer
flutter analyze

# Testes
flutter test

# Formatação
flutter format .

# Custom lint
dart run custom_lint
```

3. Use agent para correção:
```
@flutter-code-fixer

Quality gates falharam com estes erros:
[colar output do GitHub Actions]
```

---

## 📊 Métricas de Sucesso

### Antes do GitHub Copilot Otimizado

- ⏱️ Feature completa: **3-5 dias**
- 📉 Test coverage: **~50%**
- 🐛 Bugs encontrados em produção: **Alto**
- 📝 Documentação: **Incompleta/Desatualizada**
- ♻️ Código duplicado: **Frequente**
- 🔄 Refatorações: **Raras e arriscadas**

### Depois do GitHub Copilot Otimizado

- ⚡ Feature completa: **1-2 dias** (50% mais rápido)
- 📈 Test coverage: **>80%** (consistente)
- 🎯 Bugs encontrados em produção: **Baixo**
- 📚 Documentação: **Completa e atualizada**
- 🔄 Código compartilhado: **core package**
- ♻️ Refatorações: **Seguras e frequentes**

---

## 🚀 Próximos Passos

### Para Iniciantes
1. Comece com **Chat Modes simples** (Testing, Documentation)
2. Experimente **Prompts estruturados**
3. Pratique workflows básicos
4. Leia [CLAUDE.md](../CLAUDE.md) para entender padrões do monorepo

### Para Usuários Intermediários
1. Combine **múltiplos recursos** em workflows
2. Use **agentes especializados**
3. Crie seus próprios **prompts customizados**
4. Contribua com **novos chat modes**

### Para Usuários Avançados
1. Otimize **workflows complexos**
2. Crie **novos agentes**
3. Implemente **custom GitHub Actions**
4. Documente **best practices**

---

## 📚 Recursos Adicionais

### Documentação do Monorepo
- [CLAUDE.md](../CLAUDE.md) - Padrões e configurações
- [README.md](../README.md) - Visão geral do monorepo
- [.claude/docs/](../.claude/docs/) - Documentação técnica detalhada

### Documentação Externa
- [GitHub Copilot Docs](https://docs.github.com/copilot)
- [Flutter Best Practices](https://flutter.dev/docs/development/best-practices)
- [Riverpod Documentation](https://riverpod.dev)
- [Clean Architecture](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)

### Apps de Referência
- **app-plantis** - Gold standard (10/10 quality)
- **app-nebulalist** - Pure Riverpod implementation
- **app-receituagro** - Riverpod 3.0 migration complete

---

## 🤝 Contribuindo

### Adicionar Novo Chat Mode

```markdown
---
description: 'Descrição breve do modo'
tools: ['edit', 'search', 'runTests']
---

Instruções detalhadas para o Copilot neste modo...
```

Salvar em: `.github/chatmodes/Nome.chatmode.md`

### Adicionar Novo Agente

```markdown
---
name: agent-name
description: Breve descrição
---

Persona e instruções do agente...
```

Salvar em: `.github/agents/agent-name.md`

### Adicionar Novo Prompt

```markdown
---
mode: agent
---

# Título do Prompt

Instruções passo-a-passo...
```

Salvar em: `.github/prompts/nome_prompt.prompt.md`

---

## 📞 Suporte

**Problemas ou dúvidas?**

1. Consulte [Troubleshooting](#-troubleshooting) acima
2. Verifique [documentação específica](../.claude/docs/)
3. Abra issue no repositório com label `copilot`

---

## 🎯 Conclusão

Os recursos do GitHub Copilot configurados neste repositório foram projetados para maximizar produtividade no desenvolvimento Flutter. Use-os de forma estratégica:

✅ **Chat Modes** para contexto especializado
✅ **Agentes** para tarefas pontuais específicas  
✅ **Prompts** para workflows estruturados
✅ **Combine recursos** para máxima eficiência

**Resultado:** Código de qualidade, entregue mais rápido, com menos bugs.

---

**Última atualização:** Dezembro 2024  
**Versão:** 1.0  
**Mantido por:** Agrimind Solutions  
**Status:** ✅ Ativo
