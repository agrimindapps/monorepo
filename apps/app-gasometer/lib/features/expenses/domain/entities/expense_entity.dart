import 'package:core/core.dart';
import 'package:flutter/material.dart';

/// Entidade de despesa do veículo
class ExpenseEntity extends BaseSyncEntity {
  final String vehicleId;
  final ExpenseType type;
  final String description;
  final double amount;
  final DateTime date;
  final double odometer;
  final String? receiptImagePath;
  final String? location;
  final String? notes;
  final Map<String, dynamic> metadata;

  const ExpenseEntity({
    required String id,
    required this.vehicleId,
    required this.type,
    required this.description,
    required this.amount,
    required this.date,
    required this.odometer,
    this.receiptImagePath,
    this.location,
    this.notes,
    this.metadata = const {},
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastSyncAt,
    bool isDirty = false,
    bool isDeleted = false,
    int version = 1,
    String? userId,
    String? moduleName,
  }) : super(
    id: id,
    createdAt: createdAt,
    updatedAt: updatedAt,
    lastSyncAt: lastSyncAt,
    isDirty: isDirty,
    isDeleted: isDeleted,
    version: version,
    userId: userId,
    moduleName: moduleName,
  );

  @override
  List<Object?> get props => [
        ...super.props,
        vehicleId,
        type,
        description,
        amount,
        date,
        odometer,
        receiptImagePath,
        location,
        notes,
        metadata,
      ];

  /// Cria nova instância com valores atualizados
  @override
  ExpenseEntity copyWith({
    String? id,
    String? vehicleId,
    ExpenseType? type,
    String? description,
    double? amount,
    DateTime? date,
    double? odometer,
    String? receiptImagePath,
    String? location,
    String? notes,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastSyncAt,
    bool? isDirty,
    bool? isDeleted,
    int? version,
    String? userId,
    String? moduleName,
  }) {
    return ExpenseEntity(
      id: id ?? this.id,
      vehicleId: vehicleId ?? this.vehicleId,
      type: type ?? this.type,
      description: description ?? this.description,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      odometer: odometer ?? this.odometer,
      receiptImagePath: receiptImagePath ?? this.receiptImagePath,
      location: location ?? this.location,
      notes: notes ?? this.notes,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastSyncAt: lastSyncAt ?? this.lastSyncAt,
      isDirty: isDirty ?? this.isDirty,
      isDeleted: isDeleted ?? this.isDeleted,
      version: version ?? this.version,
      userId: userId ?? this.userId,
      moduleName: moduleName ?? this.moduleName,
    );
  }

  /// Verifica se tem comprovante/foto
  bool get hasReceipt => receiptImagePath != null && receiptImagePath!.isNotEmpty;

  /// Verifica se tem localização
  bool get hasLocation => location != null && location!.isNotEmpty;

  /// Verifica se tem observações
  bool get hasNotes => notes != null && notes!.isNotEmpty;

  /// Retorna data formatada para exibição
  String get displayDate {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Hoje';
    } else if (difference.inDays == 1) {
      return 'Ontem';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} dias atrás';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return '$weeks ${weeks == 1 ? 'semana' : 'semanas'} atrás';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return '$months ${months == 1 ? 'mês' : 'meses'} atrás';
    } else {
      final years = (difference.inDays / 365).floor();
      return '$years ${years == 1 ? 'ano' : 'anos'} atrás';
    }
  }

  /// Retorna valor formatado como moeda brasileira
  String get formattedAmount => 'R\$ ${amount.toStringAsFixed(2).replaceAll('.', ',')}';

  /// Retorna odômetro formatado
  String get formattedOdometer => '${odometer.toStringAsFixed(0)} km';

  /// Verifica se é uma despesa de alto valor (acima de R$ 500)
  bool get isHighValue => amount >= 500.0;

  /// Verifica se é uma despesa recente (últimos 7 dias)
  bool get isRecent => DateTime.now().difference(date).inDays <= 7;

  /// Verifica se a despesa é do tipo recorrente (seguro, IPVA, etc.)
  bool get isRecurring => type.isRecurring;

  /// Título da despesa para filtros (baseado na descrição)
  String get title => description;

  /// Nome do estabelecimento para filtros (baseado na localização)
  String get establishmentName => location ?? '';

  @override
  Map<String, dynamic> toFirebaseMap() {
    return {
      ...baseFirebaseFields,
      'vehicle_id': vehicleId,
      'type': type.name,
      'description': description,
      'amount': amount,
      'date': date.toIso8601String(),
      'odometer': odometer,
      'receipt_image_path': receiptImagePath,
      'location': location,
      'notes': notes,
      'metadata': metadata,
    };
  }

  static ExpenseEntity fromFirebaseMap(Map<String, dynamic> map) {
    final baseFields = BaseSyncEntity.parseBaseFirebaseFields(map);
    return ExpenseEntity(
      id: baseFields['id'] as String,
      vehicleId: map['vehicle_id'] as String,
      type: ExpenseType.fromString(map['type'] as String),
      description: map['description'] as String,
      amount: (map['amount'] as num).toDouble(),
      date: DateTime.parse(map['date'] as String),
      odometer: (map['odometer'] as num).toDouble(),
      receiptImagePath: map['receipt_image_path'] as String?,
      location: map['location'] as String?,
      notes: map['notes'] as String?,
      metadata: Map<String, dynamic>.from(map['metadata'] as Map? ?? {}),
      createdAt: baseFields['createdAt'] as DateTime?,
      updatedAt: baseFields['updatedAt'] as DateTime?,
      lastSyncAt: baseFields['lastSyncAt'] as DateTime?,
      isDirty: baseFields['isDirty'] as bool,
      isDeleted: baseFields['isDeleted'] as bool,
      version: baseFields['version'] as int,
      userId: baseFields['userId'] as String?,
      moduleName: baseFields['moduleName'] as String?,
    );
  }

  @override
  ExpenseEntity markAsDirty() {
    return copyWith(
      isDirty: true,
      updatedAt: DateTime.now(),
    );
  }

  @override
  ExpenseEntity markAsSynced({DateTime? syncTime}) {
    return copyWith(
      isDirty: false,
      lastSyncAt: syncTime ?? DateTime.now(),
    );
  }

  @override
  ExpenseEntity markAsDeleted() {
    return copyWith(
      isDeleted: true,
      isDirty: true,
      updatedAt: DateTime.now(),
    );
  }

  @override
  ExpenseEntity incrementVersion() {
    return copyWith(
      version: version + 1,
      updatedAt: DateTime.now(),
    );
  }

  @override
  ExpenseEntity withUserId(String userId) {
    return copyWith(userId: userId);
  }

  @override
  ExpenseEntity withModule(String moduleName) {
    return copyWith(moduleName: moduleName);
  }
}

