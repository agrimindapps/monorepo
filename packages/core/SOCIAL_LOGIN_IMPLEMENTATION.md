# 🔐 Implementação de Login Social - Core Package

**Versão:** 1.0.0
**Data:** 2025-10-01
**Status:** ✅ Implementado e Pronto para Uso

---

## 📋 Sumário

O pacote `core` agora fornece **implementação completa de login social** para todos os apps do monorepo, incluindo:

- ✅ **Google Sign In**
- ✅ **Apple Sign In** (obrigatório para conformidade App Store)
- ✅ **Facebook Login**
- ✅ **Login Anônimo**
- ✅ **Account Linking** (vinculação de múltiplos provedores)
- ✅ **Multi-Provider Sign Out**

---

## 🎯 Benefícios

### Para Desenvolvedores:
1. **Reutilização de Código** - Uma implementação para todos os 6 apps
2. **Manutenção Centralizada** - Correções e melhorias em um único lugar
3. **Conformidade Apple** - Sign in with Apple já implementado
4. **Testes Compartilhados** - Injeção de dependências permite mocking
5. **Documentação Completa** - Logs detalhados para debugging

### Para Usuários:
1. **Login Rápido** - Autenticação em 2-3 taps
2. **Múltiplas Opções** - Escolha o provedor preferido
3. **Vinculação de Contas** - Consolidar múltiplos logins
4. **Segurança** - Firebase Auth + OAuth 2.0

---

## 🏗️ Arquitetura

### Estrutura de Arquivos

```
packages/core/lib/src/
├── domain/
│   ├── entities/
│   │   └── user_entity.dart (modelo compartilhado)
│   └── repositories/
│       └── i_auth_repository.dart (interface - ATUALIZADA)
└── infrastructure/
    └── services/
        └── firebase_auth_service.dart (implementação - COMPLETA)
```

### Interface Atualizada

```dart
abstract class IAuthRepository {
  // Login Methods
  Future<Either<Failure, UserEntity>> signInWithEmailAndPassword({...});
  Future<Either<Failure, UserEntity>> signInWithGoogle();          // ✅ NOVO
  Future<Either<Failure, UserEntity>> signInWithApple();           // ✅ NOVO
  Future<Either<Failure, UserEntity>> signInWithFacebook();        // ✅ NOVO
  Future<Either<Failure, UserEntity>> signInAnonymously();

  // Account Linking
  Future<Either<Failure, UserEntity>> linkWithGoogle();            // ✅ NOVO
  Future<Either<Failure, UserEntity>> linkWithApple();             // ✅ NOVO
  Future<Either<Failure, UserEntity>> linkWithFacebook();          // ✅ NOVO
  Future<Either<Failure, UserEntity>> linkWithEmailAndPassword({...});

  // ... outros métodos (logout, password reset, etc.)
}
```

---

## 🚀 Guia de Implementação

### Passo 1: Configuração do Firebase (por app)

Cada app precisa configurar os provedores no Firebase Console:

#### Google Sign In
1. Acesse Firebase Console > Authentication > Sign-in method
2. Ative "Google"
3. Configure SHA-1/SHA-256 para Android
4. Baixe `google-services.json` (Android) e `GoogleService-Info.plist` (iOS)

#### Apple Sign In
1. Acesse Firebase Console > Authentication > Sign-in method
2. Ative "Apple"
3. Configure no Apple Developer Portal:
   - Enable "Sign in with Apple" capability
   - Configure Service ID
   - Add Firebase callback URL
4. Para Web, configure `clientId` e `redirectUri` no código

#### Facebook Login
1. Acesse Facebook Developers Console
2. Crie app e habilite Facebook Login
3. Configure Firebase Console > Authentication > Facebook
4. Adicione App ID e App Secret
5. Configure callback URLs

### Passo 2: Adicionar Dependência no App

No `pubspec.yaml` do app:

```yaml
dependencies:
  core:
    path: ../../packages/core
```

### Passo 3: Implementar nos Apps

