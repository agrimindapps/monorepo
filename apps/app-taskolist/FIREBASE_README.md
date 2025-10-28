# Firebase Configuration - app-taskolist

Documentação completa de configuração do Firebase para o app-taskolist.

## 📚 Documentação Incluída

1. **[FIREBASE_SETUP.md](./FIREBASE_SETUP.md)** - Guia de configuração inicial
   - Habilitar autenticação
   - Criar Firestore database
   - Aplicar regras de segurança
   - Estrutura de dados esperada

2. **[FIRESTORE_USAGE_EXAMPLES.md](./FIRESTORE_USAGE_EXAMPLES.md)** - Exemplos práticos de código
   - Autenticação (signup, signin, signout)
   - Operações com task lists
   - Operações com tasks
   - Padrões avançados (transações, batch, pagination)

3. **[FIREBASE_DEPLOY.md](./FIREBASE_DEPLOY.md)** - Guia de deployment
   - Setup de Firebase CLI
   - Deploy das rules
   - Testes com emulator
   - CI/CD integration

4. **[firebase_firestore.rules](./firebase_firestore.rules)** - Regras de segurança
   - Autenticação obrigatória
   - Acesso baseado em ownership
   - Validação de dados
   - Suporte a compartilhamento

## 🚀 Quick Start (5 minutos)

### 1. Criar Firebase Project

1. Acesse [Firebase Console](https://console.firebase.google.com)
2. Clique em "Criar Projeto"
3. Configure as preferências
4. Ative Firestore Database

### 2. Habilitar Autenticação

1. No Firebase Console → Authentication
2. Clique em "Get Started"
3. Habilite "Email/Password"
4. (Opcional) Habilite Google, Apple Sign-In

### 3. Aplicar Firestore Rules

```bash
# Instale Firebase CLI
npm install -g firebase-tools

# Faça login
firebase login

# No app, aplique as rules
firebase deploy --only firestore:rules
```

### 4. Configurar App Flutter

```bash
# Gere arquivo de configuração
flutterfire configure

# Adicione dependências no pubspec.yaml
# - firebase_core
# - firebase_auth
# - cloud_firestore
```

## 🔐 Segurança (Importante!)

### Regras de Ouro

✅ **SEMPRE:**
- Autenticar usuários
- Validar dados no servidor
- Usar rules específicas por coleção
- Testar com múltiplos usuários

❌ **NUNCA:**
- Usar `allow read, write: if true`
- Armazenar senhas em Firestore
- Commitar credenciais no Git
- Deixar test mode em produção

### Transição para Produção

1. Substitua regras de test mode
2. Configure CORS adequadamente
3. Implemente rate limiting
4. Monitore acessos suspeitos
5. Configure backups automáticos

## 📊 Estrutura de Dados

```
├── users/{userId}
│   └── Dados do usuário (email, displayName, etc)
├── task_lists/{taskListId}
│   ├── Metadados da lista
│   └── tasks/{taskId}
│       └── Dados da tarefa individual
└── shared_task_lists/{userId}/{taskListId}
    └── Referência para listas compartilhadas
```

## ⚙️ Configurações do App

### Environment Variables (.env)

```bash
FIREBASE_PROJECT_ID=seu-projeto-id
FIREBASE_API_KEY=sua-api-key
FIREBASE_APP_ID=seu-app-id
```

**⚠️ NÃO commitar .env no Git!**

### pubspec.yaml

```yaml
dependencies:
  firebase_core: ^2.24.0
  firebase_auth: ^4.10.0
  cloud_firestore: ^4.14.0
```

## 🧪 Testes

### Testar Localmente com Emulator

```bash
# Iniciar emulator
firebase emulators:start

# Seu app se conectará automaticamente ao localhost:8080
```

### Testar Regras

1. Use o Firestore Emulator
2. Teste com múltiplos usuários
3. Verifique erros no console
4. Valide permissões específicas

## 🔄 Workflow de Desenvolvimento

```
1. Desenvolvimento Local
   ↓
2. Testar com Emulator
   ↓
3. Validar com dry-run
   ↓
4. Deploy para Staging (opcional)
   ↓
5. Deploy para Produção
```

## 📈 Monitoramento

### Acessar Logs

**No Firebase Console:**
- Authentication → Logs
- Firestore → Stats
- Cloud Functions → Logs

### Métricas Importantes

- Taxa de erro de autenticação
- Operações Firestore (leitura/escrita)
- Latência de sincronização
- Espaço de armazenamento

## 🚨 Problemas Comuns

| Problema | Causa | Solução |
|----------|-------|---------|
| "Permission denied" | Usuário sem acesso | Verificar rules e ownership |
| "Invalid argument" | Dados mal formatados | Validar tipos de dados |
| "Unavailable" | Firestore offline | Verificar conectividade |
| Login não funciona | Auth não habilitado | Habilitar Email/Password |

## 📱 Mobile-Specific

### Android

```xml
<!-- AndroidManifest.xml -->
<uses-permission android:name="android.permission.INTERNET" />
```

### iOS

```swift
// Info.plist
<key>NSLocalNetworkUsageDescription</key>
<string>Permite sincronização de dados</string>
```

## 🎯 Objetivos de Implementação

- [ ] Firebase Auth configurado
- [ ] Firestore Database criado
- [ ] Rules publicadas
- [ ] App pode fazer login
- [ ] App pode criar task lists
- [ ] App pode criar tasks
- [ ] Sincronização funciona
- [ ] Compartilhamento funciona
- [ ] Testes passam com múltiplos usuários

## 📖 Recursos Úteis

- 📚 [Firebase Docs](https://firebase.google.com/docs)
- 🔐 [Firestore Security](https://firebase.google.com/docs/firestore/security/start)
- 🎯 [Flutter Firebase](https://firebase.flutter.dev/)
- 💬 [Firebase Stack Overflow Tag](https://stackoverflow.com/questions/tagged/firebase)

## 🤝 Suporte

- **Issues de Autenticação**: Ver [FIREBASE_SETUP.md](./FIREBASE_SETUP.md#troubleshooting)
- **Issues de Firestore**: Ver [FIRESTORE_USAGE_EXAMPLES.md](./FIRESTORE_USAGE_EXAMPLES.md#tratamento-de-erros)
- **Issues de Deploy**: Ver [FIREBASE_DEPLOY.md](./FIREBASE_DEPLOY.md#troubleshooting)

## ✅ Próximos Passos

1. ✅ Ler [FIREBASE_SETUP.md](./FIREBASE_SETUP.md)
2. ✅ Habilitar Auth e Firestore no Firebase Console
3. ✅ Executar `flutterfire configure`
4. ✅ Aplicar rules com `firebase deploy`
5. ✅ Implementar exemplos de [FIRESTORE_USAGE_EXAMPLES.md](./FIRESTORE_USAGE_EXAMPLES.md)
6. ✅ Testar com múltiplos usuários
7. ✅ Deploy para produção

---

**Última atualização**: 2025-10-28
**Status**: ✅ Pronto para implementação
**Versão**: 1.0

Para dúvidas, consulte a documentação específica ou o guia de troubleshooting.
