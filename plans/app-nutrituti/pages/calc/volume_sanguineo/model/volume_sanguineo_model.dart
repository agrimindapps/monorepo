// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../calculators/volume_calculator.dart';
import '../data/volume_sanguineo_data.dart';
import '../formatters/volume_formatter.dart';
import '../ui/form_controllers.dart';

/// Model refatorado com separação de responsabilidades
///
/// ✅ ISSUE #4 RESOLVIDA - Responsabilidades separadas!
/// - UI: FormControllers para gerenciamento de formulário
/// - Formatação: VolumeSanguineoFormatter para apresentação
/// - Dados: VolumeSanguineoData para domínio puro
/// - Cálculos: VolumeSanguineoCalculator para operações matemáticas
///
/// Este model agora é apenas um coordenador entre os componentes especializados
class VolumeSanguineoModel {
  // Componentes especializados
  final VolumeSanguineoFormControllers _formControllers;

  // Estado atual dos dados
  VolumeSanguineoData? _currentData;

  // Getters para compatibilidade com código existente
  TextEditingController get pesoController => _formControllers.pesoController;
  FocusNode get weightFocus => _formControllers.pesoFocusNode;

  // Deprecated: manter para compatibilidade
  FocusNode get focusPeso => weightFocus;

  double get peso => _currentData?.peso ?? 0;
  double get weight => peso; // Novo nome padrão

  double get resultado => _currentData?.volumeSanguineoLitros ?? 0;
  double get result => resultado; // Novo nome padrão

  Map<String, dynamic> get generoDef => _getPersonTypeFromData();
  set generoDef(Map<String, dynamic> value) => _setPersonTypeFromMap(value);

  // Novos getters/setters com nomenclatura padronizada
  Map<String, dynamic> get selectedPersonType => generoDef;
  set selectedPersonType(Map<String, dynamic> value) => generoDef = value;

  // Lista de gêneros/tipos - mantida para compatibilidade
  final List<Map<String, dynamic>> generos = [
    {'id': 1, 'value': 75, 'text': 'Masculino'},
    {'id': 2, 'value': 65, 'text': 'Feminino'},
    {'id': 3, 'value': 80, 'text': 'Criança'},
    {'id': 4, 'value': 95, 'text': 'Prematuro'},
    {'id': 5, 'value': 85, 'text': 'Recem Nascido'}
  ];

  // Novo nome padronizado
  List<Map<String, dynamic>> get personTypes => generos;

  VolumeSanguineoModel({
    VolumeSanguineoFormControllers? formControllers,
  }) : _formControllers = formControllers ?? VolumeSanguineoFormControllers() {
    // Inicializa com primeiro tipo
    _setPersonTypeFromMap(generos[0]);
  }

  /// Limpa os dados do formulário
  void limpar() {
    _formControllers.clear();
    _currentData = null;
  }

  /// Novo método com nome padronizado
  void clear() => limpar();

  /// Realiza o cálculo usando a nova arquitetura
  void calcular() {
    if (pesoController.text.isNotEmpty && _currentData != null) {
      try {
        final peso = double.parse(pesoController.text.replaceAll(',', '.'));

        // Cria dados de entrada
        final inputData = _currentData!.copyWith(peso: peso);

        // Executa cálculo usando calculator especializado
        _currentData = VolumeSanguineoCalculator.calculate(inputData);
      } catch (e) {
        // Em caso de erro, mantém dados anteriores
        rethrow;
      }
    }
  }

  /// Novo método com nome padronizado
  void calculate() => calcular();

  /// Texto formatado para compartilhar
  String getShareText() {
    if (_currentData == null) return '';

    return VolumeSanguineoFormatter.generateShareText(_currentData!);
  }

  /// Converte dados internos para formato legacy
  Map<String, dynamic> _getPersonTypeFromData() {
    if (_currentData == null) return generos[0];

    return generos.firstWhere(
      (g) => g['id'] == _currentData!.tipoPessoaId,
      orElse: () => generos[0],
    );
  }

  /// Atualiza dados internos a partir do formato legacy
  void _setPersonTypeFromMap(Map<String, dynamic> generoMap) {
    final id = generoMap['id'] as int;
    final text = generoMap['text'] as String;
    final factor = generoMap['value'] as int;

    _currentData = VolumeSanguineoData(
      peso: _currentData?.peso ?? 0,
      tipoPessoaId: id,
      tipoPessoaTexto: text,
      fatorCalculoMlKg: factor,
      volumeSanguineoLitros: _currentData?.volumeSanguineoLitros,
      dataCalculo: _currentData?.dataCalculo,
    );
  }

  /// Libera recursos
  void dispose() {
    _formControllers.dispose();
  }
}
