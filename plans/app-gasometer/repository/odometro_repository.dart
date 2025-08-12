// Flutter imports:
// Package imports:
import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';

// Project imports:
import '../../../../../core/services/firebase_firestore_service.dart';
import '../database/20_odometro_model.dart';
import '../pages/cadastros/veiculos_page/services/box_manager.dart';
import '../repository/veiculos_repository.dart';

/**
 * REFACTOR (prioridade: ALTA): Separar lógica de exportação CSV e helpers de formatação para arquivos utilitários.
 * REFACTOR (prioridade: MÉDIA): Padronizar nomes de métodos e variáveis para inglês ou português, evitando mistura.
 * REFACTOR (prioridade: MÉDIA): Documentar melhor o contrato dos métodos privados e públicos.
 * OPTIMIZE (prioridade: MÉDIA): Evitar abrir e fechar o box Hive em cada operação, usar conexão persistente ou pool.
 * OPTIMIZE (prioridade: MÉDIA): Melhorar performance do agrupamento de registros por mês, usando YearMonth ou similar.
 * BUG (prioridade: MÉDIA): Possível risco de concorrência ao acessar o box Hive em operações assíncronas simultâneas.
 * BUG (prioridade: MÉDIA): Falta validação para evitar registros duplicados de odômetro no mesmo timestamp.
 * TODO (prioridade: MÉDIA): Adicionar tratamento de erro mais detalhado e feedback para o usuário.
 * TODO (prioridade: MÉDIA): Adicionar testes unitários para métodos de CRUD e exportação.
 * TODO (prioridade: BAIXA): Permitir exportação de timeline para outros formatos além de CSV.
 * NOTE (prioridade: BAIXA): O método _getTimeline está incompleto, implementar lógica real de timeline.
 * STYLE (prioridade: BAIXA): Adicionar comentários explicativos nos métodos principais.
 * DOC (prioridade: BAIXA): Documentar o uso esperado da classe VeiculoTimelineItem.
 * SECURITY (prioridade: MÉDIA): Garantir que apenas usuários autorizados possam exportar ou alterar dados.
 */
// TODO (prioridade: MÉDIA): Adicionar opção de backup/restauração dos dados do Hive.
// TODO (prioridade: BAIXA): Permitir configuração do nome do box/coleção via parâmetro.

class OdometroRepository {
  // MARK: - Constants
  static const String _boxName = 'box_car_odometros';
  static const String collectionName = 'box_car_odometros';

  // MARK: - Dependencies
  final _firestore = FirestoreService();

  // MARK: - Properties
  Future<Box<OdometroCar>> get _box => BoxManager.instance.getBox<OdometroCar>(_boxName);

  // MARK: - Singleton Implementation
  static final OdometroRepository _instance = OdometroRepository._internal();
  factory OdometroRepository() => _instance;
  OdometroRepository._internal();

  // MARK: - Public API
  static Future<void> initialize() => _initialize();
  Future<Map<DateTime, List<OdometroCar>>> getOdometrosAgrupados(
          String veiculoId) =>
      _getGroupedOdometros(veiculoId);
  Future<OdometroCar?> getOdometroById(String id) => _getById(id);
  Future<bool> addOdometro(OdometroCar odometro) => _add(odometro);
  Future<bool> updateOdometro(OdometroCar odometro) => _update(odometro);
  Future<bool> deleteOdometro(OdometroCar odometro) => _delete(odometro);
  Future<List<VeiculoTimelineItem>> getVeiculoTimeline(
    String veiculoId, {
    int? dataInicial,
    int? dataFinal,
  }) =>
      _getTimeline(veiculoId, dataInicial: dataInicial, dataFinal: dataFinal);
  Future<Map<String, Map<String, double>>> getOdometroEstatisticas(
          String veiculoId) =>
      _getOdometroEstatisticas(veiculoId);
  Future<String> exportToCsv(String veiculoId) => _exportToCsv(veiculoId);

