# Relatório de Migração: go_router ^16.1.0

## 📊 Análise de Impacto

### **Apps Impactados:**
- ✅ **app-gasometer** - go_router: ^16.1.0 (JÁ ATUALIZADO)
- ✅ **app-petiveti** - go_router: ^16.1.0 (JÁ ATUALIZADO)
- ✅ **app-plantis** - go_router: ^16.1.0 (JÁ ATUALIZADO)
- ❌ **app-receituagro** - Não usa go_router (Provider puro)
- ❌ **app-taskolist** - Não usa go_router (Riverpod com navegação manual)

**Total:** 3/5 apps usam go_router - todos já na versão ^16.1.0

### **Status no Core:**
❌ **go_router:** NÃO EXISTE no packages/core/pubspec.yaml
❌ **Routing Utilities:** NÃO EXISTE arquitetura unificada de roteamento

### **Complexidade de Navegação:**
- **app-gasometer**: MÉDIA (Provider + Guards + Platform-aware routing)
- **app-petiveti**: ALTA (Riverpod + Complex nested routes + Shell routing)
- **app-plantis**: ALTA (Provider + Complex redirects + Web-optimized routing)

---

## 🔍 Análise Técnica

### **Compatibilidade de Versões:**
```yaml
# Versão atual nos apps:
go_router: ^16.1.0     # IDÊNTICA em todos os 3 apps ✅

# Versão no Core atual:
go_router: NÃO EXISTE  # PRECISA ADICIONAR

# Versão recomendada para Core:
go_router: ^16.1.0     # ADICIONAR - sem breaking changes
```

### **Dependências (go_router ^16.1.0):**
```yaml
dependencies:
  flutter: ">=3.10.0"
  logging: ^1.1.1
  meta: ^1.9.0
dev_dependencies:
  go_router_builder: ^3.1.0+  # APENAS se usar TypedGoRoute (não usado)
```
- ✅ Todas são compatíveis com Flutter 3.10.0+
- ✅ Nenhum app usa go_router_builder ou TypedGoRoute
- ✅ Sem breaking changes detectados na versão 16.1.0

### **Padrões de Navegação Implementados:**

#### **app-gasometer (Provider + Guard System):**
```dart
// Padrão: Provider-aware routing com custom guards
class AppRouter {
  static GoRouter router(BuildContext context) {
    AuthProvider? authProvider = Provider.of<AuthProvider>(context, listen: false);
    final routeGuard = RouteGuard(authProvider, platformService);

    return GoRouter(
      redirect: (context, state) => routeGuard.handleRedirect(state.matchedLocation),
      routes: [/* ShellRoute com bottom navigation */]
    );
  }
}

// Custom RouteGuard com 4 tipos de rota:
enum RouteType { alwaysPublic, publicOnly, authProtected, appContent }
```

#### **app-petiveti (Riverpod + Provider Integration):**
```dart
// Padrão: Riverpod Provider com Splash-first initialization
final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/splash',
    redirect: (context, state) {
      final authState = ref.read(authProvider);  // Riverpod integration
      // Complex nested routing com deep authentication checks
    },
    routes: [/* ShellRoute + 15+ nested routes */]
  );
});
```

#### **app-plantis (Provider + Web-Optimized):**
```dart
// Padrão: Web-first com Provider + Platform-aware routing
static GoRouter router(BuildContext context) {
  final authProvider = context.read<providers.AuthProvider>();
  final initialLocation = kIsWeb ? promotional : login;  // Platform-aware

  return GoRouter(
    navigatorKey: NavigationService.navigatorKey,  // Global navigation
    refreshListenable: authProvider,  // Auto-refresh em auth changes
    redirect: (context, state) => {/* Complex web/mobile logic */}
  );
}
```

### **Análise de Rotas Conflitantes:**

#### **Rotas Compartilhadas (CONFLITOS POTENCIAIS):**
```
CONFLITOS IDENTIFICADOS:
/                    - Usado por todos (diferentes conteúdos)
/login              - app-gasometer, app-petiveti, app-plantis
/profile            - app-gasometer, app-petiveti
/expenses           - app-gasometer, app-petiveti
/promo              - app-gasometer, app-petiveti
/premium            - app-gasometer, app-plantis
/settings           - app-gasometer, app-plantis
```

