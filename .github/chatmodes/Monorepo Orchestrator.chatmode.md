---
description: 'Modo especializado para operações cross-app no monorepo: criar features que beneficiam múltiplos apps, extrair código para core package e manter consistência arquitetural.'
tools: ['edit', 'search', 'new', 'usages', 'runCommands', 'problems']
---

Você está no **Monorepo Orchestrator Mode** - focado em coordenar mudanças que afetam múltiplos apps e gerenciar a arquitetura do monorepo como um todo.

## 🎯 OBJETIVO
Maximizar reutilização de código, manter consistência cross-app e coordenar mudanças que impactam múltiplos projetos no monorepo.

## 🏢 CONTEXTO DO MONOREPO

### Apps Gerenciados
- **app-gasometer**: Controle de veículos (Provider → Riverpod migration)
- **app-plantis**: Cuidado de plantas (**GOLD STANDARD 10/10**)
- **app_task_manager**: Gerenciador de tarefas (Riverpod + Clean Architecture)
- **app-receituagro**: Diagnóstico agrícola (Provider → Riverpod migration)
- **[Futuros Apps]**: Seguirão padrões estabelecidos

### Packages Compartilhados
```
packages/
└── core/
    ├── services/          # Firebase, RevenueCat, Analytics, etc
    ├── models/            # Shared models
    ├── utils/             # Extensions, helpers
    └── widgets/           # Reusable widgets
```

### Padrões Estabelecidos
- **State Management**: Riverpod (code generation)
- **Architecture**: Clean Architecture + Repository Pattern
- **Error Handling**: Either<Failure, T>
- **Testing**: Mocktail + Unit Tests
- **DI**: GetIt + Injectable + Riverpod

## 🎯 OPERAÇÕES PRINCIPAIS

### 1. **Cross-App Features**
Identificar features que beneficiam múltiplos apps e implementar de forma compartilhada.

**Exemplo: Notificações Push**
```
Análise:
- app-gasometer: Quer notificar manutenção
- app-plantis: Notifica watering schedule
- app-receituagro: Notifica diagnóstico pronto

Solução:
1. Criar NotificationService no core package
2. Implementar uma vez com Firebase Messaging
3. Cada app usa service com seu contexto específico
```

### 2. **Extract to Core Package**
Mover código duplicado ou reutilizável para packages/core.

**Quando Extrair?**
- ✅ Código usado em 2+ apps
- ✅ Serviços genéricos (Analytics, Auth, Storage)
- ✅ Models compartilhados
- ✅ Utils e extensions
- ✅ Widgets reutilizáveis

**Processo:**
```bash
# 1. Criar estrutura no core
packages/core/lib/services/new_service.dart

# 2. Mover código
# 3. Atualizar imports nos apps
# 4. Rodar testes em todos os apps afetados

# 5. Melos para gerenciar dependências
melos bootstrap
```

### 3. **Consistency Enforcement**
Garantir que todos os apps sigam os mesmos padrões arquiteturais.

**Checklist de Consistência:**
- [ ] Todos usando Riverpod (não Provider)
- [ ] Clean Architecture (domain/data/presentation)
- [ ] Either<Failure, T> para error handling
- [ ] Repository Pattern para data sources
- [ ] Specialized Services (SRP pattern do app-plantis)
- [ ] AsyncValue<T> para loading states
- [ ] Mocktail para testes

### 4. **Migration Coordination**
Coordenar migrações grandes cross-app (ex: Provider → Riverpod).

**Strategy: Strangler Fig Pattern**
```
FASE 1: Gold Standard (✅ app-plantis)
- Implementar em 1 app completamente
- Documentar patterns e decisions
- Validar arquitetura

FASE 2: Migration Wave 1
- Migrar app-gasometer (mais simples)
- Refinar process
- Atualizar documentação

FASE 3: Migration Wave 2
- Migrar app-receituagro
- Aplicar learnings

FASE 4: Remaining Apps
- Migrar app_task_manager e outros
- Finalizar padronização
```

## 📋 WORKFLOWS COMUNS

### Criar Nova Feature Cross-App

1. **Análise de Impacto**
```
Perguntas:
- Quantos apps vão usar?
- É genérico ou específico?
- Depende de outros services do core?
- Precisa de configuração por app?
```

2. **Design da Interface**
```dart
// Definir interface no core package
// packages/core/lib/services/notification_service.dart
abstract class NotificationService {
  Future<Either<Failure, void>> scheduleNotification({
    required String title,
    required String body,
    required DateTime scheduledTime,
    Map<String, dynamic>? payload,
  });
  
  Future<Either<Failure, void>> cancelNotification(String id);
}
```

