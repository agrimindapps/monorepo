import 'package:equatable/equatable.dart';

enum ExpenseCategory {
  consultation,
  medication,
  vaccine,
  surgery,
  exam,
  food,
  accessory,
  grooming,
  insurance,
  emergency,
  other,
}

enum PaymentMethod {
  cash,
  creditCard,
  debitCard,
  pix,
  bankTransfer,
  insurance,
  other,
}

enum RecurrenceType {
  weekly,
  monthly,
  yearly,
}

class Expense extends Equatable {
  final String id;
  final String animalId;
  final String userId;
  final String title;
  final String description;
  final double amount;
  final ExpenseCategory category;
  final PaymentMethod paymentMethod;
  final DateTime expenseDate;
  final String? veterinaryClinic;
  final String? veterinarianName;
  final String? invoiceNumber;
  final String? notes;
  final String? veterinarian;
  final String? receiptNumber;
  final bool isPaid;
  final bool isRecurring;
  final RecurrenceType? recurrenceType;
  final bool isDeleted;
  final List<String> attachments;
  final Map<String, dynamic>? metadata;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Expense({
    required this.id,
    required this.animalId,
    required this.userId,
    required this.title,
    required this.description,
    required this.amount,
    required this.category,
    required this.paymentMethod,
    required this.expenseDate,
    this.veterinaryClinic,
    this.veterinarianName,
    this.invoiceNumber,
    this.notes,
    this.veterinarian,
    this.receiptNumber,
    this.isPaid = true,
    this.isRecurring = false,
    this.recurrenceType,
    this.isDeleted = false,
    this.attachments = const [],
    this.metadata,
    required this.createdAt,
    required this.updatedAt,
  });

  Expense copyWith({
    String? id,
    String? animalId,
    String? userId,
    String? title,
    String? description,
    double? amount,
    ExpenseCategory? category,
    PaymentMethod? paymentMethod,
    DateTime? expenseDate,
    String? veterinaryClinic,
    String? veterinarianName,
    String? invoiceNumber,
    String? notes,
    String? veterinarian,
    String? receiptNumber,
    bool? isPaid,
    bool? isRecurring,
    RecurrenceType? recurrenceType,
    bool? isDeleted,
    List<String>? attachments,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Expense(
      id: id ?? this.id,
      animalId: animalId ?? this.animalId,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      description: description ?? this.description,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      expenseDate: expenseDate ?? this.expenseDate,
      veterinaryClinic: veterinaryClinic ?? this.veterinaryClinic,
      veterinarianName: veterinarianName ?? this.veterinarianName,
      invoiceNumber: invoiceNumber ?? this.invoiceNumber,
      notes: notes ?? this.notes,
      veterinarian: veterinarian ?? this.veterinarian,
      receiptNumber: receiptNumber ?? this.receiptNumber,
      isPaid: isPaid ?? this.isPaid,
      isRecurring: isRecurring ?? this.isRecurring,
      recurrenceType: recurrenceType ?? this.recurrenceType,
      isDeleted: isDeleted ?? this.isDeleted,
      attachments: attachments ?? this.attachments,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  bool get isCurrentMonth {
    final now = DateTime.now();
    return expenseDate.year == now.year && expenseDate.month == now.month;
  }

  bool get isCurrentYear {
    final now = DateTime.now();
    return expenseDate.year == now.year;
  }

  bool get hasAttachments => attachments.isNotEmpty;

  @override
  List<Object?> get props => [
        id,
        animalId,
        userId,
        title,
        description,
        amount,
        category,
        paymentMethod,
        expenseDate,
        veterinaryClinic,
        veterinarianName,
        invoiceNumber,
        notes,
        veterinarian,
        receiptNumber,
        isPaid,
        isRecurring,
        recurrenceType,
        isDeleted,
        attachments,
        metadata,
        createdAt,
        updatedAt,
      ];
}