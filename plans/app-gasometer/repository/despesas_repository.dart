// Flutter imports:
// Package imports:
import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';

// Project imports:
import '../../core/services/firebase_firestore_service.dart';
import '../database/22_despesas_model.dart';
import '../pages/cadastros/veiculos_page/services/box_manager.dart';

// TODO: Melhorias de Código Fonte:
// TODO: Implementar cache para consultas frequentes e reduzir acesso ao Hive
// TODO: Adicionar validações para os dados de entrada nos métodos CRUD
// TODO: Refatorar métodos add/update para evitar duplicação de código
// TODO: Utilizar enum para tipos de despesa em vez de strings
// TODO: Implementar mecanismo de retry para operações com o Firebase
// TODO: Adicionar métodos de paginação para grandes volumes de dados
// FIXED: Resource leaks resolved by using BoxManager singleton for box management
// BUG: Método _getById pode retornar despesas inativas

// TODO: Melhorias Visuais/Funcionalidades:
// TODO: Implementar sistema de categorização personalizada para despesas
// TODO: Adicionar suporte para anexar comprovantes/imagens às despesas
// TODO: Implementar exportação para outros formatos (PDF, Excel) além de CSV
// TODO: Criar sistema de notificações para despesas recorrentes
// TODO: Adicionar funcionalidade de backup manual e restauração de dados
// TODO: Implementar análise de gastos com gráficos comparativos por período
// TODO: Criar função para detecção e sugestão de economia baseada no histórico
// TODO: Adicionar suporte a múltiplas moedas para usuários internacionais

class DespesasRepository {
  // MARK: - Constants
  static const String _boxName = 'box_car_despesas';
  static const String collectionName = 'box_car_despesas';

  // MARK: - Dependencies
  final _firestore = FirestoreService();

  // MARK: - Properties
  Future<Box<DespesaCar>> get _box => BoxManager.instance.getBox<DespesaCar>(_boxName);

  // MARK: - Constructor
  DespesasRepository() {
    // Initialize any dependencies here if needed
  }

  // MARK: - Public API
  Future<void> initialize() => _initialize();
  Future<Map<DateTime, List<DespesaCar>>> getDespesasAgrupadas(
    String veiculoId,
  ) =>
      _getGroupedDespesas(veiculoId);
  Future<DespesaCar?> getDespesaById(String id) => _getById(id);
  Future<bool> addDespesa(DespesaCar despesa) => _add(despesa);
  Future<bool> updateDespesa(DespesaCar despesa) => _update(despesa);
  Future<bool> deleteDespesa(DespesaCar despesa) => _delete(despesa);
  Future<List<DespesaCar>> getDespesasByPeriodo(
          String veiculoId, DateTime inicio, DateTime fim) =>
      _getDespesasByPeriodo(veiculoId, inicio, fim);
  Future<String> exportToCsv(String veiculoId) => _exportToCsv(veiculoId);

  // MARK: - Initialization
  Future<void> _initialize() async {
    try {
      if (!Hive.isAdapterRegistered(22)) {
        Hive.registerAdapter(DespesaCarAdapter());
      }
    } catch (e) {
      debugPrint('Error initializing DespesasRepository: $e');
      rethrow;
    }
  }

  // MARK: - Box Management
  // Box management now handled by BoxManager - no need for manual open/close

  // MARK: - CRUD Operations
  Future<Map<DateTime, List<DespesaCar>>> _getGroupedDespesas(
    String veiculoId,
  ) async {
    try {
      final box = await _box;
      final despesas = box.values
          .where(
            (despesa) => despesa.veiculoId == veiculoId && !despesa.isDeleted,
          )
          .toList()
        ..sort((a, b) => b.data.compareTo(a.data));

      final grouped = groupBy(despesas, (DespesaCar despesa) {
        final date = DateTime.fromMillisecondsSinceEpoch(despesa.data);
        return DateTime(date.year, date.month);
      });

      return Map.fromEntries(
        grouped.entries.toList()..sort((a, b) => b.key.compareTo(a.key)),
      );
    } catch (e) {
      debugPrint('Error getting grouped despesas: $e');
      return {};
    }
  }

