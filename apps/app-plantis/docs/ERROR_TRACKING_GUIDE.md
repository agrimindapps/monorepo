# 🐛 Global Error Tracking - app-plantis

## Visão Geral

Sistema de captura automática de erros implementado no app-plantis para facilitar a detecção e resolução de bugs em produção através do painel Admin.

## 🏗️ Arquitetura

### **ErrorCaptureService**
Serviço principal que captura erros automaticamente:

- ✅ **Captura Automática**: FlutterError.onError + PlatformDispatcher.instance.onError
- ✅ **Rate Limiting**: Máximo 10 erros/minuto (evita spam)
- ✅ **Deduplicação**: Hash-based (evita duplicatas em 5 minutos)
- ✅ **Classificação Automática**: Detecta tipo de erro pelo contexto
- ✅ **Contexto Rico**: Route, plantId, userId, appVersion, platform

### **Componentes**

```
ErrorCaptureService (core/services/)
├─ Captura de erros globais
├─ Rate limiting
├─ Deduplication
└─ Context tracking

ErrorCaptureProvider (core/providers/)
└─ Riverpod integration

ErrorTrackingObserver (core/observers/)
└─ Route tracking automático
```

---

## 📦 Providers

### **errorCaptureServiceProvider**
```dart
final errorService = ref.read(errorCaptureServiceProvider);

// Atualizar contexto de rota (automático via NavigatorObserver)
errorService.setCurrentRoute('/plants/123');

// Atualizar contexto de planta
errorService.setCurrentPlant(id: 'plant-123', name: 'Samambaia');

// Atualizar contexto de tarefa
errorService.setCurrentTask('task-456');

// Atualizar contexto de usuário (automático via AuthProvider)
errorService.setUserContext(
  userId: 'user-789',
  email: 'user@email.com',
);

// Atualizar screen size
errorService.updateScreenSize(width, height);
```

---

## 🎯 Tipos de Erros Capturados

### **Automáticos (Flutter Framework)**

| Tipo | Detecção | Severidade |
|------|----------|------------|
| **exception** | Qualquer Exception não tratada | medium |
| **assertion** | AssertionError | high |
| **render** | Erros em rendering library | medium |
| **state** | Erros em widgets library | high |
| **navigation** | Erros em navigator | medium |

### **Manuais (Specialized Capture)**

```dart
final errorService = ref.read(errorCaptureServiceProvider);

// 1. Network Error
await errorService.captureNetworkError(
  url: 'https://api.example.com/plants',
  statusCode: 500,
  message: 'Internal Server Error',
);

// 2. Timeout Error
await errorService.captureTimeoutError(
  operation: 'syncPlants',
  timeout: Duration(seconds: 30),
);

// 3. Parsing Error
await errorService.captureParsingError(
  dataType: 'PlantEntity',
  message: 'Invalid JSON format',
  rawData: jsonString,
);
```

---

## 🔄 Fluxo Completo

```
┌─────────────────────────────────────────────────────────────────┐
│ 1. ERRO OCORRE                                                  │
│    └─ FlutterError.onError ou PlatformDispatcher.instance.onError│
└─────────────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────────┐
│ 2. RATE LIMITING                                                │
│    └─ Verifica se não excedeu 10 erros/minuto                  │
│    └─ Se excedeu: descarta                                      │
└─────────────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────────┐
│ 3. DEDUPLICAÇÃO                                                 │
│    └─ Gera hash do erro + primeira linha do stack               │
│    └─ Verifica se já ocorreu nos últimos 5 minutos             │
│    └─ Se duplicado: descarta                                    │
└─────────────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────────┐
│ 4. CLASSIFICAÇÃO                                                │
│    └─ Detecta errorType (exception, assertion, render, etc.)   │
│    └─ Determina severity (critical, high, medium, low)         │
└─────────────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────────┐
│ 5. CONTEXTO                                                     │
│    └─ Coleta contexto atual:                                    │
│         ├─ route: /plants/123                                   │
│         ├─ plantId: plant-123                                   │
│         ├─ plantName: Samambaia                                 │
│         ├─ taskId: task-456                                     │
│         ├─ userId: user-789                                     │
│         ├─ userEmail: user@email.com                            │
│         ├─ appVersion: 1.0.0+1                                  │
│         ├─ platform: web/android/ios                            │
│         └─ screenSize: 1920x1080                                │
└─────────────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────────┐
│ 6. SALVAR NO FIRESTORE                                         │
│    └─ Collection: /error_logs/{id}                             │
│         ├─ errorType: ErrorType enum                           │
│         ├─ message: String                                      │
│         ├─ stackTrace: String?                                  │
│         ├─ severity: ErrorSeverity enum                        │
│         ├─ status: ErrorLogStatus.newError                     │
│         ├─ context: Map<String, dynamic>                       │
│         ├─ errorHash: String (deduplication)                   │
│         ├─ occurrences: 1                                       │
│         ├─ platform: String                                     │
│         ├─ createdAt: DateTime                                  │
│         └─ updatedAt: DateTime                                  │
└─────────────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────────┐
│ 7. ADMIN VISUALIZA                                              │
│    └─ Acessa /admin/errors                                      │
│    └─ Vê erros em tempo real (stream)                          │
│    └─ Filtra por severity, status, type                        │
│    └─ Atualiza status (investigating, fixed, etc.)             │
│    └─ Faz cleanup (deleta erros antigos)                       │
└─────────────────────────────────────────────────────────────────┘
```

