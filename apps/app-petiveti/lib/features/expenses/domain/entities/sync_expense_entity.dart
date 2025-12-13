import 'package:cloud_firestore/cloud_firestore.dart' as fs;
import 'package:equatable/equatable.dart';

/// Entity para sincronização de Expenses com Firebase
class ExpenseEntity extends Equatable {
  final String? id; // Local ID
  final String? firebaseId;
  final String userId;
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

  // Metadata
  final DateTime createdAt;
  final DateTime? updatedAt;
  final bool isDeleted;

  // Sync fields
  final DateTime? lastSyncAt;
  final bool isDirty;
  final int version;

  const ExpenseEntity({
    this.id,
    this.firebaseId,
    required this.userId,
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
    required this.createdAt,
    this.updatedAt,
    this.isDeleted = false,
    this.lastSyncAt,
    this.isDirty = false,
    this.version = 1,
  });

  @override
  List<Object?> get props => [
    id,
    firebaseId,
    userId,
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
    createdAt,
    updatedAt,
    isDeleted,
    lastSyncAt,
    isDirty,
    version,
  ];

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
      'createdAt': fs.Timestamp.fromDate(createdAt),
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
      id: null,
      firebaseId: documentId,
      userId: data['userId'] as String,
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
      createdAt: (data['createdAt'] as fs.Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as fs.Timestamp?)?.toDate(),
      isDeleted: data['isDeleted'] as bool? ?? false,
      lastSyncAt: (data['lastSyncAt'] as fs.Timestamp?)?.toDate(),
      isDirty: false,
      version: data['version'] as int? ?? 1,
    );
  }
}
