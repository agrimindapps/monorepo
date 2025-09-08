import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    super.email,
    super.displayName,
    super.photoUrl,
    super.avatarBase64,
    required super.type,
    required super.isEmailVerified,
    required super.createdAt,
    super.lastSignInAt,
    super.metadata,
  });

  // From Firebase User
  factory UserModel.fromFirebaseUser(User firebaseUser) {
    UserType userType = UserType.anonymous;
    
    if (firebaseUser.isAnonymous) {
      userType = UserType.anonymous;
    } else if (firebaseUser.email != null) {
      userType = UserType.registered;
    }

    return UserModel(
      id: firebaseUser.uid,
      email: firebaseUser.email,
      displayName: firebaseUser.displayName,
      photoUrl: firebaseUser.photoURL,
      avatarBase64: null, // Local avatars are not stored in Firebase
      type: userType,
      isEmailVerified: firebaseUser.emailVerified,
      createdAt: firebaseUser.metadata.creationTime ?? DateTime.now(),
      lastSignInAt: firebaseUser.metadata.lastSignInTime,
      metadata: {
        'providerId': firebaseUser.providerData.map((p) => p.providerId).toList(),
        'isAnonymous': firebaseUser.isAnonymous,
      },
    );
  }

  // From Firestore document
  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    return UserModel(
      id: doc.id,
      email: data['email'] as String?,
      displayName: data['displayName'] as String?,
      photoUrl: data['photoUrl'] as String?,
      avatarBase64: null, // Local avatars are not stored in Firestore
      type: UserType.values[data['type'] as int? ?? 0],
      isEmailVerified: data['isEmailVerified'] as bool? ?? false,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      lastSignInAt: (data['lastSignInAt'] as Timestamp?)?.toDate(),
      metadata: Map<String, dynamic>.from(data['metadata'] as Map? ?? {}),
    );
  }

  // From JSON (for local storage)
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String?,
      displayName: json['displayName'] as String?,
      photoUrl: json['photoUrl'] as String?,
      avatarBase64: json['avatarBase64'] as String?,
      type: UserType.values[json['type'] as int? ?? 0],
      isEmailVerified: json['isEmailVerified'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
      lastSignInAt: json['lastSignInAt'] != null 
          ? DateTime.parse(json['lastSignInAt'] as String)
          : null,
      metadata: Map<String, dynamic>.from(json['metadata'] as Map? ?? {}),
    );
  }

  // To Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'type': type.index,
      'isEmailVerified': isEmailVerified,
      'createdAt': Timestamp.fromDate(createdAt),
      'lastSignInAt': lastSignInAt != null ? Timestamp.fromDate(lastSignInAt!) : null,
      'updatedAt': FieldValue.serverTimestamp(),
      'metadata': metadata,
    };
  }

  // To JSON (for local storage)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'avatarBase64': avatarBase64,
      'type': type.index,
      'isEmailVerified': isEmailVerified,
      'createdAt': createdAt.toIso8601String(),
      'lastSignInAt': lastSignInAt?.toIso8601String(),
      'metadata': metadata,
    };
  }

  // Convert to entity
  UserEntity toEntity() {
    return UserEntity(
      id: id,
      email: email,
      displayName: displayName,
      photoUrl: photoUrl,
      avatarBase64: avatarBase64,
      type: type,
      isEmailVerified: isEmailVerified,
      createdAt: createdAt,
      lastSignInAt: lastSignInAt,
      metadata: metadata,
    );
  }

  // Create from entity
  factory UserModel.fromEntity(UserEntity entity) {
    return UserModel(
      id: entity.id,
      email: entity.email,
      displayName: entity.displayName,
      photoUrl: entity.photoUrl,
      avatarBase64: entity.avatarBase64,
      type: entity.type,
      isEmailVerified: entity.isEmailVerified,
      createdAt: entity.createdAt,
      lastSignInAt: entity.lastSignInAt,
      metadata: entity.metadata,
    );
  }

  @override
  UserModel copyWith({
    String? id,
    String? email,
    String? displayName,
    String? photoUrl,
    String? avatarBase64,
    UserType? type,
    bool? isEmailVerified,
    DateTime? createdAt,
    DateTime? lastSignInAt,
    Map<String, dynamic>? metadata,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      avatarBase64: avatarBase64 ?? this.avatarBase64,
      type: type ?? this.type,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      createdAt: createdAt ?? this.createdAt,
      lastSignInAt: lastSignInAt ?? this.lastSignInAt,
      metadata: metadata ?? this.metadata,
    );
  }
}