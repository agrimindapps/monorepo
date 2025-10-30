# 🔐 Feature de Autenticação - app-plantis

Módulo responsável por gerenciar autenticação de usuários no Plantis.

---

## 📂 Estrutura

```
auth/
├── domain/                          # Camada de Domínio (Business Logic)
│   ├── entities/
│   │   └── register_data.dart      # Entity pura para dados de registro
│   └── usecases/
│       └── reset_password_usecase.dart  # Use case para reset de senha
│
├── presentation/                    # Camada de Apresentação (UI)
│   ├── pages/
│   │   ├── auth_page.dart          # Página principal de login
│   │   ├── register_page.dart      # Fluxo de registro
│   │   ├── register_personal_info_page.dart
│   │   ├── register_password_page.dart
│   │   └── web_login_page.dart
│   │
│   ├── providers/
│   │   └── register_notifier.dart  # Estado de registro com Riverpod
│   │
│   └── widgets/
│       ├── auth_form_widgets.dart
│       ├── auth_branding_widgets.dart
│       ├── auth_background_widgets.dart
│       ├── device_validation_overlay.dart
│       └── forgot_password_dialog.dart
│
└── utils/                           # Utilitários
    ├── auth_validators.dart        # Validadores compartilhados
    └── validation_helpers.dart

NOTA: AuthNotifier principal está em:
lib/core/providers/auth_providers.dart
```

---

## 🏗️ Arquitetura Atual

### **Status**: ⚠️ Arquitetura Parcial

A feature atualmente **NÃO possui Data Layer** (violação de Clean Architecture).

#### **Presente**:
- ✅ **Domain Layer**: Entities e alguns Use Cases
- ✅ **Presentation Layer**: Riverpod providers, páginas, widgets
- ✅ **Utils**: Validadores compartilhados

#### **Ausente**:
- ❌ **Data Layer**: Repositories, Datasources, Models
- ❌ **Domain Repositories**: Interfaces abstratas
- ❌ **Use Cases Completos**: Apenas ResetPasswordUseCase existe

---

## 🔄 Fluxos Principais

### **1. Login**
```
AuthPage → AuthNotifier.loginAndNavigate()
  ↓
LoginUseCase (core) → IAuthRepository (core)
  ↓
Device Validation → Background Sync
```

### **2. Registro (Multi-Step)**
```
Step 0: RegisterPage (intro)
  ↓
Step 1: RegisterPersonalInfoPage (nome + email)
  ↓ RegisterNotifier.validateAndProceedPersonalInfo()
  ↓
Step 2: RegisterPasswordPage (senha + confirmação)
  ↓ RegisterNotifier.validateAndProceedPassword()
  ↓
AuthNotifier.register() → IAuthRepository (core)
```

### **3. Reset de Senha**
```
ForgotPasswordDialog
  ↓
ResetPasswordUseCase
  ↓ AuthValidators.isValidEmail()
  ↓
IAuthRepository.sendPasswordResetEmail()
```

---

## 🎯 Padrões de Uso

### **State Management: Riverpod**

#### **Auth State (Principal)**
```dart
// Ler estado
final authState = ref.watch(authProvider);

// Métodos disponíveis
ref.read(authProvider.notifier).login(email, password);
ref.read(authProvider.notifier).logout();
ref.read(authProvider.notifier).register(email, password, name);
ref.read(authProvider.notifier).resetPassword(email);
```

#### **Register State (Formulário)**
```dart
// Ler estado
final registerState = ref.watch(registerNotifierProvider);

// Atualizar campos
ref.read(registerNotifierProvider.notifier).updateName(name);
ref.read(registerNotifierProvider.notifier).updateEmail(email);
ref.read(registerNotifierProvider.notifier).updatePassword(password);

// Navegação entre steps
ref.read(registerNotifierProvider.notifier).nextStep();
ref.read(registerNotifierProvider.notifier).previousStep();

// Validações
ref.read(registerNotifierProvider.notifier).validatePersonalInfo();
ref.read(registerNotifierProvider.notifier).validatePassword();
```

### **Validações: AuthValidators**

```dart
import '../../utils/auth_validators.dart';

// Validar email
if (!AuthValidators.isValidEmail(email)) {
  // email inválido
}

// Validar senha
final passwordError = AuthValidators.validatePassword(
  password,
  isRegistration: true,
);
if (passwordError != null) {
  // senha inválida
}

// Validar nome
final nameError = AuthValidators.validateName(name);
if (nameError != null) {
  // nome inválido
}

// Validar confirmação de senha
final confirmError = AuthValidators.validatePasswordConfirmation(
  password,
  confirmPassword,
);
```

---

## 📊 Estado Atual da Feature

### **Health Score: 7.5/10** ⬆️ (era 6.5/10)

