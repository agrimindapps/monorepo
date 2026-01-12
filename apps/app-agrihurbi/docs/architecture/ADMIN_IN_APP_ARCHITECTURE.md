# 🎯 Arquitetura: Admin no App + Storage JSON (Solução Híbrida)

## 💡 Conceito

**Você (admin) gerencia tudo dentro do próprio app:**
- ✏️ CRUD de bovinos/equinos no app
- 💾 Salva localmente no Drift (SQLite)
- 📤 Gera JSON e faz upload para Firebase Storage
- 🔄 Sincroniza quando quiser

**Usuários comuns:**
- 📥 Apenas baixam JSON do Storage
- 💾 Cache local noRift
- 👁️ Visualização read-only

---

## 🏗️ Arquitetura Proposta

```
┌─────────────────────────────────────────────────────────────┐
│ VOCÊ (Admin User)                                           │
│                                                             │
│  App Agrihurbi (modo admin habilitado)                    │
│  ├─ CRUD bovinos/equinos                                  │
│  │   └─ Salva no Drift (SQLite local)                    │
│  │                                                         │
│  └─ Botão "Publicar Catálogo"                            │
│      ├─ Lê todos bovinos do Drift                        │
│      ├─ Gera bovines_catalog.json                        │
│      ├─ Upload para Firebase Storage                      │
│      └─ Atualiza metadata.json                           │
│                                                             │
│  Custo: ZERO (só você usa)                                │
└─────────────────────────────────────────────────────────────┘
                           ↓
         ┌─────────────────────────────────┐
         │ Firebase Storage                │
         │ ├─ bovines_catalog.json        │
         │ ├─ equines_catalog.json        │
         │ └─ metadata.json               │
         └─────────────────────────────────┘
                           ↓
┌─────────────────────────────────────────────────────────────┐
│ USUÁRIOS (Regular Users)                                    │
│                                                             │
│  App Agrihurbi (modo read-only)                           │
│  ├─ Download bovines_catalog.json                         │
│  ├─ Salva no Drift (cache local)                         │
│  └─ Lista/busca/filtros (read-only)                      │
│                                                             │
│  Custo: $0.10/mês (1000 usuários)                         │
└─────────────────────────────────────────────────────────────┘
```

---

## ✅ Vantagens desta Abordagem

### 1. **Elimina Firebase Console**
✅ Tudo gerenciado no próprio app  
✅ Interface nativa e familiar  
✅ Validações já existentes (use cases)

### 2. **Elimina Cloud Functions**
✅ Zero código backend  
✅ Sem deploy de functions  
✅ Controle total no app

### 3. **Elimina Firestore**
✅ Zero custos de reads/writes  
✅ Dados locais (Drift) + Storage apenas  
✅ Offline-first para admin também

### 4. **Reutiliza Código Existente**
✅ CRUD já implementado (87 arquivos!)  
✅ Use cases com validações  
✅ Forms e widgets prontos

### 5. **Custo Mínimo**
✅ Admin: **ZERO** (só você, local)  
✅ Usuários: **$0.10/mês** (1000 users)  
✅ Storage: **$0.00002/mês** (800KB)

---

## 🔧 Implementação

### 1. Detecção de Modo Admin

```dart
// lib/core/auth/user_role.dart

enum UserRole {
  admin,
  regular,
}

class AuthService {
  // Verifica se usuário é admin (Firebase Auth custom claim)
  Future<UserRole> getUserRole() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return UserRole.regular;
    
    final idTokenResult = await user.getIdTokenResult();
    final isAdmin = idTokenResult.claims?['admin'] == true;
    
    return isAdmin ? UserRole.admin : UserRole.regular;
  }
}

// Provider
@riverpod
Future<UserRole> userRole(UserRoleRef ref) async {
  final authService = ref.watch(authServiceProvider);
  return await authService.getUserRole();
}
```

### 2. UI Condicional (Admin vs Regular)

