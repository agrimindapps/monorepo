import 'package:equatable/equatable.dart';

import '../../../../core/services/input_sanitizer.dart';
import '../../../vehicles/domain/entities/vehicle_entity.dart';
import '../../domain/entities/expense_entity.dart';

/// Model reativo para o formulário de despesas
class ExpenseFormModel extends Equatable {
  final String id;
  final String userId;
  final String vehicleId;
  final VehicleEntity? vehicle;
  final ExpenseType expenseType;
  final String description;
  final double amount;
  final double odometer;
  final DateTime date;
  final String location;
  final String notes;
  final String? receiptImagePath;
  final bool isLoading;
  final bool hasChanges;
  final Map<String, String> errors;
  final String? lastError;

  const ExpenseFormModel({
    required this.id,
    required this.userId,
    required this.vehicleId,
    this.vehicle,
    required this.expenseType,
    required this.description,
    required this.amount,
    required this.odometer,
    required this.date,
    required this.location,
    required this.notes,
    this.receiptImagePath,
    this.isLoading = false,
    this.hasChanges = false,
    this.errors = const {},
    this.lastError,
  });

  /// Cria modelo inicial para nova despesa
  factory ExpenseFormModel.initial(String vehicleId, String userId) {
    return ExpenseFormModel(
      id: '',
      userId: userId,
      vehicleId: vehicleId,
      vehicle: null,
      expenseType: ExpenseType.other,
      description: '',
      amount: 0.0,
      odometer: 0.0,
      date: DateTime.now(),
      location: '',
      notes: '',
      receiptImagePath: null,
      isLoading: false,
      hasChanges: false,
      errors: const {},
      lastError: null,
    );
  }