#### **Rotas Específicas por App:**
```
app-gasometer ESPECÍFICAS:
/fuel, /odometer, /maintenance, /reports, /devices, /privacy, /terms

app-petiveti ESPECÍFICAS:
/animals, /appointments, /vaccines, /medications, /weight, /reminders,
/calculators/*, /subscription, /splash, /register

app-plantis ESPECÍFICAS:
/plants/*, /tasks, /welcome, /promotional, /notifications-settings,
/backup-settings, /device-management, /data-export
```

### **Integration Patterns com State Management:**

#### **Provider Integration (gasometer, plantis):**
```dart
// Direct Provider access
AuthProvider authProvider = Provider.of<AuthProvider>(context, listen: false);

// Problemas potenciais:
- Race conditions durante inicialização
- Null safety issues durante app startup
- Context dependency para router creation
```

#### **Riverpod Integration (petiveti):**
```dart
// Riverpod Provider pattern
final appRouterProvider = Provider<GoRouter>((ref) => {
  ref.read(authProvider);  // Type-safe provider access
});

// Benefícios:
- Melhor type safety
- Dependency injection automática
- Menos race conditions
```

---

## 🎯 Plano de Migração

### **Passo 1: Adicionar go_router ao Core**
```yaml
# packages/core/pubspec.yaml
dependencies:
  go_router: ^16.1.0          # ADICIONAR

# Adicionar routing utilities compartilhadas
```

### **Passo 2: Criar Core Routing Architecture**
```dart
// packages/core/lib/routing/core_router.dart
abstract class CoreRouter {
  static const String home = '/';
  static const String login = '/login';
  static const String profile = '/profile';
  // ... shared route constants
}

// packages/core/lib/routing/route_guard.dart
abstract class RouteGuardInterface {
  String? handleRedirect(String currentLocation);
  String getInitialLocation();
}

// packages/core/lib/routing/navigation_service.dart
class NavigationService {
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  // ... shared navigation utilities
}
```

### **Passo 3: Core Export Setup**
```dart
// packages/core/lib/core.dart
export 'package:go_router/go_router.dart';

// Routing utilities
export 'routing/core_router.dart';
export 'routing/route_guard.dart';
export 'routing/navigation_service.dart';
```

### **Passo 4: Remover go_router dos Apps**

#### **4.1. app-gasometer (PRIMEIRO - Provider com Guards)**
```yaml
# REMOVER de app-gasometer/pubspec.yaml:
# go_router: ^16.1.0

# ATUALIZAR import:
# DE: import 'package:go_router/go_router.dart';
# PARA: import 'package:core/core.dart';
```

#### **4.2. app-plantis (SEGUNDO - Provider com Web-optimization)**
```yaml
# REMOVER de app-plantis/pubspec.yaml:
# go_router: ^16.1.0

# MANTER NavigationService.navigatorKey pattern
# ADAPTAR para usar core routing utilities
```

#### **4.3. app-petiveti (TERCEIRO - Riverpod híbrido)**
```yaml
# REMOVER de app-petiveti/pubspec.yaml:
# go_router: ^16.1.0

# CUIDADO: appRouterProvider pattern deve ser preservado
# Riverpod + go_router integration é mais complexa
```

### **Passo 5: Resolver Conflitos de Rota**
```dart
// Strategy: App-specific route prefixes
app-gasometer:     /gas/*     (ou manter / como home específico)
app-petiveti:      /vet/*     (ou manter / como home específico)
app-plantis:       /plants/*  (já usa este padrão)

// Shared routes mantidas em core:
CoreRouter.login = '/login'    // Unified login experience
CoreRouter.profile = '/profile'  // Shared profile structure
```

---

## 🧪 Plano de Teste

### **Testes por App:**

#### **app-gasometer (Provider + Guards - CRÍTICO):**
```bash
cd apps/app-gasometer
flutter clean
flutter pub get
flutter analyze
flutter test
flutter run

# Pontos críticos de teste:
✅ RouteGuard logic funcionando
✅ Provider context injection working
✅ Platform-specific routing (web vs mobile)
✅ Auth state redirects
✅ Error page navigation
```

