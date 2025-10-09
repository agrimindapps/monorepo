import 'dart:async';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/services/input_sanitizer.dart';
import '../../../../core/services/receipt_image_service.dart';
import '../../../vehicles/domain/usecases/get_vehicle_by_id.dart';
import '../../core/constants/maintenance_constants.dart';
import '../../domain/entities/maintenance_entity.dart';
import '../../domain/services/maintenance_formatter_service.dart';
import '../../domain/services/maintenance_validator_service.dart';
import 'maintenance_form_state.dart';

part 'maintenance_form_notifier.g.dart';

/// Notifier Riverpod para gerenciar o estado do formulário de manutenção
///
/// Features:
/// - Gerenciamento de campos de texto com TextEditingControllers
/// - Validação em tempo real com debounce
/// - Upload e processamento de imagens de comprovantes
/// - Sugestão automática de tipo baseada em título
/// - Sanitização de inputs para segurança
/// - Agendamento de próxima manutenção
/// - Persistência offline com sincronização
@riverpod
class MaintenanceFormNotifier extends _$MaintenanceFormNotifier {
  late final TextEditingController titleController;
  late final TextEditingController descriptionController;
  late final TextEditingController costController;
  late final TextEditingController odometerController;
  late final TextEditingController workshopNameController;
  late final TextEditingController workshopPhoneController;
  late final TextEditingController workshopAddressController;
  late final TextEditingController nextOdometerController;
  late final TextEditingController notesController;
  late final MaintenanceFormatterService _formatter;
  late final MaintenanceValidatorService _validator;
  late final ReceiptImageService _receiptImageService;
  late final GetVehicleById _getVehicleById;
  late final ImagePicker _imagePicker;
  Timer? _costDebounceTimer;
  Timer? _odometerDebounceTimer;
  Timer? _titleDebounceTimer;
  Timer? _descriptionDebounceTimer;

  @override
  MaintenanceFormState build() {
    titleController = TextEditingController();
    descriptionController = TextEditingController();
    costController = TextEditingController();
    odometerController = TextEditingController();
    workshopNameController = TextEditingController();
    workshopPhoneController = TextEditingController();
    workshopAddressController = TextEditingController();
    nextOdometerController = TextEditingController();
    notesController = TextEditingController();
    _formatter = MaintenanceFormatterService();
    _validator = MaintenanceValidatorService();
    _receiptImageService = getIt<ReceiptImageService>();
    _getVehicleById = getIt<GetVehicleById>();
    _imagePicker = ImagePicker();
    _initializeControllers();
    ref.onDispose(() {
      _costDebounceTimer?.cancel();
      _odometerDebounceTimer?.cancel();
      _titleDebounceTimer?.cancel();
      _descriptionDebounceTimer?.cancel();
      titleController.removeListener(_onTitleChanged);
      descriptionController.removeListener(_onDescriptionChanged);
      costController.removeListener(_onCostChanged);
      odometerController.removeListener(_onOdometerChanged);
      workshopNameController.removeListener(_onWorkshopNameChanged);
      workshopPhoneController.removeListener(_onWorkshopPhoneChanged);
      workshopAddressController.removeListener(_onWorkshopAddressChanged);
      nextOdometerController.removeListener(_onNextOdometerChanged);
      notesController.removeListener(_onNotesChanged);
      titleController.dispose();
      descriptionController.dispose();
      costController.dispose();
      odometerController.dispose();
      workshopNameController.dispose();
      workshopPhoneController.dispose();
      workshopAddressController.dispose();
      nextOdometerController.dispose();
      notesController.dispose();
    });

    return const MaintenanceFormState();
  }

  /// Adiciona listeners aos controllers
  void _initializeControllers() {
    titleController.addListener(_onTitleChanged);
    descriptionController.addListener(_onDescriptionChanged);
    costController.addListener(_onCostChanged);
    odometerController.addListener(_onOdometerChanged);
    workshopNameController.addListener(_onWorkshopNameChanged);
    workshopPhoneController.addListener(_onWorkshopPhoneChanged);
    workshopAddressController.addListener(_onWorkshopAddressChanged);
    nextOdometerController.addListener(_onNextOdometerChanged);
    notesController.addListener(_onNotesChanged);
  }

  /// Inicializa formulário para nova manutenção
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
      final vehicleResult = await _getVehicleById(GetVehicleByIdParams(vehicleId: vehicleId));

