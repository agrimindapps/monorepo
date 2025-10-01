# Guia de Implementação: Autenticação e Exclusão de Conta Padronizada

## 📋 Visão Geral

Este guia detalha como implementar o sistema completo e padronizado de autenticação e exclusão de conta em todos os apps do monorepo, utilizando os novos serviços criados no `packages/core`.

## ✅ Recursos Implementados

### 1. **Serviços Core (packages/core)**

#### Autenticação
- ✅ `FirebaseAuthService` - Serviço de autenticação com re-authentication
- ✅ `IAuthRepository` - Interface padronizada

#### Exclusão de Conta
- ✅ `EnhancedAccountDeletionService` - Serviço completo de exclusão
- ✅ `AccountDeletionRateLimiter` - Rate limiting para prevenir abuso
- ✅ `FirestoreDeletionService` - Limpeza de dados Firestore/Storage
- ✅ `RevenueCatCancellationService` - Gerenciamento de assinaturas
- ✅ `IAppDataCleaner` - Interface para limpeza de dados locais

#### Widgets UI
- ✅ `AccountDeletionConfirmationDialog` - Diálogo LGPD/GDPR compliant
- ✅ `AccountDeletionProgressDialog` - Feedback de progresso visual

### 2. **Implementações por App**

#### Data Cleaners Implementados
- ✅ `app-gasometer` - `GasometerDataCleaner`
- ✅ `app-plantis` - `DataCleanerService`
- ✅ `app-receituagro` - `ReceitaAgroDataCleaner`
- ✅ `app-taskolist` - `TaskolistDataCleaner`
- ✅ `app-petiveti` - `PetivetiDataCleaner`
- ✅ `app-agrihurbi` - `AgrihurbiDataCleaner`

---

## 🚀 Como Implementar nos Apps

### Passo 1: Registrar Serviços no DI (Dependency Injection)

#### Para apps com GetIt + Injectable:

```dart
// lib/core/di/injection.dart ou modules/account_deletion_module.dart

import 'package:core/core.dart';
import 'package:injectable/injectable.dart';

@module
abstract class AccountDeletionModule {
  // 1. Registrar FirestoreDeletionService
  @lazySingleton
  FirestoreDeletionService firestoreDeletionService() {
    return FirestoreDeletionService();
  }

  // 2. Registrar RevenueCatCancellationService
  @lazySingleton
  RevenueCatCancellationService revenueCatCancellationService() {
    return RevenueCatCancellationService();
  }

  // 3. Registrar Rate Limiter
  @lazySingleton
  AccountDeletionRateLimiter accountDeletionRateLimiter() {
    return AccountDeletionRateLimiter();
  }

  // 4. Registrar EnhancedAccountDeletionService
  @lazySingleton
  EnhancedAccountDeletionService enhancedAccountDeletionService(
    IAuthRepository authRepository,
    IAppDataCleaner appDataCleaner, // Já registrado em cada app
    FirestoreDeletionService firestoreDeletion,
    RevenueCatCancellationService revenueCatCancellation,
    AccountDeletionRateLimiter rateLimiter,
  ) {
    return EnhancedAccountDeletionService(
      authRepository: authRepository,
      appDataCleaner: appDataCleaner,
      firestoreDeletion: firestoreDeletion,
      revenueCatCancellation: revenueCatCancellation,
      rateLimiter: rateLimiter,
    );
  }
}
```

#### Para apps com Riverpod:

```dart
// lib/core/providers/account_deletion_providers.dart

import 'package:core/core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final firestoreDeletionServiceProvider = Provider<FirestoreDeletionService>((ref) {
  return FirestoreDeletionService();
});

final revenueCatCancellationServiceProvider = Provider<RevenueCatCancellationService>((ref) {
  return RevenueCatCancellationService();
});

final accountDeletionRateLimiterProvider = Provider<AccountDeletionRateLimiter>((ref) {
  return AccountDeletionRateLimiter();
});

final enhancedAccountDeletionServiceProvider = Provider<EnhancedAccountDeletionService>((ref) {
  return EnhancedAccountDeletionService(
    authRepository: ref.watch(authRepositoryProvider),
    appDataCleaner: ref.watch(appDataCleanerProvider),
    firestoreDeletion: ref.watch(firestoreDeletionServiceProvider),
    revenueCatCancellation: ref.watch(revenueCatCancellationServiceProvider),
    rateLimiter: ref.watch(accountDeletionRateLimiterProvider),
  );
});
```

---

### Passo 2: Atualizar Auth Provider/Notifier

#### Provider Pattern (app-gasometer, app-plantis, app-receituagro):

