# Provider → Riverpod Migration Plan

**Data de Início**: 2025-10-01
**Estimativa Total**: 4-6 horas
**Apps Target**: app-plantis, app-receituagro, app-gasometer

---

## 🎯 Objetivo

Migrar os 3 apps que ainda usam Provider (ChangeNotifier) para **Riverpod**, estabelecendo **consistência total** de state management em todos os 6 apps do monorepo.

---

## 📊 Status Atual State Management

| App | State Mgmt Atual | Target | Complexidade |
|-----|-----------------|--------|--------------|
| ✅ **app-petiveti** | Riverpod | - | N/A (já usa) |
| ✅ **app-agrihurbi** | Riverpod | - | N/A (já usa) |
| ✅ **app-taskolist** | Riverpod | - | N/A (já usa) |
| 🔄 **app-plantis** | Provider | Riverpod | ⭐⭐ Média |
| 🔄 **app-receituagro** | Provider | Riverpod | ⭐ Baixa |
| 🔄 **app-gasometer** | Provider | Riverpod | ⭐⭐⭐ Alta |

---

## 🔍 Análise Detalhada por App

### **1. app-receituagro** (PRIORIDADE 1 - Mais Simples)

**Complexidade**: ⭐ Baixa

**Providers Atuais**:
```dart
// Único provider principal
lib/features/auth/presentation/providers/auth_provider.dart
  → AuthProvider (ChangeNotifier)

// Service wrapper
lib/core/services/premium_service.dart
  → ReceitaAgroPremiumService (não é provider, apenas service)
```

**Estimativa**: 1-1.5 horas

**Motivo da Prioridade**:
- Apenas 1 provider principal (AuthProvider)
- Premium é service wrapper (já pronto)
- Arquitetura simples
- Melhor para estabelecer padrão de migração

---

### **2. app-plantis** (PRIORIDADE 2)

**Complexidade**: ⭐⭐ Média

**Providers Atuais**:
```dart
lib/features/auth/presentation/providers/auth_provider.dart
  → AuthProvider (ChangeNotifier)

lib/features/premium/presentation/providers/premium_provider.dart
  → PremiumProvider (ChangeNotifier)

lib/features/premium/presentation/providers/premium_provider_improved.dart
  → PremiumProviderImproved (ChangeNotifier) - versão melhorada

// Possivelmente outros providers de features
lib/features/*/presentation/providers/*.dart
```

**Estimativa**: 1.5-2 horas

**Complexidade Extra**:
- 2+ providers principais
- Comunicação entre providers (auth → premium)
- Pode ter providers de outras features

---

### **3. app-gasometer** (PRIORIDADE 3 - Mais Complexo)

**Complexidade**: ⭐⭐⭐ Alta

**Providers Atuais**:
```dart
// Auth
lib/features/auth/presentation/providers/auth_provider.dart

// Premium (Clean Architecture)
lib/features/premium/presentation/providers/premium_provider.dart
lib/features/premium/presentation/providers/premium_notifier.dart

// Fuel tracking
lib/features/fuel/presentation/providers/*

// Maintenance
lib/features/maintenance/presentation/providers/*

// Vehicles
lib/features/vehicles/presentation/providers/*

// Possivelmente 10+ providers
```

**Estimativa**: 2-2.5 horas

**Complexidade Extra**:
- 10+ providers distribuídos em múltiplas features
- Clean Architecture com Premium (domínio complexo)
- Dependências entre providers
- Muito state compartilhado

---

## 🔄 Estratégia de Migração

### **Fase 1: Preparação**

1. **Análise de Dependências**
```bash
# Para cada app, identificar todos os providers
grep -r "extends ChangeNotifier" lib/
grep -r "Provider.of<" lib/
grep -r "Consumer<" lib/
grep -r "context.watch<" lib/
```

2. **Verificar flutter_riverpod já está no pubspec.yaml**
```yaml
dependencies:
  flutter_riverpod: any  # Verificar se já existe
```

