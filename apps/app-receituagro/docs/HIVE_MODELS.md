# Documentação dos Modelos Hive - APP RECEITUAGRO

> Documentação gerada automaticamente em /private/tmp
> Data de geração: $(date +"%d/%m/%Y %H:%M:%S")

## Índice

- [AppSettingsModel](#appsettingsmodel)
- [ComentarioHive](#comentariohive)
- [CulturaHive](#culturahive)
- [DiagnosticoHive](#diagnosticohive)
- [FavoritoItemHive](#favoritoitemhive)
- [FitossanitarioHive](#fitossanitariohive)
- [FitossanitarioInfoHive](#fitossanitarioinfohive)
- [PlantasInfHive](#plantasinfhive)
- [PragasHive](#pragashive)
- [PragasInfHive](#pragasinfhive)
- [PremiumStatusHive](#premiumstatushive)
- [SyncQueueItem](#syncqueueitem)

---

## AppSettingsModel

**TypeId**: `20`  
**Arquivo**: `app-receituagro/lib/core/data/models/app_settings_model.dart`

### Campos (HiveFields)

| ID | Nome do Campo | Tipo | Nullable |
|----|---------------|------|----------|
| 0 | `theme` | `String` | ✓ |
| 1 | `language` | `String` | ✓ |
| 2 | `enableNotifications` | `bool` | ✗ |
| 3 | `enableSync` | `bool` | ✗ |
| 4 | `featureFlags` | `Map<String, bool>` | ✗ |
| 5 | `userId` | `String` | ✓ |
| 6 | `sync_synchronized` | `bool` | ✗ |
| 7 | `sync_syncedAt` | `DateTime` | ✓ |
| 8 | `sync_createdAt` | `DateTime` | ✗ |
| 9 | `sync_updatedAt` | `DateTime` | ✓ |

---

## ComentarioHive

**TypeId**: `108`  
**Arquivo**: `app-receituagro/lib/core/data/models/comentario_hive.dart`

### Campos (HiveFields)

| ID | Nome do Campo | Tipo | Nullable |
|----|---------------|------|----------|
| 0 | `sync_objectId` | `String` | ✓ |
| 1 | `sync_createdAt` | `int` | ✓ |
| 2 | `sync_updatedAt` | `int` | ✓ |
| 3 | `idReg` | `String` | ✗ |
| 4 | `sync_deleted` | `bool` | ✗ |
| 5 | `titulo` | `String` | ✗ |
| 6 | `conteudo` | `String` | ✗ |
| 7 | `ferramenta` | `String` | ✗ |
| 8 | `pkIdentificador` | `String` | ✗ |
| 9 | `userId` | `String` | ✗ |

---

## CulturaHive

**TypeId**: `100`  
**Arquivo**: `app-receituagro/lib/core/data/models/cultura_hive.dart`

### Campos (HiveFields)

| ID | Nome do Campo | Tipo | Nullable |
|----|---------------|------|----------|
| 0 | `objectId` | `String` | ✗ |
| 1 | `createdAt` | `int` | ✗ |
| 2 | `updatedAt` | `int` | ✗ |
| 3 | `idReg` | `String` | ✗ |
| 4 | `cultura` | `String` | ✗ |

---

## DiagnosticoHive

**TypeId**: `101`  
**Arquivo**: `app-receituagro/lib/core/data/models/diagnostico_hive.dart`

### Campos (HiveFields)

| ID | Nome do Campo | Tipo | Nullable |
|----|---------------|------|----------|
| 0 | `objectId` | `String` | ✗ |
| 1 | `createdAt` | `int` | ✗ |
| 2 | `updatedAt` | `int` | ✗ |
| 3 | `idReg` | `String` | ✗ |
| 4 | `fkIdDefensivo` | `String` | ✗ |
| 5 | `nomeDefensivo` | `String` | ✓ |
| 6 | `fkIdCultura` | `String` | ✗ |
| 7 | `nomeCultura` | `String` | ✓ |
| 8 | `fkIdPraga` | `String` | ✗ |
| 9 | `nomePraga` | `String` | ✓ |
| 10 | `dsMin` | `String` | ✓ |
| 11 | `dsMax` | `String` | ✗ |
| 12 | `um` | `String` | ✗ |
| 13 | `minAplicacaoT` | `String` | ✓ |
| 14 | `maxAplicacaoT` | `String` | ✓ |
| 15 | `umT` | `String` | ✓ |
| 16 | `minAplicacaoA` | `String` | ✓ |
| 17 | `maxAplicacaoA` | `String` | ✓ |
| 18 | `umA` | `String` | ✓ |
| 19 | `intervalo` | `String` | ✓ |
| 20 | `intervalo2` | `String` | ✓ |
| 21 | `epocaAplicacao` | `String` | ✓ |

---

## FavoritoItemHive

**TypeId**: `110`  
**Arquivo**: `app-receituagro/lib/core/data/models/favorito_item_hive.dart`

### Campos (HiveFields)

| ID | Nome do Campo | Tipo | Nullable |
|----|---------------|------|----------|
| 0 | `sync_objectId` | `String` | ✗ |
| 1 | `sync_createdAt` | `int` | ✗ |
| 2 | `sync_updatedAt` | `int` | ✗ |
| 3 | `tipo` | `String` | ✗ |
| 4 | `itemId` | `String` | ✗ |
| 5 | `itemData` | `String` | ✗ |

---

## FitossanitarioHive

**TypeId**: `102`  
**Arquivo**: `app-receituagro/lib/core/data/models/fitossanitario_hive.dart`

### Campos (HiveFields)

| ID | Nome do Campo | Tipo | Nullable |
|----|---------------|------|----------|
| 0 | `objectId` | `String` | ✓ |
| 1 | `createdAt` | `int` | ✓ |
| 2 | `updatedAt` | `int` | ✓ |
| 3 | `idReg` | `String` | ✗ |
| 4 | `status` | `bool` | ✗ |
| 5 | `nomeComum` | `String` | ✗ |
| 6 | `nomeTecnico` | `String` | ✗ |
| 7 | `classeAgronomica` | `String` | ✓ |
| 8 | `fabricante` | `String` | ✓ |
| 9 | `classAmbiental` | `String` | ✓ |
| 10 | `comercializado` | `int` | ✗ |
| 11 | `corrosivo` | `String` | ✓ |
| 12 | `inflamavel` | `String` | ✓ |
| 13 | `formulacao` | `String` | ✓ |
| 14 | `modoAcao` | `String` | ✓ |
| 15 | `mapa` | `String` | ✓ |
| 16 | `toxico` | `String` | ✓ |
| 17 | `ingredienteAtivo` | `String` | ✓ |
| 18 | `quantProduto` | `String` | ✓ |
| 19 | `elegivel` | `bool` | ✗ |

---

## FitossanitarioInfoHive

**TypeId**: `103`  
**Arquivo**: `app-receituagro/lib/core/data/models/fitossanitario_info_hive.dart`

### Campos (HiveFields)

| ID | Nome do Campo | Tipo | Nullable |
|----|---------------|------|----------|
| 0 | `objectId` | `String` | ✗ |
| 1 | `createdAt` | `int` | ✗ |
| 2 | `updatedAt` | `int` | ✗ |
| 3 | `idReg` | `String` | ✗ |
| 4 | `embalagens` | `String` | ✓ |
| 5 | `tecnologia` | `String` | ✓ |
| 6 | `pHumanas` | `String` | ✓ |
| 7 | `pAmbiental` | `String` | ✓ |
| 8 | `manejoResistencia` | `String` | ✓ |
| 9 | `compatibilidade` | `String` | ✓ |
| 10 | `manejoIntegrado` | `String` | ✓ |
| 11 | `fkIdDefensivo` | `String` | ✗ |

---

## PlantasInfHive

**TypeId**: `104`  
**Arquivo**: `app-receituagro/lib/core/data/models/plantas_inf_hive.dart`

### Campos (HiveFields)

| ID | Nome do Campo | Tipo | Nullable |
|----|---------------|------|----------|
| 0 | `objectId` | `String` | ✗ |
| 1 | `createdAt` | `int` | ✗ |
| 2 | `updatedAt` | `int` | ✗ |
| 3 | `idReg` | `String` | ✗ |
| 4 | `ciclo` | `String` | ✓ |
| 5 | `reproducao` | `String` | ✓ |
| 6 | `habitat` | `String` | ✓ |
| 7 | `adaptacoes` | `String` | ✓ |
| 8 | `altura` | `String` | ✓ |
| 9 | `filotaxia` | `String` | ✓ |
| 10 | `formaLimbo` | `String` | ✓ |
| 11 | `superficie` | `String` | ✓ |
| 12 | `consistencia` | `String` | ✓ |
| 13 | `nervacao` | `String` | ✓ |
| 14 | `nervacaoComprimento` | `String` | ✓ |
| 15 | `inflorescencia` | `String` | ✓ |
| 16 | `perianto` | `String` | ✓ |
| 17 | `tipologiaFruto` | `String` | ✓ |
| 18 | `observacoes` | `String` | ✓ |
| 19 | `fkIdPraga` | `String` | ✓ |

---

## PragasHive

**TypeId**: `105`  
**Arquivo**: `app-receituagro/lib/core/data/models/pragas_hive.dart`

### Campos (HiveFields)

| ID | Nome do Campo | Tipo | Nullable |
|----|---------------|------|----------|
| 0 | `objectId` | `String` | ✗ |
| 1 | `createdAt` | `int` | ✗ |
| 2 | `updatedAt` | `int` | ✗ |
| 3 | `idReg` | `String` | ✗ |
| 4 | `nomeComum` | `String` | ✗ |
| 5 | `nomeCientifico` | `String` | ✗ |
| 6 | `dominio` | `String` | ✓ |
| 7 | `reino` | `String` | ✓ |
| 8 | `subReino` | `String` | ✓ |
| 9 | `clado01` | `String` | ✓ |
| 10 | `clado02` | `String` | ✓ |
| 11 | `clado03` | `String` | ✓ |
| 12 | `superDivisao` | `String` | ✓ |
| 13 | `divisao` | `String` | ✓ |
| 14 | `subDivisao` | `String` | ✓ |
| 15 | `classe` | `String` | ✓ |
| 16 | `subClasse` | `String` | ✓ |
| 17 | `superOrdem` | `String` | ✓ |
| 18 | `ordem` | `String` | ✓ |
| 19 | `subOrdem` | `String` | ✓ |
| 20 | `infraOrdem` | `String` | ✓ |
| 21 | `superFamilia` | `String` | ✓ |
| 22 | `familia` | `String` | ✓ |
| 23 | `subFamilia` | `String` | ✓ |
| 24 | `tribo` | `String` | ✓ |
| 25 | `subTribo` | `String` | ✓ |
| 26 | `genero` | `String` | ✓ |
| 27 | `especie` | `String` | ✓ |
| 28 | `tipoPraga` | `String` | ✗ |

---

## PragasInfHive

**TypeId**: `106`  
**Arquivo**: `app-receituagro/lib/core/data/models/pragas_inf_hive.dart`

### Campos (HiveFields)

| ID | Nome do Campo | Tipo | Nullable |
|----|---------------|------|----------|
| 0 | `objectId` | `String` | ✗ |
| 1 | `createdAt` | `int` | ✗ |
| 2 | `updatedAt` | `int` | ✗ |
| 3 | `idReg` | `String` | ✗ |
| 4 | `descrisao` | `String` | ✓ |
| 5 | `sintomas` | `String` | ✓ |
| 6 | `bioecologia` | `String` | ✓ |
| 7 | `controle` | `String` | ✓ |
| 8 | `fkIdPraga` | `String` | ✗ |

---

## PremiumStatusHive

**TypeId**: `111`  
**Arquivo**: `app-receituagro/lib/core/data/models/premium_status_hive.dart`

### Campos (HiveFields)

| ID | Nome do Campo | Tipo | Nullable |
|----|---------------|------|----------|
| 0 | `sync_objectId` | `String` | ✓ |
| 1 | `sync_createdAt` | `int` | ✓ |
| 2 | `sync_updatedAt` | `int` | ✓ |
| 3 | `userId` | `String` | ✗ |
| 4 | `isActive` | `bool` | ✗ |
| 5 | `isTestSubscription` | `bool` | ✗ |
| 6 | `expiryDateTimestamp` | `int` | ✓ |
| 7 | `planType` | `String` | ✓ |
| 8 | `subscriptionId` | `String` | ✓ |
| 9 | `productId` | `String` | ✓ |
| 10 | `sync_lastSyncTimestamp` | `int` | ✓ |
| 11 | `sync_needsOnlineSync` | `bool` | ✗ |

---

## SyncQueueItem

**TypeId**: `109`  
**Arquivo**: `app-receituagro/lib/core/data/models/sync_queue_item.dart`

### Campos (HiveFields)

| ID | Nome do Campo | Tipo | Nullable |
|----|---------------|------|----------|
| 0 | `sync_id` | `String` | ✗ |
| 1 | `modelType` | `String` | ✗ |
| 2 | `sync_operation` | `String` | ✗ |
| 3 | `data` | `Map<String, dynamic>` | ✗ |
| 4 | `sync_timestamp` | `DateTime` | ✗ |
| 5 | `sync_retryCount` | `int` | ✗ |
| 6 | `sync_isSynced` | `bool` | ✗ |
| 7 | `sync_errorMessage` | `String` | ✓ |
| 8 | `sync_lastRetryAt` | `DateTime` | ✓ |

---