```dart
// lib/features/livestock/presentation/pages/bovines_list_page.dart

class BovinesListPage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userRole = ref.watch(userRoleProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bovinos'),
        actions: [
          // Botão CREATE só para admin
          if (userRole.value == UserRole.admin)
            IconButton(
              icon: Icon(Icons.add),
              onPressed: () => context.push('/bovines/create'),
            ),
          
          // Botão PUBLICAR só para admin
          if (userRole.value == UserRole.admin)
            IconButton(
              icon: Icon(Icons.cloud_upload),
              onPressed: () => _publishCatalog(ref),
              tooltip: 'Publicar Catálogo',
            ),
        ],
      ),
      body: BovinesList(
        isReadOnly: userRole.value != UserRole.admin,
      ),
    );
  }
  
  Future<void> _publishCatalog(WidgetRef ref) async {
    final result = await ref.read(
      publishLivestockCatalogUseCaseProvider
    ).call();
    
    result.fold(
      (failure) => _showError(failure.message),
      (_) => _showSuccess('Catálogo publicado com sucesso!'),
    );
  }
}
```

### 3. Use Case: Publicar Catálogo

```dart
// lib/features/livestock/domain/usecases/publish_livestock_catalog.dart

import 'package:core/core.dart';
import '../entities/bovine_entity.dart';
import '../entities/equine_entity.dart';
import '../repositories/livestock_repository.dart';

class PublishLivestockCatalogUseCase implements UseCase<Unit, NoParams> {
  final LivestockRepository _repository;
  
  PublishLivestockCatalogUseCase(this._repository);
  
  @override
  Future<Either<Failure, Unit>> call(NoParams params) async {
    try {
      // 1. Busca todos os bovinos/equinos do Drift local
      final bovinesResult = await _repository.getBovines();
      final equinesResult = await _repository.getEquines();
      
      if (bovinesResult.isLeft() || equinesResult.isLeft()) {
        return Left(CacheFailure('Erro ao buscar dados locais'));
      }
      
      final bovines = bovinesResult.getOrElse(() => []);
      final equines = equinesResult.getOrElse(() => []);
      
      // 2. Gera JSONs
      final bovinesJson = _generateBovinesJson(bovines);
      final equinesJson = _generateEquinesJson(equines);
      final metadataJson = _generateMetadataJson(bovines, equines);
      
      // 3. Upload para Firebase Storage
      await _uploadToStorage('livestock/bovines_catalog.json', bovinesJson);
      await _uploadToStorage('livestock/equines_catalog.json', equinesJson);
      await _uploadToStorage('livestock/metadata.json', metadataJson);
      
      return const Right(unit);
      
    } catch (e) {
      return Left(ServerFailure('Erro ao publicar catálogo: $e'));
    }
  }
  
  String _generateBovinesJson(List<BovineEntity> bovines) {
    final catalog = {
      'bovines': bovines
          .where((b) => b.isActive) // Só os ativos
          .map((b) => _bovineToJson(b))
          .toList(),
      'generated_at': DateTime.now().toIso8601String(),
      'count': bovines.where((b) => b.isActive).length,
      'version': '1.0.0',
    };
    
    return jsonEncode(catalog);
  }
  
  String _generateEquinesJson(List<EquineEntity> equines) {
    final catalog = {
      'equines': equines
          .where((e) => e.isActive)
          .map((e) => _equineToJson(e))
          .toList(),
      'generated_at': DateTime.now().toIso8601String(),
      'count': equines.where((e) => e.isActive).length,
      'version': '1.0.0',
    };
    
    return jsonEncode(catalog);
  }
  
  String _generateMetadataJson(
    List<BovineEntity> bovines,
    List<EquineEntity> equines,
  ) {
    final metadata = {
      'last_updated': DateTime.now().toIso8601String(),
      'bovines_count': bovines.where((b) => b.isActive).length,
      'equines_count': equines.where((e) => e.isActive).length,
      'version': '1.0.0',
    };
    
    return jsonEncode(metadata);
  }
  
  Future<void> _uploadToStorage(String path, String jsonContent) async {
    final storage = FirebaseStorage.instance;
    final ref = storage.ref(path);
    
    await ref.putString(
      jsonContent,
      metadata: SettableMetadata(
        contentType: 'application/json',
        cacheControl: 'public, max-age=3600',
      ),
    );
  }
  
  Map<String, dynamic> _bovineToJson(BovineEntity bovine) {
    return {
      'id': bovine.id,
      'registration_id': bovine.registrationId,
      'common_name': bovine.commonName,
      'origin_country': bovine.originCountry,
      'image_urls': bovine.imageUrls,
      'thumbnail_url': bovine.thumbnailUrl,
      'animal_type': bovine.animalType,
      'origin': bovine.origin,
      'characteristics': bovine.characteristics,
      'breed': bovine.breed,
      'aptitude': bovine.aptitude.name,
      'tags': bovine.tags,
      'breeding_system': bovine.breedingSystem.name,
      'purpose': bovine.purpose,
      'notes': bovine.notes,
    };
  }
  
  Map<String, dynamic> _equineToJson(EquineEntity equine) {
    // Mesma estrutura para equinos
    return {
      'id': equine.id,
      'registration_id': equine.registrationId,
      'common_name': equine.commonName,
      // ... outros campos
    };
  }
}
```