  /// Cria modelo a partir de uma despesa existente para edição
  factory ExpenseFormModel.fromExpenseEntity(ExpenseEntity expense) {
    return ExpenseFormModel(
      id: expense.id,
      userId: expense.userId,
      vehicleId: expense.vehicleId,
      vehicle: null, // Será carregado separadamente
      expenseType: expense.type,
      description: expense.description,
      amount: expense.amount,
      odometer: expense.odometer,
      date: expense.date,
      location: expense.location ?? '',
      notes: expense.notes ?? '',
      receiptImagePath: expense.receiptImagePath,
      isLoading: false,
      hasChanges: false,
      errors: const {},
      lastError: null,
    );
  }

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
        isLoading,
        hasChanges,
        errors,
        lastError,
      ];

  /// Cria nova instância com valores atualizados
  ExpenseFormModel copyWith({
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
    bool clearReceiptImage = false,
    bool? isLoading,
    bool? hasChanges,
    Map<String, String>? errors,
    String? lastError,
    bool clearLastError = false,
  }) {
    return ExpenseFormModel(
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
      receiptImagePath: clearReceiptImage ? null : (receiptImagePath ?? this.receiptImagePath),
      isLoading: isLoading ?? this.isLoading,
      hasChanges: hasChanges ?? this.hasChanges,
      errors: errors ?? this.errors,
      lastError: clearLastError ? null : (lastError ?? this.lastError),
    );
  }

  /// Verifica se o modelo tem dados válidos mínimos
  bool get hasMinimumData => 
      vehicleId.isNotEmpty && 
      description.trim().isNotEmpty && 
      amount > 0 &&
      odometer >= 0;

  /// Verifica se há erros de validação
  bool get hasErrors => errors.isNotEmpty;

  /// Verifica se o formulário está pronto para ser submetido
  bool get canSubmit => 
      hasMinimumData && 
      !hasErrors && 
      !isLoading;

  /// Verifica se é uma edição (tem ID)
  bool get isEditing => id.isNotEmpty;

  /// Verifica se tem comprovante
  bool get hasReceipt => receiptImagePath != null && receiptImagePath!.isNotEmpty;

  /// Verifica se é uma despesa de alto valor
  bool get isHighValue => amount >= 500.0;

  /// Verifica se é uma despesa recorrente
  bool get isRecurring => expenseType.isRecurring;

  /// Retorna mensagem de erro para um campo específico
  String? getFieldError(String field) => errors[field];

  /// Verifica se um campo específico tem erro
  bool hasFieldError(String field) => errors.containsKey(field);

  /// Adiciona erro para um campo específico
  ExpenseFormModel setFieldError(String field, String error) {
    final newErrors = Map<String, String>.from(errors);
    newErrors[field] = error;
    return copyWith(errors: newErrors);
  }

  /// Remove erro de um campo específico
  ExpenseFormModel clearFieldError(String field) {
    if (!errors.containsKey(field)) return this;
    
    final newErrors = Map<String, String>.from(errors);
    newErrors.remove(field);
    return copyWith(errors: newErrors);
  }

  /// Limpa todos os erros
  ExpenseFormModel clearAllErrors() {
    return copyWith(errors: const {});
  }

  /// Marca o formulário como tendo alterações
  ExpenseFormModel markAsChanged() {
    return copyWith(hasChanges: true);
  }

  /// Valida todos os campos e retorna mapa de erros
  Map<String, String> validate() {
    final validationErrors = <String, String>{};

    // Validar veículo
    if (vehicleId.isEmpty) {
      validationErrors['vehicleId'] = 'Veículo é obrigatório';
    }

    // Validar descrição
    if (description.trim().isEmpty) {
      validationErrors['description'] = 'Descrição é obrigatória';
    } else if (description.trim().length < 3) {
      validationErrors['description'] = 'Descrição muito curta (mínimo 3 caracteres)';
    } else if (description.trim().length > 100) {
      validationErrors['description'] = 'Descrição muito longa (máximo 100 caracteres)';
    }

    // Validar valor
    if (amount <= 0) {
      validationErrors['amount'] = 'Valor deve ser maior que zero';
    } else if (amount > 999999.99) {
      validationErrors['amount'] = 'Valor muito alto';
    }

    // Validar odômetro
    if (odometer < 0) {
      validationErrors['odometer'] = 'Odômetro não pode ser negativo';
    } else if (odometer > 9999999) {
      validationErrors['odometer'] = 'Valor muito alto';
    }

    // Validar data
    final now = DateTime.now();
    if (date.isAfter(now)) {
      validationErrors['date'] = 'Data não pode ser futura';
    }

    // Validar localização (opcional)
    if (location.trim().isNotEmpty) {
      if (location.trim().length < 2) {
        validationErrors['location'] = 'Localização muito curta';
      } else if (location.trim().length > 100) {
        validationErrors['location'] = 'Localização muito longa';
      }
    }

    // Validar observações (opcional)
    if (notes.trim().isNotEmpty && notes.trim().length > 300) {
      validationErrors['notes'] = 'Observação muito longa (máximo 300 caracteres)';
    }

    return validationErrors;
  }

  /// Converte para ExpenseEntity para persistência
  /// Aplica sanitização em todos os campos de texto para segurança
  ExpenseEntity toExpenseEntity() {
    final now = DateTime.now();
    
    // Sanitizar todos os campos de texto antes da persistência
    final sanitizedDescription = InputSanitizer.sanitizeDescription(description);
    final sanitizedLocation = location.trim().isEmpty 
        ? null 
        : InputSanitizer.sanitize(location);
    final sanitizedNotes = notes.trim().isEmpty 
        ? null 
        : InputSanitizer.sanitizeDescription(notes);
    
    return ExpenseEntity(
      id: id.isEmpty ? DateTime.now().millisecondsSinceEpoch.toString() : id,
      userId: userId,
      vehicleId: vehicleId,
      type: expenseType,
      description: sanitizedDescription,
      amount: amount,
      date: date,
      odometer: odometer,
      location: sanitizedLocation,
      notes: sanitizedNotes,
      receiptImagePath: receiptImagePath,
      createdAt: id.isEmpty ? now : DateTime.fromMillisecondsSinceEpoch(int.tryParse(id) ?? now.millisecondsSinceEpoch),
      updatedAt: now,
      metadata: const {},
    );
  }

  /// Reseta formulário para estado inicial
  ExpenseFormModel reset() {
    return ExpenseFormModel.initial(vehicleId, userId).copyWith(
      vehicle: vehicle,
    );
  }

  /// Cria cópia limpa sem alterações ou erros
  ExpenseFormModel clean() {
    return copyWith(
      hasChanges: false,
      errors: const {},
      lastError: null,
      clearLastError: true,
    );
  }

  /// Estatísticas do formulário para debug
  Map<String, dynamic> get stats => {
    'isValid': canSubmit,
    'hasErrors': hasErrors,
    'hasChanges': hasChanges,
    'isEditing': isEditing,
    'hasReceipt': hasReceipt,
    'isHighValue': isHighValue,
    'isRecurring': isRecurring,
    'errorCount': errors.length,
  };
}