import 'package:equatable/equatable.dart';

enum ParameterType {
  number,
  integer,
  decimal,
  text,
  selection,
  boolean,
  date,
  percentage,
  area,
  volume,
  weight
}

enum ParameterUnit {
  none,
  // Área
  hectare,
  metro2,
  acre,
  plantasha,
  // Volume
  litro,
  metro3,
  // Peso
  kg,
  quilograma,
  tonelada,
  gramas,
  grama,
  // Distância
  metro,
  centimetro,
  kilometro,
  // Percentual
  percentual,
  // Tempo
  dia,
  mes,
  ano,
  // Temperatura
  celsius,
  // Pressão
  bar,
  atm,
  // Nutrientes
  ppm,
  mgL,
  mgdm3,
  // Contadores e Scores
  count,
  escore,
  // Livestock units
  cabecas,
  // Combined units
  kgdia,
  litrodia,
  mcalkg,
  litroha,
  // Distance units
  milimetro,
  mmh,  // mm/h
  // Soil/Chemistry units
  cmolcdm3,  // cmolc/dm³
  gcm3,      // g/cm³
  dsm,       // dS/m
  // Ratios
  ratio,
  // Type extension for integers  
  integer
}

class CalculatorParameter extends Equatable {
  final String id;
  final String name;
  final String description;
  final ParameterType type;
  final ParameterUnit unit;
  final bool required;
  final dynamic defaultValue;
  final dynamic minValue;
  final dynamic maxValue;
  final List<String>? options; // Para tipo selection
  final String? validationMessage;

  const CalculatorParameter({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    this.unit = ParameterUnit.none,
    this.required = true,
    this.defaultValue,
    this.minValue,
    this.maxValue,
    this.options,
    this.validationMessage,
  });

  bool isValid(dynamic value) {
    if (required && (value == null || value.toString().isEmpty)) {
      return false;
    }

    if (value == null) return true;

    switch (type) {
      case ParameterType.number:
      case ParameterType.integer:
      case ParameterType.decimal:
        final num? numValue = double.tryParse(value.toString());
        if (numValue == null) return false;
        if (minValue != null) {
          final num? minNum = double.tryParse(minValue.toString());
          if (minNum != null && numValue < minNum) return false;
        }
        if (maxValue != null) {
          final num? maxNum = double.tryParse(maxValue.toString());
          if (maxNum != null && numValue > maxNum) return false;
        }
        break;
      case ParameterType.selection:
        if (options != null && !options!.contains(value.toString())) {
          return false;
        }
        break;
      case ParameterType.percentage:
        final num? numValue = double.tryParse(value.toString());
        if (numValue == null) return false;
        if (numValue < 0 || numValue > 100) return false;
        break;
      default:
        break;
    }

    return true;
  }

  String getDisplayValue(dynamic value) {
    if (value == null) return '';
    
    String displayValue = value.toString();
    
    if (unit != ParameterUnit.none) {
      displayValue += ' ${_getUnitSymbol()}';
    }
    
    return displayValue;
  }

  String _getUnitSymbol() {
    switch (unit) {
      case ParameterUnit.hectare:
        return 'ha';
      case ParameterUnit.metro2:
        return 'm²';
      case ParameterUnit.acre:
        return 'acre';
      case ParameterUnit.litro:
        return 'L';
      case ParameterUnit.metro3:
        return 'm³';
      case ParameterUnit.kg:
        return 'kg';
      case ParameterUnit.tonelada:
        return 't';
      case ParameterUnit.gramas:
      case ParameterUnit.grama:
        return 'g';
      case ParameterUnit.quilograma:
        return 'kg';
      case ParameterUnit.plantasha:
        return 'plantas/ha';
      case ParameterUnit.count:
        return 'unidades';
      case ParameterUnit.escore:
        return 'pts';
      case ParameterUnit.metro:
        return 'm';
      case ParameterUnit.centimetro:
        return 'cm';
      case ParameterUnit.kilometro:
        return 'km';
      case ParameterUnit.percentual:
        return '%';
      case ParameterUnit.dia:
        return 'dias';
      case ParameterUnit.mes:
        return 'meses';
      case ParameterUnit.ano:
        return 'anos';
      case ParameterUnit.celsius:
        return '°C';
      case ParameterUnit.bar:
        return 'bar';
      case ParameterUnit.atm:
        return 'atm';
      case ParameterUnit.ppm:
        return 'ppm';
      case ParameterUnit.mgL:
        return 'mg/L';
      case ParameterUnit.mgdm3:
        return 'mg/dm³';
      case ParameterUnit.cabecas:
        return 'cabeças';
      case ParameterUnit.kgdia:
        return 'kg/dia';
      case ParameterUnit.litrodia:
        return 'litros/dia';
      case ParameterUnit.mcalkg:
        return 'Mcal/kg';
      case ParameterUnit.litroha:
        return 'L/ha';
      case ParameterUnit.milimetro:
        return 'mm';
      case ParameterUnit.mmh:
        return 'mm/h';
      case ParameterUnit.cmolcdm3:
        return 'cmolc/dm³';
      case ParameterUnit.gcm3:
        return 'g/cm³';
      case ParameterUnit.dsm:
        return 'dS/m';
      case ParameterUnit.ratio:
        return '';
      case ParameterUnit.integer:
        return '';
      default:
        return '';
    }
  }

  /// Converte CalculatorParameter para Map (JSON)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'type': type.name,
      'unit': unit.name,
      'required': required,
      'defaultValue': defaultValue,
      'minValue': minValue,
      'maxValue': maxValue,
      'options': options,
      'validationMessage': validationMessage,
    };
  }

  /// Cria CalculatorParameter a partir de Map (JSON)
  factory CalculatorParameter.fromJson(Map<String, dynamic> json) {
    return CalculatorParameter(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      type: ParameterType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => ParameterType.text,
      ),
      unit: ParameterUnit.values.firstWhere(
        (e) => e.name == json['unit'],
        orElse: () => ParameterUnit.none,
      ),
      required: json['required'] as bool? ?? true,
      defaultValue: json['defaultValue'],
      minValue: json['minValue'],
      maxValue: json['maxValue'],
      options: json['options'] != null 
          ? List<String>.from(json['options'] as List)
          : null,
      validationMessage: json['validationMessage'] as String?,
    );
  }

  /// Cria cópia do CalculatorParameter com alterações
  CalculatorParameter copyWith({
    String? id,
    String? name,
    String? description,
    ParameterType? type,
    ParameterUnit? unit,
    bool? required,
    dynamic defaultValue,
    dynamic minValue,
    dynamic maxValue,
    List<String>? options,
    String? validationMessage,
  }) {
    return CalculatorParameter(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      type: type ?? this.type,
      unit: unit ?? this.unit,
      required: required ?? this.required,
      defaultValue: defaultValue ?? this.defaultValue,
      minValue: minValue ?? this.minValue,
      maxValue: maxValue ?? this.maxValue,
      options: options ?? this.options,
      validationMessage: validationMessage ?? this.validationMessage,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        type,
        unit,
        required,
        defaultValue,
        minValue,
        maxValue,
        options,
        validationMessage,
      ];
}