// Flutter imports:
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';

// Project imports:
import '../../../../database/21_veiculos_model.dart';
import '../../../../database/enums.dart';
import '../../../../repository/veiculos_repository.dart';
import '../../veiculos_page/controller/veiculos_page_controller.dart';
import '../models/veiculos_constants.dart';

/// Service responsável pela persistência de dados de veículos
///
/// Centraliza todas as operações de CRUD e verificações de negócio
/// relacionadas aos veículos.
class VeiculoPersistenceService {
  final VeiculosRepository _repository;
  late final VeiculosPageController _listController;

  VeiculoPersistenceService({required VeiculosRepository repository})
      : _repository = repository {
    _initializeControllers();
  }

  /// Inicializa controllers externos
  void _initializeControllers() {
    try {
      _listController = Get.find<VeiculosPageController>();
    } catch (e) {
      debugPrint(
          '${VeiculosConstants.mensagensErro['inicializarControllers']}: $e');
      rethrow;
    }
  }

  /// Verifica se veículo possui lançamentos associados
  Future<bool> verificarLancamentos(String veiculoId) async {
    try {
      return await _listController.veiculoPossuiLancamentos(veiculoId);
    } catch (e) {
      debugPrint(
          '${VeiculosConstants.mensagensErro['verificarLancamentos']}: $e');
      return false;
    }
  }

  /// Cria novo veículo
  Future<VeiculoCar> criarVeiculo({
    required String marca,
    required String modelo,
    required int ano,
    required String cor,
    required TipoCombustivel combustivel,
    required double odometroInicial,
    String? placa,
    String? chassi,
    String? renavam,
    String? foto,
  }) async {
    try {
      final novoVeiculo = VeiculoCar(
        id: const Uuid().v4(),
        createdAt: DateTime.now().millisecondsSinceEpoch,
        updatedAt: DateTime.now().millisecondsSinceEpoch,
        marca: marca,
        modelo: modelo,
        ano: ano,
        placa: placa ?? '',
        odometroInicial: odometroInicial,
        cor: cor,
        combustivel: combustivel.index,
        renavan: renavam ?? '',
        chassi: chassi ?? '',
        vendido: false,
        valorVenda: 0.0,
        odometroAtual: odometroInicial,
        foto: foto,
      );

      final error = await _repository.addVeiculo(novoVeiculo);
      if (error != null) {
        throw Exception(error);
      }

      await _listController.loadVeiculos();
      if (_listController.veiculos.length == 1) {
        await _listController.selecionarVeiculo(novoVeiculo.id);
      }
      return novoVeiculo;
    } catch (e) {
      debugPrint('Erro ao criar veículo: $e');
      rethrow;
    }
  }

  /// Atualiza veículo existente
  Future<VeiculoCar> atualizarVeiculo({
    required VeiculoCar veiculoOriginal,
    required String marca,
    required String modelo,
    required int ano,
    required String cor,
    required TipoCombustivel combustivel,
    required double odometroInicial,
    String? placa,
    String? chassi,
    String? renavam,
    String? foto,
  }) async {
    try {
      final veiculoAtualizado = VeiculoCar(
        id: veiculoOriginal.id,
        createdAt: veiculoOriginal.createdAt,
        updatedAt: DateTime.now().millisecondsSinceEpoch,
        marca: marca,
        modelo: modelo,
        ano: ano,
        placa: placa ?? veiculoOriginal.placa,
        odometroInicial: odometroInicial,
        cor: cor,
        combustivel: combustivel.index,
        renavan: renavam ?? veiculoOriginal.renavan,
        chassi: chassi ?? veiculoOriginal.chassi,
        vendido: veiculoOriginal.vendido,
        valorVenda: veiculoOriginal.valorVenda,
        odometroAtual: odometroInicial,
        foto: foto ?? veiculoOriginal.foto,
      );

      final error = await _repository.updateVeiculo(veiculoAtualizado);
      if (error != null) {
        throw Exception(error);
      }

      await _listController.loadVeiculos();
      if (_listController.selectedVeiculo.value?.id == veiculoAtualizado.id) {
        _listController.selectedVeiculo.value = veiculoAtualizado;
      }
      return veiculoAtualizado;
    } catch (e) {
      debugPrint('Erro ao atualizar veículo: $e');
      rethrow;
    }
  }

  /// Remove veículo
  Future<void> removerVeiculo(VeiculoCar veiculo) async {
    try {
      await _listController.removerVeiculo(veiculo);
    } catch (e) {
      debugPrint('Erro ao remover veículo: $e');
      rethrow;
    }
  }

  /// Busca veículo por ID
  Future<VeiculoCar?> buscarVeiculoPorId(String id) async {
    try {
      return _listController.getVeiculoById(id);
    } catch (e) {
      debugPrint('Erro ao buscar veículo por ID: $e');
      return null;
    }
  }

  /// Verifica limite de veículos
  Future<bool> verificarLimiteVeiculos() async {
    try {
      return _listController.veiculos.length < 10;
    } catch (e) {
      debugPrint('Erro ao verificar limite: $e');
      return false;
    }
  }

  /// Carrega lista de veículos
  Future<List<VeiculoCar>> carregarVeiculos() async {
    try {
      await _listController.loadVeiculos();
      return _listController.veiculos;
    } catch (e) {
      debugPrint('Erro ao carregar veículos: $e');
      rethrow;
    }
  }
}