      await vehicleResult.fold(
        (failure) async {
          state = state.copyWith(
            isLoading: false,
            errorMessage: () => failure.message,
          );
        },
        (vehicle) async {
          state = MaintenanceFormState.initial(
            vehicleId: vehicleId,
            userId: userId,
          ).copyWith(
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

  /// Inicializa com manutenção existente para edição
  Future<void> initializeWithMaintenance(MaintenanceEntity maintenance) async {
    Future.microtask(() {
      state = state.copyWith(isLoading: true);
    });

    try {
      final vehicleResult = await _getVehicleById(GetVehicleByIdParams(vehicleId: maintenance.vehicleId));

      await vehicleResult.fold(
        (failure) async {
          state = state.copyWith(
            isLoading: false,
            errorMessage: () => failure.message,
          );
        },
        (vehicle) async {
          state = MaintenanceFormState.fromMaintenance(maintenance).copyWith(
            vehicle: vehicle,
            isLoading: false,
          );

          _updateTextControllers();
        },
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: () => 'Erro ao carregar manutenção: $e',
      );
    }
  }

  /// Atualiza controllers com valores do estado
  void _updateTextControllers() {
    titleController.text = state.title;
    descriptionController.text = state.description;

    costController.text = state.cost > 0 ? _formatter.formatAmount(state.cost) : '';

    odometerController.text = state.odometer > 0 ? _formatter.formatOdometer(state.odometer) : '';

    workshopNameController.text = state.workshopName;
    workshopPhoneController.text = state.workshopPhone;
    workshopAddressController.text = state.workshopAddress;

    nextOdometerController.text = state.nextServiceOdometer != null
        ? _formatter.formatOdometer(state.nextServiceOdometer!)
        : '';

    notesController.text = state.notes;
  }

  void _onTitleChanged() {
    _titleDebounceTimer?.cancel();
    _titleDebounceTimer = Timer(
      const Duration(milliseconds: MaintenanceConstants.titleDebounceMs),
      () {
        final sanitized = InputSanitizer.sanitize(titleController.text);

        state = state.copyWith(
          title: sanitized,
          hasChanges: true,
        ).clearFieldError('title');
        if (sanitized.isNotEmpty && state.type == MaintenanceType.preventive) {
          final suggestedType = _validator.suggestTypeFromDescription(sanitized);
          if (suggestedType != MaintenanceType.preventive) {
            updateType(suggestedType);
          }
        }
      },
    );
  }

  void _onDescriptionChanged() {
    _descriptionDebounceTimer?.cancel();
    _descriptionDebounceTimer = Timer(
      const Duration(milliseconds: MaintenanceConstants.descriptionDebounceMs),
      () {
        final sanitized = InputSanitizer.sanitizeDescription(descriptionController.text);

        state = state.copyWith(
          description: sanitized,
          hasChanges: true,
        ).clearFieldError('description');
      },
    );
  }

  void _onCostChanged() {
    _costDebounceTimer?.cancel();
    _costDebounceTimer = Timer(
      const Duration(milliseconds: MaintenanceConstants.costDebounceMs),
      () {
        final value = _formatter.parseFormattedAmount(costController.text);

        state = state.copyWith(
          cost: value,
          hasChanges: true,
        ).clearFieldError('cost');
      },
    );
  }

  void _onOdometerChanged() {
    _odometerDebounceTimer?.cancel();
    _odometerDebounceTimer = Timer(
      const Duration(milliseconds: MaintenanceConstants.odometerDebounceMs),
      () {
        final value = _formatter.parseFormattedOdometer(odometerController.text);

        state = state.copyWith(
          odometer: value,
          hasChanges: true,
        ).clearFieldError('odometer');
      },
    );
  }

  void _onWorkshopNameChanged() {
    final sanitized = InputSanitizer.sanitizeName(workshopNameController.text);

    state = state.copyWith(
      workshopName: sanitized,
      hasChanges: true,
    ).clearFieldError('workshopName');
  }

  void _onWorkshopPhoneChanged() {
    final formatted = _formatter.formatPhone(workshopPhoneController.text);
    if (formatted != workshopPhoneController.text) {
      workshopPhoneController.value = workshopPhoneController.value.copyWith(
        text: formatted,
        selection: TextSelection.collapsed(offset: formatted.length),
      );
    }

    state = state.copyWith(
      workshopPhone: formatted,
      hasChanges: true,
    ).clearFieldError('workshopPhone');
  }

  void _onWorkshopAddressChanged() {
    final sanitized = InputSanitizer.sanitize(workshopAddressController.text);

    state = state.copyWith(
      workshopAddress: sanitized,
      hasChanges: true,
    ).clearFieldError('workshopAddress');
  }

  void _onNextOdometerChanged() {
    final value = _formatter.parseFormattedOdometer(nextOdometerController.text);

    state = state.copyWith(
      nextServiceOdometer: value > 0 ? value : null,
      hasChanges: true,
    ).clearFieldError('nextServiceOdometer');
  }

  void _onNotesChanged() {
    final sanitized = InputSanitizer.sanitizeDescription(notesController.text);

    state = state.copyWith(
      notes: sanitized,
      hasChanges: true,
    ).clearFieldError('notes');
  }

  /// Atualiza tipo de manutenção
  void updateType(MaintenanceType type) {
    if (state.type == type) return;

    state = state.copyWith(
      type: type,
      hasChanges: true,
    ).clearFieldError('type');
  }

  /// Atualiza status da manutenção
  void updateStatus(MaintenanceStatus status) {
    if (state.status == status) return;

    state = state.copyWith(
      status: status,
      hasChanges: true,
    ).clearFieldError('status');
  }

  /// Atualiza data do serviço
  void updateServiceDate(DateTime date) {
    if (state.serviceDate == date) return;

    state = state.copyWith(
      serviceDate: date,
      hasChanges: true,
    ).clearFieldError('serviceDate');
  }

  /// Atualiza data da próxima manutenção
  void updateNextServiceDate(DateTime? date) {
    if (state.nextServiceDate == date) return;

    state = state.copyWith(
      nextServiceDate: date,
      hasChanges: true,
    ).clearFieldError('nextServiceDate');
  }

  /// Adiciona foto
  Future<void> addPhoto() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 85,
      );

      if (image != null) {
        final newPaths = List<String>.from(state.photosPaths);
        newPaths.add(image.path);

        state = state.copyWith(
          photosPaths: newPaths,
          hasChanges: true,
        );
      }
    } catch (e) {
      state = state.copyWith(
        errorMessage: () => 'Erro ao adicionar foto: $e',
      );
    }
  }

