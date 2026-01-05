# Comparação: Sistemas de Formulários
**App Gasometer vs App Petiveti**

## 📊 Visão Geral

### **Gasometer - Dialog System**
- ✅ Usa `showDialog` com widget `CrudFormDialog`
- ✅ Dialog centralizado no meio da tela
- ✅ 3 modos: Create, View, Edit
- ✅ Transição entre modos (View → Edit)
- ✅ Botões: Salvar, Cancelar, Editar, Excluir
- ✅ Validação integrada
- ✅ Rate limiting / Debounce

### **Petiveti - BottomSheet System**
- ⚠️ Usa `showModalBottomSheet`  
- ⚠️ Sheet vem de baixo com drag handle
- ⚠️ Usa `PetFormDialog` wrapper
- ⚠️ Não tem modo "View" separado
- ⚠️ Menos padronizado

---

## 🎯 Componentes do Gasometer

### **1. CrudFormDialog Widget**
**Localização:** `apps/app-gasometer/lib/core/widgets/crud_form_dialog.dart`

**Características:**
```dart
CrudFormDialog(
  mode: CrudDialogMode.create, // create | view | edit
  title: 'Abastecimento',
  subtitle: 'Toyota Corolla • 25.000 km',
  headerIcon: Icons.local_gas_station,
  
  // Estados
  isLoading: false,
  isSaving: false,
  canSave: true,
  errorMessage: null,
  
  // Callbacks
  onModeChange: (newMode) => setState(() => mode = newMode),
  onSave: () => handleSave(),
  onCancel: () => Navigator.pop(context),
  onDelete: () => handleDelete(),
  
  // Configuração
  showCloseButton: true,
  showDeleteButton: mode != CrudDialogMode.create,
  maxWidth: 500,
  maxHeight: 700,
  
  // Conteúdo
  content: FuelFormView(vehicleId: vehicleId, readOnly: isReadOnly),
)
```

**Estrutura:**
```
Dialog
└─ Container (maxWidth: 500)
    ├─ Header
    │   ├─ Icon com badge (view/edit indicator)
    │   ├─ Title + Subtitle
    │   └─ Close button (X)
    ├─ Content (SingleChildScrollView)
    │   └─ FormView (custom per feature)
    └─ Bottom Buttons
        ├─ Delete (se edit/view)
        ├─ Cancel
        ├─ Edit (se view)
        └─ Save (se create/edit)
```

---

### **2. Form Pages**

#### **FuelFormPage**
```dart
class FuelFormPage extends ConsumerStatefulWidget {
  final String? fuelRecordId;  // Para view/edit
  final String? vehicleId;      // Para create
  final CrudDialogMode initialMode;
  
  // Uso:
  showDialog(
    context: context,
    builder: (context) => FuelFormPage(
      vehicleId: selectedVehicleId,
      initialMode: CrudDialogMode.create,
    ),
  );
}
```

**Responsabilidades:**
- ✅ Gerenciar modo (create/view/edit)
- ✅ Inicializar provider do formulário
- ✅ Carregar dados (se edit/view)
- ✅ Submit com rate limiting
- ✅ Validação antes de salvar
- ✅ Invalidar providers após salvar
- ✅ Retornar `bool` (true = salvou)

---

### **3. Form Notifiers (Riverpod)**

**Padrão:** `@riverpod class FuelFormNotifier`

```dart
@riverpod
class FuelFormNotifier extends _$FuelFormNotifier {
  @override
  FuelFormState build(String vehicleId) {
    return FuelFormState.initial();
  }
  
  // Métodos
  Future<void> initialize({required String vehicleId, required String userId});
  Future<void> loadFromFuelRecord(FuelRecordEntity record);
  void clearForm();
  bool validate();
  Future<bool> submit();
}
```

**Separação de responsabilidades:**
- ✅ `fuel_form_notifier.dart` - Main notifier
- ✅ `fuel_form_notifier_initialization.dart` - Initialize logic
- ✅ `fuel_form_notifier_crud.dart` - Create/Update/Delete
- ✅ `fuel_form_notifier_validation.dart` - Validation rules
- ✅ `fuel_form_notifier_image.dart` - Image handling
- ✅ `fuel_form_state.dart` - State class
- ✅ `fuel_form_model.dart` - Form data model

---

### **4. Form Views**

**FuelFormView** - Conteúdo visual do formulário

```dart
class FuelFormView extends ConsumerWidget {
  final String vehicleId;
  final bool readOnly;
  
  Widget build(context, ref) {
    final formState = ref.watch(fuelFormProvider(vehicleId));
    
    return Form(
      child: Column([
        // Date picker
        // Odometer field
        // Fuel type dropdown
        // Amount field
        // Price field
        // Total cost (calculated)
        // Image picker
        // Notes field
      ]),
    );
  }
}
```

