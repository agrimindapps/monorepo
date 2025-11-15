/// Exemplo de uso do Strategy Pattern para agrupamento de defensivos
/// 
/// Este arquivo demonstra como utilizar a implementação do Strategy Pattern
/// em diferentes contextos da aplicação.
/// 
/// ⚠️ Este é um arquivo de exemplo/referência. Não é código de produção.
/// Remova este arquivo após migração completa.

import 'package:app_receituagro/features/defensivos/data/strategies/defensivo_grouping_service_v2.dart';
import 'package:app_receituagro/features/defensivos/data/strategies/defensivo_grouping_strategy_registry.dart';
import 'package:app_receituagro/features/defensivos/domain/entities/defensivo_entity.dart';
import 'package:core/core.dart';

/// Exemplo 1: Uso básico com GetIt
Future<void> example1_BasicUsage() async {
  // Obter services do container
  final registry = GetIt.instance<DefensivoGroupingStrategyRegistry>();
  final groupingService = GetIt.instance<DefensivoGroupingServiceV2>();

  // Agrupar defensivos
  const defensivos = <DefensivoEntity>[];
  final grupos = groupingService.agruparDefensivos(
    defensivos: defensivos,
    tipoAgrupamento: 'fabricante',
    filtroTexto: 'search text',
  );

  print('Grupos criados: ${grupos.length}');
}

/// Exemplo 2: Obter estratégias disponíveis (para UI)
Future<void> example2_GetAvailableStrategies() async {
  final groupingService = GetIt.instance<DefensivoGroupingServiceV2>();

  // Listar IDs de estratégias
  final ids = groupingService.getTiposAgrupamentoDisponiveis();
  print('Estratégias disponíveis: $ids');
  // Output: [categoria, classe_agronomica, fabricante, ingrediente_ativo, modo_acao, toxicidade]

  // Obter nome para exibição
  for (final id in ids) {
    final displayName = groupingService.getTipoAgrupamentoDisplayName(id);
    print('$id → $displayName');
  }
  // Output:
  // categoria → Categoria
  // classe_agronomica → Classe Agronômica
  // fabricante → Fabricante
  // ingrediente_ativo → Ingrediente Ativo
  // modo_acao → Modo de Ação
  // toxicidade → Toxicidade
}

/// Exemplo 3: Validar tipo de agrupamento
Future<void> example3_ValidateGroupingType() async {
  final groupingService = GetIt.instance<DefensivoGroupingServiceV2>();

  // Verificar se tipo é válido
  final isValid = groupingService.isValidTipoAgrupamento('fabricante');
  print('Tipo "fabricante" é válido: $isValid'); // true

  final isInvalid = groupingService.isValidTipoAgrupamento('tipo_desconhecido');
  print('Tipo "tipo_desconhecido" é válido: $isInvalid'); // false
}

/// Exemplo 4: Filtrar e ordenar grupos após agrupamento
Future<void> example4_FilterAndSort() async {
  final groupingService = GetIt.instance<DefensivoGroupingServiceV2>();
  const defensivos = <DefensivoEntity>[];

  // 1. Agrupar
  var grupos = groupingService.agruparDefensivos(
    defensivos: defensivos,
    tipoAgrupamento: 'fabricante',
  );

  // 2. Filtrar por texto
  grupos = groupingService.filtrarGrupos(
    grupos: grupos,
    filtroTexto: 'bayer',
  );

  // 3. Ordenar (descendente)
  grupos = groupingService.ordenarGrupos(
    grupos: grupos,
    ascending: false,
  );

  print('Grupos filtrados e ordenados: ${grupos.length}');
}

/// Exemplo 5: Obter estatísticas
Future<void> example5_GetStatistics() async {
  final groupingService = GetIt.instance<DefensivoGroupingServiceV2>();
  const defensivos = <DefensivoEntity>[];

  final grupos = groupingService.agruparDefensivos(
    defensivos: defensivos,
    tipoAgrupamento: 'ingrediente_ativo',
  );

  final stats = groupingService.obterEstatisticas(grupos: grupos);
  print('Total de grupos: ${stats['totalGrupos']}');
  print('Total de itens: ${stats['totalItens']}');
  print('Média itens por grupo: ${stats['mediaItensPerGrupo']}');
  print('Grupo com mais itens: ${stats['grupoComMaisItens']}');
  print('Grupo com menos itens: ${stats['grupoComMenosItens']}');
}

