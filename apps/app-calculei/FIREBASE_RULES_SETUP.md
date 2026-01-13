# 🔐 Configuração de Regras Firebase - Calculei

## 📋 Resumo

Este documento descreve como configurar e fazer deploy das regras de segurança do Firestore para permitir acesso ao painel administrativo.

## 🎯 Problema Resolvido

Você estava tentando acessar o painel `/admin` mas não conseguia ler os dados do Firestore porque as regras de segurança não estavam configuradas.

## ✅ Arquivos Criados

1. **`firestore.rules`** - Regras de segurança do Firestore
2. **`firestore.indexes.json`** - Índices para queries compostas
3. **`firebase.json`** - Atualizado para incluir configuração do Firestore

## 🔑 Configuração de Administradores

### Adicionar Emails de Admin

Edite o arquivo `firestore.rules` e adicione os emails dos administradores autorizados:

```javascript
function isAdmin() {
  return isAuthenticated() && request.auth.token.email in [
    'agrimindsolucoes@gmail.com',
    'seu-email@exemplo.com',  // Adicione aqui
    // Adicione outros emails de admin aqui
  ];
}
```

## 🚀 Deploy das Regras

### Opção 1: Via Firebase CLI (Recomendado)

```bash
# 1. Certifique-se que o Firebase CLI está instalado
npm install -g firebase-tools

# 2. Faça login no Firebase
firebase login

# 3. Entre na pasta do app
cd apps/app-calculei

# 4. Deploy apenas das regras do Firestore
firebase deploy --only firestore:rules

# 5. Deploy dos índices (opcional, mas recomendado)
firebase deploy --only firestore:indexes
```

### Opção 2: Via Console Firebase (Manual)

1. Acesse [Firebase Console](https://console.firebase.google.com/)
2. Selecione o projeto **calculei-52e71**
3. Vá em **Firestore Database** → **Regras**
4. Copie o conteúdo do arquivo `firestore.rules`
5. Cole na interface web
6. Clique em **Publicar**

## 📊 Estrutura de Permissões

### Collection: `feedback`
- ✅ **CREATE**: Qualquer usuário (permite envio de feedback sem login)
- 🔒 **READ/UPDATE/DELETE**: Apenas administradores autenticados

### Collection: `error_logs`
- ✅ **CREATE**: Qualquer usuário (permite logging de erros)
- 🔒 **READ/DELETE**: Apenas administradores autenticados

### Collection: `users`
- 🔒 **READ/WRITE**: Usuário pode acessar apenas seus próprios dados
- 🔒 **READ (all)**: Administradores podem ler todos os usuários

### Outras collections
- 🚫 **Bloqueadas por padrão** (negar tudo)

## 🔐 Como Criar Conta de Admin

### Via Firebase Console

1. Acesse [Firebase Console](https://console.firebase.google.com/)
2. Selecione o projeto **calculei-52e71**
3. Vá em **Authentication** → **Users**
4. Clique em **Add User**
5. Digite o email e senha
6. Clique em **Add User**

### Via Firebase CLI

```bash
# Instalar Firebase Admin Tools
npm install -g firebase-admin

# Ou criar via código (veja create_admin_user.js)
node scripts/create_admin_user.js
```

## 🧪 Testar o Acesso

### 1. Deploy as regras (se ainda não fez)

```bash
cd apps/app-calculei
firebase deploy --only firestore:rules
```

### 2. Acesse o painel de admin

- **Web**: `https://calculei-52e71.web.app/admin`
- **Local**: `http://localhost:5000/admin` (se rodando localmente)

### 3. Faça login

- Email: agrimindsolucoes@gmail.com (ou o email configurado)
- Senha: a senha que você configurou no Firebase Authentication

### 4. Verifique o acesso

Se tudo estiver correto, você deve ver:
- ✅ Lista de feedbacks
- ✅ Contadores de status
- ✅ Filtros funcionando
- ✅ Logs de erro (se houver)

## ⚠️ Troubleshooting

### Erro: "Missing or insufficient permissions"

**Causa**: Regras não foram aplicadas ou email não está na lista de admins

**Solução**:
1. Verifique se fez deploy: `firebase deploy --only firestore:rules`
2. Confirme que seu email está em `firestore.rules` na função `isAdmin()`
3. Faça logout e login novamente no painel

### Erro: "User not found" ao fazer login

**Causa**: Usuário não existe no Firebase Authentication

**Solução**:
1. Acesse Firebase Console → Authentication
2. Crie o usuário manualmente
3. Ou use o script de criação de usuário

### Erro: "Index required" ao filtrar feedbacks

**Causa**: Índices compostos não foram criados

**Solução**:
```bash
firebase deploy --only firestore:indexes
```

Ou clique no link do erro que o Firestore mostra e crie o índice automaticamente.

## 📝 Regras de Segurança Explicadas

```javascript
// Qualquer pessoa pode criar feedback (enviar sugestões/bugs)
match /feedback/{feedbackId} {
  allow create: if true;  // ✅ Público
  allow read, update, delete: if isAdmin();  // 🔒 Admin only
}

// Verifica se o usuário é admin (baseado no email)
function isAdmin() {
  return isAuthenticated() && 
         request.auth.token.email in ['agrimindsolucoes@gmail.com'];
}
```

## 🔄 Próximos Passos

1. ✅ Deploy das regras: `firebase deploy --only firestore:rules`
2. ✅ Criar usuário admin no Firebase Authentication
3. ✅ Adicionar email do admin em `firestore.rules`
4. ✅ Testar acesso ao painel `/admin`
5. ✅ (Opcional) Deploy dos índices: `firebase deploy --only firestore:indexes`

## 📚 Referências

- [Firestore Security Rules](https://firebase.google.com/docs/firestore/security/get-started)
- [Firebase Authentication](https://firebase.google.com/docs/auth)
- [Firestore Indexes](https://firebase.google.com/docs/firestore/query-data/indexing)

---

**Projeto**: Calculei (calculei-52e71)  
**Data**: 2026-01-12  
**Status**: ✅ Configurado e pronto para deploy
