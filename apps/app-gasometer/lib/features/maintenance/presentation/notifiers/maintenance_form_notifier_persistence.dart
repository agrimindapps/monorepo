part of 'maintenance_form_notifier.dart';

// ignore_for_file: invalid_use_of_protected_member
// ignore_for_file: invalid_use_of_visible_for_testing_member

/// Extension for persistence-related methods of MaintenanceFormNotifier
extension MaintenanceFormNotifierPersistence on MaintenanceFormNotifier {
  /// Atualiza tipo de manutenção
  void updateType(MaintenanceType type) {
    if (state.type == type) return;

    state = state
        .copyWith(type: type, hasChanges: true)
        .clearFieldError('type');
  }

  /// Atualiza status da manutenção
  void updateStatus(MaintenanceStatus status) {
    if (state.status == status) return;

    state = state
        .copyWith(status: status, hasChanges: true)
        .clearFieldError('status');
  }

  /// Atualiza data do serviço
  void updateServiceDate(DateTime date) {
    if (state.serviceDate == date) return;

    state = state
        .copyWith(serviceDate: date, hasChanges: true)
        .clearFieldError('serviceDate');
  }

  /// Atualiza data da próxima manutenção
  void updateNextServiceDate(DateTime? date) {
    if (state.nextServiceDate == date) return;

    state = state
        .copyWith(nextServiceDate: date, hasChanges: true)
        .clearFieldError('nextServiceDate');
  }

  /// Salva o registro de manutenção (criar ou atualizar)
  Future<Either<Failure, MaintenanceEntity?>> saveMaintenanceRecord() async {
    try {
      if (!validateForm()) {
        final firstError = state.fieldErrors.values.isNotEmpty
            ? state.fieldErrors.values.first
            : 'Formulário inválido';
        return Left(ValidationFailure(firstError));
      }

      state = state.copyWith(isLoading: true, errorMessage: () => null);

      final maintenanceEntity = _entityBuilder.buildFromForm(
        state: state,
        title: titleController.text,
        description: descriptionController.text,
        cost: costController.text,
        odometer: odometerController.text,
        workshopName: workshopNameController.text,
        workshopPhone: workshopPhoneController.text,
        workshopAddress: workshopAddressController.text,
        nextOdometer: nextOdometerController.text,
        notes: notesController.text,
      );

      final Either<Failure, MaintenanceEntity> result;
      final isNewRecord = state.id.isEmpty;

      if (isNewRecord) {
        result = await _addMaintenanceRecord(
          AddMaintenanceRecordParams(maintenance: maintenanceEntity),
        );
      } else {
        result = await _updateMaintenanceRecord(
          UpdateMaintenanceRecordParams(maintenance: maintenanceEntity),
        );
      }

      state = state.copyWith(isLoading: false);
      
      return result.fold(
        (failure) => Left(failure),
        (entity) {
          // 📊 Analytics: Track maintenance only for new records
          if (isNewRecord) {
            _trackMaintenance(entity);
          }
          return Right(entity);
        },
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: () => 'Erro ao salvar: ${e.toString()}',
      );
      return Left(UnexpectedFailure('Erro ao salvar: ${e.toString()}'));
    }
  }

  /// 📊 Track maintenance event to Firebase Analytics
  void _trackMaintenance(MaintenanceEntity entity) {
    try {
      _analyticsService.logMaintenance(
        maintenanceType: entity.type.displayName,
        cost: entity.cost,
        odometer: entity.odometer.toInt(),
      );
      if (kDebugMode) {
        debugPrint('📊 [Analytics] Maintenance tracked: ${entity.type.displayName}');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('📊 [Analytics] Error tracking maintenance: $e');
      }
    }
  }

  /// Limpa formulário
  void clearForm() {
    _controllerManager.clearAll();

    state = MaintenanceFormState.initial(
      vehicleId: state.vehicleId,
      userId: state.userId,
    ).copyWith(vehicle: state.vehicle);
  }

  /// Reseta formulário
  void resetForm() {
    clearForm();
    state = state.copyWith(
      hasChanges: false,
      fieldErrors: const {},
      errorMessage: () => null,
      imageUploadError: () => null,
      clearReceiptImage: true,
      clearReceiptUrl: true,
    );
  }
}
