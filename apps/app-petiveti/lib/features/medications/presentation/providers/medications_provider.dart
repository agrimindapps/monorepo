import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'medications_providers.dart';

export 'medications_providers.dart';

part 'medications_provider.g.dart';

// Aliases for backward compatibility
const medicationsProviderAlias = medicationsProvider;
const medicationProviderAlias = medicationByIdProvider;

@riverpod
class SelectedMedication extends _$SelectedMedication {
  @override
  dynamic build() => null;

  void set(dynamic medication) => state = medication;
  void clear() => state = null;
}
