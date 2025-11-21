import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../database/petiveti_database.dart';

part 'database_providers.g.dart';

/// Provider do banco de dados principal
///
/// **Funcionamento em todas as plataformas:**
/// - **Mobile/Desktop**: SQLite nativo via Drift
/// - **Web**: WASM + IndexedDB via Drift
///
/// Usa DriftDatabaseConfig que automaticamente escolhe o executor correto.
final petivetiDatabaseProvider = Provider<PetivetiDatabase>((ref) {
  // Instancia o banco diretamente usando o factory de produção
  final db = PetivetiDatabase.production();

  // Fecha o banco quando o provider for descartado
  ref.onDispose(() {
    db.close();
  });

  // Mantém o provider vivo permanentemente
  ref.keepAlive();

  return db;
});

/// Provider legado (mantido para compatibilidade)
///
/// **DEPRECADO:** Use petivetiDatabaseProvider ao invés deste.
@Deprecated('Use petivetiDatabaseProvider (Provider) ao invés de @riverpod')
@riverpod
PetivetiDatabase petivetiDatabase(PetivetiDatabaseRef ref) {
  // Redireciona para o provider correto
  return ref.watch(petivetiDatabaseProvider);
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