3. **Mapear Provider → Riverpod equivalents**

| Provider Pattern | Riverpod Equivalent |
|-----------------|---------------------|
| `ChangeNotifier` | `StateNotifier<T>` ou `Notifier<T>` |
| `Provider.of<T>(context)` | `ref.watch(tProvider)` |
| `Consumer<T>` | `Consumer(builder: (context, ref, child))` |
| `ChangeNotifierProvider` | `StateNotifierProvider` ou `NotifierProvider` |
| `context.read<T>()` | `ref.read(tProvider)` |

---

### **Fase 2: Migração Incremental**

#### **Step 1: Setup Riverpod**

```dart
// main.dart
// ANTES
void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider(...)),
        ChangeNotifierProvider(create: (_) => PremiumProvider(...)),
      ],
      child: MyApp(),
    ),
  );
}

// DEPOIS
void main() {
  runApp(
    ProviderScope(  // ProviderScope é root
      child: MyApp(),
    ),
  );
}
```

#### **Step 2: Converter ChangeNotifier → StateNotifier**

```dart
// ANTES: Provider
class AuthProvider extends ChangeNotifier {
  UserEntity? _currentUser;
  bool _isLoading = false;

  UserEntity? get currentUser => _currentUser;
  bool get isLoading => _isLoading;

  Future<void> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    // login logic
    _currentUser = user;
    _isLoading = false;
    notifyListeners();
  }
}

// DEPOIS: Riverpod StateNotifier
class AuthNotifier extends StateNotifier<AuthState> {
  final LoginUseCase _loginUseCase;

  AuthNotifier(this._loginUseCase) : super(const AuthState.initial());

  Future<void> login(String email, String password) async {
    state = state.copyWith(isLoading: true);

    // login logic
    state = state.copyWith(
      user: user,
      isLoading: false,
    );
  }
}

// State class (imutável)
@freezed
class AuthState with _$AuthState {
  const factory AuthState({
    UserEntity? user,
    @Default(false) bool isLoading,
    String? error,
  }) = _AuthState;

  const factory AuthState.initial() = _Initial;
}

// Provider declaration
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref.watch(loginUseCaseProvider));
});
```

#### **Step 3: Converter UI Consumers**

```dart
// ANTES: Provider
class LoginScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return authProvider.isLoading
        ? CircularProgressIndicator()
        : ElevatedButton(
            onPressed: () => authProvider.login(email, password),
            child: Text('Login'),
          );
  }
}

// DEPOIS: Riverpod
class LoginScreen extends ConsumerWidget {  // ConsumerWidget ao invés de StatelessWidget
  @override
  Widget build(BuildContext context, WidgetRef ref) {  // ref adicionado
    final authState = ref.watch(authProvider);  // watch para reatividade

    return authState.isLoading
        ? CircularProgressIndicator()
        : ElevatedButton(
            onPressed: () => ref.read(authProvider.notifier).login(email, password),
            child: Text('Login'),
          );
  }
}
```

#### **Step 4: Comunicação entre Providers**

```dart
// ANTES: Provider (ref via context)
class PremiumProvider extends ChangeNotifier {
  final AuthProvider authProvider;

  PremiumProvider(this.authProvider) {
    authProvider.addListener(_onAuthChanged);
  }

  void _onAuthChanged() {
    final user = authProvider.currentUser;
    if (user != null) {
      _checkPremiumStatus(user.id);
    }
  }
}

// DEPOIS: Riverpod (ref via provider)
final premiumProvider = StateNotifierProvider<PremiumNotifier, PremiumState>((ref) {
  // Acessa outro provider diretamente
  final authState = ref.watch(authProvider);

  return PremiumNotifier(
    subscriptionRepository: ref.watch(subscriptionRepositoryProvider),
    userId: authState.user?.id,
  );
});

class PremiumNotifier extends StateNotifier<PremiumState> {
  PremiumNotifier({
    required ISubscriptionRepository subscriptionRepository,
    String? userId,
  }) : super(const PremiumState.initial()) {
    if (userId != null) {
      _checkPremiumStatus(userId);
    }
  }
}
```

