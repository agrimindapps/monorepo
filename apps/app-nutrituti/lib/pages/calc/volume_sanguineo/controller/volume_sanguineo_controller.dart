// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:share_plus/share_plus.dart';

// Project imports:
import '../model/volume_sanguineo_model.dart';
import '../services/calculation_service.dart';
import '../services/message_service.dart';
import '../services/validation_service.dart';

/// Controller principal do módulo Volume Sanguíneo
///
/// Responsável pela orquestração entre services e coordenação de estado.
/// Segue princípios SOLID com responsabilidade única de coordenação.
///
/// ✅ ISSUE #2 RESOLVIDA - Não depende mais de BuildContext!
/// - Controller não recebe BuildContext como parâmetro
/// - Comunicação com UI através de MessageService/MessageHandler
/// - Permite testes unitários sem mockar contexto
/// - Reutilização em diferentes contextos de UI
///
/// ✅ ISSUE #4 RESOLVIDA - Model com responsabilidades separadas!
/// - Model refatorado usa componentes especializados
/// - Separação clara entre UI, formatação, dados e cálculos
/// - Arquitetura limpa com injeção de dependências
class VolumeSanguineoController extends ChangeNotifier {
  final VolumeSanguineoModel _model = VolumeSanguineoModel();
  final FocusNode _unfocusNode = FocusNode();
  bool _isCalculated = false;

  // Services para separação de responsabilidades
  final VolumeSanguineoValidationService _validationService;
  final VolumeSanguineoCalculationService _calculationService;
  final VolumeSanguineoMessageService _messageService;

  // Getters
  VolumeSanguineoModel get model => _model;
  bool get isCalculated => _isCalculated;
  FocusNode get unfocusNode => _unfocusNode;

  // 🚀 ISSUE #5: Getter para permitir acesso ao validation service para debounce
  VolumeSanguineoValidationService get validationService => _validationService;

  // Inicialização do controlador com injeção de dependências
  VolumeSanguineoController({
    VolumeSanguineoValidationService? validationService,
    VolumeSanguineoCalculationService? calculationService,
    VolumeSanguineoMessageService? messageService,
  })  : _validationService =
            validationService ?? VolumeSanguineoValidationService(),
        _calculationService =
            calculationService ?? VolumeSanguineoCalculationService(),
        _messageService = messageService ?? VolumeSanguineoMessageService() {
    _model.generoDef = _model.generos[0];
  }

  /// Calcula o volume sanguíneo usando os services
  ///
  /// Método principal que não depende de BuildContext
  /// 🔒 IMPLEMENTA ISSUE #3 - SECURITY: Inclui validações robustas de segurança
  bool calcular() {
    final pesoText = _model.pesoController.text;

    // 🔒 VALIDAÇÃO DE SEGURANÇA PRÉVIA - Verifica se entrada é potencialmente maliciosa
    if (_validationService.hasPotentialSecurityThreat(pesoText)) {
      _messageService.showError('Entrada rejeitada por questões de segurança.');
      _model.focusPeso.requestFocus();
      return false;
    }

    // Validação completa usando ValidationService (que agora inclui segurança)
    final validationError = _validationService.validateAllFields(
      pesoText,
      _model.generoDef,
    );

    if (validationError != null) {
      _messageService.showError(validationError);
      _model.focusPeso.requestFocus();
      return false;
    }

    try {
      // 🔒 PARSING SEGURO - Usa valor sanitizado se necessário
      final pesoSeguro = _validationService.sanitizeNumericInput(pesoText);
      final peso = _calculationService.parsePeso(pesoSeguro);
      final fator = _model.generoDef['value'] as int;

      // 🔒 VALIDAÇÃO ADICIONAL - Verifica se peso parsed está em range seguro
      if (peso < 0.5 || peso > 700) {
        _messageService.showError('Peso fora do range seguro (0.5kg - 700kg).');
        return false;
      }

      final resultado =
          _calculationService.calculateVolumeSanguineo(peso, fator);

      // Verifica se resultado é plausível
      if (!_calculationService.isResultadoPlausivel(resultado)) {
        _messageService.showError(
            'Resultado fora do esperado. Verifique os valores inseridos.');
        return false;
      }

      // Atualiza modelo com resultados usando nova arquitetura
      try {
        _model.calcular(); // Usa o método refatorado do model
        _isCalculated = true;
        _messageService.showSuccess('Cálculo realizado com sucesso!');
        notifyListeners();
        return true;
      } catch (modelError) {
        _messageService.showError('Erro no cálculo: ${modelError.toString()}');
        return false;
      }
    } catch (e) {
      _messageService.showError('Erro no cálculo: ${e.toString()}');
      return false;
    }
  }

  /// Atualiza o tipo de pessoa selecionado
  void updateGenero(Map<String, dynamic> value) {
    _model.generoDef = value;
    notifyListeners();
  }

  /// Método com nome padronizado
  void updatePersonType(Map<String, dynamic> value) => updateGenero(value);

  /// Limpa os dados do formulário e reseta o estado
  void limpar() {
    _model.limpar();
    _isCalculated = false;
    _unfocusNode.requestFocus();
    notifyListeners();
  }

  /// Método com nome padronizado
  void clear() => limpar();

  /// Compartilha o resultado do cálculo
  void compartilhar() {
    if (!_isCalculated) return;
    final shareText = _model.getShareText();
    SharePlus.instance.share(ShareParams(text: shareText));
  }

  /// Método com nome padronizado
  void share() => compartilhar();

  /// Métodos de conveniência para acesso aos services
  /// Permite usar validação sem depender do contexto
  String? validatePeso(String pesoText) {
    return _validationService.validatePeso(pesoText);
  }

  /// Valida tipo de pessoa selecionado
  String? validateTipoPessoa() {
    return _validationService.validateTipoPessoa(_model.generoDef);
  }

  /// Verifica se todos os campos estão válidos
  bool get isFormValid {
    final error = _validationService.validateAllFields(
      _model.pesoController.text,
      _model.generoDef,
    );
    return error == null;
  }

  @override
  void dispose() {
    _unfocusNode.dispose();
    _model.dispose();
    super.dispose();
  }
}
