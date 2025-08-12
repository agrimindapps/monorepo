// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';

// Project imports:
import '../../../../database/20_odometro_model.dart';
import '../../../../database/21_veiculos_model.dart';
import '../../../../repository/odometro_repository.dart';
import '../../../../repository/veiculos_repository.dart';
import '../models/odometro_cadastro_form_model.dart';
import '../models/odometro_constants.dart';

class OdometroCadastroFormController extends GetxController {
  final _formKey = GlobalKey<FormState>();
  final _model = OdometroCadastroFormModel();

  // Repositories
  final _odometroRepository = OdometroRepository();
  final _veiculosRepository = VeiculosRepository();

  // Error handling
  final RxString _error = ''.obs;

  // Current odometer record (for editing)
  OdometroCar? _currentOdometer;

  // Concurrency control for vehicle data loading
  Completer<void>? _vehicleLoadCompleter;
  String? _lastVehicleIdRequested;
  Timer? _vehicleLoadTimeout;

  // Loading states for granular control
  final RxBool _isLoadingVehicle = false.obs;

  // Getters
  GlobalKey<FormState> get formKey => _formKey;
  OdometroCadastroFormModel get model => _model;
  OdometroCar? get currentOdometer => _currentOdometer;

  // Reactive getters for UI binding (only for frequently changing fields)
  RxInt get registrationDate => _model.registrationDateRx;
  RxDouble get odometer => _model.odometerRx;
  RxString get description => _model.descriptionRx;
  RxBool get isLoading => _model.isLoadingRx;
  RxString get error => _error;
  RxBool get isLoadingVehicle => _isLoadingVehicle;

  // Non-reactive getters for static fields
  String get vehicleId => _model.vehicleId;
  VeiculoCar? get vehicle => _model.vehicle;
  String get registrationType => _model.registrationType;

  // Computed properties
  DateTime get registrationDateTime => _model.registrationDateTime;
  bool get hasError => _model.hasError;
  bool get hasVehicle => _model.hasVehicle;
  String get formattedOdometer => _model.formattedOdometer;

  // Initialize form with odometer data
  Future<void> initializeForm(OdometroCar? odometer) async {
    debugPrint('🚗 [INIT] Inicializando formulário do odômetro...');
    debugPrint('🚗 [INIT] Odometer para edição: $odometer');

    _currentOdometer = odometer;

    if (odometer != null) {
      debugPrint(
          '🚗 [INIT] Modo: EDIÇÃO - Inicializando com dados do odômetro');
      // Initialize for editing
      _model.initializeFromOdometer(odometer);
      debugPrint('🚗 [INIT] VehicleId do odômetro: ${odometer.idVeiculo}');
    } else {
      debugPrint('🚗 [INIT] Modo: NOVO - Obtendo veículo selecionado');

      // Initialize for new odometer record
      final selectedVeiculoId =
          await VeiculosRepository().getSelectedVeiculoId();
      debugPrint(
          '🚗 [INIT] VehicleId selecionado do repository: "$selectedVeiculoId"');

      debugPrint(
          '🚗 [INIT] VehicleId final para inicialização: "$selectedVeiculoId"');
      _model.initializeForNew(selectedVeiculoId);
    }

    debugPrint('🚗 [INIT] VehicleId final no modelo: "${_model.vehicleId}"');

    // Load vehicle data
    debugPrint('🚗 [INIT] Iniciando carregamento dos dados do veículo...');
    await _loadVehicleData();
  }