/// Enum para tipos de despesa
enum ExpenseType {
  fuel('Combustível', 'local_gas_station', false, 0xFF2196F3),
  maintenance('Manutenção', 'build', false, 0xFFFF9800),
  insurance('Seguro', 'security', true, 0xFF4CAF50),
  ipva('IPVA', 'description', true, 0xFF9C27B0),
  parking('Estacionamento', 'local_parking', false, 0xFF607D8B),
  carWash('Lavagem', 'local_car_wash', false, 0xFF00BCD4),
  fine('Multa', 'report_problem', false, 0xFFF44336),
  toll('Pedágio', 'toll', false, 0xFF795548),
  licensing('Licenciamento', 'assignment', true, 0xFF3F51B5),
  accessories('Acessórios', 'shopping_bag', false, 0xFFE91E63),
  documentation('Documentação', 'folder', false, 0xFF009688),
  other('Outro', 'attach_money', false, 0xFF757575);

  const ExpenseType(this.displayName, this.iconName, this.isRecurring, this._colorValue);

  final String displayName;
  final String iconName;
  final bool isRecurring;
  final int _colorValue;

  /// Cor associada ao tipo de despesa
  Color get color => Color(_colorValue);

  /// Ícone associado ao tipo de despesa
  IconData get icon => _getIconFromName(iconName);

  /// Função helper para converter nome do ícone em IconData
  static IconData _getIconFromName(String iconName) {
    switch (iconName) {
      case 'local_gas_station':
        return Icons.local_gas_station;
      case 'build':
        return Icons.build;
      case 'security':
        return Icons.security;
      case 'description':
        return Icons.description;
      case 'local_parking':
        return Icons.local_parking;
      case 'local_car_wash':
        return Icons.local_car_wash;
      case 'report_problem':
        return Icons.report_problem;
      case 'toll':
        return Icons.toll;
      case 'assignment':
        return Icons.assignment;
      case 'shopping_bag':
        return Icons.shopping_bag;
      case 'folder':
        return Icons.folder;
      case 'attach_money':
        return Icons.attach_money;
      default:
        return Icons.help_outline;
    }
  }

  /// Converte string para ExpenseType
  static ExpenseType fromString(String value) {
    return ExpenseType.values.firstWhere(
      (type) => type.name == value || type.displayName == value,
      orElse: () => ExpenseType.other,
    );
  }

  /// Retorna lista de tipos ordenados por frequência de uso
  static List<ExpenseType> get orderedByFrequency => [
        ExpenseType.parking,
        ExpenseType.carWash,
        ExpenseType.fine,
        ExpenseType.toll,
        ExpenseType.accessories,
        ExpenseType.insurance,
        ExpenseType.ipva,
        ExpenseType.licensing,
        ExpenseType.documentation,
        ExpenseType.other,
      ];

  /// Retorna lista apenas de tipos recorrentes
  static List<ExpenseType> get recurringTypes =>
      ExpenseType.values.where((type) => type.isRecurring).toList();

  /// Retorna lista apenas de tipos não recorrentes
  static List<ExpenseType> get nonRecurringTypes =>
      ExpenseType.values.where((type) => !type.isRecurring).toList();
}