import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../notifiers/medications_notifier.dart';

export '../notifiers/medications_notifier.dart';

// Aliases for backward compatibility
final medicationsProvider = medicationsNotifierProvider;
final medicationProvider = medicationByIdProvider;
final medicationsStreamProvider = medicationsStreamProvider;
final medicationsByAnimalStreamProvider = medicationsByAnimalStreamProvider;
final activeMedicationsStreamProvider = activeMedicationsStreamProvider;
final filteredMedicationsProvider = filteredMedicationsProvider;

final medicationTypeFilterProvider = medicationTypeFilterProvider;
final medicationStatusFilterProvider = medicationStatusFilterProvider;
final medicationSearchQueryProvider = medicationSearchQueryProvider;
final selectedMedicationProvider = StateProvider<dynamic>((ref) => null); // Placeholder if needed, or remove if unused
