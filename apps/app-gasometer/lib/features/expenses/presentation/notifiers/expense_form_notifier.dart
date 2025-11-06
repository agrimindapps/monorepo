import 'dart:async';

import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/di/injection.dart' as local_di;
import '../../../../core/services/input_sanitizer.dart';
import '../../../../core/services/receipt_image_service.dart';
import '../../../vehicles/domain/usecases/get_vehicle_by_id.dart';
import '../../core/constants/expense_constants.dart';
import '../../domain/entities/expense_entity.dart';
import '../../domain/services/expense_formatter_service.dart';
import '../../domain/services/expense_validation_service.dart';
import '../../domain/usecases/add_expense.dart';
import '../../domain/usecases/update_expense.dart';
import 'expense_form_state.dart';

part 'expense_form_notifier.g.dart';

/// Notifier Riverpod para gerenciar o estado do formulário de despesas
///
/// Features:
/// - Gerenciamento de campos de texto com TextEditingControllers
/// - Validação em tempo real com debounce
/// - Upload e processamento de imagens de comprovantes
/// - Sugestão automática de categoria baseada em descrição
/// - Sanitização de inputs para segurança
/// - Persistência offline com sincronização
@riverpod
class ExpenseFormNotifier extends _$ExpenseFormNotifier {
  late final TextEditingController descriptionController;
  late final TextEditingController amountController;
  late final TextEditingController odometerController;
  late final TextEditingController locationController;
  late final TextEditingController notesController;
  late final ExpenseFormatterService _formatter;
  late final ExpenseValidationService _validator;
  late final ReceiptImageService _receiptImageService;
  late final GetVehicleById _getVehicleById;
  late final ImagePicker _imagePicker;
  Timer? _amountDebounceTimer;
  Timer? _odometerDebounceTimer;
  Timer? _descriptionDebounceTimer;

  @override
  ExpenseFormState build() {
    descriptionController = TextEditingController();
    amountController = TextEditingController();
    odometerController = TextEditingController();
    locationController = TextEditingController();
    notesController = TextEditingController();
    _formatter = ExpenseFormatterService();
    _validator = const ExpenseValidationService();
    _receiptImageService = getIt<ReceiptImageService>();
    _getVehicleById = getIt<GetVehicleById>();
    _imagePicker = ImagePicker();
    _initializeControllers();
    ref.onDispose(() {
      _amountDebounceTimer?.cancel();
      _odometerDebounceTimer?.cancel();
      _descriptionDebounceTimer?.cancel();
      descriptionController.removeListener(_onDescriptionChanged);
      amountController.removeListener(_onAmountChanged);
      odometerController.removeListener(_onOdometerChanged);
      locationController.removeListener(_onLocationChanged);
      notesController.removeListener(_onNotesChanged);
      descriptionController.dispose();
      amountController.dispose();
      odometerController.dispose();
      locationController.dispose();
      notesController.dispose();
    });

    return const ExpenseFormState();
  }

  /// Adiciona listeners aos controllers
  void _initializeControllers() {
    descriptionController.addListener(_onDescriptionChanged);
    amountController.addListener(_onAmountChanged);
    odometerController.addListener(_onOdometerChanged);
    locationController.addListener(_onLocationChanged);
    notesController.addListener(_onNotesChanged);
  }

  /// Inicializa formulário para nova despesa
  Future<void> initialize({
    required String vehicleId,
    required String userId,
  }) async {
    if (vehicleId.isEmpty) {
      Future.microtask(() {
        state = state.copyWith(
          errorMessage: () => 'Nenhum veículo selecionado',
        );
      });
      return;
    }

    Future.microtask(() {
      state = state.copyWith(isLoading: true);
    });

    try {
      final vehicleResult = await _getVehicleById(
        GetVehicleByIdParams(vehicleId: vehicleId),
      );

      await vehicleResult.fold(
        (failure) async {
          state = state.copyWith(
            isLoading: false,
            errorMessage: () => failure.message,
          );
        },
        (vehicle) async {
          state = ExpenseFormState.initial(vehicleId: vehicleId, userId: userId)
              .copyWith(
                vehicle: vehicle,
                odometer: vehicle.currentOdometer,
                isLoading: false,
              );

          _updateTextControllers();
        },
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: () => 'Erro ao inicializar formulário: $e',
      );
    }
  }

