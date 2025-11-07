import 'package:flutter/material.dart';
import '../../domain/entities/maintenance_entity.dart';

/// Constantes organizadas para o módulo de manutenção
class MaintenanceConstants {
  
  MaintenanceConstants._();
  static const double minCost = 0.01;
  static const double maxCost = 999999.99;
  static const double maxOdometer = 9999999.0;
  static const double preventiveMinExpected = 50.0;
  static const double preventiveMaxExpected = 5000.0;
  static const double correctiveMaxExpected = 15000.0;
  static const double inspectionMinExpected = 100.0;
  static const double inspectionMaxExpected = 1000.0;
  static const double emergencyMaxExpected = 20000.0;
  static const String decimalSeparator = ',';
  static const String dotSeparator = '.';
  static const String thousandSeparator = '.';
  static const String currencySymbol = 'R\$';
  static const int amountDecimals = 2;
  static const int odometerDecimals = 1;
  static const int maxYearsBack = 5;
  static const int maxYearsForward = 3;
  static const int maxTitleLength = 100;
  static const int minTitleLength = 3;
  static const int maxDescriptionLength = 500;
  static const int minDescriptionLength = 5;
  static const int maxWorkshopNameLength = 100;
  static const int minWorkshopNameLength = 2;
  static const int maxAddressLength = 200;
  static const int minAddressLength = 10;
  static const int maxNotesLength = 1000;
  static const double maxOdometerDifference = 50000.0; // Diferença máxima entre manutenções
  static const double maxNextServiceInterval = 100000.0; // Intervalo máximo para próxima manutenção
  static const double typicalPreventiveInterval = 10000.0; // Intervalo típico para preventiva
  static const double typicalInspectionInterval = 20000.0; // Intervalo típico para revisão
  static const int maxCacheSize = 100;
  static const int costDebounceMs = 300;
  static const int odometerDebounceMs = 200;
  static const int descriptionDebounceMs = 500;
  static const int titleDebounceMs = 400;
  static const String costPattern = r'^\d{0,8}[,.]?\d{0,2}$';
  static const String odometerPattern = r'^\d{0,6}[,.]?\d{0,1}$';
  static const String titlePattern = r'^[a-zA-ZÀ-ÿ0-9\s\-\.\,\(\)]+$';
  static const String phonePattern = r'^\(\d{2}\)\s\d{4,5}-\d{4}$';
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
  static const String currencyUnit = 'R\$';
  static const Map<MaintenanceType, MaintenanceTypeProperties> typeProperties = {
    MaintenanceType.preventive: MaintenanceTypeProperties(
      displayName: 'Preventiva',
      icon: Icons.build_circle,
      color: 0xFF4CAF50,
      isRecurring: true,
      minExpectedValue: preventiveMinExpected,
      maxExpectedValue: preventiveMaxExpected,
      description: 'Manutenção programada para prevenir problemas',
      typicalInterval: typicalPreventiveInterval,
    ),
    MaintenanceType.corrective: MaintenanceTypeProperties(
      displayName: 'Corretiva',
      icon: Icons.build,
      color: 0xFFFF9800,
      isRecurring: false,
      maxExpectedValue: correctiveMaxExpected,
      description: 'Reparo de problema identificado',
    ),
    MaintenanceType.inspection: MaintenanceTypeProperties(
      displayName: 'Revisão',
      icon: Icons.fact_check,
      color: 0xFF2196F3,
      isRecurring: true,
      minExpectedValue: inspectionMinExpected,
      maxExpectedValue: inspectionMaxExpected,
      description: 'Revisão geral do veículo',
      typicalInterval: typicalInspectionInterval,
    ),
    MaintenanceType.emergency: MaintenanceTypeProperties(
      displayName: 'Emergencial',
      icon: Icons.warning,
      color: 0xFFF44336,
      isRecurring: false,
      maxExpectedValue: emergencyMaxExpected,
      description: 'Reparo urgente e imprevisto',
    ),
  };
  static const Map<MaintenanceStatus, MaintenanceStatusProperties> statusProperties = {
    MaintenanceStatus.pending: MaintenanceStatusProperties(
      displayName: 'Pendente',
      icon: Icons.schedule,
      color: 0xFFFF9800,
      description: 'Manutenção agendada',
    ),
    MaintenanceStatus.inProgress: MaintenanceStatusProperties(
      displayName: 'Em Andamento',
      icon: Icons.build,
      color: 0xFF2196F3,
      description: 'Manutenção sendo executada',
    ),
    MaintenanceStatus.completed: MaintenanceStatusProperties(
      displayName: 'Concluída',
      icon: Icons.check_circle,
      color: 0xFF4CAF50,
      description: 'Manutenção finalizada com sucesso',
    ),
    MaintenanceStatus.cancelled: MaintenanceStatusProperties(
      displayName: 'Cancelada',
      icon: Icons.cancel,
      color: 0xFF9E9E9E,
      description: 'Manutenção cancelada',
    ),
  };
  static const String formStatusIdle = 'idle';
  static const String formStatusLoading = 'loading';
  static const String formStatusError = 'error';
  static const String formStatusSuccess = 'success';
  static const double formMaxHeight = 750.0;
  static const double sectionSpacing = 20.0;
  static const double fieldSpacing = 14.0;
  static const double buttonHeight = 48.0;
  static const double cardBorderRadius = 12.0;
  static const int animationDurationMs = 250;
  static const int loadingMinDurationMs = 500;
  static const String basicInfoSectionTitle = 'Informações Básicas';
  static const String workshopSectionTitle = 'Dados da Oficina';
  static const String nextServiceSectionTitle = 'Próxima Manutenção';
  static const String attachmentsSectionTitle = 'Anexos e Observações';
  static const String titlePlaceholder = 'Ex: Troca de óleo e filtro';
  static const String descriptionPlaceholder = 'Descreva detalhadamente a manutenção realizada...';
  static const String costPlaceholder = '0,00';
  static const String odometerPlaceholder = '0,0';
  static const String workshopNamePlaceholder = 'Nome da oficina ou mecânico';
  static const String workshopPhonePlaceholder = '(11) 99999-9999';
  static const String workshopAddressPlaceholder = 'Endereço completo da oficina';
  static const String notesPlaceholder = 'Observações adicionais sobre a manutenção...';
  static const String typeLabel = 'Tipo de Manutenção *';
  static const String statusLabel = 'Status';
  static const String titleLabel = 'Título/Nome *';
  static const String descriptionLabel = 'Descrição *';
  static const String costLabel = 'Valor *';
  static const String serviceDateLabel = 'Data do Serviço *';
  static const String odometerLabel = 'Odômetro *';
  static const String workshopNameLabel = 'Nome da Oficina';
  static const String workshopPhoneLabel = 'Telefone';
  static const String workshopAddressLabel = 'Endereço';
  static const String nextServiceDateLabel = 'Data da Próxima';
  static const String nextServiceOdometerLabel = 'Odômetro da Próxima';
  static const String notesLabel = 'Observações';
  static const String datePattern = 'dd/MM/yyyy';
  static const String timePattern = 'HH:mm';
  static const String dateTimePattern = 'dd/MM/yyyy HH:mm';
  static const double reportCostThousands = 1000.0;
  static const double reportCostTenThousands = 10000.0;
  static const Map<String, UrgencyProperties> urgencyProperties = {
    'overdue': UrgencyProperties(
      displayName: 'Vencida',
      color: 0xFFF44336,
      icon: Icons.error,
      priority: 4,
    ),
    'urgent': UrgencyProperties(
      displayName: 'Urgente',
      color: 0xFFFF5722,
      icon: Icons.priority_high,
      priority: 3,
    ),
    'soon': UrgencyProperties(
      displayName: 'Em Breve',
      color: 0xFFFF9800,
      icon: Icons.schedule,
      priority: 2,
    ),
    'normal': UrgencyProperties(
      displayName: 'Normal',
      color: 0xFF4CAF50,
      icon: Icons.check_circle,
      priority: 1,
    ),
  }; // Previne instanciação
}

