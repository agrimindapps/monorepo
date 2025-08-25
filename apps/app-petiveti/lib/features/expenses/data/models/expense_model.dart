import '../../domain/entities/expense.dart';

class ExpenseModel extends Expense {
  const ExpenseModel({
    required super.id,
    required super.animalId,
    required super.userId,
    required super.title,
    required super.description,
    required super.amount,
    required super.category,
    required super.paymentMethod,
    required super.expenseDate,
    super.veterinaryClinic,
    super.veterinarianName,
    super.invoiceNumber,
    super.attachments,
    super.metadata,
    required super.createdAt,
    required super.updatedAt,
  });

  factory ExpenseModel.fromMap(Map<String, dynamic> map) {
    return ExpenseModel(
      id: map['id']?.toString() ?? '',
      animalId: map['animalId']?.toString() ?? '',
      userId: map['userId']?.toString() ?? '',
      title: map['title']?.toString() ?? '',
      description: map['description']?.toString() ?? '',
      amount: ((map['amount'] ?? 0) as num).toDouble(),
      category: ExpenseCategory.values.firstWhere(
        (e) => e.toString() == 'ExpenseCategory.${map['category']}',
        orElse: () => ExpenseCategory.other,
      ),
      paymentMethod: PaymentMethod.values.firstWhere(
        (e) => e.toString() == 'PaymentMethod.${map['paymentMethod']}',
        orElse: () => PaymentMethod.cash,
      ),
      expenseDate: DateTime.fromMillisecondsSinceEpoch((map['expenseDate'] as int?) ?? 0),
      veterinaryClinic: map['veterinaryClinic']?.toString(),
      veterinarianName: map['veterinarianName']?.toString(),
      invoiceNumber: map['invoiceNumber']?.toString(),
      attachments: map['attachments'] != null 
          ? List<String>.from(map['attachments'] as Iterable)
          : [],
      metadata: map['metadata'] != null 
          ? Map<String, dynamic>.from(map['metadata'] as Map)
          : null,
      createdAt: DateTime.fromMillisecondsSinceEpoch((map['createdAt'] as int?) ?? 0),
      updatedAt: DateTime.fromMillisecondsSinceEpoch((map['updatedAt'] as int?) ?? 0),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'animalId': animalId,
      'userId': userId,
      'title': title,
      'description': description,
      'amount': amount,
      'category': category.toString().split('.').last,
      'paymentMethod': paymentMethod.toString().split('.').last,
      'expenseDate': expenseDate.millisecondsSinceEpoch,
      'veterinaryClinic': veterinaryClinic,
      'veterinarianName': veterinarianName,
      'invoiceNumber': invoiceNumber,
      'attachments': attachments,
      'metadata': metadata,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
    };
  }

  factory ExpenseModel.fromEntity(Expense expense) {
    return ExpenseModel(
      id: expense.id,
      animalId: expense.animalId,
      userId: expense.userId,
      title: expense.title,
      description: expense.description,
      amount: expense.amount,
      category: expense.category,
      paymentMethod: expense.paymentMethod,
      expenseDate: expense.expenseDate,
      veterinaryClinic: expense.veterinaryClinic,
      veterinarianName: expense.veterinarianName,
      invoiceNumber: expense.invoiceNumber,
      attachments: expense.attachments,
      metadata: expense.metadata,
      createdAt: expense.createdAt,
      updatedAt: expense.updatedAt,
    );
  }

  @override
  ExpenseModel copyWith({
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
    List<String>? attachments,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ExpenseModel(
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
      attachments: attachments ?? this.attachments,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}