### 4. Repository Adaptado (Dual Mode)

```dart
// lib/features/livestock/data/repositories/livestock_repository_impl.dart

class LivestockRepositoryImpl implements LivestockRepository {
  final LivestockLocalDataSource _localDataSource;
  final LivestockStorageDataSource _storageDataSource;
  final SharedPreferences _prefs;
  final AuthService _authService;
  
  static const _lastUpdateKey = 'livestock_last_update';
  
  @override
  Future<Either<Failure, List<BovineEntity>>> getBovines() async {
    try {
      final userRole = await _authService.getUserRole();
      
      if (userRole == UserRole.admin) {
        // ADMIN: Retorna direto do Drift local (seus dados)
        final bovines = await _localDataSource.getAllBovines();
        return Right(bovines.map((m) => m.toEntity()).toList());
        
      } else {
        // REGULAR USER: Sincroniza do Storage antes
        await _syncIfNeeded();
        
        final bovines = await _localDataSource.getAllBovines();
        return Right(bovines.map((m) => m.toEntity()).toList());
      }
      
    } catch (e) {
      return Left(CacheFailure('Erro: $e'));
    }
  }
  
  @override
  Future<Either<Failure, BovineEntity>> createBovine(BovineEntity bovine) async {
    try {
      // Verifica permissão
      final userRole = await _authService.getUserRole();
      if (userRole != UserRole.admin) {
        return Left(UnauthorizedFailure('Apenas admins podem criar bovinos'));
      }
      
      // Salva localmente (Drift)
      final model = BovineModel.fromEntity(bovine);
      await _localDataSource.saveBovine(model);
      
      // NÃO faz upload aqui, espera "Publicar Catálogo"
      
      return Right(bovine);
      
    } catch (e) {
      return Left(CacheFailure('Erro ao criar: $e'));
    }
  }
  
  @override
  Future<Either<Failure, BovineEntity>> updateBovine(BovineEntity bovine) async {
    try {
      final userRole = await _authService.getUserRole();
      if (userRole != UserRole.admin) {
        return Left(UnauthorizedFailure('Apenas admins podem atualizar'));
      }
      
      final model = BovineModel.fromEntity(bovine);
      await _localDataSource.saveBovine(model);
      
      return Right(bovine);
      
    } catch (e) {
      return Left(CacheFailure('Erro ao atualizar: $e'));
    }
  }
  
  Future<void> _syncIfNeeded() async {
    // Código de sync do Storage (usuários regulares)
    // ... mesmo código da estratégia anterior
  }
}
```

### 5. Notifier para Publicação

```dart
// lib/features/livestock/presentation/notifiers/catalog_publisher_notifier.dart

import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'catalog_publisher_notifier.g.dart';

@riverpod
class CatalogPublisherNotifier extends _$CatalogPublisherNotifier {
  @override
  CatalogPublisherState build() {
    return const CatalogPublisherState();
  }
  
  Future<void> publishCatalog() async {
    state = state.copyWith(isPublishing: true, errorMessage: null);
    
    final useCase = ref.read(publishLivestockCatalogUseCaseProvider);
    final result = await useCase(NoParams());
    
    result.fold(
      (failure) {
        state = state.copyWith(
          isPublishing: false,
          errorMessage: failure.message,
        );
      },
      (_) {
        state = state.copyWith(
          isPublishing: false,
          lastPublished: DateTime.now(),
        );
      },
    );
  }
}

@freezed
class CatalogPublisherState with _$CatalogPublisherState {
  const factory CatalogPublisherState({
    @Default(false) bool isPublishing,
    DateTime? lastPublished,
    String? errorMessage,
  }) = _CatalogPublisherState;
}
```

