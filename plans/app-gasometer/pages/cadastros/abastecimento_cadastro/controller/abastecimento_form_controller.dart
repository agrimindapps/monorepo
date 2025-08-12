// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';

// Project imports:
import '../../../../database/21_veiculos_model.dart';
import '../../../../database/23_abastecimento_model.dart';
import '../../../../database/enums.dart';
import '../../../../repository/abastecimentos_repository.dart';
import '../../../../repository/veiculos_repository.dart';
import '../models/abastecimento_form_model.dart';
import '../services/formatting_service.dart';
import '../services/validation_service.dart';

class AbastecimentoFormController extends GetxController {
  // Repositories
  final _abastecimentosRepository = AbastecimentosRepository();
  final _veiculosRepository = VeiculosRepository();

  final _formKey = GlobalKey<FormState>();
  final _validationService = ValidationService();
  final _formattingService = FormattingService();

  final Rx<AbastecimentoFormModel> _formModel =
      AbastecimentoFormModel.initial('').obs;
  final RxBool _isInitialized = false.obs;
  final RxBool _isUpdating = false.obs;

  // Debounce timers para evitar múltiplas atualizações
  Timer? _litrosDebounceTimer;
  Timer? _valorPorLitroDebounceTimer;
  Timer? _odometroDebounceTimer;

  // Controllers para campos de texto para controle de estado
  final TextEditingController litrosController = TextEditingController();
  final TextEditingController valorPorLitroController = TextEditingController();
  final TextEditingController odometroController = TextEditingController();
  final TextEditingController observacaoController = TextEditingController();

  // ValueNotifiers para campos calculados (otimização de performance)
  final ValueNotifier<double> valorTotalNotifier = ValueNotifier<double>(0.0);
  final ValueNotifier<bool> tanqueCheioNotifier = ValueNotifier<bool>(false);

  // Controle de formatação otimizada
  bool _isFormattingUpdate = false;

  GlobalKey<FormState> get formKey => _formKey;
  AbastecimentoFormModel get formModel => _formModel.value;
  bool get isInitialized => _isInitialized.value;
  bool get isUpdating => _isUpdating.value;

  Future<void> reloadVeiculo() => _loadVeiculo();

  @override
  void onClose() {
    // Limpar timers
    _litrosDebounceTimer?.cancel();
    _valorPorLitroDebounceTimer?.cancel();
    _odometroDebounceTimer?.cancel();

    // Limpar controllers
    litrosController.dispose();
    valorPorLitroController.dispose();
    odometroController.dispose();
    observacaoController.dispose();

    // Limpar ValueNotifiers
    valorTotalNotifier.dispose();
    tanqueCheioNotifier.dispose();

    super.onClose();
  }

  Future<void> initializeForm(AbastecimentoCar? abastecimento) async {
    if (abastecimento != null) {
      _formModel.value =
          AbastecimentoFormModel.fromAbastecimento(abastecimento);
    } else {
      // Obter o ID do veículo selecionado de forma assíncrona
      final selectedVeiculoId =
          await VeiculosRepository().getSelectedVeiculoId();
      _formModel.value = AbastecimentoFormModel.initial(selectedVeiculoId);
    }

    // Inicializar controllers com valores do modelo
    _updateTextControllers();

    // Calcular valor total se for uma edição com valores preenchidos
    if (_formModel.value.litros > 0 && _formModel.value.valorPorLitro > 0) {
      _calculateTotal();
    }

    _loadVeiculo();
  }

  void _updateTextControllers() {
    if (_isFormattingUpdate) return; // Evitar loops infinitos

    _isFormattingUpdate = true;
    final model = _formModel.value;

    // Atualizar controllers sem disparar listeners
    litrosController.text = model.litros > 0
        ? _formattingService.formatNumericValue(model.litros, 3)
        : '';

    valorPorLitroController.text = model.valorPorLitro > 0
        ? _formattingService.formatNumericValue(model.valorPorLitro, 2)
        : '';

    odometroController.text = model.odometro > 0
        ? _formattingService.formatNumericValue(model.odometro.toDouble(), 1)
        : '';

    observacaoController.text = model.observacao;

    // Atualizar ValueNotifiers para campos calculados
    valorTotalNotifier.value = model.valorTotal;
    tanqueCheioNotifier.value = model.tanqueCheio;

    _isFormattingUpdate = false;
  }

