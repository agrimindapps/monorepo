import 'package:equatable/equatable.dart';

/// Entidade de despesa do veículo
class ExpenseEntity extends Equatable {
  final String id;
  final String userId;
  final String vehicleId;
  final ExpenseType type;
  final String description;
  final double amount;
  final DateTime date;
  final double odometer;
  final String? receiptImagePath;
  final String? location;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Map<String, dynamic> metadata;

  const ExpenseEntity({
    required this.id,
    required this.userId,
    required this.vehicleId,
    required this.type,
    required this.description,
    required this.amount,
    required this.date,
    required this.odometer,
    this.receiptImagePath,
    this.location,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
    this.metadata = const {},
  });

  @override
  List<Object?> get props => [
        id,
        userId,
        vehicleId,
        type,
        description,
        amount,
        date,
        odometer,
        receiptImagePath,
        location,
        notes,
        createdAt,
        updatedAt,
        metadata,
      ];

  /// Cria nova instância com valores atualizados
  ExpenseEntity copyWith({
    String? id,
    String? userId,
    String? vehicleId,
    ExpenseType? type,
    String? description,
    double? amount,
    DateTime? date,
    double? odometer,
    String? receiptImagePath,
    String? location,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
    Map<String, dynamic>? metadata,
  }) {
    return ExpenseEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      vehicleId: vehicleId ?? this.vehicleId,
      type: type ?? this.type,
      description: description ?? this.description,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      odometer: odometer ?? this.odometer,
      receiptImagePath: receiptImagePath ?? this.receiptImagePath,
      location: location ?? this.location,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      metadata: metadata ?? this.metadata,
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
}

/// Enum para tipos de despesa
enum ExpenseType {
  insurance('Seguro', 'security', true),
  ipva('IPVA', 'description', true),
  parking('Estacionamento', 'local_parking', false),
  carWash('Lavagem', 'local_car_wash', false),
  fine('Multa', 'report_problem', false),
  toll('Pedágio', 'toll', false),
  licensing('Licenciamento', 'assignment', true),
  accessories('Acessórios', 'shopping_bag', false),
  documentation('Documentação', 'folder', false),
  other('Outro', 'attach_money', false);

  const ExpenseType(this.displayName, this.iconName, this.isRecurring);

  final String displayName;
  final String iconName;
  final bool isRecurring;

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