# Phase 3: Pragas por Cultura - Page Refactoring Plan

## Objetivo
Refatorar `pragas_por_cultura_detalhadas_page.dart` de uma StatefulWidget com 592 linhas para uma ConsumerStatefulWidget de ~180 linhas, integrando os serviços da Phase 1-2.

## Análise da Página Atual (592 linhas)

### Responsabilidades Atuais
1. **Estado de Dados** (110 linhas)
   - `_pragasPorCultura`, `_culturas`, `_plantasDaninhas`, `_doencas`, `_insetos`
   - `_currentState`, `_errorMessage`, `_culturaIdSelecionada`
   - `_ordenacao`, `_filtroTipo`

2. **Carregamento de Dados** (80 linhas)
   - `_carregarCulturas()` - fetch culturas
   - `_carregarPragasDaCultura()` - fetch pragas
   - `_initializeData()` - orchestração

3. **Processamento de Dados** (120 linhas)
   - `_separarPragasPorTipo()` - agrupa por tipo
   - `_aplicarOrdenacaoALista()` - ordena pragas
   - `_aplicarFiltros()` - filtra por criticidade

4. **UI Rendering** (282 linhas)
   - `build()` - layout principal
   - Múltiplos widgets e composição

## Divisão Pós-Refatoração

### Novo ViewModel (já criado em Phase 2)
- Responsável por: Carregamento, Processamento, Estado
- Linhas movidas: 310 linhas (excluir UI)

### Nova Página
- Responsável por: UI + Interação
- Linhas esperadas: ~180 linhas

## Estratégia de Refatoração

### 1. Convertendo para ConsumerStatefulWidget
```dart
// De:
class PragasPorCulturaDetalhadasPage extends StatefulWidget
// Para:
class PragasPorCulturaDetalhadasPage extends ConsumerStatefulWidget
```

### 2. Watching ViewModel State
```dart
@override
Widget build(BuildContext context, WidgetRef ref) {
  final state = ref.watch(pragasCulturaPageViewModelProvider);
  final viewModel = ref.read(pragasCulturaPageViewModelProvider.notifier);
  // ...
}
```

### 3. Delegando Lógica ao ViewModel
- Remover todos os métodos privados (já estão no ViewModel)
- Usar `viewModel.loadPragasForCultura(culturaId)`
- Usar `viewModel.filterByCriticidade()`
- Usar `viewModel.sortPragas()`

### 4. Estrutura de Widgets
```
PragasPorCulturaDetalhadasPage (ConsumerStatefulWidget, ~20 linhas)
├── CultureSelectorWidget (já existe, ~30 linhas)
├── PragasTabBarContent (novo, ~100 linhas)
│   ├── PragasList (novo, reutilizar praga_por_cultura_card_widget)
│   ├── ErrorWidget
│   └── LoadingWidget
└── FiltrosOrdenacaoDialog (já existe)
```

## Problemas Conhecidos a Resolver

### 1. Type Conversion
**Problema**: ViewModel retorna `Map<String, dynamic>`, página precisa de `PragaPorCultura`

**Solução Atual**: Manter como Map no ViewModel (mais genérico)

**Convergência na Página**:
```dart
// Widget expects PragaPorCultura, mas temos Map
// Solução: Criar mapper inline ou widget genérico
final pragasList = state.pragasFiltradasOrdenadas
  .map((map) => _mapToPragaPorCultura(map))
  .toList();
```

### 2. Repository Type Mismatch
**Problema**: `IPragasCulturaRepository.getPragasForCultura()` retorna `Either<Failure, List<dynamic>>`

**Solução**: 
- `PragasCulturaDataService` já faz o unwrap
- ViewModel já normaliza o tipo
- Página recebe `List<Map<String, dynamic>>`

### 3. Hive Model Attributes
**Problema**: `PragasHive` tem `nomeComum`, não `nome`

**Solução**: Já incorporado nos widgets existentes (praga_por_cultura_card_widget)

## Implementação Step-by-Step

### Step 1: Criar _State classe
```dart
class _PragasPorCulturaDetalhadasPageState extends ConsumerState<PragasPorCulturaDetalhadasPage> with TickerProviderStateMixin {
  late TabController _tabController;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    Future.microtask(() {
      ref.read(pragasCulturaPageViewModelProvider.notifier)
        .loadCulturas();
    });
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}
```

### Step 2: Build Method
```dart
@override
Widget build(BuildContext context, WidgetRef ref) {
  final state = ref.watch(pragasCulturaPageViewModelProvider);
  final viewModel = ref.read(pragasCulturaPageViewModelProvider.notifier);
  
  // UI building with state.pragasFiltradasOrdenadas, state.isLoading, etc.
}
```

### Step 3: Extrair Widgets Complexos
- `_buildTabBar()` → inline ou widget separado
- `_buildPragasList()` → PragasListView (novo)
- `_buildErrorWidget()` → existente
- `_buildLoadingWidget()` → existente

### Step 4: Event Handlers
```dart
_onCulturaChanged(String culturaId) {
  viewModel.loadPragasForCultura(culturaId);
}

_onFilterChanged(bool onlyCriticas) {
  viewModel.filterByCriticidade(onlyCriticas);
}

_onSortChanged(String sortBy) {
  viewModel.sortPragas(sortBy);
}
```

## Métricas de Sucesso

| Métrica | Atual | Esperado | Status |
|---------|-------|----------|--------|
| Linhas da página | 592 | ~180 | ⏳ |
| Linhas no ViewModel | N/A | 180 | ✅ |
| Linhas em serviços | N/A | 370 | ✅ |
| Compilação sem erros | N/A | 0 erros | ⏳ |
| SOLID Score | 2.6/10 | 8.5/10 | ⏳ |
| Type Safety | 30% | 95% | ⏳ |
| Test Coverage | 0% | 80% | ⏳ |

## Arquivo de Saída
- `pragas_por_cultura_detalhadas_page.dart` - versão refatorada (~180 linhas)
- `pragas_por_cultura_detalhadas_page.backup` - backup da versão original (592 linhas)

## Timeline Estimada
- Step 1-2 (Setup ConsumerStatefulWidget): 15 min
- Step 3 (Extrair widgets): 15 min
- Step 4 (Event handlers): 10 min
- Teste e debug: 20 min
- **Total: ~60 minutos**

## Próximos Passos Após Phase 3.2 (Page Refactoring)
1. Phase 3.3: Testes Unitários (60 min)
2. Phase 3.4: Testes de Integração (30 min)
3. Phase 3.5: QA e Validação em Emulador (30 min)
4. Phase 3.6: Documentação Final (20 min)