#### Para Apps com Provider (app-plantis, app-gasometer, app-petiveti, app-receituagro, app-agrihurbi)

```dart
// features/auth/data/datasources/auth_remote_datasource.dart

import 'package:core/core.dart';

class AuthRemoteDataSource {
  final IAuthRepository _authRepository;

  AuthRemoteDataSource(this._authRepository);

  // Google Sign In
  Future<UserModel> signInWithGoogle() async {
    final result = await _authRepository.signInWithGoogle();

    return result.fold(
      (failure) => throw ServerException(message: failure.message),
      (user) => UserModel.fromEntity(user),
    );
  }

  // Apple Sign In
  Future<UserModel> signInWithApple() async {
    final result = await _authRepository.signInWithApple();

    return result.fold(
      (failure) => throw ServerException(message: failure.message),
      (user) => UserModel.fromEntity(user),
    );
  }

  // Facebook Sign In
  Future<UserModel> signInWithFacebook() async {
    final result = await _authRepository.signInWithFacebook();

    return result.fold(
      (failure) => throw ServerException(message: failure.message),
      (user) => UserModel.fromEntity(user),
    );
  }

  // Account Linking (para upgrade de conta anônima)
  Future<UserModel> linkWithGoogle() async {
    final result = await _authRepository.linkWithGoogle();

    return result.fold(
      (failure) => throw ServerException(message: failure.message),
      (user) => UserModel.fromEntity(user),
    );
  }
}
```

#### Para App com Riverpod (app-taskolist)

```dart
// infrastructure/services/auth_service.dart

import 'package:core/core.dart';

class TaskManagerAuthService {
  final IAuthRepository _authRepository;
  final TaskManagerAnalyticsService _analyticsService;

  TaskManagerAuthService(
    this._authRepository,
    this._analyticsService,
  );

  Future<Either<Failure, UserEntity>> signInWithGoogle() async {
    final result = await _authRepository.signInWithGoogle();

    return result.fold(
      (failure) {
        _analyticsService.logEvent('google_sign_in_failed', {
          'error': failure.message,
        });
        return Left(failure);
      },
      (user) {
        _analyticsService.logEvent('google_sign_in_success', {
          'user_id': user.id,
        });
        return Right(user);
      },
    );
  }

  // Implementar Apple, Facebook, etc. de forma similar
}
```

### Passo 4: UI - Botões de Login Social

```dart
// presentation/pages/login_page.dart

class LoginPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Email/Password form...

        SizedBox(height: 24),

        // Social Login Buttons
        ElevatedButton.icon(
          onPressed: () => _authProvider.signInWithGoogle(),
          icon: Icon(Icons.g_mobiledata),
          label: Text('Continue com Google'),
        ),

        SizedBox(height: 12),

        ElevatedButton.icon(
          onPressed: () => _authProvider.signInWithApple(),
          icon: Icon(Icons.apple),
          label: Text('Continue com Apple'),
        ),

        SizedBox(height: 12),

        ElevatedButton.icon(
          onPressed: () => _authProvider.signInWithFacebook(),
          icon: Icon(Icons.facebook),
          label: Text('Continue com Facebook'),
        ),

        SizedBox(height: 24),

        TextButton(
          onPressed: () => _authProvider.signInAnonymously(),
          child: Text('Continuar sem cadastro'),
        ),
      ],
    );
  }
}
```

---

## 🔗 Account Linking (Vinculação de Contas)

### Caso de Uso: Upgrade de Conta Anônima

