// Flutter imports:
// Package imports:
import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';

// Project imports:
import '../../../../../core/services/firebase_firestore_service.dart';
import '../database/23_abastecimento_model.dart';
import '../pages/cadastros/veiculos_page/services/box_manager.dart';

class AbastecimentosRepository {
  // MARK: - Constants
  static const String _boxName = 'box_car_abastecimentos';
  static const String collectionName = 'box_car_abastecimentos';

  // MARK: - Dependencies
  final _firestore = FirestoreService();

  // MARK: - Properties
  Future<Box<AbastecimentoCar>> get _box => BoxManager.instance.getBox<AbastecimentoCar>(_boxName);

  // MARK: - Constructor
  AbastecimentosRepository();

  // MARK: - Public API
  static Future<void> initialize() => _initialize();
  Future<List<AbastecimentoCar>> getAbastecimentos(
    String veiculoId,
  ) =>
      _getAll(veiculoId);
  Future<AbastecimentoCar?> getAbastecimentoById(
    String id,
  ) =>
      _getById(id);
  Future<bool> addAbastecimento(
    AbastecimentoCar abastecimento,
  ) =>
      _add(abastecimento);
  Future<bool> updateAbastecimento(
    AbastecimentoCar abastecimento,
  ) =>
      _update(abastecimento);
  Future<bool> deleteAbastecimento(
    AbastecimentoCar abastecimento,
  ) =>
      _delete(abastecimento);

  // API mantida para compatibilidade, pode ser simplificada no futuro
  Future<Map<DateTime, List<AbastecimentoCar>>> getAbastecimentosAgrupados(
    String veiculoId,
  ) =>
      _getGrouped(veiculoId);

  Future<Map<String, double>> getMonthlyAnalytics(
    DateTime date,
    String veiculoId,
  ) =>
      _getMonthlyAnalytics(date, veiculoId);

  Future<List<DateTime>> getMonthsList(
    String veiculoId,
  ) =>
      _getMonthsList(veiculoId);

  Future<Map<String, Map<String, double>>> getAbastecimentosEstatisticas(
    String veiculoId,
  ) =>
      _getAbastecimentosEstatisticas(veiculoId);

  Future<String> exportToCsv(String veiculoId) => _exportToCsv(veiculoId);

  // MARK: - Initialization
  static Future<void> _initialize() async {
    try {
      if (!Hive.isAdapterRegistered(23)) {
        Hive.registerAdapter(AbastecimentoCarAdapter());
      }
    } catch (e) {
      debugPrint('Error initializing AbastecimentosRepository: $e');
      rethrow;
    }
  }

  // MARK: - Box Management
  // Box management now handled by BoxManager - no need for manual open/close

  // MARK: - CRUD Operations
  Future<List<AbastecimentoCar>> _getAll(String veiculoId) async {
    try {
      final box = await _box;

      final filtered = box.values
          .where((item) => item.veiculoId == veiculoId && !item.isDeleted)
          .toList();

      filtered.sort((a, b) => b.data.compareTo(a.data));

      return filtered;
    } catch (e) {
      debugPrint('Error getting abastecimentos: $e');
      return [];
    }
  }

  Future<AbastecimentoCar?> _getById(String id) async {
    try {
      final box = await _box;
      return box.get(id);
    } catch (e) {
      debugPrint('Error getting Abastecimento by ID: $e');
      return null;
    }
  }

  // MARK: - Data Modification Operations
  Future<bool> _add(AbastecimentoCar abastecimento) async {
    try {
      final box = await _box;
      // Adiciona o objeto no Hive e captura a chave
      final key = await box.add(abastecimento);

      // Cria o registro no Firebase
      await _firestore.createRecord(
        collection: collectionName,
        data: abastecimento.toMap(),
      );

      // Marca como sincronizado
      abastecimento.markAsSynced();
      await box.put(key, abastecimento);

      // Verificação de odômetro foi movida para o controller
      return true;
    } catch (e) {
      debugPrint('Error adding Abastecimento: $e');
      return false;
    }
  }

