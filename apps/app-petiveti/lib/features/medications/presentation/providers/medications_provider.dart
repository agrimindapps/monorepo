import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'medications_providers.dart';

export 'medications_providers.dart';

// Aliases for backward compatibility
final medicationsProvider = medicationsNotifierProvider;
final medicationProvider = medicationByIdProvider;
final selectedMedicationProvider = StateProvider<dynamic>((ref) => null);
