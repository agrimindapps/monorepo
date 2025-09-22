# Fix: Firestore Indexes Missing - App-Gasometer

## Problema Identificado
O app está fazendo consultas ao Firestore que requerem índices compostos que não foram criados, resultando em erros:

```
Background fuel vehicle sync failed: ServerException: Erro ao buscar registros por veículo: [cloud_firestore/failed-precondition] The query requires an index.
```

## Solução Temporária Aplicada ✅
- Desabilitado sync em background em `fuel_repository_impl.dart:116` e `:159`
- Desabilitado sync em background em `maintenance_repository_impl.dart:50`
- App funcionará 100% offline até que índices sejam criados

## Solução Definitiva - Criar Índices Firestore

### 1. Índices Necessários

#### Fuel Records
```json
{
  "collectionGroup": "fuel_records",
  "queryScope": "COLLECTION_GROUP",
  "fields": [
    {"fieldPath": "vehicle_id", "order": "ASCENDING"},
    {"fieldPath": "date", "order": "DESCENDING"},
    {"fieldPath": "__name__", "order": "DESCENDING"}
  ]
}
```

#### Maintenance Records
```json
{
  "collectionGroup": "maintenance",
  "queryScope": "COLLECTION_GROUP",
  "fields": [
    {"fieldPath": "is_deleted", "order": "ASCENDING"},
    {"fieldPath": "data", "order": "DESCENDING"},
    {"fieldPath": "__name__", "order": "DESCENDING"}
  ]
}
```

### 2. Como Aplicar

#### Opção A: Firebase Console
1. Acesse: https://console.firebase.google.com/project/gasometer-12c83/firestore/indexes
2. Clique em "Create Index"
3. Configure cada índice manualmente

#### Opção B: Firebase CLI
```bash
cd apps/app-gasometer
firebase use gasometer-12c83
firebase deploy --only firestore:indexes
```

#### Opção C: Links Diretos dos Erros
Fuel Records: https://console.firebase.google.com/v1/r/project/gasometer-12c83/firestore/indexes?create_composite=ClRwcm9qZWN0cy9nYXNvbWV0ZXItMTJjODMvZGF0YWJhc2VzLyhkZWZhdWx0KS9jb2xsZWN0aW9uR3JvdXBzL2Z1ZWxfcmVjb3Jkcy9pbmRleGVzL18QARoOCgp2ZWhpY2xlX2lkEAEaCAoEZGF0ZRACGgwKCF9fbmFtZV9fEAI

Maintenance: https://console.firebase.google.com/v1/r/project/gasometer-12c83/firestore/indexes?create_composite=ClNwcm9qZWN0cy9nYXNvbWV0ZXItMTJjODMvZGF0YWJhc2VzLyhkZWZhdWx0KS9jb2xsZWN0aW9uR3JvdXBzL21haW50ZW5hbmNlL2luZGV4ZXMvXxABGg4KCmlzX2RlbGV0ZWQQARoICgRkYXRhEAIaDAoIX19uYW1lX18QAg

### 3. Reativar Sync (Após Índices Criados)

Remover comentários das linhas:
- `fuel_repository_impl.dart:116`: `unawaited(_syncAllFuelRecordsInBackground());`
- `fuel_repository_impl.dart:159`: `unawaited(_syncFuelRecordsByVehicleInBackground(vehicleId));`
- `maintenance_repository_impl.dart:50`: `_scheduleSyncInBackground();`

## Status
- ✅ **IMEDIATO**: App funciona offline sem erros
- ⏳ **PENDENTE**: Criação dos índices Firestore
- ⏳ **FINAL**: Reativação do sync em background

## Impacto
- **Positivo**: Elimina erros de consulta e logs de erro
- **Temporário**: Sync manual necessário até índices criados
- **UX**: App continua funcional normalmente (dados locais)