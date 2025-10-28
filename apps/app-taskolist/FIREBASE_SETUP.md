# Firebase Setup Guide - app-taskolist

Este documento descreve como configurar o Firebase para o app-taskolist, incluindo autenticação e Firestore.

## 📋 Pré-requisitos

- Projeto Firebase criado no [Firebase Console](https://console.firebase.google.com)
- Firebase CLI instalado: `npm install -g firebase-tools`
- Conta no Google Cloud Console com permissões de administrador

## 🔐 1. Configurar Autenticação (Firebase Auth)

### 1.1 Habilitar Email/Senha

1. Acesse **Firebase Console** → Seu Projeto → **Authentication**
2. Clique em **Get Started** (se não estiver já configurado)
3. Vá para **Sign-in method**
4. Habilite **Email/Password**
5. Salve as alterações

### 1.2 Habilitar Provedores de Login Social (Opcional)

Para adicionar login com Google, Apple, Facebook:

1. Em **Sign-in method**, procure pelo provedor desejado
2. Clique para ativar e configure as credenciais necessárias
3. **Google**: Use suas credenciais OAuth do Google Cloud Console
4. **Apple**: Use suas credenciais de desenvolvedor Apple
5. **Facebook**: Use seus app credentials do Facebook Developer

### 1.3 Configuração no Código

No seu `lib/main.dart` ou durante a inicialização:

```dart
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart'; // Arquivo gerado pelo CLI

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}
```

## 🔥 2. Configurar Firestore Database

### 2.1 Criar Firestore Database

1. Acesse **Firebase Console** → Seu Projeto → **Firestore Database**
2. Clique em **Create Database**
3. Escolha a localização mais próxima da sua audiência principal
4. **Modo de inicialização**: Selecione **Start in test mode** (temporário para desenvolvimento)
5. Clique em **Create**

### 2.2 Aplicar Regras de Segurança

#### Opção A: Via Firebase Console (Recomendado para começar)

1. No Firestore, vá para a aba **Rules**
2. Copie todo o conteúdo do arquivo `firebase_firestore.rules` deste repositório
3. Cole no editor de regras do Firebase Console
4. Clique em **Publish**

#### Opção B: Via Firebase CLI (Recomendado para produção)

```bash
# Instale firebase-tools se não tiver
npm install -g firebase-tools

# Faça login no Firebase
firebase login

# Deploy das regras
firebase deploy --only firestore:rules
```

## 📊 3. Estrutura de Dados Firestore

Seu Firestore terá a seguinte estrutura:

```
firestore/
├── users/
│   └── {userId}/
│       ├── email: string
│       ├── displayName: string
│       ├── photoURL: string?
│       └── createdAt: timestamp
├── task_lists/
│   └── {taskListId}/
│       ├── id: string
│       ├── title: string
│       ├── description: string?
│       ├── color: string
│       ├── ownerId: string (referência ao userId)
│       ├── memberIds: array<string> (para listas compartilhadas)
│       ├── isShared: boolean
│       ├── isArchived: boolean
│       ├── createdAt: timestamp
│       ├── updatedAt: timestamp
│       └── tasks/ (subcoleção)
│           └── {taskId}/
│               ├── id: string
│               ├── title: string
│               ├── description: string?
│               ├── listId: string
│               ├── createdById: string
│               ├── assignedToId: string?
│               ├── status: 'pending' | 'inProgress' | 'completed' | 'cancelled'
│               ├── priority: 'low' | 'medium' | 'high' | 'urgent'
│               ├── dueDate: timestamp?
│               ├── reminderDate: timestamp?
│               ├── isStarred: boolean
│               ├── tags: array<string>
│               ├── parentTaskId: string? (para subtasks)
│               ├── notes: string?
│               ├── version: integer
│               ├── isDirty: boolean
│               ├── isDeleted: boolean
│               ├── lastSyncAt: timestamp?
│               ├── createdAt: timestamp
│               ├── updatedAt: timestamp
│               └── comments/ (subcoleção - opcional)
│                   └── {commentId}/
│                       ├── text: string
│                       ├── createdBy: string
│                       └── createdAt: timestamp
└── shared_task_lists/
    └── {userId}/
        └── {taskListId}: reference
```

## 🔑 4. Regras de Firestore Explicadas

### Permissões de Leitura/Escrita

| Recurso | Operação | Quem Pode | Regra |
|---------|----------|----------|-------|
| **task_lists** | Ler | Owner + Members | `isTaskListMember()` |
| **task_lists** | Criar | Usuário autenticado | Auto-set `ownerId` |
| **task_lists** | Atualizar | Owner | `isTaskListOwner()` |
| **task_lists** | Deletar | Owner | `isTaskListOwner()` |
| **tasks** | Ler | Owner + Members da lista | `hasTaskListAccess()` |
| **tasks** | Criar | Owner + Members da lista | `hasTaskListAccess()` |
| **tasks** | Atualizar | Creator ou Owner da lista | Same as read |
| **tasks** | Deletar | Creator ou Owner da lista | Creator or Owner |

### Validações Implementadas

1. **isValidTaskList()**: Valida estrutura de task list
   - Verifica tipos de dados
   - Garante que campos obrigatórios existem

2. **isValidTask()**: Valida estrutura de task
   - Verifica tipos de dados
   - Valida enum de status e priority

3. **hasTaskListAccess()**: Verifica acesso a lista
   - Lista existe
   - Usuário é owner ou membro

## 📱 5. Configurar no App

### 5.1 Variáveis de Ambiente

Crie um arquivo `.env` (não commitar no Git):

```
FIREBASE_PROJECT_ID=seu-projeto-id
FIREBASE_API_KEY=sua-api-key
FIREBASE_APP_ID=seu-app-id
FIREBASE_MESSAGING_SENDER_ID=seu-messaging-sender-id
```

### 5.2 Configurar pubspec.yaml

```yaml
dependencies:
  firebase_core: ^2.24.0
  firebase_auth: ^4.10.0
  cloud_firestore: ^4.14.0
  google_sign_in: ^6.1.0 # Para Google Sign-In (opcional)
  sign_in_with_apple: ^5.0.0 # Para Apple Sign-In (opcional)
```

### 5.3 Gerar Firebase Config

```bash
# No diretório do app
flutterfire configure
```

Isso gerará automaticamente `firebase_options.dart` com suas credenciais.

## 🔒 6. Migrar do Modo Test para Modo Seguro (Produção)

### ⚠️ Quando Mudar para Modo Seguro

Quando estiver pronto para produção, altere suas regras para:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Mantém as regras do firebase_firestore.rules mas remova o test mode
    // Use a versão completa com validações
  }
}
```

**NUNCA use em produção:**
```javascript
allow read, write: if true; // ❌ INSEGURO
```

## 🧪 7. Testar Regras de Firestore

### Teste Local com Emulator

```bash
# Instale Firebase Emulator
npm install -g @firebase/cli

