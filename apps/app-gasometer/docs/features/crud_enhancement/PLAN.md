# 📋 CRUD Enhancement Plan - App Gasometer

> **Data:** 2025-12-08
> **Status:** 🟡 Em Planejamento
> **Prioridade:** Alta

---

## 🎯 Objetivo

Implementar funcionalidades completas de **Visualização**, **Edição** e **Exclusão** para as 5 entidades principais do app, seguindo padrões modernos de UX.

---

## 📊 Escopo

### Entidades Afetadas

| # | Entidade | Página Atual | Form Atual | Lista Atual |
|---|----------|--------------|------------|-------------|
| 1 | **Veículos** | `add_vehicle_page.dart` | Inline na page | `vehicle_card.dart` |
| 2 | **Odômetro** | `add_odometer_page.dart` | Inline na page | Inline na page |
| 3 | **Abastecimento** | `add_fuel_page.dart` | `fuel_form_view.dart` | `fuel_records_list.dart` |
| 4 | **Despesas** | `add_expense_page.dart` | `expense_form_view.dart` | `expenses_paginated_list.dart` |
| 5 | **Manutenções** | `add_maintenance_page.dart` | Inline na page | Inline na page |

---

## 🏗️ Arquitetura da Solução

### 1. Dialog Mode Enum (Compartilhado)

```dart
/// Modo de operação do dialog/form
enum DialogMode {
  /// Criação de novo registro - campos vazios e editáveis
  create,
  
  /// Visualização de registro existente - campos preenchidos e readonly
  view,
  
  /// Edição de registro existente - campos preenchidos e editáveis
  edit,
}

extension DialogModeX on DialogMode {
  bool get isCreate => this == DialogMode.create;
  bool get isView => this == DialogMode.view;
  bool get isEdit => this == DialogMode.edit;
  bool get isEditable => this != DialogMode.view;
  bool get hasRecord => this != DialogMode.create;
  
  String get title => switch (this) {
    DialogMode.create => 'Adicionar',
    DialogMode.view => 'Detalhes',
    DialogMode.edit => 'Editar',
  };
}
```

### 2. Swipe to Delete Widget (Compartilhado)

```dart
/// Widget reutilizável para exclusão com swipe + undo
class SwipeToDeleteWrapper<T> extends StatelessWidget {
  final T item;
  final int index;
  final String itemKey;
  final String deletedMessage;
  final Widget child;
  final Future<void> Function() onDelete;
  final Future<void> Function() onRestore;
  final Duration undoDuration;
  
  // Background vermelho com ícone de lixeira
  // SnackBar com ação "DESFAZER"
  // Lógica de exclusão otimista
}
```

### 3. Fluxo de Estados

```
┌─────────────────────────────────────────────────────────────────┐
│                        LISTA DE REGISTROS                        │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  ┌──────────────────────────────────────────────────────────┐   │
│  │ ◀── Swipe Left ──  Item 1  ────────────────── [🗑️ Red] │   │
│  └──────────────────────────────────────────────────────────┘   │
│         │                              │                         │
│         │ Tap                          │ Swipe complete          │
│         ▼                              ▼                         │
│  ┌──────────────┐              ┌──────────────────────┐         │
│  │ Dialog VIEW  │              │ SnackBar + Undo      │         │
│  │              │              │ "Registro excluído"  │         │
│  │ [Editar]     │              │            [DESFAZER]│         │
│  └──────────────┘              └──────────────────────┘         │
│         │                              │                         │
│         │ Tap Editar                   │ 5 segundos              │
│         ▼                              ▼                         │
│  ┌──────────────┐              ┌──────────────────────┐         │
│  │ Dialog EDIT  │              │ Delete permanente    │         │
│  │              │              │ (se não fez undo)    │         │
│  │ [Cancelar]   │              └──────────────────────┘         │
│  │ [Salvar]     │                                                │
│  └──────────────┘                                                │
│                                                                  │
│  [+ FAB] ─────────────────────▶ Dialog CREATE                   │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

---

## 📁 Estrutura de Arquivos

### Novos Arquivos Compartilhados

```
lib/core/
├── enums/
│   └── dialog_mode.dart                    # Enum DialogMode
├── widgets/
│   ├── swipe_to_delete_wrapper.dart        # Widget de exclusão
│   └── crud_dialog_base.dart               # Base para dialogs CRUD
└── mixins/
    └── optimistic_delete_mixin.dart        # Mixin para delete otimista
