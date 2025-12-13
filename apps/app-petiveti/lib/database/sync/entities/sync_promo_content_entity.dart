import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

/// Entity for syncing PromoContent with Firestore
class SyncPromoContentEntity extends Equatable {
  final int? id;
  final String? firebaseId;
  final String title;
  final String content;
  final String? imageUrl;
  final String? actionUrl;
  final DateTime? expiryDate;
  final bool isActive;
  final DateTime createdAt;
  final bool isDeleted;
  final DateTime? lastSyncAt;
  final bool isDirty;
  final int version;

  const SyncPromoContentEntity({
    this.id,
    this.firebaseId,
    required this.title,
    required this.content,
    this.imageUrl,
    this.actionUrl,
    this.expiryDate,
    this.isActive = true,
    required this.createdAt,
    this.isDeleted = false,
    this.lastSyncAt,
    this.isDirty = false,
    this.version = 1,
  });

  @override
  List<Object?> get props => [
    id,
    firebaseId,
    title,
    content,
    imageUrl,
    actionUrl,
    expiryDate,
    isActive,
    createdAt,
    isDeleted,
    lastSyncAt,
    isDirty,
    version,
  ];

  /// Convert to Firestore map
  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'content': content,
      'imageUrl': imageUrl,
      'actionUrl': actionUrl,
      'expiryDate': expiryDate != null ? Timestamp.fromDate(expiryDate!) : null,
      'isActive': isActive,
      'createdAt': Timestamp.fromDate(createdAt),
      'isDeleted': isDeleted,
      'lastSyncAt': lastSyncAt != null ? Timestamp.fromDate(lastSyncAt!) : null,
      'isDirty': isDirty,
      'version': version,
    };
  }

  /// Create from Firestore document
  factory SyncPromoContentEntity.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
  ) {
    final data = snapshot.data()!;
    return SyncPromoContentEntity(
      firebaseId: snapshot.id,
      title: data['title'] as String,
      content: data['content'] as String,
      imageUrl: data['imageUrl'] as String?,
      actionUrl: data['actionUrl'] as String?,
      expiryDate: data['expiryDate'] != null
          ? (data['expiryDate'] as Timestamp).toDate()
          : null,
      isActive: data['isActive'] as bool? ?? true,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      isDeleted: data['isDeleted'] as bool? ?? false,
      lastSyncAt: data['lastSyncAt'] != null
          ? (data['lastSyncAt'] as Timestamp).toDate()
          : null,
      isDirty: data['isDirty'] as bool? ?? false,
      version: data['version'] as int? ?? 1,
    );
  }

  SyncPromoContentEntity copyWith({
    int? id,
    String? firebaseId,
    String? title,
    String? content,
    String? imageUrl,
    String? actionUrl,
    DateTime? expiryDate,
    bool? isActive,
    DateTime? createdAt,
    bool? isDeleted,
    DateTime? lastSyncAt,
    bool? isDirty,
    int? version,
  }) {
    return SyncPromoContentEntity(
      id: id ?? this.id,
      firebaseId: firebaseId ?? this.firebaseId,
      title: title ?? this.title,
      content: content ?? this.content,
      imageUrl: imageUrl ?? this.imageUrl,
      actionUrl: actionUrl ?? this.actionUrl,
      expiryDate: expiryDate ?? this.expiryDate,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      isDeleted: isDeleted ?? this.isDeleted,
      lastSyncAt: lastSyncAt ?? this.lastSyncAt,
      isDirty: isDirty ?? this.isDirty,
      version: version ?? this.version,
    );
  }
}
