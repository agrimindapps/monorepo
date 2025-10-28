import 'package:freezed_annotation/freezed_annotation.dart';

part 'item_master_entity.freezed.dart';

/// Entity representing an ItemMaster (reusable item template)
/// ItemMasters are stored in the user's personal item bank
/// They can be reused across multiple lists
@freezed
class ItemMasterEntity with _$ItemMasterEntity {
  const factory ItemMasterEntity({
    required String id,
    required String ownerId,
    required String name,
    @Default('') String description,
    @Default([]) List<String> tags,
    @Default('outros') String category,
    String? photoUrl,
    double? estimatedPrice,
    String? preferredBrand,
    String? notes,
    @Default(0) int usageCount,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _ItemMasterEntity;

  const ItemMasterEntity._();

  /// Check if item has been used before
  bool get hasBeenUsed => usageCount > 0;

  /// Check if item has photo
  bool get hasPhoto => photoUrl != null && photoUrl!.isNotEmpty;

  /// Check if item has price estimate
  bool get hasPrice => estimatedPrice != null && estimatedPrice! > 0;
}