/// Classe para propriedades específicas de cada tipo de manutenção
class MaintenanceTypeProperties {

  const MaintenanceTypeProperties({
    required this.displayName,
    required this.icon,
    required this.color,
    required this.isRecurring,
    this.minExpectedValue,
    this.maxExpectedValue,
    required this.description,
    this.typicalInterval,
  });
  final String displayName;
  final IconData icon;
  final int color;
  final bool isRecurring;
  final double? minExpectedValue;
  final double? maxExpectedValue;
  final String description;
  final double? typicalInterval;

  Color get colorValue => Color(color);
}

/// Classe para propriedades específicas de cada status
class MaintenanceStatusProperties {

  const MaintenanceStatusProperties({
    required this.displayName,
    required this.icon,
    required this.color,
    required this.description,
  });
  final String displayName;
  final IconData icon;
  final int color;
  final String description;

  Color get colorValue => Color(color);
}

/// Classe para propriedades de urgência
class UrgencyProperties {

  const UrgencyProperties({
    required this.displayName,
    required this.color,
    required this.icon,
    required this.priority,
  });
  final String displayName;
  final int color;
  final IconData icon;
  final int priority;

  Color get colorValue => Color(color);
}

/// Extensions para facilitar o uso das constantes
extension MaintenanceTypeExtension on MaintenanceType {
  MaintenanceTypeProperties get properties => MaintenanceConstants.typeProperties[this]!;
  
  String get displayName => properties.displayName;
  IconData get icon => properties.icon;
  Color get color => properties.colorValue;
  bool get isRecurring => properties.isRecurring;
  double? get minExpectedValue => properties.minExpectedValue;
  double? get maxExpectedValue => properties.maxExpectedValue;
  String get description => properties.description;
  double? get typicalInterval => properties.typicalInterval;
}

extension MaintenanceStatusExtension on MaintenanceStatus {
  MaintenanceStatusProperties get properties => MaintenanceConstants.statusProperties[this]!;
  
  String get displayName => properties.displayName;
  IconData get icon => properties.icon;
  Color get color => properties.colorValue;
  String get description => properties.description;
}