  /// Inicializa com despesa existente para edição
  Future<void> initializeWithExpense(ExpenseEntity expense) async {
    Future.microtask(() {
      state = state.copyWith(isLoading: true);
    });

    try {
      final vehicleResult = await _getVehicleById(
        GetVehicleByIdParams(vehicleId: expense.vehicleId),
      );

      await vehicleResult.fold(
        (failure) async {
          state = state.copyWith(
            isLoading: false,
            errorMessage: () => failure.message,
          );
        },
        (vehicle) async {
          state = ExpenseFormState.fromExpense(
            expense,
          ).copyWith(vehicle: vehicle, isLoading: false);

          _updateTextControllers();
        },
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: () => 'Erro ao carregar despesa: $e',
      );
    }
  }

  /// Atualiza controllers com valores do estado
  void _updateTextControllers() {
    descriptionController.text = state.description;

    amountController.text = state.amount > 0
        ? _formatter.formatAmount(state.amount)
        : '';

    odometerController.text = state.odometer > 0
        ? _formatter.formatOdometer(state.odometer)
        : '';

    locationController.text = state.location;
    notesController.text = state.notes;
  }

  void _onDescriptionChanged() {
    _descriptionDebounceTimer?.cancel();
    _descriptionDebounceTimer = Timer(
      const Duration(milliseconds: ExpenseConstants.descriptionDebounceMs),
      () {
        final sanitized = InputSanitizer.sanitizeDescription(
          descriptionController.text,
        );

        state = state
            .copyWith(description: sanitized, hasChanges: true)
            .clearFieldError('description');
        if (sanitized.isNotEmpty && state.expenseType == ExpenseType.other) {
          final suggestedType = _validator.suggestCategoryFromDescription(
            sanitized,
          );
          if (suggestedType != ExpenseType.other) {
            updateExpenseType(suggestedType);
          }
        }
      },
    );
  }

  void _onAmountChanged() {
    _amountDebounceTimer?.cancel();
    _amountDebounceTimer = Timer(
      const Duration(milliseconds: ExpenseConstants.amountDebounceMs),
      () {
        final value = _formatter.parseFormattedAmount(amountController.text);

        state = state
            .copyWith(amount: value, hasChanges: true)
            .clearFieldError('amount');
      },
    );
  }

  void _onOdometerChanged() {
    _odometerDebounceTimer?.cancel();
    _odometerDebounceTimer = Timer(
      const Duration(milliseconds: ExpenseConstants.odometerDebounceMs),
      () {
        final value = _formatter.parseFormattedOdometer(
          odometerController.text,
        );

        state = state
            .copyWith(odometer: value, hasChanges: true)
            .clearFieldError('odometer');
      },
    );
  }

  void _onLocationChanged() {
    final sanitized = InputSanitizer.sanitize(locationController.text);

    state = state
        .copyWith(location: sanitized, hasChanges: true)
        .clearFieldError('location');
  }

  void _onNotesChanged() {
    final sanitized = InputSanitizer.sanitizeDescription(notesController.text);

    state = state
        .copyWith(notes: sanitized, hasChanges: true)
        .clearFieldError('notes');
  }

  /// Atualiza tipo de despesa
  void updateExpenseType(ExpenseType expenseType) {
    if (state.expenseType == expenseType) return;

    state = state
        .copyWith(expenseType: expenseType, hasChanges: true)
        .clearFieldError('expenseType');
  }

  /// Atualiza data
  void updateDate(DateTime date) {
    if (state.date == date) return;

    state = state
        .copyWith(date: date, hasChanges: true)
        .clearFieldError('date');
  }

  /// Limpa mensagem de erro
  void clearError() {
    state = state.clearError();
  }

  /// Limpa erro de imagem
  void clearImageError() {
    state = state.clearImageError();
  }