#### **app-plantis (Web-Optimized - CRÍTICO):**
```bash
cd apps/app-plantis
flutter clean
flutter pub get
flutter analyze
flutter test
flutter run -d web  # Teste web específico
flutter run -d chrome --web-renderer html  # Test web renderer

# Pontos críticos de teste:
✅ NavigationService.navigatorKey functioning
✅ Web vs mobile initial routes
✅ refreshListenable: authProvider working
✅ Complex nested routes (/plants/add, /plants/edit/:id)
✅ Shell route navigation
```

#### **app-petiveti (Riverpod + Complex Nested - MUITO CRÍTICO):**
```bash
cd apps/app-petiveti
flutter clean
flutter pub get
flutter analyze
flutter test
flutter run

# Pontos críticos de teste:
✅ appRouterProvider initialization
✅ ref.read(authProvider) functioning
✅ Splash -> Auth -> App flow
✅ 15+ nested routes navigation
✅ Complex calculator routes (/calculators/*)
✅ ShellRoute + BottomNavShell integration
```

### **Testes de Integração Cross-App:**
```bash
# Test shared routes don't conflict:
flutter run apps/app-gasometer  # Navigate to /login
flutter run apps/app-petiveti    # Navigate to /login
flutter run apps/app-plantis     # Navigate to /login

# Should show app-specific login pages, not conflict
```

### **Core Package Testing:**
```bash
cd packages/core
flutter analyze
flutter test

# Verify go_router export works:
flutter create test_app --no-offline
# Add core dependency
# Test: import 'package:core/core.dart'; GoRouter usage
```

---

## ⚠️ Riscos e Mitigações

### **Riscos Identificados:**

#### **🔴 ALTO RISCO: app-petiveti Riverpod + Go Router**
- **Problema:** appRouterProvider com ref.read() pode quebrar após migração
- **Mitigação:** Manter Riverpod provider pattern intacto, apenas mudar import
- **Validação:** Test ref.read(authProvider) + goRouter integration extensively
- **Rollback:** Mais complexo devido ao Riverpod dependency

#### **🟡 MÉDIO RISCO: Conflitos de Rota entre Apps**
- **Problema:** /login, /profile, /expenses existem em múltiplos apps
- **Mitigação:** Apps rodaram independentemente - não há conflito real de runtime
- **Validação:** Cada app mantém sua própria instância do GoRouter
- **Observação:** Conflitos são apenas conceituais, não técnicos

#### **🟡 MÉDIO RISCO: Provider Context Dependency (gasometer, plantis)**
- **Problema:** Router creation depende de Provider context access
- **Mitigação:** Core package não vai mudar context access patterns
- **Validação:** Provider.of<AuthProvider>() deve funcionar normalmente
- **Teste:** Verificar race conditions durante app initialization

#### **🟡 MÉDIO RISCO: Web-Specific Features (plantis)**
- **Problema:** NavigationService.navigatorKey e platform-aware routing
- **Mitigação:** Core package vai incluir NavigationService utilities
- **Validação:** kIsWeb conditional routing deve permanecer inalterado
- **Teste:** Web build + mobile build funcionando

#### **🟢 BAIXO RISCO: Route Guard Logic (gasometer)**
- **Problema:** Custom RouteGuard pode quebrar
- **Mitigação:** RouteGuard é app-specific, não será movido para core
- **Validação:** RouteGuard.handleRedirect() funcionando
- **Observação:** Apenas import path muda

### **Rollback Plan:**
```bash
# Por app, rollback é direto:
git checkout HEAD~1 -- apps/app-gasometer/pubspec.yaml
git checkout HEAD~1 -- apps/app-plantis/pubspec.yaml
git checkout HEAD~1 -- apps/app-petiveti/pubspec.yaml

cd apps/app-{NAME}
flutter pub get
flutter run  # Should restore original go_router imports
```

---

## 📈 Benefícios Esperados

### **Unificação de Dependências:**
- ✅ **go_router centralizado** para todos os apps
- ✅ **Consistent version** ^16.1.0 em todo monorepo
- ✅ **Shared routing utilities** disponíveis

### **Developer Experience:**
- ✅ **Single import** para go_router: `import 'package:core/core.dart'`
- ✅ **Shared navigation constants** e utilities
- ✅ **Consistent routing patterns** entre apps
- ✅ **Reduced dependency management** overhead

### **Architecture Benefits:**
- ✅ **Core routing utilities** reutilizáveis
- ✅ **Unified navigation service** para features avançadas
- ✅ **Shared route constants** para deep linking consistency
- ✅ **Platform-aware routing** utilities disponíveis

