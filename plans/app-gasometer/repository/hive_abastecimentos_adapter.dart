// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/foundation.dart';

// Project imports:
import '../../../core/interfaces/realtime_repository_interface.dart';
import '../database/23_abastecimento_model.dart';
import 'abastecimentos_repository.dart';
import 'veiculos_repository.dart';

/// Adapter que conecta o repositório Hive existente com a interface RealtimeRepositoryInterface
///
/// Este adapter permite que o AbastecimentosRepository existente seja usado
/// com a nova arquitetura de sincronização, sem modificar o código original.
class HiveAbastecimentosAdapter
    implements RealtimeRepositoryInterface<AbastecimentoCar> {
  final AbastecimentosRepository _hiveRepo = AbastecimentosRepository();
  final VeiculosRepository _veiculosRepo = VeiculosRepository();

  // Stream controllers para simular streams reativas do Hive
  final StreamController<List<AbastecimentoCar>> _allItemsController =
      StreamController<List<AbastecimentoCar>>.broadcast();
  final Map<String, StreamController<AbastecimentoCar?>> _itemControllers = {};

  // Timer para polling periódico (simulando reatividade)
  // TODO: OPTIMIZE - Since AbastecimentosRepository now uses BoxManager,
  // this polling approach can be replaced with more efficient BoxManager events
  Timer? _pollingTimer;
  List<AbastecimentoCar> _lastKnownItems = [];

  @override
  bool get isInitialized => true; // Hive já está inicializado no main

  @override
  bool get isOnline => true; // Hive sempre disponível localmente

  @override
  Future<void> initialize() async {
    // Hive já foi inicializado no main.dart
    // Aqui apenas iniciamos o polling para simular reatividade
    _startPolling();
  }

  /// Iniciar polling para simular streams reativas
  void _startPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(const Duration(seconds: 2), (timer) async {
      try {
        final currentItems = await findAll();

        // Verificar se houve mudanças
        if (!_listEquals(_lastKnownItems, currentItems)) {
          _lastKnownItems = List.from(currentItems);
          _allItemsController.add(currentItems);

          // Atualizar streams individuais
          for (final item in currentItems) {
            final controller = _itemControllers[item.id];
            if (controller != null && !controller.isClosed) {
              controller.add(item);
            }
          }
        }
      } catch (e) {
        debugPrint('❌ Erro no polling do HiveAbastecimentosAdapter: $e');
      }
    });
  }

  /// Comparar duas listas para detectar mudanças
  bool _listEquals(List<AbastecimentoCar> list1, List<AbastecimentoCar> list2) {
    if (list1.length != list2.length) return false;

    for (int i = 0; i < list1.length; i++) {
      if (list1[i].id != list2[i].id ||
          list1[i].updatedAt != list2[i].updatedAt) {
        return false;
      }
    }
    return true;
  }

  @override
  Stream<List<AbastecimentoCar>> watchAll() {
    // Emitir dados iniciais
    findAll().then((items) {
      if (!_allItemsController.isClosed) {
        _allItemsController.add(items);
      }
    }).catchError((e) {
      if (!_allItemsController.isClosed) {
        _allItemsController.addError(e);
      }
    });

    return _allItemsController.stream;
  }

  @override
  Stream<AbastecimentoCar?> watchById(String id) {
    // Criar controller específico para este ID se não existir
    if (!_itemControllers.containsKey(id)) {
      _itemControllers[id] = StreamController<AbastecimentoCar?>.broadcast();
    }

    final controller = _itemControllers[id]!;

    // Emitir dado inicial
    findById(id).then((item) {
      if (!controller.isClosed) {
        controller.add(item);
      }
    }).catchError((e) {
      if (!controller.isClosed) {
        controller.addError(e);
      }
    });

    return controller.stream;
  }

  @override
  Future<List<AbastecimentoCar>> findAll() async {
    try {
      // Buscar de todos os veículos, já que o repositório existente funciona por veículo
      final veiculos = await _veiculosRepo.getVeiculos();
      final List<AbastecimentoCar> todosAbastecimentos = [];

      for (final veiculo in veiculos) {
        if (!veiculo.isDeleted) {
          final abastecimentos = await _hiveRepo.getAbastecimentos(veiculo.id);
          todosAbastecimentos.addAll(abastecimentos);
        }
      }

      // Ordenar por data (mais recente primeiro)
      todosAbastecimentos.sort((a, b) => b.data.compareTo(a.data));

      return todosAbastecimentos;
    } catch (e) {
      throw Exception('Erro ao buscar todos os abastecimentos: $e');
    }
  }

  @override
  Future<AbastecimentoCar?> findById(String id) async {
    try {
      return await _hiveRepo.getAbastecimentoById(id);
    } catch (e) {
      debugPrint('❌ Erro ao buscar abastecimento por ID $id: $e');
      return null;
    }
  }

  @override
  Future<String> create(AbastecimentoCar item) async {
    try {
      final success = await _hiveRepo.addAbastecimento(item);
      if (success) {
        // Triggerar atualização dos streams
        _triggerStreamUpdate();
        return item.id;
      }
      throw Exception('Falha ao criar abastecimento no Hive');
    } catch (e) {
      throw Exception('Erro ao criar abastecimento: $e');
    }
  }

  @override
  Future<void> update(String id, AbastecimentoCar item) async {
    try {
      final success = await _hiveRepo.updateAbastecimento(item);
      if (!success) {
        throw Exception('Falha ao atualizar abastecimento no Hive');
      }
      // Triggerar atualização dos streams
      _triggerStreamUpdate();
    } catch (e) {
      throw Exception('Erro ao atualizar abastecimento: $e');
    }
  }

  @override
  Future<void> delete(String id) async {
    try {
      final item = await findById(id);
      if (item != null) {
        final success = await _hiveRepo.deleteAbastecimento(item);
        if (!success) {
          throw Exception('Falha ao deletar abastecimento no Hive');
        }
        // Triggerar atualização dos streams
        _triggerStreamUpdate();
      }
    } catch (e) {
      throw Exception('Erro ao deletar abastecimento: $e');
    }
  }

  /// Triggerar atualização manual dos streams
  void _triggerStreamUpdate() {
    Future.delayed(const Duration(milliseconds: 100), () async {
      try {
        final items = await findAll();
        if (!_allItemsController.isClosed) {
          _allItemsController.add(items);
        }
      } catch (e) {
        debugPrint('❌ Erro ao triggerar atualização do stream: $e');
      }
    });
  }

  // Implementações dos métodos em lote (usar métodos individuais por enquanto)

  @override
  Future<void> createBatch(List<AbastecimentoCar> items) async {
    try {
      for (final item in items) {
        await create(item);
      }
    } catch (e) {
      throw Exception('Erro ao criar abastecimentos em lote: $e');
    }
  }

  @override
  Future<void> updateBatch(Map<String, AbastecimentoCar> items) async {
    try {
      for (final entry in items.entries) {
        await update(entry.key, entry.value);
      }
    } catch (e) {
      throw Exception('Erro ao atualizar abastecimentos em lote: $e');
    }
  }

  @override
  Future<void> deleteBatch(List<String> ids) async {
    try {
      for (final id in ids) {
        await delete(id);
      }
    } catch (e) {
      throw Exception('Erro ao deletar abastecimentos em lote: $e');
    }
  }

  @override
  Future<void> clear() async {
    // Por segurança, não implementamos clear no adapter Hive
    // O usuário deve usar os métodos específicos do app
    throw UnimplementedError(
        'Clear não implementado no HiveAbastecimentosAdapter por segurança');
  }

  /// Métodos específicos para abastecimentos

  /// Buscar abastecimentos por veículo
  Future<List<AbastecimentoCar>> findByVeiculo(String veiculoId) async {
    try {
      return await _hiveRepo.getAbastecimentos(veiculoId);
    } catch (e) {
      throw Exception('Erro ao buscar abastecimentos do veículo: $e');
    }
  }

  /// Stream de abastecimentos por veículo
  Stream<List<AbastecimentoCar>> watchByVeiculo(String veiculoId) {
    return watchAll().map((allItems) =>
        allItems.where((item) => item.veiculoId == veiculoId).toList());
  }

  /// Obter estatísticas usando métodos do repositório existente
  Future<Map<String, double>> getMonthlyAnalytics(
      DateTime date, String veiculoId) async {
    try {
      return await _hiveRepo.getMonthlyAnalytics(date, veiculoId);
    } catch (e) {
      throw Exception('Erro ao obter analytics mensais: $e');
    }
  }

  /// Exportar para CSV usando método existente
  Future<String> exportToCsv(String veiculoId) async {
    try {
      return await _hiveRepo.exportToCsv(veiculoId);
    } catch (e) {
      throw Exception('Erro ao exportar CSV: $e');
    }
  }

  /// Limpar recursos
  void dispose() {
    _pollingTimer?.cancel();
    _allItemsController.close();

    for (final controller in _itemControllers.values) {
      controller.close();
    }
    _itemControllers.clear();
  }
}