  Future<void> _loadVeiculo() async {
    if (_isUpdating.value) return; // Evitar race condition

    _isUpdating.value = true;
    try {
      final veiculoId = _formModel.value.veiculoId;

      if (veiculoId.isNotEmpty) {
        final veiculo = await carregarVeiculo(veiculoId);
        _formModel.value = _formModel.value.copyWith(veiculo: veiculo);
      } else {
        debugPrint('VeiculoId está vazio - nenhum veículo selecionado');
      }

      _isInitialized.value = true;
    } catch (e) {
      debugPrint('Erro ao carregar veículo: $e');
      _isInitialized.value = true;
    } finally {
      _isUpdating.value = false;
    }
  }

  void updateTipoCombustivel(TipoCombustivel tipoCombustivel) {
    if (_isUpdating.value) return;

    _formModel.value = _formModel.value.copyWith(
      tipoCombustivel: tipoCombustivel,
      unidade: tipoCombustivel.unidade,
    );
    _formModel.refresh(); // Forçar notificação de mudança
  }

  void updateLitros(double litros) {
    if (_isUpdating.value) return;

    // Cancelar timer anterior se existir
    _litrosDebounceTimer?.cancel();

    // Atualizar imediatamente o modelo para responsividade
    _formModel.value = _formModel.value.copyWith(litros: litros);

    // Calcular imediatamente se ambos os valores estão preenchidos
    if (litros > 0 && _formModel.value.valorPorLitro > 0) {
      _calculateTotal();
    }

    // Debounce para cálculo (evitar múltiplas chamadas)
    _litrosDebounceTimer = Timer(const Duration(milliseconds: 300), () {
      if (!_isUpdating.value) {
        _calculateTotal();
      }
    });
  }

  void updateValorPorLitro(double valorPorLitro) {
    if (_isUpdating.value) return;

    // Cancelar timer anterior se existir
    _valorPorLitroDebounceTimer?.cancel();

    // Atualizar imediatamente o modelo para responsividade
    _formModel.value = _formModel.value.copyWith(valorPorLitro: valorPorLitro);

    // Calcular imediatamente se ambos os valores estão preenchidos
    if (valorPorLitro > 0 && _formModel.value.litros > 0) {
      _calculateTotal();
    }

    // Debounce para cálculo (evitar múltiplas chamadas)
    _valorPorLitroDebounceTimer = Timer(const Duration(milliseconds: 300), () {
      if (!_isUpdating.value) {
        _calculateTotal();
      }
    });
  }

  void updateOdometro(int odometro) {
    if (_isUpdating.value) return;

    // Cancelar timer anterior se existir
    _odometroDebounceTimer?.cancel();

    // Debounce para validação e atualização
    _odometroDebounceTimer = Timer(const Duration(milliseconds: 200), () {
      if (!_isUpdating.value) {
        _formModel.value = _formModel.value.copyWith(odometro: odometro);
        _formModel.refresh(); // Forçar notificação de mudança
      }
    });
  }

  void updateData(int data) {
    if (_isUpdating.value) return;

    _formModel.value = _formModel.value.copyWith(data: data);
    _formModel.refresh(); // Forçar notificação de mudança
  }

  void updateTanqueCheio(bool tanqueCheio) {
    if (_isUpdating.value) return;

    _formModel.value = _formModel.value.copyWith(tanqueCheio: tanqueCheio);
    tanqueCheioNotifier.value = tanqueCheio; // Atualização otimizada
    _formModel.refresh(); // Forçar notificação de mudança
  }

