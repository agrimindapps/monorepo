import 'package:equatable/equatable.dart';

/// Tipo de input para os campos das calculadoras
enum InputFieldType {
  text,
  number,
  dropdown,
  slider,
  switch_,
  radio,
}

/// Representa um campo de entrada para uma calculadora
class InputField extends Equatable {
  const InputField({
    required this.key,
    required this.label,
    required this.type,
    this.isRequired = true,
    this.placeholder,
    this.helperText,
    this.unit,
    this.options,
    this.minValue,
    this.maxValue,
    this.defaultValue,
    this.validator,
  });

  /// Chave única do campo (usada como key no Map de inputs)
  final String key;
  
  /// Label exibido para o usuário
  final String label;
  
  /// Tipo do campo de entrada
  final InputFieldType type;
  
  /// Se o campo é obrigatório
  final bool isRequired;
  
  /// Texto de placeholder (para campos de texto)
  final String? placeholder;
  
  /// Texto de ajuda exibido abaixo do campo
  final String? helperText;
  
  /// Unidade de medida (ex: "kg", "ml", "mg/kg")
  final String? unit;
  
  /// Lista de opções (para dropdown e radio)
  final List<String>? options;
  
  /// Valor mínimo (para números e sliders)
  final double? minValue;
  
  /// Valor máximo (para números e sliders)
  final double? maxValue;
  
  /// Valor padrão do campo
  final dynamic defaultValue;
  
  /// Função de validação customizada
  final String? Function(dynamic value)? validator;

  @override
  List<Object?> get props => [
    key,
    label,
    type,
    isRequired,
    placeholder,
    helperText,
    unit,
    options,
    minValue,
    maxValue,
    defaultValue,
  ];
}