| Aspecto | Score | Comentário |
|---------|-------|------------|
| Presentation Layer | 9/10 | Bem estruturado, usa Riverpod |
| Domain Layer | 5/10 | Falta use cases e interfaces |
| Data Layer | 0/10 | ⚠️ **CRÍTICO**: Não existe (bloqueia 9.0/10) |
| Validações | 10/10 | ✅ Centralizadas e robustas |
| Duplicação | 10/10 | ✅ Eliminada completamente (+4.0 pontos) |
| SOLID | 8.5/10 | Boa aderência (+2.5 pontos) |

**Melhoria Recente**: +1.0 ponto após Quick Wins (eliminação de duplicação + SOLID)

---

## 🔧 Melhorias Recentes

### ✅ **Outubro 2025 - Quick Wins**
1. **Eliminada duplicação crítica**
   - Removidos auth_provider.dart e auth_notifier.dart obsoletos (1573 linhas)
   - Removido register_provider.dart duplicado
   
2. **RegisterData refatorado**
   - Transformado em entity pura (sem lógica de validação)
   - Validação movida para AuthValidators
   
3. **Validações consolidadas**
   - ResetPasswordUseCase usa AuthValidators
   - Consistência 100% no uso de validadores

**Impacto**: Redução de 75% no código, eliminação de toda duplicação

---

## 📋 Roadmap de Melhorias

### **P0 - Crítico** (Próximo Sprint)
- [ ] **Criar Data Layer completo**
  - Datasources (local + remote)
  - Repository implementation
  - Models (UserModel, AuthStateModel)
  - Domain repository interfaces

### **P1 - Importante**
- [ ] Padronizar Either<Failure, T> em todos os métodos
- [ ] Criar use cases completos (Login, Register, SignInAnonymously)
- [ ] Adicionar testes unitários

### **P2 - Bom ter**
- [ ] Melhorar tratamento de erros
- [ ] Adicionar analytics events
- [ ] Documentar fluxos de edge cases

---

## 🧪 Testes

**Status**: ❌ Testes não implementados

### **Cobertura Desejada**:
```
test/features/auth/
├── domain/
│   ├── entities/
│   │   └── register_data_test.dart
│   └── usecases/
│       └── reset_password_usecase_test.dart
│
├── presentation/
│   └── providers/
│       └── register_notifier_test.dart
│
└── utils/
    └── auth_validators_test.dart
```

---

## 📚 Documentação Adicional

- **Análise Completa**: [ANALISE_FEATURE_AUTH.md](./ANALISE_FEATURE_AUTH.md)
- **Melhorias Implementadas**: [MELHORIAS_IMPLEMENTADAS.md](./MELHORIAS_IMPLEMENTADAS.md)
- **Migration Guide**: `/.claude/guides/MIGRATION_PROVIDER_TO_RIVERPOD.md`

---

## 🔗 Dependências

### **Core Package**
```dart
import 'package:core/core.dart';

// Usado:
- IAuthRepository          # Autenticação Firebase
- ISubscriptionRepository  # RevenueCat Premium
- LoginUseCase            # Login com email/senha
- LogoutUseCase           # Logout
- UserEntity              # Entity de usuário
- Either<Failure, T>      # Error handling
```

### **Features Cross-referenciadas**
- `device_management`: Validação de dispositivos
- `premium`: Lógica de assinatura

---

## 💡 Como Adicionar Nova Funcionalidade

### **Exemplo: Adicionar Login Social (Google)**

1. **Criar Use Case** (domain/usecases/):
```dart
class SignInWithGoogleUseCase {
  final IAuthRepository _repository;
  
  Future<Either<Failure, UserEntity>> call() async {
    // Lógica de negócio
    return await _repository.signInWithGoogle();
  }
}
```

2. **Atualizar AuthNotifier** (core/providers/auth_providers.dart):
```dart
Future<void> signInWithGoogle() async {
  state = AsyncData(currentState.copyWith(
    isLoading: true,
    currentOperation: AuthOperation.signIn,
  ));
  
  final result = await _signInWithGoogleUseCase();
  // handle result...
}
```

3. **Adicionar Widget** (presentation/widgets/):
```dart
GoogleSignInButton(
  onPressed: () {
    ref.read(authProvider.notifier).signInWithGoogle();
  },
)
```

4. **Adicionar Testes**:
```dart
test('should sign in with Google successfully', () async {
  // arrange, act, assert
});
```

---

## ⚠️ Avisos Importantes

1. **AuthNotifier Real**: Está em `lib/core/providers/auth_providers.dart`, NÃO em `lib/features/auth/`
2. **Validações**: Sempre use `AuthValidators`, nunca crie validações inline
3. **Either**: Novos métodos devem retornar `Either<Failure, T>`, não `bool`
4. **Data Layer**: Ao criar, seguir padrão de `features/plants/data/`

---

## 📞 Contato & Suporte

Para dúvidas sobre esta feature:
- Ver documentação completa em `ANALISE_FEATURE_AUTH.md`
- Consultar padrões do monorepo em `/CLAUDE.md`
- Verificar migration guide em `/.claude/guides/`

---

**Última Atualização**: 2025-10-29  
**Versão**: v2.0.0 (pós Quick Wins)  
**Status**: 🟡 Em evolução (aguarda Data Layer)