  /// Valida campo específico (para TextFormField)
  String? validateField(String field, String? value) {
    switch (field) {
      case 'description':
        return _validator.validateDescription(value);
      case 'amount':
        return _validator.validateAmount(value, expenseType: state.expenseType);
      case 'odometer':
        return _validator.validateOdometer(
          value,
          currentOdometer: state.vehicle?.currentOdometer,
        );
      case 'location':
        return _validator.validateLocation(value);
      case 'notes':
        return _validator.validateNotes(value);
      default:
        return null;
    }
  }

  /// Valida formulário completo
  bool validateForm() {
    final errors = _validator.validateCompleteForm(
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

  /// Abre picker de data
  Future<void> pickDate(BuildContext context) async {
    final date = await showDatePicker(
      context: context,
      initialDate: state.date ?? DateTime.now(),
      firstDate: DateTime.now().subtract(
        const Duration(days: 365 * ExpenseConstants.maxYearsBack),
      ),
      lastDate: DateTime.now(),
      locale: const Locale('pt', 'BR'),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: Colors.grey.shade800,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (date != null) {
      final currentTime = TimeOfDay.fromDateTime(state.date ?? DateTime.now());
      final newDateTime = DateTime(
        date.year,
        date.month,
        date.day,
        currentTime.hour,
        currentTime.minute,
      );
      updateDate(newDateTime);
    }
  }

  /// Abre picker de hora
  Future<void> pickTime(BuildContext context) async {
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(state.date ?? DateTime.now()),
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false),
          child: Localizations.override(
            context: context,
            locale: const Locale('pt', 'BR'),
            child: Theme(
              data: Theme.of(context).copyWith(
                colorScheme: Theme.of(context).colorScheme.copyWith(
                  primary: Theme.of(context).colorScheme.primary,
                ),
              ),
              child: child!,
            ),
          ),
        );
      },
    );

