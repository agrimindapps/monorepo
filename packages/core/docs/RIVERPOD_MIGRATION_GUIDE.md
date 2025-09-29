# Guia de Migração para Riverpod Centralizado

## 📋 Visão Geral

Este guia detalha como migrar apps que usam Provider para **Riverpod centralizado via packages/core**, garantindo consistência arquitetural em todo o monorepo.

## 🎯 **Arquitetura Alvo: Riverpod via Core**

### **Princípios:**
- ✅ **Single Source of Truth** - Riverpod apenas no packages/core
- ✅ **Zero Dependencies** - Apps não declaram Riverpod diretamente  
- ✅ **Consistent Patterns** - Mesmos utilitários em todos os apps
- ✅ **Easier Maintenance** - Atualizações centralizadas

## 📁 **Estrutura do Sistema Riverpod**

```
packages/core/
├── lib/
│   ├── core.dart                          # Re-export de Riverpod
│   └── src/riverpod/
│       ├── common_providers.dart          # Providers globais
│       ├── riverpod_utils.dart           # Widgets e utilities
│       └── common_notifiers.dart         # Notifiers reutilizáveis
```

## 🔄 **Passo-a-Passo da Migração**

### **Passo 1: Atualizar pubspec.yaml do App**

#### ❌ **ANTES (Provider)**
```yaml
dependencies:
  flutter:
    sdk: flutter
  provider: ^6.1.5          # Remove this
  core:
    path: ../../packages/core
```

#### ✅ **DEPOIS (Riverpod via Core)**
```yaml
dependencies:
  flutter:
    sdk: flutter
  # provider: ^6.1.5        # Removed - gets from core
  core:
    path: ../../packages/core  # Riverpod comes from here
```

### **Passo 2: Atualizar main.dart**

#### ❌ **ANTES (Provider)**
```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: MyApp(),
    ),
  );
}
```

#### ✅ **DEPOIS (Riverpod via Core)**
```dart
import 'package:flutter/material.dart';
import 'package:core/core.dart'; // Riverpod comes from core

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize SharedPreferences
  final prefs = await SharedPreferences.getInstance();
  
  runApp(
    ProviderScope(
      overrides: [
        // Override common providers with app-specific implementations
        sharedPreferencesProvider.overrideWithValue(prefs),
      ],
      child: MyApp(),
    ),
  );
}
```

### **Passo 3: Migrar Widgets**

#### ❌ **ANTES (Consumer Widget Provider)**
```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        if (authProvider.isLoading) {
          return CircularProgressIndicator();
        }
        
        return Text('Welcome ${authProvider.user?.name}');
      },
    );
  }
}
```

#### ✅ **DEPOIS (ConsumerWidget Riverpod)**
```dart
import 'package:flutter/material.dart';
import 'package:core/core.dart'; // Riverpod utilities from core

class HomePage extends BaseConsumerWidget { // Uses core BaseConsumerWidget
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final user = ref.watch(currentUserProvider);
    
    if (!authState) {
      return CircularProgressIndicator();
    }
    
    return Text('Welcome ${user?['name'] ?? 'User'}');
  }
}
```

### **Passo 4: Migrar State Management**

#### ❌ **ANTES (ChangeNotifier)**
```dart
import 'package:flutter/foundation.dart';

class AuthProvider extends ChangeNotifier {
  User? _user;
  bool _isLoading = false;
  
  User? get user => _user;
  bool get isLoading => _isLoading;
  
  Future<void> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();
    
    try {
      _user = await AuthService.login(email, password);
    } catch (e) {
      // Handle error
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
```

