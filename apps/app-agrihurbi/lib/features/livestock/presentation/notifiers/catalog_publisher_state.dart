import 'package:freezed_annotation/freezed_annotation.dart';

part 'catalog_publisher_state.freezed.dart';

@freezed
class CatalogPublisherState with _$CatalogPublisherState {
  const CatalogPublisherState._();
  
  const factory CatalogPublisherState({
    @Default(false) bool isPublishing,
    DateTime? lastPublished,
    String? errorMessage,
    String? successMessage,
    @Default(0) int bovinesPublished,
    @Default(0) int equinesPublished,
  }) = _CatalogPublisherState;
}