/// Exemplo 6: Usar em Riverpod Provider
/// 
/// ```dart
/// @riverpod
/// Future<List<DefensivoGroupEntity>> defensivosGrouped(
///   DefensivosGroupedRef ref,
///   String tipoAgrupamento,
///   String? filtroTexto,
/// ) async {
///   final groupingService = ref.watch(
///     groupingServiceProvider,
///   );
///   final defensivos = await ref.watch(
///     defensivosProvider.future,
///   );
///
///   return groupingService.agruparDefensivos(
///     defensivos: defensivos,
///     tipoAgrupamento: tipoAgrupamento,
///     filtroTexto: filtroTexto,
///   );
/// }
/// ```

/// Exemplo 7: Como adicionar nova estratégia
/// 
/// Passo 1: Criar a classe em `defensivo_grouping_strategies.dart`
/// 
/// ```dart
/// class ByRecenteGrouping implements IDefensivoGroupingStrategy {
///   @override
///   String get name => 'Recentes';
///
///   @override
///   String get id => 'recente';
///
///   @override
///   String get description => 'Agrupa defensivos por data de atualização';
///
///   @override
///   Map<String, List<DefensivoEntity>> group(List<DefensivoEntity> defensivos) {
///     final Map<String, List<DefensivoEntity>> grupos = {};
///     
///     for (final defensivo in defensivos) {
///       final data = defensivo.lastUpdated ?? DateTime.now();
///       final chave = _getCategoriaRecente(data);
///       
///       grupos.putIfAbsent(chave, () => <DefensivoEntity>[]);
///       grupos[chave]!.add(defensivo);
///     }
///     
///     return grupos;
///   }
///
///   String _getCategoriaRecente(DateTime data) {
///     final agora = DateTime.now();
///     final diferenca = agora.difference(data).inDays;
///     
///     if (diferenca == 0) return 'Hoje';
///     if (diferenca == 1) return 'Ontem';
///     if (diferenca <= 7) return 'Esta semana';
///     if (diferenca <= 30) return 'Este mês';
///     return 'Anterior';
///   }
/// }
/// ```
/// 
/// Passo 2: Registrar em `DefensivoGroupingStrategyRegistry`
/// 
/// ```dart
/// DefensivoGroupingStrategyRegistry()
///     : _strategies = {
///         'categoria': ByCategoriaGrouping(),
///         'classe_agronomica': ByClasseAgronomicaGrouping(),
///         'fabricante': ByFabricanteGrouping(),
///         'ingrediente_ativo': ByIngredienteAtivoGrouping(),
///         'modo_acao': ByModoAcaoGrouping(),
///         'recente': ByRecenteGrouping(), // ← NOVO
///         'toxicidade': ByToxicidadeGrouping(),
///       };
/// ```
/// 
/// Pronto! A nova estratégia está disponível em toda a aplicação.

/// Exemplo 8: Teste unitário para nova estratégia
/// 
/// ```dart
/// import 'package:flutter_test/flutter_test.dart';
/// import 'package:app_receituagro/features/defensivos/data/strategies/defensivo_grouping_strategies.dart';
/// import 'package:app_receituagro/features/defensivos/domain/entities/defensivo_entity.dart';
///
/// void main() {
///   group('ByFabricanteGrouping', () {
///     test('should group defensivos by fabricante', () {
///       final strategy = ByFabricanteGrouping();
///       
///       final defensivos = [
///         DefensivoEntity(
///           id: '1',
///           nome: 'Defensivo A',
///           ingredienteAtivo: 'Ingrediente 1',
///           fabricante: 'Bayer',
///         ),
///         DefensivoEntity(
///           id: '2',
///           nome: 'Defensivo B',
///           ingredienteAtivo: 'Ingrediente 2',
///           fabricante: 'Syngenta',
///         ),
///         DefensivoEntity(
///           id: '3',
///           nome: 'Defensivo C',
///           ingredienteAtivo: 'Ingrediente 3',
///           fabricante: 'Bayer',
///         ),
///       ];
///       
///       final result = strategy.group(defensivos);
///       
///       expect(result.keys, containsAll(['Bayer', 'Syngenta']));
///       expect(result['Bayer'], hasLength(2));
///       expect(result['Syngenta'], hasLength(1));
///     });
///
///     test('should return "Não informado" when fabricante is null', () {
///       final strategy = ByFabricanteGrouping();
///       
///       final defensivos = [
///         DefensivoEntity(
///           id: '1',
///           nome: 'Defensivo A',
///           ingredienteAtivo: 'Ingrediente 1',
///         ),
///       ];
///       
///       final result = strategy.group(defensivos);
///       
///       expect(result.keys, contains('Não informado'));
///     });
///   });
/// }
/// ```

// ⚠️ NOTA: Este arquivo é apenas um exemplo de referência
// Remova após migração completa das dependências para DefensivoGroupingServiceV2
