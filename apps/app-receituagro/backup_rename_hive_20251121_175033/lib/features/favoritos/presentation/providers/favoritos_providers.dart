import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:get_it/get_it.dart';
import '../../data/repositories/favoritos_repository_simplified.dart';
import '../../data/services/favoritos_error_message_service.dart';

part 'favoritos_providers.g.dart';

/// Bridge provider for FavoritosRepositorySimplified
@riverpod
FavoritosRepositorySimplified favoritosRepositorySimplified(FavoritosRepositorySimplifiedRef ref) {
  return GetIt.I.get<FavoritosRepositorySimplified>();
}

/// Bridge provider for FavoritosErrorMessageService
@riverpod
FavoritosErrorMessageService favoritosErrorMessageService(FavoritosErrorMessageServiceRef ref) {
  return GetIt.I.get<FavoritosErrorMessageService>();
}
