# CRUD Enhancement Plan - App Gasometer

## 📋 Visão Geral

Implementação completa de funcionalidades CRUD (Create, Read, Update, Delete) para todas as entidades do app-gasometer, com UX moderna e consistente.

## 🎯 Objetivos

1. **Visualização de Registros**: Ao tocar em um item da lista, abrir dialog em modo visualização (readonly)
2. **Edição de Registros**: Botão de editar no modo visualização habilita os campos
3. **Exclusão com Swipe**: Arrastar item para o lado para excluir + Toast com "Desfazer"
4. **Consistência**: Mesmo padrão visual e comportamental em todas as entidades

## 🏗️ Arquitetura

### Componentes Criados

#### 1. `CrudFormDialog` (`core/widgets/crud_form_dialog.dart`)
Dialog reutilizável com 3 modos de operação:
- **CREATE**: Formulário vazio para criar novo registro
- **VIEW**: Campos em modo readonly com botões Excluir/Editar
- **EDIT**: Campos editáveis com botões Cancelar/Salvar

```dart
CrudFormDialog(
  mode: CrudDialogMode.view,
  title: 'Abastecimento',
  subtitle: 'Detalhes do registro',
  headerIcon: Icons.local_gas_station,
  content: FuelFormView(readOnly: true),
  onModeChange: (newMode) => setState(() => mode = newMode),
  onSave: () => handleSave(),
  onDelete: () => handleDelete(),
)
```

#### 2. `ReadOnlyField` Widgets (`core/widgets/readonly_field.dart`)
Família de widgets para exibição de dados em modo visualização:
- `ReadOnlyField` - Campo genérico
- `ReadOnlyMoneyField` - Valores monetários formatados
- `ReadOnlyNumberField` - Números com unidade
- `ReadOnlyDateField` - Datas formatadas
- `ReadOnlyBoolField` - Booleanos com badge visual
- `ReadOnlyFieldSection` - Container para agrupar campos
- `ReadOnlyFieldRow` - Dois campos lado a lado

#### 3. `SwipeToDeleteWrapper` (já existente em `core/widgets/`)
Widget para exclusão com swipe + SnackBar com undo:
```dart
SwipeToDeleteWrapper(
  itemKey: 'fuel_${record.id}',
  deletedMessage: 'Abastecimento excluído',
  onDelete: () => notifier.softDelete(record.id),
  onRestore: () => notifier.restore(record.id),
  child: FuelRecordCard(record: record),
)
```

## 📝 Entidades a Implementar

### 1. 🚗 Veículos (vehicles)
**Status**: ⬜ Pendente

**Arquivos a modificar**:
- `features/vehicles/presentation/widgets/vehicle_card.dart` - Adicionar swipe
- `features/vehicles/presentation/forms/` - Criar view mode
- `features/vehicles/presentation/providers/` - Adicionar soft delete/restore

**Campos**:
- Nome, Placa, Marca, Modelo, Ano
- Combustíveis suportados
- Capacidade do tanque
- Odômetro atual
- Foto

### 2. ⛽ Abastecimentos (fuel)
**Status**: ⬜ Pendente

**Arquivos a modificar**:
- `features/fuel/presentation/widgets/fuel_record_card.dart` - Adicionar swipe
- `features/fuel/presentation/widgets/fuel_form_view.dart` - Suportar readOnly
- `features/fuel/presentation/providers/fuel_form_notifier.dart` - Carregar dados existentes

**Campos**:
- Tipo de combustível
- Data/hora
- Tanque cheio (bool)
- Litros, Preço/litro, Total
- Odômetro
- Observações
- Comprovante (imagem)

### 3. 📊 Odômetro (odometer)
**Status**: ⬜ Pendente

**Arquivos a modificar**:
- `features/odometer/presentation/pages/odometer_page.dart` - Lista com swipe
- Criar: `odometer_view_dialog.dart` - Dialog de visualização/edição

**Campos**:
- Data/hora
- Leitura (km)
- Observações

### 4. 💰 Despesas (expenses)
**Status**: ⬜ Pendente

**Arquivos a modificar**:
- `features/expenses/presentation/widgets/expenses_paginated_list.dart` - Adicionar swipe
- `features/expenses/presentation/widgets/expense_form_view.dart` - Suportar readOnly
- `features/expenses/presentation/notifiers/expense_form_notifier.dart` - Carregar dados

**Campos**:
- Tipo de despesa
- Descrição
- Data/hora
- Valor
- Odômetro
- Local
- Observações
- Comprovante (imagem)

