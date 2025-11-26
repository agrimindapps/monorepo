import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Culturas imports
import '../../features/culturas/data/datasources/culturas_local_datasource.dart';
import '../../features/culturas/data/datasources/culturas_remote_datasource.dart';
import '../../features/culturas/data/repositories/culturas_repository_impl.dart';
import '../../features/culturas/domain/repositories/culturas_repository.dart';
import '../../features/culturas/domain/usecases/get_cultura_by_id_usecase.dart';
import '../../features/culturas/domain/usecases/get_culturas_usecase.dart';

// Defensivos imports
import '../../features/defensivos/data/datasources/defensivos_local_datasource.dart';
import '../../features/defensivos/data/datasources/defensivos_remote_datasource.dart';
import '../../features/defensivos/data/repositories/defensivos_repository_impl.dart';
import '../../features/defensivos/domain/repositories/defensivos_repository.dart';
import '../../features/defensivos/domain/usecases/get_defensivo_by_id_usecase.dart';
import '../../features/defensivos/domain/usecases/get_defensivos_usecase.dart';

// Pragas imports
import '../../features/pragas/data/datasources/pragas_local_datasource.dart';
import '../../features/pragas/data/datasources/pragas_remote_datasource.dart';
import '../../features/pragas/data/repositories/pragas_repository_impl.dart';
import '../../features/pragas/domain/repositories/pragas_repository.dart';
import '../../features/pragas/domain/usecases/get_praga_by_id_usecase.dart';
import '../../features/pragas/domain/usecases/get_pragas_usecase.dart';

// =============================================================================
// EXTERNAL DEPENDENCIES
// =============================================================================

/// Provider for SharedPreferences
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError(
    'sharedPreferencesProvider must be overridden in ProviderScope',
  );
});

/// Provider for SupabaseClient
final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});

// =============================================================================
// CULTURAS DEPENDENCIES
// =============================================================================

/// Provider for CulturasRemoteDataSource
final culturasRemoteDataSourceProvider = Provider<CulturasRemoteDataSource>((ref) {
  final supabase = ref.watch(supabaseClientProvider);
  return CulturasRemoteDataSourceImpl(supabase);
});

/// Provider for CulturasLocalDataSource
final culturasLocalDataSourceProvider = Provider<CulturasLocalDataSource>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return CulturasLocalDataSourceImpl(prefs);
});

/// Provider for ICulturasRepository
final culturasRepositoryProvider = Provider<ICulturasRepository>((ref) {
  return CulturasRepositoryImpl(
    remoteDataSource: ref.watch(culturasRemoteDataSourceProvider),
    localDataSource: ref.watch(culturasLocalDataSourceProvider),
  );
});

/// Provider for GetCulturasUseCase
final getCulturasUseCaseProvider = Provider<GetCulturasUseCase>((ref) {
  return GetCulturasUseCase(ref.watch(culturasRepositoryProvider));
});

/// Provider for GetCulturaByIdUseCase
final getCulturaByIdUseCaseProvider = Provider<GetCulturaByIdUseCase>((ref) {
  return GetCulturaByIdUseCase(ref.watch(culturasRepositoryProvider));
});

// =============================================================================
// DEFENSIVOS DEPENDENCIES
// =============================================================================

/// Provider for DefensivosRemoteDataSource
final defensivosRemoteDataSourceProvider = Provider<DefensivosRemoteDataSource>((ref) {
  final supabase = ref.watch(supabaseClientProvider);
  return DefensivosRemoteDataSourceImpl(supabase);
});

/// Provider for DefensivosLocalDataSource
final defensivosLocalDataSourceProvider = Provider<DefensivosLocalDataSource>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return DefensivosLocalDataSourceImpl(prefs);
});

/// Provider for IDefensivosRepository
final defensivosRepositoryProvider = Provider<IDefensivosRepository>((ref) {
  return DefensivosRepositoryImpl(
    remoteDataSource: ref.watch(defensivosRemoteDataSourceProvider),
    localDataSource: ref.watch(defensivosLocalDataSourceProvider),
  );
});

/// Provider for GetDefensivosUseCase
final getDefensivosUseCaseProvider = Provider<GetDefensivosUseCase>((ref) {
  return GetDefensivosUseCase(ref.watch(defensivosRepositoryProvider));
});

/// Provider for GetDefensivoByIdUseCase
final getDefensivoByIdUseCaseProvider = Provider<GetDefensivoByIdUseCase>((ref) {
  return GetDefensivoByIdUseCase(ref.watch(defensivosRepositoryProvider));
});

// =============================================================================
// PRAGAS DEPENDENCIES
// =============================================================================

/// Provider for PragasRemoteDataSource
final pragasRemoteDataSourceProvider = Provider<PragasRemoteDataSource>((ref) {
  final supabase = ref.watch(supabaseClientProvider);
  return PragasRemoteDataSourceImpl(supabase);
});

/// Provider for PragasLocalDataSource
final pragasLocalDataSourceProvider = Provider<PragasLocalDataSource>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return PragasLocalDataSourceImpl(prefs);
});

/// Provider for IPragasRepository
final pragasRepositoryProvider = Provider<IPragasRepository>((ref) {
  return PragasRepositoryImpl(
    remoteDataSource: ref.watch(pragasRemoteDataSourceProvider),
    localDataSource: ref.watch(pragasLocalDataSourceProvider),
  );
});

/// Provider for GetPragasUseCase
final getPragasUseCaseProvider = Provider<GetPragasUseCase>((ref) {
  return GetPragasUseCase(ref.watch(pragasRepositoryProvider));
});

/// Provider for GetPragaByIdUseCase
final getPragaByIdUseCaseProvider = Provider<GetPragaByIdUseCase>((ref) {
  return GetPragaByIdUseCase(ref.watch(pragasRepositoryProvider));
});
