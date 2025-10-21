// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../calculators/volume_calculator.dart';
import '../data/volume_sanguineo_data.dart';

/// Controllers de formulário para UI do Volume Sanguíneo
///
/// Responsável apenas pelo gerenciamento de controladores de UI,
/// sem lógica de negócio ou cálculos.
class VolumeSanguineoFormControllers {
  final TextEditingController pesoController;
  final FocusNode pesoFocusNode;

  PersonType _selectedPersonType;

  VolumeSanguineoFormControllers({
    TextEditingController? pesoController,
    FocusNode? pesoFocusNode,
    PersonType? initialPersonType,
  })  : pesoController = pesoController ?? TextEditingController(),
        pesoFocusNode = pesoFocusNode ?? FocusNode(),
        _selectedPersonType =
            initialPersonType ?? VolumeSanguineoCalculator.getPersonTypeById(1);

  /// Tipo de pessoa selecionado
  PersonType get selectedPersonType => _selectedPersonType;

  /// Define tipo de pessoa selecionado
  set selectedPersonType(PersonType personType) {
    _selectedPersonType = personType;
  }

  /// Texto do peso inserido
  String get pesoText => pesoController.text;

  /// Define texto do peso
  set pesoText(String value) {
    pesoController.text = value;
  }

  /// Verifica se há peso inserido
  bool get hasPesoText => pesoController.text.isNotEmpty;

  /// Obtém peso como double
  double? get pesoAsDouble {
    if (!hasPesoText) return null;
    try {
      return double.parse(pesoController.text.replaceAll(',', '.'));
    } catch (e) {
      return null;
    }
  }

  /// Cria VolumeSanguineoData a partir dos dados do formulário
  VolumeSanguineoData? createDataFromForm() {
    final peso = pesoAsDouble;
    if (peso == null) return null;

    return VolumeSanguineoData(
      peso: peso,
      tipoPessoaId: _selectedPersonType.id,
      tipoPessoaTexto: _selectedPersonType.text,
      fatorCalculoMlKg: _selectedPersonType.factorMlKg,
    );
  }

  /// Preenche formulário a partir de VolumeSanguineoData
  void fillFromData(VolumeSanguineoData data) {
    pesoController.text = data.peso.toString().replaceAll('.', ',');
    _selectedPersonType =
        VolumeSanguineoCalculator.getPersonTypeById(data.tipoPessoaId);
  }

  /// Limpa todos os campos do formulário
  void clear() {
    pesoController.clear();
    pesoFocusNode.unfocus();
  }

  /// Foca no campo de peso
  void focusPeso() {
    pesoFocusNode.requestFocus();
  }

  /// Obtém todos os tipos de pessoa para dropdown
  List<PersonType> get allPersonTypes =>
      VolumeSanguineoCalculator.getAllPersonTypes();

  /// Converte PersonType para formato de dropdown compatível
  List<Map<String, dynamic>> get personTypesForDropdown {
    return allPersonTypes.map((type) => type.toMap()).toList();
  }

  /// Obtém PersonType selecionado no formato antigo (compatibilidade)
  Map<String, dynamic> get selectedPersonTypeMap => _selectedPersonType.toMap();

  /// Define PersonType a partir do formato antigo (compatibilidade)
  set selectedPersonTypeFromMap(Map<String, dynamic> map) {
    final id = map['id'] as int;
    _selectedPersonType = VolumeSanguineoCalculator.getPersonTypeById(id);
  }

  /// Valida se o formulário está preenchido corretamente
  FormValidationResult validateForm() {
    final errors = <String>[];

    if (!hasPesoText) {
      errors.add('Peso é obrigatório');
    } else {
      final peso = pesoAsDouble;
      if (peso == null) {
        errors.add('Peso deve ser um número válido');
      } else if (peso <= 0) {
        errors.add('Peso deve ser maior que zero');
      } else if (peso < 0.5) {
        errors.add('Peso muito baixo (mínimo: 0.5kg)');
      } else if (peso > 700) {
        errors.add('Peso muito alto (máximo: 700kg)');
      }
    }

    return FormValidationResult(
      isValid: errors.isEmpty,
      errors: errors,
    );
  }

  /// Libera recursos
  void dispose() {
    pesoController.dispose();
    pesoFocusNode.dispose();
  }

  @override
  String toString() {
    return 'VolumeSanguineoFormControllers(peso: $pesoText, tipo: ${_selectedPersonType.text})';
  }
}

/// Resultado da validação do formulário
class FormValidationResult {
  final bool isValid;
  final List<String> errors;

  const FormValidationResult({
    required this.isValid,
    required this.errors,
  });

  /// Primeiro erro (se houver)
  String? get firstError => errors.isNotEmpty ? errors.first : null;

  /// Todos os erros como string única
  String get allErrorsText => errors.join('\n');

  @override
  String toString() {
    return 'FormValidationResult(valid: $isValid, errors: ${errors.length})';
  }
}
