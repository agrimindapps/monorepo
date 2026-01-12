import 'package:freezed_annotation/freezed_annotation.dart';

part 'catalog_publisher_state.freezed.dart';

@freezed
abstract class CatalogPublisherState with _$CatalogPublisherState {
  const CatalogPublisherState._();
  
  const factory CatalogPublisherState({
    @Default(false) bool isPublishing,
    @Default(null) DateTime? lastPublished,
    @Default(null) String? errorMessage,
    @Default(null) String? successMessage,
    @Default(0) int bovinesPublished,
    @Default(0) int equinesPublished,
  }) = _CatalogPublisherState;
}
