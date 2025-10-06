import 'package:core/core.dart' show Equatable;

import '../../../vehicles/domain/entities/vehicle_entity.dart';
import '../../domain/entities/expense_entity.dart';

/// Estado imutável do formulário de despesas para Riverpod
class ExpenseFormState extends Equatable {
  const ExpenseFormState({
    this.id = '',
    this.userId = '',
    this.vehicleId = '',
    this.vehicle,
    this.expenseType = ExpenseType.other,
    this.description = '',
    this.amount = 0.0,
    this.odometer = 0.0,
    this.date,
    this.location = '',
    this.notes = '',
    this.receiptImagePath,
    this.receiptImageUrl,
    this.isLoading = false,
    this.isUploadingImage = false,
    this.hasChanges = false,
    this.errorMessage,
    this.imageUploadError,
    this.fieldErrors = const {},
  });

  /// Estado inicial para nova despesa
  factory ExpenseFormState.initial({
    required String vehicleId,
    required String userId,
  }) {
    return ExpenseFormState(
      vehicleId: vehicleId,
      userId: userId,
      date: DateTime.now(),
    );
  }

  /// Estado a partir de despesa existente (edição)
  factory ExpenseFormState.fromExpense(ExpenseEntity expense) {
    return ExpenseFormState(
      id: expense.id,
      userId: expense.userId ?? '',
      vehicleId: expense.vehicleId,
      expenseType: expense.type,
      description: expense.description,
      amount: expense.amount,
      odometer: expense.odometer,
      date: expense.date,
      location: expense.location ?? '',
      notes: expense.notes ?? '',
      receiptImagePath: expense.receiptImagePath,
    );
  }

  final String id;
  final String userId;
  final String vehicleId;
  final VehicleEntity? vehicle;
  final ExpenseType expenseType;
  final String description;
  final double amount;
  final double odometer;
  final DateTime? date;
  final String location;
  final String notes;
  final String? receiptImagePath;
  final String? receiptImageUrl;
  final bool isLoading;
  final bool isUploadingImage;
  final bool hasChanges;
  final String? errorMessage;
  final String? imageUploadError;
  final Map<String, String> fieldErrors;

  @override
  List<Object?> get props => [
    id,
    userId,
    vehicleId,
    vehicle,
    expenseType,
    description,
    amount,
    odometer,
    date,
    location,
    notes,
    receiptImagePath,
    receiptImageUrl,
    isLoading,
    isUploadingImage,
    hasChanges,
    errorMessage,
    imageUploadError,
    fieldErrors,
  ];

  // ==================== Computed Properties ====================

  /// Verifica se tem comprovante (local ou remoto)
  bool get hasReceiptImage =>
      receiptImagePath != null || receiptImageUrl != null;

  /// Verifica se está em algum estado de loading
  bool get isProcessing => isLoading || isUploadingImage;

  /// Verifica se tem dados mínimos válidos
  bool get hasMinimumData =>
      vehicleId.isNotEmpty &&
      description.trim().isNotEmpty &&
      amount > 0 &&
      odometer >= 0;

  /// Verifica se tem erros de validação
  bool get hasErrors => fieldErrors.isNotEmpty;

  /// Verifica se o formulário pode ser submetido
  bool get canSubmit => hasMinimumData && !hasErrors && !isProcessing;

  /// Verifica se é edição (tem ID)
  bool get isEditing => id.isNotEmpty;

  /// Verifica se é despesa de alto valor
  bool get isHighValue => amount >= 500.0;

  /// Retorna mensagem de erro de um campo específico
  String? getFieldError(String field) => fieldErrors[field];

  /// Verifica se um campo tem erro
  bool hasFieldError(String field) => fieldErrors.containsKey(field);

  // ==================== CopyWith Methods ====================

  ExpenseFormState copyWith({
    String? id,
    String? userId,
    String? vehicleId,
    VehicleEntity? vehicle,
    ExpenseType? expenseType,
    String? description,
    double? amount,
    double? odometer,
    DateTime? date,
    String? location,
    String? notes,
    String? receiptImagePath,
    String? receiptImageUrl,
    bool? isLoading,
    bool? isUploadingImage,
    bool? hasChanges,
    String? Function()? errorMessage,
    String? Function()? imageUploadError,
    Map<String, String>? fieldErrors,
    bool clearReceiptImage = false,
    bool clearReceiptUrl = false,
  }) {
    return ExpenseFormState(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      vehicleId: vehicleId ?? this.vehicleId,
      vehicle: vehicle ?? this.vehicle,
      expenseType: expenseType ?? this.expenseType,
      description: description ?? this.description,
      amount: amount ?? this.amount,
      odometer: odometer ?? this.odometer,
      date: date ?? this.date,
      location: location ?? this.location,
      notes: notes ?? this.notes,
      receiptImagePath:
          clearReceiptImage
              ? null
              : (receiptImagePath ?? this.receiptImagePath),
      receiptImageUrl:
          clearReceiptUrl ? null : (receiptImageUrl ?? this.receiptImageUrl),
      isLoading: isLoading ?? this.isLoading,
      isUploadingImage: isUploadingImage ?? this.isUploadingImage,
      hasChanges: hasChanges ?? this.hasChanges,
      errorMessage: errorMessage != null ? errorMessage() : this.errorMessage,
      imageUploadError:
          imageUploadError != null ? imageUploadError() : this.imageUploadError,
      fieldErrors: fieldErrors ?? this.fieldErrors,
    );
  }

  /// Limpa erro geral
  ExpenseFormState clearError() {
    return copyWith(errorMessage: () => null);
  }

  /// Limpa erro de upload de imagem
  ExpenseFormState clearImageError() {
    return copyWith(imageUploadError: () => null);
  }

  /// Define erro em um campo específico
  ExpenseFormState setFieldError(String field, String error) {
    final newErrors = Map<String, String>.from(fieldErrors);
    newErrors[field] = error;
    return copyWith(fieldErrors: newErrors);
  }

  /// Remove erro de um campo específico
  ExpenseFormState clearFieldError(String field) {
    if (!fieldErrors.containsKey(field)) return this;

    final newErrors = Map<String, String>.from(fieldErrors);
    newErrors.remove(field);
    return copyWith(fieldErrors: newErrors);
  }

  /// Limpa todos os erros de campos
  ExpenseFormState clearAllFieldErrors() {
    return copyWith(fieldErrors: const {});
  }

  /// Marca formulário como alterado
  ExpenseFormState markAsChanged() {
    return copyWith(hasChanges: true);
  }
}
