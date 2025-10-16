import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../../../../core/di/injection.dart';
import '../../domain/usecases/create_defensivo_usecase.dart';
import '../../domain/usecases/create_diagnostico_usecase.dart';
import '../../domain/usecases/delete_defensivo_usecase.dart';
import '../../domain/usecases/get_all_defensivos_usecase.dart';
import '../../domain/usecases/get_defensivo_info_by_defensivo_id_usecase.dart';
import '../../domain/usecases/get_diagnosticos_by_defensivo_id_usecase.dart';
import '../../domain/usecases/save_defensivo_info_usecase.dart';
import '../../domain/usecases/search_defensivos_usecase.dart';
import '../../domain/usecases/update_defensivo_usecase.dart';

part 'defensivos_usecases_providers.g.dart';

// ============================================================================
// DEFENSIVOS USE CASES
// ============================================================================

@riverpod
GetAllDefensivosUseCase getAllDefensivosUseCase(
  GetAllDefensivosUseCaseRef ref,
) {
  return getIt<GetAllDefensivosUseCase>();
}

@riverpod
SearchDefensivosUseCase searchDefensivosUseCase(
  SearchDefensivosUseCaseRef ref,
) {
  return getIt<SearchDefensivosUseCase>();
}

@riverpod
CreateDefensivoUseCase createDefensivoUseCase(
  CreateDefensivoUseCaseRef ref,
) {
  return getIt<CreateDefensivoUseCase>();
}

@riverpod
UpdateDefensivoUseCase updateDefensivoUseCase(
  UpdateDefensivoUseCaseRef ref,
) {
  return getIt<UpdateDefensivoUseCase>();
}

@riverpod
DeleteDefensivoUseCase deleteDefensivoUseCase(
  DeleteDefensivoUseCaseRef ref,
) {
  return getIt<DeleteDefensivoUseCase>();
}

// ============================================================================
// DIAGNOSTICOS USE CASES
// ============================================================================

@riverpod
GetDiagnosticosByDefensivoIdUseCase getDiagnosticosByDefensivoIdUseCase(
  GetDiagnosticosByDefensivoIdUseCaseRef ref,
) {
  return getIt<GetDiagnosticosByDefensivoIdUseCase>();
}

@riverpod
CreateDiagnosticoUseCase createDiagnosticoUseCase(
  CreateDiagnosticoUseCaseRef ref,
) {
  return getIt<CreateDiagnosticoUseCase>();
}

// ============================================================================
// DEFENSIVOS INFO USE CASES
// ============================================================================

@riverpod
GetDefensivoInfoByDefensivoIdUseCase getDefensivoInfoByDefensivoIdUseCase(
  GetDefensivoInfoByDefensivoIdUseCaseRef ref,
) {
  return getIt<GetDefensivoInfoByDefensivoIdUseCase>();
}

@riverpod
SaveDefensivoInfoUseCase saveDefensivoInfoUseCase(
  SaveDefensivoInfoUseCaseRef ref,
) {
  return getIt<SaveDefensivoInfoUseCase>();
}
