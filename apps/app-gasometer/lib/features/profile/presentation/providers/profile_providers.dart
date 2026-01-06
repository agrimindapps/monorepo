import 'package:core/core.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/providers/dependency_providers.dart';
import '../../../auth/presentation/providers/auth_usecase_providers.dart';
import '../../data/datasources/profile_local_datasource.dart';
import '../../data/datasources/profile_remote_datasource.dart';
import '../../data/repositories/profile_repository_impl.dart';
import '../../domain/repositories/i_profile_repository.dart';

part 'profile_providers.g.dart';

// Data Sources
@riverpod
IProfileLocalDataSource profileLocalDataSource(Ref ref) {
  final SharedPreferences prefs = ref.watch(gasometerSharedPreferencesProvider);
  return ProfileLocalDataSource(sharedPreferences: prefs);
}

@riverpod
IProfileRemoteDataSource profileRemoteDataSource(Ref ref) {
  return ProfileRemoteDataSource(
    firestore: FirebaseFirestore.instance,
    storageService: FirebaseStorageService(),
  );
}

// Repository
@riverpod
IProfileRepository profileRepository(Ref ref) {
  return ProfileRepositoryImpl(
    remoteDataSource: ref.watch(profileRemoteDataSourceProvider),
    localDataSource: ref.watch(profileLocalDataSourceProvider),
    authRepository: ref.watch(authRepositoryProvider),
  );
}
