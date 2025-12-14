import 'package:core/core.dart';

import 'petiveti_data_cleaner.dart';

/// Provider para o serviço de limpeza de dados do Petiveti
final petivetiDataCleanerProvider = Provider<PetivetiDataCleaner>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return PetivetiDataCleaner(prefs: prefs);
});
