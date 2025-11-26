import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// ============================================================================
// AUTH
// ============================================================================
import '../../features/auth/data/datasources/auth_remote_datasource.dart';
import '../../features/auth/data/datasources/auth_supabase_datasource.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/get_current_user_usecase.dart';
import '../../features/auth/domain/usecases/login_usecase.dart';
import '../../features/auth/domain/usecases/logout_usecase.dart';

// ============================================================================
// CULTURAS
// ============================================================================
import '../../features/culturas/data/datasources/culturas_supabase_datasource.dart';
import '../../features/culturas/data/repositories/culturas_repository_impl.dart';
import '../../features/culturas/domain/repositories/culturas_repository.dart';
import '../../features/culturas/domain/usecases/create_cultura_usecase.dart';
import '../../features/culturas/domain/usecases/delete_cultura_usecase.dart';
import '../../features/culturas/domain/usecases/get_all_culturas_usecase.dart';
import '../../features/culturas/domain/usecases/update_cultura_usecase.dart';

// ============================================================================
// PRAGAS
// ============================================================================
import '../../features/pragas/data/datasources/pragas_supabase_datasource.dart';
import '../../features/pragas/data/repositories/pragas_repository_impl.dart';
import '../../features/pragas/domain/repositories/pragas_repository.dart';
import '../../features/pragas/domain/usecases/create_praga_usecase.dart';
import '../../features/pragas/domain/usecases/delete_praga_usecase.dart';
import '../../features/pragas/domain/usecases/get_all_pragas_usecase.dart';
import '../../features/pragas/domain/usecases/update_praga_usecase.dart';

// ============================================================================
// DEFENSIVOS
// ============================================================================
import '../../features/defensivos/data/datasources/defensivos_remote_datasource.dart';
import '../../features/defensivos/data/datasources/defensivos_supabase_datasource.dart';
import '../../features/defensivos/data/datasources/defensivos_info_remote_datasource.dart';
import '../../features/defensivos/data/datasources/defensivos_info_supabase_datasource.dart';
import '../../features/defensivos/data/datasources/diagnosticos_remote_datasource.dart';
import '../../features/defensivos/data/datasources/diagnosticos_supabase_datasource.dart';
import '../../features/defensivos/data/repositories/defensivos_repository_impl.dart';
import '../../features/defensivos/data/repositories/defensivos_info_repository_impl.dart';
import '../../features/defensivos/data/repositories/diagnosticos_repository_impl.dart';
import '../../features/defensivos/domain/repositories/defensivos_repository.dart';
import '../../features/defensivos/domain/repositories/defensivos_info_repository.dart';
import '../../features/defensivos/domain/repositories/diagnosticos_repository.dart';
import '../../features/defensivos/domain/usecases/create_defensivo_usecase.dart';
import '../../features/defensivos/domain/usecases/create_diagnostico_usecase.dart';
import '../../features/defensivos/domain/usecases/delete_defensivo_usecase.dart';
import '../../features/defensivos/domain/usecases/get_all_defensivos_usecase.dart';
import '../../features/defensivos/domain/usecases/get_defensivo_info_by_defensivo_id_usecase.dart';
import '../../features/defensivos/domain/usecases/get_diagnosticos_by_defensivo_id_usecase.dart';
import '../../features/defensivos/domain/usecases/save_defensivo_info_usecase.dart';
import '../../features/defensivos/domain/usecases/search_defensivos_usecase.dart';
import '../../features/defensivos/domain/usecases/update_defensivo_usecase.dart';

// ============================================================================
// CORE - SUPABASE CLIENT
// ============================================================================

/// Supabase client provider
final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});

// ============================================================================
// AUTH PROVIDERS
// ============================================================================

/// Auth remote data source provider
final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return AuthSupabaseDataSource(client);
});

/// Auth repository provider
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final dataSource = ref.watch(authRemoteDataSourceProvider);
  return AuthRepositoryImpl(dataSource);
});

