# 🔐 Sistema de Segurança Admin - AgriHurbi

## Arquitetura de Segurança em 3 Camadas

O sistema admin do AgriHurbi implementa **defesa em profundidade** com 3 camadas de validação:

```
┌─────────────────────────────────────────────────────────────┐
│ CAMADA 1: Router (app_router.dart)                         │
│ ✅ Valida autenticação básica                               │
│ ✅ Redireciona não-autenticados para /admin login          │
└─────────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────┐
│ CAMADA 2: AdminGuard Widget                                │
│ ✅ Valida role do usuário (admin vs regular)               │
│ ✅ Checa Firestore claims + hardcoded emails               │
│ ✅ Redireciona não-admins para /home                       │
└─────────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────┐
│ CAMADA 3: Firestore Rules                                  │
│ ✅ Validação backend (última linha de defesa)              │
│ ✅ Impede escrita mesmo se UI for contornada               │
│ ✅ Dupla validação: role field + email whitelist           │
└─────────────────────────────────────────────────────────────┘
```

---

## 🔑 Métodos de Autenticação Admin

### Método 1: Role Field no Firestore (Recomendado)

**Como funciona:**
```javascript
// Firestore: /users/{userId}
{
  email: "admin@example.com",
  role: "admin",  // ← Campo que define admin
  createdAt: Timestamp,
  ...
}
```

**Vantagens:**
- ✅ Gerenciamento dinâmico de admins
- ✅ Adicionar/remover sem redeploy
- ✅ Escalável para múltiplos níveis de permissão

**Como criar admin:**
```javascript
// Via Firebase Console ou Cloud Function
await admin.firestore().collection('users').doc(userId).set({
  email: userEmail,
  role: 'admin',
  createdAt: admin.firestore.FieldValue.serverTimestamp(),
});
```

---

### Método 2: Email Hardcoded (Fallback)

**Como funciona:**
```javascript
// firestore.rules
function isAdmin() {
  return isAuthenticated() && request.auth.token.email in [
    'agrimindsolucoes@gmail.com',
    'agrimind.br@gmail.com'
  ];
}
```

**Vantagens:**
- ✅ Funciona sem documento Firestore
- ✅ Simples e direto
- ✅ Backup caso role field falhe

**Desvantagens:**
- ❌ Requer redeploy para adicionar/remover
- ❌ Menos flexível

---

## 🛠️ Validação Híbrida (ATUAL)

O sistema usa **AMBOS** os métodos (OR lógico):

```javascript
function isAdmin() {
  return (
    // Método 1: Role field no Firestore
    (isAuthenticated() && 
     exists(/databases/$(database)/documents/users/$(request.auth.uid)) &&
     get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin')
    ||
    // Método 2: Email hardcoded (fallback)
    (isAuthenticated() && request.auth.token.email in [
      'agrimindsolucoes@gmail.com',
      'agrimind.br@gmail.com'
    ])
  );
}
```

**Por que híbrido?**
- ✅ **Segurança:** Dupla verificação
- ✅ **Confiabilidade:** Fallback se Firestore falhar
- ✅ **Flexibilidade:** Adicionar admins dinamicamente
- ✅ **Simplicidade:** Admins principais sempre funcionam

---

## 📋 Como Tornar Usuário Admin

### Opção A: Via Firebase Console (Recomendado)

1. Acesse Firebase Console → Firestore Database
2. Navegue para coleção `users`
3. Encontre/crie documento do usuário (uid como ID)
4. Adicione campo:
   ```
   role: "admin"
   ```
5. Salve

### Opção B: Via Cloud Function

```javascript
// functions/src/index.js
exports.makeAdmin = functions.https.onCall(async (data, context) => {
  // Verificar se quem chama é admin
  if (!context.auth || !await isUserAdmin(context.auth.uid)) {
    throw new functions.https.HttpsError('permission-denied', 'Somente admins podem promover usuários');
  }

  const { userId } = data;
  
  await admin.firestore().collection('users').doc(userId).update({
    role: 'admin'
  });

  return { success: true };
});
```

### Opção C: Hardcoded (Temporário)

1. Edite `firestore.rules`
2. Adicione email na lista:
   ```javascript
   'novo-admin@example.com'
   ```
3. Deploy: `firebase deploy --only firestore:rules`

---

## 🔒 Regras Firestore Completas

