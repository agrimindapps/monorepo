import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:core/core.dart';

import '../../database/petiveti_database.dart';

part 'database_providers.g.dart';

/// Provider do banco de dados principal
///
/// **Funcionamento em todas as plataformas:**
/// - **Mobile/Desktop**: SQLite nativo via Drift
/// - **Web**: WASM + IndexedDB via Drift
///
/// Usa DriftDatabaseConfig que automaticamente escolhe o executor correto.
@riverpod
PetivetiDatabase petivetiDatabase(Ref ref) {
  // Instancia o banco diretamente usando o factory de produção
  final db = PetivetiDatabase.production();

  // Fecha o banco quando o provider for descartado
  ref.onDispose(() {
    db.close();
  });

  // Mantém o provider vivo permanentemente
  ref.keepAlive();

  return db;
}

/// Provider for Firestore instance (local version - prefer using core_services_providers.dart)
@riverpod
FirebaseFirestore petivetiFirestore(Ref ref) {
  return FirebaseFirestore.instance;
}

/// Provider for Connectivity
@riverpod
Connectivity connectivity(Ref ref) {
  return Connectivity();
}
