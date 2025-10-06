import 'package:flutter/material.dart';
import '../../domain/entities/expense_entity.dart';

/// Constantes organizadas para o módulo de despesas
class ExpenseConstants {
  
  ExpenseConstants._();
  static const double minAmount = 0.01;
  static const double maxAmount = 999999.99;
  static const double maxOdometer = 9999999.0;
  static const double parkingMaxExpected = 50.0;
  static const double carWashMaxExpected = 100.0;
  static const double tollMaxExpected = 200.0;
  static const double fineMaxExpected = 2000.0;
  static const double insuranceMinExpected = 100.0;
  static const double insuranceMaxExpected = 10000.0;
  static const double ipvaMinExpected = 50.0;
  static const double ipvaMaxExpected = 15000.0;
  static const double licensingMaxExpected = 500.0;
  static const double accessoriesMaxExpected = 5000.0;
  static const double documentationMaxExpected = 1000.0;
  static const String decimalSeparator = ',';
  static const String dotSeparator = '.';
  static const String thousandSeparator = '.';
  static const String currencySymbol = 'R\$';
  static const int amountDecimals = 2;
  static const int odometerDecimals = 1;
  static const int maxYearsBack = 10;
  static const int maxDescriptionLength = 100;
  static const int minDescriptionLength = 3;
  static const int maxLocationLength = 100;
  static const int minLocationLength = 2;
  static const int maxNotesLength = 300;
  static const int maxCacheSize = 100;
  static const int defaultPageSize = 20;
  static const int amountDebounceMs = 300;
  static const int odometerDebounceMs = 200;
  static const int descriptionDebounceMs = 500;
  static const double maxOdometerDifference = 5000.0; // Diferença máxima entre registros
  static const double maxAmountVariationPercent = 0.5; // 50% de variação para despesas recorrentes
  static const String amountPattern = r'^\d{0,8}[,.]?\d{0,2}$';
  static const String odometerPattern = r'^\d{0,6}[,.]?\d{0,1}$';
  static const String descriptionPattern = r'^[a-zA-ZÀ-ÿ0-9\s\-\.\,\(\)]+$';
  static const String locationPattern = r'^[a-zA-ZÀ-ÿ0-9\s\-\.\,\(\)\/]+$';
  static const String requiredFieldError = 'Campo obrigatório';
  static const String invalidValueError = 'Valor inválido';
  static const String tooHighValueError = 'Valor muito alto';
  static const String tooLowValueError = 'Valor muito baixo';
  static const String futureDateError = 'Data não pode ser futura';
  static const String tooOldDateError = 'Data muito antiga';
  static const String invalidCharactersError = 'Caracteres inválidos';
  static const String tooShortError = 'Muito curto';
  static const String tooLongError = 'Muito longo';
  static const String kilometerUnit = 'km';
  static const String consumptionUnit = 'km/l';
  static const Map<ExpenseType, ExpenseTypeProperties> expenseTypeProperties = {
    ExpenseType.fuel: ExpenseTypeProperties(
      displayName: 'Combustível',
      icon: Icons.local_gas_station,
      color: 0xFF2196F3,
      isRecurring: false,
      description: 'Gastos com combustível',
    ),
    ExpenseType.maintenance: ExpenseTypeProperties(
      displayName: 'Manutenção',
      icon: Icons.build,
      color: 0xFFFF9800,
      isRecurring: false,
      description: 'Gastos com manutenção do veículo',
    ),
    ExpenseType.insurance: ExpenseTypeProperties(
      displayName: 'Seguro',
      icon: Icons.security,
      color: 0xFF4CAF50,
      isRecurring: true,
      minExpectedValue: insuranceMinExpected,
      maxExpectedValue: insuranceMaxExpected,
      description: 'Seguro do veículo',
    ),
    ExpenseType.ipva: ExpenseTypeProperties(
      displayName: 'IPVA',
      icon: Icons.description,
      color: 0xFF2196F3,
      isRecurring: true,
      minExpectedValue: ipvaMinExpected,
      maxExpectedValue: ipvaMaxExpected,
      description: 'Imposto sobre a Propriedade de Veículos Automotores',
    ),
    ExpenseType.parking: ExpenseTypeProperties(
      displayName: 'Estacionamento',
      icon: Icons.local_parking,
      color: 0xFF9C27B0,
      isRecurring: false,
      maxExpectedValue: parkingMaxExpected,
      description: 'Gastos com estacionamento',
    ),
    ExpenseType.carWash: ExpenseTypeProperties(
      displayName: 'Lavagem',
      icon: Icons.local_car_wash,
      color: 0xFF00BCD4,
      isRecurring: false,
      maxExpectedValue: carWashMaxExpected,
      description: 'Lavagem e limpeza do veículo',
    ),
    ExpenseType.fine: ExpenseTypeProperties(
      displayName: 'Multa',
      icon: Icons.report_problem,
      color: 0xFFF44336,
      isRecurring: false,
      maxExpectedValue: fineMaxExpected,
      description: 'Multas de trânsito',
    ),
    ExpenseType.toll: ExpenseTypeProperties(
      displayName: 'Pedágio',
      icon: Icons.toll,
      color: 0xFFFF9800,
      isRecurring: false,
      maxExpectedValue: tollMaxExpected,
      description: 'Tarifas de pedágio',
    ),
    ExpenseType.licensing: ExpenseTypeProperties(
      displayName: 'Licenciamento',
      icon: Icons.assignment,
      color: 0xFF795548,
      isRecurring: true,
      maxExpectedValue: licensingMaxExpected,
      description: 'Licenciamento anual do veículo',
    ),
    ExpenseType.accessories: ExpenseTypeProperties(
      displayName: 'Acessórios',
      icon: Icons.shopping_bag,
      color: 0xFFE91E63,
      isRecurring: false,
      maxExpectedValue: accessoriesMaxExpected,
      description: 'Acessórios e equipamentos',
    ),
    ExpenseType.documentation: ExpenseTypeProperties(
      displayName: 'Documentação',
      icon: Icons.folder,
      color: 0xFF607D8B,
      isRecurring: false,
      maxExpectedValue: documentationMaxExpected,
      description: 'Documentos e papelada',
    ),
    ExpenseType.other: ExpenseTypeProperties(
      displayName: 'Outro',
      icon: Icons.attach_money,
      color: 0xFF9E9E9E,
      isRecurring: false,
      description: 'Outras despesas não categorizadas',
    ),
  };
  static const String formStatusIdle = 'idle';
  static const String formStatusLoading = 'loading';
  static const String formStatusError = 'error';
  static const String formStatusSuccess = 'success';
  static const double formMaxHeight = 650.0;
  static const double sectionSpacing = 16.0;
  static const double fieldSpacing = 12.0;
  static const double buttonHeight = 48.0;
  static const double cardBorderRadius = 12.0;
  static const int animationDurationMs = 250;
  static const int loadingMinDurationMs = 500;
  static const String basicInfoSectionTitle = 'Informações Básicas';
  static const String expenseSectionTitle = 'Despesa';
  static const String locationSectionTitle = 'Localização';
  static const String additionalSectionTitle = 'Informações Adicionais';
  static const String descriptionPlaceholder = 'Ex: Seguro anual, Multa de velocidade...';
  static const String amountPlaceholder = '0,00';
  static const String odometerPlaceholder = '0,0';
  static const String locationPlaceholder = 'Ex: Shopping Center, Posto de Gasolina...';
  static const String notesPlaceholder = 'Observações sobre esta despesa...';
  static const String datePattern = 'dd/MM/yyyy';
  static const String timePattern = 'HH:mm';
  static const String dateTimePattern = 'dd/MM/yyyy HH:mm';
  static const double reportAmountThousands = 1000.0;
  static const double reportAmountMillions = 1000000.0;
  static const int maxPageSize = 100;
  static const int minPageSize = 5;
  static const int imageMaxWidth = 1200;
  static const int imageMaxHeight = 1200;
  static const int imageQuality = 85; // Previne instanciação
}

/// Classe para propriedades específicas de cada tipo de despesa
class ExpenseTypeProperties {

  const ExpenseTypeProperties({
    required this.displayName,
    required this.icon,
    required this.color,
    required this.isRecurring,
    this.minExpectedValue,
    this.maxExpectedValue,
    required this.description,
  });
  final String displayName;
  final IconData icon;
  final int color;
  final bool isRecurring;
  final double? minExpectedValue;
  final double? maxExpectedValue;
  final String description;

  Color get colorValue => Color(color);
}

/// Extensions para facilitar o uso das constantes
extension ExpenseTypeExtension on ExpenseType {
  ExpenseTypeProperties get properties => ExpenseConstants.expenseTypeProperties[this] ?? 
      const ExpenseTypeProperties(
        displayName: 'Desconhecido',
        icon: Icons.help,
        color: 0xFF9E9E9E,
        isRecurring: false,
        description: 'Tipo de despesa desconhecido',
      );
  
  String get displayName => properties.displayName;
  IconData get icon => properties.icon;
  Color get color => properties.colorValue;
  bool get isRecurring => properties.isRecurring;
  double? get minExpectedValue => properties.minExpectedValue;
  double? get maxExpectedValue => properties.maxExpectedValue;
  String get description => properties.description;
}