  // Load vehicle data with concurrency control
  Future<void> _loadVehicleData() async {
    final vehicleId = _model.vehicleId;

    debugPrint('🚗 [VEICULO] Iniciando carregamento do veículo...');
    debugPrint('🚗 [VEICULO] Vehicle ID: "$vehicleId"');
    debugPrint('🚗 [VEICULO] Vehicle ID isEmpty: ${vehicleId.isEmpty}');
    debugPrint('🚗 [VEICULO] Vehicle ID length: ${vehicleId.length}');

    if (vehicleId.isEmpty) {
      debugPrint('🚗 [VEICULO] ERRO: Vehicle ID está vazio!');
      _model.setError('ID do veículo não pode estar vazio');
      return;
    }

    // Cancel any pending timeout
    _vehicleLoadTimeout?.cancel();

    // If the same vehicle is already being loaded, wait for it
    if (_lastVehicleIdRequested == vehicleId && _vehicleLoadCompleter != null) {
      debugPrint('🚗 [VEICULO] Aguardando carregamento em andamento...');
      try {
        await _vehicleLoadCompleter!.future;
        return;
      } catch (e) {
        debugPrint('🚗 [VEICULO] Carregamento anterior falhou: $e');
        // If previous request failed, continue with new request
      }
    }

    // Cancel any ongoing request for different vehicle
    if (_lastVehicleIdRequested != vehicleId && _vehicleLoadCompleter != null) {
      debugPrint('🚗 [VEICULO] Cancelando carregamento de veículo diferente');
      _vehicleLoadCompleter!
          .completeError('Request cancelled for different vehicle');
    }

    // Set up new request
    _lastVehicleIdRequested = vehicleId;
    _vehicleLoadCompleter = Completer<void>();
    _isLoadingVehicle.value = true;
    _model.clearError();

    debugPrint('🚗 [VEICULO] Configurando timeout de 30 segundos...');
    // Set timeout for the operation
    _vehicleLoadTimeout = Timer(const Duration(seconds: 30), () {
      if (!_vehicleLoadCompleter!.isCompleted) {
        debugPrint('🚗 [VEICULO] TIMEOUT: Carregamento excedeu 30 segundos');
        _vehicleLoadCompleter!.completeError('Timeout loading vehicle data');
        _isLoadingVehicle.value = false;
        _model.setError('Tempo limite excedido ao carregar dados do veículo');
      }
    });

    try {
      debugPrint(
          '🚗 [VEICULO] Chamando VeiculosRepository().getVeiculoById("$vehicleId")...');
      final veiculoData = await VeiculosRepository().getVeiculoById(vehicleId);

      debugPrint('🚗 [VEICULO] Veículo carregado com sucesso: $veiculoData');

      // Only proceed if this is still the current request
      if (_lastVehicleIdRequested == vehicleId &&
          !_vehicleLoadCompleter!.isCompleted) {
        debugPrint('🚗 [VEICULO] Definindo veículo no modelo...');
        _model.setVehicle(veiculoData);
        _vehicleLoadCompleter!.complete();
        debugPrint('🚗 [VEICULO] Carregamento concluído com sucesso!');
      } else {
        debugPrint(
            '🚗 [VEICULO] Carregamento cancelado - requisição não é mais atual');
      }
    } catch (e) {
      debugPrint('🚗 [VEICULO] ERRO no carregamento: $e');
      debugPrint('🚗 [VEICULO] Tipo do erro: ${e.runtimeType}');

      // Only set error if this is still the current request
      if (_lastVehicleIdRequested == vehicleId &&
          !_vehicleLoadCompleter!.isCompleted) {
        final errorMessage = 'Erro ao carregar dados do veículo: $e';
        debugPrint('🚗 [VEICULO] Definindo erro no modelo: $errorMessage');
        _model.setError(errorMessage);
        _vehicleLoadCompleter!.completeError(e);
      }
    } finally {
      _vehicleLoadTimeout?.cancel();
      if (_lastVehicleIdRequested == vehicleId) {
        _isLoadingVehicle.value = false;
        debugPrint('🚗 [VEICULO] Finalizando carregamento (isLoading = false)');
      }
    }
  }

  // Form field setters
  void setOdometer(double value) => _model.setOdometer(value);
  void setOdometerFromString(String value) =>
      _model.setOdometerFromString(value);
  void setDescription(String value) {
    _model.setDescription(value);
    update(['description_field']);
  }

  void setRegistrationDate(DateTime dateTime) =>
      _model.setRegistrationDateFromDateTime(dateTime);

  // Public method to reload vehicle data
  Future<void> reloadVehicleData() async {
    await _loadVehicleData();
  }

  // Date and time handling
  void setDate(DateTime date) => _model.setDate(date);
  void setTime(int hour, int minute) => _model.setTime(hour, minute);

  // Validation methods
  String? validateOdometer(String? value) => _model.validateOdometer(value);
  String? validateDescription(String? value) =>
      _model.validateDescription(value);

