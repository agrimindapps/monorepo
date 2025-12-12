# 🔐 Auth - Arquitetura

**Feature**: auth  
**Atualizado**: 13/12/2025

---

## 📋 Índice

1. [Visão Geral](#visão-geral)
2. [Arquitetura Clean Architecture](#arquitetura-clean-architecture)
3. [Fluxos de Autenticação](#fluxos-de-autenticação)
4. [Componentes Principais](#componentes-principais)
5. [Gerenciamento de Estado](#gerenciamento-de-estado)
6. [Persistência de Credenciais](#persistência-de-credenciais)
7. [Validação de Dispositivos](#validação-de-dispositivos)
8. [Diagramas](#diagramas)

---

## 🎯 Visão Geral

A feature **Auth** implementa autenticação completa seguindo **Clean Architecture** e **Riverpod** para gerenciamento de estado. Suporta múltiplos métodos de autenticação e integração com Firebase Auth do pacote `core`.

### Métodos de Autenticação Suportados

| Método | Status | Implementação |
|--------|--------|---------------|
| **Email/Senha** | ✅ Ativo | `AuthProvider.login()` |
| **Cadastro** | ✅ Ativo | `AuthProvider.register()` |
| **Anônimo** | ✅ Ativo | `AuthProvider.signInAnonymously()` |
| **Google** | 🚧 Dev | Dialog "Em Desenvolvimento" |
| **Apple** | 🚧 Dev | Dialog "Em Desenvolvimento" |
| **Microsoft** | 🚧 Dev | Dialog "Em Desenvolvimento" |
| **Reset Senha** | ✅ Ativo | `ResetPasswordUseCase` |

---

## 🏗️ Arquitetura Clean Architecture

```
lib/features/auth/
├── data/                          # Camada de Dados
│   └── repositories/
│       └── auth_repository_impl.dart    # Adapter IAuthRepository (core) → AuthRepository (feature)
│
├── domain/                        # Camada de Domínio
│   ├── entities/                 # (Usa UserEntity do core)
│   ├── repositories/
│   │   └── auth_repository.dart  # Interface da feature
│   └── usecases/
│       └── reset_password_usecase.dart
│
├── presentation/                  # Camada de Apresentação
│   ├── managers/                 # Gerenciadores especializados
│   │   ├── auth_dialog_manager.dart           # Dialogs centralizados
│   │   ├── credentials_persistence_manager.dart # Persistência "Lembrar-me"
│   │   ├── auth_submission_manager.dart       # Submissão de formulários
│   │   ├── email_checker_manager.dart         # Validação de email
│   │   └── forgot_password_dialog_manager.dart
│   │
│   ├── pages/
│   │   ├── auth_page.dart        # Página unificada (Login + Cadastro)
│   │   └── register_page.dart    # Página de cadastro standalone
│   │
│   ├── providers/
│   │   └── auth_dialog_managers_providers.dart # Providers Riverpod
│   │
│   └── widgets/                  # Widgets reutilizáveis
│       ├── auth_background_widgets.dart
│       ├── auth_branding_widgets.dart
│       ├── auth_form_widgets.dart
│       ├── device_validation_overlay.dart
│       └── forgot_password_dialog.dart
│
└── utils/                        # Utilitários
    └── auth_utils.dart
```

### Separação Core vs Feature

- **Core (`core` package)**: 
  - `IAuthRepository` - Interface abstrata
  - `LoginUseCase`, `LogoutUseCase` - UseCases genéricos
  - `UserEntity` - Entidade de usuário
  - Firebase Auth implementation

- **Feature (app-plantis)**:
  - `AuthRepository` (interface da feature) → `AuthRepositoryImpl` (adapter)
  - `ResetPasswordUseCase` - UseCase específico da feature
  - `AuthProvider` - Gerenciamento de estado Riverpod

---

## 🔄 Fluxos de Autenticação

### 1️⃣ Login com Email/Senha

```
AuthPage (UI)
    ↓
    └─> _handleEmailLogin()
        ↓
        └─> AuthProvider.login(email, password)
            ↓
            ├─> Validação de dispositivos (DeviceValidationService)
            │   └─> Verifica limite de 3 dispositivos
            ↓
            ├─> LoginUseCase (core)
            │   ├─> IAuthRepository.signInWithEmail()
            │   └─> Firebase Auth signInWithEmailAndPassword()
            ↓
            ├─> CredentialsPersistenceManager.saveRememberedCredentials()
            │   └─> SharedPreferences (se "Lembrar-me" ativo)
            ↓
            ├─> _checkPremiumStatus()
            │   └─> SubscriptionRepository.hasPlantisSubscription()
            ↓
            └─> State atualizado
                ├─> AuthState.currentUser = UserEntity
                ├─> AuthState.isPremium = bool
                └─> AuthStateNotifier.updateUser()
```

**Arquivos envolvidos**:
- UI: `auth_page.dart:_handleEmailLogin()`
- State: `auth_providers.dart:login()`
- UseCase: `core/lib/auth/usecases/login_usecase.dart`
- Repository: `auth_repository_impl.dart` → `core/lib/auth/repositories/i_auth_repository.dart`

---

### 2️⃣ Cadastro (Sign Up)

```
AuthPage (UI) - Tab Register
    ↓
    └─> _handleRegister()
        ↓
        ├─> Validação de campos
        │   ├─> Nome completo (mínimo 3 chars)
        │   ├─> Email válido
        │   ├─> Senha (mínimo 6 chars)
        │   └─> Confirmação de senha
        ↓
        └─> AuthProvider.register(name, email, password)
            ↓
            ├─> Validação de dispositivos
            ↓
            ├─> IAuthRepository.signUpWithEmail()
            │   └─> Firebase Auth createUserWithEmailAndPassword()
            ↓
            ├─> IAuthRepository.updateProfile(displayName: name)
            │   └─> Firebase Auth updateProfile()
            ↓
            ├─> _checkPremiumStatus()
            ↓
            └─> State atualizado + Analytics.logEvent('sign_up')
```

**Validações implementadas**:
- Nome: `validator: validateName` (3+ caracteres)
- Email: `validator: validateEmail` (formato válido)
- Senha: `validator: validatePassword` (6+ caracteres)
- Confirmação: `validator: (value) => value != password ? 'Senhas não conferem' : null`

---

### 3️⃣ Login Anônimo

```
AuthPage (UI)
    ↓
    └─> AnonymousLoginSection
        ↓
        └─> AuthDialogManager.showAnonymousLoginDialog(context)
            ├─> Usuário confirma?
            │   ├─> Sim → continua
            │   └─> Não → cancela
            ↓
            └─> AuthProvider.signInAnonymously()
                ↓
                ├─> IAuthRepository.signInAnonymously()
                │   └─> Firebase Auth signInAnonymously()
                ↓
                ├─> Sem validação de dispositivos
                ├─> Sem persistência de credenciais
                ├─> Sem verificação de premium
                ↓
                └─> State atualizado
                    └─> AuthState.currentUser (isAnonymous = true)
```

**Limitações do Login Anônimo**:
- ⚠️ Dados locais apenas (sem backup em nuvem)
- ⚠️ Sem sincronização entre dispositivos
- ⚠️ Dados perdidos se app for desinstalado
- ⚠️ Sem acesso a recursos premium

---

### 4️⃣ Reset de Senha

```
AuthPage (UI)
    ↓
    └─> ForgotPasswordDialog
        ↓
        ├─> Usuário digita email
        ↓
        └─> AuthProvider.sendPasswordResetEmail(email)
            ↓
            └─> ResetPasswordUseCase
                ├─> AuthRepository (feature).resetPassword()
                │   └─> IAuthRepository (core).sendPasswordResetEmail()
                │       └─> Firebase Auth sendPasswordResetEmail()
                ↓
                ├─> Sucesso: Dialog "Email enviado"
                └─> Erro: Dialog com mensagem de erro
```

**Fluxo completo**:
1. Usuário clica "Esqueceu a senha?"
2. Dialog abre com campo de email
3. Validação de email no client-side
4. Envio para Firebase
5. Firebase envia email com link
6. Usuário clica no link (fora do app)
7. Usuário define nova senha no browser
8. Retorna ao app e faz login

---

### 5️⃣ Logout

```
AuthPage ou Settings
    ↓
    └─> AuthProvider.logout()
        ↓
        ├─> LogoutUseCase (core)
        │   └─> IAuthRepository.signOut()
        │       └─> Firebase Auth signOut()
        ↓
        ├─> CredentialsPersistenceManager (não limpa)
        │   └─> Mantém email se "Lembrar-me" ativo
        ↓
        ├─> AuthState resetado
        │   ├─> currentUser = null
        │   ├─> isPremium = false
        │   └─> errorMessage = null
        ↓
        └─> Analytics.logEvent('logout')
```

---

## 🧩 Componentes Principais

### 1. AuthProvider (State Management)

**Localização**: `core/providers/auth_providers.dart`

**Responsabilidades**:
- Gerenciar estado global de autenticação (`AuthState`)
- Coordenar fluxos de login/register/logout
- Validar dispositivos via `DeviceValidationService`
- Verificar status premium via `SubscriptionRepository`
- Persistir/carregar credenciais via `CredentialsPersistenceManager`
- Comunicar com `AuthStateNotifier` para atualizar UI

**Principais métodos**:
```dart
Future<void> login(String email, String password)
Future<void> register(String name, String email, String password)
Future<void> signInAnonymously()
Future<void> logout()
Future<void> sendPasswordResetEmail(String email)
Future<Either<Failure, void>> updateProfile({String? displayName, String? photoUrl})
```

**Estado gerenciado**:
```dart
class AuthState {
  final UserEntity? currentUser;
  final bool isLoading;
  final String? errorMessage;
  final bool isInitialized;
  final bool isPremium;
  final AuthOperation? currentOperation; // signIn, signUp, logout, anonymous
  final bool isValidatingDevice;
  final String? deviceValidationError;
  final bool deviceLimitExceeded;
}
```

---

### 2. AuthPage (UI)

**Localização**: `presentation/pages/auth_page.dart` (668 linhas)

**Estrutura**:
```dart
AuthPage (ConsumerStatefulWidget)
├─> TabController (Login / Cadastro)
├─> AnimatedBackground (gradiente animado)
├─> AuthBranding (logo + título)
│
├─> Tab 1: Login Form
│   ├─> EmailFormField
│   ├─> PasswordFormField
│   ├─> RememberMeCheckbox
│   ├─> LoginButton
│   ├─> ForgotPasswordButton
│   ├─> SocialLoginSection (Google, Apple, Microsoft)
│   └─> AnonymousLoginSection
│
└─> Tab 2: Register Form
    ├─> NameFormField
    ├─> EmailFormField
    ├─> PasswordFormField
    ├─> ConfirmPasswordFormField
    ├─> RegisterButton
    └─> SocialLoginSection
```

**Mixins utilizados**:
- `TickerProviderStateMixin` - Animações
- `LoadingStateMixin` - Estados de loading
- `AccessibilityFocusMixin` - Acessibilidade

**Recursos avançados**:
- ✅ Animação de background com gradiente
- ✅ Transições suaves entre tabs
- ✅ Loading states por operação
- ✅ Validação de formulários em tempo real
- ✅ Persistência de email ("Lembrar-me")
- ✅ Acessibilidade (focus nodes, semantic labels)
- ✅ Device validation overlay

---

### 3. Managers (Responsabilidade Única)

#### AuthDialogManager

**Localização**: `presentation/managers/auth_dialog_manager.dart`

**Propósito**: Centralizar exibição de dialogs relacionados à autenticação

**Métodos**:
```dart
void showSocialLoginDialog(BuildContext context)        // "Em Desenvolvimento"
Future<bool?> showAnonymousLoginDialog(BuildContext context)  // Confirmação anonymous
void showTermsOfService(BuildContext context)           // Termos de serviço
void showPrivacyPolicy(BuildContext context)            // Política de privacidade
```

#### CredentialsPersistenceManager

**Localização**: `presentation/managers/credentials_persistence_manager.dart`

**Propósito**: Gerenciar persistência de credenciais ("Lembrar-me")

**Métodos**:
```dart
Future<void> saveRememberedCredentials({
  required String email,
  required bool rememberMe,
})

Future<({String? email, bool rememberMe})> loadRememberedCredentials()

Future<void> clearRememberedCredentials()
```

**Storage**: `SharedPreferences`
- Key: `remembered_email`
- Key: `remember_me`

#### AuthSubmissionManager

**Localização**: `presentation/managers/auth_submission_manager.dart`

**Propósito**: Gerenciar submissão de formulários com loading states

#### EmailCheckerManager

**Localização**: `presentation/managers/email_checker_manager.dart`

**Propósito**: Validar formato de email e sugerir correções

---

## 📊 Gerenciamento de Estado

### Hierarquia de Providers

```
┌─────────────────────────────────────────┐
│   authProvider (StateNotifierProvider)  │
│   ↓                                      │
│   Gerencia AuthState global             │
│   ├─> currentUser                        │
│   ├─> isLoading                          │
│   ├─> isPremium                          │
│   └─> errorMessage                       │
└─────────────────────────────────────────┘
           ↓
┌─────────────────────────────────────────┐
│   authStateNotifierProvider             │
│   ↓                                      │
│   Notifica mudanças para toda a UI      │
│   (usado por AppBar, Drawer, etc)       │
└─────────────────────────────────────────┘
           ↓
┌─────────────────────────────────────────┐
│   Providers de Repositories              │
│   ├─> authRepositoryProvider            │
│   ├─> subscriptionRepositoryProvider    │
│   └─> analyticsRepositoryProvider       │
└─────────────────────────────────────────┘
           ↓
┌─────────────────────────────────────────┐
│   Providers de UseCases                  │
│   ├─> loginUseCaseProvider              │
│   ├─> logoutUseCaseProvider             │
│   └─> resetPasswordUseCaseProvider      │
└─────────────────────────────────────────┘
```

### Fluxo de Atualização de Estado

```
User Action (Login button)
    ↓
AuthProvider.login(email, password)
    ↓
state = AuthState(isLoading: true)
    ↓
LoginUseCase.call(params)
    ↓
IAuthRepository.signInWithEmail()
    ↓
Firebase Auth (async)
    ↓
Success: UserEntity
    ↓
state = AuthState(currentUser: user, isLoading: false)
    ↓
AuthStateNotifier.updateUser(user)
    ↓
UI rebuilds (Consumer widgets)
```

---

## 💾 Persistência de Credenciais

### Como funciona "Lembrar-me"

1. **Ao fazer login com checkbox marcado**:
   ```dart
   if (_rememberMe) {
     await _credentialsManager.saveRememberedCredentials(
       email: email,
       rememberMe: true,
     );
   }
   ```

2. **Na inicialização do AuthPage**:
   ```dart
   Future<void> _loadRememberedCredentials() async {
     final credentials = await _credentialsManager.loadRememberedCredentials();
     if (credentials.email != null) {
       setState(() {
         _loginEmailController.text = credentials.email!;
         _rememberMe = credentials.rememberMe;
       });
     }
   }
   ```

3. **Ao desmarcar checkbox**:
   ```dart
   if (!_rememberMe) {
     await _credentialsManager.clearRememberedCredentials();
   }
   ```

### Segurança

⚠️ **IMPORTANTE**: 
- Apenas o **email** é salvo em SharedPreferences
- A **senha NUNCA é persistida**
- Firebase mantém sessão via token (RefreshToken)
- Token é gerenciado automaticamente pelo Firebase SDK

---

## 🔒 Validação de Dispositivos

### Limite de Dispositivos

**Regra**: Máximo de **3 dispositivos ativos** por conta (não-premium)

### Fluxo de Validação

```
Login/Register
    ↓
DeviceValidationService.validateAndRegisterDevice(userId)
    ↓
DeviceRepository.getUserDevices(userId)
    ↓
Count devices onde lastActiveAt > 30 dias
    ↓
Se count >= 3:
    ├─> Show DeviceValidationOverlay
    │   └─> Lista dispositivos ativos
    │   └─> Usuário deve remover um
    └─> Bloqueia login
Senão:
    └─> Registra novo device
        └─> DeviceRepository.registerDevice(DeviceModel)
```

### DeviceValidationOverlay

**UI**: Modal overlay exibido sobre AuthPage

**Funcionalidades**:
- Lista todos os dispositivos ativos (nome, modelo, última atividade)
- Botão "Remover" para cada device
- Explicação sobre limite de dispositivos
- Link para "Assinar Premium" (remove limite)

**Arquivos**:
- `presentation/widgets/device_validation_overlay.dart`
- `features/device_management/`

---

## 📐 Diagramas

### Diagrama de Componentes

```
┌───────────────────────────────────────────────────────────┐
│                         AuthPage                          │
│  ┌─────────────────────────────────────────────────────┐  │
│  │  TabController: Login / Register                     │  │
│  └─────────────────────────────────────────────────────┘  │
│                          ↓                                 │
│  ┌─────────────────┐  ┌─────────────────────────────┐    │
│  │  Login Form     │  │  Register Form              │    │
│  │  - Email        │  │  - Name                     │    │
│  │  - Password     │  │  - Email                    │    │
│  │  - Remember Me  │  │  - Password                 │    │
│  └────────┬────────┘  │  - Confirm Password         │    │
│           │           └──────────┬──────────────────┘    │
│           ↓                      ↓                        │
│  ┌────────────────────────────────────────────────┐      │
│  │         AuthProvider (Riverpod)                │      │
│  │  - login()                                     │      │
│  │  - register()                                  │      │
│  │  - signInAnonymously()                         │      │
│  └────────────────┬───────────────────────────────┘      │
│                   ↓                                       │
│  ┌────────────────────────────────────────────────┐      │
│  │  Managers (Dependency Injection)               │      │
│  │  - AuthDialogManager                           │      │
│  │  - CredentialsPersistenceManager               │      │
│  │  - DeviceValidationService                     │      │
│  └────────────────┬───────────────────────────────┘      │
└───────────────────┼───────────────────────────────────────┘
                    ↓
┌───────────────────────────────────────────────────────────┐
│                 Core Layer (Package)                      │
│  ┌─────────────────────────────────────────────────────┐  │
│  │  UseCases                                           │  │
│  │  - LoginUseCase                                     │  │
│  │  - LogoutUseCase                                    │  │
│  └───────────────────┬─────────────────────────────────┘  │
│                      ↓                                     │
│  ┌─────────────────────────────────────────────────────┐  │
│  │  IAuthRepository (Interface)                        │  │
│  │  - signInWithEmail()                                │  │
│  │  - signUpWithEmail()                                │  │
│  │  - signInAnonymously()                              │  │
│  │  - signOut()                                        │  │
│  └───────────────────┬─────────────────────────────────┘  │
│                      ↓                                     │
│  ┌─────────────────────────────────────────────────────┐  │
│  │  Firebase Auth Implementation                       │  │
│  │  - createUserWithEmailAndPassword()                 │  │
│  │  - signInWithEmailAndPassword()                     │  │
│  │  - signInAnonymously()                              │  │
│  │  - signOut()                                        │  │
│  └─────────────────────────────────────────────────────┘  │
└───────────────────────────────────────────────────────────┘
```

### Diagrama de Sequência: Login

```
User        AuthPage    AuthProvider    LoginUseCase    IAuthRepository    Firebase
 │              │             │                │                │              │
 │──Enter────>│             │                │                │              │
 │  Email+Pass  │             │                │                │              │
 │              │             │                │                │              │
 │──Click────>│             │                │                │              │
 │  Login       │             │                │                │              │
 │              │             │                │                │              │
 │              │──login()──>│                │                │              │
 │              │             │                │                │              │
 │              │             │──call()──────>│                │              │
 │              │             │                │                │              │
 │              │             │                │──signIn()────>│              │
 │              │             │                │                │              │
 │              │             │                │                │──Auth────>│
 │              │             │                │                │              │
 │              │             │                │                │<──Token───┤
 │              │             │                │<──User────────┤              │
 │              │             │<──User────────┤                │              │
 │              │             │                │                │              │
 │              │             │──Update State──│                │              │
 │              │<──Rebuild──┤                │                │              │
 │<──Navigate──┤             │                │                │              │
 │  to Home     │             │                │                │              │
```

---

## 🔧 Configuração e Inicialização

### Providers Setup

**Localização**: `core/providers/repository_providers.dart`

```dart
@riverpod
AuthRepository featureAuthRepository(Ref ref) {
  return AuthRepositoryImpl(
    coreAuthRepository: ref.watch(authRepositoryProvider),
  );
}

@riverpod
ResetPasswordUseCase resetPasswordUseCase(Ref ref) {
  return ResetPasswordUseCase(
    ref.watch(featureAuthRepositoryProvider),
  );
}
```

### Inicialização do App

```dart
// main.dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  
  runApp(
    ProviderScope(
      child: MyApp(),
    ),
  );
}

// app.dart
class MyApp extends ConsumerWidget {
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    
    return authState.when(
      data: (state) {
        if (!state.isInitialized) {
          return SplashScreen();
        }
        
        if (state.isAuthenticated) {
          return HomePage();
        }
        
        return AuthPage();
      },
      loading: () => SplashScreen(),
      error: (e, st) => ErrorPage(),
    );
  }
}
```

---

## 🧪 Testes

**Status atual**: 0% de cobertura

**Testes necessários** (PLT-AUTH-007):
- Unit tests para UseCases
- Unit tests para Repositories (mocks)
- Widget tests para AuthPage
- Integration tests para fluxos completos

---

## 🚀 Melhorias Futuras

### Curto Prazo
- [ ] Implementar login social (Google, Apple, Microsoft)
- [ ] Adicionar biometria (fingerprint, face ID)
- [ ] Melhorar UX de validação de dispositivos
- [ ] Adicionar rate limiting para tentativas de login

### Médio Prazo
- [ ] Refatorar AuthPage (734L) em componentes menores (PLT-AUTH-002)
- [ ] Implementar AuthSubmissionManager (PLT-AUTH-004)
- [ ] Consolidar validações duplicadas (PLT-AUTH-005)
- [ ] Adicionar testes unitários (PLT-AUTH-007)

### Longo Prazo
- [ ] Suporte a Multi-factor Authentication (MFA)
- [ ] Login com código QR
- [ ] Integração com passkeys (WebAuthn)

---

## 📚 Referências

### Arquivos Principais
- `lib/features/auth/presentation/pages/auth_page.dart` (668 linhas)
- `lib/core/providers/auth_providers.dart` (758 linhas)
- `lib/features/auth/data/repositories/auth_repository_impl.dart`
- `lib/features/auth/domain/usecases/reset_password_usecase.dart`

### Pacotes Utilizados
- `firebase_auth` - Autenticação Firebase
- `riverpod` - Gerenciamento de estado
- `shared_preferences` - Persistência local
- `core` (package) - Interfaces e UseCases compartilhados

### Documentação Relacionada
- [TASKS.md](TASKS.md) - Tarefas pendentes
- [SOFT_DELETE_FLOW.md](../plants/SOFT_DELETE_FLOW.md) - Exemplo de doc técnica
- [RECURRING_TASKS.md](../tasks/RECURRING_TASKS.md) - Exemplo de doc de features

---

**Última atualização**: 13/12/2025  
**Mantido por**: Agrimind Solutions
