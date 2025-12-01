import 'package:core/core.dart' as core;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:core/core.dart';
import 'package:flutter/material.dart';

import '../../../../core/providers/dependency_providers.dart';
import '../../../../core/services/storage/firebase_storage_service.dart' as local_storage;
import '../../../../core/validation/input_sanitizer.dart';
import '../../../../features/receipt/domain/services/receipt_image_service.dart';
import '../../../vehicles/domain/usecases/get_vehicle_by_id.dart';
import '../../domain/entities/expense_entity.dart';
import '../../domain/usecases/add_expense.dart';
import '../../domain/usecases/update_expense.dart';
import '../helpers/helpers.dart';
import '../providers/expenses_providers.dart';
import 'expense_form_state.dart';

part 'expense_form_notifier.g.dart';

/// Notifier Riverpod para gerenciar o estado do formulário de despesas
///
/// Orquestra helpers especializados:
/// - [ExpenseFormControllerManager]: Gerenciamento de TextEditingControllers
/// - [ExpenseFormValidatorHandler]: Validação com debounce
/// - [ExpenseFormImageHandler]: Upload e processamento de imagens
/// - [ExpenseDatePickerHelper]: Date/Time pickers
@riverpod
class ExpenseFormNotifier extends _$ExpenseFormNotifier {
  late final ExpenseFormControllerManager _controllerManager;
  late final ExpenseFormValidatorHandler _validatorHandler;
  late final ExpenseFormImageHandler _imageHandler;
  late final ExpenseDatePickerHelper _datePickerHelper;
  late final GetVehicleById _getVehicleById;
  late final AddExpenseUseCase _addExpense;
  late final UpdateExpenseUseCase _updateExpense;

  TextEditingController get descriptionController =>
      _controllerManager.descriptionController;
  TextEditingController get amountController =>
      _controllerManager.amountController;
  TextEditingController get odometerController =>
      _controllerManager.odometerController;
  TextEditingController get locationController =>
      _controllerManager.locationController;
  TextEditingController get notesController =>
      _controllerManager.notesController;

  @override
  ExpenseFormState build() {
    _controllerManager = ExpenseFormControllerManager();
    _controllerManager.initialize();
    _validatorHandler = ExpenseFormValidatorHandler();
    _datePickerHelper = const ExpenseDatePickerHelper();
    
    final compressionService = core.ImageCompressionService();
    final storageService = local_storage.FirebaseStorageService();
    final connectivityService = ref.watch(connectivityServiceProvider);
    final imageSyncService = ref.watch(imageSyncServiceProvider);
    
    final receiptImageService = ReceiptImageService(
      compressionService,
      storageService,
      connectivityService,
      imageSyncService,
    );
    _imageHandler = ExpenseFormImageHandler(
      receiptImageService: receiptImageService,
    );
    
    _getVehicleById = ref.watch(getVehicleByIdProvider);
    _addExpense = ref.watch(addExpenseProvider);
    _updateExpense = ref.watch(updateExpenseProvider);
    
    _setupControllerListeners();
    ref.onDispose(_dispose);

    return const ExpenseFormState();
  }

  void _setupControllerListeners() {
    _controllerManager.addListeners(
      onDescriptionChanged: _onDescriptionChanged,
      onAmountChanged: _onAmountChanged,
      onOdometerChanged: _onOdometerChanged,
      onLocationChanged: _onLocationChanged,
      onNotesChanged: _onNotesChanged,
    );
  }

  void _dispose() {
    _validatorHandler.dispose();
    _controllerManager.dispose();
  }

  Future<void> initialize({required String vehicleId, required String userId}) async {
    if (vehicleId.isEmpty) {
      state = state.copyWith(errorMessage: () => 'Nenhum veículo selecionado');
      return;
    }
    state = state.copyWith(isLoading: true);
    try {
      final vehicleResult = await _getVehicleById(GetVehicleByIdParams(vehicleId: vehicleId));
      await vehicleResult.fold(
        (failure) async => state = state.copyWith(isLoading: false, errorMessage: () => failure.message),
        (vehicle) async {
          state = ExpenseFormState.initial(vehicleId: vehicleId, userId: userId)
              .copyWith(vehicle: vehicle, odometer: vehicle.currentOdometer, isLoading: false);
          _controllerManager.updateFromState(state);
        },
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: () => 'Erro ao inicializar formulário: $e');
    }
  }

