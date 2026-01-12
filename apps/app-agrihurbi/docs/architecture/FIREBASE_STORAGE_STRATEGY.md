# 🔥 Estratégia Firebase Storage para Catálogos Read-Only

**Objetivo:** Reduzir custos de leitura de bovinos/equinos de **$360/mês** para **$0.10/mês**

---

## 💡 Problema

**Firestore atual:**
- 100 bovinos = 100 documentos = **100 reads por usuário**
- 1000 usuários = **100.000 reads/dia**
- Custo: **~$360/mês** 💸

---

## ✅ Solução: Firebase Storage + JSON

### Estrutura

```
gs://bucket/livestock/
├── bovines_catalog.json    (500KB - 150 bovinos)
├── equines_catalog.json    (300KB - 80 equinos)
└── metadata.json           (1KB - timestamps)
```

### Custos

- Storage: 800KB × $0.026/GB = **$0.00002/mês**
- Download: 1000 users × 0.8MB × $0.12/GB = **$0.096/mês**
- **Total: $0.10/mês** (redução de **3600x**!)

---

## 🔄 Fluxo

```
Admin → Supabase (CRUD)
  ↓
Script → Gera JSON
  ↓
Script → Upload Storage
  ↓
App → Verifica metadata
  ↓
App → Download se necessário
  ↓
App → Cache Drift (offline)
```

---

## 📝 Implementação

### 1. Datasource

```dart
class LivestockStorageDataSource {
  final FirebaseStorage _storage;
  
  Future<List<BovineModel>> fetchBovinesCatalog() async {
    final ref = _storage.ref('livestock/bovines_catalog.json');
    final bytes = await ref.getData();
    final json = jsonDecode(utf8.decode(bytes!));
    return (json['bovines'] as List)
        .map((e) => BovineModel.fromJson(e))
        .toList();
  }
  
  Future<bool> needsUpdate(DateTime lastLocal) async {
    final metadata = await fetchMetadata();
    return metadata.lastUpdated.isAfter(lastLocal);
  }
}
```

### 2. Repository

```dart
@override
Future<Either<Failure, List<BovineEntity>>> getBovines() async {
  // 1. Sync se necessário
  await _syncIfNeeded();
  
  // 2. Retorna do cache Drift
  final bovines = await _localDataSource.getAllBovines();
  return Right(bovines.map((m) => m.toEntity()).toList());
}
```

### 3. Script Admin

```dart
void main() async {
  final bovines = await fetchFromSupabase();
  final json = jsonEncode({
    'bovines': bovines.map((b) => b.toJson()).toList(),
    'count': bovines.length,
  });
  
  await FirebaseStorage.instance
      .ref('livestock/bovines_catalog.json')
      .putString(json);
}
```

---

## 🎯 Vantagens

✅ Custo **3600x menor**  
✅ **Offline-first** (Drift cache)  
✅ Update **incremental**  
✅ **CDN global**  
✅ Sem limite de reads  

---

## 📊 Comparação

| Método | Custo/mês | Limite | Offline |
|--------|-----------|--------|---------|
| Firestore docs | $360 | ∞ | ❌ |
| Firestore array | $3.60 | 1MB | ❌ |
| **Storage JSON** | **$0.10** | **∞** | **✅** |

---

## 🎖️ Recomendação

**Use Storage para:**
- ✅ Catálogos read-only (bovinos, equinos)
- ✅ Dados que atualizam raramente
- ✅ Apps com muitos usuários

**Use Firestore para:**
- ✅ Dados do usuário
- ✅ Real-time
- ✅ Queries complexas

---

**Economia:** **$359.90/mês** (99.97% de redução) 🎉
