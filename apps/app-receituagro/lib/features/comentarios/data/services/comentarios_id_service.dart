import 'package:firebase_auth/firebase_auth.dart';

/// Service responsible for generating unique IDs for comments.
///
/// This service encapsulates ID generation logic, separating it from the repository
/// to improve Single Responsibility Principle (SRP) compliance.
///
/// ID Generation Strategies:
/// - **Main ID**: Combines user UID + timestamp for uniqueness
/// - **Registry ID**: Timestamp-based for ordering and tracking
///
/// Benefits of this separation:
/// - Easy to test ID generation logic in isolation
/// - Can be extended to support different ID generation strategies
/// - Repository remains focused on data persistence
abstract class IComentariosIdService {
  /// Generate unique ID for new comentarios
  /// Format: COMMENT_{userId}_{timestamp}
  String generateCommentId();

  /// Generate unique registration ID
  /// Format: REG_{timestamp}
  String generateRegistryId();

  /// Get the current user ID
  /// Returns 'anonymous' if no user is logged in
  String getCurrentUserId();
}

/// Default implementation using Firebase Auth
class ComentariosIdService implements IComentariosIdService {
  final FirebaseAuth _firebaseAuth;

  ComentariosIdService({FirebaseAuth? firebaseAuth})
      : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance;

  @override
  String generateCommentId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final userId = getCurrentUserId();
    return 'COMMENT_${userId}_$timestamp';
  }

  @override
  String generateRegistryId() {
    return 'REG_${DateTime.now().millisecondsSinceEpoch}';
  }

  @override
  String getCurrentUserId() {
    // Get user from Firebase Auth
    final user = _firebaseAuth.currentUser;
    return user?.uid ?? 'anonymous';
  }
}