  Future<void> initializeWithExpense(ExpenseEntity expense) async {
    state = state.copyWith(isLoading: true);
    try {
      final vehicleResult = await _getVehicleById(GetVehicleByIdParams(vehicleId: expense.vehicleId));
      await vehicleResult.fold(
        (failure) async => state = state.copyWith(isLoading: false, errorMessage: () => failure.message),
        (vehicle) async {
          state = ExpenseFormState.fromExpense(expense).copyWith(vehicle: vehicle, isLoading: false);
          _controllerManager.updateFromState(state);
        },
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: () => 'Erro ao carregar despesa: $e');
    }
  }

  // ============================================================
  // Controller Change Handlers
  // ============================================================

  void _onDescriptionChanged() {
    _validatorHandler.validateDescriptionWithDebounce(
      value: descriptionController.text,
      onSanitizedValue: (sanitized) => state = state
          .copyWith(description: sanitized, hasChanges: true)
          .clearFieldError('description'),
      onSuggestedType: (type) { if (type != null) updateExpenseType(type); },
      currentType: state.expenseType,
    );
  }

  void _onAmountChanged() {
    _validatorHandler.validateAmountWithDebounce(
      value: amountController.text,
      onParsedValue: (value) => state = state
          .copyWith(amount: value, hasChanges: true)
          .clearFieldError('amount'),
    );
  }

  void _onOdometerChanged() {
    _validatorHandler.validateOdometerWithDebounce(
      value: odometerController.text,
      onParsedValue: (value) => state = state
          .copyWith(odometer: value, hasChanges: true)
          .clearFieldError('odometer'),
    );
  }

  void _onLocationChanged() {
    final sanitized = _validatorHandler.sanitizeLocation(locationController.text);
    state = state.copyWith(location: sanitized, hasChanges: true).clearFieldError('location');
  }

  void _onNotesChanged() {
    final sanitized = _validatorHandler.sanitizeNotes(notesController.text);
    state = state.copyWith(notes: sanitized, hasChanges: true).clearFieldError('notes');
  }

  // ============================================================
  // State Updates
  // ============================================================

  void updateExpenseType(ExpenseType expenseType) {
    if (state.expenseType == expenseType) return;
    state = state.copyWith(expenseType: expenseType, hasChanges: true).clearFieldError('expenseType');
  }

  void updateDate(DateTime date) {
    if (state.date == date) return;
    state = state.copyWith(date: date, hasChanges: true).clearFieldError('date');
  }

  void clearError() {
    state = state.clearError();
  }

  /// Limpa erro de imagem
  void clearImageError() {
    state = state.clearImageError();
  }

  // ============================================================
  // Validation
  // ============================================================

  /// Valida campo específico (para TextFormField)
  String? validateField(String field, String? value) {
    return _validatorHandler.validateField(
      field,
      value,
      expenseType: state.expenseType,
      currentOdometer: state.vehicle?.currentOdometer,
    );
  }

  bool validateForm() {
    final errors = _validatorHandler.validator.validateCompleteForm(
      expenseType: state.expenseType,
      description: descriptionController.text,
      amount: amountController.text,
      odometer: odometerController.text,
      date: state.date,
      location: locationController.text,
      notes: notesController.text,
      vehicle: state.vehicle,
    );
    state = state.copyWith(fieldErrors: errors);
    return errors.isEmpty;
  }

  // ============================================================
  // Date/Time Pickers
  // ============================================================

  Future<void> pickDate(BuildContext context) async {
    final newDateTime = await _datePickerHelper.pickDate(context, initialDate: state.date);
    if (newDateTime != null) updateDate(newDateTime);
  }

  Future<void> pickTime(BuildContext context) async {
    final newDateTime = await _datePickerHelper.pickTime(context, initialDateTime: state.date);
    if (newDateTime != null) updateDate(newDateTime);
  }

  // ============================================================
  // Image Operations
  // ============================================================

  Future<void> captureReceiptImage() async {
    state = state.copyWith(isUploadingImage: true).clearImageError();
    _handleImageResult(await _imageHandler.captureAndProcessImage(
      userId: state.userId, expenseId: _imageHandler.generateTemporaryId()));
  }

