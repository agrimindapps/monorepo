import 'package:cloud_firestore/cloud_firestore.dart';

/// Firebase Firestore ID generator for the app
/// Uses Firebase's native ID generation for consistency across the platform
class UuidGenerator {
  /// Generates a Firebase Firestore document ID
  /// Uses Firebase's native ID generation which is optimized for distributed systems
  static String generate() {
    return FirebaseFirestore.instance.collection('_').doc().id;
  }

  /// Generates a simple Firebase Firestore ID (alias for generate)
  static String generateShort() {
    return FirebaseFirestore.instance.collection('_').doc().id;
  }

  /// Generates a Firebase Firestore ID (alias for generate)
  /// Maintained for backward compatibility
  static String generateTimestamp() {
    return FirebaseFirestore.instance.collection('_').doc().id;
  }
}
