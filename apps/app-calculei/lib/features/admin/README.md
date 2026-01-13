# 🔐 Painel Administrativo - Calculei

## 📋 Visão Geral

O painel administrativo permite gerenciar feedbacks e erros enviados pelos usuários do aplicativo Calculei.

## 🌐 Acesso

- **URL Web**: https://calculei-52e71.web.app/admin
- **URL Local**: http://localhost:5000/admin (durante desenvolvimento)

## 🔑 Autenticação

O acesso é restrito a administradores autorizados via Firebase Authentication.

### Configurar Primeiro Acesso

1. **Criar usuário admin no Firebase**:
   - Acesse: https://console.firebase.google.com/u/0/project/calculei-52e71/authentication/users
   - Clique em "Add User"
   - Digite email e senha
   - Salve as credenciais em local seguro

2. **Adicionar email na lista de admins**:
   - Edite `firestore.rules`
   - Adicione o email na função `isAdmin()`
   - Deploy: `firebase deploy --only firestore:rules`

3. **Fazer login**:
   - Acesse `/admin`
   - Digite email e senha
   - Você será redirecionado para `/admin/dashboard`

## 📊 Funcionalidades

### Dashboard (`/admin/dashboard`)

**Visualização de Feedbacks**:
- 📈 Contadores por status (Pendente, Em Análise, Resolvido, Arquivado)
- 🔍 Filtros por status e tipo
- 📝 Lista em tempo real de feedbacks
- ✏️ Atualização de status
- 💬 Adicionar notas/respostas

**Tipos de Feedback**:
- 🐛 Bug
- 💡 Sugestão
- ❓ Outro

**Status de Feedback**:
- 🆕 Pendente (novo)
- 🔍 Em Análise
- ✅ Resolvido
- 📦 Arquivado

### Logs de Erros (`/admin/errors`)

**Visualização de Erros Web**:
- 🚨 Lista de erros capturados
- 📊 Filtros por severidade
- 🗑️ Limpeza de logs antigos
- 📝 Detalhes de stack trace

## 🛡️ Segurança

### Regras do Firestore

**Collection `feedback`**:
- ✅ CREATE: Público (qualquer usuário pode enviar)
- 🔒 READ/UPDATE/DELETE: Apenas admins

**Collection `error_logs`**:
- ✅ CREATE: Público (logging automático)
- 🔒 READ/DELETE: Apenas admins

### Implementação

```dart
// Verificação de autenticação em cada página admin
@override
void initState() {
  super.initState();
  WidgetsBinding.instance.addPostFrameCallback((_) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      context.go('/admin'); // Redireciona para login
    }
  });
}
```

## 🔄 Sincronização em Tempo Real

O dashboard usa Riverpod com streams do Firestore para atualização em tempo real:

```dart
// Provider que escuta mudanças no Firestore
final feedbacksAsync = ref.watch(feedbackStreamProvider(filters));
```

Quando um novo feedback chega ou o status muda, a UI atualiza automaticamente.

## 📱 Responsividade

O painel é responsivo e funciona em:
- 💻 Desktop (layout completo)
- 📱 Tablet (layout adaptado)
- 📲 Mobile (layout compacto)

## 🎨 Design

- **Cores**: Tema teal (#009688)
- **Dark Mode**: Suportado
- **Componentes**: Material Design 3
- **Animações**: Transições suaves

## 🧪 Testando Localmente

### 1. Configurar emuladores Firebase (opcional)

```bash
firebase emulators:start
```

### 2. Rodar app web

```bash
cd apps/app-calculei
flutter run -d chrome --web-port=5000
```

### 3. Acessar painel

```
http://localhost:5000/admin
```

## 📚 Estrutura de Código

```
lib/features/admin/
├── presentation/
│   └── pages/
│       ├── admin_login_page.dart      # Tela de login
│       ├── admin_dashboard_page.dart  # Dashboard principal
│       └── admin_errors_page.dart     # Logs de erros
```

## 🔧 Manutenção

### Adicionar Novo Admin

1. Criar usuário no Firebase Authentication
2. Adicionar email em `firestore.rules`:

```javascript
function isAdmin() {
  return isAuthenticated() && request.auth.token.email in [
    'admin1@example.com',
    'admin2@example.com',  // Novo admin
  ];
}
```

3. Deploy: `firebase deploy --only firestore:rules`

### Remover Admin

1. Remover email de `firestore.rules`
2. Deploy das regras
3. (Opcional) Desativar usuário no Firebase Authentication

### Limpar Feedbacks Antigos

Atualmente manual via Firebase Console. Considere implementar:
- Limpeza automática de feedbacks arquivados após X dias
- Exportação de dados antes de deletar
- Archive em vez de delete permanente

## 🚀 Melhorias Futuras

- [ ] Exportar feedbacks para CSV/Excel
- [ ] Estatísticas e gráficos
- [ ] Notificações de novos feedbacks
- [ ] Respostas automáticas
- [ ] Integração com email
- [ ] Multi-tenancy (vários apps)
- [ ] Auditoria de ações admin
- [ ] Permissões granulares (roles)

## 📞 Suporte

Em caso de problemas:
1. Verifique os logs no console do navegador
2. Confirme que as regras foram deployadas
3. Teste a autenticação no Firebase Console
4. Verifique conectividade com Firestore

---

**Projeto**: Calculei  
**Firebase Project ID**: calculei-52e71  
**Última atualização**: 2026-01-12