### 6. Widget de Publicação

```dart
// lib/features/livestock/presentation/widgets/publish_catalog_button.dart

class PublishCatalogButton extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(catalogPublisherNotifierProvider);
    final notifier = ref.read(catalogPublisherNotifierProvider.notifier);
    
    return Column(
      children: [
        ElevatedButton.icon(
          onPressed: state.isPublishing 
              ? null 
              : () => _showConfirmDialog(context, notifier),
          icon: state.isPublishing
              ? SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Icon(Icons.cloud_upload),
          label: Text(
            state.isPublishing 
                ? 'Publicando...' 
                : 'Publicar Catálogo'
          ),
        ),
        
        if (state.lastPublished != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              'Última publicação: ${_formatDate(state.lastPublished!)}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        
        if (state.errorMessage != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              state.errorMessage!,
              style: TextStyle(color: Colors.red),
            ),
          ),
      ],
    );
  }
  
  Future<void> _showConfirmDialog(
    BuildContext context,
    CatalogPublisherNotifier notifier,
  ) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Publicar Catálogo'),
        content: Text(
          'Isso irá atualizar o catálogo para todos os usuários. '
          'Deseja continuar?'
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Publicar'),
          ),
        ],
      ),
    );
    
    if (confirm == true) {
      await notifier.publishCatalog();
    }
  }
  
  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute}';
  }
}
```

---

## 🔐 Configuração de Admin

### 1. Marcar seu usuário como admin

```bash
# Firebase CLI
firebase auth:users:set-custom-claims SEU_USER_ID --claims '{"admin":true}'
```

### 2. Ou via Cloud Function (primeira vez)

```javascript
// functions/index.js
exports.makeAdmin = functions.https.onRequest(async (req, res) => {
  const email = req.query.email; // seu-email@gmail.com
  
  const user = await admin.auth().getUserByEmail(email);
  await admin.auth().setCustomUserClaims(user.uid, { admin: true });
  
  res.send(`${email} agora é admin!`);
});
```

Acesse: `https://your-project.cloudfunctions.net/makeAdmin?email=seu@email.com`

---

## 🔒 Firebase Storage Rules

```javascript
// storage.rules
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /livestock/{file} {
      // Leitura: todos (usuários autenticados)
      allow read: if request.auth != null;
      
      // Escrita: apenas admins
      allow write: if request.auth != null 
                   && request.auth.token.admin == true;
    }
  }
}
```

---

## 📊 Fluxo Completo

### Admin (Você)

1. **Login** → Firebase Auth identifica como admin
2. **CRUD** → Cria/edita bovinos no app
3. **Salva** → Drift local (SQLite)
4. **Botão "Publicar"** → Gera JSON + Upload Storage
5. **Confirmação** → "Catálogo publicado!"

### Usuários Regulares

1. **Login** → Firebase Auth identifica como regular
2. **App abre** → Verifica metadata.json
3. **Se houver update** → Baixa bovines_catalog.json
4. **Salva** → Drift local (cache)
5. **Navegação** → Lista/busca (read-only)

---

## ✅ Benefícios

| Aspecto | Benefício |
|---------|-----------|
| **Custo** | $0.10/mês (vs $360 Firestore) |
| **Código** | Reutiliza 100% do CRUD existente |
| **Backend** | Zero (sem Cloud Functions/Firestore) |
| **Interface** | Nativa do app (não precisa Console) |
| **Offline** | Admin e usuários trabalham offline |
| **Controle** | Você decide quando publicar |
| **Validação** | Use cases já testados |

---

## 🚀 Próximos Passos

1. ✅ Implementar `PublishLivestockCatalogUseCase`
2. ✅ Criar `CatalogPublisherNotifier`
3. ✅ Adicionar botão "Publicar" nas páginas admin
4. ✅ Configurar custom claim de admin
5. ✅ Adaptar `LivestockRepositoryImpl` (dual mode)
6. ✅ Testar fluxo completo

---

**Esta é a solução IDEAL:**
- ✅ Máximo aproveitamento do código existente
- ✅ Custo mínimo ($0.10/mês)
- ✅ Zero backend/Cloud Functions
- ✅ Controle total no app
- ✅ Simples de manter

**Quer que eu implemente isso agora?** 🚀
