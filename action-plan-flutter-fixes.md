# Plano de Ação - Correção Flutter Analyze

## 🎯 Foco Imediato: Resolver 5 Imports Críticos

### **PROBLEMA RAIZ IDENTIFICADO**
Os arquivos em `apps/app-gasometer/lib/features/*/data/models/` estão tentando importar:
```dart
import '../../../core/data/models/base_sync_model.dart';
```

Mas o arquivo correto está em:
```
apps/app-gasometer/lib/core/data/models/base_sync_model.dart
```

O path deveria ser: `../../../../core/data/models/base_sync_model.dart`

---

## 🔧 FASE 1 - Correção de Imports (CRÍTICO)

### Arquivo 1: expense_model.dart
**Local:** `apps/app-gasometer/lib/features/expenses/data/models/expense_model.dart`
**Linha 3:** Corrigir import path

### Arquivo 2: fuel_supply_model.dart  
**Local:** `apps/app-gasometer/lib/features/fuel/data/models/fuel_supply_model.dart`
**Linha 2:** Corrigir import path

### Arquivo 3: maintenance_model.dart
**Local:** `apps/app-gasometer/lib/features/maintenance/data/models/maintenance_model.dart`  
**Linha 2:** Corrigir import path

### Arquivo 4: odometer_model.dart
**Local:** `apps/app-gasometer/lib/features/odometer/data/models/odometer_model.dart`
**Linha 2:** Corrigir import path

### Arquivo 5: vehicle_model.dart
**Local:** `apps/app-gasometer/lib/features/vehicles/data/models/vehicle_model.dart`
**Linha 2:** Corrigir import path

---

## 🔧 FASE 2 - Resolver Métodos Ausentes

Após corrigir os imports, implementar métodos ausentes em:
`apps/app-gasometer/lib/core/data/models/base_sync_model.dart`

### Métodos a Implementar:

#### 1. parseBaseFirebaseFields
```dart
/// Parse base Firebase fields from map
static Map<String, dynamic> parseBaseFirebaseFields(Map<String, dynamic> map) {
  final timestamps = parseFirebaseTimestamps(map);
  return {
    'id': map['id'] as String,
    'createdAt': timestamps['createdAt'],
    'updatedAt': timestamps['updatedAt'], 
    'lastSyncAt': timestamps['lastSyncAt'],
    'isDirty': map['is_dirty'] as bool? ?? false,
    'isDeleted': map['is_deleted'] as bool? ?? false,
    'version': map['version'] as int? ?? 1,
    'userId': map['user_id'] as String?,
    'moduleName': map['module_name'] as String? ?? 'gasometer',
  };
}
```

#### 2. baseFirebaseFields getter
```dart
/// Base Firebase fields for all models
Map<String, dynamic> get baseFirebaseFields => {
  'id': id,
  'is_dirty': isDirty,
  'is_deleted': isDeleted,
  'version': version,
  'user_id': userId,
  'module_name': moduleName,
  ...firebaseTimestampFields,
};
```

---

## 🔧 FASE 3 - Resolver Construtores

### Problema: const constructor com HiveObjectMixin
Remover `const` dos construtores nos seguintes arquivos:
- `expense_model.dart` - linha ~45
- `category_model.dart` - linha ~25  
- Todos os outros modelos com mesmo padrão

### Alternativa: Implementar Factory Pattern
```dart
factory ExpenseModel.create({
  required String id,
  // ... outros params
}) {
  return ExpenseModel._internal(
    id: id,
    // ... outros params
  );
}

const ExpenseModel._internal({
  // ... internal constructor
});
```

---

## 🔧 FASE 4 - Corrigir Parâmetros de Construtor

Nos arquivos de modelo, alinhar chamadas super() com parâmetros disponíveis:

### Exemplo em expense_model.dart:
```dart
const ExpenseModel({
  required this.id,
  this.createdAtMs,
  this.updatedAtMs,
  this.lastSyncAtMs,
  this.isDirty = false,
  this.isDeleted = false,
  this.version = 1,
  this.userId,
  this.moduleName = 'gasometer',
  // ... campos específicos
}) : super(
    id: id,
    createdAt: createdAtMs != null 
        ? DateTime.fromMillisecondsSinceEpoch(createdAtMs)
        : null,
    updatedAt: updatedAtMs != null
        ? DateTime.fromMillisecondsSinceEpoch(updatedAtMs) 
        : null,
    lastSyncAt: lastSyncAtMs != null
        ? DateTime.fromMillisecondsSinceEpoch(lastSyncAtMs)
        : null,
    isDirty: isDirty,
    isDeleted: isDeleted,
    version: version,
    userId: userId,
    moduleName: moduleName,
  );
```

