import 'package:dartz/dartz.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/providers/dependency_providers.dart';
import '../../domain/entities/praga.dart';
import '../../domain/entities/praga_info.dart';
import '../../domain/entities/planta_info.dart';
import '../../domain/entities/tipo_praga.dart';

part 'praga_detalhes_provider.g.dart';

/// State class for praga details
class PragaDetalhesState {
  final Praga? praga;
  final PragaInfo? pragaInfo;
  final PlantaInfo? plantaInfo;
  final bool isLoading;
  final String? error;

  const PragaDetalhesState({
    this.praga,
    this.pragaInfo,
    this.plantaInfo,
    this.isLoading = false,
    this.error,
  });

  PragaDetalhesState copyWith({
    Praga? praga,
    PragaInfo? pragaInfo,
    PlantaInfo? plantaInfo,
    bool? isLoading,
    String? error,
  }) {
    return PragaDetalhesState(
      praga: praga ?? this.praga,
      pragaInfo: pragaInfo ?? this.pragaInfo,
      plantaInfo: plantaInfo ?? this.plantaInfo,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

/// Provider for managing praga detalhes state
@riverpod
class PragaDetalhes extends _$PragaDetalhes {
  @override
  PragaDetalhesState build() {
    return const PragaDetalhesState();
  }

  /// Load praga and its related info
  Future<Either<Failure, Praga>> loadPraga(String pragaId) async {
    state = state.copyWith(isLoading: true, error: null);

    final repository = ref.read(pragasRepositoryProvider);
    final result = await repository.getPragaById(pragaId);

    return result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, error: failure.message);
        return Left(failure);
      },
      (praga) async {
        state = state.copyWith(praga: praga);

        // Load related info based on tipoPraga
        if (praga.tipoPraga?.usesPlantaInfo == true) {
          await _loadPlantaInfo(pragaId);
        } else {
          await _loadPragaInfo(pragaId);
        }

        state = state.copyWith(isLoading: false);
        return Right(praga);
      },
    );
  }

  Future<void> _loadPragaInfo(String pragaId) async {
    final useCase = ref.read(getPragaInfoUseCaseProvider);
    final result = await useCase(pragaId);

    result.fold(
      (failure) {
        // If not found, we just don't have info yet
      },
      (info) {
        state = state.copyWith(pragaInfo: info);
      },
    );
  }

  Future<void> _loadPlantaInfo(String pragaId) async {
    final useCase = ref.read(getPlantaInfoUseCaseProvider);
    final result = await useCase(pragaId);

    result.fold(
      (failure) {
        // If not found, we just don't have info yet
      },
      (info) {
        state = state.copyWith(plantaInfo: info);
      },
    );
  }

  /// Save praga info (for insects/diseases)
  Future<Either<Failure, PragaInfo>> savePragaInfo(PragaInfo info) async {
    final useCase = ref.read(savePragaInfoUseCaseProvider);
    final result = await useCase(info);

    return result.fold(
      (failure) => Left(failure),
      (savedInfo) {
        state = state.copyWith(pragaInfo: savedInfo);
        return Right(savedInfo);
      },
    );
  }

  /// Save planta info (for weeds)
  Future<Either<Failure, PlantaInfo>> savePlantaInfo(PlantaInfo info) async {
    final useCase = ref.read(savePlantaInfoUseCaseProvider);
    final result = await useCase(info);

    return result.fold(
      (failure) => Left(failure),
      (savedInfo) {
        state = state.copyWith(plantaInfo: savedInfo);
        return Right(savedInfo);
      },
    );
  }

  /// Update praga tipoPraga
  Future<Either<Failure, Praga>> updateTipoPraga(TipoPraga tipoPraga) async {
    if (state.praga == null) {
      return const Left(ValidationFailure('Praga não carregada'));
    }

    final updatedPraga = state.praga!.copyWith(
      tipoPraga: tipoPraga,
      updatedAt: DateTime.now(),
    );

    final useCase = ref.read(updatePragaUseCaseProvider);
    final result = await useCase(updatedPraga);

    return result.fold(
      (failure) => Left(failure),
      (praga) {
        state = state.copyWith(praga: praga);
        return Right(praga);
      },
    );
  }
}
