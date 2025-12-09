# 🗺️ Mapa de Recursos do GitHub Copilot

Guia visual para navegar nos recursos do GitHub Copilot no monorepo.

## 🎯 Começando

```
┌─────────────────────────────────────────────────────────────┐
│                    VOCÊ ESTÁ AQUI                           │
│                         👇                                   │
│              Quer aproveitar o Copilot?                     │
└─────────────────────────────────────────────────────────────┘
                          │
                          ├─── Novo no Copilot? ──────────┐
                          │                               │
                          ├─── Já uso mas quero mais ────┤
                          │                               │
                          └─── Preciso de referência ────┘
                                                          │
                ┌─────────────────────────────────────────┘
                │
                ▼
┌───────────────────────────────────────────────────────────────┐
│                    ESCOLHA SEU CAMINHO                        │
└───────────────────────────────────────────────────────────────┘

    ┌─────────────┐      ┌──────────────┐      ┌─────────────┐
    │  🆕 NOVO    │      │ 📚 COMPLETO  │      │ ⚡ RÁPIDO   │
    │  USUÁRIO    │      │  AVANÇADO    │      │ REFERÊNCIA  │
    └─────────────┘      └──────────────┘      └─────────────┘
          │                     │                     │
          │                     │                     │
          ▼                     ▼                     ▼
    README.md          COPILOT_GUIDE.md     QUICK_START_
                                             COPILOT.md
```

---

## 📚 Guia de Documentos

### 1. 📋 README.md - Ponto de Entrada

**Público:** Todos  
**Tempo de leitura:** 5 minutos  
**Quando usar:** Primeira vez usando os recursos

**Contém:**
- ✅ Visão geral dos recursos
- ✅ Lista de chat modes e agentes
- ✅ Links para documentação detalhada
- ✅ Quick start básico

**Próximo passo:** 
- Novo? → Leia QUICK_START_COPILOT.md
- Experiente? → Vá direto para COPILOT_GUIDE.md

---

### 2. 🚀 QUICK_START_COPILOT.md - Referência Rápida

**Público:** Todos (especialmente uso diário)  
**Tempo de leitura:** 10 minutos  
**Quando usar:** Consulta rápida durante desenvolvimento

**Contém:**
- ✅ Tabelas de referência rápida
- ✅ Comandos essenciais
- ✅ Workflows curtos
- ✅ Checklist diário
- ✅ Problemas comuns e soluções rápidas

**Como usar:**
1. Mantenha aberto em aba do navegador
2. Consulte quando precisar lembrar um comando
3. Use checklist antes de commit
4. Verifique workflows para tarefas comuns

**Próximo passo:**
- Quer detalhes? → COPILOT_GUIDE.md
- Quer exemplos? → COPILOT_EXAMPLES.md

---

### 3. 📖 COPILOT_GUIDE.md - Documentação Completa

**Público:** Intermediário/Avançado  
**Tempo de leitura:** 30-45 minutos  
**Quando usar:** Aprendizado profundo, casos complexos

**Contém:**
- ✅ Explicação detalhada de cada recurso
- ✅ 8 chat modes com exemplos
- ✅ 4 agentes especializados
- ✅ 4 prompts estruturados
- ✅ Workflows completos step-by-step
- ✅ Casos de uso do mundo real
- ✅ Dicas avançadas
- ✅ Troubleshooting completo

**Como usar:**
1. Leia seções conforme necessidade
2. Marque páginas importantes
3. Use como referência para casos complexos
4. Volte quando encontrar problemas

**Seções recomendadas:**
- **Chat Modes** → Entenda cada modo disponível
- **Workflows** → Copie workflows para suas tarefas
- **Dicas Avançadas** → Maximize produtividade
- **Troubleshooting** → Resolva problemas comuns

---

### 4. 💡 COPILOT_EXAMPLES.md - Exemplos Práticos

**Público:** Todos (especialmente iniciantes)  
**Tempo de leitura:** 40-60 minutos (não precisa ler tudo)  
**Quando usar:** Precisa de exemplo concreto, quer copiar código

