// Package imports:
import 'package:connectivity_plus/connectivity_plus.dart';

// Project imports:
import '../../../core/services/firebase_firestore_service.dart';
import '../constants/firebase_collections.dart';
import '../database/23_abastecimento_model.dart';

/// Repositório Firebase para AbastecimentoCar com sincronização em tempo real
///
/// Este repositório usa o FirestoreService para gerenciar abastecimentos no Firebase Firestore.
class RealtimeAbastecimentosRepository {
  final FirestoreService _firestore = FirestoreService();

  /// Verifica se há conexão com a internet
  Future<bool> get isOnline async {
    try {
      final connectivityResults = await Connectivity().checkConnectivity();
      return !connectivityResults.contains(ConnectivityResult.none);
    } catch (e) {
      return false;
    }
  }

  /// Buscar todos os abastecimentos
  Future<List<AbastecimentoCar>> findAll() async {
    if (!await isOnline) {
      throw Exception('Serviço offline - não é possível buscar abastecimentos');
    }

    try {
      final records = await _firestore.readRecords(
        collection: FirebaseCollections.abastecimentos,
      );

      return records.map((record) => AbastecimentoCar.fromMap(record)).toList();
    } catch (e) {
      throw Exception('Erro ao buscar abastecimentos: $e');
    }
  }

  /// Buscar abastecimentos por veículo específico
  Future<List<AbastecimentoCar>> findByVeiculo(String veiculoId) async {
    if (!await isOnline) {
      throw Exception('Serviço offline - não é possível buscar por veículo');
    }

    try {
      final records = await _firestore.queryRecords(
        collection: FirebaseCollections.abastecimentos,
        filters: {'veiculoId': veiculoId},
      );

      return records.map((record) => AbastecimentoCar.fromMap(record)).toList();
    } catch (e) {
      throw Exception(
          'Erro ao buscar abastecimentos do veículo $veiculoId: $e');
    }
  }

  /// Stream de abastecimentos por veículo específico
  Stream<List<AbastecimentoCar>> watchByVeiculo(String veiculoId) {
    return _firestore.escutarRegistros(FirebaseCollections.abastecimentos).map(
        (records) => records
            .where((record) => record['veiculoId'] == veiculoId)
            .map((record) => AbastecimentoCar.fromMap(record))
            .toList());
  }

  /// Stream de todos os abastecimentos
  Stream<List<AbastecimentoCar>> watchAll() {
    return _firestore.escutarRegistros(FirebaseCollections.abastecimentos).map(
        (records) =>
            records.map((record) => AbastecimentoCar.fromMap(record)).toList());
  }

  /// Buscar abastecimentos em um período específico
  Future<List<AbastecimentoCar>> findByPeriodo({
    required String veiculoId,
    required int dataInicial,
    required int dataFinal,
  }) async {
    if (!await isOnline) {
      throw Exception('Serviço offline - não é possível buscar por período');
    }

    try {
      // Como o Firestore não suporta múltiplos filtros complexos facilmente,
      // vamos buscar por veículo e filtrar localmente por data
      final abastecimentos = await findByVeiculo(veiculoId);

      return abastecimentos.where((abastecimento) {
        return abastecimento.data >= dataInicial &&
            abastecimento.data <= dataFinal;
      }).toList();
    } catch (e) {
      throw Exception('Erro ao buscar abastecimentos por período: $e');
    }
  }

  /// Buscar último abastecimento de um veículo
  Future<AbastecimentoCar?> findUltimoAbastecimento(String veiculoId) async {
    if (!await isOnline) {
      throw Exception(
          'Serviço offline - não é possível buscar último abastecimento');
    }

    try {
      final abastecimentos = await findByVeiculo(veiculoId);

      if (abastecimentos.isEmpty) return null;

      // Ordenar por data (mais recente primeiro) e retornar o primeiro
      abastecimentos.sort((a, b) => b.data.compareTo(a.data));
      return abastecimentos.first;
    } catch (e) {
      throw Exception('Erro ao buscar último abastecimento: $e');
    }
  }