  Future<void> selectReceiptImageFromGallery() async {
    state = state.copyWith(isUploadingImage: true).clearImageError();
    _handleImageResult(await _imageHandler.selectFromGalleryAndProcess(
      userId: state.userId, expenseId: _imageHandler.generateTemporaryId()));
  }

  void _handleImageResult(Either<Failure, ImageProcessingResult> result) {
    result.fold(
      (failure) => state = state.copyWith(isUploadingImage: false, imageUploadError: () => failure.message),
      (imageResult) => state = state.copyWith(
        receiptImagePath: imageResult.localPath,
        receiptImageUrl: imageResult.downloadUrl,
        hasChanges: true,
        isUploadingImage: false,
      ),
    );
  }

  Future<void> removeReceiptImage() async {
    final result = await _imageHandler.removeImage(
      localPath: state.receiptImagePath,
      downloadUrl: state.receiptImageUrl,
    );
    result.fold(
      (failure) => state = state.copyWith(imageUploadError: () => failure.message),
      (_) => state = state.copyWith(
        hasChanges: true,
        clearReceiptImage: true,
        clearReceiptUrl: true,
      ).clearImageError(),
    );
  }

  Future<void> syncImageToFirebase(String actualExpenseId) async {
    if (state.receiptImagePath == null || state.receiptImageUrl != null) return;

    state = state.copyWith(isUploadingImage: true);
    final result = await _imageHandler.syncImageToFirebase(
      localPath: state.receiptImagePath!,
      userId: state.userId,
      expenseId: actualExpenseId,
    );
    result.fold(
      (_) => state = state.copyWith(isUploadingImage: false),
      (downloadUrl) => state = state.copyWith(
        receiptImageUrl: downloadUrl,
        isUploadingImage: false,
      ),
    );
  }

  // ============================================================
  // Save Operations
  // ============================================================

  Future<Either<Failure, ExpenseEntity?>> saveExpenseRecord() async {
    try {
      if (!validateForm()) {
        final firstError = state.fieldErrors.values.isNotEmpty
            ? state.fieldErrors.values.first
            : 'Formulário inválido';
        return Left(ValidationFailure(firstError));
      }

      state = state.copyWith(isLoading: true, errorMessage: () => null);
      final expenseEntity = _buildExpenseEntity();
      final result = state.id.isEmpty
          ? await _addExpense(expenseEntity)
          : await _updateExpense(expenseEntity);
      state = state.copyWith(isLoading: false);
      return result;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: () => 'Erro ao salvar: ${e.toString()}',
      );
      return Left(UnexpectedFailure('Erro ao salvar: ${e.toString()}'));
    }
  }

  ExpenseEntity _buildExpenseEntity() {
    final sanitizedDescription = InputSanitizer.sanitizeDescription(
      descriptionController.text,
    );
    final sanitizedLocation = InputSanitizer.sanitize(locationController.text);
    final sanitizedNotes = InputSanitizer.sanitizeDescription(
      notesController.text,
    );
    final amount = _validatorHandler.formatter.parseFormattedAmount(
      amountController.text,
    );
    final odometer = _validatorHandler.formatter.parseFormattedOdometer(
      odometerController.text,
    );
    final now = DateTime.now();

    return ExpenseEntity(
      id: state.id.isEmpty ? now.millisecondsSinceEpoch.toString() : state.id,
      vehicleId: state.vehicleId,
      userId: state.userId,
      type: state.expenseType,
      description: sanitizedDescription,
      amount: amount,
      odometer: odometer,
      date: state.date ?? now,
      location: sanitizedLocation.isNotEmpty ? sanitizedLocation : null,
      notes: sanitizedNotes.isNotEmpty ? sanitizedNotes : null,
      receiptImagePath: state.receiptImagePath,
      createdAt: state.id.isEmpty
          ? now
          : DateTime.fromMillisecondsSinceEpoch(
              int.tryParse(state.id) ?? now.millisecondsSinceEpoch,
            ),
      updatedAt: now,
    );
  }

  // ============================================================
  // Form Reset
  // ============================================================

  void clearForm() {
    _controllerManager.clearAll();
    state = ExpenseFormState.initial(
      vehicleId: state.vehicleId,
      userId: state.userId,
    ).copyWith(vehicle: state.vehicle);
  }

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
