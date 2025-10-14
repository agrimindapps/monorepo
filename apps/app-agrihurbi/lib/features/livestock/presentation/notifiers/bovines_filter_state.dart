import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/bovine_entity.dart';

part 'bovines_filter_state.freezed.dart';

/// Immutable state for bovines filters
@freezed
class BovinesFilterState with _$BovinesFilterState {
  const factory BovinesFilterState({
    @Default('') String searchQuery,
    @Default(null) String? selectedBreed,
    @Default(null) String? selectedOriginCountry,
    @Default(null) BovineAptitude? selectedAptitude,
    @Default(null) BreedingSystem? selectedBreedingSystem,
    @Default(true) bool onlyActive,
    @Default({}) Set<String> availableBreeds,
    @Default({}) Set<String> availableCountries,
  }) = _BovinesFilterState;
}
