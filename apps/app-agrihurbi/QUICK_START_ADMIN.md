# ⚡ Quick Start - Painel Administrativo AgriHurbi

## 🎯 Objetivo
Configurar e acessar o painel administrativo para gerenciar dados públicos de bovinos e equinos.

## ✅ Checklist de Configuração

### 1️⃣ Deploy das Regras do Firestore (OBRIGATÓRIO)

```bash
cd apps/app-agrihurbi

# Usando Firebase CLI
firebase deploy --only firestore:rules

# Ou via npx (se não tiver firebase-tools global)
npx firebase-tools deploy --only firestore:rules
```

### 2️⃣ Criar Usuário Administrador

**Via Firebase Console** (mais fácil):

1. Acesse o Firebase Console do projeto AgriHurbi
2. Vá em **Authentication** → **Users**
3. Clique em **"Add User"**
4. Digite:
   - **Email**: `agrimindsolucoes@gmail.com` (ou seu email)
   - **Senha**: escolha uma senha forte (mínimo 6 caracteres)
5. Clique em **"Add User"**

### 3️⃣ Verificar Email na Lista de Admins

Abra `firestore.rules` e confirme que seu email está na lista:

```javascript
function isAdmin() {
  return isAuthenticated() && request.auth.token.email in [
    'agrimindsolucoes@gmail.com',  // ✅ Seu email aqui
    'agrimind.br@gmail.com'
  ];
}
```

Se não estiver, adicione e faça deploy novamente (passo 1).

### 4️⃣ Testar Acesso

**Mobile/Desktop:**
1. Execute o app: `flutter run`
2. Navegue para a rota `/admin`
3. Faça login com o email e senha criados
4. Você deve ver o dashboard administrativo

**Web:**
1. Execute: `flutter run -d chrome`
2. Acesse: `http://localhost:PORTA/admin`
3. Faça login
4. Acesse o painel

## 🎨 Funcionalidades do Painel

### Dashboard Principal (`/admin/dashboard`)
- Estatísticas gerais
- Contadores de bovinos e equinos
- Ações rápidas
- Atividade recente

### Gerenciamento de Bovinos (`/admin/bovines`)
- Listar todos os bovinos públicos
- Adicionar novos bovinos
- Editar informações
- Remover registros
- Importação em lote (futuro)

### Gerenciamento de Equinos (`/admin/equines`)
- Listar todos os equinos públicos
- Adicionar novos equinos
- Editar informações
- Remover registros
- Importação em lote (futuro)

## 🚨 Problemas Comuns

### "Missing or insufficient permissions"
- ❌ Você não fez deploy das regras
- ✅ Solução: Execute `firebase deploy --only firestore:rules`

### "User not found" ou "Invalid credentials"
- ❌ Usuário não existe ou senha incorreta
- ✅ Solução: Verifique no Firebase Console → Authentication → Users

### "Permission denied" mesmo após login
- ❌ Seu email não está na lista de admins em `firestore.rules`
- ✅ Solução: Adicione em `firestore.rules` e faça deploy novamente

### Rota `/admin` não encontrada
- ❌ Rotas admin não configuradas corretamente
- ✅ Solução: Verifique se as rotas estão em `lib/core/router/app_router.dart`

## 📱 Comandos Úteis

```bash
# Ver projeto Firebase atual
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

# Executar app
flutter run

# Executar web
flutter run -d chrome
```

## 🔐 Segurança

### Emails Admin Hardcoded
Por simplicidade, usamos uma lista hardcoded de emails admin nas regras:

```javascript
function isAdmin() {
  return isAuthenticated() && request.auth.token.email in [
    'agrimindsolucoes@gmail.com',
    'agrimind.br@gmail.com'
  ];
}
```

### Sistema de Roles (Futuro - Mais Escalável)
Para adicionar mais admins no futuro sem deploy, crie documentos de usuário:

```javascript
// firestore.rules
function isAdmin() {
  return isAuthenticated() && 
         exists(/databases/$(database)/documents/users/$(request.auth.uid)) &&
         get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin';
}
```

E crie documentos em `users/{userId}`:
```json
{
  "email": "novo-admin@gmail.com",
  "role": "admin",
  "createdAt": "2026-01-16T...",
  "name": "Nome do Admin"
}
```

## 🎯 Próximos Passos

### Implementar Gestão de Bovinos
1. Criar página de listagem com filtros
2. Formulário de criação/edição
3. Integração com Firestore
4. Validações e feedbacks

### Implementar Gestão de Equinos
1. Mesma estrutura dos bovinos
2. Campos específicos para equinos
3. Integração com Firestore

### Importação em Lote
1. Upload de CSV/Excel
2. Parse e validação
3. Importação batch no Firestore
4. Relatório de erros

### Exportação de Dados
1. Gerar CSV dos dados
2. Download automático
3. Opções de filtro

## ⏱️ Tempo Estimado

- **Deploy das regras**: 30 segundos
- **Criar usuário admin**: 1 minuto
- **Testar acesso**: 30 segundos
- **Total**: ~2 minutos

## 📚 Arquitetura

```
lib/features/admin/
├── presentation/
│   ├── pages/
│   │   ├── admin_login_page.dart        # ✅ Login admin
│   │   └── admin_dashboard_page.dart    # ✅ Dashboard
│   └── widgets/
│       └── (widgets compartilhados)
```

## 🎨 Design

- **Tema**: Verde (#4CAF50) - AgriHurbi
- **Layout**: Responsivo (mobile + web)
- **Componentes**: Material Design 3
- **Dark Mode**: Suportado

---

**🚀 Pronto para começar!**

Qualquer dúvida, consulte a documentação do Firebase ou o código de referência no `app-calculei`.
