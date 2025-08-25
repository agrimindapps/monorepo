// Flutter imports:
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Project imports:
import '../../core/services/firebase_firestore_service.dart';
import '../database/21_veiculos_model.dart';
import '../database/enums.dart';
import '../errors/gasometer_exceptions.dart';
import '../pages/cadastros/veiculos_page/services/box_manager.dart';
import '../services/error_handler.dart';
import '../types/result.dart';

// Local imports

/// TODO (prioridade: MÉDIA): Extrair funções auxiliares (ex: checkBoxForRecords) para helpers reutilizáveis.
/// TODO (prioridade: MÉDIA): Centralizar mensagens de erro e textos em arquivo de constantes ou localization.
/// TODO (prioridade: MÉDIA): Adicionar tratamento para possíveis erros de null em operações com Hive e SharedPreferences.
/// TODO (prioridade: MÉDIA): Adicionar testes unitários para métodos de CRUD e verificação de lançamentos.
/// FIXME (prioridade: MÉDIA): O método _getById lança exceção se não encontrar veículo, mas retorna null no catch; padronizar comportamento.
/// FIXME (prioridade: MÉDIA): O método _delete apenas marca como inativo, considerar remoção física ou opção de restauração.
/// OPTIMIZE (prioridade: MÉDIA): Evitar abrir e fechar o box Hive em cada operação, usar cache ou gerenciar ciclo de vida do box.
/// NOTE (prioridade: BAIXA): O padrão singleton pode dificultar testes, considerar uso de injeção de dependência.
/// STYLE (prioridade: BAIXA): Padronizar espaçamentos e comentários para melhor legibilidade.
/// DOC (prioridade: BAIXA): Adicionar comentários explicativos nos métodos principais para facilitar manutenção.
/// TODO (prioridade: MÉDIA): Adicionar feedback visual para operações longas (ex: sincronização com Firestore).
/// TODO (prioridade: BAIXA): Adicionar logs mais detalhados para facilitar debug em produção.


class VeiculosRepository {
  // MARK: - Constants
  static const String _boxName = 'box_car_veiculos';
  static const String collectionName = 'box_car_veiculos';
  static const String _selectedVeiculoKey = 'selected_veiculo_id';

  // MARK: - Dependencies
  final FirestoreService _firestore;
  final Future<SharedPreferences> _prefs;

  // MARK: - Properties
  String selectedVeiculoId = '';

  // MARK: - Constructor com injeção de dependência
  VeiculosRepository({
    FirestoreService? firestoreService,
    Future<SharedPreferences>? sharedPreferences,
  })  : _firestore = firestoreService ?? FirestoreService(),
        _prefs = sharedPreferences ?? SharedPreferences.getInstance();

  static Future<void> initialize() => _initialize();
  Future<String> getSelectedVeiculoId() => _getSelectedId();
  Future<void> setSelectedVeiculoId(String id) => _setSelectedId(id);
  Future<List<VeiculoCar>> getVeiculos() => _getAll();
  Future<VeiculoCar?> getVeiculoById(String id) => _getByIdLegacy(id);
  Future<VeiculoResult<VeiculoCar>> getVeiculoByIdSafe(String id) => _getById(id);
  Future<String?> addVeiculo(VeiculoCar veiculo) => _add(veiculo);
  Future<String?> updateVeiculo(VeiculoCar veiculo) => _update(veiculo);
  Future<bool> deleteVeiculo(VeiculoCar veiculo) => _delete(veiculo);
  Future<bool> updateOdometroAtual(String veiculoId, double novoOdometro) =>
      _updateOdometer(veiculoId, novoOdometro);
  Future<bool> veiculoPossuiLancamentos(String veiculoId) =>
      _verificarPossuiLancamentos(veiculoId);

  // MARK: - Initialization
  static Future<void> _initialize() async {
    try {
      if (!Hive.isAdapterRegistered(21)) {
        Hive.registerAdapter(VeiculoCarAdapter());
      }
    } catch (e) {
      debugPrint('Error initializing VeiculosRepository: $e');
      rethrow;
    }
  }

  // MARK: - Box Management (using BoxManager)
  Future<Box<VeiculoCar>> _ensureBoxOpen() async {
    return await BoxManager.instance.getBox<VeiculoCar>(_boxName);
  }

  // Removido _closeBox() - boxes devem permanecer abertos durante o ciclo de vida da app

  // MARK: - Selected Vehicle Management
  Future<String> _getSelectedId() async {
    try {
      final prefs = await _prefs;
      selectedVeiculoId = prefs.getString(_selectedVeiculoKey) ?? '';
      debugPrint(
          'VeiculosRepository: _getSelectedId returning: $selectedVeiculoId');
    } catch (e) {
      debugPrint('Error getting selected veiculo: $e');
    }
    return selectedVeiculoId;
  }

  Future<void> _setSelectedId(String id) async {
    try {
      final prefs = await _prefs;
      selectedVeiculoId = id;
      await prefs.setString(_selectedVeiculoKey, id);
    } catch (e) {
      debugPrint('Error saving selected veiculo: $e');
    }
  }

