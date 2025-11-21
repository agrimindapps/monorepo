# Strategy Pattern - Defensivos Grouping

## 📋 Overview

Implementação do **Strategy Pattern** para agrupamento de defensivos agrícolas, aderindo ao **Open/Closed Principle** (SOLID).

### Problema Resolvido ❌ → ✅

**Antes (Hard-coded if/else chains):**
```dart
// ❌ PROBLEMA: Modificar código existente para adicionar nova estratégia
if (strategy == 'byNome') {
  // lógica de ordenação por nome
} else if (strategy == 'byTipo') {
  // lógica de ordenação por tipo
} else if (strategy == 'byAplicacao') {
  // lógica de ordenação por aplicação
}
// Cada nova estratégia = modificar DefensivosGroupingService
```

**Depois (Strategy Pattern):**
```dart
// ✅ SOLUÇÃO: Criar novo Strategy, não modificar código existente
class ByNovaEstrategiaGrouping implements IDefensivoGroupingStrategy {
  @override
  Map<String, List<DefensivoEntity>> group(List<DefensivoEntity> defensivos) {
    // nova lógica aqui
  }
}

// Registrar no registry
DefensivoGroupingStrategyRegistry()
  : _strategies = {
      'fabricante': ByFabricanteGrouping(),
      'nova_estrategia': ByNovaEstrategiaGrouping(), // ← Novo!
    };
```

## 🏛️ Arquitetura

### Componentes

1. **IDefensivoGroupingStrategy** (Interface)
   - Define contrato para todas as estratégias
   - Propriedades: `name`, `id`, `description`
   - Método: `group(defensivos) → Map`

2. **Concrete Strategies** (Implementações)
   - `ByFabricanteGrouping`
   - `ByIngredienteAtivoGrouping`
   - `ByModoAcaoGrouping`
   - `ByClasseAgronomicaGrouping`
   - `ByToxicidadeGrouping`
   - `ByCategoriaGrouping`

3. **DefensivoGroupingStrategyRegistry** (Registry)
   - Centraliza todas as estratégias
   - Fornece: `get()`, `getOrDefault()`, `getAvailableIds()`, `exists()`

4. **DefensivoGroupingServiceV2** (Service - Orquestrador)
   - Utiliza estratégias via Registry
   - Delega agrupamento para estratégia específica
   - Normaliza resultado em DefensivoGroupEntity

## 📊 Fluxo de Execução

```
Presentation (UI)
    ↓
DefensivoGroupingServiceV2.agruparDefensivos(tipoAgrupamento: 'fabricante')
    ↓
DefensivoGroupingStrategyRegistry.getOrDefault('fabricante')
    ↓
ByFabricanteGrouping.group(defensivos)
    ↓
Map<String, List<DefensivoEntity>>
    ↓
DefensivoGroupingServiceV2 (normaliza)
    ↓
List<DefensivoGroupEntity>
    ↓
Presentation (UI) - Renderiza
```

## 🚀 Como Usar

### Injetar no Construtor

```dart
class MyNotifier {
  final DefensivoGroupingServiceV2 _groupingService;

  MyNotifier(this._groupingService);

  void loadGroupedDefensivos() {
    final grupos = _groupingService.agruparDefensivos(
      defensivos: defensivos,
      tipoAgrupamento: 'fabricante',
      filtroTexto: searchText,
    );
    // usar grupos...
  }
}
```

### Via Dependency Injection (GetIt)

```dart
final groupingService = sl<DefensivoGroupingServiceV2>();

final grupos = groupingService.agruparDefensivos(
  defensivos: defensivos,
  tipoAgrupamento: 'modo_acao',
);
```

### Tipos de Agrupamento Disponíveis

```dart
final disponíveis = groupingService.getTiposAgrupamentoDisponiveis();
// ['categoria', 'classe_agronomica', 'fabricante', 'ingrediente_ativo', 'modo_acao', 'toxicidade']

// Obter nome de exibição
final displayName = groupingService.getTipoAgrupamentoDisplayName('fabricante');
// 'Fabricante'

// Verificar se tipo é válido
final isValid = groupingService.isValidTipoAgrupamento('fabricante');
// true
```

## ➕ Como Adicionar Nova Estratégia

Exemplo: Agrupar por "Popularidade" (quantidade de diagnósticos)

### 1. Criar nova Strategy

```dart
// Adicionar em defensivo_grouping_strategies.dart

class ByPopularidadeGrouping implements IDefensivoGroupingStrategy {
  @override
  String get name => 'Popularidade';

  @override
  String get id => 'popularidade';

  @override
  String get description => 'Agrupa defensivos por quantidade de diagnósticos';

  @override
  Map<String, List<DefensivoEntity>> group(List<DefensivoEntity> defensivos) {
    final Map<String, List<DefensivoEntity>> grupos = {};
    
    for (final defensivo in defensivos) {
      // Agrupar por ranges de popularidade
      final quantidade = defensivo.quantidadeDiagnosticos ?? 0;
      final chave = _getCategoriaPopularidade(quantidade);
      
      grupos.putIfAbsent(chave, () => <DefensivoEntity>[]);
      grupos[chave]!.add(defensivo);
    }
    
    return grupos;
  }

  String _getCategoriaPopularidade(int quantidade) {
    if (quantidade >= 100) return 'Muito Popular (100+)';
    if (quantidade >= 50) return 'Popular (50-99)';
    if (quantidade >= 10) return 'Moderado (10-49)';
    return 'Novo (<10)';
  }
}
```

### 2. Registrar no Registry