  Future<bool> _update(AbastecimentoCar abastecimento) async {
    try {
      final box = await _box;
      final index = box.values
          .toList()
          .indexWhere((item) => item.id == abastecimento.id);

      if (index != -1) {
        // Atualiza o campo updatedAt com a data atual (em microsegundos)
        abastecimento.updatedAt = DateTime.now().millisecondsSinceEpoch;

        await box.putAt(index, abastecimento);
        await _firestore.updateRecord(
          collection: collectionName,
          recordId: abastecimento.id,
          data: abastecimento.toMap(),
        );

        // Marca como sincronizado
        abastecimento.markAsSynced();

        // Verificação de odômetro foi movida para o controller
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error updating Abastecimento: $e');
      return false;
    }
  }

  Future<bool> _delete(AbastecimentoCar abastecimento) async {
    try {
      final box = await _box;
      final index = box.values
          .toList()
          .indexWhere((item) => item.id == abastecimento.id);

      if (index != -1) {
        // Define o registro como deletado e atualiza o campo updatedAt
        abastecimento.markAsDeleted();

        await box.putAt(index, abastecimento);
        await _firestore.updateRecord(
          collection: collectionName,
          recordId: abastecimento.id,
          data: abastecimento.toMap(),
        );

        // Marca como sincronizado
        abastecimento.markAsSynced();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error deleting Abastecimento: $e');
      return false;
    }
  }

  // MARK: - Métodos mantidos para compatibilidade com código existente
  // Essas funções poderiam ser movidas completamente para o controller em uma refatoração mais completa
  Future<Map<DateTime, List<AbastecimentoCar>>> _getGrouped(
      String veiculoId) async {
    try {
      final abastecimentos = await _getAll(veiculoId);

      final grouped = groupBy(abastecimentos, (AbastecimentoCar abastecimento) {
        final date = DateTime.fromMillisecondsSinceEpoch(abastecimento.data);
        return DateTime(date.year, date.month);
      });

      final result = Map.fromEntries(
          grouped.entries.toList()..sort((a, b) => b.key.compareTo(a.key)));

      return result;
    } catch (e) {
      debugPrint('Error getting grouped abastecimentos: $e');
      return {};
    }
  }

  Future<Map<String, double>> _getMonthlyAnalytics(
      DateTime date, String veiculoId) async {
    try {
      final abastecimentosDoMes =
          await _getAbastecimentosDoMes(date, veiculoId);

      final totalGastoMes =
          abastecimentosDoMes.fold(0.0, (sum, item) => sum + item.valorTotal);
      final totalLitrosMes =
          abastecimentosDoMes.fold(0.0, (sum, item) => sum + item.litros);
      final precoMedioLitro =
          totalLitrosMes > 0 ? totalGastoMes / totalLitrosMes : 0.0;

      double mediaConsumoMes = 0.0;
      if (abastecimentosDoMes.length > 1) {
        final kmInicial = abastecimentosDoMes.last.odometro;
        final kmFinal = abastecimentosDoMes.first.odometro;
        final distanciaPercorrida = kmFinal - kmInicial;
        mediaConsumoMes = distanciaPercorrida / totalLitrosMes;
      }

      return {
        'totalGastoMes': totalGastoMes,
        'totalLitrosMes': totalLitrosMes,
        'precoMedioLitro': precoMedioLitro,
        'mediaConsumoMes': mediaConsumoMes,
      };
    } catch (e) {
      debugPrint('Error calculating monthly analytics: $e');
      return {};
    }
  }

  Future<List<DateTime>> _getMonthsList(String veiculoId) async {
    try {
      final abastecimentos = await _getAll(veiculoId);
      if (abastecimentos.isEmpty) return [];

      final dates = abastecimentos
          .map((a) => DateTime.fromMillisecondsSinceEpoch(a.data))
          .toList();

      final oldestDate = dates.reduce((a, b) => a.isBefore(b) ? a : b);
      final newestDate = dates.reduce((a, b) => a.isAfter(b) ? a : b);

      List<DateTime> allMonths = [];
      DateTime currentDate = DateTime(oldestDate.year, oldestDate.month);
      final lastDate = DateTime(newestDate.year, newestDate.month);

      while (!currentDate.isAfter(lastDate)) {
        allMonths.add(currentDate);
        currentDate = DateTime(
          currentDate.year + (currentDate.month == 12 ? 1 : 0),
          currentDate.month == 12 ? 1 : currentDate.month + 1,
        );
      }

      return allMonths.reversed.toList();
    } catch (e) {
      debugPrint('Error getting months list: $e');
      return [];
    }
  }

  Future<List<AbastecimentoCar>> _getAbastecimentosDoMes(
      DateTime date, String veiculoId) async {
    final allAbastecimentos = await _getAll(veiculoId);
    return allAbastecimentos.where((abastecimento) {
      final abasteData =
          DateTime.fromMillisecondsSinceEpoch(abastecimento.data);
      return abasteData.year == date.year && abasteData.month == date.month;
    }).toList();
  }

  Future<Map<String, Map<String, double>>> _getAbastecimentosEstatisticas(
    String veiculoId,
  ) async {
    try {
      final now = DateTime.now();
      final allAbastecimentos = await _getAll(veiculoId);

      // Filtra apenas registros não deletados
      final nonDeletedAbastecimentos =
          allAbastecimentos.where((a) => !a.isDeleted).toList();

      // Define períodos
      final esteMes = DateTime(now.year, now.month);
      final mesAnterior = DateTime(now.year, now.month - 1);
      final esteAno = DateTime(now.year);
      final anoAnterior = DateTime(now.year - 1);

      // Função auxiliar para calcular totais
      Map<String, double> calcularTotais(
          List<AbastecimentoCar> abastecimentos) {
        final totalCusto =
            abastecimentos.fold(0.0, (sum, item) => sum + item.valorTotal);
        final totalLitros =
            abastecimentos.fold(0.0, (sum, item) => sum + item.litros);
        return {
          'custo': totalCusto,
          'litros': totalLitros,
        };
      }

      // Filtrar abastecimentos por período
      final abastecimentosEsteMes = nonDeletedAbastecimentos.where((a) {
        final data = DateTime.fromMillisecondsSinceEpoch(a.data);
        return data.year == esteMes.year && data.month == esteMes.month;
      }).toList();

      final abastecimentosMesAnterior = nonDeletedAbastecimentos.where((a) {
        final data = DateTime.fromMillisecondsSinceEpoch(a.data);
        return data.year == mesAnterior.year && data.month == mesAnterior.month;
      }).toList();

      final abastecimentosEsteAno = nonDeletedAbastecimentos.where((a) {
        final data = DateTime.fromMillisecondsSinceEpoch(a.data);
        return data.year == esteAno.year;
      }).toList();

      final abastecimentosAnoAnterior = nonDeletedAbastecimentos.where((a) {
        final data = DateTime.fromMillisecondsSinceEpoch(a.data);
        return data.year == anoAnterior.year;
      }).toList();

      // Retornar resultados
      return {
        'esteMes': calcularTotais(abastecimentosEsteMes),
        'mesAnterior': calcularTotais(abastecimentosMesAnterior),
        'esteAno': calcularTotais(abastecimentosEsteAno),
        'anoAnterior': calcularTotais(abastecimentosAnoAnterior),
      };
    } catch (e) {
      debugPrint('Error getting períodos de abastecimentos: $e');
      return {};
    }
  }

  // Método de exportação - mantido no repositório pois envolve formatação de dados
  Future<String> _exportToCsv(String veiculoId) async {
    try {
      // Obter todos os abastecimentos ativos do veículo
      final abastecimentos = await _getAll(veiculoId);

      if (abastecimentos.isEmpty) {
        return ''; // Retorna string vazia se não houver dados
      }

      // Define o cabeçalho do CSV com os campos relevantes
      const csvHeader =
          'Data,Odometro,Litros,Valor Total,Preço por Litro,Posto,Tanque Cheio,Tipo de Combustível,Observação\n';

      // Converte cada registro de abastecimento em uma linha CSV
      final csvRows = abastecimentos.map((abastecimento) {
        // Converte o timestamp para data legível
        final date = DateTime.fromMillisecondsSinceEpoch(abastecimento.data);
        final dataFormatada = '${date.day}/${date.month}/${date.year}';

        // Converte o tipo de combustível para texto
        final tipoCombustivel =
            _combustivelToString(abastecimento.tipoCombustivel);

        // Escapa campos de texto que podem conter vírgulas
        final posto = _escapeField(abastecimento.posto ?? '');
        final observacao = _escapeField(abastecimento.observacao ?? '');

        return '$dataFormatada,${abastecimento.odometro},${abastecimento.litros},${abastecimento.valorTotal},${abastecimento.precoPorLitro},$posto,${abastecimento.tanqueCheio ?? false},$tipoCombustivel,$observacao';
      }).join('\n');

      return csvHeader + csvRows;
    } catch (e) {
      debugPrint('Error exporting abastecimentos to CSV: $e');
      return '';
    }
  }

  // Métodos auxiliares - deveriam ser movidos para o controller em uma refatoração completa
  String _combustivelToString(int tipo) {
    switch (tipo) {
      case 0:
        return 'Gasolina';
      case 1:
        return 'Etanol';
      case 2:
        return 'Diesel';
      case 3:
        return 'GNV';
      case 4:
        return 'Elétrico';
      case 5:
        return 'Híbrido';
      default:
        return 'Desconhecido';
    }
  }

  String _escapeField(String field) {
    if (field.contains(',') || field.contains('"') || field.contains('\n')) {
      // Substitui aspas duplas por duas aspas duplas e envolve em aspas
      return '"${field.replaceAll('"', '""')}"';
    }
    return field;
  }
}