  void updateObservacao(String observacao) {
    if (_isUpdating.value) return;

    _formModel.value = _formModel.value.copyWith(observacao: observacao);
    // Não força refresh aqui pois observação não afeta outros campos
  }

  void clearLitros() {
    if (_isUpdating.value) return;

    // Limpar controller e modelo
    litrosController.clear();
    updateLitros(0.0);
  }

  void clearValorPorLitro() {
    if (_isUpdating.value) return;

    // Limpar controller e modelo
    valorPorLitroController.clear();
    updateValorPorLitro(0.0);
  }

  void clearOdometro() {
    if (_isUpdating.value) return;

    // Limpar controller e modelo
    odometroController.clear();
    updateOdometro(0);
  }

  void _calculateTotal() {
    if (_isUpdating.value) return;

    final currentModel = _formModel.value;
    final litros = currentModel.litros >= 0 ? currentModel.litros : 0.0;
    final valorPorLitro =
        currentModel.valorPorLitro >= 0 ? currentModel.valorPorLitro : 0.0;

    try {
      final valorTotal = calcularValorTotal(litros, valorPorLitro);

      // Verificar se o modelo ainda é o mesmo (evita race conditions)
      if (_formModel.value.litros == litros &&
          _formModel.value.valorPorLitro == valorPorLitro) {
        _formModel.value = _formModel.value.copyWith(valorTotal: valorTotal);
        valorTotalNotifier.value = valorTotal; // Atualização otimizada
        _formModel.refresh(); // Forçar notificação de mudança
      }
    } catch (e) {
      debugPrint('Erro ao calcular valor total: $e');
      _formModel.value = _formModel.value.copyWith(valorTotal: 0.0);
      valorTotalNotifier.value = 0.0; // Atualização otimizada
      _formModel.refresh(); // Forçar notificação de mudança
    }
  }

  String? validateLitros(String? value) =>
      _validationService.validateLitros(value);

  String? validateValorPorLitro(String? value) =>
      _validationService.validateValorPorLitro(value);

  String? validateOdometro(String? value) {
    final veiculo = _formModel.value.veiculo;
    return _validationService.validateOdometro(
      value,
      odometroInicial: veiculo?.odometroInicial,
      odometroAtual: veiculo?.odometroAtual,
    );
  }

  String? validateTipoCombustivel(TipoCombustivel? value) =>
      _validationService.validateTipoCombustivel(value);

  Future<bool> submitForm(AbastecimentoCar? originalAbastecimento) async {
    // Cancelar todos os timers pendentes antes de submeter
    _litrosDebounceTimer?.cancel();
    _valorPorLitroDebounceTimer?.cancel();
    _odometroDebounceTimer?.cancel();

    if (!_formKey.currentState!.validate()) {
      return false;
    }

    if (_formModel.value.isLoading || _isUpdating.value) return false;

    _isUpdating.value = true;
    _formModel.value = _formModel.value.copyWith(isLoading: true);
    _formModel.refresh(); // Forçar notificação de mudança

    try {
      _formKey.currentState!.save();

      final model = _formModel.value;

      if (model.veiculoId.isEmpty) {
        throw Exception('ID do veículo não pode estar vazio');
      }

      if (model.litros <= 0) {
        throw Exception('A quantidade de litros deve ser maior que zero');
      }

      final id = originalAbastecimento?.id ?? const Uuid().v4();
      final createdAt = originalAbastecimento?.createdAt ??
          DateTime.now().millisecondsSinceEpoch;
      final updatedAt = DateTime.now().millisecondsSinceEpoch;

      final newAbastecimento = criarNovoAbastecimento(
        id: id,
        createdAt: createdAt,
        updatedAt: updatedAt,
        veiculoId: model.veiculoId,
        litros: model.litros,
        valorTotal: model.valorTotal,
        data: model.data,
        odometro: model.odometro.toDouble(),
        tanqueCheio: model.tanqueCheio,
        precoPorLitro: model.valorPorLitro,
        tipoCombustivel: model.tipoCombustivel.index,
        posto: model.posto,
        observacao: model.observacao,
      );

      if (originalAbastecimento != null) {
        debugPrint('🚗 [ABASTECIMENTO] Atualizando abastecimento...');
        await atualizarAbastecimento(newAbastecimento);
        debugPrint('🚗 [ABASTECIMENTO] Abastecimento atualizado');
      } else {
        debugPrint('🚗 [ABASTECIMENTO] Adicionando novo abastecimento...');
        await adicionarAbastecimento(newAbastecimento);
        debugPrint('🚗 [ABASTECIMENTO] Abastecimento adicionado');
      }

      // Update vehicle's current odometer if new reading is higher
      final veiculo = model.veiculo;
      if (veiculo != null && model.odometro > veiculo.odometroAtual) {
        debugPrint('🚗 [ABASTECIMENTO] Atualizando odômetro do veículo...');
        VeiculosRepository().updateOdometroAtual(
          veiculo.id,
          model.odometro.toDouble(),
        );
        debugPrint('🚗 [ABASTECIMENTO] Odômetro do veículo atualizado');
      }

      debugPrint('🚗 [ABASTECIMENTO] submitForm retornando true');
      return true;
    } catch (e) {
      debugPrint('Erro ao salvar abastecimento: $e');
      rethrow;
    } finally {
      _isUpdating.value = false;
      _formModel.value = _formModel.value.copyWith(isLoading: false);
      _formModel.refresh(); // Forçar notificação de mudança
    }
  }