  // Callbacks for UI interactions
  void Function(DateTime)? onDateSelected;
  void Function(TimeOfDay)? onTimeSelected;
  void Function(String, String)? onShowError;

  // Date selection callback
  void selectDate(DateTime date) {
    setDate(date);
    update(['date_field']);
  }

  // Time selection callback
  void selectTime(int hour, int minute) {
    setTime(hour, minute);
    update(['date_field']);
  }

  // Clear odometer value
  void clearOdometer() {
    _model.setOdometer(0.0);
    update(['odometer_field']);
  }

  // Submit form
  Future<bool> submitForm({VoidCallback? onSuccess}) async {
    debugPrint('🔧 [ODOMETRO] Iniciando submitForm...');

    if (!_formKey.currentState!.validate()) {
      debugPrint('🔧 [ODOMETRO] Validação do formulário falhou');
      _model.setIsLoading(false);
      return false;
    }

    // Use centralized validation for comprehensive check
    final validationResult = _model.validateForSubmission();
    debugPrint('🔧 [ODOMETRO] Resultado da validação: $validationResult');

    if (!validationResult['isValid']) {
      final errors = validationResult['errors'] as Map<String, String>;
      final firstError = errors.values.first;
      debugPrint('🔧 [ODOMETRO] Erro de validação: $firstError');
      onShowError?.call(
        OdometroConstants.dialogMessages['erro']!,
        firstError,
      );
      return false;
    }

    if (_model.isLoading) {
      debugPrint('🔧 [ODOMETRO] Já está carregando, cancelando...');
      return false;
    }

    _model.setIsLoading(true);
    _model.clearError();

    debugPrint('🔧 [ODOMETRO] Dados do modelo:');
    debugPrint('  - Veículo ID: ${_model.vehicleId}');
    debugPrint('  - Odômetro: ${_model.odometer}');
    debugPrint('  - Data: ${_model.registrationDate}');
    debugPrint('  - Descrição: ${_model.description}');
    debugPrint('  - Tipo Registro: ${_model.registrationType}');
    debugPrint('  - É edição: ${_currentOdometer != null}');

    try {
      _formKey.currentState!.save();

      // Validate odometer value with vehicle
      debugPrint('🔧 [ODOMETRO] Validando valor do odômetro com veículo...');
      final isValid = await validarValorOdometroComVeiculo(
        _model.odometer,
        _model.vehicleId,
      );

      if (!isValid) {
        debugPrint(
            '🔧 [ODOMETRO] Validação do odômetro falhou: ${_error.value}');
        _model.setIsLoading(false);
        _model.setError(_error.value);
        return false;
      }

      debugPrint('🔧 [ODOMETRO] Validação do odômetro passou, prosseguindo...');

      bool success;
      if (_currentOdometer != null) {
        debugPrint('🔧 [ODOMETRO] Atualizando odômetro existente...');
        success = await _updateOdometer();
      } else {
        debugPrint('🔧 [ODOMETRO] Criando novo odômetro...');
        success = await _createOdometer();
      }

      debugPrint('🔧 [ODOMETRO] Resultado da operação: $success');

      if (success) {
        debugPrint('🔧 [ODOMETRO] Sucesso! Chamando onSuccess...');
        _model.setIsLoading(false);
        onSuccess?.call();
        return true;
      } else {
        debugPrint('🔧 [ODOMETRO] Falha na operação: ${_error.value}');
        debugPrint(
            '🔧 [ODOMETRO] isLoading do controller: ${_model.isLoading}');
        _model.setError(_error.value.isEmpty
            ? 'Erro desconhecido na gravação'
            : _error.value);
        return false;
      }
    } catch (e) {
      debugPrint('🔧 [ODOMETRO] Exceção capturada: $e');
      _model.setError(e.toString());
      return false;
    } finally {
      _model.setIsLoading(false);
    }
  }