  // MARK: - Initialization
  static Future<void> _initialize() async {
    try {
      if (!Hive.isAdapterRegistered(20)) {
        Hive.registerAdapter(OdometroCarAdapter());
      }
    } catch (e) {
      debugPrint('Error initializing OdometroRepository: $e');
      rethrow;
    }
  }

  // MARK: - Box Management
  // Box management now handled by BoxManager - no need for manual open/close

  // MARK: - CRUD Operations
  Future<Map<DateTime, List<OdometroCar>>> _getGroupedOdometros(
      String veiculoId) async {
    try {
      final box = await _box;
      final odometros = box.values
          .where((odometro) =>
              odometro.idVeiculo == veiculoId && !odometro.isDeleted)
          .toList()
        ..sort((a, b) => b.data.compareTo(a.data));

      final grouped = groupBy(odometros, (OdometroCar odometro) {
        final date = DateTime.fromMillisecondsSinceEpoch(odometro.data);
        return DateTime(date.year, date.month);
      });

      return Map.fromEntries(
          grouped.entries.toList()..sort((a, b) => b.key.compareTo(a.key)));
    } catch (e) {
      debugPrint('Error getting grouped odometros: $e');
      return {};
    }
  }

  Future<OdometroCar?> _getById(String id) async {
    try {
      final box = await _box;
      return box.get(id);
    } catch (e) {
      debugPrint('Error getting Odometro by ID: $e');
      return null;
    }
  }

  Future<bool> _add(OdometroCar odometro) async {
    try {
      final box = await _box;

      // Adiciona o objeto no Hive e captura a chave
      final key = await box.add(odometro);

      // Cria o registro no Firebase
      await _firestore.createRecord(
        collection: collectionName,
        data: odometro.toMap(),
      );

      // Marca como sincronizado
      odometro.markAsSynced();
      await box.put(key, odometro);

      // Busca o veículo para verificar se o odômetro atual deve ser atualizado
      final veiculosRepo = VeiculosRepository();
      final veiculo = await veiculosRepo.getVeiculoById(odometro.idVeiculo);

      if (veiculo != null) {
        // Só atualiza o odômetro do veículo se o novo valor for maior que o atual
        if (odometro.odometro > veiculo.odometroAtual) {
          await veiculosRepo.updateOdometroAtual(
              odometro.idVeiculo, odometro.odometro);
        }
      }

      return true;
    } catch (e) {
      debugPrint('Erro ao adicionar odômetro: $e');
      return false;
    }
  }

  Future<bool> _update(OdometroCar odometro) async {
    try {
      final box = await _box;
      final index =
          box.values.toList().indexWhere((item) => item.id == odometro.id);

      if (index != -1) {
        // Atualiza o campo updatedAt com a data atual (em microsegundos)
        odometro.updatedAt = DateTime.now().millisecondsSinceEpoch;

        await box.putAt(index, odometro);
        await _firestore.updateRecord(
          collection: collectionName,
          recordId: odometro.id,
          data: odometro.toMap(),
        );

        // Marca como sincronizado
        odometro.markAsSynced();

        // Verifica se o odômetro do veículo deve ser atualizado
        final veiculosRepo = VeiculosRepository();
        final veiculo = await veiculosRepo.getVeiculoById(odometro.idVeiculo);

        if (veiculo != null) {
          // Só atualiza o odômetro do veículo se o novo valor for maior que o atual
          if (odometro.odometro > veiculo.odometroAtual) {
            await veiculosRepo.updateOdometroAtual(
                odometro.idVeiculo, odometro.odometro);
          }
        }

        return true;
      }

      return false;
    } catch (e) {
      debugPrint('Erro ao atualizar odômetro: $e');
      return false;
    }
  }

