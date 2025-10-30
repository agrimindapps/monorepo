# Guia de Migração - Feature Account

## 🎯 Objetivo

Este guia detalha como migrar widgets existentes para usar a nova arquitetura Clean Architecture com `Either<Failure, T>` e Riverpod.

## 📊 Antes vs Depois

### ❌ ANTES (Acesso direto a serviços)

```dart
class AccountActionsSection extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
      title: Text('Sair da Conta'),
      onTap: () async {
        try {
          final authNotifier = ref.read(authProvider.notifier);
          await authNotifier.logout();
          context.go('/');
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erro: $e')),
          );
        }
      },
    );
  }
}
```

**Problemas:**
- ❌ Lógica de negócio no widget
- ❌ Try-catch genérico
- ❌ Sem separação de responsabilidades
- ❌ Dificulta testes

### ✅ DEPOIS (Clean Architecture + Either)

```dart
class AccountActionsSection extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
      title: const Text('Sair da Conta'),
      onTap: () => _handleLogout(context, ref),
    );
  }

  Future<void> _handleLogout(BuildContext context, WidgetRef ref) async {
    final logoutNotifier = ref.read(logoutNotifierProvider.notifier);
    final result = await logoutNotifier.logout();
    
    if (!context.mounted) return;
    
    result.fold(
      (failure) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(failure.message),
            backgroundColor: Colors.red,
          ),
        );
      },
      (_) {
        context.go('/');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Logout realizado com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
      },
    );
  }
}
```

**Benefícios:**
- ✅ Lógica de negócio no Use Case
- ✅ Tratamento de erros tipado com `Failure`
- ✅ Separação de responsabilidades
- ✅ Fácil de testar

## 🔄 Passos para Migração

### Passo 1: Gerar código Riverpod

```bash
cd apps/app-plantis
flutter pub run build_runner build --delete-conflicting-outputs
```

Isso gerará o arquivo `account_providers.g.dart` com os providers.

### Passo 2: Atualizar imports nos widgets

```dart
// ❌ ANTES
import '../../../core/providers/auth_providers.dart' as local;
import '../../../core/di/injection_container.dart' as di;

// ✅ DEPOIS
import '../../presentation/providers/account_providers.dart';
```

### Passo 3: Substituir acesso direto a serviços

```dart
// ❌ ANTES - Acesso direto ao serviço
final dataCleanerService = di.sl<DataCleanerService>();
final result = await dataCleanerService.clearUserContentOnly();

// ✅ DEPOIS - Usar Use Case via provider
final clearDataNotifier = ref.read(clearDataNotifierProvider.notifier);
final result = await clearDataNotifier.clearData();
```

### Passo 4: Atualizar tratamento de erros

```dart
// ❌ ANTES - try-catch genérico
try {
  await operation();
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('Sucesso!')),
  );
} catch (e) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('Erro: $e')),
  );
}

// ✅ DEPOIS - Either pattern
final result = await notifier.performOperation();

result.fold(
  (failure) {
    // Tratamento específico por tipo de erro
    String message;
    if (failure is AuthFailure) {
      message = 'Erro de autenticação: ${failure.message}';
    } else if (failure is NetworkFailure) {
      message = 'Sem conexão: ${failure.message}';
    } else {
      message = failure.message;
    }
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  },
  (data) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Sucesso!'),
        backgroundColor: Colors.green,
      ),
    );
  },
);
```

### Passo 5: Atualizar observação de estado

```dart
// ❌ ANTES - Observar AuthState
final authStateAsync = ref.watch(authProvider);

authStateAsync.when(
  data: (authState) {
    final user = authState.currentUser;
    return Text(user?.displayName ?? '');
  },
  loading: () => CircularProgressIndicator(),
  error: (e, s) => Text('Erro'),
);

// ✅ DEPOIS - Observar AccountInfo
final accountInfoAsync = ref.watch(accountInfoProvider);

accountInfoAsync.when(
  data: (accountInfo) {
    return Text(accountInfo.displayName);
  },
  loading: () => const CircularProgressIndicator(),
  error: (e, s) => Text('Erro: $e'),
);
```

## 📝 Checklist de Migração por Widget

### ✅ account_profile_page.dart
- [x] Estrutura mantida (página principal)
- [ ] Considerar usar `accountInfoProvider` no futuro

