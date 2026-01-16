# 🔍 Análise de Implementação Admin - app-calculei → app-plantis

**Data**: 2026-01-16  
**Objetivo**: Replicar funcionalidades admin do app-calculei para app-plantis

---

## 📊 Estado Atual - app-calculei

### ✅ **Funcionalidades Implementadas:**

#### 1. **🔐 Admin Login** (`/admin`)
- Firebase Authentication com email/password
- Validação de admin via email hardcoded em firestore.rules
- Redirect para `/admin/dashboard` após login
- **Arquivo**: `lib/features/admin/presentation/pages/admin_login_page.dart`

#### 2. **📊 Admin Dashboard** (`/admin/dashboard`)
- **Visualização de Feedbacks**
- Cards de estatísticas por status
- Filtros: status, tipo, busca
- Lista em tempo real (Firestore streams)
- Ações: atualizar status, adicionar notas admin
- **Arquivo**: `lib/features/admin/presentation/pages/admin_dashboard_page.dart`

#### 3. **🚨 Error Logs** (`/admin/errors`)
- Visualização de erros web capturados
- Cards de estatísticas por severidade
- Filtros: status, tipo, severidade
- Detalhes: stack trace, URL, dispositivo
- Cleanup de logs antigos
- **Arquivo**: `lib/features/admin/presentation/pages/admin_errors_page.dart`

#### 4. **🎨 Admin Layout**
- Sidebar de navegação responsivo
- Header com ações rápidas
- Dark mode support
- Material Design 3
- **Arquivo**: `lib/features/admin/presentation/widgets/admin_layout.dart`

---

## 📦 **Infraestrutura no Package Core**

### ✅ **Entities Já Disponíveis:**

#### **FeedbackEntity** (`packages/core/lib/src/domain/entities/feedback_entity.dart`)
```dart
class FeedbackEntity {
  final String id;
  final FeedbackType type;        // bug, suggestion, comment, other
  final String message;
  final FeedbackStatus status;    // pending, reviewed, resolved, archived
  final String? calculatorId;     // → Adaptar para plantId no plantis
  final String? calculatorName;   // → Adaptar para plantName
  final double? rating;
  final String? userEmail;
  final String? userAgent;
  final String? appVersion;
  final String? platform;
  final DateTime createdAt;
  final DateTime? reviewedAt;
  final String? adminNotes;
}
```

**Enums:**
- `FeedbackType`: bug, suggestion, comment, other
- `FeedbackStatus`: pending, reviewed, resolved, archived

---

#### **ErrorLogEntity** (`packages/core/lib/src/domain/entities/error_log_entity.dart`)
```dart
class ErrorLogEntity {
  final String id;
  final ErrorType errorType;       // exception, network, timeout, etc
  final String message;
  final String? stackTrace;
  final ErrorSeverity severity;    // low, medium, high, critical
  final ErrorStatus status;        // new, investigating, fixed, ignored, wontFix
  final String? url;
  final String? calculatorId;      // → Adaptar para plantId
  final String? calculatorName;    // → Adaptar para plantName
  final String? userAgent;
  final String? appVersion;
  final String platform;
  final String? browserInfo;
  final String? screenSize;
  final DateTime createdAt;
  final DateTime? resolvedAt;
  final String? adminNotes;
  final int occurrences;           // Deduplicação de erros
  final DateTime? lastOccurrence;
  final String? errorHash;
  final String? sessionId;
}
```

**Enums:**
- `ErrorType`: exception, assertion, network, timeout, parsing, render, state, navigation, other
- `ErrorStatus`: newError, investigating, fixed, ignored, wontFix
- `ErrorSeverity`: low, medium, high, critical

---

### ✅ **Services Já Disponíveis:**

#### **FirebaseFeedbackService** (`packages/core/lib/src/infrastructure/services/firebase_feedback_service.dart`)
- Stream de feedbacks com filtros
- Contadores por status
- Atualizar status
- Adicionar notas admin
- CRUD completo

#### **FirebaseErrorLogService** (`packages/core/lib/src/infrastructure/services/firebase_error_log_service.dart`)
- Stream de error logs com filtros
- Contadores por status/severidade
- Atualizar status
- Cleanup de logs antigos
- Deduplicação automática (errorHash)

#### **Providers Riverpod** (`packages/core/lib/src/riverpod/domain/`)
```dart
// Feedback
@riverpod
Stream<List<FeedbackEntity>> feedbackStream(...)
@riverpod
Future<Map<FeedbackStatus, int>> feedbackCounts(...)

// Error Logs
@riverpod
Stream<List<ErrorLogEntity>> errorLogStream(...)
@riverpod
Future<Map<ErrorStatus, int>> errorLogCounts(...)
```

---

## 🔒 **Segurança - Firestore Rules**

### **app-calculei/firestore.rules:**

```javascript
function isAdmin() {
  return isAuthenticated() && request.auth.token.email in [
    'agrimindsolucoes@gmail.com',
    'agrimind.br@gmail.com'
  ];
}

match /feedback/{feedbackId} {
  // Qualquer usuário pode criar feedback
  allow create: if isAuthenticated();
  
  // Apenas admins podem ler/atualizar/deletar
  allow read, update, delete: if isAdmin();
}

match /error_logs/{errorId} {
  // Público pode criar (logging automático)
  allow create: if true;
  
  // Apenas admins podem ler/deletar
  allow read, delete: if isAdmin();
}
```

---

## 🎯 **Adaptações para app-plantis**

### **1. Contexto de Feedback/Erros:**