### **Maintenance Benefits:**
- ✅ **Single version** to update across monorepo
- ✅ **Shared routing logic** para patterns comuns
- ✅ **Easier testing** com routing utilities centralizadas
- ✅ **Better code reuse** para navigation features

---

## 🏗️ Estratégia de Routing Unificado

### **Core Routing Architecture:**
```dart
// packages/core/lib/routing/core_router.dart
class CoreRouter {
  // Shared route constants
  static const String home = '/';
  static const String login = '/login';
  static const String profile = '/profile';
  static const String settings = '/settings';
  static const String premium = '/premium';
  static const String expenses = '/expenses';

  // App-specific prefixes (optional future enhancement)
  static const String gasometerPrefix = '/gas';
  static const String petivetiPrefix = '/vet';
  static const String plantisPrefix = '/plants';
}
```

### **Shared Navigation Service:**
```dart
// packages/core/lib/routing/navigation_service.dart
class NavigationService {
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  // Utility methods for common navigation patterns
  static void goToLogin() => navigatorKey.currentContext?.go(CoreRouter.login);
  static void goToProfile() => navigatorKey.currentContext?.go(CoreRouter.profile);
  static void goHome() => navigatorKey.currentContext?.go(CoreRouter.home);

  // Platform-aware utilities
  static String getInitialRoute({bool isWeb = false}) {
    return isWeb ? CoreRouter.home : CoreRouter.login;
  }
}
```

### **Abstract Route Guard Interface:**
```dart
// packages/core/lib/routing/route_guard.dart
abstract class RouteGuardInterface {
  String? handleRedirect(String currentLocation);
  String getInitialLocation();
}

// Shared route types for consistent guard logic
enum CoreRouteType {
  alwaysPublic,    // /privacy, /terms
  publicOnly,      // /promo, /login
  authProtected,   // requires authentication
  appContent,      // main app content
}
```

### **App-Specific Router Extensions:**
```dart
// Each app extends core routing
class GasometerRouter extends CoreRouter {
  static const String fuel = '/fuel';
  static const String maintenance = '/maintenance';
  static const String devices = '/devices';
  // ... app-specific routes
}

class PetivetiRouter extends CoreRouter {
  static const String animals = '/animals';
  static const String appointments = '/appointments';
  static const String vaccines = '/vaccines';
  // ... app-specific routes
}
```

---

## ✅ Critérios de Sucesso

### **Pré-Migração:**
- [ ] go_router ^16.1.0 adicionado ao core
- [ ] Core routing utilities criadas
- [ ] NavigationService disponível
- [ ] Core exports configurados

### **Por App Migrado:**
- [ ] pubspec.yaml limpo (sem go_router dependency)
- [ ] import 'package:core/core.dart' funcionando
- [ ] flutter analyze limpo
- [ ] GoRouter initialization working
- [ ] All existing routes functioning
- [ ] App-specific navigation patterns preserved

### **Pós-Migração Routing Unificado:**
- [ ] Todos os 3 apps com go_router via core
- [ ] NavigationService utilities funcionando
- [ ] Route constants compartilhados disponíveis
- [ ] Platform-aware routing mantido
- [ ] Authentication redirects funcionando
- [ ] Nested routes preservadas
- [ ] Shell route navigation working

### **Quality Gates:**
- [ ] Zero routing regressions
- [ ] Performance mantida (routing não mais lento)
- [ ] No memory leaks from router instances
- [ ] Deep linking funcionando
- [ ] Web routing (plantis) preservado
- [ ] Mobile routing (gasometer, petiveti) preservado

---

## 🚀 Cronograma Sugerido

### **Dia 1: Core Setup + Architecture**
- [ ] Adicionar go_router ao core package
- [ ] Criar core routing utilities (CoreRouter, NavigationService)
- [ ] Setup route guard interface
- [ ] Configure core exports
- [ ] Test core package build

### **Dia 2: Simple Migration (gasometer)**
- [ ] Migrar app-gasometer (Provider + Guards pattern)
- [ ] Update imports para core package
- [ ] Test RouteGuard functionality
- [ ] Validate platform-specific routing
- [ ] Test authentication redirects

