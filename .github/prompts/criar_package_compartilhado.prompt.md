---
mode: agent
---
# Criar Package Compartilhado no Monorepo

Você será guiado na criação de um package compartilhado no diretório `packages/` para reutilização cross-app.

## 🎯 QUANDO CRIAR UM PACKAGE

### ✅ Crie quando:
- Código usado em 2+ apps
- Services genéricos e reutilizáveis
- Widgets compartilhados
- Utils e extensions comuns
- Business logic cross-app

### ❌ Não crie quando:
- Código específico de um app apenas
- Lógica de UI muito customizada
- Features experimentais não validadas

## 📋 TIPOS DE PACKAGE

### 1. **Core Package** (já existe)
```
packages/core/
├── lib/
│   ├── services/      # Firebase, Analytics, Auth
│   ├── models/        # Shared models
│   ├── utils/         # Extensions, helpers
│   └── widgets/       # Reusable widgets
```

### 2. **Feature Package** (novo)
```
packages/[feature-name]/
├── lib/
│   ├── domain/        # Business logic
│   ├── data/          # Implementation
│   └── presentation/  # UI components
```

### 3. **UI Package** (novo)
```
packages/design_system/
├── lib/
│   ├── theme/         # Colors, typography
│   ├── widgets/       # Custom widgets
│   └── animations/    # Shared animations
```

## 🛠️ PROCESSO DE CRIAÇÃO

### Passo 1: Criar Estrutura Base

```bash
# Navegar para packages/
cd packages/

# Criar novo package
mkdir my_package
cd my_package

# Criar estrutura
mkdir -p lib/src
touch lib/my_package.dart
touch pubspec.yaml
touch README.md
touch CHANGELOG.md
touch LICENSE
```

### Passo 2: Configurar pubspec.yaml

```yaml
# packages/my_package/pubspec.yaml
name: my_package
description: A shared package for [describe purpose]
version: 1.0.0
publish_to: none  # Private package

environment:
  sdk: '>=3.0.0 <4.0.0'
  flutter: ">=3.10.0"

dependencies:
  flutter:
    sdk: flutter
  # Adicionar dependências necessárias
  dartz: ^0.10.1
  equatable: ^2.0.5

dev_dependencies:
  flutter_test:
    sdk: flutter
  mocktail: ^1.0.0
  flutter_lints: ^3.0.0

flutter:
  # Se tiver assets
  # assets:
  #   - assets/images/
```

### Passo 3: Criar Arquivo Principal

```dart
// lib/my_package.dart
library my_package;

// Export principais classes públicas
export 'src/services/my_service.dart';
export 'src/models/my_model.dart';
export 'src/utils/extensions.dart';

// Não exportar classes internas (_private.dart)
```

### Passo 4: Implementar Conteúdo

