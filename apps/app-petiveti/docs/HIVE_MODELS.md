# Documentação dos Modelos Hive - APP PETIVETI

> Documentação gerada automaticamente em /private/tmp
> Data de geração: $(date +"%d/%m/%Y %H:%M:%S")

## Índice

- [AnimalModel](#animalmodel)
- [AppointmentModel](#appointmentmodel)
- [CalculationHistoryModel](#calculationhistorymodel)
- [LogEntry](#logentry)
- [MedicationModel](#medicationmodel)
- [VaccineModel](#vaccinemodel)
- [WeightModel](#weightmodel)

---

## AnimalModel

**TypeId**: `0`  
**Arquivo**: `app-petiveti/lib/features/animals/data/models/animal_model.dart`

*Nenhum campo HiveField encontrado.*

---

## AppointmentModel

**TypeId**: `12`  
**Arquivo**: `app-petiveti/lib/features/appointments/data/models/appointment_model.dart`

### Campos (HiveFields)

| ID | Nome do Campo | Tipo | Nullable |
|----|---------------|------|----------|
| 0 | `id` | `String` | ✗ |
| 1 | `animalId` | `String` | ✗ |
| 2 | `veterinarianName` | `String` | ✗ |
| 3 | `dateTimestamp` | `int` | ✗ |
| 4 | `reason` | `String` | ✗ |
| 5 | `diagnosis` | `String` | ✓ |
| 6 | `notes` | `String` | ✓ |
| 7 | `status` | `int` | ✗ |
| 8 | `cost` | `double` | ✓ |
| 9 | `createdAtTimestamp` | `int` | ✗ |
| 10 | `updatedAtTimestamp` | `int` | ✗ |
| 11 | `isDeleted` | `bool` | ✗ |

---

## CalculationHistoryModel

**TypeId**: `20`  
**Arquivo**: `app-petiveti/lib/features/calculators/data/models/calculation_history_model.dart`

### Campos (HiveFields)

| ID | Nome do Campo | Tipo | Nullable |
|----|---------------|------|----------|
| 0 | `id` | `String` | ✗ |
| 1 | `calculatorId` | `String` | ✗ |
| 2 | `calculatorName` | `String` | ✗ |
| 3 | `inputs` | `Map<String, dynamic>` | ✗ |
| 4 | `resultData` | `Map<String, dynamic>` | ✗ |
| 5 | `createdAt` | `DateTime` | ✗ |
| 6 | `animalId` | `String` | ✓ |
| 7 | `notes` | `String` | ✓ |

---

## LogEntry

**TypeId**: `100`  
**Arquivo**: `app-petiveti/lib/core/logging/entities/log_entry.dart`

### Campos (HiveFields)

| ID | Nome do Campo | Tipo | Nullable |
|----|---------------|------|----------|
| 0 | `id` | `String` | ✗ |
| 1 | `timestamp` | `DateTime` | ✗ |
| 2 | `level` | `LogLevel` | ✗ |
| 3 | `category` | `LogCategory` | ✗ |
| 4 | `operation` | `LogOperation` | ✗ |
| 5 | `message` | `String` | ✗ |
| 6 | `metadata` | `Map<String, dynamic>` | ✓ |
| 7 | `userId` | `String` | ✓ |
| 8 | `error` | `String` | ✓ |
| 9 | `stackTrace` | `String` | ✓ |
| 10 | `duration` | `Duration` | ✓ |

---

## MedicationModel

**TypeId**: `15`  
**Arquivo**: `app-petiveti/lib/features/medications/data/models/medication_model.dart`

*Nenhum campo HiveField encontrado.*

---

## VaccineModel

**TypeId**: `16`  
**Arquivo**: `app-petiveti/lib/features/vaccines/data/models/vaccine_model.dart`

### Campos (HiveFields)

| ID | Nome do Campo | Tipo | Nullable |
|----|---------------|------|----------|
| 0 | `id` | `String` | ✗ |
| 1 | `animalId` | `String` | ✗ |
| 2 | `name` | `String` | ✗ |
| 3 | `veterinarian` | `String` | ✗ |
| 4 | `dateTimestamp` | `int` | ✗ |
| 5 | `nextDueDateTimestamp` | `int` | ✓ |
| 6 | `batch` | `String` | ✓ |
| 7 | `manufacturer` | `String` | ✓ |
| 8 | `dosage` | `String` | ✓ |
| 9 | `notes` | `String` | ✓ |
| 10 | `isRequired` | `bool` | ✗ |
| 11 | `isCompleted` | `bool` | ✗ |
| 12 | `reminderDateTimestamp` | `int` | ✓ |
| 13 | `status` | `int` | ✗ |
| 14 | `createdAtTimestamp` | `int` | ✗ |
| 15 | `updatedAtTimestamp` | `int` | ✗ |
| 16 | `isDeleted` | `bool` | ✗ |

---

## WeightModel

**TypeId**: `17`  
**Arquivo**: `app-petiveti/lib/features/weight/data/models/weight_model.dart`

*Nenhum campo HiveField encontrado.*

---

