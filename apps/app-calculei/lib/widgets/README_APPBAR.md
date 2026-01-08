# AppBar Standardization Guide

## ✅ PADRÃO OFICIAL: CalculatorAppBar

**Localização:** `/lib/core/presentation/widgets/calculator_app_bar.dart`

### Uso em todas as páginas de calculadora:

```dart
import 'package:app_calculei/core/presentation/widgets/calculator_app_bar.dart';

class MinhaCalculadoraPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CalculatorAppBar(),
      body: // seu conteúdo
    );
  }
}
```

### Features da CalculatorAppBar:
- ✅ Logo "Calculei" padronizado
- ✅ Botão voltar automático
- ✅ Dropdown de navegação de categorias
- ✅ Suporte dark/light/system theme
- ✅ Responsivo (mobile/desktop)
- ✅ Actions customizáveis

### Parâmetros disponíveis:

```dart
CalculatorAppBar(
  showBackButton: true,           // Mostrar botão voltar (default: true)
  onBack: () => context.go('/'),  // Ação customizada de voltar
  showCalculatorsDropdown: true,  // Mostrar dropdown (default: true)
  actions: [                      // Ações extras
    InfoAppBarAction(onPressed: () {}),
    ShareAppBarAction(onPressed: () {}),
  ],
)
```

## ⚠️ EXCEÇÃO: HomePage

A **HomePage** usa `SliverAppBar` para permitir scroll collapsing do header.
Este é o ÚNICO caso onde `SliverAppBar` é permitida.

## ❌ NÃO USAR:

- `CustomLocalAppBar` - Removido
- `PageHeaderWidget` - Removido (use CalculatorAppBar)
- `AppBar()` direto - Use CalculatorAppBar
- AppBar customizada - Use CalculatorAppBar

## 🎯 Benefícios da Padronização:

1. **Consistência** - Mesma experiência em todo app
2. **Manutenibilidade** - Mudanças em um único lugar
3. **Theme** - Suporte automático a temas
4. **Navegação** - Dropdown de categorias em toda parte
5. **Responsividade** - Adaptação automática mobile/desktop

## 📝 Migração:

Se encontrar código usando outras AppBars, migre para:

```dart
// ANTES ❌
appBar: AppBar(title: Text('Título'))

// DEPOIS ✅
appBar: const CalculatorAppBar()
```

---
**Última atualização:** 2026-01-08
**Responsável:** Time de Desenvolvimento
