# Documentação do `FirebaseAuthService`

O `FirebaseAuthService` é uma implementação concreta do repositório de autenticação, utilizando o Firebase Authentication. Ele oferece uma interface abrangente para gerenciar usuários, incluindo registro, login, logout, redefinição de senha, atualização de perfil e vinculação de contas, além de lidar com diferentes provedores de autenticação.

## 1. Propósito

O principal objetivo do `FirebaseAuthService` é:
- Fornecer uma camada de abstração para as operações de autenticação, desacoplando a lógica de negócio do Firebase Auth.
- Gerenciar o ciclo de vida do usuário (autenticação, sessão).
- Oferecer métodos para diferentes fluxos de autenticação (email/senha, anônimo, Google, Apple).
- Mapear os objetos de usuário do Firebase para entidades de domínio (`UserEntity`).
- Tratar e traduzir erros do Firebase Auth para mensagens amigáveis ao usuário.

## 2. Inicialização

O `FirebaseAuthService` pode ser instanciado diretamente. Ele utiliza a instância padrão do `FirebaseAuth`.

```dart
import 'package:core/src/infrastructure/services/firebase_auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Instância padrão
final authService = FirebaseAuthService();

// Ou, para testes ou injeção de dependência, você pode passar uma instância mock/real
final authServiceWithMock = FirebaseAuthService(
  firebaseAuth: FirebaseAuth.instance, // ou um mock
);
```

## 3. Funcionalidades Principais

Todos os métodos que realizam operações de autenticação retornam um `Future<Either<Failure, T>>`, onde `T` pode ser `UserEntity` em caso de sucesso ou `void` para operações sem retorno específico, e `Failure` em caso de erro.

### 3.1. `currentUser`

Um `Stream` que emite o `UserEntity` atual sempre que o estado de autenticação do usuário muda (login, logout, registro).

Exemplo:

```dart
authService.currentUser.listen((user) {
  if (user != null) {
    print('Usuário logado: ${user.email}');
  } else {
    print('Nenhum usuário logado.');
  }
});
```

### 3.2. `isLoggedIn`

Retorna um `Future<bool>` indicando se há um usuário autenticado no momento.

Exemplo:

```dart
bool loggedIn = await authService.isLoggedIn;
if (loggedIn) {
  print('Usuário está logado.');
}
```

### 3.3. `signInWithEmailAndPassword({required String email, required String password})`

Autentica um usuário com email e senha.

Exemplo:

```dart
final result = await authService.signInWithEmailAndPassword(
  email: 'test@example.com',
  password: 'password123',
);

result.fold(
  (failure) => print('Erro de login: ${failure.message}'),
  (user) => print('Login bem-sucedido: ${user.email}'),
);
```

### 3.4. `signUpWithEmailAndPassword({required String email, required String password, required String displayName})`

Cria uma nova conta de usuário com email, senha e nome de exibição.

Exemplo:

```dart
final result = await authService.signUpWithEmailAndPassword(
  email: 'newuser@example.com',
  password: 'strongpassword',
  displayName: 'Novo Usuário',
);

result.fold(
  (failure) => print('Erro de registro: ${failure.message}'),
  (user) => print('Registro bem-sucedido: ${user.email}'),
);
```

### 3.5. `signInWithGoogle()`

**TODO:** Implementar login com Google. Requer o pacote `google_sign_in`.

### 3.6. `signInWithApple()`

**TODO:** Implementar login com Apple. Requer o pacote `sign_in_with_apple`.

### 3.7. `signInAnonymously()`

Autentica um usuário anonimamente. Útil para permitir que usuários explorem o aplicativo antes de criar uma conta.

Exemplo:

```dart
final result = await authService.signInAnonymously();

result.fold(
  (failure) => print('Erro de login anônimo: ${failure.message}'),
  (user) => print('Login anônimo bem-sucedido: ${user.id}'),
);
```

### 3.8. `signOut()`

Desloga o usuário atualmente autenticado.

Exemplo:

```dart
final result = await authService.signOut();

result.fold(
  (failure) => print('Erro ao fazer logout: ${failure.message}'),
  (_) => print('Logout bem-sucedido.'),
);
```

