# Documentação dos Modelos Hive - APP NUTRITUTI

> Documentação gerada automaticamente em /private/tmp
> Data de geração: $(date +"%d/%m/%Y %H:%M:%S")

## Índice

- [BeberAgua](#beberagua)
- [Comentarios](#comentarios)
- [PerfilModel](#perfilmodel)
- [PesoModel](#pesomodel)
- [WaterAchievementModel](#waterachievementmodel)
- [WaterRecordModel](#waterrecordmodel)

---

## BeberAgua

**TypeId**: `51`  
**Arquivo**: `app-nutrituti/lib/pages/agua/models/beber_agua_model.dart`

### Campos (HiveFields)

| ID | Nome do Campo | Tipo | Nullable |
|----|---------------|------|----------|
| 0 | `id` | `String` | ✓ |
| 1 | `createdAt` | `DateTime` | ✓ |
| 2 | `updatedAt` | `DateTime` | ✓ |
| 7 | `dataRegistro` | `int` | ✗ |
| 8 | `quantidade` | `double` | ✗ |
| 9 | `fkIdPerfil` | `String` | ✗ |

---

## Comentarios

**TypeId**: `50`  
**Arquivo**: `app-nutrituti/lib/database/comentarios_models.dart`

### Campos (HiveFields)

| ID | Nome do Campo | Tipo | Nullable |
|----|---------------|------|----------|
| 0 | `id` | `String` | ✓ |
| 1 | `createdAt` | `DateTime` | ✓ |
| 2 | `updatedAt` | `DateTime` | ✓ |
| 7 | `titulo` | `String` | ✗ |
| 8 | `conteudo` | `String` | ✗ |
| 9 | `ferramenta` | `String` | ✗ |
| 10 | `pkIdentificador` | `String` | ✗ |

---

## PerfilModel

**TypeId**: `52`  
**Arquivo**: `app-nutrituti/lib/database/perfil_model.dart`

### Campos (HiveFields)

| ID | Nome do Campo | Tipo | Nullable |
|----|---------------|------|----------|
| 0 | `id` | `String` | ✓ |
| 1 | `createdAt` | `DateTime` | ✓ |
| 2 | `updatedAt` | `DateTime` | ✓ |
| 7 | `nome` | `String` | ✗ |
| 8 | `datanascimento` | `DateTime` | ✗ |
| 9 | `altura` | `double` | ✗ |
| 10 | `peso` | `double` | ✗ |
| 11 | `genero` | `int` | ✗ |
| 12 | `imagePath` | `String` | ✓ |

---

## PesoModel

**TypeId**: `53`  
**Arquivo**: `app-nutrituti/lib/pages/peso/models/peso_model.dart`

### Campos (HiveFields)

| ID | Nome do Campo | Tipo | Nullable |
|----|---------------|------|----------|
| 0 | `id` | `String` | ✓ |
| 1 | `createdAt` | `DateTime` | ✓ |
| 2 | `updatedAt` | `DateTime` | ✓ |
| 7 | `dataRegistro` | `int` | ✗ |
| 8 | `peso` | `double` | ✗ |
| 9 | `fkIdPerfil` | `String` | ✗ |
| 10 | `isDeleted` | `bool` | ✗ |

---

## WaterAchievementModel

**TypeId**: `11`  
**Arquivo**: `app-nutrituti/lib/features/water/data/models/water_achievement_model.dart`

### Campos (HiveFields)

| ID | Nome do Campo | Tipo | Nullable |
|----|---------------|------|----------|
| 0 | `id` | `String` | ✗ |
| 1 | `type` | `AchievementType` | ✗ |
| 2 | `title` | `String` | ✗ |
| 3 | `description` | `String` | ✗ |
| 4 | `unlockedAt` | `DateTime` | ✗ |
| 5 | `iconName` | `String` | ✓ |

---

## WaterRecordModel

**TypeId**: `10`  
**Arquivo**: `app-nutrituti/lib/features/water/data/models/water_record_model.dart`

### Campos (HiveFields)

| ID | Nome do Campo | Tipo | Nullable |
|----|---------------|------|----------|
| 0 | `id` | `String` | ✗ |
| 1 | `amount` | `int` | ✗ |
| 2 | `timestamp` | `DateTime` | ✗ |
| 3 | `note` | `String` | ✓ |

---

