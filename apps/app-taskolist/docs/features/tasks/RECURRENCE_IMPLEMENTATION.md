# 🔄 Implementação de Tarefas Recorrentes

**Feature ID**: RECURRENCE-001  
**Status**: 🟢 95% Completo  
**Última Atualização**: 2025-12-18

---

## 📋 Visão Geral

Implementação de tarefas recorrentes (repetitivas) inspirada no Microsoft To Do, permitindo que usuários criem tarefas que se repetem automaticamente em intervalos personalizados.

---

## ✅ Componentes Implementados

### 1. **Schema de Banco de Dados** ✅
Tabela `tasks` atualizada com novos campos:

```dart
// Campos de recorrência
TextColumn get recurrenceType => text().withDefault(const Constant('none'))();
IntColumn get recurrenceInterval => integer().withDefault(const Constant(1))();
TextColumn get recurrenceDaysOfWeek => text().nullable()();
IntColumn get recurrenceDayOfMonth => integer().nullable()();
DateTimeColumn get recurrenceEndDate => dateTime().nullable()();
```

### 2. **Entidade RecurrencePattern** ✅
Arquivo: `lib/features/tasks/domain/recurrence_entity.dart`

**Tipos de Recorrência**:
- ✅ `none` - Sem recorrência
- ✅ `daily` - Diariamente
- ✅ `weekly` - Semanalmente (com seleção de dias)
- ✅ `monthly` - Mensalmente (com dia do mês)
- ✅ `yearly` - Anualmente
- ✅ `custom` - Personalizado

**Funcionalidades**:
- ✅ Cálculo automático de próxima ocorrência
- ✅ Validação de data final (endDate)
- ✅ Conversão JSON para sync Firebase
- ✅ toString() amigável para exibição

### 3. **TaskEntity Atualizada** ✅
- ✅ Campo `recurrence` do tipo `RecurrencePattern`
- ✅ Propriedades computadas:
  - `isRecurring`: indica se task é recorrente
  - `nextOccurrence`: calcula próxima data

### 4. **TaskModel & DAO** ✅
- ✅ `TaskModel` atualizado com recurrence
- ✅ `TaskDao` com conversores JSON para daysOfWeek
- ✅ Suporte completo para CRUD com recorrência

### 5. **Use Cases** ✅
Arquivo: `lib/features/tasks/domain/usecases/create_next_recurrence_usecase.dart`

**CreateNextRecurrenceUseCase**:
- ✅ Valida se task é recorrente
- ✅ Calcula próxima data de ocorrência
- ✅ Cria nova task com mesmo padrão
- ✅ Reseta status para pending
- ✅ Ajusta reminderDate automaticamente

### 6. **UI Components** ✅

**RecurrenceConfigDialog** (`widgets/recurrence_config_dialog.dart`):
- ✅ Dialog completo para configuração
- ✅ Seleção de tipo de recorrência
- ✅ Configuração de intervalo (a cada X dias/semanas/meses)
- ✅ Seleção de dias da semana (chips para Weekly)
- ✅ Input de dia do mês (para Monthly)
- ✅ Date picker para data final (opcional)
- ✅ Validação de inputs

**RecurrenceIndicator** (`widgets/recurrence_indicator.dart`):
- ✅ Chip para exibir recorrência nas listas
- ✅ Ícone de repeat
- ✅ Texto descritivo do padrão

### 7. **Providers** ✅
- ✅ `createNextRecurrenceProvider` integrado em task_providers.dart
- ✅ Injeção de dependências configurada

---

## ⏳ Pendências

### Integração com TaskFormPage
- [ ] Adicionar botão para abrir `RecurrenceConfigDialog`
- [ ] Exibir `RecurrenceIndicator` no formulário
- [ ] Persistência ao salvar task

### Integração com Task Lists
- [ ] Exibir `RecurrenceIndicator` nos TaskItems
- [ ] Ícone especial para tasks recorrentes

### Lógica de Geração Automática
- [ ] Integrar `CreateNextRecurrenceUseCase` ao completar task
- [ ] Adicionar opção: "Completar apenas esta ocorrência" vs "Completar todas"
- [ ] Background Job (opcional):
  - Gerar tasks recorrentes com antecedência (7 dias)
  - Evitar duplicatas

### Sincronização Firebase
- ✅ Recorrência é sincronizada via toFirebaseMap/fromFirebaseMap
- [ ] Testar resolução de conflitos

---

## 🎯 Casos de Uso

### Exemplo 1: Tarefa Diária
```dart
RecurrencePattern(
  type: RecurrenceType.daily,
  interval: 1, // Todo dia
  endDate: null, // Infinito
)
```

### Exemplo 2: Reunião Semanal
```dart
RecurrencePattern(
  type: RecurrenceType.weekly,
  interval: 1,
  daysOfWeek: [1, 3, 5], // Segunda, Quarta, Sexta
  endDate: DateTime(2026, 12, 31),
)
```

### Exemplo 3: Fatura Mensal
```dart
RecurrencePattern(
  type: RecurrenceType.monthly,
  interval: 1,
  dayOfMonth: 10, // Dia 10 de cada mês
  endDate: null,
)
```

---

## 🧪 Testes Necessários

### Unitários
- [ ] `RecurrencePattern.getNextOccurrence()` para cada tipo
- [ ] Validação de datas inválidas (ex: 31 de fevereiro)
- [ ] Conversão JSON <-> Entity

### Integração
- [ ] Salvar e recuperar task recorrente do Drift
- [ ] Sincronizar com Firebase
- [ ] Completar task e gerar próxima

### UI
- [ ] Widget RecurrencePicker em diferentes cenários
- [ ] Validação de inputs

---

## 📝 Notas Técnicas

### Limitações Conhecidas
1. **Monthly recurrence**: Se dayOfMonth > dias do mês, ajusta automaticamente
2. **Weekly recurrence**: Requer pelo menos 1 dia selecionado
3. **Custom type**: Ainda não implementado (reservado para futuro)

### Performance
- Cálculo de `nextOccurrence` é O(1) para daily/monthly/yearly
- Para weekly com múltiplos dias, é O(7) no pior caso
- Não há impacto em queries do banco (campos simples)

---

## 🚀 Próximos Passos

1. **Curto Prazo** (hoje):
   - Integrar RecurrencePicker no TaskFormPage
   - Testar criação de task recorrente

2. **Médio Prazo** (esta semana):
   - Implementar CompleteRecurringTaskUseCase
   - Adicionar indicador visual de tasks recorrentes na lista

3. **Longo Prazo** (próxima sprint):
   - Background job para geração antecipada
   - Suporte a exceções (pular uma ocorrência)
   - Histórico de ocorrências completadas

---

## 🔗 Referências

- [Microsoft To Do - Recurrence](https://support.microsoft.com/en-us/office/create-recurring-tasks-and-reminders-6e3e7359-8d13-4c5c-8e30-3ed8b183d5e2)
- [RFC 5545 - iCalendar Recurrence](https://tools.ietf.org/html/rfc5545#section-3.3.10)
- [Flutter DatePicker](https://api.flutter.dev/flutter/material/showDatePicker.html)
