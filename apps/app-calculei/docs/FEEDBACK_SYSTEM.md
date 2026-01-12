# Sistema de Feedback - app-calculei

## Visão Geral

O sistema de feedback permite que usuários enviem bug reports, sugestões, comentários e outros feedbacks diretamente do app. Os feedbacks são armazenados no Firebase Firestore e podem ser gerenciados através de um painel administrativo.

## Arquitetura

### Camadas

1. **Domain Layer** (packages/core)
   - `FeedbackEntity` - Modelo de dados do feedback
   - `IFeedbackRepository` - Interface do repositório
   - `FeedbackType` e `FeedbackStatus` - Enums

2. **Infrastructure Layer** (packages/core)
   - `FirebaseFeedbackService` - Implementação usando Firestore

3. **Presentation Layer** 
   - `FeedbackDialog` (core) - Widget para envio de feedback
   - `AdminLoginPage` (app-calculei) - Login administrativo
   - `AdminDashboardPage` (app-calculei) - Painel de gerenciamento

4. **State Management** (Riverpod)
   - `feedbackServiceProvider` - Provider do serviço
   - `feedbackStreamProvider` - Stream de feedbacks em tempo real
   - `feedbackActionsProvider` - Ações de update/delete

## Firebase Firestore

### Collection: `feedback`

#### Estrutura do Documento

```json
{
  "type": "bug" | "suggestion" | "comment" | "other",
  "message": "Texto do feedback (obrigatório)",
  "calculatorId": "id-da-calculadora (opcional)",
  "calculatorName": "Nome da Calculadora (opcional)",
  "rating": 1-5 (opcional),
  "userAgent": "info do dispositivo (opcional)",
  "appVersion": "1.0.0 (opcional)",
  "platform": "android" | "ios" | "web" | "macos" | "windows",
  "status": "pending" | "reviewed" | "resolved" | "archived",
  "createdAt": Timestamp,
  "reviewedAt": Timestamp (opcional),
  "adminNotes": "Notas do admin (opcional)",
  "userEmail": "user@example.com (opcional)"
}
```

### Security Rules

Adicione as seguintes regras ao arquivo `firestore.rules` do projeto Firebase:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    
    // Feedback collection
    match /feedback/{feedbackId} {
      // Qualquer usuário pode criar feedback (mesmo não autenticado)
      allow create: if true;
      
      // Apenas admin autenticado pode ler, atualizar ou deletar
      // Substitua pelo email do admin real
      allow read, update, delete: if request.auth != null 
        && request.auth.token.email in ['admin@seudominio.com'];
    }
    
    // ... outras regras existentes
  }
}
```

**Importante:** 
- Substitua `admin@seudominio.com` pelos emails dos administradores reais
- Para múltiplos admins, adicione todos à lista: `['admin1@email.com', 'admin2@email.com']`

### Deploy das Rules

```bash
firebase deploy --only firestore:rules
```

## Uso

### Enviar Feedback (Usuário)

```dart
import 'package:core/core.dart';

// Em qualquer lugar do app
FeedbackDialog.show(
  context,
  calculatorId: 'brick-calculator',
  calculatorName: 'Calculadora de Tijolos',
  appVersion: '1.2.0',
  primaryColor: Colors.blue,
);
```

### Acessar Painel Admin

1. Navegue para `/admin` no app
2. Faça login com email/senha do Firebase Auth
3. O dashboard estará disponível em `/admin/dashboard`

### Gerenciar Feedbacks (Admin)

O painel permite:
- Visualizar todos os feedbacks em tempo real
- Filtrar por status (Pendente, Revisado, Resolvido, Arquivado)
- Filtrar por tipo (Bug, Sugestão, Comentário, Outro)
- Atualizar status com notas do admin
- Excluir feedbacks

## Fluxo de Status

```
[Novo Feedback] -> PENDING
                      |
                      v
                   REVIEWED (Admin viu e está analisando)
                      |
                      v
                   RESOLVED (Problema corrigido / Sugestão implementada)
                      |
                      v
                   ARCHIVED (Feedback arquivado)
```

## Configuração no Firebase Console

### 1. Criar usuário admin

1. Acesse Firebase Console > Authentication
2. Clique em "Add user"
3. Adicione email/senha do admin
4. Atualize as security rules com o email do admin

### 2. Criar índices (se necessário)

Se você receber erros de índices, o Firebase geralmente fornece um link para criá-los automaticamente. Os índices comuns são:

- `status` (ASC) + `createdAt` (DESC)
- `type` (ASC) + `createdAt` (DESC)

## Manutenção

### Limpeza de feedbacks antigos

Considere criar uma Cloud Function para arquivar/deletar feedbacks resolvidos após X dias:

```javascript
// Exemplo de Cloud Function (Node.js)
exports.archiveOldFeedback = functions.pubsub
  .schedule('every 24 hours')
  .onRun(async (context) => {
    const thirtyDaysAgo = new Date();
    thirtyDaysAgo.setDate(thirtyDaysAgo.getDate() - 30);
    
    const snapshot = await admin.firestore()
      .collection('feedback')
      .where('status', '==', 'resolved')
      .where('reviewedAt', '<', thirtyDaysAgo)
      .get();
    
    const batch = admin.firestore().batch();
    snapshot.docs.forEach(doc => {
      batch.update(doc.ref, { status: 'archived' });
    });
    
    return batch.commit();
  });
```