### 3.9. `sendPasswordResetEmail({required String email})`

Envia um email de redefinição de senha para o email fornecido.

Exemplo:

```dart
final result = await authService.sendPasswordResetEmail(email: 'user@example.com');

result.fold(
  (failure) => print('Erro ao enviar email de redefinição: ${failure.message}'),
  (_) => print('Email de redefinição enviado com sucesso.'),
);
```

### 3.10. `updateProfile({String? displayName, String? photoUrl})`

Atualiza o nome de exibição e/ou a URL da foto do perfil do usuário atual.

Exemplo:

```dart
final result = await authService.updateProfile(
  displayName: 'Novo Nome',
  photoUrl: 'https://example.com/new_photo.jpg',
);

result.fold(
  (failure) => print('Erro ao atualizar perfil: ${failure.message}'),
  (user) => print('Perfil atualizado: ${user.displayName}'),
);
```

### 3.11. `updateEmail({required String newEmail})`

Atualiza o email do usuário. Requer que o usuário esteja logado recentemente.

Exemplo:

```dart
final result = await authService.updateEmail(newEmail: 'newemail@example.com');

result.fold(
  (failure) => print('Erro ao atualizar email: ${failure.message}'),
  (user) => print('Email atualizado: ${user.email}'),
);
```

### 3.12. `updatePassword({required String currentPassword, required String newPassword})`

Atualiza a senha do usuário. Requer que o usuário seja reautenticado com a senha atual.

Exemplo:

```dart
final result = await authService.updatePassword(
  currentPassword: 'oldpassword',
  newPassword: 'supernewpassword',
);

result.fold(
  (failure) => print('Erro ao atualizar senha: ${failure.message}'),
  (_) => print('Senha atualizada com sucesso.'),
);
```

### 3.13. `deleteAccount()`

Deleta a conta do usuário atualmente autenticado. Requer que o usuário esteja logado recentemente.

Exemplo:

```dart
final result = await authService.deleteAccount();

result.fold(
  (failure) => print('Erro ao deletar conta: ${failure.message}'),
  (_) => print('Conta deletada com sucesso.'),
);
```

### 3.14. `sendEmailVerification()`

Envia um email de verificação para o email do usuário atual.

Exemplo:

```dart
final result = await authService.sendEmailVerification();

result.fold(
  (failure) => print('Erro ao enviar verificação de email: ${failure.message}'),
  (_) => print('Email de verificação enviado.'),
);
```

### 3.15. `reauthenticate({required String password})`

Reautentica o usuário com sua senha. Necessário para operações sensíveis como atualização de email/senha ou exclusão de conta.

Exemplo:

```dart
final result = await authService.reauthenticate(password: 'currentpassword');

result.fold(
  (failure) => print('Erro ao reautenticar: ${failure.message}'),
  (_) => print('Reautenticação bem-sucedida.'),
);
```

### 3.16. `linkWithEmailAndPassword({required String email, required String password, required String displayName})`

Vincula uma credencial de email/senha a um usuário existente (por exemplo, um usuário anônimo).

Exemplo:

```dart
final result = await authService.linkWithEmailAndPassword(
  email: 'linked@example.com',
  password: 'linkpass',
  displayName: 'Linked User',
);

result.fold(
  (failure) => print('Erro ao vincular conta: ${failure.message}'),
  (user) => print('Conta vinculada: ${user.email}'),
);
```

### 3.17. `linkWithGoogle()`

**TODO:** Implementar vinculação com Google.

### 3.18. `linkWithApple()`

**TODO:** Implementar vinculação com Apple.

## 4. Métodos Auxiliares

### 4.1. `_mapFirebaseUserToEntity(User firebaseUser)`

Mapeia um objeto `User` do Firebase para a entidade de domínio `UserEntity`.

### 4.2. `_mapAuthProvider(List<UserInfo> providerData)`

Mapeia os provedores de autenticação do Firebase para a enumeração `AuthProvider`.

### 4.3. `_mapFirebaseAuthError(FirebaseAuthException e)`

Traduz os códigos de erro do `FirebaseAuthException` para mensagens de erro mais amigáveis e localizadas para o usuário.
