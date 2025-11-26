import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/providers/dependency_providers.dart';
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
// DEFENSIVOS USE CASES (using dependency_providers.dart)
// ============================================================================

@riverpod
GetAllDefensivosUseCase getAllDefensivosUseCaseLocal(Ref ref) {
  return ref.watch(getAllDefensivosUseCaseProvider);
}

@riverpod
SearchDefensivosUseCase searchDefensivosUseCaseLocal(Ref ref) {
  return ref.watch(searchDefensivosUseCaseProvider);
}

@riverpod
CreateDefensivoUseCase createDefensivoUseCaseLocal(Ref ref) {
  return ref.watch(createDefensivoUseCaseProvider);
}

@riverpod
UpdateDefensivoUseCase updateDefensivoUseCaseLocal(Ref ref) {
  return ref.watch(updateDefensivoUseCaseProvider);
}

@riverpod
DeleteDefensivoUseCase deleteDefensivoUseCaseLocal(Ref ref) {
  return ref.watch(deleteDefensivoUseCaseProvider);
}

// ============================================================================
// DIAGNOSTICOS USE CASES
// ============================================================================

@riverpod
GetDiagnosticosByDefensivoIdUseCase getDiagnosticosByDefensivoIdUseCaseLocal(
    Ref ref) {
  return ref.watch(getDiagnosticosByDefensivoIdUseCaseProvider);
}

@riverpod
CreateDiagnosticoUseCase createDiagnosticoUseCaseLocal(Ref ref) {
  return ref.watch(createDiagnosticoUseCaseProvider);
}

// ============================================================================
// DEFENSIVOS INFO USE CASES
// ============================================================================

@riverpod
GetDefensivoInfoByDefensivoIdUseCase getDefensivoInfoByDefensivoIdUseCaseLocal(
    Ref ref) {
  return ref.watch(getDefensivoInfoByDefensivoIdUseCaseProvider);
}

@riverpod
SaveDefensivoInfoUseCase saveDefensivoInfoUseCaseLocal(Ref ref) {
  return ref.watch(saveDefensivoInfoUseCaseProvider);
}
