# 🔥 Migração Supabase → Firebase (Admin + Usuários)

## 🎯 Objetivo

Substituir Supabase por Firebase mantendo:
- ✅ CRUD admin de bovinos/equinos (você)
- ✅ Leitura read-only (usuários)
- ✅ Custo mínimo

---

## 📊 Opções de Arquitetura

### **Opção 1: Firestore Console + Storage JSON** ⭐ RECOMENDADO

**Para você (admin):**
- CRUD via **Firebase Console** (interface web)
- Sem necessidade de código backend

**Para usuários:**
- Leitura via **Storage JSON** (custo $0.10/mês)

**Arquitetura:**

```
┌─────────────────────────────────────────────────────────────┐
│ ADMIN (Você)                                                │
│                                                             │
│  Firebase Console (Web)                                    │
│  └─ Firestore Database                                     │
│      └─ Collection: bovines                                │
│          ├─ doc1 (Nelore)                                  │
│          ├─ doc2 (Angus)                                   │
│          └─ doc3 (Girolando)                               │
│                                                             │
│  ✏️ Create, Update, Delete direto na interface             │
└─────────────────────────────────────────────────────────────┘
                           ↓
         ┌─────────────────────────────────┐
         │ Cloud Function (Trigger)        │
         │ onWrite → Gera JSON             │
         │ Upload → Storage                │
         └─────────────────────────────────┘
                           ↓
┌─────────────────────────────────────────────────────────────┐
│ USUÁRIOS (App)                                              │
│                                                             │
│  1. App inicia                                             │
│  2. Verifica metadata.json                                 │
│  3. Se houver atualização, baixa bovines_catalog.json     │
│  4. Salva no Drift (SQLite local)                         │
│  5. Usa offline-first                                      │
│                                                             │
│  Custo: $0.10/mês (1000 usuários)                         │
└─────────────────────────────────────────────────────────────┘
```

#### Cloud Function (auto-sync)

```javascript
// functions/index.js

const functions = require('firebase-functions');
const admin = require('firebase-admin');

admin.initializeApp();

// Trigger quando qualquer bovino é criado/atualizado/deletado
exports.syncBovinesToStorage = functions.firestore
  .document('bovines/{bovineId}')
  .onWrite(async (change, context) => {
    console.log('Bovine changed, regenerating catalog...');
    
    // 1. Busca TODOS os bovinos ativos
    const snapshot = await admin.firestore()
      .collection('bovines')
      .where('isActive', '==', true)
      .get();
    
    const bovines = [];
    snapshot.forEach(doc => {
      bovines.push({ id: doc.id, ...doc.data() });
    });
    
    // 2. Gera JSON
    const catalogJson = {
      bovines: bovines,
      generated_at: new Date().toISOString(),
      count: bovines.length,
    };
    
    // 3. Upload para Storage
    const bucket = admin.storage().bucket();
    const file = bucket.file('livestock/bovines_catalog.json');
    
    await file.save(JSON.stringify(catalogJson), {
      contentType: 'application/json',
      metadata: {
        cacheControl: 'public, max-age=3600',
      },
    });
    
    // 4. Atualiza metadata
    const metadataFile = bucket.file('livestock/metadata.json');
    await metadataFile.save(JSON.stringify({
      last_updated: new Date().toISOString(),
      bovines_count: bovines.length,
      version: '1.0.0',
    }));
    
    console.log(`✅ Catalog updated: ${bovines.length} bovines`);
    return null;
  });

// Mesma função para equinos
exports.syncEquinesToStorage = functions.firestore
  .document('equines/{equineId}')
  .onWrite(async (change, context) => {
    // ... mesmo código para equinos
  });
```

#### Firestore Rules

```javascript
// firestore.rules
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    
    // Bovinos: admin full access, users read-only
    match /bovines/{bovineId} {
      allow read: if request.auth != null;
      allow write: if request.auth.token.admin == true;
    }
    
    // Equinos: mesma regra
    match /equines/{equineId} {
      allow read: if request.auth != null;
      allow write: if request.auth.token.admin == true;
    }
  }
}
```

#### Como definir admin

```bash
# Firebase CLI - Marcar seu usuário como admin
firebase auth:users:set-custom-claims SEU_USER_ID --claims '{"admin":true}'
```

#### Custos

| Operação | Quantidade | Custo |
|----------|-----------|-------|
| Firestore writes (você) | 10/dia | **Grátis** (50k/dia free) |
| Cloud Functions executions | 10/dia | **Grátis** (2M/mês free) |
| Storage (800KB) | 1 arquivo | **$0.00002/mês** |
| Download (1000 users) | 800MB total | **$0.096/mês** |
| **TOTAL** | | **$0.10/mês** 🎉 |

---

### **Opção 2: Firebase Admin SDK em App Separado**

**Criar um app Flutter/Web separado só para admin:**

```
monorepo/
├── apps/
│   ├── app-agrihurbi/          # App usuários (read-only)
│   └── app-agrihurbi-admin/    # App admin (CRUD) ← NOVO
```

**Vantagens:**
✅ Interface customizada para você  
✅ Validações complexas no app  
✅ Offline editing (Drift)  
✅ Mesma arquitetura Clean  