  Future<DespesaCar?> _getById(String id) async {
    try {
      final box = await _box;
      return box.get(id);
    } catch (e) {
      debugPrint('Error getting Despesa by ID: $e');
      return null;
    }
  }

  // MARK: - Data Modification Operations
  Future<bool> _add(DespesaCar despesa) async {
    try {
      final box = await _box;
      // Adiciona o objeto no Hive e captura a chave
      final key = await box.add(despesa);

      // Cria o registro no Firebase
      await _firestore.createRecord(
        collection: collectionName,
        data: despesa.toMap(),
      );

      // Marca como sincronizado
      despesa.markAsSynced();
      await box.put(key, despesa);

      return true;
    } catch (e) {
      debugPrint('Error adding Despesa: $e');
      return false;
    }
  }

  Future<bool> _update(DespesaCar despesa) async {
    try {
      final box = await _box;
      final index = box.values.toList().indexWhere(
            (item) => item.id == despesa.id,
          );

      if (index != -1) {
        // Atualiza o campo updatedAt com a data atual
        despesa.updatedAt = DateTime.now().millisecondsSinceEpoch;

        await box.putAt(index, despesa);
        await _firestore.updateRecord(
          collection: collectionName,
          recordId: despesa.id,
          data: despesa.toMap(),
        );

        // Marca como sincronizado
        despesa.markAsSynced();

        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error updating Despesa: $e');
      return false;
    }
  }

  Future<bool> _delete(DespesaCar despesa) async {
    try {
      final box = await _box;
      final index = box.values.toList().indexWhere(
            (item) => item.id == despesa.id,
          );

      if (index != -1) {
        // Marca o registro como deletado
        despesa.markAsDeleted();

        await box.putAt(index, despesa);
        await _firestore.updateRecord(
          collection: collectionName,
          recordId: despesa.id,
          data: despesa.toMap(),
        );

        // Marca como sincronizado
        despesa.markAsSynced();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error deleting Despesa: $e');
      return false;
    }
  }

  // Obtém despesas de um período específico
  Future<List<DespesaCar>> _getDespesasByPeriodo(
      String veiculoId, DateTime inicio, DateTime fim) async {
    try {
      final box = await _box;

      // Converte datas para timestamp
      final inicioTimestamp = inicio.millisecondsSinceEpoch;
      final fimTimestamp = fim.millisecondsSinceEpoch;

      // Filtra as despesas pelo período
      final despesas = box.values
          .where((d) =>
              d.veiculoId == veiculoId &&
              !d.isDeleted &&
              d.data >= inicioTimestamp &&
              d.data <= fimTimestamp)
          .toList()
        ..sort((a, b) => a.data.compareTo(b.data));

      return despesas;
    } catch (e) {
      debugPrint('Error getting despesas by period: $e');
      return [];
    }
  }

  // MARK: - CSV Export
  Future<String> _exportToCsv(String veiculoId) async {
    try {
      final box = await _box;

      // Filtra apenas os registros ativos para o veículo especificado
      final despesas = box.values
          .where((d) => d.veiculoId == veiculoId && !d.isDeleted)
          .toList()
        ..sort(
            (a, b) => a.data.compareTo(b.data)); // Ordena por data (crescente)

      if (despesas.isEmpty) {
        return ''; // Retorna string vazia se não houver dados
      }

      // Define o cabeçalho do CSV com os campos relevantes
      const csvHeader = 'Data,Tipo,Descrição,Valor,Odometro\n';

      // Converte cada registro de despesa em uma linha CSV
      final csvRows = despesas.map((despesa) {
        // Converte o timestamp para data legível
        final date = DateTime.fromMillisecondsSinceEpoch(despesa.data);
        final dataFormatada = '${date.day}/${date.month}/${date.year}';

        // Escapa campos de texto que podem conter vírgulas
        final tipo = _escapeField(despesa.tipo);
        final descricao = _escapeField(despesa.descricao);

        return '$dataFormatada,$tipo,$descricao,${despesa.valor},${despesa.odometro}';
      }).join('\n');

      return csvHeader + csvRows;
    } catch (e) {
      debugPrint('Error exporting despesas to CSV: $e');
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
