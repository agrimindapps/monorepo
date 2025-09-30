# ✅ Checklist de Refatoração - app-gasometer

## 🎯 Objetivo
Migrar 38 arquivos de imports diretos para `package:core`

---

## 📋 Fase 1: Quick Wins (2 horas - HOJE)

### ☐ 1. cloud_firestore (10 arquivos)
- [ ] `lib/core/logging/data/datasources/log_remote_data_source.dart:1`
- [ ] `lib/core/services/gasometer_firebase_service.dart:5`
- [ ] `lib/features/fuel/data/datasources/fuel_remote_data_source.dart:1`
- [ ] `lib/features/auth/data/models/user_model.dart:1`
- [ ] `lib/features/expenses/data/datasources/expenses_remote_data_source.dart:1`
- [ ] `lib/features/vehicles/data/datasources/vehicle_remote_data_source.dart:1`
- [ ] `lib/features/maintenance/data/datasources/maintenance_remote_data_source.dart:3`
- [ ] `lib/features/odometer/data/datasources/odometer_remote_data_source.dart:1`
- [ ] `lib/features/premium/data/datasources/premium_webhook_data_source.dart:3`
- [ ] `lib/features/premium/data/datasources/premium_firebase_data_source.dart:3`

**Substituir**: `import 'package:cloud_firestore/cloud_firestore.dart';` → `import 'package:core/core.dart';`

---

### ☐ 2. hive (6 arquivos)
- [ ] `lib/core/data/models/base_model.dart:1`
- [ ] `lib/core/data/models/category_model.dart:1`
- [ ] `lib/core/logging/entities/log_entry.dart:1`
- [ ] `lib/features/expenses/data/repositories/expenses_repository.dart:5`
- [ ] `lib/features/maintenance/data/repositories/maintenance_repository.dart:2`
- [ ] `lib/features/odometer/data/repositories/odometer_repository.dart:5`

**Substituir**: `import 'package:hive/hive.dart';` → `import 'package:core/core.dart';`

---

### ☐ 3. shared_preferences (7 arquivos)
- [ ] `lib/core/services/local_data_service.dart:4`
- [ ] `lib/core/services/data_cleaner_service.dart:3`
- [ ] `lib/features/auth/presentation/controllers/login_controller.dart:4`
- [ ] `lib/features/data_export/data/repositories/data_export_repository_impl.dart:5`
- [ ] `lib/features/data_export/domain/services/data_export_service.dart:3`
- [ ] `lib/features/premium/data/datasources/premium_local_data_source.dart:2`
- [ ] `lib/shared/widgets/enhanced_vehicle_selector.dart:4`

**Substituir**: `import 'package:shared_preferences/shared_preferences.dart';` → `import 'package:core/core.dart';`

---

### ☐ 4. connectivity_plus (4 arquivos)
- [ ] `lib/core/logging/data/repositories/log_repository_impl.dart:3`
- [ ] `lib/core/services/startup_sync_service.dart:1`
- [ ] `lib/features/expenses/data/repositories/expenses_repository.dart:3`
- [ ] `lib/features/odometer/data/repositories/odometer_repository.dart:3`

**Substituir**: `import 'package:connectivity_plus/connectivity_plus.dart';` → `import 'package:core/core.dart';`

---

### ☐ 5. firebase_analytics (1 arquivo)
- [ ] `lib/core/di/modules/core_module.dart:2`

**Substituir**: `import 'package:firebase_analytics/firebase_analytics.dart';` → `import 'package:core/core.dart';`

---

### ☐ 6. Validação Fase 1
- [ ] Rodar `flutter analyze`
- [ ] Build debug: `flutter build apk --debug`
- [ ] Testar funcionalidades críticas
- [ ] Commit: `git commit -m "refactor: migrate 28 files to use core package"`

**Checkpoint**: Score 6.0 → 7.5 ✅

---

## 📦 Fase 2: Adicionar Packages ao Core (2 dias)

### ☐ 7. Adicionar image_picker ao core
1. [ ] Editar `packages/core/pubspec.yaml`:
```yaml
dependencies:
  image_picker: ^1.0.7
```
2. [ ] Criar `packages/core/lib/src/shared/services/image_picker_service.dart`
3. [ ] Exportar em `packages/core/lib/core.dart`:
```dart
export 'src/shared/services/image_picker_service.dart';
```
4. [ ] Testar no core: `cd packages/core && flutter test`

---

### ☐ 8. Migrar image_picker (8 arquivos)
- [ ] `lib/core/presentation/widgets/enhanced_image_picker.dart:3`
- [ ] `lib/core/services/avatar_service.dart:6`
- [ ] `lib/features/fuel/presentation/providers/fuel_form_notifier.dart:6`
- [ ] `lib/features/fuel/presentation/providers/fuel_form_provider.dart:4`
- [ ] `lib/features/expenses/presentation/providers/expense_form_provider.dart:5`
- [ ] `lib/features/profile/presentation/widgets/profile_image_picker_widget.dart:6`
- [ ] `lib/features/vehicles/presentation/pages/add_vehicle_page.dart:7`
- [ ] `lib/features/maintenance/presentation/providers/maintenance_form_provider.dart:4`

**Substituir**: `import 'package:image_picker/image_picker.dart';` → `import 'package:core/core.dart';`

---

### ☐ 9. Adicionar device_info_plus ao core
1. [ ] Editar `packages/core/pubspec.yaml`:
```yaml
dependencies:
  device_info_plus: ^10.0.0
```
2. [ ] Criar wrapper service no core
3. [ ] Exportar no `core.dart`

---

### ☐ 10. Migrar device_info_plus (2 arquivos)
- [ ] `lib/features/device_management/di/device_management_module.dart:2`
- [ ] `lib/features/device_management/core/device_integration_service.dart:4`

**Substituir**: `import 'package:device_info_plus/device_info_plus.dart';` → `import 'package:core/core.dart';`

---

### ☐ 11. Validação Fase 2
- [ ] Rodar `flutter analyze`
- [ ] Build release: `flutter build apk --release`
- [ ] Testes E2E
- [ ] Commit: `git commit -m "refactor: complete core package migration (38 files)"`

**Checkpoint**: Score 7.5 → 9.0 ✅

---

## 📊 Progresso

| Fase | Arquivos | Status | Score |
|------|----------|--------|-------|
| Inicial | 0/38 | ⚪ Não iniciado | 6.0/10 |
| Fase 1 | 28/38 | ⚪ Não iniciado | 7.5/10 |
| Fase 2 | 38/38 | ⚪ Não iniciado | 9.0/10 |

---

## 🎯 Meta Final
✅ 38 arquivos migrados
📈 Score: 6.0 → 9.0 (+50%)
⏱️ Tempo: 2h (Fase 1) + 2 dias (Fase 2)

---

**Última atualização**: 2025-09-30
**Responsável**: [Seu nome]
**Branch**: `refactor/gasometer-centralize-core`
