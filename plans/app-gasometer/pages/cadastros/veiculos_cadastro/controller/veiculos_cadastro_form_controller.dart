// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:get/get.dart';

// Project imports:
import '../../../../database/21_veiculos_model.dart';
import '../../../../database/enums.dart';
import '../../../../repository/veiculos_repository.dart';
import '../mixins/controller_lifecycle_mixin.dart';
import '../models/veiculos_cadastro_form_model.dart';
import '../models/veiculos_constants.dart';
import '../services/veiculo_formatter_service.dart';
import '../services/veiculo_persistence_service.dart';
import '../services/veiculo_validation_service.dart';

/// Controller refatorado com gestão consistente de lifecycle
///
/// Implementa:
/// - Padrão consistente de dependency injection
/// - Cleanup automático de recursos
/// - Sincronização robusta de estados
/// - Prevenção de vazamentos de memória
class VeiculosCadastroFormController extends GetxController
    with ControllerLifecycleMixin {
  // Dependencies - Services que fazem o trabalho pesado
  late final VeiculoPersistenceService _persistenceService;

  // UI State
  final _formKey = GlobalKey<FormState>();
  final _model = VeiculosCadastroFormModel();
  final Rx<VeiculoCar?> _currentVeiculo = Rx<VeiculoCar?>(null);

  // Controllers for text fields
  late final TextEditingController marcaController;
  late final TextEditingController modeloController;
  late final TextEditingController corController;
  late final TextEditingController placaController;
  late final TextEditingController renavamController;
  late final TextEditingController chassiController;

  // Getters for UI binding
  GlobalKey<FormState> get formKey => _formKey;
  VeiculosCadastroFormModel get model => _model;
  VeiculoCar? get currentVeiculo => _currentVeiculo.value;

  // Reactive getters - delegated to model
  RxString get marca => _model.marcaRx;
  RxString get modelo => _model.modeloRx;
  RxInt get ano => _model.anoRx;
  RxString get placa => _model.placaRx;
  RxDouble get odometroInicial => _model.odometroInicialRx;
  RxString get cor => _model.corRx;
  RxInt get combustivel => _model.combustivelRx;
  RxString get renavam => _model.renavamRx;
  RxString get chassi => _model.chassiRx;
  Rx<TipoCombustivel> get tipoCombustivel => _model.tipoCombustivelRx;
  RxString get unidade => _model.unidadeRx;
  RxBool get isLoading => _model.isLoadingRx;
  RxBool get possuiLancamentos => _model.possuiLancamentosRx;
  RxString get foto => _model.fotoRx;

  @override
  void onInit() {
    super.onInit();
    marcaController = TextEditingController();
    modeloController = TextEditingController();
    corController = TextEditingController();
    placaController = TextEditingController();
    renavamController = TextEditingController();
    chassiController = TextEditingController();
    _initializeServices();
    _setupReactiveWorkers();
  }

  @override
  void onClose() {
    marcaController.dispose();
    modeloController.dispose();
    corController.dispose();
    placaController.dispose();
    renavamController.dispose();
    chassiController.dispose();
    super.onClose();
  }

  /// Inicializa services com dependency injection segura
  void _initializeServices() {
    try {
      // Usa dependency injection segura do mixin
      _persistenceService = safeFindDependency<VeiculoPersistenceService>(
        errorMessage:
            'VeiculoPersistenceService não encontrado. Verifique o VeiculosModuleBinding.',
      );
    } catch (e) {
      // Fallback para instanciação direta se binding não estiver configurado
      _persistenceService = VeiculoPersistenceService(
        repository: Get.find<VeiculosRepository>(),
      );
    }
  }

  /// Configura workers reativos com registro automático para cleanup
  void _setupReactiveWorkers() {
    // Worker para debounce de updates da UI
    registerDebouncedWorker(
      _model.isLoadingRx,
      (isLoading) {
        if (isLoading) {
          safeUpdate(['loading_state']);
        }
      },
      time: const Duration(milliseconds: 100),
    );

    // Worker para mudanças no veículo atual
    registerEverWorker(
      _currentVeiculo,
      (veiculo) {
        if (veiculo != null) {
          debouncedUpdate(['vehicle_info']);
        }
      },
    );
  }

  /// Inicializa formulário com dados do veículo
  Future<void> initializeForm(VeiculoCar? veiculo) async {
    // Reset form first to clear any previous state
    _model.resetForm();
    _currentVeiculo.value = null;

    // Clear text controllers first
    marcaController.clear();
    modeloController.clear();
    corController.clear();
    placaController.clear();
    renavamController.clear();
    chassiController.clear();

    if (veiculo != null) {
      _currentVeiculo.value = veiculo;
      _model.initializeFromVeiculo(veiculo);
      await _checkExistingRecords();

      // Update text controllers with vehicle data
      marcaController.text = _model.marca;
      modeloController.text = _model.modelo;
      corController.text = _model.cor;
      placaController.text = _model.placa;
      renavamController.text = _model.renavam;
      chassiController.text = _model.chassi;
    }

    _updateAllFields();
  }

  /// Verifica se veículo possui lançamentos
  Future<void> _checkExistingRecords() async {
    if (_currentVeiculo.value?.id != null) {
      final temLancamentos = await _persistenceService
          .verificarLancamentos(_currentVeiculo.value!.id);
      _model.setPossuiLancamentos(temLancamentos);
    }
  }

  /// Atualiza todos os campos na UI com debounce automático
  void _updateAllFields() {
    final fieldIds = [
      VeiculosConstants.camposGetBuilder['marca']!,
      VeiculosConstants.camposGetBuilder['modelo']!,
      VeiculosConstants.camposGetBuilder['ano']!,
      VeiculosConstants.camposGetBuilder['cor']!,
      VeiculosConstants.camposGetBuilder['placa']!,
      VeiculosConstants.camposGetBuilder['chassi']!,
      VeiculosConstants.camposGetBuilder['renavam']!,
    ];

    debouncedUpdate(fieldIds, const Duration(milliseconds: 50));
  }

  // ===================================
  // FIELD SETTERS - UI State Management
  // ===================================

  void setMarca(String value) {
    final formattedValue = VeiculoFormatterService.formatTextInput(value);
    _model.setMarca(formattedValue);
    safeUpdate([VeiculosConstants.camposGetBuilder['marca']!]);
  }

  void setModelo(String value) {
    final formattedValue = VeiculoFormatterService.formatTextInput(value);
    _model.setModelo(formattedValue);
    safeUpdate([VeiculosConstants.camposGetBuilder['modelo']!]);
  }

  void setAno(int value) {
    _model.setAno(value);
    safeUpdate([VeiculosConstants.camposGetBuilder['ano']!]);
  }

  void setPlaca(String value) {
    final formattedValue = VeiculoFormatterService.formatPlacaInput(value);
    _model.setPlaca(formattedValue);
    safeUpdate([VeiculosConstants.camposGetBuilder['placa']!]);
  }

  void setOdometroInicial(double value) => _model.setOdometroInicial(value);

  void setCor(String value) {
    final formattedValue = VeiculoFormatterService.formatTextInput(value);
    _model.setCor(formattedValue);
    safeUpdate([VeiculosConstants.camposGetBuilder['cor']!]);
  }

  void setRenavam(String value) {
    final formattedValue = VeiculoFormatterService.formatRenavamInput(value);
    _model.setRenavam(formattedValue);
    safeUpdate([VeiculosConstants.camposGetBuilder['renavam']!]);
  }

  void setChassi(String value) {
    final formattedValue = VeiculoFormatterService.formatChassisInput(value);
    _model.setChassi(formattedValue);
    safeUpdate([VeiculosConstants.camposGetBuilder['chassi']!]);
  }

  void setTipoCombustivel(TipoCombustivel value) {
    _model.setTipoCombustivel(value);
  }

  void setFoto(String? value) {
    _model.setFoto(value);
  }

  // ===================================
  // VALIDATION METHODS - Delegated to Service
  // ===================================

  String? validateMarca(String? value) =>
      VeiculoValidationService.validateMarca(value);

  String? validateModelo(String? value) =>
      VeiculoValidationService.validateModelo(value);

  String? validateAno(int? value) =>
      VeiculoValidationService.validateAno(value);

  String? validateCor(String? value) =>
      VeiculoValidationService.validateCor(value);

  String? validatePlaca(String? value) =>
      VeiculoValidationService.validatePlaca(value);

  String? validateChassi(String? value) =>
      VeiculoValidationService.validateChassi(value);

  String? validateRenavam(String? value) =>
      VeiculoValidationService.validateRenavam(value);

  String? validateOdometro(double? value) =>
      VeiculoValidationService.validateOdometro(
          value, _currentVeiculo.value?.odometroAtual);

  String? validateCombustivel(TipoCombustivel? value) =>
      VeiculoValidationService.validateCombustivel(value);

  // ===================================
  // UI HELPER METHODS - Delegated to Service
  // ===================================

  List<int> getYearOptions() => VeiculoFormatterService.getYearOptions();

  IconData getFuelIcon(TipoCombustivel tipo) =>
      VeiculoFormatterService.getFuelIcon(tipo);

  // ===================================
  // FORM SUBMISSION - Coordinated with Services
  // ===================================

  /// Submete formulário usando os services
  Future<bool> submitForm() async {
    if (!_formKey.currentState!.validate()) {
      _model.setIsLoading(false);
      return false;
    }

    _model.setIsLoading(true);

    try {
      _formKey.currentState!.save();

      if (_currentVeiculo.value != null) {
        // Update existing vehicle
        await _persistenceService.atualizarVeiculo(
          veiculoOriginal: _currentVeiculo.value!,
          marca: _model.marca,
          modelo: _model.modelo,
          ano: _model.ano,
          placa: _model.placa.isEmpty ? null : _model.placa,
          odometroInicial: _model.odometroInicial,
          cor: _model.cor,
          combustivel: _model.tipoCombustivel,
          renavam: _model.renavam.isEmpty ? null : _model.renavam,
          chassi: _model.chassi.isEmpty ? null : _model.chassi,
          foto: _model.foto.isEmpty ? null : _model.foto,
        );
      } else {
        // Create new vehicle
        await _persistenceService.criarVeiculo(
          marca: _model.marca,
          modelo: _model.modelo,
          ano: _model.ano,
          placa: _model.placa.isEmpty ? null : _model.placa,
          odometroInicial: _model.odometroInicial,
          cor: _model.cor,
          combustivel: _model.tipoCombustivel,
          renavam: _model.renavam.isEmpty ? null : _model.renavam,
          chassi: _model.chassi.isEmpty ? null : _model.chassi,
          foto: _model.foto.isEmpty ? null : _model.foto,
        );
      }

      _model.setIsLoading(false);
      return true;
    } catch (e) {
      _model.setIsLoading(false);
      return false;
    }
  }

  /// Reset do formulário
  void resetForm() {
    _model.resetForm();
    _currentVeiculo.value = null;
    _formKey.currentState?.reset();
    _updateAllFields();
  }
}