**Implementação:**

```dart
// app-agrihurbi-admin/lib/main.dart

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  
  runApp(const AdminApp());
}

class AdminApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Agrihurbi Admin',
      home: BovinesAdminPage(),
    );
  }
}
```

**Admin Repository (usa Firestore direto):**

```dart
class LivestockAdminRepository {
  final FirebaseFirestore _firestore;
  
  Future<void> createBovine(BovineEntity bovine) async {
    await _firestore.collection('bovines').doc(bovine.id).set({
      ...bovine.toJson(),
      'created_at': FieldValue.serverTimestamp(),
    });
    
    // Trigger Cloud Function automaticamente
  }
  
  Future<void> updateBovine(BovineEntity bovine) async {
    await _firestore.collection('bovines').doc(bovine.id).update({
      ...bovine.toJson(),
      'updated_at': FieldValue.serverTimestamp(),
    });
  }
  
  Future<void> deleteBovine(String id) async {
    // Soft delete
    await _firestore.collection('bovines').doc(id).update({
      'isActive': false,
    });
  }
}
```

---

### **Opção 3: Firestore + Realtime Database (Híbrido)**

**Firestore para admin (CRUD):**
- Você edita via Console ou app admin
- Queries complexas, validação

**Realtime Database para usuários:**
- Export automático (Cloud Function)
- 1 read = todos os dados
- Custo: $1/GB download (vs $0.12/GB no Storage)

**Não recomendado** (Storage é mais barato)

---

## 🎯 Comparação de Opções

| Opção | Interface Admin | Custo | Complexidade | Offline |
|-------|-----------------|-------|--------------|---------|
| **1. Console + Storage** ⭐ | Firebase Console | $0.10/mês | Baixa | ✅ |
| **2. App Admin + Storage** | Flutter app custom | $0.10/mês | Média | ✅ |
| **3. Realtime Database** | Console | $8/mês | Baixa | ❌ |

---

## 🏆 Recomendação

**Use Opção 1: Firebase Console + Storage**

**Por quê?**
✅ **Menos código** (Cloud Function auto-sync)  
✅ **Interface pronta** (Firebase Console é ótimo)  
✅ **Custo mínimo** ($0.10/mês)  
✅ **Simples** de manter  
✅ **Offline-first** para usuários  

**Quando usar Opção 2 (App Admin)?**
- ⚠️ Se precisar interface super customizada
- ⚠️ Se tiver validações complexas de negócio
- ⚠️ Se precisar editar offline

---

## 📋 Migração Supabase → Firebase (Checklist)

### Fase 1: Setup Firebase
- [ ] Criar projeto no Firebase Console
- [ ] Habilitar Firestore
- [ ] Habilitar Storage
- [ ] Habilitar Cloud Functions
- [ ] Configurar Authentication (se necessário)

### Fase 2: Migrar Dados
- [ ] Exportar bovinos do Supabase (JSON)
- [ ] Importar para Firestore via script
- [ ] Validar dados migrados

### Fase 3: Implementar Sync
- [ ] Criar Cloud Function `syncBovinesToStorage`
- [ ] Configurar trigger `onWrite`
- [ ] Testar geração de JSON
- [ ] Validar upload no Storage

### Fase 4: Adaptar App
- [ ] Criar `LivestockStorageDataSource`
- [ ] Adaptar `LivestockRepositoryImpl`
- [ ] Remover dependências do Supabase
- [ ] Testar download e cache

### Fase 5: Deploy
- [ ] Deploy Cloud Functions
- [ ] Configurar Firestore Rules
- [ ] Configurar Storage Rules
- [ ] Testar em produção

---

## 🛠️ Script de Migração

```dart
// scripts/migrate_supabase_to_firebase.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'supabase_client.dart'; // Seu cliente atual

void main() async {
  // 1. Busca todos do Supabase
  final supabaseBovines = await fetchAllBovinesFromSupabase();
  
  // 2. Firebase
  final firestore = FirebaseFirestore.instance;
  
  // 3. Migra cada um
  for (final bovine in supabaseBovines) {
    await firestore.collection('bovines').doc(bovine.id).set({
      ...bovine.toJson(),
      'migrated_at': FieldValue.serverTimestamp(),
    });
    print('Migrated: ${bovine.commonName}');
  }
  
  print('✅ Migration complete: ${supabaseBovines.length} bovines');
}
```

---

## 💰 Custo Final (1000 usuários)

| Item | Custo/mês |
|------|-----------|
| Firestore writes (admin) | **Grátis** (tier free) |
| Cloud Functions | **Grátis** (tier free) |
| Storage (800KB) | **$0.00002** |
| Download (800MB) | **$0.096** |
| **TOTAL** | **$0.10/mês** 🎉 |

**vs Supabase:** Economia de ~$XX/mês (depende do plano)

---

## 📚 Recursos

- [Firestore Triggers](https://firebase.google.com/docs/functions/firestore-events)
- [Storage API](https://firebase.google.com/docs/storage)
- [Custom Claims](https://firebase.google.com/docs/auth/admin/custom-claims)
- [Firebase Console](https://console.firebase.google.com)

---

**Quer que eu implemente a Opção 1 (Cloud Function + Storage)?**
