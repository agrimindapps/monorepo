import 'package:cloud_firestore/cloud_firestore.dart' as fs;
import 'package:core/core.dart';

/// Entity para sincronização de Expenses com Firebase
class ExpenseEntity extends BaseSyncEntity {
  final String? firebaseId;
  final int animalId;
  final String title;
  final String description;
  final double amount;
  final String category;
  final String paymentMethod;
  final DateTime expenseDate;
  final String? veterinaryClinic;
  final String? veterinarianName;
  final String? invoiceNumber;
  final String? notes;
  final String? veterinarian;
  final String? receiptNumber;
  final bool isPaid;
  final bool isRecurring;
  final String? recurrenceType;

  const ExpenseEntity({
    required super.id,
    this.firebaseId,
    required super.userId,
    required this.animalId,
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
    super.createdAt,
    super.updatedAt,
    super.isDeleted = false,
    super.lastSyncAt,
    super.isDirty = false,
    super.version = 1,
    super.moduleName,
  });

  @override
  List<Object?> get props => [
    ...super.props,
    firebaseId,
    animalId,
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
  ];

  @override
  ExpenseEntity copyWith({
    String? id,
    String? firebaseId,
    String? userId,
    int? animalId,
    String? title,
    String? description,
    double? amount,
    String? category,
    String? paymentMethod,
    DateTime? expenseDate,
    String? veterinaryClinic,
    String? veterinarianName,
    String? invoiceNumber,
    String? notes,
    String? veterinarian,
    String? receiptNumber,
    bool? isPaid,
    bool? isRecurring,
    String? recurrenceType,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isDeleted,
    DateTime? lastSyncAt,
    bool? isDirty,
    int? version,
    String? moduleName,
  }) {
    return ExpenseEntity(
      id: id ?? this.id,
      firebaseId: firebaseId ?? this.firebaseId,
      userId: userId ?? this.userId,
      animalId: animalId ?? this.animalId,
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
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isDeleted: isDeleted ?? this.isDeleted,
      lastSyncAt: lastSyncAt ?? this.lastSyncAt,
      isDirty: isDirty ?? this.isDirty,
      version: version ?? this.version,
      moduleName: moduleName ?? this.moduleName,
    );
  }

  @override
  ExpenseEntity markAsDirty() => copyWith(isDirty: true);

  @override
  ExpenseEntity markAsSynced({DateTime? syncTime}) => copyWith(
    isDirty: false,
    lastSyncAt: syncTime ?? DateTime.now(),
  );

  @override
  ExpenseEntity markAsDeleted() => copyWith(isDeleted: true, isDirty: true);

  @override
  ExpenseEntity incrementVersion() => copyWith(version: version + 1);

  @override
  ExpenseEntity withUserId(String userId) => copyWith(userId: userId);

  @override
  ExpenseEntity withModule(String moduleName) => copyWith(moduleName: moduleName);

  @override
  Map<String, dynamic> toFirebaseMap() => toFirestore();

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'animalId': animalId,
      'title': title,
      'description': description,
      'amount': amount,
      'category': category,
      'paymentMethod': paymentMethod,
      'expenseDate': fs.Timestamp.fromDate(expenseDate),
      'veterinaryClinic': veterinaryClinic,
      'veterinarianName': veterinarianName,
      'invoiceNumber': invoiceNumber,
      'notes': notes,
      'veterinarian': veterinarian,
      'receiptNumber': receiptNumber,
      'isPaid': isPaid,
      'isRecurring': isRecurring,
      'recurrenceType': recurrenceType,
      'createdAt': createdAt != null ? fs.Timestamp.fromDate(createdAt!) : fs.Timestamp.now(),
      'updatedAt': updatedAt != null ? fs.Timestamp.fromDate(updatedAt!) : null,
      'isDeleted': isDeleted,
      'lastSyncAt': fs.Timestamp.now(),
      'version': version,
    };
  }

  factory ExpenseEntity.fromFirestore(
    Map<String, dynamic> data,
    String documentId,
  ) {
    return ExpenseEntity(
      id: data['localId'] as String? ?? documentId,
      firebaseId: documentId,
      userId: data['userId'] as String? ?? '',
      animalId: data['animalId'] as int,
      title: data['title'] as String,
      description: data['description'] as String,
      amount: (data['amount'] as num).toDouble(),
      category: data['category'] as String,
      paymentMethod: data['paymentMethod'] as String,
      expenseDate: (data['expenseDate'] as fs.Timestamp).toDate(),
      veterinaryClinic: data['veterinaryClinic'] as String?,
      veterinarianName: data['veterinarianName'] as String?,
      invoiceNumber: data['invoiceNumber'] as String?,
      notes: data['notes'] as String?,
      veterinarian: data['veterinarian'] as String?,
      receiptNumber: data['receiptNumber'] as String?,
      isPaid: data['isPaid'] as bool? ?? true,
      isRecurring: data['isRecurring'] as bool? ?? false,
      recurrenceType: data['recurrenceType'] as String?,
      createdAt: (data['createdAt'] as fs.Timestamp?)?.toDate(),
      updatedAt: (data['updatedAt'] as fs.Timestamp?)?.toDate(),
      isDeleted: data['isDeleted'] as bool? ?? false,
      lastSyncAt: (data['lastSyncAt'] as fs.Timestamp?)?.toDate(),
      isDirty: false,
      version: data['version'] as int? ?? 1,
    );
  }
}
