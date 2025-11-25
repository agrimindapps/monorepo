import 'package:core/core.dart' hide Column;

import '../../../core/providers/auth_providers.dart';
import '../data/repositories/profile_repository_impl.dart';
import '../domain/repositories/profile_repository.dart';

part 'profile_providers.g.dart';

/// Provider para ProfileImageService
@riverpod
ProfileImageService profileImageService(Ref ref) {
  return ProfileImageServiceFactory.createDefault();
}

/// Provider para ProfileRepository usando Riverpod
@riverpod
ProfileRepository profileRepository(Ref ref) {
  return ProfileRepositoryImpl(
    profileImageService: ref.watch(profileImageServiceProvider),
    getAuthState: () {
      return ref.read(authProvider);
    },
  );
}