    if (time != null) {
      final currentDate = state.date ?? DateTime.now();
      final newDateTime = DateTime(
        currentDate.year,
        currentDate.month,
        currentDate.day,
        time.hour,
        time.minute,
      );
      updateDate(newDateTime);
    }
  }

  /// Captura imagem usando câmera
  Future<void> captureReceiptImage() async {
    try {
      state = state.clearImageError();

      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
        maxWidth: 1920,
        maxHeight: 1080,
      );

      if (image != null) {
        await _processReceiptImage(image.path);
      }
    } catch (e) {
      state = state.copyWith(
        imageUploadError: () => 'Erro ao capturar imagem: $e',
      );
    }
  }

  /// Seleciona imagem da galeria
  Future<void> selectReceiptImageFromGallery() async {
    try {
      state = state.clearImageError();

      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
        maxWidth: 1920,
        maxHeight: 1080,
      );

      if (image != null) {
        await _processReceiptImage(image.path);
      }
    } catch (e) {
      state = state.copyWith(
        imageUploadError: () => 'Erro ao selecionar imagem: $e',
      );
    }
  }

  /// Processa e faz upload da imagem do comprovante
  Future<void> _processReceiptImage(String imagePath) async {
    try {
      state = state.copyWith(isUploadingImage: true).clearImageError();
      final isValid = await _receiptImageService.isValidImage(imagePath);
      if (!isValid) {
        throw Exception('Arquivo de imagem inválido');
      }
      final result = await _receiptImageService.processExpenseReceiptImage(
        userId: state.userId,
        expenseId: _generateTemporaryId(),
        imagePath: imagePath,
        compressImage: true,
        uploadToFirebase: true,
      );

      state = state.copyWith(
        receiptImagePath: result.localPath,
        receiptImageUrl: result.downloadUrl,
        hasChanges: true,
        isUploadingImage: false,
      );

      debugPrint('[EXPENSE FORM] Image processed successfully');
      debugPrint('[EXPENSE FORM] Local path: ${result.localPath}');
      debugPrint('[EXPENSE FORM] Download URL: ${result.downloadUrl}');
    } catch (e) {
      state = state.copyWith(
        isUploadingImage: false,
        imageUploadError: () => 'Erro ao processar imagem: $e',
      );
      debugPrint('[EXPENSE FORM] Image processing error: $e');
    }
  }

  /// Remove imagem do comprovante
  Future<void> removeReceiptImage() async {
    try {
      if (state.receiptImagePath != null || state.receiptImageUrl != null) {
        await _receiptImageService.deleteReceiptImage(
          localPath: state.receiptImagePath,
          downloadUrl: state.receiptImageUrl,
        );
      }

      state = state
          .copyWith(
            hasChanges: true,
            clearReceiptImage: true,
            clearReceiptUrl: true,
          )
          .clearImageError();
    } catch (e) {
      state = state.copyWith(
        imageUploadError: () => 'Erro ao remover imagem: $e',
      );
    }
  }

  /// Sincroniza imagem local com Firebase (para casos offline)
  Future<void> syncImageToFirebase(String actualExpenseId) async {
    if (state.receiptImagePath == null || state.receiptImageUrl != null) {
      return; // Nada para sincronizar
    }

    try {
      state = state.copyWith(isUploadingImage: true);

      final result = await _receiptImageService.processExpenseReceiptImage(
        userId: state.userId,
        expenseId: actualExpenseId,
        imagePath: state.receiptImagePath!,
        compressImage: false, // Já foi comprimida
        uploadToFirebase: true,
      );

      state = state.copyWith(
        receiptImageUrl: result.downloadUrl,
        isUploadingImage: false,
      );

      debugPrint(
        '[EXPENSE FORM] Image synced to Firebase: ${result.downloadUrl}',
      );
    } catch (e) {
      debugPrint('[EXPENSE FORM] Failed to sync image: $e');
      state = state.copyWith(isUploadingImage: false);
    }
  }

  /// Gera ID temporário para processar imagem antes do save
  String _generateTemporaryId() {
    return 'temp_${DateTime.now().millisecondsSinceEpoch}';
  }

  /// Salva o registro de despesa (criar ou atualizar)
  Future<Either<Failure, ExpenseEntity?>> saveExpenseRecord() async {
    try {
      // Valida antes de salvar
      if (!validateForm()) {
        // Pega a primeira mensagem de erro
        final firstError = state.fieldErrors.values.isNotEmpty
            ? state.fieldErrors.values.first
            : 'Formulário inválido';
        return Left(ValidationFailure(firstError));
      }

      state = state.copyWith(isLoading: true, errorMessage: () => null);

      // Cria entidade a partir do formulário
      final expenseEntity = _buildExpenseEntity();

      // Decide se é criar ou atualizar
      final Either<Failure, ExpenseEntity?> result;

      if (state.id.isEmpty) {
        // Criar novo
        final addUseCase = local_di.getIt<AddExpenseUseCase>();
        result = await addUseCase(expenseEntity);
      } else {
        // Atualizar existente
        final updateUseCase = local_di.getIt<UpdateExpenseUseCase>();
        result = await updateUseCase(expenseEntity);
      }

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

  /// Constrói a entidade de despesa a partir do estado atual
  ExpenseEntity _buildExpenseEntity() {
    final sanitizedDescription = InputSanitizer.sanitizeDescription(
      descriptionController.text,
    );
    final sanitizedLocation = InputSanitizer.sanitize(locationController.text);
    final sanitizedNotes = InputSanitizer.sanitizeDescription(
      notesController.text,
    );

    final amount =
        double.tryParse(
          amountController.text
              .replaceAll(RegExp(r'[^\d,.]'), '')
              .replaceAll(',', '.'),
        ) ??
        0.0;

    final odometer =
        double.tryParse(
          odometerController.text
              .replaceAll(RegExp(r'[^\d,.]'), '')
              .replaceAll(',', '.'),
        ) ??
        0.0;

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

  /// Limpa formulário
  void clearForm() {
    descriptionController.clear();
    amountController.clear();
    odometerController.clear();
    locationController.clear();
    notesController.clear();

    state = ExpenseFormState.initial(
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
