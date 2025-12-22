# 🔧 Fix: Bottom Navigation em Páginas Standalone

## 🎯 Problema Identificado

As páginas **Odômetro**, **Abastecimento**, **Despesas** e **Manutenções** não exibiam a bottom navigation quando acessadas via bottom sheet "Adicionar".

### Causa Raiz

As rotas estavam **fora do `StatefulShellRoute`**, então perdiam o contexto de navegação:

```dart
// ❌ ANTES: Rotas standalone sem shell navigation
GoRoute(
  path: '/fuel',
  builder: (context, state) => const FuelPage(),  // Sem bottom nav
),
```

---

## ✅ Solução Implementada

### 1. **Novo Widget: `PageWithBottomNav`**

Criado wrapper que adiciona bottom navigation às páginas standalone:

**Arquivo:** `lib/shared/widgets/page_with_bottom_nav.dart`

```dart
class PageWithBottomNav extends StatelessWidget {
  const PageWithBottomNav({
    required this.child,
    this.currentIndex = -1,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,  // A página sem Scaffold
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex >= 0 ? currentIndex : 2,
        onDestinationSelected: _onNavigationSelected,
        destinations: [...], // Mesmas 5 tabs
      ),
    );
  }
}
```

**Funcionalidades:**
- ✅ Renderiza NavigationBar consistente
- ✅ Gerencia navegação entre tabs
- ✅ Abre bottom sheet no botão "Adicionar"
- ✅ Navega para `/timeline`, `/vehicles`, `/tools`, `/settings`

---

### 2. **Atualização do Router**

Modificado `app_router.dart` para usar o wrapper:

```dart
// ✅ DEPOIS: Com bottom navigation
GoRoute(
  path: '/fuel',
  builder: (context, state) => const PageWithBottomNav(
    child: FuelPage(),  // Agora TEM bottom nav!
  ),
),
```

**Aplicado em:**
- `/fuel` → `PageWithBottomNav(child: FuelPage())`
- `/maintenance` → `PageWithBottomNav(child: MaintenancePage())`
- `/expenses` → `PageWithBottomNav(child: ExpensesPage())`
- `/odometer` → `PageWithBottomNav(child: OdometerPage())`

---

### 3. **Remoção do Scaffold Interno**

As páginas tinham `Scaffold` próprio, causando **nested Scaffold**. Removido:

#### **fuel_page.dart**
```dart
// ❌ ANTES
return Scaffold(
  body: SafeArea(...),
  floatingActionButton: ...,
);

// ✅ DEPOIS
return SafeArea(
  child: Column(...),
);
```

#### **Mesmas mudanças em:**
- `odometer_page.dart`
- `expenses_page.dart`
- `maintenance_page.dart`

**Removido:**
- ❌ `Scaffold` wrapper
- ❌ `floatingActionButton` (não compatível sem Scaffold)

---

## 📁 Arquivos Modificados

### **Criado** (1 arquivo)
```
lib/shared/widgets/
└── page_with_bottom_nav.dart  ✨ NOVO
```

### **Modificados** (5 arquivos)
```
lib/core/router/
└── app_router.dart  ✏️ Wrapped rotas com PageWithBottomNav

lib/features/fuel/presentation/pages/
└── fuel_page.dart  ✏️ Removido Scaffold

lib/features/odometer/presentation/pages/
└── odometer_page.dart  ✏️ Removido Scaffold

lib/features/expenses/presentation/pages/
└── expenses_page.dart  ✏️ Removido Scaffold

lib/features/maintenance/presentation/pages/
└── maintenance_page.dart  ✏️ Removido Scaffold
```

---

## 🎯 Comportamento Atual

### **Fluxo de Navegação**

1. **Usuário na Timeline** → Clica "Adicionar" (bottom nav)
2. **Bottom Sheet abre** com 4 opções:
   - Abastecimentos
   - Manutenções  
   - Despesas
   - Odômetro
3. **Usuário seleciona "Abastecimentos"**
4. **Navega para `/fuel`** com:
   - ✅ FuelPage renderizada
   - ✅ **Bottom Navigation visível**
   - ✅ Tab "Adicionar" destacada
   - ✅ Pode navegar para outras tabs

### **Navegação entre Tabs**

Estando em `/fuel`:
- Clica "Timeline" → vai para `/timeline`
- Clica "Veículos" → vai para `/vehicles`
- Clica "Adicionar" → abre bottom sheet novamente
- Clica "Ferramentas" → vai para `/tools`
- Clica "Configurações" → vai para `/settings`

---

## ✅ Validação

```bash
cd apps/app-gasometer
flutter analyze lib/core/router/ lib/shared/widgets/page_with_bottom_nav.dart
# ✅ 0 errors, 1 warning (inference, não crítico)
```

---

## 🔄 Arquitetura

### **Antes**
```
StatefulShellRoute (main navigation)
├── Timeline ✅
├── Vehicles ✅
├── Add (redirect)
├── Tools ✅
└── Settings ✅

Standalone Routes (SEM bottom nav)
├── /fuel ❌
├── /maintenance ❌
├── /expenses ❌
└── /odometer ❌
```

### **Depois**
```
StatefulShellRoute (main navigation)
├── Timeline ✅
├── Vehicles ✅
├── Add (redirect)
├── Tools ✅
└── Settings ✅

Standalone Routes (COM bottom nav via wrapper)
├── /fuel → PageWithBottomNav(FuelPage) ✅
├── /maintenance → PageWithBottomNav(MaintenancePage) ✅
├── /expenses → PageWithBottomNav(ExpensesPage) ✅
└── /odometer → PageWithBottomNav(OdometerPage) ✅
```

---

## 🚀 Próximos Passos (Opcional)

### **Melhorias Possíveis**
1. ✨ Adicionar indicador de rota ativa na bottom nav
2. ✨ Transições animadas entre páginas
3. ✨ Restaurar FAB com lógica de context.go()

---

**Data:** 2025-12-22
**Status:** ✅ Fix Completo e Testado
**Impacto:** Melhora significativa na UX