```javascript
rules_version = '2';

service cloud.firestore {
  match /databases/{database}/documents {
    
    // Helper: Check authentication
    function isAuthenticated() {
      return request.auth != null;
    }
    
    // Helper: Check admin (hybrid validation)
    function isAdmin() {
      return (
        // Role-based (scalable)
        (isAuthenticated() && 
         exists(/databases/$(database)/documents/users/$(request.auth.uid)) &&
         get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin')
        ||
        // Hardcoded emails (fallback)
        (isAuthenticated() && request.auth.token.email in [
          'agrimindsolucoes@gmail.com',
          'agrimind.br@gmail.com'
        ])
      );
    }
    
    // Bovinos - Leitura pública, escrita admin
    match /bovinos/{bovineId} {
      allow read: if true;
      allow create, update, delete: if isAdmin();
    }
    
    // Equinos - Leitura pública, escrita admin
    match /equinos/{equineId} {
      allow read: if true;
      allow create, update, delete: if isAdmin();
    }
    
    // Users - Gerenciamento de roles
    match /users/{userId} {
      allow read: if isAuthenticated();
      allow create: if isAuthenticated() && isOwner(userId);
      allow update, delete: if isOwner(userId) || isAdmin();
    }
  }
}
```

---

## 🧪 Como Testar

### 1. Teste de Admin Válido

```bash
# 1. Criar usuário no Firebase Console
# Email: agrimindsolucoes@gmail.com
# Senha: sua_senha_segura

# 2. (Opcional) Adicionar role no Firestore
# users/{uid}: { role: "admin" }

# 3. Testar no app
flutter run
# Navegar para /admin
# Login com credenciais
# Deve acessar dashboard
```

### 2. Teste de Usuário Regular

```bash
# 1. Criar usuário regular (sem role admin)
# 2. Tentar acessar /admin/dashboard
# Resultado esperado: Redirecionado para /home com mensagem de erro
```

### 3. Teste de Não-Autenticado

```bash
# 1. Fazer logout
# 2. Navegar para /admin/dashboard
# Resultado esperado: Redirecionado para /admin (login)
```

---

## 🚨 Troubleshooting

### "Acesso negado" mesmo sendo admin

**Causas possíveis:**
1. Email não está na lista hardcoded
2. Documento `users/{uid}` não tem `role: "admin"`
3. Token do Firebase Auth desatualizado

**Solução:**
```dart
// Forçar refresh do token
final user = FirebaseAuth.instance.currentUser;
await user?.getIdTokenResult(true); // true = force refresh
```

### Firestore Rules não aplicam

**Causa:** Rules não deployadas

**Solução:**
```bash
cd apps/app-agrihurbi
firebase deploy --only firestore:rules
```

### AdminGuard não redireciona

**Causa:** Provider não está carregando role

**Debug:**
```dart
// Adicione log no UserRoleService
debugPrint('Role: $role');
debugPrint('Is Admin: ${role.isAdmin}');
```

---

## 📊 Fluxo de Autenticação Admin

```
┌──────────────┐
│ Usuário tenta│
│ acessar      │
│ /admin/*     │
└──────┬───────┘
       │
       ▼
┌──────────────────────────┐
│ Router valida            │
│ autenticação básica      │
└──────┬───────────────────┘
       │ ✅ Autenticado
       ▼
┌──────────────────────────┐
│ AdminGuard Widget        │
│ consulta role via        │
│ UserRoleService          │
└──────┬───────────────────┘
       │
       ├─► ✅ role == 'admin'     → Exibe página
       │
       ├─► ✅ email hardcoded     → Exibe página
       │
       └─► ❌ Nenhum dos dois    → Redireciona /home
```

---

## 🎯 Best Practices

1. **Sempre use AdminGuard** nas páginas admin
2. **Nunca confie apenas no router** - use múltiplas camadas
3. **Firestore Rules são obrigatórias** - última linha de defesa
4. **Logs são seus amigos** - adicione debug nos guards
5. **Teste ambos os métodos** - role field e hardcoded
6. **Force token refresh** se role mudar em runtime

---

## 📚 Referências

- `lib/core/auth/user_role_service.dart` - Serviço de validação
- `lib/core/providers/user_role_providers.dart` - Providers Riverpod
- `lib/features/admin/presentation/widgets/admin_guard.dart` - Widget protetor
- `firestore.rules` - Regras backend
- `lib/core/router/app_router.dart` - Configuração de rotas

---

**Última atualização:** 2026-01-16  
**Versão:** 1.0  
**Status:** ✅ Produção
