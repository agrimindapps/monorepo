// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../model/adiposidade_model.dart';
import '../services/state_service.dart';
import '../services/validation_service.dart';
import '../utils/adiposidade_utils.dart';

class AdipososidadeController extends ChangeNotifier {
  // Controllers e focus nodes
  final quadrilController = TextEditingController();
  final alturaController = TextEditingController();
  final idadeController = TextEditingController();
  final focusQuadril = FocusNode();
  final focusAltura = FocusNode();
  final focusIdade = FocusNode();

  // State management service
  final AdiposidadeStateService _stateService = AdiposidadeStateService();

  // Debounce para validação
  Timer? _debounceTimer;

  // Getters delegados ao state service
  int get generoSelecionado => _stateService.generoSelecionado;
  bool get calculado => _stateService.state.hasValidResult;
  AdipososidadeModel get modelo =>
      _stateService.resultado ?? AdipososidadeModel.empty();
  String? get quadrilError => _stateService.quadrilState.error;
  String? get alturaError => _stateService.alturaState.error;
  String? get idadeError => _stateService.idadeState.error;
  AdiposidadeState get state => _stateService.state;

  // Streams para reatividade
  Stream<AdiposidadeState> get stateStream => _stateService.stateStream;
  Stream<FieldState> get quadrilStream => _stateService.quadrilStream;
  Stream<FieldState> get alturaStream => _stateService.alturaStream;
  Stream<FieldState> get idadeStream => _stateService.idadeStream;

  // Construtor
  AdipososidadeController() {
    _setupFieldListeners();
    // Escuta mudanças no state service e replica no notifier
    _stateService.addListener(_onStateChanged);
  }

  void _onStateChanged() {
    notifyListeners();
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    quadrilController.dispose();
    alturaController.dispose();
    idadeController.dispose();
    focusQuadril.dispose();
    focusAltura.dispose();
    focusIdade.dispose();
    _stateService.dispose();
    super.dispose();
  }

  // Configura listeners para validação em tempo real
  void _setupFieldListeners() {
    quadrilController.addListener(() => _validateFieldWithDebounce('quadril'));
    alturaController.addListener(() => _validateFieldWithDebounce('altura'));
    idadeController.addListener(() => _validateFieldWithDebounce('idade'));
  }

  // Validação com debounce
  void _validateFieldWithDebounce(String field) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      _validateField(field);
    });
  }

  // Validação específica por campo usando ValidationService e StateService
  void _validateField(String field) {
    ValidationResult result;

    switch (field) {
      case 'quadril':
        result = AdiposidadeValidationService.validateQuadrilRealTime(
            quadrilController.text);
        _stateService.updateQuadril(
          quadrilController.text,
          error: result.isValid ? null : result.message,
          isValid: result.isValid,
          isValidating: false,
        );
        break;
      case 'altura':
        result = AdiposidadeValidationService.validateAlturaRealTime(
            alturaController.text);
        _stateService.updateAltura(
          alturaController.text,
          error: result.isValid ? null : result.message,
          isValid: result.isValid,
          isValidating: false,
        );
        break;
      case 'idade':
        result = AdiposidadeValidationService.validateIdadeRealTime(
            idadeController.text);
        _stateService.updateIdade(
          idadeController.text,
          error: result.isValid ? null : result.message,
          isValid: result.isValid,
          isValidating: false,
        );
        break;
    }
  }

  // Métodos públicos
  void calcular(BuildContext context) {
    // Verifica se pode calcular usando o state service
    if (!_stateService.state.canCalculate) {
      if (!_validarCampos(context)) return;
    }

    // Define estado de cálculo
    _stateService.setCalculatingState();

    // Verifica cache primeiro
    final cachedResult = _stateService.getCachedResult();
    if (cachedResult != null) {
      _stateService.setCalculationResult(cachedResult);
      _exibirMensagem(context, 'Cálculo realizado com sucesso!',
          isError: false);
      return;
    }

    // Processar os dados usando formatação padronizada
    final quadril = _parseDecimal(quadrilController.text);
    final altura = _parseDecimal(alturaController.text);
    final idade = int.parse(idadeController.text);

    // Calcular IAC
    final iac = AdipososidadeUtils.calcularIAC(quadril, altura);

    // Obter classificação
    final classificacao = AdipososidadeUtils.obterClassificacao(
        iac, _stateService.generoSelecionado);

    // Obter comentário
    final comentario = AdipososidadeUtils.obterComentario(classificacao);

    // Criar modelo de resultado
    final modelo = AdipososidadeModel(
      generoSelecionado: _stateService.generoSelecionado,
      quadril: quadril,
      altura: altura,
      idade: idade,
      iac: iac,
      classificacao: classificacao,
      comentario: comentario,
    );

    // Atualizar estado com resultado
    _stateService.setCalculationResult(modelo);

    // Exibir mensagem de sucesso
    _exibirMensagem(context, 'Cálculo realizado com sucesso!', isError: false);
  }

  void limpar() {
    quadrilController.clear();
    alturaController.clear();
    idadeController.clear();
    _stateService.clearAll();
  }

  void compartilhar() {
    if (_stateService.state.hasValidResult) {
      _stateService.setSharingState();
      // final texto = AdipososidadeUtils.gerarTextoCompartilhamento(_stateService.resultado!);
      // SharePlus.instance.share(ShareParams(text: texto));
    }
  }

  void atualizarGenero(int genero) {
    _stateService.updateGenero(genero);
  }

  // Métodos privados
  // Validação usando ValidationService
  bool _validarCampos(BuildContext context) {
    final validationResults = AdiposidadeValidationService.validateAllFields(
      quadril: quadrilController.text,
      altura: alturaController.text,
      idade: idadeController.text,
    );

    // Verifica se há erros de validação
    if (!AdiposidadeValidationService.areAllFieldsValid(validationResults)) {
      final errorMessage =
          AdiposidadeValidationService.getFirstErrorMessage(validationResults);
      if (errorMessage != null) {
        _exibirMensagem(context, errorMessage);

        // Move o foco para o primeiro campo com erro
        if (!validationResults['quadril']!.isValid) {
          focusQuadril.requestFocus();
        } else if (!validationResults['altura']!.isValid) {
          focusAltura.requestFocus();
        } else if (!validationResults['idade']!.isValid) {
          focusIdade.requestFocus();
        }
      }
      return false;
    }

    // Exibe avisos se houver
    final warnings =
        AdiposidadeValidationService.getWarningMessages(validationResults);
    for (final warning in warnings) {
      _exibirMensagem(context, warning, isError: false);
    }

    return true;
  }

  void _exibirMensagem(BuildContext context, String message,
      {bool isError = true}) {
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(SnackBar(
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        content: Row(
          children: [
            Icon(
              isError ? Icons.error_outline : Icons.check_circle_outline,
              color: Colors.white,
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: isError ? Colors.red.shade900 : Colors.green.shade700,
        duration: Duration(seconds: isError ? 3 : 2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ));
  }

  // Funções helper para formatação de números decimais
  double _parseDecimal(String value) {
    // Converte vírgula para ponto para processamento interno
    return double.parse(value.replaceAll(',', '.'));
  }
}