```dart
// Usuário fez login anônimo e agora quer criar conta permanente

class AccountUpgradeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('Deseja salvar seu progresso permanentemente?'),

        ElevatedButton(
          onPressed: () async {
            // Link com Google
            final result = await authRepository.linkWithGoogle();
            result.fold(
              (failure) => showError(failure.message),
              (user) => navigateToHome(),
            );
          },
          child: Text('Vincular com Google'),
        ),

        ElevatedButton(
          onPressed: () async {
            // Link com Apple
            final result = await authRepository.linkWithApple();
            result.fold(
              (failure) => showError(failure.message),
              (user) => navigateToHome(),
            );
          },
          child: Text('Vincular com Apple'),
        ),

        // Ou vincular com email/senha
        ElevatedButton(
          onPressed: () async {
            final result = await authRepository.linkWithEmailAndPassword(
              email: emailController.text,
              password: passwordController.text,
              displayName: nameController.text,
            );
            result.fold(
              (failure) => showError(failure.message),
              (user) => navigateToHome(),
            );
          },
          child: Text('Criar conta com Email'),
        ),
      ],
    );
  }
}
```

### Detectar Usuário Anônimo

```dart
class AuthProvider extends ChangeNotifier {
  UserEntity? _currentUser;

  bool get isAnonymous => _currentUser?.provider == AuthProvider.anonymous;
  bool get canUpgrade => isAnonymous;

  Future<void> showUpgradeDialog() async {
    if (canUpgrade) {
      // Show dialog to link account
    }
  }
}
```

---

## 🛡️ Tratamento de Erros

O serviço retorna mensagens de erro específicas em português:

### Erros Comuns e Mensagens

| Situação | Mensagem |
|----------|----------|
| Usuário cancela login | "Login cancelado pelo usuário" |
| Email já em uso | "O email já está em uso" |
| Conta já vinculada | "Conta já vinculada com [provedor]" |
| Provedor não disponível | "Login com Apple não disponível neste dispositivo" |
| Credencial em uso | "Esta conta [provedor] já está em uso por outro usuário" |
| Token inválido | "Falha ao obter credenciais do [provedor]" |

### Exemplo de Tratamento

```dart
Future<void> handleGoogleSignIn() async {
  setState(() => isLoading = true);

  final result = await _authRepository.signInWithGoogle();

  result.fold(
    (failure) {
      setState(() => isLoading = false);

      // Mensagens já estão em português
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(failure.message)),
      );
    },
    (user) {
      setState(() => isLoading = false);

      // Navegar para home
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => HomePage()),
      );
    },
  );
}
```

---

## 📊 Logs e Debugging

O serviço fornece logs detalhados (apenas em modo debug):

```
🔄 Firebase: Attempting Google Sign In...
🔄 Firebase: Google user obtained, getting authentication...
🔄 Firebase: Signing in with Google credential...
✅ Firebase: Google Sign In successful - User: uid_123456
```

Em caso de erro:

```
❌ Firebase: FirebaseAuthException - email-already-in-use: The email address is already in use
```

### Habilitar Logs

```dart
// main.dart
void main() {
  if (kDebugMode) {
    // Logs já estão habilitados automaticamente
  }
  runApp(MyApp());
}
```

---

## ✅ Checklist de Conformidade Apple

Para passar na App Store Review, certifique-se:

- [ ] Se tem Google/Facebook, **DEVE** ter Apple Sign In
- [ ] Apple Sign In funciona em iOS 13+ e macOS 10.15+
- [ ] Botão "Sign in with Apple" tem design correto (guidelines da Apple)
- [ ] Login anônimo disponível se social é método primário
- [ ] Exclusão de conta implementada in-app
- [ ] PrivacyInfo.xcprivacy manifest configurado

---

## 🧪 Testes

### Testes Unitários

```dart
// test/auth_service_test.dart

void main() {
  late FirebaseAuthService authService;
  late MockFirebaseAuth mockAuth;
  late MockGoogleSignIn mockGoogle;

  setUp(() {
    mockAuth = MockFirebaseAuth();
    mockGoogle = MockGoogleSignIn();

    authService = FirebaseAuthService(
      firebaseAuth: mockAuth,
      googleSignIn: mockGoogle,
    );
  });

  group('Google Sign In', () {
    test('should return UserEntity on successful sign in', () async {
      // Arrange
      when(mockGoogle.signIn()).thenAnswer((_) async => mockGoogleUser);
      when(mockAuth.signInWithCredential(any))
          .thenAnswer((_) async => mockUserCredential);

      // Act
      final result = await authService.signInWithGoogle();

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (l) => fail('Should not return Left'),
        (user) => expect(user.email, 'test@example.com'),
      );
    });

    test('should return AuthFailure when user cancels', () async {
      // Arrange
      when(mockGoogle.signIn()).thenAnswer((_) async => null);

      // Act
      final result = await authService.signInWithGoogle();

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure.message, contains('cancelado')),
        (r) => fail('Should not return Right'),
      );
    });
  });
}
```