# Inicie o emulator
firebase emulators:start

# Configure seu app para usar o emulator (development only)
```

### Teste Manual no Console

1. Crie dados de teste manualmente no Firestore
2. Tente ler/escrever como diferentes usuários
3. Verifique se as permissões estão funcionando

## 📚 8. Troubleshooting

### Erro: "Permission denied"

**Causa**: Usuário não tem acesso à coleção/documento

**Solução**:
1. Verifique se o usuário está autenticado (`request.auth != null`)
2. Verifique se a estrutura de dados está correta
3. Verifique as regras de acesso para o recurso específico

### Erro: "Invalid argument"

**Causa**: Estrutura de dados não corresponde às regras

**Solução**:
1. Valide que todos os campos obrigatórios estão presentes
2. Valide que os tipos de dados correspondem (string, timestamp, etc.)
3. Verifique enums de status e priority

### Dados não sincronizam

**Causa**: Problemas de conectividade ou regras

**Solução**:
1. Ative Firestore offline persistence
2. Implemente retry logic
3. Monitore Firebase logs

## 🚀 9. Deploy Checklist

- [ ] Firebase Authentication habilitado (Email/Password)
- [ ] Firestore Database criado
- [ ] Regras de segurança publicadas
- [ ] Estrutura de coleções criada
- [ ] Testado login com múltiplos usuários
- [ ] Testadas permissões de read/write
- [ ] Testada sincronização de dados
- [ ] Removidas credenciais de .env do controle de versão
- [ ] Backup configurado (Firebase Backup & Restore)

## 📖 Recursos Úteis

- [Firebase Authentication Docs](https://firebase.google.com/docs/auth)
- [Firestore Security Rules](https://firebase.google.com/docs/firestore/security/start)
- [Firestore Best Practices](https://firebase.google.com/docs/firestore/best-practices)
- [Flutter Firebase Integration](https://firebase.flutter.dev/)

---

**Última atualização**: 2025-10-28
**Autor**: Claude Code
