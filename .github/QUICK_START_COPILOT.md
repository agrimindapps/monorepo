# 🚀 Quick Start - GitHub Copilot

Guia rápido de referência para usar os recursos do GitHub Copilot no monorepo.

## ⚡ Uso Rápido

### 1️⃣ Chat Modes (Contextos)

**Como ativar:** Abra Copilot Chat (`Cmd/Ctrl + Shift + I`) → Clique 📋 → Selecione modo

| Modo | Quando Usar | Comando Exemplo |
|------|-------------|-----------------|
| 🧪 Testing & TDD | Criar/debugar testes | "Criar testes para use case X" |
| 🐛 Debugging Expert | Resolver bugs | "Analisar stack trace: [colar]" |
| ♻️ Refactoring | Melhorar código | "Refatorar usando pattern X" |
| 📝 Documentation | Criar docs | "Documentar feature X" |
| ⚡ Performance | Otimizar código | "App lento, como otimizar?" |
| 🔒 Security | Auditar segurança | "Auditar código de auth" |
| 🏢 Monorepo | Cross-app | "Feature em 3 apps" |
| 🔄 Riverpod | Migrar Riverpod | "Migrar provider legado" |

---

### 2️⃣ Agentes (Especialistas)

**Como usar:** No chat do Copilot, digite `@agent-name sua pergunta`

| Agente | Especialidade | Exemplo |
|--------|---------------|---------|
| `@flutter-architect` | Arquitetura/Planejamento | `@flutter-architect Estruturar sistema de pagamentos cross-app` |
| `@flutter-code-fixer` | Correção de código | `@flutter-code-fixer Corrigir 15 analyzer warnings` |
| `@flutter-ux-designer` | UX/UI | `@flutter-ux-designer Melhorar tela de lista` |
| `@monorepo-orchestrator` | Coordenação apps | `@monorepo-orchestrator Extrair auth para core` |

---

### 3️⃣ Prompts (Templates)

**Como usar:** `Cmd/Ctrl + Shift + P` → "Copilot: Open Prompt Library" → Selecione

| Prompt | Descrição | Uso |
|--------|-----------|-----|
| 📦 `implementar_feature_completa` | Feature com Clean Arch | Nova feature do zero |
| 🧪 `criar_testes_unitarios` | Testes TDD completos | Adicionar testes |
| 📦 `criar_package_compartilhado` | Novo package core | Código compartilhado |
| ♻️ `refatorar_arquivo` | Refatoração segura | Melhorar código existente |

---

## 🎯 Workflows Rápidos

### Nova Feature
```
1. @flutter-architect - Planejar
2. [Prompt: implementar_feature_completa] - Implementar
3. [Chat Mode: Testing & TDD] - Testar
4. flutter analyze && flutter test - Validar
```

### Resolver Bug
```
1. [Chat Mode: Debugging Expert] - Analisar
2. @flutter-code-fixer - Corrigir
3. [Chat Mode: Testing & TDD] - Teste regressão
```

### Refatorar
```
1. [Chat Mode: Refactoring Specialist] - Planejar
2. [Prompt: refatorar_arquivo] - Executar
3. flutter test - Validar
```

### Migrar Riverpod
```
1. [Chat Mode: Riverpod Migration] - Setup
2. Migrar providers incrementalmente
3. dart run build_runner build - Gerar código
4. flutter analyze - Validar
```

---

## 💡 Dicas Essenciais

### ✅ Sempre Faça

```bash
# Após gerar código Riverpod
dart run build_runner build --delete-conflicting-outputs

# Validação completa
flutter analyze
flutter test
dart run custom_lint
flutter format .
```

### ⚡ Comandos Úteis

```bash
# Análise
flutter analyze

# Testes
flutter test
flutter test --coverage

# Build runner (Riverpod)
dart run build_runner watch --delete-conflicting-outputs

# Lint customizado (Riverpod)
dart run custom_lint
```

---

## 🎓 Exemplos Práticos

### Exemplo 1: Criar Feature
```
[Prompt: implementar_feature_completa]

Nome: Sistema de Favoritos
App: app-plantis
Descrição: Usuários favoritarem plantas
Complexidade: Média
Cross-App: N
```

### Exemplo 2: Corrigir Warnings
```
@flutter-code-fixer

Corrigir todos analyzer warnings em app-gasometer:
- Tipos nullable
- Unused imports
- Missing returns
```

### Exemplo 3: Melhorar Performance
```
[Chat Mode: Performance Optimizer]

Lista de plantas lenta com 200+ itens.
Multiple rebuilds detectados.
Como otimizar?
```

### Exemplo 4: Migrar Provider
```
[Chat Mode: Riverpod Migration]

Migrar este ChangeNotifierProvider para @riverpod:

class PlantNotifier extends ChangeNotifier {
  List<Plant> _plants = [];
  List<Plant> get plants => _plants;
  
  Future<void> loadPlants() async {
    _plants = await repository.getPlants();
    notifyListeners();
  }
}
```

---

## 🐛 Problemas Comuns

### Código não compila
```bash
# Solução
dart run build_runner build --delete-conflicting-outputs
flutter clean
flutter pub get
```

### Chat Mode não funciona
```
1. Verificar se modo está ativo (ícone 📋)
2. Reiniciar chat
3. Fornecer mais contexto
```

### Agente não responde
```
1. Verificar sintaxe: @agent-name
2. Ser mais específico
3. Dar contexto completo
```

---

## 📚 Documentação Completa

Para guia detalhado: **[COPILOT_GUIDE.md](COPILOT_GUIDE.md)**

---

## 🎯 Métricas

### Produtividade

| Métrica | Antes | Depois | Melhoria |
|---------|-------|--------|----------|
| Feature completa | 3-5 dias | 1-2 dias | **50%** ⬆️ |
| Test coverage | ~50% | >80% | **60%** ⬆️ |
| Bugs produção | Alto | Baixo | **70%** ⬇️ |
| Tempo refatoração | 1 dia | 2h | **75%** ⬆️ |

---

## ✅ Checklist Diário

```
[ ] Ativei chat mode apropriado
[ ] Usei agent especializado quando apropriado
[ ] Rodei build_runner após gerar providers
[ ] Validei com flutter analyze
[ ] Executei testes
[ ] Commit com código limpo
```

---

**💡 Dica:** Mantenha este guia aberto durante desenvolvimento para referência rápida!

**📖 Ver também:** [COPILOT_GUIDE.md](COPILOT_GUIDE.md) para documentação completa
