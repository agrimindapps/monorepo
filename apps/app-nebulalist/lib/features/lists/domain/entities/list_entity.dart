import 'package:freezed_annotation/freezed_annotation.dart';

part 'list_entity.freezed.dart';

/// Entity representing a user list in the app
/// Used in domain layer for business logic
@freezed
class ListEntity with _$ListEntity {
  const factory ListEntity({
    required String id,
    required String name,
    required String ownerId,
    @Default('') String description,
    @Default([]) List<String> tags,
    @Default('outros') String category,
    @Default(false) bool isFavorite,
    @Default(false) bool isArchived,
    required DateTime createdAt,
    required DateTime updatedAt,
    String? shareToken,
    @Default(false) bool isShared,
    DateTime? archivedAt,
    @Default(0) int itemCount,
    @Default(0) int completedCount,
  }) = _ListEntity;

  const ListEntity._();

  /// Calculate completion percentage
  double get completionPercentage {
    if (itemCount == 0) return 0.0;
    return (completedCount / itemCount * 100).clamp(0.0, 100.0);
  }

  /// Check if list is empty
  bool get isEmpty => itemCount == 0;

  /// Check if list is complete
  bool get isComplete => itemCount > 0 && itemCount == completedCount;
}