**Contém:**
- ✅ 10 exemplos completos com código
- ✅ Implementação de features
- ✅ Resolução de bugs reais
- ✅ Testes e TDD
- ✅ Refatoração
- ✅ Migração Riverpod
- ✅ Otimização de performance
- ✅ Cross-app features

**Como usar:**
1. Encontre exemplo similar ao seu caso
2. Copie e adapte o código
3. Siga o workflow do exemplo
4. Valide com os comandos mostrados

**Exemplos mais úteis:**
- **#1 Sistema de Favoritos** → Feature simples end-to-end
- **#3 Null Pointer** → Debugging típico
- **#5 TDD** → Criar código com testes primeiro
- **#7 Migração Riverpod** → Converter código legado

---

### 5. 🗺️ RESOURCES_MAP.md - Este Documento

**Público:** Todos  
**Tempo de leitura:** 10 minutos  
**Quando usar:** Está perdido, não sabe por onde começar

**Contém:**
- ✅ Mapa visual dos recursos
- ✅ Guia de navegação
- ✅ Árvores de decisão
- ✅ Fluxogramas de uso

---

## 🎯 Árvores de Decisão

### "Preciso implementar uma feature"

```
Implementar Feature
       │
       ├─── Feature simples? ────────┐
       │                             │
       └─── Feature complexa? ───────┤
                                     │
       ┌─────────────────────────────┘
       │
       ▼
    É cross-app?
       │
       ├─── Não ─────────────────────┐
       │                             │
       └─── Sim ─────────────────────┤
                                     │
       ┌─────────────────────────────┘
       │
       ▼

┌──────────────────────────────────────────────────────────────┐
│ Feature SIMPLES (single app)                                 │
├──────────────────────────────────────────────────────────────┤
│ 1. [Prompt: implementar_feature_completa]                    │
│ 2. Seguir guia passo-a-passo                                 │
│ 3. [Chat Mode: Testing & TDD] criar testes                   │
│ 4. Validar: flutter analyze && flutter test                  │
└──────────────────────────────────────────────────────────────┘

┌──────────────────────────────────────────────────────────────┐
│ Feature CROSS-APP                                            │
├──────────────────────────────────────────────────────────────┤
│ 1. @monorepo-orchestrator - Planejar                        │
│ 2. [Prompt: criar_package_compartilhado] - Core package     │
│ 3. [Prompt: implementar_feature_completa] por app           │
│ 4. Coordenar integração                                      │
└──────────────────────────────────────────────────────────────┘

┌──────────────────────────────────────────────────────────────┐
│ Feature COMPLEXA                                             │
├──────────────────────────────────────────────────────────────┤
│ 1. @flutter-architect - Arquitetura                         │
│ 2. [Chat Mode: Monorepo Orchestrator] - Coordenação         │
│ 3. Implementação incremental                                 │
│ 4. Validação em cada fase                                    │
└──────────────────────────────────────────────────────────────┘
```

---

### "Encontrei um bug"

```
Bug Encontrado
       │
       ├─── Sei a causa? ────────────┐
       │                             │
       └─── Não sei a causa? ────────┤
                                     │
       ┌─────────────────────────────┘
       │
       ▼

┌──────────────────────────────────────────────────────────────┐
│ CAUSA DESCONHECIDA                                           │
├──────────────────────────────────────────────────────────────┤
│ 1. [Chat Mode: Debugging Expert]                            │
│    "Analisar stack trace: [colar]"                          │
│                                                              │
│ 2. Seguir diagnóstico do Copilot                            │
│                                                              │
│ 3. @flutter-code-fixer                                      │
│    "Investigar módulo X"                                     │
│                                                              │
│ 4. Aplicar correção sugerida                                │
│                                                              │
│ 5. [Chat Mode: Testing & TDD]                               │
│    "Criar teste de regressão"                               │
└──────────────────────────────────────────────────────────────┘

┌──────────────────────────────────────────────────────────────┐
│ CAUSA CONHECIDA                                              │
├──────────────────────────────────────────────────────────────┤
│ 1. @flutter-code-fixer                                      │
│    "Corrigir [descrever problema]"                          │
│                                                              │
│ 2. [Chat Mode: Testing & TDD]                               │
│    "Criar teste de regressão"                               │
│                                                              │
│ 3. Validar correção                                          │
└──────────────────────────────────────────────────────────────┘
```

