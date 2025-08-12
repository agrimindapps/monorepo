// Flutter imports:
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:hive/hive.dart';

// Project imports:
import '../../core/services/firebase_firestore_service.dart';
import '../database/25_manutencao_model.dart';
import '../pages/cadastros/veiculos_page/services/box_manager.dart';

// TODO: Melhorias de Código
// TODO: Implementar padrão Repository com interface para facilitar mock em testes
// TODO: Adicionar tratamento de erro mais detalhado com propagação adequada de exceções
// TODO: Utilizar transaction para operações que envolvem múltiplos passos (Hive e Firebase)
// TODO: Implementar log estruturado em vez de debugPrint para melhor depuração
// TODO: Extrair constantes para um arquivo separado para centralizar configurações
// TODO: Aplicar métodos de retry para operações com Firestore que podem falhar por conectividade
// TODO: Utilizar injeção de dependência para FirestoreService em vez de instanciação direta
// TODO: Implementar mecanismo de cache com política de expiração para reduzir leituras desnecessárias

// TODO: Novas Funcionalidades
// TODO: Adicionar suporte para sincronização offline com mecanismo de resolução de conflitos
// TODO: Implementar funcionalidade de backup e restauração de dados
// TODO: Criar métodos para obter estatísticas e relatórios (custo mensal, anual, etc)
// TODO: Adicionar suporte para múltiplos usuários com compartilhamento de dados
// TODO: Implementar paginação para consultas com grandes volumes de dados
// TODO: Adicionar sistema de eventos para notificar mudanças nos dados (usando streams)
// TODO: Implementar busca full-text para facilitar pesquisa por descrição ou tipo
// TODO: Criar mecanismo de migração de dados para atualizações de esquema

class ManutencoesRepository {
  // MARK: - Constants
  static const String _boxName = 'box_car_manutencoes';
  static const String collectionName = 'box_car_manutencoes';

  // MARK: - Dependencies
  final _firestore = FirestoreService();

  // MARK: - Properties
  Future<Box<ManutencaoCar>> get _box => BoxManager.instance.getBox<ManutencaoCar>(_boxName);

  // MARK: - Singleton Implementation
  static final ManutencoesRepository _instance =
      ManutencoesRepository._internal();
  factory ManutencoesRepository() => _instance;
  ManutencoesRepository._internal();

  // MARK: - Public API
  static Future<void> initialize() => _initialize();
  Future<List<ManutencaoCar>> getManutencoes(String veiculoId) =>
      _getAll(veiculoId);
  Future<ManutencaoCar?> getManutencaoById(String id) => _getById(id);
  Future<bool> addManutencao(ManutencaoCar manutencao) => _add(manutencao);
  Future<bool> updateManutencao(ManutencaoCar manutencao) =>
      _update(manutencao);
  Future<bool> deleteManutencao(ManutencaoCar manutencao) =>
      _delete(manutencao);
  Future<List<ManutencaoCar>> getManutencoesVencidas() => _getExpired();
  Future<List<ManutencaoCar>> getManutencoesProximas(int odometroAtual) =>
      _getUpcoming(odometroAtual);

  // MARK: - Initialization
  static Future<void> _initialize() async {
    try {
      if (!Hive.isAdapterRegistered(25)) {
        Hive.registerAdapter(ManutencaoCarAdapter());
      }
    } catch (e) {
      debugPrint('Error initializing ManutencoesRepository: $e');
      rethrow;
    }
  }

  // MARK: - Box Management
  // Box management now handled by BoxManager - no need for manual open/close

  // MARK: - CRUD Operations
  Future<List<ManutencaoCar>> _getAll(String veiculoId) async {
    try {
      final box = await _box;
      return box.values
          .where(
            (manutencao) =>
                manutencao.veiculoId == veiculoId && !manutencao.isDeleted,
          )
          .toList()
        ..sort((a, b) => b.data.compareTo(a.data));
    } catch (e) {
      debugPrint('Error getting manutencoes: $e');
      return [];
    }
  }

  Future<ManutencaoCar?> _getById(String id) async {
    try {
      final box = await _box;
      return box.get(id);
    } catch (e) {
      debugPrint('Error getting Manutencao by ID: $e');
      return null;
    }
  }

  Future<bool> _add(ManutencaoCar manutencao) async {
    try {
      final box = await _box;
      // Adiciona o objeto no Hive e captura a chave
      final key = await box.add(manutencao);

      // Cria o registro no Firebase
      await _firestore.createRecord(
        collection: collectionName,
        data: manutencao.toMap(),
      );

      // Marca como sincronizado
      manutencao.markAsSynced();
      await box.put(key, manutencao);

      return true;
    } catch (e) {
      debugPrint('Error adding Manutencao: $e');
      return false;
    }
  }

  Future<bool> _update(ManutencaoCar manutencao) async {
    try {
      final box = await _box;
      final index = box.values.toList().indexWhere(
            (item) => item.id == manutencao.id,
          );

      if (index != -1) {
        // Atualiza o campo updatedAt com a data atual (em microsegundos)
        manutencao.updatedAt = DateTime.now().millisecondsSinceEpoch;

        await box.putAt(index, manutencao);
        await _firestore.updateRecord(
          collection: collectionName,
          recordId: manutencao.id,
          data: manutencao.toMap(),
        );

        // Marca como sincronizado
        manutencao.markAsSynced();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error updating Manutencao: $e');
      return false;
    }
  }

  Future<bool> _delete(ManutencaoCar manutencao) async {
    try {
      final box = await _box;
      final index = box.values.toList().indexWhere(
            (item) => item.id == manutencao.id,
          );

      if (index != -1) {
        // Marca o registro como deletado
        manutencao.markAsDeleted();

        await box.putAt(index, manutencao);
        await _firestore.updateRecord(
          collection: collectionName,
          recordId: manutencao.id,
          data: manutencao.toMap(),
        );

        // Marca como sincronizado
        manutencao.markAsSynced();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error deleting Manutencao: $e');
      return false;
    }
  }

  // MARK: - Specialized Operations
  Future<List<ManutencaoCar>> _getExpired() async {
    try {
      final box = await _box;
      return box.values.where((m) => m.estaVencida()).toList();
    } catch (e) {
      debugPrint('Error getting Manutencoes Vencidas: $e');
      return [];
    }
  }

  Future<List<ManutencaoCar>> _getUpcoming(int odometroAtual) async {
    try {
      final box = await _box;
      return box.values.where((m) => m.precisaRevisao(odometroAtual)).toList();
    } catch (e) {
      debugPrint('Error getting Manutencoes Proximas: $e');
      return [];
    }
  }
}
