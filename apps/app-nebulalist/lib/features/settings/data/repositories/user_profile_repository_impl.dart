import 'package:dartz/dartz.dart';
import '../../domain/entities/user_profile_entity.dart';
import '../../domain/repositories/user_profile_repository.dart';
import '../datasources/user_profile_remote_datasource.dart';
import '../models/user_profile_model.dart';

class UserProfileRepositoryImpl implements UserProfileRepository {
  final UserProfileRemoteDataSource remoteDataSource;

  UserProfileRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<String, UserProfileEntity?>> getUserProfile() async {
    try {
      final profile = await remoteDataSource.getUserProfile();
      return Right(profile);
    } catch (e) {
      return Left('Erro ao carregar perfil: $e');
    }
  }

  @override
  Future<Either<String, UserProfileEntity>> updateUserProfile(
      UserProfileEntity profile) async {
    try {
      final model = UserProfileModel.fromEntity(profile);
      await remoteDataSource.updateUserProfile(model);
      return Right(profile);
    } catch (e) {
      return Left('Erro ao atualizar perfil: $e');
    }
  }

  @override
  Future<Either<String, bool>> deleteAccount() async {
    try {
      await remoteDataSource.deleteAccount();
      return const Right(true);
    } catch (e) {
      return Left('Erro ao excluir conta: $e');
    }
  }
}
