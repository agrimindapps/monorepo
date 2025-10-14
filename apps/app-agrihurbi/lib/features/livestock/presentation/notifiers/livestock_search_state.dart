import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/animal_base_entity.dart';

part 'livestock_search_state.freezed.dart';

/// Immutable state for livestock search
@freezed
class LivestockSearchState with _$LivestockSearchState {
  const factory LivestockSearchState({
    @Default(false) bool isSearching,
    @Default([]) List<AnimalBaseEntity> searchResults,
    @Default('') String searchQuery,
    @Default(null) String? errorMessage,
  }) = _LivestockSearchState;
}