/// Login use case provider
final loginUseCaseProvider = Provider<LoginUseCase>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return LoginUseCase(repository);
});

/// Logout use case provider
final logoutUseCaseProvider = Provider<LogoutUseCase>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return LogoutUseCase(repository);
});

/// Get current user use case provider
final getCurrentUserUseCaseProvider = Provider<GetCurrentUserUseCase>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return GetCurrentUserUseCase(repository);
});

// ============================================================================
// CULTURAS PROVIDERS
// ============================================================================

/// Culturas remote data source provider
final culturasRemoteDataSourceProvider =
    Provider<CulturasRemoteDataSource>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return CulturasSupabaseDataSource(client);
});

/// Culturas repository provider
final culturasRepositoryProvider = Provider<CulturasRepository>((ref) {
  final dataSource = ref.watch(culturasRemoteDataSourceProvider);
  return CulturasRepositoryImpl(dataSource);
});

/// Get all culturas use case provider
final getAllCulturasUseCaseProvider = Provider<GetAllCulturasUseCase>((ref) {
  final repository = ref.watch(culturasRepositoryProvider);
  return GetAllCulturasUseCase(repository);
});

/// Create cultura use case provider
final createCulturaUseCaseProvider = Provider<CreateCulturaUseCase>((ref) {
  final repository = ref.watch(culturasRepositoryProvider);
  return CreateCulturaUseCase(repository);
});

/// Update cultura use case provider
final updateCulturaUseCaseProvider = Provider<UpdateCulturaUseCase>((ref) {
  final repository = ref.watch(culturasRepositoryProvider);
  return UpdateCulturaUseCase(repository);
});

/// Delete cultura use case provider
final deleteCulturaUseCaseProvider = Provider<DeleteCulturaUseCase>((ref) {
  final repository = ref.watch(culturasRepositoryProvider);
  return DeleteCulturaUseCase(repository);
});

// ============================================================================
// PRAGAS PROVIDERS
// ============================================================================

/// Pragas remote data source provider
final pragasRemoteDataSourceProvider = Provider<PragasRemoteDataSource>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return PragasSupabaseDataSource(client);
});

/// Pragas repository provider
final pragasRepositoryProvider = Provider<PragasRepository>((ref) {
  final dataSource = ref.watch(pragasRemoteDataSourceProvider);
  return PragasRepositoryImpl(dataSource);
});

/// Get all pragas use case provider
final getAllPragasUseCaseProvider = Provider<GetAllPragasUseCase>((ref) {
  final repository = ref.watch(pragasRepositoryProvider);
  return GetAllPragasUseCase(repository);
});

/// Create praga use case provider
final createPragaUseCaseProvider = Provider<CreatePragaUseCase>((ref) {
  final repository = ref.watch(pragasRepositoryProvider);
  return CreatePragaUseCase(repository);
});

/// Update praga use case provider
final updatePragaUseCaseProvider = Provider<UpdatePragaUseCase>((ref) {
  final repository = ref.watch(pragasRepositoryProvider);
  return UpdatePragaUseCase(repository);
});

/// Delete praga use case provider
final deletePragaUseCaseProvider = Provider<DeletePragaUseCase>((ref) {
  final repository = ref.watch(pragasRepositoryProvider);
  return DeletePragaUseCase(repository);
});

// ============================================================================
// DEFENSIVOS PROVIDERS
// ============================================================================

/// Defensivos remote data source provider
final defensivosRemoteDataSourceProvider =
    Provider<DefensivosRemoteDataSource>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return DefensivosSupabaseDataSource(client);
});

/// Defensivos repository provider
final defensivosRepositoryProvider = Provider<DefensivosRepository>((ref) {
  final dataSource = ref.watch(defensivosRemoteDataSourceProvider);
  return DefensivosRepositoryImpl(dataSource);
});