---

## 📝 Notas de Implementação

### Apple Sign In - Configuração Web

Se seu app roda na web, você **DEVE** configurar no código:

```dart
// Localização: firebase_auth_service.dart, linha 191 e 741

// SUBSTITUA:
clientId: 'your.bundle.id',
// POR:
clientId: 'com.seuapp.bundleid',  // Seu Bundle ID real

// SUBSTITUA:
redirectUri: Uri.parse('https://your-project.firebaseapp.com/__/auth/handler'),
// POR:
redirectUri: Uri.parse('https://seu-projeto.firebaseapp.com/__/auth/handler'),
```

### Facebook Login - Permissões

Por padrão, o serviço solicita apenas permissão de `email`. Para solicitar mais:

```dart
// Se precisar de mais dados (foto, etc.), modifique no construtor:
FirebaseAuthService({
  FacebookAuth? facebookAuth,
}) : _facebookAuth = facebookAuth ?? FacebookAuth.instance;

// E use:
final result = await _facebookAuth.login(
  permissions: ['email', 'public_profile'],  // Adicione permissões
);
```

### Sign Out Multi-Provider

O método `signOut()` já faz logout de **todos** os provedores automaticamente:

```dart
await authRepository.signOut();
// Faz logout de: Firebase + Google + Facebook simultaneamente
```

---

## 🚨 Troubleshooting

### Problema: "Google Sign In não funciona no Android"

**Solução:**
1. Configure SHA-1 e SHA-256 no Firebase Console
2. Baixe novo `google-services.json`
3. Adicione ao app: `android/app/google-services.json`
4. Reconstrua o app

### Problema: "Apple Sign In retorna erro 1000"

**Solução:**
1. Verifique que capability "Sign in with Apple" está habilitada no Xcode
2. Confirme que Bundle ID corresponde ao configurado no Firebase
3. Para Web, verifique `clientId` e `redirectUri`

### Problema: "Facebook Login não abre navegador"

**Solução:**
1. Verifique que `facebook_app_id` está configurado no `AndroidManifest.xml`
2. iOS: Configure `CFBundleURLSchemes` no `Info.plist`
3. Confirme App ID no Facebook Developers Console

---

## 📚 Recursos Adicionais

- [Firebase Auth Documentation](https://firebase.google.com/docs/auth)
- [Google Sign In Flutter](https://pub.dev/packages/google_sign_in)
- [Sign in with Apple Flutter](https://pub.dev/packages/sign_in_with_apple)
- [Apple Sign In Guidelines](https://developer.apple.com/sign-in-with-apple/)
- [Facebook Login for Android](https://developers.facebook.com/docs/facebook-login/android)

---

## 🔄 Atualizações Futuras

Planejado para versão 1.1:

- [ ] Biometric reauthentication antes de operações sensíveis
- [ ] Twitter/X Sign In
- [ ] Microsoft Account Sign In
- [ ] Phone Number Authentication
- [ ] Email Link Authentication (passwordless)

---

## 📞 Suporte

Se encontrar problemas ou tiver dúvidas:

1. Verifique logs no console (modo debug)
2. Consulte seção Troubleshooting acima
3. Revise configuração no Firebase Console
4. Crie issue no repositório do monorepo

---

**Última Atualização:** 2025-10-01
**Mantido por:** Equipe Agrimind Soluções
**Status:** ✅ Produção-Ready
