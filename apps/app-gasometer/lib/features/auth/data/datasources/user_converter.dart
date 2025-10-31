import 'package:core/core.dart';

import '../../../../core/extensions/user_entity_gasometer_extension.dart';

/// Conversor especializado para entidades de usuário
///
/// Responsabilidade: Converter entre diferentes representações de UserEntity
/// Aplica SRP (Single Responsibility Principle) e ISP (Interface Segregation)
@injectable
class UserConverter {
  /// Converte Firebase User para UserEntity do Gasometer
  UserEntity fromFirebaseUser(User firebaseUser) {
    return UserEntityGasometerExtension.fromFirebaseUser(firebaseUser);
  }

  /// Converte Core UserEntity para UserEntity do Gasometer
  UserEntity fromCoreUserEntity(UserEntity coreUser) {
    return UserEntityGasometerExtension.fromCoreUserEntity(coreUser);
  }

  /// Converte DocumentSnapshot do Firestore para UserEntity do Gasometer
  UserEntity fromFirestore(DocumentSnapshot doc) {
    return UserEntityGasometerExtension.fromFirestore(doc);
  }

  /// Converte UserEntity do Gasometer para mapa Firestore
  Map<String, dynamic> toFirestore(UserEntity user) {
    return user.toGasometerFirestore();
  }

  /// Converte UserEntity do Gasometer para JSON
  Map<String, dynamic> toJson(UserEntity user) {
    return user.toGasometerJson();
  }
}
