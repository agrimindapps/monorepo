part of 'fuel_form_notifier.dart';

/// Extension for FuelFormNotifier CRUD operations
extension FuelFormNotifierCrud on FuelFormNotifier {
  /// Saves the fuel record (create or update)
  Future<Either<Failure, FuelRecordEntity?>> saveFuelRecord() async {
    try {
      final (isValid, firstErrorField) = validateForm();
      if (!isValid) {
        final errorMsg = firstErrorField != null
            ? state.formModel.errors[firstErrorField] ?? 'Formulário inválido'
            : 'Formulário inválido';
        return Left(ValidationFailure(errorMsg));
      }

      state = state.copyWith(isLoading: true, clearError: true);

      final fuelEntity = state.formModel.toFuelRecord();
      bool success = false;

      if (state.formModel.id.isEmpty) {
        success = await ref
            .read(fuelRiverpodProvider.notifier)
            .addFuelRecord(fuelEntity);
      } else {
        success = await ref
            .read(fuelRiverpodProvider.notifier)
            .updateFuelRecord(fuelEntity);
      }

      state = state.copyWith(isLoading: false);

      if (success) {
        return Right(fuelEntity);
      } else {
        final error = ref.read(fuelRiverpodProvider).value?.errorMessage ??
            'Erro desconhecido ao salvar';
        return Left(UnexpectedFailure(error));
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        lastError: 'Erro ao salvar: ${e.toString()}',
      );
      return Left(UnexpectedFailure('Erro ao salvar: ${e.toString()}'));
    }
  }
}