/// Get all defensivos use case provider
final getAllDefensivosUseCaseProvider =
    Provider<GetAllDefensivosUseCase>((ref) {
  final repository = ref.watch(defensivosRepositoryProvider);
  return GetAllDefensivosUseCase(repository);
});

/// Search defensivos use case provider
final searchDefensivosUseCaseProvider =
    Provider<SearchDefensivosUseCase>((ref) {
  final repository = ref.watch(defensivosRepositoryProvider);
  return SearchDefensivosUseCase(repository);
});

/// Create defensivo use case provider
final createDefensivoUseCaseProvider = Provider<CreateDefensivoUseCase>((ref) {
  final repository = ref.watch(defensivosRepositoryProvider);
  return CreateDefensivoUseCase(repository);
});

/// Update defensivo use case provider
final updateDefensivoUseCaseProvider = Provider<UpdateDefensivoUseCase>((ref) {
  final repository = ref.watch(defensivosRepositoryProvider);
  return UpdateDefensivoUseCase(repository);
});

/// Delete defensivo use case provider
final deleteDefensivoUseCaseProvider = Provider<DeleteDefensivoUseCase>((ref) {
  final defensivosRepository = ref.watch(defensivosRepositoryProvider);
  final diagnosticosRepository = ref.watch(diagnosticosRepositoryProvider);
  final defensivosInfoRepository = ref.watch(defensivosInfoRepositoryProvider);
  return DeleteDefensivoUseCase(
    defensivosRepository,
    diagnosticosRepository,
    defensivosInfoRepository,
  );
});

// ============================================================================
// DEFENSIVOS INFO PROVIDERS
// ============================================================================

/// Defensivos info remote data source provider
final defensivosInfoRemoteDataSourceProvider =
    Provider<DefensivosInfoRemoteDataSource>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return DefensivosInfoSupabaseDataSource(client);
});

/// Defensivos info repository provider
final defensivosInfoRepositoryProvider =
    Provider<DefensivosInfoRepository>((ref) {
  final dataSource = ref.watch(defensivosInfoRemoteDataSourceProvider);
  return DefensivosInfoRepositoryImpl(dataSource);
});

/// Get defensivo info by defensivo ID use case provider
final getDefensivoInfoByDefensivoIdUseCaseProvider =
    Provider<GetDefensivoInfoByDefensivoIdUseCase>((ref) {
  final repository = ref.watch(defensivosInfoRepositoryProvider);
  return GetDefensivoInfoByDefensivoIdUseCase(repository);
});

/// Save defensivo info use case provider
final saveDefensivoInfoUseCaseProvider =
    Provider<SaveDefensivoInfoUseCase>((ref) {
  final repository = ref.watch(defensivosInfoRepositoryProvider);
  return SaveDefensivoInfoUseCase(repository);
});

// ============================================================================
// DIAGNOSTICOS PROVIDERS
// ============================================================================

/// Diagnosticos remote data source provider
final diagnosticosRemoteDataSourceProvider =
    Provider<DiagnosticosRemoteDataSource>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return DiagnosticosSupabaseDataSource(client);
});

/// Diagnosticos repository provider
final diagnosticosRepositoryProvider = Provider<DiagnosticosRepository>((ref) {
  final dataSource = ref.watch(diagnosticosRemoteDataSourceProvider);
  return DiagnosticosRepositoryImpl(dataSource);
});

/// Get diagnosticos by defensivo ID use case provider
final getDiagnosticosByDefensivoIdUseCaseProvider =
    Provider<GetDiagnosticosByDefensivoIdUseCase>((ref) {
  final repository = ref.watch(diagnosticosRepositoryProvider);
  return GetDiagnosticosByDefensivoIdUseCase(repository);
});

/// Create diagnostico use case provider
final createDiagnosticoUseCaseProvider =
    Provider<CreateDiagnosticoUseCase>((ref) {
  final repository = ref.watch(diagnosticosRepositoryProvider);
  return CreateDiagnosticoUseCase(repository);
});