#### ✅ **DEPOIS (StateNotifier via Core)**
```dart
import 'package:core/core.dart'; // BaseAuthNotifier from core

// Create app-specific implementation
class AppAuthNotifier extends BaseAuthNotifier {
  @override
  Future<void> login(String email, String password) async {
    setLoading();
    
    try {
      final user = await AuthService.login(email, password);
      setAuthenticated(user.toMap());
    } catch (e) {
      setError(e.toString());
    }
  }
  
  @override
  Future<void> logout() async {
    await AuthService.logout();
    setUnauthenticated();
  }
  
  @override
  Future<void> register(String email, String password, Map<String, dynamic> userData) async {
    setLoading();
    try {
      final user = await AuthService.register(email, password, userData);
      setAuthenticated(user.toMap());
    } catch (e) {
      setError(e.toString());
    }
  }
  
  @override
  Future<void> resetPassword(String email) async {
    await AuthService.resetPassword(email);
  }
  
  @override
  Future<void> checkAuthStatus() async {
    final user = await AuthService.getCurrentUser();
    if (user != null) {
      setAuthenticated(user.toMap());
    } else {
      setUnauthenticated();
    }
  }
}

// Register the provider
final appAuthProvider = StateNotifierProvider<AppAuthNotifier, AuthState>((ref) {
  return AppAuthNotifier();
});
```

### **Passo 5: Usar Utilities do Core**

#### ✅ **Widgets com Mixins**
```dart
import 'package:core/core.dart';

class LoginPage extends BaseConsumerWidget with LoadingMixin, ErrorHandlingMixin {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(appAuthProvider);
    
    return authState.when(
      loading: () => const CircularProgressIndicator(),
      authenticated: (user) => HomePage(),
      unauthenticated: () => _buildLoginForm(context, ref),
      error: (error) {
        // Auto show error using mixin
        WidgetsBinding.instance.addPostFrameCallback((_) {
          showError(context, error);
        });
        return _buildLoginForm(context, ref);
      },
    );
  }
  
  Widget _buildLoginForm(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        // Form fields...
        ElevatedButton(
          onPressed: () async {
            await withLoading(context, () async {
              await ref.read(appAuthProvider.notifier).login(email, password);
            });
          },
          child: Text('Login'),
        ),
      ],
    );
  }
}
```

#### ✅ **AsyncValue Widgets**
```dart
import 'package:core/core.dart';

class UserProfile extends BaseConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(userProfileProvider);
    
    return AsyncValueWidget<UserProfile>(
      value: userAsync,
      data: (profile) => Column(
        children: [
          Text(profile.name),
          Text(profile.email),
        ],
      ),
      loading: const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Column(
        children: [
          Text('Error: $error'),
          ElevatedButton(
            onPressed: () => ref.invalidate(userProfileProvider),
            child: Text('Retry'),
          ),
        ],
      ),
    );
  }
}
```

## 🎯 **Providers Específicos por App**

### **Gasometer App**
```dart
// gasometer_providers.dart
import 'package:core/core.dart';

final vehiclesProvider = FutureProvider<List<Vehicle>>((ref) async {
  return VehicleService.getAllVehicles();
});

final fuelRecordsProvider = FutureProvider.family<List<FuelRecord>, String>((ref, vehicleId) async {
  return FuelService.getRecordsByVehicle(vehicleId);
});

final expensesProvider = StateNotifierProvider<ExpensesNotifier, List<Expense>>((ref) {
  return ExpensesNotifier();
});
```

### **Plantis App**
```dart
// plantis_providers.dart
import 'package:core/core.dart';

final plantsProvider = FutureProvider<List<Plant>>((ref) async {
  return PlantService.getAllPlants();
});

final careTasksProvider = StateNotifierProvider<CareTasksNotifier, List<CareTask>>((ref) {
  return CareTasksNotifier();
});

final plantPhotosProvider = FutureProvider.family<List<PlantPhoto>, String>((ref, plantId) async {
  return PhotoService.getPhotosByPlant(plantId);
});
```

## 🔧 **Utilitários Avançados**