```

### Alterações por Entidade

```
lib/features/vehicles/
├── presentation/
│   ├── pages/
│   │   └── add_vehicle_page.dart           # → Renomear: vehicle_form_page.dart
│   ├── widgets/
│   │   └── vehicle_card.dart               # + Swipe to delete
│   └── notifiers/
│       └── vehicles_notifier.dart          # + removeOptimistic, restore, deletePermanent

lib/features/odometer/
├── presentation/
│   ├── pages/
│   │   └── add_odometer_page.dart          # → Renomear: odometer_form_page.dart
│   └── notifiers/
│       └── odometer_notifier.dart          # + removeOptimistic, restore, deletePermanent

lib/features/fuel/
├── presentation/
│   ├── pages/
│   │   └── add_fuel_page.dart              # → Renomear: fuel_form_page.dart
│   ├── widgets/
│   │   ├── fuel_form_view.dart             # + mode parameter
│   │   └── fuel_records_list.dart          # + Swipe to delete
│   └── providers/
│       └── fuel_form_notifier.dart         # + loadRecord, mode handling

lib/features/expenses/
├── presentation/
│   ├── pages/
│   │   └── add_expense_page.dart           # → Renomear: expense_form_page.dart
│   ├── widgets/
│   │   ├── expense_form_view.dart          # + mode parameter
│   │   └── expenses_paginated_list.dart    # + Swipe to delete
│   └── notifiers/
│       └── expense_form_notifier.dart      # + loadRecord, mode handling