### ✅ account_info_section.dart
- [x] Widget de apresentação - OK como está
- [ ] Considerar usar `accountInfoProvider` para dados

### ⚠️ account_actions_section.dart (PRECISA MIGRAÇÃO)
- [ ] Substituir acesso direto a `DataCleanerService`
- [ ] Usar `clearDataNotifierProvider`
- [ ] Usar `logoutNotifierProvider`
- [ ] Atualizar tratamento de erros com `Either`

### ✅ account_details_section.dart
- [x] Widget de apresentação - OK como está

### ✅ data_sync_section.dart
- [x] Widget de apresentação - OK como está

### ✅ device_management_section.dart
- [x] Widget de apresentação - OK como está

### ⚠️ account_deletion_dialog.dart (PRECISA MIGRAÇÃO)
- [ ] Usar `deleteAccountNotifierProvider`
- [ ] Atualizar para usar `Either<Failure, void>`

## 🧪 Exemplos Completos

### Exemplo 1: Migrar Clear Data Action

**ANTES:**
```dart
Future<void> _performClearData(BuildContext context) async {
  try {
    final dataCleanerService = di.sl<DataCleanerService>();
    final result = await dataCleanerService.clearUserContentOnly();
    
    if (result['success'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Dados limpos!')),
      );
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Erro: $e')),
    );
  }
}
```

**DEPOIS:**
```dart
Future<void> _performClearData(BuildContext context, WidgetRef ref) async {
  final clearDataNotifier = ref.read(clearDataNotifierProvider.notifier);
  
  // Mostrar loading
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => const Center(child: CircularProgressIndicator()),
  );
  
  final result = await clearDataNotifier.clearData();
  
  if (!context.mounted) return;
  Navigator.of(context).pop(); // Fechar loading
  
  result.fold(
    (failure) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao limpar dados: ${failure.message}'),
          backgroundColor: Colors.red,
        ),
      );
    },
    (count) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✅ $count registros limpos com sucesso!'),
          backgroundColor: Colors.green,
        ),
      );
    },
  );
}
```

### Exemplo 2: Migrar Logout Action

**ANTES:**
```dart
Future<void> _performLogout(
  BuildContext context,
  AuthNotifier authNotifier,
) async {
  try {
    await authNotifier.logout();
    context.go('/');
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Erro: $e')),
    );
  }
}
```

**DEPOIS:**
```dart
Future<void> _performLogout(BuildContext context, WidgetRef ref) async {
  final logoutNotifier = ref.read(logoutNotifierProvider.notifier);
  
  final result = await logoutNotifier.logout();
  
  if (!context.mounted) return;
  
  result.fold(
    (failure) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao fazer logout: ${failure.message}'),
          backgroundColor: Colors.red,
        ),
      );
    },
    (_) {
      context.go('/');
      
      Future.delayed(const Duration(milliseconds: 300), () {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ Logout realizado com sucesso!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      });
    },
  );
}
```

## 🎓 Conceitos Importantes

### Either<L, R>
```dart
// Left = Falha
// Right = Sucesso

Either<Failure, int> result = Right(42);
result.fold(
  (failure) => print('Erro: ${failure.message}'),
  (value) => print('Sucesso: $value'),
);
```

### AsyncValue<T>
```dart
// Estado assíncrono do Riverpod
final accountAsync = ref.watch(accountInfoProvider);

// Possíveis estados:
// - AsyncLoading(): Carregando
// - AsyncData(T): Dados disponíveis
// - AsyncError(Object, StackTrace): Erro
```

## 🚀 Próximos Passos

1. ✅ Arquitetura domain/data/presentation criada
2. ✅ Providers Riverpod criados
3. ✅ Use Cases implementados
4. [ ] Gerar código Riverpod (build_runner)
5. [ ] Migrar `account_actions_section.dart`
6. [ ] Migrar `account_deletion_dialog.dart`
7. [ ] Testar fluxos completos
8. [ ] Adicionar testes unitários

## 📚 Recursos Adicionais

- [Either Pattern em Dart](https://pub.dev/packages/dartz)
- [Riverpod Code Generation](https://riverpod.dev/docs/concepts/about_code_generation)
- [Clean Architecture](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)