  // ===================================
  // MIGRATED METHODS FROM EXTERNAL CONTROLLER
  // ===================================

  /// Adiciona novo abastecimento
  Future<bool> adicionarAbastecimento(AbastecimentoCar abastecimento) async {
    try {
      return await _abastecimentosRepository.addAbastecimento(abastecimento);
    } catch (e) {
      debugPrint('Erro ao adicionar abastecimento: $e');
      return false;
    }
  }

  /// Atualiza abastecimento existente
  Future<bool> atualizarAbastecimento(AbastecimentoCar abastecimento) async {
    try {
      return await _abastecimentosRepository.updateAbastecimento(abastecimento);
    } catch (e) {
      debugPrint('Erro ao atualizar abastecimento: $e');
      return false;
    }
  }

  /// Carrega dados do veículo por ID
  Future<VeiculoCar?> carregarVeiculo(String veiculoId) async {
    try {
      return await _veiculosRepository.getVeiculoById(veiculoId);
    } catch (e) {
      debugPrint('Erro ao carregar veículo: $e');
      return null;
    }
  }

  /// Calcula valor total do abastecimento
  double calcularValorTotal(double litros, double precoPorLitro) {
    if (litros <= 0 || precoPorLitro <= 0) return 0.0;
    return litros * precoPorLitro;
  }

  /// Cria novo objeto AbastecimentoCar
  AbastecimentoCar criarNovoAbastecimento({
    required String id,
    required int createdAt,
    required int updatedAt,
    required String veiculoId,
    required double litros,
    required double valorTotal,
    required int data,
    required double odometro,
    required bool tanqueCheio,
    required double precoPorLitro,
    required int tipoCombustivel,
    required String posto,
    required String observacao,
  }) {
    return AbastecimentoCar(
      id: id,
      createdAt: createdAt,
      updatedAt: updatedAt,
      veiculoId: veiculoId,
      data: data,
      odometro: odometro,
      litros: litros,
      valorTotal: valorTotal,
      tanqueCheio: tanqueCheio,
      precoPorLitro: precoPorLitro,
      tipoCombustivel: tipoCombustivel,
      posto: posto,
      observacao: observacao,
    );
  }

  /// Busca abastecimento por ID
  Future<AbastecimentoCar?> getAbastecimentoById(String id) async {
    try {
      return await _abastecimentosRepository.getAbastecimentoById(id);
    } catch (e) {
      debugPrint('Erro ao buscar abastecimento: $e');
      return null;
    }
  }
}
