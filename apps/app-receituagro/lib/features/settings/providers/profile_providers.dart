import 'package:core/core.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/di/injection_container.dart' as di;
import '../../../core/providers/receituagro_auth_notifier.dart';
import '../data/repositories/profile_repository_impl.dart';
import '../domain/repositories/profile_repository.dart';

part 'profile_providers.g.dart';

/// Provider para ProfileRepository usando Riverpod
@riverpod
ProfileRepository profileRepository(Ref ref) {
  return ProfileRepositoryImpl(
    profileImageService: di.sl<ProfileImageService>(),
    getAuthState: () {
      return ref.read(receitaAgroAuthNotifierProvider).valueOrNull;
    },
  );
}