---

### "Preciso melhorar código existente"

```
Melhorar Código
       │
       ├─── Refatoração? ────────────┐
       │                             │
       ├─── Performance? ─────────────┤
       │                             │
       └─── Migração Riverpod? ──────┤
                                     │
       ┌─────────────────────────────┘
       │
       ▼

┌──────────────────────────────────────────────────────────────┐
│ REFATORAÇÃO                                                  │
├──────────────────────────────────────────────────────────────┤
│ 1. [Chat Mode: Refactoring Specialist]                      │
│    "Analisar código: [colar]"                               │
│                                                              │
│ 2. [Prompt: refatorar_arquivo]                              │
│    - Definir objetivos                                       │
│    - Aplicar patterns                                        │
│                                                              │
│ 3. Validar com testes existentes                            │
└──────────────────────────────────────────────────────────────┘

┌──────────────────────────────────────────────────────────────┐
│ PERFORMANCE                                                  │
├──────────────────────────────────────────────────────────────┤
│ 1. [Chat Mode: Performance Optimizer]                       │
│    "App lento em [cenário]"                                 │
│                                                              │
│ 2. Seguir diagnóstico                                        │
│                                                              │
│ 3. Aplicar otimizações sugeridas                            │
│                                                              │
│ 4. Medir melhoria (DevTools)                                │
└──────────────────────────────────────────────────────────────┘

┌──────────────────────────────────────────────────────────────┐
│ MIGRAÇÃO RIVERPOD                                            │
├──────────────────────────────────────────────────────────────┤
│ 1. [Chat Mode: Riverpod Migration]                          │
│    "Setup inicial"                                           │
│                                                              │
│ 2. Para cada provider:                                       │
│    "Migrar provider: [colar código]"                        │
│                                                              │
│ 3. dart run build_runner build                              │
│                                                              │
│ 4. Validar: flutter analyze && flutter test                 │
└──────────────────────────────────────────────────────────────┘
```

---

## 🎓 Trilhas de Aprendizado

### Trilha 1: Iniciante (2-3 horas)

```
Dia 1: Fundamentos (1h)
├─ 1. Ler README.md (5min)
├─ 2. Ler QUICK_START_COPILOT.md (10min)
├─ 3. Ativar primeiro Chat Mode (5min)
├─ 4. Testar @flutter-code-fixer (10min)
└─ 5. Usar prompt implementar_feature_completa (30min)

Dia 2: Prática (1h)
├─ 1. Ler COPILOT_EXAMPLES.md - Exemplo #1 (15min)
├─ 2. Implementar feature simples (30min)
└─ 3. Criar testes com Testing & TDD mode (15min)

Dia 3: Consolidação (30min)
├─ 1. Revisar workflows no COPILOT_GUIDE.md (15min)
└─ 2. Praticar workflow completo (15min)
```

---

### Trilha 2: Intermediário (4-5 horas)

```
Semana 1: Recursos Avançados
├─ Dia 1: Chat Modes avançados (1h)
│  └─ Testar: Debugging, Performance, Refactoring
│
├─ Dia 2: Agentes especializados (1h)
│  └─ Usar: @flutter-architect, @monorepo-orchestrator
│
├─ Dia 3: Workflows complexos (1h)
│  └─ Feature cross-app, Migração Riverpod
│
├─ Dia 4: Troubleshooting (30min)
│  └─ Resolver problemas comuns
│
└─ Dia 5: Projeto prático (1.5h)
   └─ Implementar feature completa usando recursos
```

---

### Trilha 3: Avançado (ongoing)

```
Mestre do Copilot
├─ Combinar múltiplos recursos
├─ Criar workflows customizados
├─ Contribuir com novos chat modes
├─ Documentar best practices
└─ Mentoriar outros desenvolvedores
```

---

## 📊 Matriz de Recursos por Tarefa

