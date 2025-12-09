# Fix: Dados do Usuário não aparecem após Login Manual

## 🔍 Problema Identificado

Após fazer login manual (não auto-login), os dados do usuário (nome e email) não aparecem na interface, mostrando apenas "Usuário" e "email@usuario.com" como placeholders.

## 📊 Análise

### Fluxo Atual
1. Usuário faz login via `signInWithEmailAndPassword()`
2. Firebase Auth retorna `User` com `email` mas `displayName` pode ser `null`
3. `AuthRepository` converte para `UserEntity`
4. `AuthNotifier._handleUserStateChange()` é chamado
5. `_initializeUserSession()` atualiza o state
6. Widget `ProfileUserSection` tenta mostrar `user.displayName` e `user.email`

### Onde está o problema?

**Local**: Conversão de `firebase_auth.User` → `UserEntity`

Quando um usuário faz login com email/senha no Firebase, o campo `displayName` pode vir como `null` se não foi definido durante o cadastro. O código atual não trata esse caso.

## ✅ Solução

### Opção 1: Criar extension para UserEntity (RECOMENDADA)

Criar uma extension que garante que sempre haja um displayName válido:

```dart
extension UserEntityDisplayExtension on UserEntity {
  /// Retorna displayName ou fallback para parte local do email
  String get safeDisplayName {
    if (displayName != null && displayName!.isNotEmpty) {
      return displayName!;
    }
    
    if (email != null && email!.isNotEmpty) {
      // Pega a parte antes do @ do email
      final emailParts = email!.split('@');
      return emailParts.first;
    }
    
    return 'Usuário';
  }
}
```

### Opção 2: Atualizar UserEntity após login

No `AuthNotifier`, após login bem-sucedido, atualizar o `displayName` no Firebase Auth se ele for `null`:

```dart
// Em _handleUserStateChange ou _initializeUserSession
if (user.displayName == null || user.displayName.isEmpty) {
  final fallbackName = user.email?.split('@').first ?? 'Usuário';
  await _authRepository.updateDisplayName(fallbackName);
}
```

### Opção 3: Widget com fallback (PALIATIVO)

Já está implementado parcialmente em `ProfileUserSection._getUserDisplayTitle()`, mas pode ser melhorado:

```dart
String _getUserDisplayTitle(dynamic user) {
  // 1. Tenta displayName
  final displayName = user?.displayName;
  if (displayName != null && displayName is String && displayName.isNotEmpty) {
    return displayName;
  }
  
  // 2. Fallback para parte do email
  final email = user?.email;
  if (email is String && email.isNotEmpty) {
    final emailParts = email.split('@');
    return emailParts.first; // "lucineiy" ao invés de "lucineiy@hotmail.com"
  }
  
  // 3. Último fallback
  return 'Usuário';
}
```

## 🎯 Recomendação

**Implementar Opção 1 + Opção 3 combinadas:**

1. Criar extension `UserEntityDisplayExtension` no core package
2. Melhorar o método `_getUserDisplayTitle()` no widget
3. Garantir que sempre mostre algo útil (parte do email)

## 📝 Implementação

### Passo 1: Extension no core

```dart
// packages/core/lib/features/auth/domain/entities/user_entity_extensions.dart

extension UserEntityDisplayExtension on UserEntity {
  /// Retorna displayName seguro (nunca null/empty)
  String get safeDisplayName {
    if (displayName != null && displayName!.trim().isNotEmpty) {
      return displayName!.trim();
    }
    
    if (email != null && email!.isNotEmpty) {
      final emailParts = email!.split('@');
      return emailParts.first;
    }
    
    return 'Usuário';
  }
  
  /// Retorna email seguro
  String get safeEmail {
    if (email != null && email!.trim().isNotEmpty) {
      return email!.trim();
    }
    return 'Sem email';
  }
}
```

### Passo 2: Usar no widget

```dart
// Em ProfileUserSection

String _getUserDisplayTitle(dynamic user) {
  if (user == null) return 'Usuário';
  
  // Se user é UserEntity, usa extension
  if (user is UserEntity) {
    return user.safeDisplayName;
  }
  
  // Fallback para acesso dinâmico
  final displayName = user?.displayName;
  if (displayName != null && displayName is String && displayName.isNotEmpty) {
    return displayName;
  }
  
  final email = user?.email;
  if (email is String && email.isNotEmpty) {
    return email.split('@').first;
  }
  
  return 'Usuário';
}
```

## 🧪 Teste

1. Fazer login manual com `lucineiy@hotmail.com`
2. Verificar que mostra "lucineiy" ao invés de "Usuário"
3. Verificar que mostra o email completo na linha inferior

## 📌 Status

- [ ] Extension criada no core
- [ ] Widget atualizado
- [ ] Testado com login manual
- [ ] Testado com login anônimo
- [ ] Testado com usuário sem displayName
