import 'package:core/core.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../core/providers/database_providers.dart';
// import '../sync/adapters/calculation_history_drift_sync_adapter.dart';
// import '../sync/adapters/promo_content_drift_sync_adapter.dart';
import '../petiveti_database.dart';
import '../repositories/animal_images_repository.dart';
import '../repositories/subscription_local_repository.dart';
import '../sync/adapters/animal_drift_sync_adapter.dart';
import '../sync/adapters/appointment_drift_sync_adapter.dart';
import '../sync/adapters/expense_drift_sync_adapter.dart';
import '../sync/adapters/medication_drift_sync_adapter.dart';
import '../sync/adapters/reminder_drift_sync_adapter.dart';
import '../sync/adapters/vaccine_drift_sync_adapter.dart';
import '../sync/adapters/weight_record_drift_sync_adapter.dart';

part 'sync_providers.g.dart';

/// Provider do AnimalDriftSyncAdapter
@riverpod
AnimalDriftSyncAdapter animalSyncAdapter(Ref ref) {
  final db = ref.watch(petivetiDatabaseProvider);
  final firestore = FirebaseFirestore.instance;
  final connectivityService = ConnectivityService.instance;

  return AnimalDriftSyncAdapter(db, firestore, connectivityService);
}

/// Provider do MedicationDriftSyncAdapter
@riverpod
MedicationDriftSyncAdapter medicationSyncAdapter(Ref ref) {
  final db = ref.watch(petivetiDatabaseProvider);
  final firestore = FirebaseFirestore.instance;
  final connectivityService = ConnectivityService.instance;

  return MedicationDriftSyncAdapter(db, firestore, connectivityService);
}

/// Provider do VaccineDriftSyncAdapter
@riverpod
VaccineDriftSyncAdapter vaccineSyncAdapter(Ref ref) {
  final db = ref.watch(petivetiDatabaseProvider);
  final firestore = FirebaseFirestore.instance;
  final connectivityService = ConnectivityService.instance;

  return VaccineDriftSyncAdapter(db, firestore, connectivityService);
}

/// Provider do AppointmentDriftSyncAdapter
@riverpod
AppointmentDriftSyncAdapter appointmentSyncAdapter(Ref ref) {
  final db = ref.watch(petivetiDatabaseProvider);
  final firestore = FirebaseFirestore.instance;
  final connectivityService = ConnectivityService.instance;

  return AppointmentDriftSyncAdapter(db, firestore, connectivityService);
}

/// Provider do WeightRecordDriftSyncAdapter
@riverpod
WeightRecordDriftSyncAdapter weightRecordSyncAdapter(Ref ref) {
  final db = ref.watch(petivetiDatabaseProvider);
  final firestore = FirebaseFirestore.instance;
  final connectivityService = ConnectivityService.instance;

  return WeightRecordDriftSyncAdapter(db, firestore, connectivityService);
}

/// Provider do ExpenseDriftSyncAdapter
@riverpod
ExpenseDriftSyncAdapter expenseSyncAdapter(Ref ref) {
  final db = ref.watch(petivetiDatabaseProvider);
  final firestore = FirebaseFirestore.instance;
  final connectivityService = ConnectivityService.instance;

  return ExpenseDriftSyncAdapter(db, firestore, connectivityService);
}

/// Provider do ReminderDriftSyncAdapter
@riverpod
ReminderDriftSyncAdapter reminderSyncAdapter(Ref ref) {
  final db = ref.watch(petivetiDatabaseProvider);
  final firestore = FirebaseFirestore.instance;
  final connectivityService = ConnectivityService.instance;

  return ReminderDriftSyncAdapter(db, firestore, connectivityService);
}

// FIXME: Calculation History e Promo Content adapters temporariamente desabilitados
// pois as entities não estendem BaseSyncEntity e precisam de refatoração
/*
/// Provider do CalculationHistoryDriftSyncAdapter
@riverpod
CalculationHistoryDriftSyncAdapter calculationHistorySyncAdapter(Ref ref) {
  final db = ref.watch(petivetiDatabaseProvider);
  final firestore = FirebaseFirestore.instance;
  final connectivityService = ConnectivityService.instance;

  return CalculationHistoryDriftSyncAdapter(
    database: db,
    firestore: firestore,
    connectivityService: connectivityService,
  );
}

/// Provider do PromoContentDriftSyncAdapter
@riverpod
PromoContentDriftSyncAdapter promoContentSyncAdapter(Ref ref) {
  final db = ref.watch(petivetiDatabaseProvider);
  final firestore = FirebaseFirestore.instance;
  final connectivityService = ConnectivityService.instance;

  return PromoContentDriftSyncAdapter(
    database: db,
    firestore: firestore,
    connectivityService: connectivityService,
  );
}
*/

/// Provider do SubscriptionLocalRepository
/// Cache local de assinaturas com Drift
@riverpod
SubscriptionLocalRepository subscriptionLocalRepository(Ref ref) {
  final db = ref.watch(petivetiDatabaseProvider);
  return SubscriptionLocalRepository(db);
}

// ========== ANIMAL IMAGES PROVIDERS ==========

/// Provider do repositório de imagens de animais
@riverpod
AnimalImagesRepository animalImagesRepository(Ref ref) {
  final db = ref.watch(petivetiDatabaseProvider);
  return AnimalImagesRepository(db);
}

/// Stream de imagens de um animal
final animalImagesStreamProvider = StreamProvider.autoDispose
    .family<List<AnimalImage>, int>((ref, animalId) {
      final repo = ref.watch(animalImagesRepositoryProvider);
      return repo.watchImagesByAnimalId(animalId);
    });

/// Stream da imagem primária de um animal
final animalPrimaryImageStreamProvider = StreamProvider.autoDispose
    .family<AnimalImage?, int>((ref, animalId) {
      final repo = ref.watch(animalImagesRepositoryProvider);
      return repo.watchPrimaryImage(animalId);
    });
