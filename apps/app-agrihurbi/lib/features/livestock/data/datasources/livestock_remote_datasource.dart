// ignore_for_file: only_throw_errors

import 'package:app_agrihurbi/core/network/dio_client.dart';
import 'package:core/core.dart';

import '../models/bovine_model.dart';
import '../models/equine_model.dart';

/// Interface para data source remoto de livestock
abstract class LivestockRemoteDataSource {
  // === BOVINOS ===
  Future<List<BovineModel>> getAllBovines();
  Future<BovineModel?> getBovineById(String id);
  Future<void> createBovine(BovineModel bovine);
  Future<void> updateBovine(BovineModel bovine);
  Future<void> deleteBovine(String id);

  // === EQUINOS ===
  Future<List<EquineModel>> getAllEquines();
  Future<EquineModel?> getEquineById(String id);
  Future<void> createEquine(EquineModel equine);
  Future<void> updateEquine(EquineModel equine);
  Future<void> deleteEquine(String id);

  // === SYNC ===
  Future<void> syncLivestockData();
}

/// Implementação do data source remoto usando HTTP API
@LazySingleton(as: LivestockRemoteDataSource)
class LivestockRemoteDataSourceImpl implements LivestockRemoteDataSource {
  // ignore: unused_field
  final DioClient _dioClient;

  // Endpoints da API

  LivestockRemoteDataSourceImpl(this._dioClient);

  // === BOVINOS ===

  @override
  Future<List<BovineModel>> getAllBovines() async {
    try {
      // REVIEW (converted TODO 2025-10-06): Implementar chamada real para API quando estiver disponível
      // Por enquanto, retorna lista vazia para não quebrar o app
      return [];

      // final response = await _dioClient.get(
      //   _bovinesEndpoint,
      //   queryParameters: {'is_active': true},
      // );
      //
      // return (response.data as List<dynamic>)
      //     .map((item) => BovineModel.fromJson(item as Map<String, dynamic>))
      //     .toList();
    } catch (e) {
      throw const ServerFailure('Erro ao buscar bovinos');
    }
  }

  @override
  Future<BovineModel?> getBovineById(String id) async {
    try {
      // REVIEW (converted TODO 2025-10-06): Implementar quando API estiver disponível
      return null;
    } catch (e) {
      throw const ServerFailure('Erro ao buscar bovino por ID');
    }
  }

  @override
  Future<void> createBovine(BovineModel bovine) async {
    try {
      // REVIEW (converted TODO 2025-10-06): Implementar quando API estiver disponível
      // Simula sucesso por enquanto
    } catch (e) {
      throw Exception('Erro ao criar bovino: $e');
    }
  }

  @override
  Future<void> updateBovine(BovineModel bovine) async {
    try {
      // REVIEW (converted TODO 2025-10-06): Implementar quando API estiver disponível
      // Simula sucesso por enquanto
    } catch (e) {
      throw Exception('Erro ao atualizar bovino: $e');
    }
  }

  @override
  Future<void> deleteBovine(String id) async {
    try {
      // REVIEW (converted TODO 2025-10-06): Implementar quando API estiver disponível
      // Simula sucesso por enquanto
    } catch (e) {
      throw Exception('Erro ao deletar bovino: $e');
    }
  }

  // === EQUINOS ===

  @override
  Future<List<EquineModel>> getAllEquines() async {
    try {
      // REVIEW (converted TODO 2025-10-06): Implementar chamada real para API quando estiver disponível
      return [];
    } catch (e) {
      throw Exception('Erro ao buscar equinos: $e');
    }
  }

  @override
  Future<EquineModel?> getEquineById(String id) async {
    try {
      // REVIEW (converted TODO 2025-10-06): Implementar quando API estiver disponível
      return null;
    } catch (e) {
      throw Exception('Erro ao buscar equino por ID: $e');
    }
  }

  @override
  Future<void> createEquine(EquineModel equine) async {
    try {
      // REVIEW (converted TODO 2025-10-06): Implementar quando API estiver disponível
      // Simula sucesso por enquanto
    } catch (e) {
      throw Exception('Erro ao criar equino: $e');
    }
  }

  @override
  Future<void> updateEquine(EquineModel equine) async {
    try {
      // REVIEW (converted TODO 2025-10-06): Implementar quando API estiver disponível
      // Simula sucesso por enquanto
    } catch (e) {
      throw Exception('Erro ao atualizar equino: $e');
    }
  }

  @override
  Future<void> deleteEquine(String id) async {
    try {
      // REVIEW (converted TODO 2025-10-06): Implementar quando API estiver disponível
      // Simula sucesso por enquanto
    } catch (e) {
      throw Exception('Erro ao deletar equino: $e');
    }
  }

  // === SYNC ===

  @override
  Future<void> syncLivestockData() async {
    try {
      // REVIEW (converted TODO 2025-10-06): Implementar sincronização quando API estiver disponível
      // Simula sucesso por enquanto
    } catch (e) {
      throw Exception('Erro na sincronização: $e');
    }
  }
}
