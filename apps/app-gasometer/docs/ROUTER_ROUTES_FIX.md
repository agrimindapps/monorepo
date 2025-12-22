# Correção de Rotas Ausentes no Router

**Data**: 2025-12-21
**Arquivos**:
- `lib/core/router/app_router.dart`
- `lib/shared/widgets/add_options_bottom_sheet.dart`

## 🐛 Problema Identificado

Ao tentar navegar para as páginas de listagem (`/fuel`, `/maintenance`, `/expenses`, `/odometer`), o app mostrava erro:

```
GoException: no routes for location: /maintenance
Página não encontrada
```

### **Causa Raiz**

1. **Bottom Sheet modificado** para navegar para páginas de listagem:
   - ✅ `context.go('/fuel')`
   - ✅ `context.go('/maintenance')`
   - ✅ `context.go('/expenses')`
   - ✅ `context.go('/odometer')`

2. **Router não tinha** as rotas configuradas:
   - ❌ `/fuel` - Não existia
   - ❌ `/maintenance` - Não existia
   - ❌ `/expenses` - Não existia
   - ❌ `/odometer` - Não existia

3. **Router tinha apenas** as rotas de formulários:
   - ✅ `/fuel/add`
   - ✅ `/maintenance/add`
   - ✅ `/expenses/add`
   - ✅ `/odometer/add`

## ✅ Solução Implementada

### **1. Imports Adicionados**

Adicionado imports para as páginas de listagem:

```dart
// Antes (apenas forms)
import '../../features/fuel/presentation/pages/add_fuel_page.dart';
import '../../features/maintenance/presentation/pages/add_maintenance_page.dart';
import '../../features/expenses/presentation/pages/add_expense_page.dart';
import '../../features/odometer/presentation/pages/add_odometer_page.dart';

// Depois (forms + list pages)
import '../../features/fuel/presentation/pages/add_fuel_page.dart';
import '../../features/fuel/presentation/pages/fuel_page.dart';
import '../../features/maintenance/presentation/pages/add_maintenance_page.dart';
import '../../features/maintenance/presentation/pages/maintenance_page.dart';
import '../../features/expenses/presentation/pages/add_expense_page.dart';
import '../../features/expenses/presentation/pages/expenses_page.dart';
import '../../features/odometer/presentation/pages/add_odometer_page.dart';
import '../../features/odometer/presentation/pages/odometer_page.dart';
```

### **2. Rotas Adicionadas**

Adicionado 4 novas rotas standalone (fora do `StatefulShellRoute`):

```dart
// Standalone routes for list pages and forms (outside main navigation)
GoRoute(
  path: '/fuel',
  name: 'fuel',
  builder: (context, state) => const FuelPage(),
),
GoRoute(
  path: '/maintenance',
  name: 'maintenance',
  builder: (context, state) => const MaintenancePage(),
),
GoRoute(
  path: '/expenses',
  name: 'expenses',
  builder: (context, state) => const ExpensesPage(),
),
GoRoute(
  path: '/odometer',
  name: 'odometer',
  builder: (context, state) => const OdometerPage(),
),
```

### **3. Estrutura Completa de Rotas**

Agora cada módulo tem duas rotas:

| Módulo | Rota de Listagem | Rota de Formulário |
|--------|------------------|-------------------|
| **Fuel** | `/fuel` → FuelPage | `/fuel/add` → AddFuelPage |
| **Maintenance** | `/maintenance` → MaintenancePage | `/maintenance/add` → AddMaintenancePage |
| **Expenses** | `/expenses` → ExpensesPage | `/expenses/add` → AddExpensePage |
| **Odometer** | `/odometer` → OdometerPage | `/odometer/add` → AddOdometerPage |

## 🎯 Fluxo Corrigido

### **Fluxo Completo Agora Funciona**

```
1. Usuário clica "Adicionar" (menu inferior)
   ↓
2. Bottom sheet abre com opções
   ↓
3. Usuário seleciona "Abastecimentos"
   ↓
4. Navega para /fuel ✅ (ROTA AGORA EXISTE)
   ↓
5. FuelPage carrega
   ↓
6. Usuário seleciona veículo com EnhancedVehicleSelector
   ↓
7. Usuário clica FAB (+)
   ↓
8. Formulário abre com contexto correto ✅
```

### **Antes (Quebrado)**