  /// Calcular estatísticas básicas dos abastecimentos de um veículo
  Future<Map<String, double>> calcularEstatisticas(String veiculoId) async {
    if (!await isOnline) {
      throw Exception('Serviço offline - não é possível calcular estatísticas');
    }

    try {
      final abastecimentos = await findByVeiculo(veiculoId);

      if (abastecimentos.isEmpty) {
        return {
          'totalGasto': 0.0,
          'totalLitros': 0.0,
          'precoMedioLitro': 0.0,
          'consumoMedio': 0.0,
        };
      }

      final totalGasto =
          abastecimentos.fold(0.0, (sum, item) => sum + item.valorTotal);
      final totalLitros =
          abastecimentos.fold(0.0, (sum, item) => sum + item.litros);
      final precoMedioLitro = totalLitros > 0 ? totalGasto / totalLitros : 0.0;

      // Calcular consumo médio (km/l)
      double consumoMedio = 0.0;
      if (abastecimentos.length > 1) {
        // Ordenar por data
        abastecimentos.sort((a, b) => a.data.compareTo(b.data));
        final kmInicial = abastecimentos.first.odometro;
        final kmFinal = abastecimentos.last.odometro;
        final distanciaPercorrida = kmFinal - kmInicial;

        if (distanciaPercorrida > 0 && totalLitros > 0) {
          consumoMedio = distanciaPercorrida / totalLitros;
        }
      }

      return {
        'totalGasto': totalGasto,
        'totalLitros': totalLitros,
        'precoMedioLitro': precoMedioLitro,
        'consumoMedio': consumoMedio,
      };
    } catch (e) {
      throw Exception('Erro ao calcular estatísticas: $e');
    }
  }

  /// Validar dados antes de salvar
  bool validarAbastecimento(AbastecimentoCar abastecimento) {
    if (abastecimento.veiculoId.isEmpty) return false;
    if (abastecimento.litros <= 0) return false;
    if (abastecimento.valorTotal <= 0) return false;
    if (abastecimento.odometro <= 0) return false;
    if (abastecimento.precoPorLitro <= 0) return false;

    return true;
  }

  /// Criar novo abastecimento
  Future<String> create(AbastecimentoCar item) async {
    if (!validarAbastecimento(item)) {
      throw Exception('Dados do abastecimento são inválidos');
    }

    if (!await isOnline) {
      throw Exception('Serviço offline - não é possível criar abastecimento');
    }

    try {
      return await _firestore.createRecord(
        collection: FirebaseCollections.abastecimentos,
        data: item.toMap(),
      );
    } catch (e) {
      throw Exception('Erro ao criar abastecimento: $e');
    }
  }

  /// Atualizar abastecimento existente
  Future<void> update(String id, AbastecimentoCar item) async {
    if (!validarAbastecimento(item)) {
      throw Exception('Dados do abastecimento são inválidos');
    }

    if (!await isOnline) {
      throw Exception(
          'Serviço offline - não é possível atualizar abastecimento');
    }

    try {
      await _firestore.updateRecord(
        collection: FirebaseCollections.abastecimentos,
        recordId: id,
        data: item.toMap(),
      );
    } catch (e) {
      throw Exception('Erro ao atualizar abastecimento: $e');
    }
  }

  /// Deletar abastecimento
  Future<void> delete(String id) async {
    if (!await isOnline) {
      throw Exception('Serviço offline - não é possível deletar abastecimento');
    }

    try {
      await _firestore.deleteRecord(
        collection: FirebaseCollections.abastecimentos,
        recordId: id,
      );
    } catch (e) {
      throw Exception('Erro ao deletar abastecimento: $e');
    }
  }

  /// Buscar abastecimento por ID
  Future<AbastecimentoCar?> findById(String id) async {
    if (!await isOnline) {
      throw Exception('Serviço offline - não é possível buscar abastecimento');
    }

    try {
      final records = await _firestore.readRecords(
        collection: FirebaseCollections.abastecimentos,
      );

      final record = records.where((r) => r['id'] == id).firstOrNull;
      return record != null ? AbastecimentoCar.fromMap(record) : null;
    } catch (e) {
      throw Exception('Erro ao buscar abastecimento por ID: $e');
    }
  }
}