### 5. 🔧 Manutenções (maintenance)
**Status**: ⬜ Pendente

**Arquivos a modificar**:
- `features/maintenance/presentation/pages/maintenance_page.dart` - Lista com swipe
- `features/maintenance/presentation/pages/add_maintenance_page.dart` - Refatorar para dialog

**Campos**:
- Tipo de manutenção
- Descrição
- Data/hora
- Custo
- Odômetro
- Local/Oficina
- Observações
- Comprovante (imagem)

## 🔄 Fluxo de Implementação por Entidade

### Fase 1: Preparação do Notifier
1. Adicionar método `loadRecord(String id)` para carregar dados existentes
2. Adicionar método `softDelete(String id)` para exclusão otimista
3. Adicionar método `restore(String id)` para restaurar item excluído
4. Adicionar flag `isEditing` no state

### Fase 2: Adaptar FormView
1. Adicionar parâmetro `readOnly: bool`
2. Quando `readOnly=true`, usar widgets `ReadOnlyField`
3. Quando `readOnly=false`, usar widgets de input normais
4. Opcional: Criar widget separado `*ViewContent` para visualização

### Fase 3: Criar/Adaptar Dialog
1. Usar `CrudFormDialog` como container
2. Gerenciar estado do modo (create/view/edit)
3. Implementar callbacks onSave, onDelete, onModeChange

### Fase 4: Integrar na Lista
1. Envolver cards com `SwipeToDeleteWrapper`
2. Adicionar `onTap` para abrir dialog em modo VIEW
3. Remover botão de adicionar antigo (se usar FAB ou similar)

## 📐 Padrões de UX

### Transições de Modo
```
[Lista] --tap--> [VIEW] --editar--> [EDIT] --salvar--> [Lista refresh]
                   |                   |
                   +--excluir----------+--cancelar--> [VIEW]
```

### Swipe to Delete
```
[Card] --swipe left--> [Background vermelho] --release--> 
  [Remove da lista] + [Toast "Excluído" + botão DESFAZER]
       |                                    |
       +----<--- tap DESFAZER --------------+
```

### Toast de Undo
- Duração: 5 segundos
- Comportamento: `SnackBarBehavior.floating`
- Ação: "DESFAZER" restaura o item

## ✅ Checklist de Implementação

### Infraestrutura ✅
- [x] `CrudFormDialog` criado
- [x] `ReadOnlyField` widgets criados
- [x] `SwipeToDeleteWrapper` já existente
- [x] Exports adicionados ao barrel file

### Veículos
- [ ] Adicionar soft delete/restore no VehicleNotifier
- [ ] Criar VehicleViewContent com ReadOnlyFields
- [ ] Adaptar dialog para usar CrudFormDialog
- [ ] Integrar SwipeToDeleteWrapper na lista

### Abastecimentos
- [ ] Adicionar soft delete/restore no FuelFormNotifier
- [ ] Adaptar FuelFormView para suportar readOnly
- [ ] Criar dialog com CrudFormDialog
- [ ] Integrar SwipeToDeleteWrapper na lista

### Odômetro
- [ ] Adicionar soft delete/restore no OdometerNotifier
- [ ] Criar OdometerViewDialog
- [ ] Integrar SwipeToDeleteWrapper na lista

### Despesas
- [ ] Adicionar soft delete/restore no ExpenseFormNotifier
- [ ] Adaptar ExpenseFormView para suportar readOnly
- [ ] Criar dialog com CrudFormDialog
- [ ] Integrar SwipeToDeleteWrapper na lista

### Manutenções
- [ ] Adicionar soft delete/restore no MaintenanceNotifier
- [ ] Criar MaintenanceViewDialog
- [ ] Integrar SwipeToDeleteWrapper na lista

## 📅 Estimativa de Tempo

| Entidade | Complexidade | Estimativa |
|----------|--------------|------------|
| Veículos | Alta | 3-4h |
| Abastecimentos | Média | 2-3h |
| Odômetro | Baixa | 1-2h |
| Despesas | Média | 2-3h |
| Manutenções | Média | 2-3h |
| **Total** | | **10-15h** |

## 🚀 Próximos Passos

1. **Começar por Abastecimentos** (fuel) - entidade mais usada e serve de template
2. Validar UX com usuário antes de replicar para outras entidades
3. Após validação, aplicar padrão nas demais entidades

---
*Documento criado em: 2024-12-08*
*Última atualização: 2024-12-08*
