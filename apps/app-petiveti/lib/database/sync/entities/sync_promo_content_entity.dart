import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:core/core.dart';

/// Entity for syncing PromoContent with Firestore
class SyncPromoContentEntity extends BaseSyncEntity {
  final String? firebaseId;
  final String title;
  final String content;
  final String? imageUrl;
  final String? actionUrl;
  final DateTime? expiryDate;
  final bool isActive;

  const SyncPromoContentEntity({
    required super.id,
    this.firebaseId,
    required this.title,
    required this.content,
    this.imageUrl,
    this.actionUrl,
    this.expiryDate,
    this.isActive = true,
    super.createdAt,
    super.updatedAt,
    super.isDeleted = false,
    super.lastSyncAt,
    super.isDirty = false,
    super.version = 1,
    super.userId,
    super.moduleName,
  });

  @override
  List<Object?> get props => [
    ...super.props,
    firebaseId,
    title,
    content,
    imageUrl,
    actionUrl,
    expiryDate,
    isActive,
  ];

  @override
  SyncPromoContentEntity copyWith({
    String? id,
    String? firebaseId,
    String? title,
    String? content,
    String? imageUrl,
    String? actionUrl,
    DateTime? expiryDate,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isDeleted,
    DateTime? lastSyncAt,
    bool? isDirty,
    int? version,
    String? userId,
    String? moduleName,
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
      updatedAt: updatedAt ?? this.updatedAt,
      isDeleted: isDeleted ?? this.isDeleted,
      lastSyncAt: lastSyncAt ?? this.lastSyncAt,
      isDirty: isDirty ?? this.isDirty,
      version: version ?? this.version,
      userId: userId ?? this.userId,
      moduleName: moduleName ?? this.moduleName,
    );
  }

  @override
  SyncPromoContentEntity markAsDirty() => copyWith(isDirty: true);

  @override
  SyncPromoContentEntity markAsSynced({DateTime? syncTime}) => copyWith(
    isDirty: false,
    lastSyncAt: syncTime ?? DateTime.now(),
  );

  @override
  SyncPromoContentEntity markAsDeleted() => copyWith(isDeleted: true, isDirty: true);

  @override
  SyncPromoContentEntity incrementVersion() => copyWith(version: version + 1);

  @override
  SyncPromoContentEntity withUserId(String userId) => copyWith(userId: userId);

  @override
  SyncPromoContentEntity withModule(String moduleName) => copyWith(moduleName: moduleName);

  @override
  Map<String, dynamic> toFirebaseMap() => toFirestore();

  /// Convert to Firestore map
  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'content': content,
      'imageUrl': imageUrl,
      'actionUrl': actionUrl,
      'expiryDate': expiryDate != null ? Timestamp.fromDate(expiryDate!) : null,
      'isActive': isActive,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : Timestamp.now(),
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
      id: data['localId'] as String? ?? snapshot.id,
      firebaseId: snapshot.id,
      title: data['title'] as String,
      content: data['content'] as String,
      imageUrl: data['imageUrl'] as String?,
      actionUrl: data['actionUrl'] as String?,
      expiryDate: data['expiryDate'] != null
          ? (data['expiryDate'] as Timestamp).toDate()
          : null,
      isActive: data['isActive'] as bool? ?? true,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      isDeleted: data['isDeleted'] as bool? ?? false,
      lastSyncAt: data['lastSyncAt'] != null
          ? (data['lastSyncAt'] as Timestamp).toDate()
          : null,
      isDirty: data['isDirty'] as bool? ?? false,
      version: data['version'] as int? ?? 1,
    );
  }
}
