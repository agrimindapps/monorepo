import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:core/core.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'sync_providers.dart';

part 'unified_sync_manager_provider.g.dart';

/// Provider for UnifiedSyncManager
///
/// Orchestrates sync for all 9 tables in Petiveti app:
/// 1. Animals
/// 2. Medications
/// 3. Vaccines
/// 4. Appointments
/// 5. WeightRecords
/// 6. Expenses
/// 7. Reminders
/// 8. CalculationHistory
/// 9. PromoContent
@riverpod
UnifiedSyncManager unifiedSyncManager(Ref ref) {
  // Get all sync adapters (7 ativos, 2 desabilitados temporariamente)
  final adapters = [
    ref.watch(animalSyncAdapterProvider),
    ref.watch(medicationSyncAdapterProvider),
    ref.watch(vaccineSyncAdapterProvider),
    ref.watch(appointmentSyncAdapterProvider),
    ref.watch(weightRecordSyncAdapterProvider),
    ref.watch(expenseSyncAdapterProvider),
    ref.watch(reminderSyncAdapterProvider),
    // TODO: Re-enable quando calculation_history e promo_content forem refatorados
    // ref.watch(calculationHistorySyncAdapterProvider),
    // ref.watch(promoContentSyncAdapterProvider),
  ];

  // Use o singleton UnifiedSyncManager.instance ao invés de criar nova instância
  return UnifiedSyncManager.instance;
}