```dart
// lib/features/auth/providers/auth_provider.dart

import 'package:core/core.dart';
import 'package:flutter/material.dart';

class AuthProvider extends ChangeNotifier {
  final IAuthRepository _authRepository;
  final EnhancedAccountDeletionService _enhancedDeletionService;

  AuthProvider({
    required IAuthRepository authRepository,
    required EnhancedAccountDeletionService enhancedDeletionService,
  })  : _authRepository = authRepository,
        _enhancedDeletionService = enhancedDeletionService;

  // ... outros métodos existentes ...

  /// Deleta conta com todos os recursos de segurança
  Future<bool> deleteAccount({
    required String password,
    required BuildContext context,
  }) async {
    // 1. Obter preview dos dados
    final user = await _authRepository.currentUser.first;
    if (user == null) return false;

    final previewResult = await _enhancedDeletionService.getAccountDeletionPreview(user.id);

    Map<String, dynamic>? dataPreview;
    bool hasActiveSubscription = false;

    previewResult.fold(
      (error) => debugPrint('Error getting preview: ${error.message}'),
      (preview) {
        dataPreview = preview;
        hasActiveSubscription = preview['subscription']?['hasActiveSubscription'] ?? false;
      },
    );

    // 2. Mostrar diálogo de confirmação LGPD
    bool confirmed = false;
    await showDialog(
      context: context,
      builder: (context) => AccountDeletionConfirmationDialog(
        appName: 'App Name', // Substituir pelo nome do app
        dataPreview: dataPreview,
        hasActiveSubscription: hasActiveSubscription,
        subscriptionMessage: dataPreview?['subscription']?['message'],
        onConfirmed: () => confirmed = true,
      ),
    );

    if (!confirmed) return false;

    // 3. Solicitar senha
    String? confirmedPassword;
    await showDialog(
      context: context,
      builder: (context) => _PasswordConfirmationDialog(
        onConfirmed: (pwd) => confirmedPassword = pwd,
      ),
    );

    if (confirmedPassword == null) return false;

    // 4. Iniciar exclusão com progresso
    List<String> steps = [];
    int currentStep = 0;
    bool hasError = false;
    String? errorMessage;

    // Mostrar diálogo de progresso
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AccountDeletionProgressDialog(
        steps: steps,
        currentStepIndex: currentStep,
      ),
    );

    // 5. Executar exclusão
    final result = await _enhancedDeletionService.deleteAccount(
      password: confirmedPassword,
      userId: user.id,
      isAnonymous: user.isAnonymous,
    );

    // 6. Atualizar diálogo com resultado
    result.fold(
      (error) {
        hasError = true;
        errorMessage = error.message;
      },
      (deletionResult) {
        steps = deletionResult.steps;
        currentStep = steps.length - 1;
      },
    );

    // Fechar e reabrir com resultado final
    Navigator.of(context).pop();
    await showDialog(
      context: context,
      builder: (context) => AccountDeletionProgressDialog(
        steps: steps,
        currentStepIndex: currentStep,
        isComplete: !hasError,
        hasError: hasError,
        errorMessage: errorMessage,
      ),
    );

    return !hasError;
  }
}

// Diálogo auxiliar para confirmar senha
class _PasswordConfirmationDialog extends StatefulWidget {
  final Function(String) onConfirmed;

  const _PasswordConfirmationDialog({required this.onConfirmed});

  @override
  State<_PasswordConfirmationDialog> createState() =>
      _PasswordConfirmationDialogState();
}

class _PasswordConfirmationDialogState
    extends State<_PasswordConfirmationDialog> {
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Confirmar Senha'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Por segurança, digite sua senha para confirmar a exclusão da conta.',
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _passwordController,
            obscureText: _obscurePassword,
            decoration: InputDecoration(
              labelText: 'Senha',
              border: const OutlineInputBorder(),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility : Icons.visibility_off,
                ),
                onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
              ),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_passwordController.text.isNotEmpty) {
              widget.onConfirmed(_passwordController.text);
              Navigator.of(context).pop();
            }
          },
          child: const Text('Confirmar'),
        ),
      ],
    );
  }
}
```

#### Riverpod Pattern (app-taskolist):

```dart
// lib/features/auth/providers/auth_notifier.dart

import 'package:core/core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AuthNotifier extends StateNotifier<AuthState> {
  final IAuthRepository _authRepository;
  final EnhancedAccountDeletionService _enhancedDeletionService;

  AuthNotifier({
    required IAuthRepository authRepository,
    required EnhancedAccountDeletionService enhancedDeletionService,
  })  : _authRepository = authRepository,
        _enhancedDeletionService = enhancedDeletionService,
        super(const AuthState.initial());

  Future<bool> deleteAccount({
    required String password,
    required BuildContext context,
  }) async {
    // Implementação similar ao Provider pattern acima
    // ...
  }
}

final authNotifierProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(
    authRepository: ref.watch(authRepositoryProvider),
    enhancedDeletionService: ref.watch(enhancedAccountDeletionServiceProvider),
  );
});
```

---

### Passo 3: Atualizar UI (Settings/Account Page)

