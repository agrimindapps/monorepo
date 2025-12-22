# 🔧 Restauração do FloatingActionButton

## 🎯 Problema

Após implementar o `PageWithBottomNav`, os **FloatingActionButtons** (FAB) das páginas de listagem não apareciam mais.

### Causa

As páginas tiveram seus `Scaffold` removidos, e o FAB estava definido no `floatingActionButton` do Scaffold.

---

## ✅ Solução Implementada

### **Atualização do `PageWithBottomNav`**

Adicionados parâmetros para configurar o FAB:

```dart
class PageWithBottomNav extends StatelessWidget {
  const PageWithBottomNav({
    required this.child,
    this.currentIndex = -1,
    this.fabRoute,      // ✨ NOVO: Rota para navegar
    this.fabIcon = Icons.add,  // ✨ NOVO: Ícone do FAB
    this.fabLabel,      // ✨ NOVO: Label do FAB
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(...),
      floatingActionButton: fabRoute != null
          ? FloatingActionButton.extended(
              onPressed: () => context.push(fabRoute!),
              icon: Icon(fabIcon),
              label: Text(fabLabel ?? 'Adicionar'),
            )
          : null,
    );
  }
}
```

---

### **Atualização das Rotas**

Cada rota agora especifica seu FAB:

#### **Fuel (Abastecimentos)**
```dart
GoRoute(
  path: '/fuel',
  builder: (context, state) => const PageWithBottomNav(
    fabRoute: '/fuel/add',           // ✅ Rota de adição
    fabIcon: Icons.local_gas_station, // ✅ Ícone específico
    fabLabel: 'Adicionar',            // ✅ Label
    child: FuelPage(),
  ),
),
```

#### **Maintenance (Manutenções)**
```dart
GoRoute(
  path: '/maintenance',
  builder: (context, state) => const PageWithBottomNav(
    fabRoute: '/maintenance/add',
    fabIcon: Icons.build,
    fabLabel: 'Adicionar',
    child: MaintenancePage(),
  ),
),
```

#### **Expenses (Despesas)**
```dart
GoRoute(
  path: '/expenses',
  builder: (context, state) => const PageWithBottomNav(
    fabRoute: '/expenses/add',
    fabIcon: Icons.attach_money,
    fabLabel: 'Adicionar',
    child: ExpensesPage(),
  ),
),
```

#### **Odometer (Odômetro)**
```dart
GoRoute(
  path: '/odometer',
  builder: (context, state) => const PageWithBottomNav(
    fabRoute: '/odometer/add',
    fabIcon: Icons.speed,
    fabLabel: 'Adicionar',
    child: OdometerPage(),
  ),
),
```

---

## 🎨 Resultado Visual

### **Antes** ❌
```
┌──────────────────────────┐
│  Abastecimentos          │
│  (lista de registros)    │
│                          │
│                          │
│                          │
│                          │
└──────────────────────────┘
  Timeline | Veículos | + | Tools | Config
```
**Sem FloatingActionButton!**

---

### **Depois** ✅
```
┌──────────────────────────┐
│  Abastecimentos          │
│  (lista de registros)    │
│                          │
│                          │
│                      ┌───┐
│                      │⛽+│  <- FAB
│                      └───┘
└──────────────────────────┘
  Timeline | Veículos | + | Tools | Config
```
**Com FloatingActionButton customizado!**

---

## 📊 Características do FAB

### **Por Página**

| Página | Ícone | Label | Rota de Destino |
|--------|-------|-------|-----------------|
| Fuel | ⛽ `local_gas_station` | "Adicionar" | `/fuel/add` |
| Maintenance | 🔧 `build` | "Adicionar" | `/maintenance/add` |
| Expenses | 💵 `attach_money` | "Adicionar" | `/expenses/add` |
| Odometer | 🚗 `speed` | "Adicionar" | `/odometer/add` |

### **Comportamento**
- **Tipo:** `FloatingActionButton.extended` (ícone + label)
- **Ação:** Navega para a rota de adição via `context.push()`
- **Posicionamento:** Padrão (bottom-right)
- **Aparece:** Apenas nas páginas com `fabRoute` definido

---

## 📁 Arquivos Modificados

```
lib/shared/widgets/
└── page_with_bottom_nav.dart  ✏️ Adicionados parâmetros FAB

lib/core/router/
└── app_router.dart  ✏️ Configurados FABs para 4 rotas
```

---

## ✅ Validação

```bash
cd apps/app-gasometer
flutter analyze lib/core/router/ lib/shared/widgets/page_with_bottom_nav.dart
# ✅ 0 errors, 1 warning (inference não crítico)
```

---

## 🔄 Comparação: Antes vs Depois

### **Arquitetura Anterior**
```dart
// Página com Scaffold próprio
class FuelPage extends ConsumerStatefulWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ...,
      floatingActionButton: _buildFloatingActionButton(context),  // ✅ FAB
    );
  }
  
  Widget _buildFloatingActionButton(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: () => context.push('/fuel/add'),
      icon: Icon(Icons.local_gas_station),
      label: Text('Adicionar'),
    );
  }
}
```

### **Arquitetura Atual**
```dart
// Página SEM Scaffold (body puro)
class FuelPage extends ConsumerStatefulWidget {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(...),  // Apenas o conteúdo
    );
  }
  
  // Método _buildFloatingActionButton ainda existe mas não é usado
  // FAB agora é renderizado pelo PageWithBottomNav wrapper
}
```

---

## 🎯 Vantagens da Nova Abordagem

1. ✅ **Consistência:** FAB configurado no router, não na página
2. ✅ **Simples:** Apenas 3 parâmetros (route, icon, label)
3. ✅ **Manutenível:** Mudanças no router, não em cada página
4. ✅ **Flexível:** Fácil adicionar/remover FAB por rota
5. ✅ **DRY:** Não repetir lógica de FAB em cada página

---

## 🚀 Melhorias Futuras (Opcional)

1. ✨ Adicionar animação ao FAB (Hero animation)
2. ✨ FAB que muda de ícone baseado no scroll
3. ✨ Mini FAB vs Extended FAB baseado em scroll
4. ✨ Tooltips customizados

---

**Data:** 2025-12-22  
**Status:** ✅ Completo e Validado  
**Impacto:** UX restaurada + Arquitetura melhorada

