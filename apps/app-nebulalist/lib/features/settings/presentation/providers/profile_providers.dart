import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/entities/user_profile_entity.dart';
import '../../domain/usecases/get_user_profile_usecase.dart';
import '../../domain/usecases/update_user_profile_usecase.dart';
import '../../domain/usecases/delete_account_usecase.dart';
import '../../data/repositories/user_profile_repository_impl.dart';
import '../../data/datasources/user_profile_remote_datasource.dart';

part 'profile_providers.g.dart';

// Firebase Auth Provider
@riverpod
FirebaseAuth firebaseAuth(Ref ref) {
  return FirebaseAuth.instance;
}

// DataSource Provider
@riverpod
UserProfileRemoteDataSource userProfileRemoteDataSource(Ref ref) {
  final auth = ref.watch(firebaseAuthProvider);
  return UserProfileRemoteDataSource(auth);
}

// Repository Provider
@riverpod
UserProfileRepositoryImpl userProfileRepository(Ref ref) {
  final dataSource = ref.watch(userProfileRemoteDataSourceProvider);
  return UserProfileRepositoryImpl(dataSource);
}

// UseCase Providers
@riverpod
GetUserProfileUseCase getUserProfileUseCase(Ref ref) {
  final repository = ref.watch(userProfileRepositoryProvider);
  return GetUserProfileUseCase(repository);
}

@riverpod
UpdateUserProfileUseCase updateUserProfileUseCase(Ref ref) {
  final repository = ref.watch(userProfileRepositoryProvider);
  return UpdateUserProfileUseCase(repository);
}

@riverpod
DeleteAccountUseCase deleteAccountUseCase(Ref ref) {
  final repository = ref.watch(userProfileRepositoryProvider);
  return DeleteAccountUseCase(repository);
}

// User Profile State Provider
@riverpod
class UserProfileNotifier extends _$UserProfileNotifier {
  @override
  Future<UserProfileEntity?> build() async {
    final getUserProfile = ref.read(getUserProfileUseCaseProvider);
    final result = await getUserProfile();
    
    return result.fold(
      (failure) => null,
      (profile) => profile,
    );
  }

  Future<void> updateProfile({
    String? displayName,
    String? email,
    String? photoUrl,
    String? phoneNumber,
  }) async {
    final updateProfile = ref.read(updateUserProfileUseCaseProvider);
    final currentProfile = await future;
    
    if (currentProfile == null) return;
    
    final updatedProfile = currentProfile.copyWith(
      displayName: displayName,
      email: email,
      photoUrl: photoUrl,
      phoneNumber: phoneNumber,
    );
    
    final result = await updateProfile(updatedProfile);
    
    result.fold(
      (failure) => null,
      (profile) => state = AsyncValue.data(profile),
    );
  }

  Future<bool> deleteAccount() async {
    final deleteAccount = ref.read(deleteAccountUseCaseProvider);
    final result = await deleteAccount();
    
    return result.fold(
      (failure) => false,
      (success) {
        state = const AsyncValue.data(null);
        return true;
      },
    );
  }

  Future<void> reload() async {
    state = const AsyncValue.loading();
    final getUserProfile = ref.read(getUserProfileUseCaseProvider);
    final result = await getUserProfile();
    
    state = result.fold(
      (failure) => const AsyncValue.data(null),
      (profile) => AsyncValue.data(profile),
    );
  }
}
