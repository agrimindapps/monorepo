# 🔐 Painel Administrativo - CantinhoVerde

## 📋 Visão Geral

O painel administrativo permite gerenciar feedbacks e erros enviados pelos usuários do aplicativo CantinhoVerde (Plantis).

---

## 🌐 Acesso

- **URL Web**: https://plantis.web.app/admin (após deploy)
- **URL Local**: http://localhost:5000/admin (durante desenvolvimento)
- **Rotas**:
  - `/admin` - Login administrativo
  - `/admin/dashboard` - Feedbacks dos usuários
  - `/admin/errors` - Logs de erros

---

## 🔑 Autenticação

### Configurar Primeiro Acesso

1. **Criar usuário admin no Firebase**:
   - Acesse: [Firebase Console - Authentication](https://console.firebase.google.com/)
   - Navegue para Authentication → Users
   - Clique em "Add User"
   - Digite email e senha
   - Salve as credenciais em local seguro

2. **Emails autorizados** (já configurado em `firestore.rules`):
   ```
   - agrimindsolucoes@gmail.com
   - agrimind.br@gmail.com
   ```

3. **Fazer login**:
   - Acesse `/admin`
   - Digite email e senha
   - Você será redirecionado para `/admin/dashboard`

---

## 📊 Funcionalidades

### 1. Dashboard de Feedbacks (`/admin/dashboard`)

**Visualização**:
- 📈 Cards de estatísticas por status (Pendente, Revisado, Resolvido, Arquivado)
- 🔍 Filtros por status e tipo
- 📝 Lista em tempo real de feedbacks
- ✏️ Atualização de status
- 💬 Visualização de detalhes

**Tipos de Feedback**:
- 🐛 **Bug**: Relato de erro
- 💡 **Suggestion**: Sugestão de melhoria
- 💬 **Comment**: Comentário geral
- 📝 **Other**: Outros

**Status de Feedback**:
- 🆕 **Pendente**: Aguardando revisão
- 🔍 **Revisado**: Em análise
- ✅ **Resolvido**: Problema corrigido
- 📦 **Arquivado**: Finalizado

### 2. Logs de Erros (`/admin/errors`)

**Visualização**:
- 🚨 Lista de erros capturados
- 📊 Estatísticas por status e severidade
- 🔍 Filtros por tipo, status e severidade
- 📝 Visualização de stack trace
- 🗑️ Limpeza de logs antigos (>30 dias)

**Tipos de Erro**:
- 💥 Exception
- ⚠️ Assertion
- 🌐 Network
- ⏱️ Timeout
- 📄 Parsing
- 🖼️ Render
- 🔄 State
- 🧭 Navigation

**Severidade**:
- 🔵 **Low**: Impacto baixo
- 🟠 **Medium**: Impacto moderado
- 🟠 **High**: Impacto alto
- 🔴 **Critical**: Impacto crítico

**Status**:
- 🆕 **Novo**: Erro recente
- 🔍 **Investigando**: Em análise
- ✅ **Corrigido**: Problema resolvido
- ❌ **Ignorado**: Não será tratado

---

## 🛡️ Segurança

### Regras do Firestore (`firestore.rules`)

```javascript
function isAdmin() {
  return isAuthenticated() && request.auth.token.email in [
    'agrimindsolucoes@gmail.com',
    'agrimind.br@gmail.com'
  ];
}

// Collection feedback
match /feedback/{feedbackId} {
  allow create: if isAuthenticated();  // Usuários podem criar
  allow read, update, delete: if isAdmin();  // Apenas admins gerenciam
}

// Collection error_logs
match /error_logs/{errorId} {
  allow create: if true;  // Logging automático público
  allow read, delete: if isAdmin();  // Apenas admins visualizam
}
```

### Verificação de Autenticação

Cada página admin valida no `initState`:

```dart
@override
void initState() {
  super.initState();
  WidgetsBinding.instance.addPostFrameCallback((_) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      context.go('/admin');  // Redireciona para login
    }
  });
}
```

---

## 🔄 Sincronização em Tempo Real

O dashboard usa Riverpod com streams do Firestore:

```dart
final feedbacksAsync = ref.watch(feedbackStreamProvider(filters));
final countsAsync = ref.watch(feedbackCountsProvider);
```

Quando um novo feedback chega ou o status muda, a UI atualiza automaticamente.

---

## 📱 Responsividade

- 💻 **Desktop**: Layout completo com sidebar
- 📱 **Tablet**: Layout adaptado com sidebar compacto
- 📲 **Mobile**: Menu drawer com navegação simplificada

---

## 🎨 Design

- **Cores Primárias**: Verde (#4CAF50), Verde Escuro (#2E7D32)
- **Dark Mode**: Suportado
- **Componentes**: Material Design 3
- **Layout**: AdminLayout reutilizável com sidebar

---

## 🧪 Testando Localmente

### 1. Rodar app web

```bash
cd apps/app-plantis
flutter run -d chrome --web-port=5000
```

### 2. Acessar painel

```
http://localhost:5000/admin
```

### 3. Fazer login

Use as credenciais criadas no Firebase Authentication.

---

## 📚 Estrutura de Código

```
lib/features/admin/
├── presentation/
│   ├── pages/
│   │   ├── admin_login_page.dart       # Tela de login
│   │   ├── admin_dashboard_page.dart   # Dashboard de feedbacks
│   │   └── admin_errors_page.dart      # Logs de erros
│   └── widgets/
│       └── admin_layout.dart           # Layout base compartilhado
```

---

## 🔧 Manutenção

### Adicionar Novo Admin

1. Criar usuário no Firebase Authentication
2. Adicionar email em `firestore.rules`:

```javascript
function isAdmin() {
  return isAuthenticated() && request.auth.token.email in [
    'agrimindsolucoes@gmail.com',
    'agrimind.br@gmail.com',
    'novoadmin@example.com',  // ← Adicionar aqui
  ];
}
```

3. Deploy: `firebase deploy --only firestore:rules`

### Remover Admin

1. Remover email de `firestore.rules`
2. Deploy das regras
3. (Opcional) Desativar usuário no Firebase Authentication

---

## 🚀 Deploy

### Deploy das Rules

```bash
cd apps/app-plantis
firebase deploy --only firestore:rules
```

### Deploy do App Web

```bash
flutter build web --release
firebase deploy --only hosting
```

---

## 📞 Suporte

Em caso de problemas:
1. Verifique os logs no console do navegador
2. Confirme que as regras foram deployadas
3. Teste a autenticação no Firebase Console
4. Verifique conectividade com Firestore

---

## 🎯 Próximas Melhorias

- [ ] Exportar feedbacks para CSV/Excel
- [ ] Estatísticas e gráficos
- [ ] Notificações de novos feedbacks
- [ ] Integração com email para responder usuários
- [ ] Multi-tenancy (vários apps)
- [ ] Auditoria de ações admin
- [ ] Permissões granulares (roles personalizadas)

---

**Projeto**: CantinhoVerde (Plantis)  
**Firebase Project ID**: (configurar)  
**Última atualização**: 2026-01-16