```dart
// lib/src/services/my_service.dart
import 'package:dartz/dartz.dart';

/// Service description
///
/// **Used by:**
/// - app-plantis: [describe usage]
/// - app-gasometer: [describe usage]
///
/// **Example:**
/// ```dart
/// final service = MyService();
/// final result = await service.doSomething();
/// result.fold(
///   (failure) => handleError(failure),
///   (data) => processData(data),
/// );
/// ```
class MyService {
  Future<Either<Failure, Data>> doSomething() async {
    try {
      // Implementation
      return Right(data);
    } catch (e) {
      return Left(ServiceFailure(e.toString()));
    }
  }
}
```

### Passo 5: Adicionar ao Melos

```yaml
# melos.yaml (root do monorepo)
name: monorepo
packages:
  - apps/**
  - packages/**  # Já inclui todos packages

scripts:
  # Adicionar scripts específicos se necessário
  test:my_package:
    run: melos exec -c 1 --scope="my_package" -- flutter test
    description: Run tests for my_package
```

### Passo 6: Documentar no README

```markdown
# My Package

Brief description of what this package does.

## Features

- ✅ Feature 1
- ✅ Feature 2
- ✅ Feature 3

## Usage

\```dart
import 'package:my_package/my_package.dart';

// Example usage
final service = MyService();
final result = await service.doSomething();
\```

## Used By

- **app-plantis**: [describe how it's used]
- **app-gasometer**: [describe how it's used]

## Installation

Add to your app's `pubspec.yaml`:

\```yaml
dependencies:
  my_package:
    path: ../../packages/my_package
\```

## API Documentation

See [API.md](API.md) for detailed API reference.

## Testing

\```bash
flutter test
\```

## Changelog

See [CHANGELOG.md](CHANGELOG.md) for version history.
```

### Passo 7: Integrar nos Apps

```yaml
# apps/app-plantis/pubspec.yaml
dependencies:
  flutter:
    sdk: flutter
  my_package:
    path: ../../packages/my_package
```

```dart
// apps/app-plantis/lib/main.dart
import 'package:my_package/my_package.dart';

void main() {
  final service = MyService();
  // Use service
}
```

## 📊 EXEMPLOS PRÁTICOS

### Exemplo 1: Notification Package

```
packages/notifications/
├── lib/
│   ├── notifications.dart              # Main export
│   └── src/
│       ├── services/
│       │   └── notification_service.dart
│       ├── models/
│       │   └── notification.dart
│       └── providers/
│           └── notification_provider.dart
├── test/
│   └── services/
│       └── notification_service_test.dart
├── pubspec.yaml
└── README.md
```

```dart
// lib/src/services/notification_service.dart
abstract class NotificationService {
  Future<Either<Failure, void>> scheduleNotification({
    required String title,
    required String body,
    required DateTime scheduledTime,
  });
  
  Future<Either<Failure, void>> cancelNotification(String id);
  Future<Either<Failure, List<Notification>>> getPendingNotifications();
}

class FirebaseNotificationService implements NotificationService {
  // Implementation using Firebase Messaging
}
```

### Exemplo 2: Analytics Package

```
packages/analytics/
├── lib/
│   ├── analytics.dart
│   └── src/
│       ├── services/
│       │   ├── analytics_service.dart
│       │   └── event_tracker.dart
│       └── models/
│           └── analytics_event.dart
├── test/
└── pubspec.yaml
```

```dart
// lib/src/services/analytics_service.dart
class AnalyticsService {
  Future<void> logEvent(String name, Map<String, dynamic> params) async {
    // Firebase Analytics integration
  }
  
  Future<void> setUserId(String userId) async { }
  Future<void> setUserProperty(String name, String value) async { }
}
```

### Exemplo 3: Design System Package

```
packages/design_system/
├── lib/
│   ├── design_system.dart
│   └── src/
│       ├── theme/
│       │   ├── app_theme.dart
│       │   ├── colors.dart
│       │   └── typography.dart
│       ├── widgets/
│       │   ├── buttons/
│       │   ├── cards/
│       │   └── inputs/
│       └── constants/
│           └── spacing.dart
├── pubspec.yaml
└── README.md
```

```dart
// lib/src/theme/app_theme.dart
class AppTheme {
  static ThemeData lightTheme = ThemeData(
    primarySwatch: AppColors.primary,
    textTheme: AppTypography.textTheme,
    // ...
  );
  
  static ThemeData darkTheme = ThemeData(
    // ...
  );
}

// lib/src/widgets/buttons/primary_button.dart
class PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  
  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
  });
  
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      child: Text(label),
    );
  }
}
```

## 🎯 VERSIONAMENTO SEMÂNTICO

```yaml
# pubspec.yaml
version: 1.2.3  # MAJOR.MINOR.PATCH
```

### Quando incrementar:
- **MAJOR** (1.x.x): Breaking changes
- **MINOR** (x.2.x): New features (backward compatible)
- **PATCH** (x.x.3): Bug fixes

### CHANGELOG.md
```markdown
# Changelog

## [1.2.0] - 2024-01-15

### Added
- NotificationService with scheduling support
- Support for custom notification sounds

### Changed
- Improved error handling in analytics

### Fixed
- Memory leak in event tracking

### Breaking
- Removed deprecated `oldMethod()` - use `newMethod()` instead

## [1.1.0] - 2024-01-01
...
```

## ✅ CHECKLIST DE CRIAÇÃO

- [ ] Estrutura de diretórios criada
- [ ] pubspec.yaml configurado
- [ ] README.md documentado
- [ ] CHANGELOG.md iniciado
- [ ] Exports no arquivo principal
- [ ] Testes unitários implementados
- [ ] Integrado ao melos.yaml
- [ ] Testado em pelo menos 2 apps
- [ ] Documentação de API completa
- [ ] Exemplos de uso no README

## 🚨 BEST PRACTICES

### 1. **API Pública Clara**
```dart
// ✅ Export apenas o necessário
library my_package;

export 'src/services/public_service.dart';
export 'src/models/public_model.dart';

// ❌ Não exportar internos
// export 'src/services/_private_helper.dart';
```

### 2. **Documentação Completa**
```dart
/// Complete description with examples
///
/// **Parameters:**
/// - [param1]: Description
/// - [param2]: Description
///
/// **Returns:**
/// Description of return value
///
/// **Throws:**
/// - [SomeException]: When something happens
///
/// **Example:**
/// ```dart
/// final result = await service.method(param1, param2);
/// ```
class MyService { }
```

### 3. **Sem Dependências Pesadas**
- Evitar dependências grandes se possível
- Permitir que apps escolham implementações
- Usar interfaces/abstrações

### 4. **Testabilidade**
- Sempre fornecer interfaces/abstrações
- Facilitar mocking
- Incluir testes exemplo

## 🎯 MIGRAÇÃO PARA PACKAGE

### Identificar Código Duplicado
```bash
# Encontrar código similar cross-app
grep -r "class AnalyticsService" apps/*/lib --include="*.dart"

# Se encontrar em 2+ apps, considere extrair para package
```

### Processo de Extração
1. Criar package novo
2. Mover código para package
3. Atualizar imports nos apps
4. Rodar testes em todos apps
5. Remover código duplicado

```bash
# Após criar package, atualizar dependências
melos bootstrap

# Rodar testes em todos apps
melos run test

# Validar quality gates
dart scripts/quality_gates.dart --app=all
```

Bom desenvolvimento de packages! 📦
