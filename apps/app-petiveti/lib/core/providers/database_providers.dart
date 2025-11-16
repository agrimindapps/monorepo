import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../database/petiveti_database.dart';

part 'database_providers.g.dart';

/// Provider for Drift database instance
@riverpod
PetivetiDatabase petivetiDatabase(PetivetiDatabaseRef ref) {
  final db = PetivetiDatabase();
  ref.onDispose(() => db.close());
  return db;
}

/// Provider for Firestore instance
@riverpod
FirebaseFirestore firebaseFirestore(FirebaseFirestoreRef ref) {
  return FirebaseFirestore.instance;
}

/// Provider for Connectivity
@riverpod
Connectivity connectivity(ConnectivityRef ref) {
  return Connectivity();
}