---

## 📋 Checklist de Execução

### ✅ FASE 1 - Imports (30 min)
- [ ] Corrigir expense_model.dart import
- [ ] Corrigir fuel_supply_model.dart import  
- [ ] Corrigir maintenance_model.dart import
- [ ] Corrigir odometer_model.dart import
- [ ] Corrigir vehicle_model.dart import
- [ ] Testar: `flutter analyze apps/app-gasometer/lib/features/`

### ✅ FASE 2 - Métodos Base (45 min)
- [ ] Implementar parseBaseFirebaseFields em BaseSyncModel
- [ ] Implementar baseFirebaseFields getter
- [ ] Verificar outros métodos ausentes
- [ ] Testar: `flutter analyze apps/app-gasometer/lib/core/`

### ✅ FASE 3 - Construtores (30 min)  
- [ ] Remover const de expense_model.dart
- [ ] Remover const de category_model.dart
- [ ] Verificar outros modelos similares
- [ ] Testar: Verificar const_constructor_with_non_final_field eliminado

### ✅ FASE 4 - Parâmetros (60 min)
- [ ] Alinhar construtores em expense_model.dart
- [ ] Alinhar construtores em outros modelos
- [ ] Implementar conversões DateTime <-> milliseconds
- [ ] Testar: `flutter analyze apps/app-gasometer/`

### ✅ VALIDAÇÃO FINAL (15 min)
- [ ] Executar: `flutter analyze apps/app-gasometer/`
- [ ] Meta: Zero erros críticos em app-gasometer
- [ ] Executar: `flutter build apk --debug --target=lib/main.dart`
- [ ] Meta: Build bem-sucedido

---

## 🎯 Redução Esperada de Erros

### Após FASE 1 (Imports):
- **Elimina:** ~500+ erros de uri_does_not_exist
- **Elimina:** ~200+ erros de extends_non_class  
- **Elimina:** ~300+ erros de undefined_identifier

### Após FASE 2 (Métodos):
- **Elimina:** ~100+ erros de undefined_method
- **Elimina:** ~50+ erros de undefined_getter

### Após FASE 3 (Construtores):
- **Elimina:** ~100+ erros de const_constructor_with_non_final_field
- **Elimina:** ~200+ erros de invalid_constant

### Após FASE 4 (Parâmetros):
- **Elimina:** ~300+ erros de undefined_named_parameter
- **Elimina:** Erros restantes de herança

### **TOTAL ESPERADO: Redução de ~1.500+ erros críticos**
**De 7.490 para ~5.990 erros** (redução de 20%)

---

## ⚡ Comandos de Teste Rápido

```bash
# Testar imports corrigidos
flutter analyze apps/app-gasometer/lib/features/ | grep uri_does_not_exist

# Testar herança corrigida  
flutter analyze apps/app-gasometer/lib/features/ | grep extends_non_class

# Testar métodos implementados
flutter analyze apps/app-gasometer/lib/features/ | grep undefined_method

# Testar construtores corrigidos
flutter analyze apps/app-gasometer/lib/features/ | grep const_constructor

# Count total após cada fase
flutter analyze apps/app-gasometer/ | grep "error •" | wc -l
```

---

## 🚨 Riscos e Mitigações

### Risco 1: Quebrar funcionalidade existente
**Mitigação:** Testar build após cada fase

### Risco 2: Incompatibilidade entre Hive e Flutter patterns  
**Mitigação:** Implementar Factory pattern se necessário

### Risco 3: Dependências circulares
**Mitigação:** Verificar imports cuidadosamente

### Risco 4: Performance degradation
**Mitigação:** Manter conversões DateTime eficientes

---

**Tempo Total Estimado:** 3-4 horas para app-gasometer
**Próximo:** Replicar mesmas correções para app-plantis (1-2 horas)

Este plano foca em resolver sistematicamente os erros críticos que impedem
a compilação, começando pelos problemas mais fundamentais (imports) e
progredindo para questões mais específicas de implementação.