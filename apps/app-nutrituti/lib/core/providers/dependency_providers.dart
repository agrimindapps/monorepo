import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:logger/logger.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../drift_database/daos/agua_dao.dart';
import '../../drift_database/daos/comentario_dao.dart';
import '../../drift_database/daos/exercicio_dao.dart';
import '../../drift_database/daos/perfil_dao.dart';
import '../../drift_database/daos/peso_dao.dart';
import '../../drift_database/daos/water_dao.dart';
import '../../drift_database/nutrituti_database.dart';
import '../../pages/agua/repository/agua_repository.dart';
import '../../pages/peso/repository/peso_repository.dart';
import '../../repository/alimentos_repository.dart';
import '../../repository/comentarios_repository.dart';
import '../../repository/perfil_repository.dart';
import '../services/firebase_firestore_service.dart';

part 'dependency_providers.g.dart';

/// ============================================================================
/// DEPENDENCY PROVIDERS - Riverpod Implementation
/// ============================================================================
///
/// Providers centralizados para substituir GetIt/Injectable.
///
/// **PADRÃO ESTABELECIDO:**
/// - Usa @riverpod para code generation
/// - Singletons implementados via keepAlive: true
/// - Database e DAOs como providers Riverpod
/// - Firebase e External dependencies expostos via providers
///
/// **ORGANIZAÇÃO:**
/// 1. External Dependencies (Firebase, SharedPreferences, Logger)
/// 2. Database (NutritutiDatabase)
/// 3. DAOs (Perfil, Peso, Agua, Water, Exercicio, Comentario)
/// 4. Services (FirestoreService)
///
/// ============================================================================

// ============================================================================
// EXTERNAL DEPENDENCIES
// ============================================================================

/// Firebase Firestore singleton
@Riverpod(keepAlive: true)
FirebaseFirestore firebaseFirestore(FirebaseFirestoreRef ref) {
  return FirebaseFirestore.instance;
}

/// Firebase Auth singleton
@Riverpod(keepAlive: true)
FirebaseAuth firebaseAuth(FirebaseAuthRef ref) {
  return FirebaseAuth.instance;
}

/// Logger singleton
@Riverpod(keepAlive: true)
Logger logger(LoggerRef ref) {
  return Logger();
}

/// SharedPreferences singleton (async initialization)
@Riverpod(keepAlive: true)
Future<SharedPreferences> sharedPreferences(SharedPreferencesRef ref) async {
  return SharedPreferences.getInstance();
}

// ============================================================================
// DATABASE
// ============================================================================

/// NutritutiDatabase singleton
@Riverpod(keepAlive: true)
NutritutiDatabase nutritutiDatabase(NutritutiDatabaseRef ref) {
  final db = NutritutiDatabase.production();
  // Dispose database when provider is disposed
  ref.onDispose(() => db.close());
  return db;
}

// ============================================================================
// DAOs (Database Access Objects)
// ============================================================================

/// AguaDao provider
@Riverpod(keepAlive: true)
AguaDao aguaDao(AguaDaoRef ref) {
  final db = ref.watch(nutritutiDatabaseProvider);
  return db.aguaDao;
}

/// ComentarioDao provider
@Riverpod(keepAlive: true)
ComentarioDao comentarioDao(ComentarioDaoRef ref) {
  final db = ref.watch(nutritutiDatabaseProvider);
  return db.comentarioDao;
}

/// ExercicioDao provider
@Riverpod(keepAlive: true)
ExercicioDao exercicioDao(ExercicioDaoRef ref) {
  final db = ref.watch(nutritutiDatabaseProvider);
  return db.exercicioDao;
}

/// PerfilDao provider
@Riverpod(keepAlive: true)
PerfilDao perfilDao(PerfilDaoRef ref) {
  final db = ref.watch(nutritutiDatabaseProvider);
  return db.perfilDao;
}

/// PesoDao provider
@Riverpod(keepAlive: true)
PesoDao pesoDao(PesoDaoRef ref) {
  final db = ref.watch(nutritutiDatabaseProvider);
  return db.pesoDao;
}

/// WaterDao provider
@Riverpod(keepAlive: true)
WaterDao waterDao(WaterDaoRef ref) {
  final db = ref.watch(nutritutiDatabaseProvider);
  return db.waterDao;
}

// ============================================================================
// SERVICES
// ============================================================================

/// FirestoreService provider
@riverpod
FirestoreService firestoreService(FirestoreServiceRef ref) {
  final firestore = ref.watch(firebaseFirestoreProvider);
  return FirestoreService(firestore);
}

// ============================================================================
// REPOSITORIES
// ============================================================================

/// PerfilRepository provider
@riverpod
PerfilRepository perfilRepository(PerfilRepositoryRef ref) {
  final database = ref.watch(nutritutiDatabaseProvider);
  return PerfilRepository(database);
}

/// AlimentosRepository provider
@riverpod
AlimentosRepository alimentosRepository(AlimentosRepositoryRef ref) {
  return AlimentosRepository();
}

/// ComentariosRepository provider
@riverpod
ComentariosRepository comentariosRepository(ComentariosRepositoryRef ref) {
  final database = ref.watch(nutritutiDatabaseProvider);
  return ComentariosRepository(database);
}

/// AguaRepository provider
@riverpod
AguaRepository aguaRepository(AguaRepositoryRef ref) {
  final aguaDao = ref.watch(aguaDaoProvider);
  return AguaRepository(aguaDao);
}

/// PesoRepository provider
@riverpod
PesoRepository pesoRepository(PesoRepositoryRef ref) {
  final firestoreService = ref.watch(firestoreServiceProvider);
  final database = ref.watch(nutritutiDatabaseProvider);
  return PesoRepository(firestoreService, database);
}