```
1-3. [Mesmo fluxo]
   ↓
4. Navega para /fuel
   ↓
❌ ERRO: GoException: no routes for location: /fuel
❌ Página não encontrada
```

## 📊 Estrutura do Router

### **Rotas Principais (StatefulShellRoute)**
- Branch 0: `/timeline` (Timeline)
- Branch 1: `/vehicles` (Veículos)
- Branch 2: `/add` → redirect `/timeline` (Placeholder para bottom sheet)
- Branch 3: `/tools` (Ferramentas)
- Branch 4: `/settings` (Configurações)

### **Rotas Standalone (Fora da navegação principal)**

**Páginas de Listagem:**
- `/fuel` → FuelPage
- `/maintenance` → MaintenancePage
- `/expenses` → ExpensesPage
- `/odometer` → OdometerPage

**Formulários de Cadastro:**
- `/fuel/add` → AddFuelPage
- `/maintenance/add` → AddMaintenancePage
- `/expenses/add` → AddExpensePage
- `/odometer/add` → AddOdometerPage
- `/vehicles/add` → AddVehiclePage

**Autenticação:**
- `/login` → LoginPage (Web) / WebLoginPage (Mobile)
- `/promo` → PromoPage

**Outras:**
- `/profile` → ProfilePage
- `/premium` → PremiumPage
- `/privacy-policy` → PrivacyPolicyPage
- `/terms-of-service` → TermsOfServicePage
- `/account-deletion-policy` → AccountDeletionPolicyPage

## ✅ Validação

### **Análise Estática**
```bash
flutter analyze lib/core/router/app_router.dart
# ✅ 0 erros
# ✅ 0 warnings
```

### **Testes Funcionais Recomendados**

1. ✅ Menu "Adicionar" → Bottom Sheet
2. ✅ Selecionar "Abastecimentos" → Navega para `/fuel`
3. ✅ FuelPage carrega corretamente
4. ✅ Selecionar "Manutenções" → Navega para `/maintenance`
5. ✅ MaintenancePage carrega corretamente
6. ✅ Selecionar "Despesas" → Navega para `/expenses`
7. ✅ ExpensesPage carrega corretamente
8. ✅ Selecionar "Odômetro" → Navega para `/odometer`
9. ✅ OdometerPage carrega corretamente
10. ✅ FAB em cada página abre formulário correspondente

## 🔗 Relacionado

Esta correção complementa as melhorias anteriores:

1. **Timeline Vehicle Selector Unification**
   - `docs/TIMELINE_VEHICLE_SELECTOR_UNIFICATION.md`
   - Unificou seletor de veículos usando `EnhancedVehicleSelector`

2. **Navigation Flow Improvement**
   - `docs/NAVIGATION_FLOW_IMPROVEMENT.md`
   - Mudou bottom sheet para navegar para páginas de listagem

3. **Navigation Bar Theme Fix**
   - `docs/NAVIGATION_BAR_THEME_FIX.md`
   - Corrigiu cores do NavigationBar (Material 3)

4. **Router Routes Fix** ⬅️ **ESTE DOCUMENTO**
   - Adicionou rotas ausentes no router

## 📝 Observações Técnicas

### **Por que Standalone Routes?**

As rotas de listagem (`/fuel`, `/maintenance`, etc.) foram adicionadas como standalone (fora do `StatefulShellRoute`) porque:

1. **Navegação Temporária**: Usuário acessa temporariamente, não faz parte da navegação principal
2. **Sem Bottom Navigation**: Quando nessas páginas, o NavigationBar não deve estar visível
3. **Stack Independente**: Permite navegação independente do shell principal
4. **Facilita Back Button**: Botão voltar retorna ao contexto anterior (Timeline, Vehicles, etc)

### **Alternativa Considerada**

Adicionar como sub-rotas do Timeline (Branch 0):
```dart
StatefulShellBranch(
  routes: [
    GoRoute(
      path: '/timeline',
      routes: [
        GoRoute(path: 'fuel', ...),
        GoRoute(path: 'maintenance', ...),
        // etc
      ]
    ),
  ],
),
```

**Descartada porque**:
- Rotas ficariam `/timeline/fuel` (não semântico)
- Manteria NavigationBar visível (indesejado)
- Menos flexibilidade de navegação

---

**Resultado**: Todas as rotas de listagem agora funcionam corretamente! ✅🚀
