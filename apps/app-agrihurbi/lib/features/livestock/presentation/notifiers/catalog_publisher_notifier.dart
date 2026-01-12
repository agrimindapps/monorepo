import 'package:core/core.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/usecases/publish_livestock_catalog.dart';
import '../providers/livestock_di_providers.dart';
import 'catalog_publisher_state.dart';

part 'catalog_publisher_notifier.g.dart';

/// Notifier para gerenciar publicação de catálogo no Storage
/// 
/// Responsabilidade única: Publicar catálogo de bovinos/equinos
/// no Firebase Storage para ser baixado por usuários
@riverpod
class CatalogPublisherNotifier extends _$CatalogPublisherNotifier {
  late final PublishLivestockCatalogUseCase _publishUseCase;
  
  @override
  CatalogPublisherState build() {
    _publishUseCase = ref.watch(publishLivestockCatalogUseCaseProvider);
    return const CatalogPublisherState();
  }
  
  /// Publica catálogo no Firebase Storage
  Future<void> publishCatalog() async {
    debugPrint('🚀 CatalogPublisherNotifier: Starting catalog publication...');
    
    state = state.copyWith(
      isPublishing: true,
      errorMessage: null,
      successMessage: null,
    );
    
    final result = await _publishUseCase(NoParams());
    
    result.fold(
      (failure) {
        debugPrint('❌ CatalogPublisherNotifier: Publication failed: ${failure.message}');
        
        state = state.copyWith(
          isPublishing: false,
          errorMessage: failure.message,
          successMessage: null,
        );
      },
      (_) {
        debugPrint('✅ CatalogPublisherNotifier: Catalog published successfully!');
        
        state = state.copyWith(
          isPublishing: false,
          lastPublished: DateTime.now(),
          errorMessage: null,
          successMessage: 'Catálogo publicado com sucesso!',
        );
      },
    );
  }
  
  /// Limpa mensagens de erro/sucesso
  void clearMessages() {
    state = state.copyWith(
      errorMessage: null,
      successMessage: null,
    );
  }
}
