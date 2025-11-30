import 'package:core/core.dart';

import '../../../../core/network/network_info.dart';
// import '../../../../database/agrihurbi_database.dart';
import '../../../../database/database_provider.dart';
import '../../data/datasources/livestock_local_datasource.dart';
import '../../data/datasources/livestock_remote_datasource.dart';
import '../../data/repositories/livestock_repository_impl.dart';
import '../../domain/repositories/livestock_repository.dart';
import '../../domain/usecases/create_bovine.dart';
import '../../domain/usecases/delete_bovine.dart';
import '../../domain/usecases/get_bovine_by_id.dart';
import '../../domain/usecases/get_bovines.dart';
import '../../domain/usecases/get_equines.dart';
import '../../domain/usecases/search_animals.dart';
import '../../domain/usecases/update_bovine.dart';

// Network Info
final networkInfoProvider = Provider<NetworkInfo>((ref) {
  final connectivity = Connectivity();
  return NetworkInfoImpl(connectivity);
});

// Datasources
final livestockLocalDataSourceProvider =
    Provider<LivestockLocalDataSource>((ref) {
  final database = ref.watch(agrihurbiDatabaseProvider);
  return LivestockDriftLocalDataSource(database);
});

final livestockRemoteDataSourceProvider =
    Provider<LivestockRemoteDataSource>((ref) {
  return LivestockRemoteDataSourceImpl();
});

// Repository
final livestockRepositoryProvider = Provider<LivestockRepository>((ref) {
  final localDataSource = ref.watch(livestockLocalDataSourceProvider);
  final remoteDataSource = ref.watch(livestockRemoteDataSourceProvider);
  final connectivity = Connectivity();

  return LivestockRepositoryImpl(
    localDataSource,
    remoteDataSource,
    connectivity,
  );
});

// Usecases
final getBovinesUseCaseProvider = Provider<GetBovinesUseCase>((ref) {
  return GetBovinesUseCase(ref.watch(livestockRepositoryProvider));
});

final getAllBovinesUseCaseProvider = Provider<GetAllBovinesUseCase>((ref) {
  return GetAllBovinesUseCase(ref.watch(livestockRepositoryProvider));
});

final getEquinesUseCaseProvider = Provider<GetEquinesUseCase>((ref) {
  return GetEquinesUseCase(ref.watch(livestockRepositoryProvider));
});

final getAllEquinesUseCaseProvider = Provider<GetAllEquinesUseCase>((ref) {
  return GetAllEquinesUseCase(ref.watch(livestockRepositoryProvider));
});

final getEquineByIdUseCaseProvider = Provider<GetEquineByIdUseCase>((ref) {
  return GetEquineByIdUseCase(ref.watch(livestockRepositoryProvider));
});

final createBovineUseCaseProvider = Provider<CreateBovineUseCase>((ref) {
  return CreateBovineUseCase(ref.watch(livestockRepositoryProvider));
});

final updateBovineUseCaseProvider = Provider<UpdateBovineUseCase>((ref) {
  return UpdateBovineUseCase(ref.watch(livestockRepositoryProvider));
});

final deleteBovineUseCaseProvider = Provider<DeleteBovineUseCase>((ref) {
  return DeleteBovineUseCase(ref.watch(livestockRepositoryProvider));
});

final searchAnimalsUseCaseProvider = Provider<SearchAnimalsUseCase>((ref) {
  return SearchAnimalsUseCase(ref.watch(livestockRepositoryProvider));
});

final getBovineByIdUseCaseProvider = Provider<GetBovineByIdUseCase>((ref) {
  return GetBovineByIdUseCase(ref.watch(livestockRepositoryProvider));
});