```dart
// lib/features/settings/pages/account_settings_page.dart

ListTile(
  leading: const Icon(Icons.delete_forever, color: Colors.red),
  title: const Text('Excluir Conta'),
  subtitle: const Text('Ação irreversível - exclui todos seus dados'),
  onTap: () async {
    final authProvider = context.read<AuthProvider>(); // ou ref.read para Riverpod

    final success = await authProvider.deleteAccount(
      password: '', // Será solicitado no fluxo
      context: context,
    );

    if (success && mounted) {
      // Redirecionar para login
      Navigator.of(context).pushNamedAndRemoveUntil(
        '/login',
        (route) => false,
      );
    }
  },
)
```

---

## 📊 Checklist de Implementação por App

### app-gasometer
- [x] Data Cleaner implementado
- [ ] DI configurado com EnhancedAccountDeletionService
- [ ] AuthProvider atualizado
- [ ] UI atualizada

### app-plantis
- [x] Data Cleaner implementado
- [ ] DI configurado
- [ ] AuthProvider atualizado
- [ ] UI atualizada

### app-receituagro
- [x] Data Cleaner implementado
- [ ] DI configurado
- [ ] AuthProvider atualizado
- [ ] UI atualizada

### app-taskolist
- [x] Data Cleaner implementado
- [ ] DI configurado
- [ ] AuthNotifier atualizado (Riverpod)
- [ ] UI atualizada

### app-petiveti
- [x] Data Cleaner implementado
- [ ] DI configurado
- [ ] AuthProvider atualizado
- [ ] UI atualizada

### app-agrihurbi
- [x] Data Cleaner implementado
- [ ] DI configurado
- [ ] AuthProvider atualizado
- [ ] UI atualizada

---

## 🔒 Recursos de Segurança Implementados

### ✅ Implementados no Core

1. **Re-autenticação obrigatória** - Senha exigida antes de deletar
2. **Rate limiting** - Máximo 3 tentativas por hora
3. **Bloqueio de usuários anônimos** - Anônimos não podem deletar conta
4. **Limpeza Firestore/Storage** - Dados na nuvem são removidos
5. **Cancelamento RevenueCat** - Instruções para cancelar assinaturas
6. **Limpeza local completa** - Hive boxes e SharedPreferences
7. **Auditoria e logging** - Todas as etapas são registradas
8. **Diálogos LGPD/GDPR** - Conformidade legal completa
9. **Feedback de progresso** - UX transparente
10. **Verificação pós-exclusão** - Confirma que dados foram removidos

---

## 🧪 Como Testar

### 1. Teste de Exclusão Bem-Sucedida

```bash
# 1. Criar conta de teste
# 2. Adicionar dados (tarefas, plantas, etc)
# 3. Tentar deletar conta
# 4. Confirmar senha correta
# 5. Verificar:
#    - Firebase Auth: conta removida
#    - Firestore: documentos removidos
#    - Hive: boxes deletadas
#    - SharedPreferences: chaves removidas
```

### 2. Teste de Rate Limiting

```bash
# 1. Tentar deletar com senha errada 3x
# 2. 4ª tentativa deve ser bloqueada
# 3. Aguardar 1 hora
# 4. Tentar novamente deve funcionar
```

### 3. Teste de Usuário Anônimo

```bash
# 1. Login como anônimo
# 2. Tentar deletar conta
# 3. Deve ser bloqueado com mensagem clara
```

### 4. Teste de Re-autenticação

```bash
# 1. Login normal
# 2. Tentar deletar sem senha -> deve falhar
# 3. Tentar com senha errada -> deve falhar
# 4. Tentar com senha certa -> deve funcionar
```

---

## 📝 Notas Importantes

### LGPD/GDPR Compliance

- ✅ Usuário deve ler informações completas antes de confirmar
- ✅ Checkboxes de consentimento explícito obrigatórios
- ✅ Aviso sobre dados que podem ser mantidos por lei
- ✅ Período de 30 dias não implementado (pode ser adicionado se necessário)

### RevenueCat

- ✅ Detecta assinaturas ativas
- ✅ Fornece instruções de cancelamento manual
- ⚠️ Não cancela automaticamente (limitação das stores)

### Performance

- ✅ Firestore: Batch delete (máx 500 docs por batch)
- ✅ Rate limiting previne abuso
- ✅ Cleanup assíncrono não bloqueia UI

---

## 🎯 Próximos Passos

1. **Implementar nos 6 apps** seguindo este guia
2. **Testar cada app** com o checklist acima
3. **Ajustar subcollections** no FirestoreDeletionService para cada app
4. **Adicionar analytics** para monitorar exclusões
5. **Criar testes automatizados** para fluxo completo

---

## 📞 Suporte

Para dúvidas ou problemas na implementação:
1. Verificar código dos serviços em `packages/core/lib/src/infrastructure/services/`
2. Verificar exemplos de Data Cleaners em cada app
3. Revisar este guia
4. Testar em ambiente de desenvolvimento primeiro

---

**Última atualização**: 2025-10-01
**Versão do Core**: 1.0.0
**Status**: ✅ Pronto para implementação
