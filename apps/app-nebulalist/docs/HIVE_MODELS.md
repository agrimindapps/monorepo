# Documentação dos Modelos Hive - APP NEBULALIST

> Documentação gerada automaticamente em /private/tmp
> Data de geração: $(date +"%d/%m/%Y %H:%M:%S")

## Índice

- [ItemMasterModel](#itemmastermodel)
- [ListItemModel](#listitemmodel)
- [ListModel](#listmodel)

---

## ItemMasterModel

**TypeId**: `1`  
**Arquivo**: `app-nebulalist/lib/features/items/data/models/item_master_model.dart`

### Campos (HiveFields)

| ID | Nome do Campo | Tipo | Nullable |
|----|---------------|------|----------|
| 0 | `id` | `String` | ✗ |
| 1 | `ownerId` | `String` | ✗ |
| 2 | `name` | `String` | ✗ |
| 3 | `description` | `String` | ✗ |
| 4 | `tags` | `List<String>` | ✗ |
| 5 | `category` | `String` | ✗ |
| 6 | `photoUrl` | `String` | ✓ |
| 7 | `estimatedPrice` | `double` | ✓ |
| 8 | `preferredBrand` | `String` | ✓ |
| 9 | `notes` | `String` | ✓ |
| 10 | `usageCount` | `int` | ✗ |
| 11 | `createdAt` | `DateTime` | ✗ |
| 12 | `updatedAt` | `DateTime` | ✗ |

---

## ListItemModel

**TypeId**: `2`  
**Arquivo**: `app-nebulalist/lib/features/items/data/models/list_item_model.dart`

### Campos (HiveFields)

| ID | Nome do Campo | Tipo | Nullable |
|----|---------------|------|----------|
| 0 | `id` | `String` | ✗ |
| 1 | `listId` | `String` | ✗ |
| 2 | `itemMasterId` | `String` | ✗ |
| 3 | `quantity` | `String` | ✗ |
| 4 | `priorityIndex` | `int` | ✗ |
| 5 | `isCompleted` | `bool` | ✗ |
| 6 | `completedAt` | `DateTime` | ✓ |
| 7 | `notes` | `String` | ✓ |
| 8 | `order` | `int` | ✗ |
| 9 | `createdAt` | `DateTime` | ✗ |
| 10 | `updatedAt` | `DateTime` | ✗ |
| 11 | `addedBy` | `String` | ✓ |

---

## ListModel

**TypeId**: `0`  
**Arquivo**: `app-nebulalist/lib/features/lists/data/models/list_model.dart`

### Campos (HiveFields)

| ID | Nome do Campo | Tipo | Nullable |
|----|---------------|------|----------|
| 0 | `id` | `String` | ✗ |
| 1 | `name` | `String` | ✗ |
| 2 | `ownerId` | `String` | ✗ |
| 3 | `description` | `String` | ✗ |
| 4 | `tags` | `List<String>` | ✗ |
| 5 | `category` | `String` | ✗ |
| 6 | `isFavorite` | `bool` | ✗ |
| 7 | `isArchived` | `bool` | ✗ |
| 8 | `createdAt` | `DateTime` | ✗ |
| 9 | `updatedAt` | `DateTime` | ✗ |
| 10 | `shareToken` | `String` | ✓ |
| 11 | `isShared` | `bool` | ✗ |
| 12 | `archivedAt` | `DateTime` | ✓ |
| 13 | `itemCount` | `int` | ✗ |
| 14 | `completedCount` | `int` | ✗ |

---

