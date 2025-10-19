# Migração de Ícones - ReceitaAgro

## 📦 Mudanças Implementadas

### Novos Ícones com `icons_plus` (Bootstrap Icons)

Os ícones do app foram atualizados para usar a biblioteca **`icons_plus`** (Bootstrap Icons), oferecendo:
- ✅ Melhor adequação ao tema agrícola
- ✅ Consistência visual moderna
- ✅ Ícones preenchidos (fill) e outlined
- ✅ Centralização e padronização

---

## 🎨 Arquivo Centralizado: `AppIcons`

**Localização:** `lib/core/theme/app_icons.dart`

Todos os ícones do app estão centralizados neste arquivo para facilitar manutenção e garantir consistência.

### Ícones Principais

```dart
import 'package:app_receituagro/core/theme/app_icons.dart';

// Navegação Principal
AppIcons.defensivos          // Shield com check (proteção)
AppIcons.defensivosOutlined  // Shield outlined
AppIcons.pragas              // Inseto preenchido
AppIcons.pragasOutlined      // Inseto outlined
AppIcons.favoritos           // Coração outlined
AppIcons.favoritosFill       // Coração preenchido
AppIcons.comentarios         // Chat com texto
AppIcons.comentariosFill     // Chat preenchido
AppIcons.configuracoes       // Engrenagem
AppIcons.configuracoesFill   // Engrenagem preenchida
```

---

## 🔄 Mudanças Realizadas

### BottomNavigationBar

**Antes:**
```dart
Icon(Icons.shield)           // Defensivos
Icon(Icons.bug_report)       // Pragas
Icon(Icons.favorite_border)  // Favoritos
Icon(Icons.comment_outlined) // Comentários
Icon(Icons.settings_outlined)// Configurações
```

**Depois:**
```dart
Icon(AppIcons.defensivos)        // ✅ Shield com check
Icon(AppIcons.pragas)            // ✅ Inseto (bug)
Icon(AppIcons.favoritos)         // ✅ Coração
Icon(AppIcons.comentarios)       // ✅ Chat
Icon(AppIcons.configuracoes)     // ✅ Engrenagem
```

### Headers e Páginas

**Home Defensivos Header:**
```dart
// Antes
leftIcon: Icons.shield_outlined

// Depois
leftIcon: AppIcons.defensivosOutlined
```

---

## 🎯 Ícones Disponíveis

### Navegação
- `defensivos` / `defensivosOutlined`
- `pragas` / `pragasOutlined`
- `favoritos` / `favoritosFill`
- `comentarios` / `comentariosFill`
- `configuracoes` / `configuracoesFill`

### Tipos de Pragas
- `insetos` - Ícone de inseto
- `doencas` - Ícone de vírus
- `plantasDaninhas` - Ícone de flor

### Ações Comuns
- `busca` - Lupa
- `filtro` - Funil
- `adicionar` - Plus circle
- `editar` - Lápis
- `deletar` - Lixeira
- `compartilhar` - Share
- `info` - Info circle
- `alerta` - Triângulo de alerta
- `sucesso` - Check circle
- `erro` - X circle

### Funcionalidades Específicas
- `diagnostico` - Clipboard com check
- `tecnologia` - Gota (defensivo)
- `seguranca` - Shield com exclamação
- `dosagem` - Clipboard com dados
- `calendario` - Calendário
- `notificacoes` - Sino
- `premium` - Estrela preenchida
- `usuario` - Círculo de pessoa
- `sair` - Seta saindo da caixa

---

## 🔧 Helpers Disponíveis

```dart
// Retorna ícone baseado no contexto
AppIcons.getDefensivoIcon(outlined: true)   // Outlined version
AppIcons.getPragaIcon(outlined: false)       // Filled version

// Retorna ícone por tipo de praga
AppIcons.getTipoPragaIcon('inseto')          // Bootstrap.bug_fill
AppIcons.getTipoPragaIcon('doença')          // Bootstrap.virus
AppIcons.getTipoPragaIcon('planta daninha')  // Bootstrap.flower2
```

---

## 📝 Como Usar

### 1. Importar o arquivo
```dart
import 'package:app_receituagro/core/theme/app_icons.dart';
```

### 2. Usar os ícones
```dart
Icon(AppIcons.defensivos)
Icon(AppIcons.pragas, size: 32, color: Colors.green)
Icon(AppIcons.favoritos)
```

### 3. Em widgets
```dart
IconButton(
  icon: Icon(AppIcons.busca),
  onPressed: () {
    // Action
  },
)
```

---

## ✅ Arquivos Atualizados

- ✅ `lib/features/navigation/main_navigation_page.dart`
- ✅ `lib/features/defensivos/presentation/widgets/home_defensivos_header.dart`
- ✅ `lib/core/theme/app_icons.dart` (novo)

---

## 🎯 Próximos Passos (Opcional)

Arquivos que ainda usam ícones antigos e podem ser atualizados gradualmente:

### Defensivos
- `lib/features/defensivos/presentation/pages/detalhe_defensivo_page.dart`
- `lib/features/defensivos/presentation/widgets/detalhe/tecnologia_tab_widget.dart`
- `lib/features/defensivos/presentation/widgets/defensivo_agrupado_item_widget.dart`

### Pragas
- `lib/features/pragas/widgets/praga_cultura_tab_bar_widget.dart`
- `lib/features/pragas/presentation/widgets/home_pragas_stats_widget.dart`
- `lib/features/pragas/presentation/pages/detalhe_praga_page.dart`
- `lib/features/pragas/presentation/widgets/praga_info_widget.dart`
- `lib/features/pragas/presentation/widgets/home_pragas_suggestions_widget.dart`

**Nota:** A migração pode ser feita gradualmente conforme necessidade. O sistema antigo continua funcionando.

---

## 🚀 Benefícios

1. ✅ **Consistência Visual**: Todos os ícones seguem o mesmo design system (Bootstrap Icons)
2. ✅ **Manutenibilidade**: Mudanças centralizadas em um único arquivo
3. ✅ **Adequação Temática**: Ícones mais apropriados para aplicação agrícola
4. ✅ **Melhor UX**: Ícones filled/outlined melhoram feedback visual
5. ✅ **Documentação**: Todos os ícones documentados e organizados

---

## 📚 Referências

- [icons_plus no pub.dev](https://pub.dev/packages/icons_plus)
- [Bootstrap Icons](https://icons.getbootstrap.com/)
- Arquivo de ícones: `lib/core/theme/app_icons.dart`
- Exemplos: `packages/core/EXAMPLES.md`
