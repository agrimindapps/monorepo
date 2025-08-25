import 'package:equatable/equatable.dart';

import 'calculation_result.dart';
import 'input_field.dart';

/// Enum que define as categorias de calculadoras disponíveis
enum CalculatorCategory {
  nutrition('Nutrição', 'Cálculos relacionados à alimentação e nutrição'),
  medication('Medicação', 'Cálculos de dosagens e medicamentos'),
  health('Saúde', 'Avaliações e indicadores de saúde'),
  treatment('Tratamento', 'Cálculos para procedimentos terapêuticos'),
  conversion('Conversão', 'Conversões de unidades e medidas');

  const CalculatorCategory(this.name, this.description);
  
  final String name;
  final String description;
}

/// Entidade abstrata base para todas as calculadoras
/// Implementa Strategy Pattern para diferentes tipos de cálculos
abstract class Calculator extends Equatable {
  const Calculator();

  /// Identificador único da calculadora
  String get id;
  
  /// Nome da calculadora exibido na interface
  String get name;
  
  /// Descrição detalhada da calculadora
  String get description;
  
  /// Categoria da calculadora
  CalculatorCategory get category;
  
  /// Lista de campos de entrada necessários para o cálculo
  List<InputField> get inputFields;
  
  /// Ícone associado à calculadora (nome do ícone do Material Design)
  String get iconName;
  
  /// Versão da calculadora (para controle de mudanças)
  String get version;

  /// Executa o cálculo baseado nos inputs fornecidos
  /// 
  /// [inputs] - Mapa com os valores dos campos de entrada
  /// Retorna o resultado do cálculo ou lança exceção em caso de erro
  CalculationResult calculate(Map<String, dynamic> inputs);
  
  /// Valida se os inputs fornecidos são válidos para o cálculo
  /// 
  /// [inputs] - Mapa com os valores dos campos de entrada
  /// Retorna true se todos os inputs são válidos, false caso contrário
  bool validateInputs(Map<String, dynamic> inputs);
  
  /// Obtém mensagens de erro para inputs inválidos
  /// 
  /// [inputs] - Mapa com os valores dos campos de entrada
  /// Retorna lista de mensagens de erro, vazia se todos os inputs são válidos
  List<String> getValidationErrors(Map<String, dynamic> inputs);

  @override
  List<Object?> get props => [id, name, version];
}