---

## 🎯 Componentes do Petiveti (Atual)

### **1. PetFormDialog**
**Localização:** `apps/app-petiveti/lib/shared/widgets/dialogs/pet_form_dialog.dart`

```dart
// Simples wrapper, menos funcionalidades
PetFormDialog(
  title: 'Nova Vacina',
  child: AddVaccineForm(initialAnimalId: animalId),
)
```

### **2. BottomSheet Approach**
```dart
showModalBottomSheet(
  context: context,
  isScrollControlled: true,
  builder: (context) => DraggableScrollableSheet(
    initialChildSize: 0.7,
    child: AddVaccineDialog(initialAnimalId: animalId),
  ),
);
```

**Problemas:**
- ❌ Menos consistente
- ❌ Sem separação Create/View/Edit
- ❌ Drag handle manual
- ❌ Cada feature implementa diferente

---

## 📋 Proposta de Migração

### **Opção 1: Adotar CrudFormDialog do Gasometer (RECOMENDADO)**

**Vantagens:**
- ✅ Sistema robusto e testado
- ✅ 3 modos bem definidos
- ✅ UI consistente
- ✅ Fácil manutenção
- ✅ Menos código duplicado

**Passos:**
1. Copiar `CrudFormDialog` para Petiveti core
2. Criar Form Pages para cada feature:
   - `VaccineFormPage`
   - `AppointmentFormPage`
   - `MedicationFormPage`
   - `WeightFormPage`
3. Criar Form Notifiers (Riverpod)
4. Criar Form Views (conteúdo)
5. Atualizar `_openAddDialog` em `home_page.dart`

---

### **Opção 2: Melhorar BottomSheet Atual**

**Vantagens:**
- ✅ Mantém UX mobile-first
- ✅ Drag to dismiss nativo

**Desvantagens:**
- ❌ Mais trabalho de padronização
- ❌ Menos reutilização

---

## ✅ Recomendação Final

**Usar CrudFormDialog do Gasometer no Petiveti**

**Motivos:**
1. **Consistência** entre apps
2. **Robustez** testada em produção
3. **3 modos** (Create/View/Edit) bem definidos
4. **Reutilização** de código
5. **Manutenção** centralizada

**Alteração necessária:**
- Trocar `showModalBottomSheet` por `showDialog`
- Usar `CrudFormDialog` como wrapper
- Seguir padrão de Form Pages/Notifiers/Views

---

## 🎯 Checklist de Implementação

### **1. Setup Inicial**
- [ ] Copiar `CrudFormDialog` para Petiveti `/shared/widgets`
- [ ] Criar estrutura de pastas para forms
- [ ] Documentar padrão

### **2. Vaccines Feature**
- [ ] Criar `VaccineFormPage`
- [ ] Criar `VaccineFormNotifier` (Riverpod)
- [ ] Criar `VaccineFormView` (conteúdo)
- [ ] Atualizar `_openAddDialog('vaccines')`
- [ ] Testar 3 modos (Create/View/Edit)

### **3. Appointments Feature**
- [ ] Criar `AppointmentFormPage`
- [ ] Criar `AppointmentFormNotifier`
- [ ] Criar `AppointmentFormView`
- [ ] Atualizar `_openAddDialog('appointments')`

### **4. Medications Feature**
- [ ] Criar `MedicationFormPage`
- [ ] Criar `MedicationFormNotifier`
- [ ] Criar `MedicationFormView`
- [ ] Atualizar `_openAddDialog('medications')`

### **5. Weight Feature**
- [ ] Criar `WeightFormPage`
- [ ] Criar `WeightFormNotifier`
- [ ] Criar `WeightFormView`
- [ ] Atualizar `_openAddDialog('weight')`

### **6. Testes e Refinamento**
- [ ] Testar fluxo completo de cada feature
- [ ] Validar estados (loading, error, success)
- [ ] Testar transição entre modos
- [ ] Performance e UX

---

## 📊 Benefícios Esperados

| Aspecto | Antes | Depois |
|---------|-------|--------|
| Consistência | 40% | 100% ✅ |
| Código duplicado | Alto | Baixo ✅ |
| Manutenibilidade | Difícil | Fácil ✅ |
| UX | Variável | Consistente ✅ |
| Funcionalidades | Básicas | Avançadas ✅ |

---

## 🚀 Próximos Passos

1. **Decisão:** Aprovar uso de `CrudFormDialog`
2. **Setup:** Copiar componente para Petiveti
3. **Implementação:** Começar por Vaccines (feature mais completa)
4. **Iteração:** Aplicar em outras features
5. **Refinamento:** Ajustes finais e testes
