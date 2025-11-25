import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'medications_providers.dart';

part 'medications_provider.g.dart';

export 'medications_providers.dart';

// Aliases for backward compatibility
final medicationsProviderAlias = medicationsProvider;
final medicationProviderAlias = medicationByIdProvider;

@riverpod
class SelectedMedication extends _$SelectedMedication {
  @override
  dynamic build() => null;

  void set(dynamic medication) => state = medication;
  void clear() => state = null;
}