  /// Remove foto
  void removePhoto(String photoPath) {
    final newPaths = List<String>.from(state.photosPaths);
    newPaths.remove(photoPath);

    state = state.copyWith(
      photosPaths: newPaths,
      hasChanges: true,
    );
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
      case 'title':
        return _validator.validateTitle(value);
      case 'description':
        return _validator.validateDescription(value);
      case 'cost':
        return _validator.validateCost(value, type: state.type);
      case 'odometer':
        return _validator.validateOdometer(
          value,
          currentOdometer: state.vehicle?.currentOdometer,
        );
      case 'workshopName':
        return _validator.validateWorkshopName(value);
      case 'workshopPhone':
        return _validator.validatePhone(value);
      case 'workshopAddress':
        return _validator.validateAddress(value);
      case 'notes':
        return _validator.validateNotes(value);
      default:
        return null;
    }
  }

  /// Valida formulário completo
  bool validateForm() {
    debugPrint('[MAINTENANCE VALIDATION] Starting form validation...');
    debugPrint('[MAINTENANCE VALIDATION] type: ${state.type}');
    debugPrint('[MAINTENANCE VALIDATION] title: "${titleController.text}"');
    debugPrint('[MAINTENANCE VALIDATION] description: "${descriptionController.text}"');
    debugPrint('[MAINTENANCE VALIDATION] cost: "${costController.text}"');
    debugPrint('[MAINTENANCE VALIDATION] odometer: "${odometerController.text}"');
    debugPrint('[MAINTENANCE VALIDATION] serviceDate: ${state.serviceDate}');
    debugPrint('[MAINTENANCE VALIDATION] workshopName: "${workshopNameController.text}"');
    debugPrint('[MAINTENANCE VALIDATION] workshopPhone: "${workshopPhoneController.text}"');
    debugPrint('[MAINTENANCE VALIDATION] workshopAddress: "${workshopAddressController.text}"');
    debugPrint('[MAINTENANCE VALIDATION] nextServiceDate: ${state.nextServiceDate}');
    debugPrint('[MAINTENANCE VALIDATION] nextServiceOdometer: "${nextOdometerController.text}"');
    debugPrint('[MAINTENANCE VALIDATION] notes: "${notesController.text}"');
    debugPrint('[MAINTENANCE VALIDATION] vehicle: ${state.vehicle?.displayName ?? "null"}');

    final errors = _validator.validateCompleteForm(
      type: state.type,
      title: titleController.text,
      description: descriptionController.text,
      cost: costController.text,
      odometer: odometerController.text,
      serviceDate: state.serviceDate,
      workshopName: workshopNameController.text,
      workshopPhone: workshopPhoneController.text,
      workshopAddress: workshopAddressController.text,
      nextServiceDate: state.nextServiceDate,
      nextServiceOdometer: nextOdometerController.text,
      notes: notesController.text,
      vehicle: state.vehicle,
    );

    debugPrint('[MAINTENANCE VALIDATION] Validation errors: $errors');
    debugPrint('[MAINTENANCE VALIDATION] Form is ${errors.isEmpty ? "VALID" : "INVALID"}');

    state = state.copyWith(fieldErrors: errors);

    return errors.isEmpty;
  }

  /// Abre picker de data do serviço
  Future<void> pickServiceDate(BuildContext context) async {
    final date = await showDatePicker(
      context: context,
      initialDate: state.serviceDate ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365 * MaintenanceConstants.maxYearsBack)),
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
      final currentTime = TimeOfDay.fromDateTime(state.serviceDate ?? DateTime.now());
      final newDateTime = DateTime(
        date.year,
        date.month,
        date.day,
        currentTime.hour,
        currentTime.minute,
      );
      updateServiceDate(newDateTime);
    }
  }

  /// Abre picker de hora do serviço
  Future<void> pickServiceTime(BuildContext context) async {
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(state.serviceDate ?? DateTime.now()),
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
      final currentDate = state.serviceDate ?? DateTime.now();
      final newDateTime = DateTime(
        currentDate.year,
        currentDate.month,
        currentDate.day,
        time.hour,
        time.minute,
      );
      updateServiceDate(newDateTime);
    }
  }

  /// Abre picker de data da próxima manutenção
  Future<void> pickNextServiceDate(BuildContext context) async {
    final date = await showDatePicker(
      context: context,
      initialDate: state.nextServiceDate ?? (state.serviceDate ?? DateTime.now()).add(const Duration(days: 180)),
      firstDate: state.serviceDate ?? DateTime.now(),
      lastDate: (state.serviceDate ?? DateTime.now()).add(const Duration(days: 365 * MaintenanceConstants.maxYearsForward)),
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
      updateNextServiceDate(date);
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
      state = state.copyWith(
        isUploadingImage: true,
      ).clearImageError();
      final isValid = await _receiptImageService.isValidImage(imagePath);
      if (!isValid) {
        throw Exception('Arquivo de imagem inválido');
      }
      final result = await _receiptImageService.processMaintenanceReceiptImage(
        userId: state.userId,
        maintenanceId: _generateTemporaryId(),
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

      debugPrint('[MAINTENANCE FORM] Image processed successfully');
      debugPrint('[MAINTENANCE FORM] Local path: ${result.localPath}');
      debugPrint('[MAINTENANCE FORM] Download URL: ${result.downloadUrl}');
    } catch (e) {
      state = state.copyWith(
        isUploadingImage: false,
        imageUploadError: () => 'Erro ao processar imagem: $e',
      );
      debugPrint('[MAINTENANCE FORM] Image processing error: $e');
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

      state = state.copyWith(
        hasChanges: true,
        clearReceiptImage: true,
        clearReceiptUrl: true,
      ).clearImageError();
    } catch (e) {
      state = state.copyWith(
        imageUploadError: () => 'Erro ao remover imagem: $e',
      );
    }
  }

  /// Sincroniza imagem local com Firebase (para casos offline)
  Future<void> syncImageToFirebase(String actualMaintenanceId) async {
    if (state.receiptImagePath == null || state.receiptImageUrl != null) {
      return; // Nada para sincronizar
    }

    try {
      state = state.copyWith(isUploadingImage: true);

      final result = await _receiptImageService.processMaintenanceReceiptImage(
        userId: state.userId,
        maintenanceId: actualMaintenanceId,
        imagePath: state.receiptImagePath!,
        compressImage: false, // Já foi comprimida
        uploadToFirebase: true,
      );

      state = state.copyWith(
        receiptImageUrl: result.downloadUrl,
        isUploadingImage: false,
      );

      debugPrint('[MAINTENANCE FORM] Image synced to Firebase: ${result.downloadUrl}');
    } catch (e) {
      debugPrint('[MAINTENANCE FORM] Failed to sync image: $e');
      state = state.copyWith(isUploadingImage: false);
    }
  }

  /// Gera ID temporário para processar imagem antes do save
  String _generateTemporaryId() {
    return 'temp_${DateTime.now().millisecondsSinceEpoch}';
  }

  /// Limpa formulário
  void clearForm() {
    titleController.clear();
    descriptionController.clear();
    costController.clear();
    odometerController.clear();
    workshopNameController.clear();
    workshopPhoneController.clear();
    workshopAddressController.clear();
    nextOdometerController.clear();
    notesController.clear();

    state = MaintenanceFormState.initial(
      vehicleId: state.vehicleId,
      userId: state.userId,
    ).copyWith(
      vehicle: state.vehicle,
    );
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
