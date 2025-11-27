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
import '../../pages/exercicios/repository/exercicio_repository.dart';
import '../../pages/exercicios/services/exercicio_business_service.dart';
import '../../pages/peso/repository/peso_repository.dart';
import '../../repository/alimentos_repository.dart';
import '../../repository/comentarios_repository.dart';
import '../../repository/perfil_repository.dart';
import '../services/firebase_firestore_service.dart';

part 'dependency_providers.g.dart';

/// ============================================================================
/// DEPENDENCY PROVIDERS - Riverpod 3.0 Implementation
/// ============================================================================
///
/// Providers centralizados para injeção de dependências.
///
/// **PADRÃO RIVERPOD 3.0:**
/// - Usa @riverpod para code generation
/// - Funções usam Ref genérico (não mais *Ref específicos)
/// - Singletons implementados via keepAlive: true
///
/// ============================================================================

// ============================================================================
// EXTERNAL DEPENDENCIES
// ============================================================================

/// Firebase Firestore singleton
@Riverpod(keepAlive: true)
FirebaseFirestore firebaseFirestore(Ref ref) {
  return FirebaseFirestore.instance;
}

/// Firebase Auth singleton
@Riverpod(keepAlive: true)
FirebaseAuth firebaseAuth(Ref ref) {
  return FirebaseAuth.instance;
}

/// Logger singleton
@Riverpod(keepAlive: true)
Logger logger(Ref ref) {
  return Logger();
}

/// SharedPreferences singleton (async initialization)
@Riverpod(keepAlive: true)
Future<SharedPreferences> sharedPreferences(Ref ref) async {
  return SharedPreferences.getInstance();
}

// ============================================================================
// DATABASE
// ============================================================================

/// NutritutiDatabase singleton
@Riverpod(keepAlive: true)
NutritutiDatabase nutritutiDatabase(Ref ref) {
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
AguaDao aguaDao(Ref ref) {
  final db = ref.watch(nutritutiDatabaseProvider);
  return db.aguaDao;
}

/// ComentarioDao provider
@Riverpod(keepAlive: true)
ComentarioDao comentarioDao(Ref ref) {
  final db = ref.watch(nutritutiDatabaseProvider);
  return db.comentarioDao;
}

/// ExercicioDao provider
@Riverpod(keepAlive: true)
ExercicioDao exercicioDao(Ref ref) {
  final db = ref.watch(nutritutiDatabaseProvider);
  return db.exercicioDao;
}

/// PerfilDao provider
@Riverpod(keepAlive: true)
PerfilDao perfilDao(Ref ref) {
  final db = ref.watch(nutritutiDatabaseProvider);
  return db.perfilDao;
}

/// PesoDao provider
@Riverpod(keepAlive: true)
PesoDao pesoDao(Ref ref) {
  final db = ref.watch(nutritutiDatabaseProvider);
  return db.pesoDao;
}

/// WaterDao provider
@Riverpod(keepAlive: true)
WaterDao waterDao(Ref ref) {
  final db = ref.watch(nutritutiDatabaseProvider);
  return db.waterDao;
}

// ============================================================================
// SERVICES
// ============================================================================

/// FirestoreService provider
@riverpod
FirestoreService firestoreService(Ref ref) {
  final firestore = ref.watch(firebaseFirestoreProvider);
  return FirestoreService(firestore);
}

// ============================================================================
// REPOSITORIES
// ============================================================================

/// PerfilRepository provider
@riverpod
PerfilRepository perfilRepository(Ref ref) {
  final database = ref.watch(nutritutiDatabaseProvider);
  return PerfilRepository(database);
}

/// AlimentosRepository provider
@riverpod
AlimentosRepository alimentosRepository(Ref ref) {
  return AlimentosRepository();
}

/// ComentariosRepository provider
@riverpod
ComentariosRepository comentariosRepository(Ref ref) {
  final database = ref.watch(nutritutiDatabaseProvider);
  return ComentariosRepository(database);
}

/// AguaRepository provider
@riverpod
AguaRepository aguaRepository(Ref ref) {
  final aguaDao = ref.watch(aguaDaoProvider);
  return AguaRepository(aguaDao);
}

/// PesoRepository provider
@riverpod
PesoRepository pesoRepository(Ref ref) {
  final firestoreService = ref.watch(firestoreServiceProvider);
  final database = ref.watch(nutritutiDatabaseProvider);
  return PesoRepository(firestoreService, database);
}

/// ExercicioRepository provider
@riverpod
ExercicioRepository exercicioRepository(Ref ref) {
  return ExercicioRepository();
}

/// ExercicioBusinessService provider
@riverpod
ExercicioBusinessService exercicioBusinessService(Ref ref) {
  final database = ref.watch(nutritutiDatabaseProvider);
  final repository = ref.watch(exercicioRepositoryProvider);
  return ExercicioBusinessService(database, repository);
}