---

### **Fase 3: Padrões Específicos por App**

#### **app-receituagro Pattern**

```dart
// Estado simples (sem freezed se não quiser)
class AuthState {
  final UserEntity? user;
  final bool isLoading;
  final String? error;

  const AuthState({
    this.user,
    this.isLoading = false,
    this.error,
  });

  AuthState copyWith({
    UserEntity? user,
    bool? isLoading,
    String? error,
  }) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

// Notifier simples
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(
    loginUseCase: ref.watch(loginUseCaseProvider),
    // ... outros use cases
  );
});
```

#### **app-plantis Pattern (com múltiplos providers)**

```dart
// Auth Provider
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref.watch(authRepositoryProvider));
});

// Premium Provider (depende de auth)
final premiumProvider = StateNotifierProvider<PremiumNotifier, PremiumState>((ref) {
  final authState = ref.watch(authProvider);

  return PremiumNotifier(
    subscriptionRepository: ref.watch(subscriptionRepositoryProvider),
    userId: authState.user?.id,
  );
});

// Derived provider (apenas leitura)
final isPremiumProvider = Provider<bool>((ref) {
  return ref.watch(premiumProvider).isPremium;
});
```

#### **app-gasometer Pattern (Clean Arch com múltiplas features)**

```dart
// Estrutura modular por feature
// features/fuel/presentation/providers/fuel_providers.dart
final fuelProvider = StateNotifierProvider<FuelNotifier, FuelState>((ref) {
  return FuelNotifier(
    getFuelRecords: ref.watch(getFuelRecordsUseCaseProvider),
    addFuelRecord: ref.watch(addFuelRecordUseCaseProvider),
    // ... outros use cases
  );
});

// features/maintenance/presentation/providers/maintenance_providers.dart
final maintenanceProvider = StateNotifierProvider<MaintenanceNotifier, MaintenanceState>((ref) {
  return MaintenanceNotifier(
    getMaintenanceRecords: ref.watch(getMaintenanceRecordsUseCaseProvider),
    // ...
  );
});

// features/premium/presentation/providers/premium_providers.dart
final premiumProvider = StateNotifierProvider<PremiumNotifier, PremiumState>((ref) {
  final authState = ref.watch(authProvider);

  return PremiumNotifier(
    checkPremiumStatus: ref.watch(checkPremiumStatusUseCaseProvider),
    userId: authState.user?.id,
  );
});
```

---

## 📋 Checklist de Migração (Por App)

### **Pre-Migration**
- [ ] Identificar todos os ChangeNotifier providers
- [ ] Mapear dependências entre providers
- [ ] Verificar flutter_riverpod no pubspec.yaml
- [ ] Criar branch de migração

### **During Migration**
- [ ] Wrap main.dart com ProviderScope
- [ ] Converter ChangeNotifier → StateNotifier (um por vez)
- [ ] Criar state classes (imutáveis)
- [ ] Converter Provider.of → ref.watch
- [ ] Converter Consumer → ConsumerWidget
- [ ] Atualizar comunicação entre providers
- [ ] Testar cada provider convertido

### **Post-Migration**
- [ ] Remover package `provider` do pubspec.yaml
- [ ] Remover imports de `package:provider/provider.dart`
- [ ] Flutter analyze sem warnings
- [ ] Testar todas as features principais
- [ ] Documentar padrões usados

---

## 🎯 Ordem de Execução Recomendada

### **Fase 1: app-receituagro** (1-1.5h)
**Motivo**: Apenas 1 provider, estabelece padrão base

1. Setup ProviderScope no main.dart
2. Converter AuthProvider → AuthNotifier
3. Criar AuthState class
4. Converter UI consumers
5. Testar login/logout flow
6. Remover package provider

