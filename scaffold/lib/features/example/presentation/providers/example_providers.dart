import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:core/core.dart';
import '../../data/datasources/local/example_local_datasource.dart';
import '../../data/datasources/remote/example_remote_datasource.dart';
import '../../data/repositories/example_repository_impl.dart';
import '../../domain/repositories/example_repository.dart';
import '../../domain/usecases/add_example_usecase.dart';
import '../../domain/usecases/update_example_usecase.dart';
import '../../domain/usecases/delete_example_usecase.dart';
import '../../domain/usecases/get_examples_usecase.dart';
import '../../domain/usecases/get_example_by_id_usecase.dart';

part 'example_providers.g.dart'; // Generated file

// Data Sources
@riverpod
ExampleLocalDataSource exampleLocalDataSource(ExampleLocalDataSourceRef ref) {
  return ExampleLocalDataSource();
}

@riverpod
ExampleRemoteDataSource exampleRemoteDataSource(
  ExampleRemoteDataSourceRef ref,
) {
  // Get FirebaseFirestore from DI or provider
  final firestore = getIt<FirebaseFirestore>(); // Assuming GetIt setup
  return ExampleRemoteDataSource(firestore);
}

// Repository
@riverpod
ExampleRepository exampleRepository(ExampleRepositoryRef ref) {
  return ExampleRepositoryImpl(
    localDataSource: ref.watch(exampleLocalDataSourceProvider),
    remoteDataSource: ref.watch(exampleRemoteDataSourceProvider),
  );
}

// Use Cases
@riverpod
AddExampleUseCase addExampleUseCase(AddExampleUseCaseRef ref) {
  return AddExampleUseCase(ref.watch(exampleRepositoryProvider));
}

@riverpod
UpdateExampleUseCase updateExampleUseCase(UpdateExampleUseCaseRef ref) {
  return UpdateExampleUseCase(ref.watch(exampleRepositoryProvider));
}

@riverpod
DeleteExampleUseCase deleteExampleUseCase(DeleteExampleUseCaseRef ref) {
  return DeleteExampleUseCase(ref.watch(exampleRepositoryProvider));
}

@riverpod
GetExamplesUseCase getExamplesUseCase(GetExamplesUseCaseRef ref) {
  return GetExamplesUseCase(ref.watch(exampleRepositoryProvider));
}

@riverpod
GetExampleByIdUseCase getExampleByIdUseCase(GetExampleByIdUseCaseRef ref) {
  return GetExampleByIdUseCase(ref.watch(exampleRepositoryProvider));
}