  // MARK: - CRUD Operations
  Future<List<VeiculoCar>> _getAll() async {
    List<VeiculoCar> veiculos = [];
    try {
      debugPrint('VeiculosRepository: Abrindo box de veículos...');
      final box = await _ensureBoxOpen();
      debugPrint('VeiculosRepository: Box contém ${box.values.length} itens');

      final allVeiculos = box.values.toList();
      final deletedCount = allVeiculos.where((item) => item.isDeleted).length;
      debugPrint(
          'VeiculosRepository: $deletedCount veículos deletados serão filtrados');

      veiculos = box.values
          .where((item) => !item.isDeleted) // Filtrar veículos não deletados
          .map((item) => item)
          .toList();
      debugPrint(
          'VeiculosRepository: Retornando ${veiculos.length} veículos não deletados');
    } catch (e) {
      debugPrint('Error getting veiculos: $e');
    }
    return veiculos;
  }

  Future<VeiculoResult<VeiculoCar>> _getById(String id) async {
    try {
      if (id.isEmpty) {
        return VeiculoResult.failure(VeiculoValidationException('id', 'ID não pode ser vazio'));
      }

      final box = await _ensureBoxOpen();
      final veiculo = box.values
          .cast<VeiculoCar?>()
          .firstWhere(
            (veiculo) => veiculo?.id == id,
            orElse: () => null,
          );

      if (veiculo == null) {
        return VeiculoResult.failure(VeiculoNotFoundException(id));
      }

      return VeiculoResult.success(veiculo);
    } catch (e) {
      final wrappedException = wrapException(
        e is Exception ? e : Exception(e.toString()),
        operation: 'get_veiculo_by_id',
        context: {'veiculoId': id},
      );
      
      GasometerErrorHandler.instance.logError(
        wrappedException,
        operation: 'get_veiculo_by_id',
        additionalContext: {'veiculoId': id},
      );

      final veiculoException = wrappedException is VeiculoException 
        ? wrappedException 
        : VeiculoValidationException('lookup', 'Erro ao buscar veículo');
      
      return VeiculoResult.failure(veiculoException);
    }
  }

  // Método de compatibilidade - será removido gradualmente
  Future<VeiculoCar?> _getByIdLegacy(String id) async {
    final result = await _getById(id);
    return result.dataOrNull;
  }

  // MARK: - Data Modification Operations
  Future<String?> _add(VeiculoCar veiculo) async {
    try {
      // Basic security validation before persistence
      final validationError = _validateVehicleData(veiculo);
      if (validationError != null) {
        debugPrint('Invalid vehicle data rejected: $validationError');
        return validationError;
      }

      final box = await _ensureBoxOpen();
      final key = await box.add(veiculo);

      await _firestore.createRecord(
        collection: collectionName,
        data: veiculo.toMap(),
      );

      // Marca como sincronizado
      veiculo.markAsSynced();
      await box.put(key, veiculo);

      return null; // Success
    } catch (e) {
      final errorMessage = 'Erro ao salvar veículo: $e';
      debugPrint('Error adding Veiculo: $e');
      return errorMessage;
    }
  }

  Future<String?> _update(VeiculoCar veiculo) async {
    try {
      // Basic security validation before persistence
      final validationError = _validateVehicleData(veiculo);
      if (validationError != null) {
        debugPrint(
            'Invalid vehicle data rejected for update: $validationError');
        return validationError;
      }

      final box = await _ensureBoxOpen();
      final index = box.values.toList().indexWhere(
            (item) => item.id == veiculo.id,
          );

      if (index != -1) {
        veiculo.updatedAt = DateTime.now().millisecondsSinceEpoch;

        await box.putAt(index, veiculo);
        await _firestore.updateRecord(
          collection: collectionName,
          recordId: veiculo.id,
          data: veiculo.toMap(),
        );

        // Marca como sincronizado
        veiculo.markAsSynced();
        return null; // Success
      }
      return 'Veículo não encontrado';
    } catch (e) {
      final errorMessage = 'Erro ao atualizar veículo: $e';
      debugPrint('Error updating Veiculo: $e');
      return errorMessage;
    }
  }