### **Fase 2: app-plantis** (1.5-2h)
**Motivo**: 2-3 providers, comunicação entre providers

1. Setup ProviderScope
2. Converter AuthProvider → AuthNotifier
3. Converter PremiumProvider → PremiumNotifier
4. Implementar comunicação auth → premium
5. Converter outros providers (se houver)
6. Testar integração auth + premium
7. Remover package provider

### **Fase 3: app-gasometer** (2-2.5h)
**Motivo**: 10+ providers, Clean Architecture

1. Setup ProviderScope
2. Converter AuthProvider → AuthNotifier (core)
3. Converter PremiumProvider → PremiumNotifier
4. Converter Fuel providers
5. Converter Maintenance providers
6. Converter Vehicles providers
7. Converter outros providers restantes
8. Testar integração completa
9. Remover package provider

---

## ⚠️ Pontos de Atenção

### **1. Breaking Changes**
- `StatelessWidget` → `ConsumerWidget`
- `StatefulWidget` → `ConsumerStatefulWidget`
- `context` → `ref` para acessar providers
- `addListener` → Automático via `ref.watch`

### **2. Performance**
- `ref.watch` → Re-renders quando state muda (use com cuidado)
- `ref.read` → Uma vez só (para actions/callbacks)
- `ref.listen` → Side effects (não re-render)

### **3. State Imutabilidade**
```dart
// ❌ NÃO FAZER
state.isLoading = true;  // Mutação direta não funciona

// ✅ FAZER
state = state.copyWith(isLoading: true);  // Criar novo state
```

### **4. Provider Dependencies**
```dart
// ✅ Dependências explícitas via ref.watch
final myProvider = Provider<MyService>((ref) {
  final dependency = ref.watch(dependencyProvider);
  return MyService(dependency);
});
```

---

## 📊 Métricas de Sucesso

| Métrica | Antes | Meta Após Migração |
|---------|-------|-------------------|
| **Apps usando Riverpod** | 3/6 (50%) | 6/6 (100%) |
| **State Management consistency** | 50% | 100% |
| **Provider package dependencies** | 3 | 0 |
| **Code maintainability** | Média | Alta |

---

## 🚀 Benefícios da Migração

### **1. Consistência**
- ✅ Todos os 6 apps usando mesmo state management
- ✅ Padrões unificados de código
- ✅ Onboarding mais fácil para novos devs

### **2. Performance**
- ✅ Rebuilds mais granulares
- ✅ Melhor gestão de memória
- ✅ Compile-time safety

### **3. Developer Experience**
- ✅ Type safety total
- ✅ Provider dependencies explícitas
- ✅ Testing mais fácil (providers mockáveis)
- ✅ DevTools integrado

### **4. Manutenibilidade**
- ✅ State imutável (menos bugs)
- ✅ Debugging mais fácil
- ✅ Refactoring mais seguro

---

## 📚 Recursos de Referência

### **Documentação**
- [Riverpod Official Docs](https://riverpod.dev)
- [Provider → Riverpod Migration Guide](https://riverpod.dev/docs/from_provider/motivation)
- [Riverpod Best Practices](https://codewithandrea.com/articles/flutter-state-management-riverpod/)

### **Exemplos no Monorepo**
- ✅ app-petiveti (Riverpod + Clean Arch)
- ✅ app-agrihurbi (Riverpod + Clean Arch)
- ✅ app-taskolist (Riverpod + Service Wrapper)

---

## 🎯 Critérios de Conclusão

- [ ] ✅ 6/6 apps usando Riverpod
- [ ] ✅ 0 dependências do package `provider`
- [ ] ✅ Flutter analyze sem warnings
- [ ] ✅ Todas as features principais testadas
- [ ] ✅ Documentação de padrões atualizada
- [ ] ✅ Code review aprovado

---

**Documento Criado**: 2025-10-01
**Status**: PLANEJAMENTO
**Pronto para execução!** 🚀
