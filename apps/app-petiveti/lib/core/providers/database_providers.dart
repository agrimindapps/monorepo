import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../database/petiveti_database.dart';

part 'database_providers.g.dart';

/// Provider do banco de dados principal
///
/// **IMPORTANTE:** Este provider retorna a MESMA instância registrada no GetIt
/// para evitar múltiplas instâncias do banco de dados.
///
/// **Funcionamento em todas as plataformas:**
/// - **Mobile/Desktop**: SQLite nativo via Drift
/// - **Web**: WASM + IndexedDB via Drift
///
/// Usa DriftDatabaseConfig que automaticamente escolhe o executor correto.
final petivetiDatabaseProvider = Provider<PetivetiDatabase>((ref) {
  // 🔒 CRITICAL: Retorna a instância única do GetIt
  // Isso previne múltiplas instâncias que causam race conditions
  final db = GetIt.I<PetivetiDatabase>();

  // NÃO fecha o banco aqui, pois a instância é gerenciada pelo GetIt
  // ref.onDispose não deve ser usado para instâncias compartilhadas

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