  // Create new odometer record
  Future<bool> _createOdometer() async {
    debugPrint('🔧 [ODOMETRO] Criando novo odômetro com dados:');

    final id = const Uuid().v4();
    final createdAt = DateTime.now().millisecondsSinceEpoch;

    debugPrint('  - ID: $id');
    debugPrint('  - CreatedAt: $createdAt');
    debugPrint('  - VeiculoID: ${_model.vehicleId}');
    debugPrint('  - Data: ${_model.registrationDate}');
    debugPrint('  - Odometro: ${_model.odometer}');
    debugPrint('  - Descricao: ${_model.description}');
    debugPrint('  - TipoRegistro: ${_model.registrationType}');

    final newOdometro = criarOdometro(
      id: id,
      createdAt: createdAt,
      idVeiculo: _model.vehicleId,
      data: _model.registrationDate,
      odometro: _model.odometer,
      descricao: _model.description,
      tipoRegistro: _model.registrationType,
    );

    debugPrint('🔧 [ODOMETRO] Odômetro criado: $newOdometro');
    debugPrint('🔧 [ODOMETRO] Chamando adicionarOdometro...');

    final result = await adicionarOdometro(newOdometro);
    debugPrint('🔧 [ODOMETRO] Resultado adicionarOdometro: $result');

    return result;
  }

  // Update existing odometer record
  Future<bool> _updateOdometer() async {
    debugPrint('🔧 [ODOMETRO] Atualizando odômetro existente com dados:');
    debugPrint('  - ID: ${_currentOdometer!.id}');
    debugPrint('  - ID: ${_currentOdometer!.id}');
    debugPrint('  - CreatedAt: ${_currentOdometer!.createdAt}');
    debugPrint('  - VeiculoID: ${_model.vehicleId}');
    debugPrint('  - Data: ${_model.registrationDate}');
    debugPrint('  - Odometro: ${_model.odometer}');
    debugPrint('  - Descricao: ${_model.description}');
    debugPrint(
        '  - TipoRegistro: ${_currentOdometer!.tipoRegistro ?? _model.registrationType}');

    final updatedOdometro = criarOdometro(
      id: _currentOdometer!.id,
      createdAt: _currentOdometer!.createdAt,
      idVeiculo: _model.vehicleId,
      data: _model.registrationDate,
      odometro: _model.odometer,
      descricao: _model.description,
      tipoRegistro: _currentOdometer!.tipoRegistro ?? _model.registrationType,
    );

    debugPrint('🔧 [ODOMETRO] Odômetro atualizado: $updatedOdometro');
    debugPrint('🔧 [ODOMETRO] Chamando atualizarOdometro...');

    final result = await atualizarOdometro(updatedOdometro);
    debugPrint('🔧 [ODOMETRO] Resultado atualizarOdometro: $result');

    return result;
  }

  // Show error message callback
  void showErrorMessage(String? errorMessage) {
    final message =
        errorMessage ?? OdometroConstants.validationMessages['erroGenerico']!;
    onShowError?.call(
      OdometroConstants.dialogMessages['erro']!,
      message,
    );
  }

  // Clear error
  void clearError() {
    _model.clearError();
    _error.value = '';
  }

  // ===================================
  // MIGRATED METHODS FROM EXTERNAL CONTROLLER
  // ===================================

  /// Adiciona novo registro de odômetro
  Future<bool> adicionarOdometro(OdometroCar odometro) async {
    debugPrint('🔧 [CONTROLLER] adicionarOdometro - INÍCIO');
    debugPrint('🔧 [CONTROLLER] Odômetro recebido para adicionar:');
    debugPrint('  - toMap(): ${odometro.toMap()}');

    _model.setIsLoading(true);
    _error.value = '';

    try {
      debugPrint('🔧 [CONTROLLER] Chamando _odometroRepository.addOdometro...');
      final result = await _odometroRepository.addOdometro(odometro);
      debugPrint('🔧 [CONTROLLER] Resultado do repository: $result');

      if (result) {
        debugPrint(
            '🔧 [CONTROLLER] Adição bem-sucedida, verificando atualização do veículo...');
        if (odometro.odometro > 0) {
          debugPrint(
              '🔧 [CONTROLLER] Atualizando odômetro atual do veículo...');
          final updateResult = await _veiculosRepository.updateOdometroAtual(
              odometro.idVeiculo, odometro.odometro);
          debugPrint(
              '🔧 [CONTROLLER] Resultado da atualização do veículo: $updateResult');
        } else {
          debugPrint('🔧 [CONTROLLER] Odômetro <= 0, não atualizando veículo');
        }
      } else {
        debugPrint('🔧 [CONTROLLER] FALHA na adição do odômetro');
      }

      debugPrint(
          '🔧 [CONTROLLER] adicionarOdometro - FIM com resultado: $result');
      return result;
    } catch (e, stackTrace) {
      _error.value = 'Erro ao adicionar registro de odômetro: $e';
      debugPrint('🔧 [CONTROLLER] EXCEÇÃO em adicionarOdometro: $e');
      debugPrint('🔧 [CONTROLLER] Stack trace: $stackTrace');
      return false;
    } finally {
      _model.setIsLoading(false);
      debugPrint('🔧 [CONTROLLER] Loading definido como false');
    }
  }