lib/features/maintenance/
├── presentation/
│   ├── pages/
│   │   └── add_maintenance_page.dart       # → Renomear: maintenance_form_page.dart
│   └── notifiers/
│       └── maintenance_notifier.dart       # + removeOptimistic, restore, deletePermanent
```

---

## 🔄 Fases de Implementação

### Fase 1: Infraestrutura Base (Prioridade: Alta) ✅ CONCLUÍDA
**Estimativa:** 2-3 horas

- [x] **1.1** Criar `dialog_mode.dart` com enum e extensions
- [x] **1.2** Criar `swipe_to_delete_wrapper.dart` widget
- [x] **1.3** Criar `optimistic_delete_mixin.dart`
- [ ] **1.4** Criar testes unitários para os componentes base

### Fase 2: Implementação - Veículos (Modelo Base) ✅ CONCLUÍDA
**Estimativa:** 3-4 horas

- [x] **2.1** Adaptar `VehiclesNotifier` com métodos de delete otimista
- [x] **2.2** Adaptar `vehicle_card.dart` com `SwipeToDeleteWrapper`
- [x] **2.3** Adaptar `add_vehicle_page.dart` para suportar modes (VIEW/EDIT)
- [x] **2.4** Atualizar navegação para passar `recordId` e `mode`
- [ ] **2.5** Testar fluxo completo CREATE → VIEW → EDIT → DELETE

### Fase 3: Implementação - Odômetro
**Estimativa:** 2-3 horas

- [ ] **3.1** Adaptar `OdometerNotifier`
- [ ] **3.2** Adicionar swipe to delete na lista
- [ ] **3.3** Adaptar `add_odometer_page.dart` para modes
- [ ] **3.4** Testar fluxo completo

### Fase 4: Implementação - Abastecimento
**Estimativa:** 2-3 horas

- [ ] **4.1** Adaptar `FuelFormNotifier` com `loadRecord`
- [ ] **4.2** Adaptar `fuel_form_view.dart` para modes
- [ ] **4.3** Adaptar `fuel_records_list.dart` com swipe
- [ ] **4.4** Testar fluxo completo

### Fase 5: Implementação - Despesas
**Estimativa:** 2-3 horas

- [ ] **5.1** Adaptar `ExpenseFormNotifier` com `loadRecord`
- [ ] **5.2** Adaptar `expense_form_view.dart` para modes
- [ ] **5.3** Adaptar `expenses_paginated_list.dart` com swipe
- [ ] **5.4** Testar fluxo completo

### Fase 6: Implementação - Manutenções
**Estimativa:** 2-3 horas

- [ ] **6.1** Adaptar `MaintenanceNotifier`
- [ ] **6.2** Adicionar swipe to delete na lista
- [ ] **6.3** Adaptar `add_maintenance_page.dart` para modes
- [ ] **6.4** Testar fluxo completo

### Fase 7: Polimento e Testes Finais
**Estimativa:** 2 horas

- [ ] **7.1** Revisar consistência visual entre todas as entidades
- [ ] **7.2** Testar edge cases (sem internet, erros de sync)
- [ ] **7.3** Atualizar documentação
- [ ] **7.4** Code review final

---

## 📐 Especificações de UI/UX

### Swipe to Delete

| Aspecto | Especificação |
|---------|---------------|
| **Direção** | Esquerda → Direita (endToStart) |
| **Background** | `Colors.red.shade600` |
| **Ícone** | `Icons.delete_outline`, branco, 28px |
| **Threshold** | 40% da largura do item |
| **Animação** | Curva ease-out, 300ms |

### SnackBar de Undo

| Aspecto | Especificação |
|---------|---------------|
| **Duração** | 5 segundos |
| **Posição** | Bottom |
| **Texto** | "Registro excluído" |
| **Ação** | "DESFAZER" em cor primária |
| **Behavior** | `SnackBarBehavior.floating` |

### Dialog Modes

| Mode | AppBar Title | Campos | Botões |
|------|-------------|--------|--------|
| **CREATE** | "Adicionar [Entidade]" | Editáveis, vazios | [Cancelar] [Salvar] |
| **VIEW** | "Detalhes" | Readonly, preenchidos | [Editar] |
| **EDIT** | "Editar [Entidade]" | Editáveis, preenchidos | [Cancelar] [Salvar] |

---

## 🔗 Dependências

### Internas
- Riverpod (state management)
- GoRouter (navegação)
- Drift (persistência)

### Externas (já existentes)
- `flutter_slidable` (opcional - pode usar `Dismissible` nativo)

---

## ⚠️ Riscos e Mitigações

| Risco | Probabilidade | Impacto | Mitigação |
|-------|---------------|---------|-----------|
| Sync offline durante delete | Média | Alto | Queue de operações + retry automático |
| Perda de dados no undo timeout | Baixa | Alto | Confirmação visual clara do countdown |
| Inconsistência entre entidades | Média | Médio | Componentes compartilhados + code review |

---

## ✅ Critérios de Aceitação

### Por Entidade
- [ ] Usuário pode criar novo registro via FAB
- [ ] Usuário pode visualizar registro existente tocando no item
- [ ] Usuário pode editar registro via botão no modo VIEW
- [ ] Usuário pode excluir registro via swipe
- [ ] Usuário pode desfazer exclusão em até 5 segundos
- [ ] Dados persistem corretamente no Drift
- [ ] Dados sincronizam com Firebase

### Global
- [ ] UI consistente entre todas as entidades
- [ ] Sem regressões em funcionalidades existentes
- [ ] Código segue padrões do projeto (Clean Architecture, Riverpod)

---

## 📝 Notas de Implementação

### Ordem de Execução Recomendada

1. **Veículos primeiro** - será o modelo base para as outras
2. **Abastecimento e Despesas** - já têm forms bem estruturados
3. **Odômetro e Manutenções** - forms mais simples

### Pontos de Atenção

- Manter retrocompatibilidade com rotas existentes
- Não quebrar deep links
- Considerar estado offline para todas operações
- Usar `ValueKey` apropriado para animações do `Dismissible`

---

## 🚀 Próximos Passos

1. **Aprovação** do plano
2. **Início da Fase 1** - Infraestrutura base
3. **Review** após cada fase completa