  Future<bool> _delete(OdometroCar odometro) async {
    try {
      final box = await _box;
      final index =
          box.values.toList().indexWhere((item) => item.id == odometro.id);

      if (index != -1) {
        // Marca o registro como deletado
        odometro.markAsDeleted();

        await box.putAt(index, odometro);
        await _firestore.updateRecord(
          collection: collectionName,
          recordId: odometro.id,
          data: odometro.toMap(),
        );

        // Marca como sincronizado
        odometro.markAsSynced();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error deleting Odometro: $e');
      return false;
    }
  }

  // MARK: - Timeline Operations
  Future<List<VeiculoTimelineItem>> _getTimeline(
    String veiculoId, {
    int? dataInicial,
    int? dataFinal,
  }) async {
    try {
      // Note: Timeline functionality is incomplete - leaving as placeholder
      final List<VeiculoTimelineItem> timeline = [];
      return timeline;
    } catch (e) {
      debugPrint('Error getting timeline: $e');
      return [];
    }
  }

  // MARK: - Statistics Operations
  Future<Map<String, Map<String, double>>> _getOdometroEstatisticas(
      String veiculoId) async {
    try {
      final box = await _box;

      // Resultado padrão com valores zerados
      final result = {
        'esteMes': {
          'inicial': 0.0,
          'final': 0.0,
          'diferenca': 0.0,
        },
        'mesAnterior': {
          'inicial': 0.0,
          'final': 0.0,
          'diferenca': 0.0,
        },
        'esteAno': {
          'inicial': 0.0,
          'final': 0.0,
          'diferenca': 0.0,
        },
        'anoAnterior': {
          'inicial': 0.0,
          'final': 0.0,
          'diferenca': 0.0,
        },
      };

      // Filtrar lançamentos ativos para o veículo especificado
      final odometros = box.values
          .where((odometro) =>
              odometro.idVeiculo == veiculoId && !odometro.isDeleted)
          .toList()
        ..sort(
            (a, b) => a.data.compareTo(b.data)); // Ordenar por data crescente

      if (odometros.isEmpty) {
        return result;
      }

      // Datas de referência
      final agora = DateTime.now();
      final inicioMesAtual = DateTime(agora.year, agora.month, 1);
      final inicioMesAnterior = DateTime(agora.year, agora.month - 1, 1);
      final fimMesAnterior = DateTime(agora.year, agora.month, 0);
      final inicioAnoAtual = DateTime(agora.year, 1, 1);
      final inicioAnoAnterior = DateTime(agora.year - 1, 1, 1);
      final fimAnoAnterior = DateTime(agora.year, 1, 0);

      // Função para encontrar registros em um período
      List<OdometroCar> getRegistrosNoPeriodo(DateTime inicio, DateTime fim) {
        final inicioEpoch = inicio.millisecondsSinceEpoch;
        final fimEpoch = fim.millisecondsSinceEpoch;
        return odometros
            .where((o) => o.data >= inicioEpoch && o.data <= fimEpoch)
            .toList();
      }

      // Mês atual
      final registrosMesAtual = getRegistrosNoPeriodo(inicioMesAtual,
          DateTime(agora.year, agora.month, agora.day, 23, 59, 59));
      if (registrosMesAtual.isNotEmpty) {
        result['esteMes']!['inicial'] = registrosMesAtual.first.odometro;
        result['esteMes']!['final'] = registrosMesAtual.last.odometro;
        result['esteMes']!['diferenca'] =
            result['esteMes']!['final']! - result['esteMes']!['inicial']!;
      }

      // Mês anterior
      final registrosMesAnterior =
          getRegistrosNoPeriodo(inicioMesAnterior, fimMesAnterior);
      if (registrosMesAnterior.isNotEmpty) {
        result['mesAnterior']!['inicial'] = registrosMesAnterior.first.odometro;
        result['mesAnterior']!['final'] = registrosMesAnterior.last.odometro;
        result['mesAnterior']!['diferenca'] = result['mesAnterior']!['final']! -
            result['mesAnterior']!['inicial']!;
      }

      // Ano atual
      final registrosAnoAtual = getRegistrosNoPeriodo(inicioAnoAtual,
          DateTime(agora.year, agora.month, agora.day, 23, 59, 59));
      if (registrosAnoAtual.isNotEmpty) {
        result['esteAno']!['inicial'] = registrosAnoAtual.first.odometro;
        result['esteAno']!['final'] = registrosAnoAtual.last.odometro;
        result['esteAno']!['diferenca'] =
            result['esteAno']!['final']! - result['esteAno']!['inicial']!;
      }

      // Ano anterior
      final registrosAnoAnterior =
          getRegistrosNoPeriodo(inicioAnoAnterior, fimAnoAnterior);
      if (registrosAnoAnterior.isNotEmpty) {
        result['anoAnterior']!['inicial'] = registrosAnoAnterior.first.odometro;
        result['anoAnterior']!['final'] = registrosAnoAnterior.last.odometro;
        result['anoAnterior']!['diferenca'] = result['anoAnterior']!['final']! -
            result['anoAnterior']!['inicial']!;
      }

      return result;
    } catch (e) {
      debugPrint('Error getting odometro statistics: $e');
      return {
        'esteMes': {'inicial': 0.0, 'final': 0.0, 'diferenca': 0.0},
        'mesAnterior': {'inicial': 0.0, 'final': 0.0, 'diferenca': 0.0},
        'esteAno': {'inicial': 0.0, 'final': 0.0, 'diferenca': 0.0},
        'anoAnterior': {'inicial': 0.0, 'final': 0.0, 'diferenca': 0.0},
      };
    }
  }

  // MARK: - CSV Export
  Future<String> _exportToCsv(String veiculoId) async {
    try {
      final box = await _box;
      // Filtra apenas os registros ativos para o veículo especificado
      final odometros = box.values
          .where((o) => o.idVeiculo == veiculoId && !o.isDeleted)
          .toList()
        ..sort(
            (a, b) => a.data.compareTo(b.data)); // Ordena por data (crescente)

      // Define o cabeçalho do CSV com os campos mais relevantes
      const csvHeader = 'Data,Odometro,Descricao,Tipo de Registro\n';

      // Converte cada registro de odômetro em uma linha CSV
      final csvRows = odometros.map((odometro) {
        // Converte o timestamp para data legível
        final date = DateTime.fromMillisecondsSinceEpoch(odometro.data);
        final dataFormatada = '${date.day}/${date.month}/${date.year}';

        // Escapa campos de texto que podem conter vírgulas
        final descricao = _escapeField(odometro.descricao);
        final tipoRegistro = _escapeField(odometro.tipoRegistro ?? '');

        return '$dataFormatada,${odometro.odometro},$descricao,$tipoRegistro';
      }).join('\n');

      return csvHeader + csvRows;
    } catch (e) {
      debugPrint('Error exporting odometros to CSV: $e');
      return '';
    }
  }

  // Helper para escapar campos que podem conter vírgulas
  String _escapeField(String field) {
    if (field.contains(',') || field.contains('"') || field.contains('\n')) {
      // Substitui aspas duplas por duas aspas duplas e envolve em aspas
      return '"${field.replaceAll('"', '""')}"';
    }
    return field;
  }
}

class VeiculoTimelineItem {
  final String id;
  final int odometro;
  final DateTime data;
  final String tipo; // 'odometro', 'abastecimento', 'manutencao', 'despesa'
  final dynamic item; // Original item object

  VeiculoTimelineItem({
    required this.id,
    required this.odometro,
    required this.data,
    required this.tipo,
    required this.item,
  });
}

// final timeline = await OdometroRepository().getVeiculoTimeline(
//   'vehicle_id',
//   dataInicial: DateTime.now().subtract(const Duration(days: 30)).millisecondsSinceEpoch,
//   dataFinal: DateTime.now().millisecondsSinceEpoch,
// );

// // Access timeline items
// for (final item in timeline) {
//   debugPrint('${item.tipo}: ${item.odometro}km em ${item.data}');

//   // Access specific item details using type checking
//   switch (item.tipo) {
//     case 'abastecimento':
//       final abastecimento = item.item as AbastecimentoCar;
//       debugPrint('Volume: ${abastecimento.volume}L');
//       break;
//     case 'manutencao':
//       final manutencao = item.item as ManutencaoCar;
//       debugPrint('Serviço: ${manutencao.descricao}');
//       break;
//     // ... handle other types
//   }
// }