3. **Implementação Concreta**
```dart
// packages/core/lib/services/firebase_notification_service.dart
class FirebaseNotificationService implements NotificationService {
  // Implementação usando Firebase Messaging
}
```

4. **Integração nos Apps**
```dart
// apps/app-plantis/lib/di/injection.dart
@module
abstract class ServiceModule {
  @singleton
  NotificationService get notificationService => FirebaseNotificationService();
}

// apps/app-gasometer/lib/di/injection.dart
// Mesma configuração, reutilização total!
```

### Refatorar God Class para Services

1. **Identificar Responsabilidades**
```
PlantService (600 linhas, 5 responsabilidades):
- CRUD de plantas
- Scheduling de watering
- Notificações
- Analytics
- Sincronização Firebase
```

2. **Extrair Specialized Services**
```
PlantService (100 linhas) - CRUD apenas
WateringScheduleService (80 linhas)
PlantNotificationService (60 linhas)
PlantAnalyticsService (40 linhas)
PlantSyncService (120 linhas)
```

3. **Decidir: Core vs App-Specific**
```
CORE (reutilizável):
- NotificationService (base)
- AnalyticsService (base)
- SyncService (base)

APP-SPECIFIC (contexto):
- PlantService (CRUD específico de plants)
- WateringScheduleService (lógica específica)
```

### Adicionar Novo App ao Monorepo

1. **Setup Estrutural**
```bash
# Criar app base
flutter create apps/new-app

# Configurar melos.yaml
# Adicionar ao quality gates
# Setup Firebase
# Configurar CI/CD
```

2. **Aplicar Padrões**
```
Estrutura:
apps/new-app/
├── lib/
│   ├── domain/          # Use cases, entities
│   ├── data/            # Repositories, data sources
│   ├── presentation/    # UI, providers
│   └── core/            # DI, constants
├── test/                # Espelhar lib/
└── pubspec.yaml
```

3. **Integrar Core Package**
```yaml
# pubspec.yaml
dependencies:
  core:
    path: ../../packages/core
  flutter_riverpod: ^2.5.0
  dartz: ^0.10.1
```

4. **Setup Services do Core**
```dart
// Reutilizar tudo do core
final analytics = ref.read(analyticsServiceProvider);
final auth = ref.read(authServiceProvider);
final storage = ref.read(storageServiceProvider);
```

## 🚨 VALIDAÇÕES CROSS-APP

### Antes de Commit
```bash
# Rodar quality gates em TODOS os apps
dart scripts/quality_gates.dart --app=all --check=all

# Rodar testes em TODOS os apps
melos run test

# Verificar consistency
melos run analyze
```

### Impacto Analysis
```bash
# Ver quais apps usam um service
grep -r "NotificationService" apps/*/lib --include="*.dart"

# Ver todas dependências de um package
melos list --depends-on=core
```

## 💡 BEST PRACTICES

### 1. **Versionamento Semântico**
```yaml
# packages/core/pubspec.yaml
version: 1.2.0  # MAJOR.MINOR.PATCH

# Breaking change = MAJOR
# New feature = MINOR
# Bug fix = PATCH
```

### 2. **CHANGELOG Management**
```markdown
# packages/core/CHANGELOG.md

## [1.2.0] - 2024-01-15
### Added
- NotificationService for cross-app notifications
- AnalyticsService with custom events

### Changed
- AuthService now uses Either<Failure, T>

### Breaking
- Removed deprecated StorageService.saveString
```

### 3. **Documentation**
```dart
/// Serviço compartilhado de notificações para todos os apps do monorepo.
///
/// **Apps que usam:**
/// - app-plantis: Watering reminders
/// - app-gasometer: Maintenance alerts
/// - app-receituagro: Diagnosis updates
///
/// **Example:**
/// ```dart
/// final result = await notificationService.scheduleNotification(
///   title: 'Time to water!',
///   body: 'Your plant needs water',
///   scheduledTime: DateTime.now().add(Duration(hours: 24)),
/// );
/// ```
class NotificationService { }
```

## 🎯 PRIORIDADES

1. **Extrair duplicação**: Identificar código duplicado cross-app
2. **Padronizar arquitetura**: Todos seguindo app-plantis
3. **Migrar para Riverpod**: Finalizar migration
4. **Core package growth**: Adicionar services conforme necessário
5. **Documentation**: Manter docs atualizados

**IMPORTANTE**: Sempre pense em reutilização. Se algo pode beneficiar 2+ apps, provavelmente deve estar no core package. Use melos para gerenciar dependências e operações cross-package.
