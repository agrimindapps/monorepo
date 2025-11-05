# Documentação dos Modelos Hive - APP GASOMETER

> Documentação gerada automaticamente em /private/tmp
> Data de geração: $(date +"%d/%m/%Y %H:%M:%S")

## Índice

- [CategoryModel](#categorymodel)
- [ExpenseModel](#expensemodel)
- [FinancialAuditEntry](#financialauditentry)
- [FuelSupplyModel](#fuelsupplymodel)
- [LogEntry](#logentry)
- [MaintenanceModel](#maintenancemodel)
- [OdometerModel](#odometermodel)
- [PendingImageUpload](#pendingimageupload)
- [VehicleModel](#vehiclemodel)

---

## CategoryModel

**TypeId**: `5`  
**Arquivo**: `app-gasometer/lib/core/data/models/category_model.dart`

### Campos (HiveFields)

| ID | Nome do Campo | Tipo | Nullable |
|----|---------------|------|----------|
| 0 | `id` | `String` | ✗ |
| 1 | `createdAtMs` | `int` | ✓ |
| 2 | `updatedAtMs` | `int` | ✓ |
| 3 | `lastSyncAtMs` | `int` | ✓ |
| 4 | `isDirty` | `bool` | ✗ |
| 5 | `isDeleted` | `bool` | ✗ |
| 6 | `version` | `int` | ✗ |
| 7 | `userId` | `String` | ✓ |
| 8 | `moduleName` | `String` | ✓ |
| 10 | `categoria` | `int` | ✗ |
| 11 | `descricao` | `String` | ✗ |

---

## ExpenseModel

**TypeId**: `13`  
**Arquivo**: `app-gasometer/lib/features/expenses/data/models/expense_model.dart`

### Campos (HiveFields)

| ID | Nome do Campo | Tipo | Nullable |
|----|---------------|------|----------|
| 0 | `id` | `String` | ✗ |
| 1 | `createdAtMs` | `int` | ✓ |
| 2 | `updatedAtMs` | `int` | ✓ |
| 3 | `lastSyncAtMs` | `int` | ✓ |
| 4 | `isDirty` | `bool` | ✗ |
| 5 | `isDeleted` | `bool` | ✗ |
| 6 | `version` | `int` | ✗ |
| 7 | `userId` | `String` | ✓ |
| 8 | `moduleName` | `String` | ✓ |
| 10 | `veiculoId` | `String` | ✗ |
| 11 | `tipo` | `String` | ✗ |
| 12 | `descricao` | `String` | ✗ |
| 13 | `valor` | `double` | ✗ |
| 14 | `data` | `int` | ✗ |
| 15 | `odometro` | `double` | ✗ |
| 16 | `receiptImagePath` | `String` | ✓ |
| 17 | `location` | `String` | ✓ |
| 18 | `notes` | `String` | ✓ |
| 19 | `metadata` | `Map<String, dynamic>` | ✗ |
| 20 | `receiptImageUrl` | `String` | ✓ |

---

## FinancialAuditEntry

**TypeId**: `50`  
**Arquivo**: `app-gasometer/lib/core/services/audit_trail_service.dart`

### Campos (HiveFields)

| ID | Nome do Campo | Tipo | Nullable |
|----|---------------|------|----------|
| 0 | `id` | `String` | ✗ |
| 1 | `entityId` | `String` | ✗ |
| 2 | `entityType` | `String` | ✗ |
| 3 | `eventType` | `String` | ✗ |
| 4 | `timestamp` | `int` | ✗ |
| 5 | `userId` | `String` | ✓ |
| 6 | `beforeState` | `Map<String, dynamic>` | ✗ |
| 7 | `afterState` | `Map<String, dynamic>` | ✗ |
| 8 | `description` | `String` | ✓ |
| 9 | `monetaryValue` | `double` | ✓ |
| 10 | `metadata` | `Map<String, dynamic>` | ✗ |
| 11 | `syncSource` | `String` | ✓ |

---

## FuelSupplyModel

**TypeId**: `11`  
**Arquivo**: `app-gasometer/lib/features/fuel/data/models/fuel_supply_model.dart`

### Campos (HiveFields)

| ID | Nome do Campo | Tipo | Nullable |
|----|---------------|------|----------|
| 0 | `id` | `String` | ✗ |
| 1 | `createdAtMs` | `int` | ✓ |
| 2 | `updatedAtMs` | `int` | ✓ |
| 3 | `lastSyncAtMs` | `int` | ✓ |
| 4 | `isDirty` | `bool` | ✗ |
| 5 | `isDeleted` | `bool` | ✗ |
| 6 | `version` | `int` | ✗ |
| 7 | `userId` | `String` | ✓ |
| 8 | `moduleName` | `String` | ✓ |
| 10 | `vehicleId` | `String` | ✗ |
| 11 | `date` | `int` | ✗ |
| 12 | `odometer` | `double` | ✗ |
| 13 | `liters` | `double` | ✗ |
| 14 | `totalPrice` | `double` | ✗ |
| 15 | `fullTank` | `bool` | ✓ |
| 16 | `pricePerLiter` | `double` | ✗ |
| 17 | `gasStationName` | `String` | ✓ |
| 18 | `notes` | `String` | ✓ |
| 19 | `fuelType` | `int` | ✗ |
| 20 | `receiptImageUrl` | `String` | ✓ |
| 21 | `receiptImagePath` | `String` | ✓ |

---

## LogEntry

**TypeId**: `20`  
**Arquivo**: `app-gasometer/lib/core/logging/entities/log_entry.dart`

### Campos (HiveFields)

| ID | Nome do Campo | Tipo | Nullable |
|----|---------------|------|----------|
| 0 | `id` | `String` | ✗ |
| 1 | `timestamp` | `DateTime` | ✗ |
| 2 | `level` | `String` | ✗ |
| 3 | `category` | `String` | ✗ |
| 4 | `operation` | `String` | ✗ |
| 5 | `message` | `String` | ✗ |
| 6 | `metadata` | `Map<String, dynamic>` | ✓ |
| 7 | `userId` | `String` | ✓ |
| 8 | `error` | `String` | ✓ |
| 9 | `stackTrace` | `String` | ✓ |
| 10 | `duration` | `int` | ✓ |
| 11 | `synced` | `bool` | ✗ |

---

## MaintenanceModel

**TypeId**: `14`  
**Arquivo**: `app-gasometer/lib/features/maintenance/data/models/maintenance_model.dart`

### Campos (HiveFields)

| ID | Nome do Campo | Tipo | Nullable |
|----|---------------|------|----------|
| 0 | `id` | `String` | ✗ |
| 1 | `createdAtMs` | `int` | ✓ |
| 2 | `updatedAtMs` | `int` | ✓ |
| 3 | `lastSyncAtMs` | `int` | ✓ |
| 4 | `isDirty` | `bool` | ✗ |
| 5 | `isDeleted` | `bool` | ✗ |
| 6 | `version` | `int` | ✗ |
| 7 | `userId` | `String` | ✓ |
| 8 | `moduleName` | `String` | ✓ |
| 10 | `veiculoId` | `String` | ✗ |
| 11 | `tipo` | `String` | ✗ |
| 12 | `descricao` | `String` | ✗ |
| 13 | `valor` | `double` | ✗ |
| 14 | `data` | `int` | ✗ |
| 15 | `odometro` | `int` | ✗ |
| 16 | `proximaRevisao` | `int` | ✓ |
| 17 | `concluida` | `bool` | ✗ |
| 18 | `receiptImageUrl` | `String` | ✓ |
| 19 | `receiptImagePath` | `String` | ✓ |

---

## OdometerModel

**TypeId**: `12`  
**Arquivo**: `app-gasometer/lib/features/odometer/data/models/odometer_model.dart`

### Campos (HiveFields)

| ID | Nome do Campo | Tipo | Nullable |
|----|---------------|------|----------|
| 0 | `id` | `String` | ✗ |
| 1 | `createdAtMs` | `int` | ✓ |
| 2 | `updatedAtMs` | `int` | ✓ |
| 3 | `lastSyncAtMs` | `int` | ✓ |
| 4 | `isDirty` | `bool` | ✗ |
| 5 | `isDeleted` | `bool` | ✗ |
| 6 | `version` | `int` | ✗ |
| 7 | `userId` | `String` | ✓ |
| 8 | `moduleName` | `String` | ✓ |
| 10 | `vehicleId` | `String` | ✗ |
| 11 | `registrationDate` | `int` | ✗ |
| 12 | `value` | `double` | ✗ |
| 13 | `description` | `String` | ✗ |
| 14 | `type` | `String` | ✓ |

---

## PendingImageUpload

**TypeId**: `50`  
**Arquivo**: `app-gasometer/lib/core/data/models/pending_image_upload.dart`

### Campos (HiveFields)

| ID | Nome do Campo | Tipo | Nullable |
|----|---------------|------|----------|
| 0 | `id` | `String` | ✗ |
| 1 | `localPath` | `String` | ✗ |
| 2 | `userId` | `String` | ✗ |
| 3 | `recordId` | `String` | ✗ |
| 4 | `category` | `String` | ✗ |
| 5 | `collectionPath` | `String` | ✗ |
| 6 | `createdAtMs` | `int` | ✗ |
| 7 | `retryCount` | `int` | ✗ |
| 8 | `lastError` | `String` | ✓ |
| 9 | `lastAttemptMs` | `int` | ✓ |

---

## VehicleModel

**TypeId**: `10`  
**Arquivo**: `app-gasometer/lib/features/vehicles/data/models/vehicle_model.dart`

### Campos (HiveFields)

| ID | Nome do Campo | Tipo | Nullable |
|----|---------------|------|----------|
| 0 | `id` | `String` | ✗ |
| 1 | `createdAtMs` | `int` | ✓ |
| 2 | `updatedAtMs` | `int` | ✓ |
| 3 | `lastSyncAtMs` | `int` | ✓ |
| 4 | `isDirty` | `bool` | ✗ |
| 5 | `isDeleted` | `bool` | ✗ |
| 6 | `version` | `int` | ✗ |
| 7 | `userId` | `String` | ✓ |
| 8 | `moduleName` | `String` | ✓ |
| 10 | `marca` | `String` | ✗ |
| 11 | `modelo` | `String` | ✗ |
| 12 | `ano` | `int` | ✗ |
| 13 | `placa` | `String` | ✗ |
| 14 | `odometroInicial` | `double` | ✗ |
| 15 | `combustivel` | `int` | ✗ |
| 16 | `renavan` | `String` | ✗ |
| 17 | `chassi` | `String` | ✗ |
| 18 | `cor` | `String` | ✗ |
| 19 | `vendido` | `bool` | ✗ |
| 20 | `valorVenda` | `double` | ✗ |
| 21 | `odometroAtual` | `double` | ✗ |
| 22 | `foto` | `String` | ✓ |

---