| Campo Calculei | Campo Plantis | Descrição |
|----------------|---------------|-----------|
| `calculatorId` | `plantId` | ID da planta onde ocorreu |
| `calculatorName` | `plantName` | Nome da planta |
| - | `taskId` | ID da tarefa relacionada (opcional) |
| - | `spaceId` | ID do ambiente/espaço (opcional) |

### **2. Tipos de Feedback Específicos:**

Além dos tipos padrão, adicionar contexto plantis:
- 💬 **comment**: Comentário geral ou em planta
- 🐛 **bug**: Bug report
- 💡 **suggestion**: Sugestão de feature
- 🌱 **plant_issue**: Problema com planta específica
- ⏰ **task_issue**: Problema com tarefas/notificações

### **3. Onde Capturar Feedback:**

#### **A. Comentários em Plantas** (feature comments vazia!)
- Usuários comentam em suas próprias plantas
- Sistema de notas/diário de cuidados
- Não precisa moderação (dados privados do usuário)
- **USO**: Tracking de crescimento, observações

#### **B. Feedback Geral** (similar ao calculei)
- Botão "Enviar Feedback" em Settings
- Report de bugs
- Sugestões de melhorias
- **USO**: Admin gerenciar feedbacks

**DECISÃO**: Implementar AMBOS!
- `comments` collection: Privado por usuário (notas pessoais)
- `feedback` collection: Público para admins (bugs/sugestões)

### **4. Captura de Erros:**

#### **A. Manual (Botão "Reportar Problema")**
```dart
// Settings → Ajuda → Reportar Problema
FeedbackType.bug + captura de contexto
```

#### **B. Automático (Global Error Handler)**
```dart
// main.dart
void main() {
  FlutterError.onError = (details) {
    ErrorLogService.logError(details);
  };
  
  runZonedGuarded(() {
    runApp(MyApp());
  }, (error, stack) {
    ErrorLogService.logError(error, stack);
  });
}
```

---

## 📋 **Plano de Implementação**

### **Fase 1: Infraestrutura Admin** ⏳
- [ ] Criar `lib/features/admin/`
- [ ] Copiar `AdminLayout` do calculei (adaptar cores)
- [ ] Criar `AdminLoginPage` (tema verde plantis)
- [ ] Criar `AdminDashboardPage`
- [ ] Criar `AdminErrorsPage`
- [ ] Adicionar rotas no `app_router.dart`
- [ ] Configurar `firestore.rules` com função `isAdmin()`

### **Fase 2: Feature Comments (Notas Pessoais)** ⏳
- [ ] Completar `lib/features/comments/domain/entities/comment_entity.dart`
- [ ] Criar repository/service para comments
- [ ] UI: Adicionar aba "Notas" em PlantDetailsPage
- [ ] Permitir fotos nas notas (galeria de evolução!)
- [ ] Timeline de comentários ordenados por data

### **Fase 3: Feature Feedback (Admin Moderation)** ⏳
- [ ] Reutilizar `FeedbackEntity` do core
- [ ] Criar botão "Enviar Feedback" em Settings
- [ ] Formulário de feedback (tipo, mensagem, email opcional)
- [ ] AdminDashboardPage: Lista de feedbacks com filtros
- [ ] Ações admin: atualizar status, adicionar notas

### **Fase 4: Error Logging** ⏳
- [ ] Reutilizar `ErrorLogEntity` do core
- [ ] Configurar global error handler no `main.dart`
- [ ] Captura de contexto: plantId, taskId, route
- [ ] AdminErrorsPage: Lista de erros com filtros
- [ ] Cleanup automático de erros antigos (>30 dias)

### **Fase 5: Segurança** ⏳
- [ ] Configurar emails admin em `firestore.rules`
- [ ] Testar acesso admin vs regular user
- [ ] Validar que usuários não-admin não veem /admin
- [ ] Verificar rules: users podem criar feedback/logs

---

## 🔑 **Emails Admin (a definir)**

```javascript
// firestore.rules - app-plantis
function isAdmin() {
  return isAuthenticated() && request.auth.token.email in [
    'agrimindsolucoes@gmail.com',    // ← Confirmar
    'agrimind.br@gmail.com',         // ← Confirmar
    // Adicionar outros admins aqui
  ];
}
```

---

## 🎨 **Design System - Plantis**

### **Cores:**
- **Primary**: Verde (#4CAF50 ou similar)
- **Accent**: Verde escuro (#2E7D32)
- **Background Dark**: #1A1A2E
- **Card Dark**: #16213E

### **Componentes:**
- Reutilizar `AdminLayout` com tema verde
- Manter estrutura de cards do calculei
- Adaptar ícones para contexto de plantas (🌱 🌿 🍃)

---

## ✅ **Diferenças Principais:**

| Aspecto | app-calculei | app-plantis |
|---------|--------------|-------------|
| **Contexto** | Calculadora específica | Planta/Tarefa específica |
| **Feedback** | Bugs em cálculos | Bugs em app + Comentários em plantas |
| **Comments** | Não existe | Feature vazia → implementar como notas pessoais |
| **Error Context** | calculatorId, calculatorName | plantId, plantName, taskId, spaceId |
| **Tema** | Teal (#009688) | Verde (#4CAF50) |

---

## 🚀 **Próximos Passos:**

1. ✅ **Análise completa** (este documento)
2. ⏳ **Decidir emails admin**
3. ⏳ **Implementar Fase 1** (infraestrutura)
4. ⏳ **Implementar Fase 2** (comments como notas pessoais)
5. ⏳ **Implementar Fase 3** (feedback admin)
6. ⏳ **Implementar Fase 4** (error logging)
7. ⏳ **Implementar Fase 5** (segurança e testes)

---

**Status**: 📋 Planejamento completo  
**Estimativa**: ~3-4 dias de implementação  
**Prioridade**: Média-Alta
