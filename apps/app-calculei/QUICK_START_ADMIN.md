# ⚡ Quick Start - Habilitar Painel Admin

## 🎯 Objetivo
Configurar regras do Firestore para permitir acesso ao painel administrativo do Calculei.

## ✅ Checklist Rápido

### 1️⃣ Deploy das Regras (OBRIGATÓRIO)

```bash
cd apps/app-calculei

# Usando Firebase CLI
firebase deploy --only firestore:rules

# Ou via npx (se não tiver firebase-tools global)
npx firebase-tools deploy --only firestore:rules
```

### 2️⃣ Criar Usuário Admin

**Via Firebase Console** (mais fácil):

1. Acesse: https://console.firebase.google.com/u/0/project/calculei-52e71/authentication/users
2. Clique em "Add User"
3. Digite:
   - Email: `agrimindsolucoes@gmail.com` (ou seu email)
   - Senha: escolha uma senha forte
4. Clique em "Add User"

### 3️⃣ Verificar Email na Lista de Admins

Abra `firestore.rules` e confirme que seu email está na lista:

```javascript
function isAdmin() {
  return isAuthenticated() && request.auth.token.email in [
    'agrimindsolucoes@gmail.com',  // ✅ Seu email aqui
  ];
}
```

Se não estiver, adicione e faça deploy novamente (passo 1).

### 4️⃣ Testar Acesso

1. Acesse: https://calculei-52e71.web.app/admin
2. Faça login com o email e senha criados
3. Você deve ver o painel com a lista de feedbacks

## 🚨 Problemas Comuns

### "Missing or insufficient permissions"
- ❌ Você não fez deploy das regras
- ✅ Solução: Execute `firebase deploy --only firestore:rules`

### "User not found" ou "Invalid credentials"
- ❌ Usuário não existe ou senha incorreta
- ✅ Solução: Verifique no Firebase Console → Authentication → Users

### "Permission denied" mesmo após login
- ❌ Seu email não está na lista de admins
- ✅ Solução: Adicione em `firestore.rules` e faça deploy novamente

## 📱 Comandos Úteis

```bash
# Ver projeto atual
firebase use

# Listar todos os projetos
firebase projects:list

# Fazer login no Firebase
firebase login

# Deploy completo (regras + índices + hosting)
firebase deploy

# Apenas regras
firebase deploy --only firestore:rules

# Apenas índices
firebase deploy --only firestore:indexes
```

## 🎓 Entendendo as Regras

```javascript
// ✅ PÚBLICO - Qualquer um pode criar (enviar feedback)
allow create: if true;

// 🔒 ADMIN ONLY - Apenas admins podem ler/editar/deletar
allow read, update, delete: if isAdmin();

// 🔐 Verifica se é admin (baseado no email)
function isAdmin() {
  return isAuthenticated() && 
         request.auth.token.email in ['seu-email@gmail.com'];
}
```

## ⏱️ Tempo Estimado
- Deploy das regras: **30 segundos**
- Criar usuário admin: **1 minuto**
- Testar acesso: **30 segundos**
- **Total: ~2 minutos**

---

**Precisa de ajuda detalhada?** Veja `FIREBASE_RULES_SETUP.md`