| Tarefa | Chat Mode | Agente | Prompt | Exemplo |
|--------|-----------|--------|--------|---------|
| **Nova feature simples** | - | - | implementar_feature_completa | #1 |
| **Feature cross-app** | Monorepo Orchestrator | @monorepo-orchestrator | criar_package_compartilhado | #2 |
| **Resolver bug** | Debugging Expert | @flutter-code-fixer | - | #3, #4 |
| **Criar testes** | Testing & TDD | - | criar_testes_unitarios | #5 |
| **Refatorar** | Refactoring Specialist | - | refatorar_arquivo | #6 |
| **Migrar Riverpod** | Riverpod Migration | - | - | #7 |
| **Otimizar performance** | Performance Optimizer | - | - | #8 |
| **Documentar** | Documentation Master | - | - | #9 |
| **Extrair para core** | Monorepo Orchestrator | @monorepo-orchestrator | criar_package_compartilhado | #10 |
| **Auditar segurança** | Security Auditor | - | - | - |
| **Melhorar UX** | - | @flutter-ux-designer | - | - |

---

## 🔄 Workflow Diário Recomendado

### Manhã (Planejamento)
```
1. Abrir QUICK_START_COPILOT.md em aba do navegador
2. Revisar tasks do dia
3. Para cada task, identificar recursos apropriados
4. Planejar com @flutter-architect se necessário
```

### Durante Desenvolvimento
```
1. Consultar QUICK_START_COPILOT.md para comandos
2. Usar chat modes apropriados
3. Invocar agentes quando necessário
4. Validar frequentemente (analyze + test)
```

### Antes de Commit
```
1. ✅ flutter analyze (0 issues)
2. ✅ flutter test (all passing)
3. ✅ dart run custom_lint (clean)
4. ✅ flutter format .
5. ✅ Code review próprio
6. ✅ Commit com mensagem clara
```

---

## 🆘 Estou Perdido - FAQ

### "Não sei qual recurso usar"

👉 **Resposta:**
1. Identifique sua tarefa
2. Veja matriz de recursos acima
3. Se ainda em dúvida, pergunte no chat mode geral

---

### "Chat mode não está funcionando"

👉 **Resposta:**
1. Verificar se modo está ativo (ícone 📋)
2. Reiniciar chat
3. Ver Troubleshooting no COPILOT_GUIDE.md

---

### "Não encontrei exemplo para meu caso"

👉 **Resposta:**
1. Procure exemplo similar em COPILOT_EXAMPLES.md
2. Adapte para seu contexto
3. Se muito específico, pergunte ao @flutter-architect

---

### "Código gerado não compila"

👉 **Resposta:**
1. Rodar `dart run build_runner build --delete-conflicting-outputs`
2. Ver seção Troubleshooting → "Código não compila"
3. Usar @flutter-code-fixer para correção

---

## 🎯 Próximos Passos

### Para Você Agora

1. **Identifique seu nível:**
   - Novo? → Trilha 1 (Iniciante)
   - Já uso? → Trilha 2 (Intermediário)
   - Expert? → Trilha 3 (Avançado)

2. **Escolha um documento:**
   - Pressa? → QUICK_START_COPILOT.md
   - Tempo? → COPILOT_GUIDE.md
   - Exemplo? → COPILOT_EXAMPLES.md

3. **Comece:**
   - Leia o documento escolhido
   - Teste um recurso
   - Aplique no seu trabalho

---

## 📖 Links Rápidos

| Documento | Link | Quando Usar |
|-----------|------|-------------|
| 📋 Overview | [README.md](README.md) | Primeiro contato |
| ⚡ Quick Start | [QUICK_START_COPILOT.md](QUICK_START_COPILOT.md) | Referência diária |
| 📖 Guia Completo | [COPILOT_GUIDE.md](COPILOT_GUIDE.md) | Aprendizado profundo |
| 💡 Exemplos | [COPILOT_EXAMPLES.md](COPILOT_EXAMPLES.md) | Precisa de código |
| 🗺️ Navegação | [RESOURCES_MAP.md](RESOURCES_MAP.md) | Está perdido |

---

**💡 Dica Final:** Marque este documento nos favoritos - é seu mapa para navegar nos recursos do Copilot!

**🚀 Comece agora:** Escolha um documento acima e comece sua jornada de produtividade com GitHub Copilot!