  Future<bool> _delete(VeiculoCar veiculo) async {
    try {
      final box = await _ensureBoxOpen();
      final index = box.values.toList().indexWhere(
            (item) => item.id == veiculo.id,
          );

      if (index != -1) {
        // Marca o veículo como deletado
        veiculo.markAsDeleted();

        await box.putAt(index, veiculo);
        await _firestore.updateRecord(
          collection: collectionName,
          recordId: veiculo.id,
          data: veiculo.toMap(),
        );

        // Marca como sincronizado
        veiculo.markAsSynced();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error deleting Veiculo: $e');
      return false;
    }
  }

  // MARK: - Specialized Operations
  Future<bool> _updateOdometer(String veiculoId, double novoOdometro) async {
    try {
      final box = await _ensureBoxOpen();
      final veiculo = box.values.firstWhere(
        (v) => v.id == veiculoId,
        orElse: () => throw Exception('Vehicle not found'),
      );

      veiculo.odometroAtual = novoOdometro;
      final index = box.values.toList().indexWhere(
            (item) => item.id == veiculoId,
          );

      if (index != -1) {
        await box.putAt(index, veiculo);
        await _firestore.updateRecord(
          collection: collectionName,
          recordId: veiculo.id,
          data: veiculo.toMap(),
        );

        // Marca como sincronizado
        veiculo.markAsSynced();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error updating odometro atual: $e');
      return false;
    }
  }

  // MARK: - Verificação de lançamentos
  Future<bool> _verificarPossuiLancamentos(String veiculoId) async {
    if (veiculoId.isEmpty) return false;

    // Lista de boxes para verificar
    final boxesToCheck = [
      {'name': 'box_car_odometros', 'idField': 'idVeiculo'},
      {'name': 'box_car_abastecimentos', 'idField': 'veiculoId'},
      {'name': 'box_car_manutencoes', 'idField': 'veiculoId'},
      {'name': 'box_car_despesas', 'idField': 'veiculoId'},
    ];

    // Helper function to check a box for records
    Future<bool> checkBoxForRecords(String boxName, String idFieldName) async {
      Box? box;
      try {
        if (Hive.isBoxOpen(boxName)) {
          box = Hive.box(boxName);
        } else {
          box = await Hive.openBox(boxName);
        }

        // Check for records based on box type
        for (final item in box.values) {
          if (!item.isDeleted) {
            String? itemVeiculoId;

            // Get vehicle ID based on object type and field name
            switch (idFieldName) {
              case 'idVeiculo':
                // For odometer records
                if (item.idVeiculo != null) {
                  itemVeiculoId = item.idVeiculo;
                }
                break;
              case 'veiculoId':
                // For fuel records, maintenance, expenses
                if (item.veiculoId != null) {
                  itemVeiculoId = item.veiculoId;
                }
                break;
            }

            if (itemVeiculoId == veiculoId) {
              return true;
            }
          }
        }
        return false;
      } catch (e) {
        debugPrint('Erro ao verificar lançamentos em $boxName: $e');
        return false;
      } finally {
        if (box != null && box.isOpen) {
          await box.close();
        }
      }
    }

    // Check each box and return early if any has records
    for (final box in boxesToCheck) {
      if (await checkBoxForRecords(box['name']!, box['idField']!)) {
        return true;
      }
    }

    return false;
  }

  // MARK: - Security Validation
  /// Basic validation to prevent obviously invalid or malicious data
  String? _validateVehicleData(VeiculoCar veiculo) {
    // Check for required fields
    if (veiculo.marca.trim().isEmpty) {
      return 'Marca é obrigatória';
    }
    if (veiculo.modelo.trim().isEmpty) {
      return 'Modelo é obrigatório';
    }
    if (veiculo.placa.trim().isEmpty) {
      return 'Placa é obrigatória';
    }
    if (veiculo.id.trim().isEmpty) {
      return 'ID é obrigatório';
    }

    // Check for suspicious injection patterns
    if (_containsSuspiciousContent(veiculo.marca)) {
      return 'Marca contém caracteres não permitidos';
    }
    if (_containsSuspiciousContent(veiculo.modelo)) {
      return 'Modelo contém caracteres não permitidos';
    }
    if (_containsSuspiciousContent(veiculo.cor)) {
      return 'Cor contém caracteres não permitidos';
    }
    if (_containsSuspiciousContent(veiculo.placa)) {
      return 'Placa contém caracteres não permitidos';
    }

    // Check for reasonable data ranges
    if (veiculo.ano < 1900 || veiculo.ano > DateTime.now().year + 2) {
      return 'Ano deve estar entre 1900 e ${DateTime.now().year + 2}';
    }

    if (veiculo.odometroInicial < 0) {
      return 'Odômetro inicial não pode ser negativo';
    }
    if (veiculo.odometroAtual < 0) {
      return 'Odômetro atual não pode ser negativo';
    }

    if (veiculo.combustivel < 0 ||
        veiculo.combustivel >= TipoCombustivel.values.length) {
      return 'Tipo de combustível inválido';
    }

    // Check for excessively long strings (potential buffer overflow)
    if (veiculo.marca.length > 100) {
      return 'Marca deve ter no máximo 100 caracteres';
    }
    if (veiculo.modelo.length > 100) {
      return 'Modelo deve ter no máximo 100 caracteres';
    }
    if (veiculo.cor.length > 50) {
      return 'Cor deve ter no máximo 50 caracteres';
    }
    if (veiculo.placa.length > 15) {
      return 'Placa deve ter no máximo 15 caracteres';
    }

    return null; // Valid data
  }

  /// Check for suspicious content that might indicate injection attempts
  bool _containsSuspiciousContent(String input) {
    if (input.isEmpty) return false;

    final suspiciousPatterns = [
      '<script',
      'javascript:',
      'SELECT ',
      'DROP ',
      'INSERT ',
      'DELETE ',
      'UPDATE ',
      'exec(',
      'eval(',
      '\${',
      '../',
      '/etc/',
      '/proc/',
    ];

    final lowerInput = input.toLowerCase();
    return suspiciousPatterns
        .any((pattern) => lowerInput.contains(pattern.toLowerCase()));
  }
}