### **Forms com Core Utils**
```dart
import 'package:core/core.dart';

class AddVehicleForm extends BaseFormWidget {
  @override
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  
  @override
  List<Widget> buildFormFields(BuildContext context, WidgetRef ref) {
    return [
      TextFormField(
        decoration: InputDecoration(labelText: 'Nome do Veículo'),
        validator: (value) => value?.isEmpty ?? true ? 'Campo obrigatório' : null,
      ),
      TextFormField(
        decoration: InputDecoration(labelText: 'Placa'),
        validator: (value) => value?.isEmpty ?? true ? 'Campo obrigatório' : null,
      ),
    ];
  }
  
  @override
  Future<void> onFormSubmit(BuildContext context, WidgetRef ref) async {
    // Form submission logic
    await ref.read(vehiclesProvider.notifier).addVehicle(vehicleData);
  }
}
```

### **Navigation com Core Utils**
```dart
import 'package:core/core.dart';

class VehicleCard extends BaseConsumerWidget with NavigationMixin {
  final Vehicle vehicle;
  
  const VehicleCard({required this.vehicle});
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      child: ListTile(
        title: Text(vehicle.name),
        onTap: () => navigateTo(context, '/vehicle-details', arguments: vehicle.id),
      ),
    );
  }
}
```

## 📊 **Comparação: Antes vs Depois**

| Aspecto | Provider (Antes) | Riverpod via Core (Depois) |
|---------|------------------|----------------------------|
| **Dependencies** | Cada app declara Provider | Apenas core declara Riverpod |
| **Consistency** | Padrões diferentes por app | Padrões unificados via core |
| **Maintenance** | Atualizações em cada app | Atualizações centralizadas |
| **Boilerplate** | Muito código repetitivo | Utilities reutilizáveis |
| **Type Safety** | Limitada | Completa com compile-time |
| **Testing** | Setup complexo | Mocking simplificado |
| **Performance** | Rebuilds desnecessários | Rebuilds otimizados |

## ✅ **Checklist de Migração**

### **Para cada App:**
- [ ] Remover `provider` do pubspec.yaml
- [ ] Atualizar main.dart para `ProviderScope`
- [ ] Migrar widgets para `ConsumerWidget`
- [ ] Converter `ChangeNotifier` para `StateNotifier` 
- [ ] Usar `BaseConsumerWidget` do core
- [ ] Implementar mixins (`LoadingMixin`, `ErrorHandlingMixin`)
- [ ] Usar `AsyncValueWidget` para async data
- [ ] Override common providers quando necessário
- [ ] Testar funcionalidades críticas
- [ ] Verificar performance

### **Providers para Migrar:**
- [ ] AuthProvider → BaseAuthNotifier (via core)
- [ ] ThemeProvider → ThemeNotifier (via core)  
- [ ] SettingsProvider → PreferencesNotifier (via core)
- [ ] SyncProvider → SyncNotifier (via core)
- [ ] Outros providers específicos do app

## 🎉 **Benefícios da Migração**

### **Desenvolvimento:**
- ✅ **Padrões Consistentes** - Mesmo approach em todos os apps
- ✅ **Less Boilerplate** - Utilities reutilizáveis reduzem código
- ✅ **Better DX** - Hot reload mais rápido, debugging melhor
- ✅ **Type Safety** - Compile-time error detection

### **Manutenção:**
- ✅ **Single Source** - Atualizações de Riverpod centralizadas
- ✅ **Easier Testing** - Mocking e testing simplificados
- ✅ **Code Reuse** - Providers e notifiers compartilhados
- ✅ **Easier Onboarding** - Novos devs aprendem padrões únicos

### **Performance:**
- ✅ **Optimized Rebuilds** - Riverpod's smart dependency tracking
- ✅ **Memory Management** - Automatic disposal e lifecycle
- ✅ **Lazy Loading** - Providers carregados sob demanda
- ✅ **Bundle Size** - Single Riverpod instance no core

## 🚀 **Próximos Passos**

1. **Migrar app por app** seguindo este guia
2. **Testar funcionalidades** críticas após cada migração  
3. **Monitorar performance** e fix issues
4. **Remover Provider** completamente após todos migrados
5. **Documentar patterns** específicos de cada app
6. **Training team** nos novos padrões Riverpod

---

**🎯 Resultado:** Monorepo 100% padronizado com Riverpod centralizado via packages/core!