---

## 📊 Severidades

```dart
enum ErrorSeverity {
  low,       // Erros menores, não impactam UX
  medium,    // Network, timeout, parsing
  high,      // Assertion, state errors
  critical,  // Fatal errors, crashes
}
```

**Lógica de Determinação:**

- ✅ `fatal: true` → **critical**
- ✅ Network/Timeout → **medium**
- ✅ AssertionError → **high**
- ✅ State errors → **high**
- ✅ Render errors → **medium**
- ✅ Default → **low**

---

## 🔧 Integração com App

### **1. Main.dart**
```dart
// Inicialização automática
final container = ProviderContainer(
  overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
);

if (firebaseInitialized) {
  final errorCaptureService = container.read(errorCaptureServiceProvider);
  await errorCaptureService.initialize(); // ✅ Setup handlers
}
```

### **2. Router (app_router.dart)**
```dart
// Route tracking automático
final errorTrackingObserver = ErrorTrackingNavigatorObserver(ref);

return GoRouter(
  observers: [analyticsObserver, errorTrackingObserver], // ✅ Auto tracking
);
```

### **3. Auth Provider**
```dart
// User context tracking automático
try {
  final errorService = ref.read(errorCaptureServiceProvider);
  if (user != null) {
    errorService.setUserContext(
      userId: user.id,
      email: user.email,
    );
  }
} catch (_) {}
```

### **4. Plant Details**
```dart
// Plant context tracking
try {
  final errorService = ref.read(errorCaptureServiceProvider);
  errorService.setCurrentPlant(
    id: plant.id,
    name: plant.name,
  );
} catch (_) {}
```

---

## 🧪 Testando

### **1. Teste Manual de Erro**
```dart
// Em qualquer widget
throw Exception('Test error from PlantDetailsPage');
```

### **2. Verificar no Admin**
```
1. Acesse: /admin/errors
2. Filtre por: severity = 'all', status = 'new'
3. Veja o erro capturado com contexto completo!
```

### **3. Exemplo de Context Capturado**
```json
{
  "route": "/plants/abc123",
  "plantId": "abc123",
  "plantName": "Samambaia",
  "taskId": null,
  "userId": "user-xyz789",
  "userEmail": "user@example.com",
  "appVersion": "1.0.0+1",
  "screenSize": "1920x1080",
  "platform": "web",
  "fatal": false,
  "library": "widgets",
  "summary": "Exception: Test error"
}
```

---

## 🎨 Admin Interface

### **AdminErrorsPage (/admin/errors)**

**Features:**
- ✅ Real-time stream de erros
- ✅ Filtros: severity, status, errorType
- ✅ Stats cards: Total, New, Investigating, Fixed
- ✅ Stack trace completo
- ✅ Context rico com todos os dados
- ✅ Ações:
  - Update status (new → investigating → fixed)
  - Delete individual
  - Cleanup (deleta erros > 30 dias)

**Exemplo Visual:**
```
╔════════════════════════════════════════════════════════════════╗
║ 🐛 Error Logs                                                  ║
╠════════════════════════════════════════════════════════════════╣
║ Stats: [Total: 42] [New: 12] [Investigating: 5] [Fixed: 25]   ║
║ Filters: [Severity: All] [Status: All] [Type: All]            ║
╠════════════════════════════════════════════════════════════════╣
║ 🔴 CRITICAL - exception - NEW                                  ║
║ Exception: Failed to load plant data                           ║
║ Route: /plants/123                                             ║
║ User: user@example.com                                         ║
║ Platform: web | Version: 1.0.0                                 ║
║ [View Details] [Update Status] [Delete]                       ║
╚════════════════════════════════════════════════════════════════╝
```

---

## 🚀 Melhorias Futuras

- [ ] **Agrupamento de erros similares** (incrementar occurrences)
- [ ] **Notificação push para admins** (erros critical)
- [ ] **Trending errors dashboard** (erros mais frequentes)
- [ ] **Performance tracking** (app version vs error rate)
- [ ] **User impact analysis** (quantos users afetados)

---

## 📚 Referências

**Core Package:**
- `IErrorLogRepository` - Interface de logging
- `FirebaseErrorLogService` - Implementação Firestore
- `ErrorLogEntity` - Entidade de erro
- `ErrorType` / `ErrorSeverity` / `ErrorLogStatus` - Enums

**App-plantis:**
- `ErrorCaptureService` - Serviço de captura
- `ErrorCaptureProvider` - Riverpod provider
- `ErrorTrackingObserver` - Route tracking
- `AdminErrorsPage` - Interface admin

---

## ✅ Status

- ✅ **ErrorCaptureService** implementado
- ✅ **Provider** criado e gerado
- ✅ **Main.dart** integrado
- ✅ **Router** com observer
- ✅ **Auth tracking** integrado
- ✅ **Plant context tracking** implementado
- ✅ **Admin interface** funcionando
- ✅ **Firestore rules** configuradas

**Pronto para testar em produção! 🎉**