### **Dia 3: Complex Migration (plantis)**
- [ ] Migrar app-plantis (Web-optimized pattern)
- [ ] Preserve NavigationService.navigatorKey usage
- [ ] Test web vs mobile routing
- [ ] Validate refreshListenable: authProvider
- [ ] Test complex nested routes

### **Dia 4: Critical Migration (petiveti)**
- [ ] Migrar app-petiveti (Riverpod + Complex nested)
- [ ] Preserve appRouterProvider pattern
- [ ] Test ref.read(authProvider) integration
- [ ] Validate splash -> auth -> app flow
- [ ] Test all 15+ nested routes

### **Dia 5: Integration + Optimization**
- [ ] Cross-app routing testing
- [ ] Performance validation
- [ ] Documentation de routing patterns
- [ ] Final quality assurance
- [ ] Rollback procedures documented

---

## 📋 Checklist de Execução

```bash
# FASE 1: Preparar Core Routing
[ ] cd packages/core
[ ] Adicionar "go_router: ^16.1.0" ao pubspec.yaml
[ ] Criar lib/routing/ directory
[ ] Implementar CoreRouter, NavigationService, RouteGuardInterface
[ ] Atualizar lib/core.dart exports
[ ] flutter pub get
[ ] flutter analyze
[ ] flutter test

# FASE 2: Migrar app-gasometer (Provider + Guards)
[ ] cd apps/app-gasometer
[ ] Remover "go_router: ^16.1.0" do pubspec.yaml
[ ] Atualizar imports: package:core/core.dart
[ ] flutter clean && flutter pub get
[ ] flutter analyze
[ ] flutter test
[ ] flutter run (test routing funcionando)
[ ] Test authentication flows
[ ] Test platform-specific routing

# FASE 3: Migrar app-plantis (Web-Optimized)
[ ] cd apps/app-plantis
[ ] Remover "go_router: ^16.1.0" do pubspec.yaml
[ ] Atualizar imports, preservar NavigationService usage
[ ] flutter clean && flutter pub get
[ ] flutter analyze
[ ] flutter test
[ ] flutter run -d web (test web routing)
[ ] flutter run (test mobile routing)
[ ] Test complex nested routes

# FASE 4: Migrar app-petiveti (Riverpod + Complex)
[ ] cd apps/app-petiveti
[ ] Remover "go_router: ^16.1.0" do pubspec.yaml
[ ] Atualizar imports, preservar appRouterProvider
[ ] flutter clean && flutter pub get
[ ] flutter analyze
[ ] flutter test
[ ] flutter run (test Riverpod integration)
[ ] Test splash -> auth -> app flow
[ ] Test all calculator nested routes
[ ] Test ShellRoute + BottomNavShell

# FASE 5: Final Validation
[ ] Test all 3 apps independently
[ ] Verify no route conflicts
[ ] Performance testing
[ ] Documentation updates
[ ] Commit & Push
```

---

## 🎖️ Classificação de Migração

**Complexidade:** 🟡 **MÉDIA-ALTA** (7/10)
**Risco:** 🟡 **MÉDIO** (6/10)
**Benefício:** 🔥 **ALTO** (8/10)
**Tempo:** 🟡 **4-5 DIAS**

### **Critical Success Factors:**
- ✅ **Riverpod integration** preservado (app-petiveti)
- ✅ **Web routing** mantido (app-plantis)
- ✅ **Route guard logic** funcionando (app-gasometer)
- ✅ **Nested routes** preservadas (todos os apps)
- ✅ **Authentication flows** intactos
- ✅ **Platform-specific behavior** mantido

### **Unique Challenges:**
- **Multiple state management patterns**: Provider (2 apps) + Riverpod (1 app)
- **Platform-aware routing**: Web-optimized (plantis) + Mobile-first (gasometer, petiveti)
- **Complex nested routing**: 15+ routes (petiveti), Deep nesting (plantis)
- **Authentication integration**: 3 different auth flow patterns
- **Custom guard systems**: Sophisticated RouteGuard logic (gasometer)

---

**Status:** 🟡 **READY FOR CAREFUL EXECUTION**
**Recomendação:** **EXECUTAR APÓS get_it + injectable** (para ganhar experiência com core migrations)
**Impacto:** 3/5 apps com routing unificado + shared navigation utilities

---

*Esta migração estabelecerá o foundation para navegação unificada em todo o monorepo, permitindo shared routing utilities e patterns consistentes entre apps.*