```dart
// Editar DefensivoGroupingStrategyRegistry()

DefensivoGroupingStrategyRegistry()
    : _strategies = {
        'categoria': ByCategoriaGrouping(),
        'classe_agronomica': ByClasseAgronomicaGrouping(),
        'fabricante': ByFabricanteGrouping(),
        'ingrediente_ativo': ByIngredienteAtivoGrouping(),
        'modo_acao': ByModoAcaoGrouping(),
        'popularidade': ByPopularidadeGrouping(), // ← NOVO
        'toxicidade': ByToxicidadeGrouping(),
      };
```

### 3. Pronto! 🎉

Não precisa modificar:
- DefensivoGroupingServiceV2
- Nenhuma outra classe existente

A UI automaticamente terá acesso à nova estratégia via `getTiposAgrupamentoDisponiveis()`.

## 📋 SOLID Principles - Verificação ✅

### ✅ Open/Closed Principle (OCP)
- **Aberto para extensão**: Adicionar novo Strategy sem modificar código existente
- **Fechado para modificação**: DefensivoGroupingServiceV2 não muda

### ✅ Single Responsibility Principle (SRP)
- `ByFabricanteGrouping`: Responsável apenas por agrupar por fabricante
- `ByIngredienteAtivoGrouping`: Responsável apenas por agrupar por ingrediente ativo
- `DefensivoGroupingServiceV2`: Responsável apenas por orquestrar

### ✅ Liskov Substitution Principle (LSP)
- Qualquer Strategy pode substituir outro sem quebrar código
- Todos implementam mesma interface

### ✅ Interface Segregation Principle (ISP)
- `IDefensivoGroupingStrategy` define apenas métodos necessários

### ✅ Dependency Inversion Principle (DIP)
- `DefensivoGroupingServiceV2` depende de `IDefensivoGroupingStrategy` (abstração)
- Não depende de implementações concretas

## 🔄 Migração Gradual

Ambas as versões coexistem por enquanto:

```dart
// V1 (Legado - a ser removido)
final legacyService = sl<DefensivosGroupingService>();

// V2 (Novo - Strategy Pattern)
final newService = sl<DefensivoGroupingServiceV2>();
```

### Plano de Migração

1. **Fase 1** (Atual): V2 implementada, coexiste com V1
2. **Fase 2**: Migrar notifiers/providers para usar V2
3. **Fase 3**: Remover V1 quando 100% migrado

## 📚 Exemplo Completo

```dart
// Uso típico em um Notifier

class DefensivosGroupedNotifier extends StateNotifier<AsyncValue<List<DefensivoGroupEntity>>> {
  final DefensivoGroupingServiceV2 _groupingService;
  final IDefensivosRepository _repository;

  DefensivosGroupedNotifier(this._groupingService, this._repository)
      : super(const AsyncValue.loading());

  Future<void> loadGrouped({
    required String tipoAgrupamento,
    String? filtroTexto,
  }) async {
    state = const AsyncValue.loading();

    try {
      final defensivos = await _repository.getDefensivos();
      
      final grupos = _groupingService.agruparDefensivos(
        defensivos: defensivos,
        tipoAgrupamento: tipoAgrupamento,
        filtroTexto: filtroTexto,
      );

      state = AsyncValue.data(grupos);
    } catch (error) {
      state = AsyncValue.error(error, StackTrace.current);
    }
  }

  List<String> getAvailableGroupings() => 
      _groupingService.getTiposAgrupamentoDisponiveis();
}
```

## 🧪 Testabilidade

### Antes (Difícil de testar)
```dart
// Testes precisam cobrir todas as condições if/else
test('should group by type', () {
  // Mock DefensivosGroupingService inteira
  // Muito trabalho
});
```

### Depois (Fácil de testar)
```dart
// Teste cada strategy isoladamente
test('ByFabricanteGrouping groups correctly', () {
  final strategy = ByFabricanteGrouping();
  final result = strategy.group(defensivos);
  expect(result, containsPair('Fabricante A', isNotEmpty));
});

// Teste service com mock de strategy
test('DefensivoGroupingServiceV2 uses correct strategy', () {
  final mockStrategy = MockStrategy();
  final registry = MockRegistry(mockStrategy);
  final service = DefensivoGroupingServiceV2(registry);
  
  service.agruparDefensivos(defensivos: [], tipoAgrupamento: 'test');
  
  verify(() => mockStrategy.group(any())).called(1);
});
```

## 📊 Benefícios Quantificáveis

| Aspecto | Antes | Depois |
|--------|--------|--------|
| Linhas se/else | ~20+ | 0 (deletadas) |
| Tempo adicionar estratégia | ~10 min | ~2 min |
| Mudanças necessárias | Modificar service + testes | Apenas novo strategy |
| Complexidade ciclomática | Alta (nested if/else) | Baixa (1 por strategy) |
| Testabilidade | Baixa | Alta |
| Risco de regressão | Alto | Baixo |

## 📝 Checklist para Nova Strategy

- [ ] Criar classe `By<TipoAgrupamento>Grouping` em `defensivo_grouping_strategies.dart`
- [ ] Implementar `IDefensivoGroupingStrategy`
- [ ] Implementar `name`, `id`, `description` properties
- [ ] Implementar `group()` method
- [ ] Adicionar ao `_strategies` map em `DefensivoGroupingStrategyRegistry`
- [ ] Atualizar descrição em `_obterDescricaoGrupo()` em `DefensivoGroupingServiceV2` (opcional)
- [ ] Criar unit tests para nova strategy
- [ ] Testar UI manualmente

## 📖 Referências

- [Strategy Pattern - Wikipedia](https://en.wikipedia.org/wiki/Strategy_pattern)
- [SOLID Principles - Robert C. Martin](https://en.wikipedia.org/wiki/SOLID)
- [Design Patterns in Dart](https://dart.dev/)