  /// Atualiza registro de odômetro existente
  Future<bool> atualizarOdometro(OdometroCar odometro) async {
    _model.setIsLoading(true);
    _error.value = '';

    try {
      final result = await _odometroRepository.updateOdometro(odometro);
      if (result) {
        if (odometro.odometro > 0) {
          await _veiculosRepository.updateOdometroAtual(
              odometro.idVeiculo, odometro.odometro);
        }
      }
      return result;
    } catch (e) {
      _error.value = 'Erro ao atualizar registro de odômetro: $e';
      debugPrint('Erro ao atualizar registro de odômetro: $e');
      return false;
    } finally {
      _model.setIsLoading(false);
    }
  }

  /// Valida valor do odômetro com os dados do veículo
  Future<bool> validarValorOdometroComVeiculo(
      double valor, String idVeiculo) async {
    try {
      if (valor < 0) {
        _error.value = 'O valor do odômetro não pode ser negativo';
        return false;
      }

      final veiculo = await _veiculosRepository.getVeiculoById(idVeiculo);
      if (veiculo == null) {
        _error.value = 'Veículo não encontrado';
        return false;
      }

      if (valor < veiculo.odometroInicial) {
        _error.value =
            'O valor do odômetro não pode ser menor que a quilometragem inicial do veículo (${veiculo.odometroInicial} km)';
        return false;
      }

      return true;
    } catch (e) {
      _error.value = 'Erro ao validar valor do odômetro: $e';
      return false;
    }
  }

  /// Cria novo objeto OdometroCar
  OdometroCar criarOdometro({
    required String id,
    required int createdAt,
    required String idVeiculo,
    required int data,
    required double odometro,
    required String descricao,
    String? tipoRegistro,
  }) {
    return OdometroCar(
      id: id,
      createdAt: createdAt,
      updatedAt: DateTime.now().millisecondsSinceEpoch,
      idVeiculo: idVeiculo,
      data: data,
      odometro: odometro,
      descricao: descricao,
      tipoRegistro: tipoRegistro ?? 'Outros',
    );
  }

  /// Valida valor simples do odômetro
  bool validarValorOdometro(double valor, double valorAtual) {
    return valor >= 0 && valor >= valorAtual;
  }

  /// Valida data de registro
  bool validarDataRegistro(int dataRegistro) {
    final agora = DateTime.now();
    final dataRegistroDate = DateTime.fromMillisecondsSinceEpoch(dataRegistro);
    if (dataRegistroDate.isAfter(agora)) {
      _error.value = 'A data de registro não pode ser futura';
      return false;
    }
    return true;
  }

  /// Lista de tipos de registro disponíveis
  List<String> get tiposRegistroDisponiveis => [
        'Viagem',
        'Passeio',
        'Manutenção',
        'Abastecimento',
        'Outros',
      ];

  // Reset form
  void resetForm() {
    _model.resetForm();
    _currentOdometer = null;
    _formKey.currentState?.reset();
  }

  /// Limpeza adequada do controller
  ///
  /// Agora o cleanup é gerenciado apenas aqui, evitando duplicação
  /// com o widget e prevenindo vazamentos de memória
  @override
  void onClose() {
    // Cancel any pending vehicle loading operations
    _vehicleLoadTimeout?.cancel();
    if (_vehicleLoadCompleter != null && !_vehicleLoadCompleter!.isCompleted) {
      _vehicleLoadCompleter!.completeError('Controller disposed');
    }

    // Limpa o formulário e dados
    resetForm();

    // Chama o cleanup do GetxController
    super.onClose();
  }
}
