import 'dart:io';

import 'package:core/core.dart';
import 'package:flutter/material.dart' as flutter show FormState;
import 'package:flutter/material.dart' hide FormState;

import '../../../../core/error/app_error.dart' as local_error;
import '../../../../core/services/input_sanitizer.dart';
import '../../../auth/presentation/notifiers/auth_notifier.dart';
import '../../domain/entities/fuel_type_mapper.dart';
import '../../domain/entities/vehicle_entity.dart';
import 'vehicles_notifier.dart';

/// Estado do formulário de veículo
class VehicleFormState {

  const VehicleFormState({
    this.editingVehicle,
    this.isLoading = false,
    this.error,
    this.hasChanges = false,
    this.selectedFuelType = 'Gasolina',
    this.vehicleImage,
  });

  const VehicleFormState.initial() : this();
  final VehicleEntity? editingVehicle;
  final bool isLoading;
  final local_error.AppError? error;
  final bool hasChanges;
  final String selectedFuelType;
  final File? vehicleImage;

  /// Alias para selectedFuelType (compatibilidade)
  String get selectedFuel => selectedFuelType;

  VehicleFormState copyWith({
    VehicleEntity? editingVehicle,
    bool? isLoading,
    local_error.AppError? error,
    bool? hasChanges,
    String? selectedFuelType,
    File? vehicleImage,
    bool clearError = false,
    bool clearImage = false,
    bool clearEditingVehicle = false,
  }) {
    return VehicleFormState(
      editingVehicle: clearEditingVehicle ? null : (editingVehicle ?? this.editingVehicle),
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      hasChanges: hasChanges ?? this.hasChanges,
      selectedFuelType: selectedFuelType ?? this.selectedFuelType,
      vehicleImage: clearImage ? null : (vehicleImage ?? this.vehicleImage),
    );
  }

  bool get isEditing => editingVehicle != null;
  bool get hasError => error != null;
  String get errorMessage => error?.message ?? '';
}

/// Notifier para gerenciar estado do formulário de veículos
class VehicleFormNotifier extends StateNotifier<VehicleFormState> {
  VehicleFormNotifier(this.ref) : super(const VehicleFormState.initial());

  final Ref ref;
  final GlobalKey<flutter.FormState> formKey = GlobalKey<flutter.FormState>();

  // Controllers para campos de texto
  final TextEditingController brandController = TextEditingController();
  final TextEditingController modelController = TextEditingController();
  final TextEditingController yearController = TextEditingController();
  final TextEditingController colorController = TextEditingController();
  final TextEditingController plateController = TextEditingController();
  final TextEditingController chassisController = TextEditingController();
  final TextEditingController renavamController = TextEditingController();
  final TextEditingController odometerController = TextEditingController();

  @override
  void dispose() {
    brandController.dispose();
    modelController.dispose();
    yearController.dispose();
    colorController.dispose();
    plateController.dispose();
    chassisController.dispose();
    renavamController.dispose();
    odometerController.dispose();
    super.dispose();
  }

  /// Inicializa formulário para edição
  void initializeForEdit(VehicleEntity vehicle) {
    state = state.copyWith(
      editingVehicle: vehicle,
      clearError: true,
      hasChanges: false,
    );

    brandController.text = vehicle.brand;
    modelController.text = vehicle.model;
    yearController.text = vehicle.year.toString();
    colorController.text = vehicle.color;
    plateController.text = vehicle.licensePlate;
    chassisController.text = vehicle.metadata['chassi'] as String? ?? '';
    renavamController.text = vehicle.metadata['renavam'] as String? ?? '';
    odometerController.text = vehicle.currentOdometer.toString();

    final fuelType = vehicle.supportedFuels.isNotEmpty
        ? FuelTypeMapper.toStringFormat(vehicle.supportedFuels.first)
        : 'Gasolina';

    state = state.copyWith(selectedFuelType: fuelType);

    final imagePath = vehicle.metadata['foto'] as String?;
    if (imagePath != null && imagePath.isNotEmpty) {
      final imageFile = File(imagePath);
      if (imageFile.existsSync()) {
        state = state.copyWith(vehicleImage: imageFile);
      }
    }
  }

  /// Limpa formulário
  void clearForm() {
    brandController.clear();
    modelController.clear();
    yearController.clear();
    colorController.clear();
    plateController.clear();
    chassisController.clear();
    renavamController.clear();
    odometerController.clear();

    state = const VehicleFormState.initial();
  }

  /// Atualiza tipo de combustível selecionado
  void updateSelectedFuelType(String fuelType) {
    if (state.selectedFuelType != fuelType) {
      state = state.copyWith(
        selectedFuelType: fuelType,
        hasChanges: true,
      );
    }
  }

  /// Alias para updateSelectedFuelType (compatibilidade)
  void updateSelectedFuel(String fuelType) {
    updateSelectedFuelType(fuelType);
  }

  /// Atualiza imagem do veículo
  void updateVehicleImage(File? image) {
    if (state.vehicleImage != image) {
      state = state.copyWith(
        vehicleImage: image,
        hasChanges: true,
      );
    }
  }

  /// Remove imagem do veículo com validação de segurança
  Future<void> removeVehicleImage() async {
    try {
      final currentImage = state.vehicleImage;
      if (currentImage != null && currentImage.existsSync()) {
        // Validar ownership do arquivo
        if (await _isFileOwnedByUser(currentImage)) {
          await currentImage.delete();
          state = state.copyWith(
            clearImage: true,
            hasChanges: true,
            clearError: true,
          );
        } else {
          state = state.copyWith(
            error: const local_error.PermissionError(
              permission: 'delete_image',
              message: 'Tentativa de exclusão não autorizada detectada',
            ),
          );
        }
      } else {
        state = state.copyWith(
          clearImage: true,
          hasChanges: true,
        );
      }
    } catch (e) {
      state = state.copyWith(
        error: local_error.UnexpectedError(
          message: 'Erro ao remover imagem: ${e.toString()}',
        ),
      );
    }
  }

  /// Valida se arquivo pertence ao usuário atual
  Future<bool> _isFileOwnedByUser(File file) async {
    try {
      final filePath = file.path;

      // Para arquivos temporários de imagem, sempre permitir exclusão
      if (filePath.contains('cache') || filePath.contains('tmp') || filePath.contains('TemporaryItems')) {
        return true;
      }

      // Verificar se arquivo está no diretório do usuário (se userId disponível)
      // Nota: Sem acesso ao userId aqui, validamos por padrão de diretório permitido

      // Verificar se está em diretórios permitidos
      final allowedDirectories = ['tmp', 'cache', 'Documents', 'files'];
      final isInAllowedDir = allowedDirectories.any((dir) => filePath.contains(dir));

      if (!isInAllowedDir) {
        return false;
      }

      // Verificar idade do arquivo
      final fileStats = await file.stat();
      final now = DateTime.now();
      final fileAge = now.difference(fileStats.modified);

      // Permitir exclusão apenas se arquivo for recente (< 24h) ou criado pelo usuário
      return fileAge.inHours < 24;
    } catch (e) {
      // Em caso de erro na validação, negar exclusão por segurança
      return false;
    }
  }

  /// Marca formulário como alterado
  void markAsChanged() {
    if (!state.hasChanges) {
      state = state.copyWith(hasChanges: true);
    }
  }

  /// Define estado de loading
  void setLoading(bool loading) {
    state = state.copyWith(isLoading: loading);
  }

  /// Define erro
  void setError(local_error.AppError error) {
    state = state.copyWith(error: error);
  }

  /// Limpa erro
  void clearError() {
    state = state.copyWith(clearError: true);
  }

  /// Valida formulário
  bool validateForm() {
    state = state.copyWith(clearError: true);

    // Validar campos obrigatórios
    final List<String> missingFields = [];

    if (brandController.text.trim().isEmpty) {
      missingFields.add('Marca');
    }

    if (modelController.text.trim().isEmpty) {
      missingFields.add('Modelo');
    }

    if (yearController.text.trim().isEmpty) {
      missingFields.add('Ano');
    }

    if (colorController.text.trim().isEmpty) {
      missingFields.add('Cor');
    }

    if (plateController.text.trim().isEmpty) {
      missingFields.add('Placa');
    }

    if (odometerController.text.trim().isEmpty) {
      missingFields.add('Odômetro');
    }

    if (missingFields.isNotEmpty) {
      state = state.copyWith(
        error: local_error.ValidationError(
          message: 'Por favor, preencha os seguintes campos obrigatórios: ${missingFields.join(', ')}',
        ),
      );
      return false;
    }

    // Validar usando FormKey
    if (!formKey.currentState!.validate()) {
      state = state.copyWith(
        error: const local_error.ValidationError(
          message: 'Por favor, corrija os erros no formulário',
        ),
      );
      return false;
    }

    return true;
  }

  /// Cria entidade do veículo a partir dos dados do formulário
  /// Requer userId como parâmetro
  VehicleEntity buildVehicleEntity({String? userId}) {
    // Obter userId de parâmetro ou do auth state
    String? effectiveUserId = userId;
    if (effectiveUserId == null) {
      final authState = ref.read(authProvider);
      effectiveUserId = authState.currentUser?.id;
    }

    if (effectiveUserId == null) {
      throw const local_error.AuthenticationError(
        message: 'Usuário não autenticado',
      );
    }

    final fuelType = FuelTypeMapper.fromString(state.selectedFuelType);
    final odometerValue = double.tryParse(odometerController.text.replaceAll(',', '.')) ?? 0.0;

    // Aplicar sanitização específica para cada campo
    final sanitizedBrand = InputSanitizer.sanitizeName(brandController.text);
    final sanitizedModel = InputSanitizer.sanitizeName(modelController.text);
    final sanitizedColor = InputSanitizer.sanitizeName(colorController.text);
    final sanitizedPlate = InputSanitizer.sanitize(plateController.text).toUpperCase();
    final sanitizedChassis = InputSanitizer.sanitize(chassisController.text);
    final sanitizedRenavam = InputSanitizer.sanitizeNumeric(renavamController.text);

    return VehicleEntity(
      id: state.editingVehicle?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      userId: effectiveUserId,
      name: '$sanitizedBrand $sanitizedModel',
      brand: sanitizedBrand,
      model: sanitizedModel,
      year: int.tryParse(yearController.text) ?? DateTime.now().year,
      color: sanitizedColor,
      licensePlate: sanitizedPlate,
      type: VehicleType.car,
      supportedFuels: [fuelType],
      currentOdometer: odometerValue,
      createdAt: state.editingVehicle?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
      metadata: {
        if (sanitizedChassis.isNotEmpty) 'chassi': sanitizedChassis,
        if (sanitizedRenavam.isNotEmpty) 'renavam': sanitizedRenavam,
        if (state.vehicleImage?.path != null) 'foto': state.vehicleImage!.path,
        'odometroInicial': odometerValue,
      },
    );
  }

  /// Alias para buildVehicleEntity (compatibilidade)
  VehicleEntity createVehicleEntity({String? userId}) {
    return buildVehicleEntity(userId: userId);
  }

  /// Salva veículo (adiciona ou atualiza)
  Future<bool> saveVehicle() async {
    if (!validateForm()) {
      return false;
    }

    state = state.copyWith(
      isLoading: true,
      clearError: true,
    );

    try {
      final vehicle = buildVehicleEntity();
      final notifier = ref.read(vehiclesNotifierProvider.notifier);

      if (state.isEditing) {
        await notifier.updateVehicle(vehicle);
      } else {
        await notifier.addVehicle(vehicle);
      }

      state = state.copyWith(
        isLoading: false,
        hasChanges: false,
      );

      return true;
    } catch (e) {
      final error = e is local_error.AppError
          ? e
          : local_error.UnexpectedError(
              message: 'Erro ao salvar veículo: ${e.toString()}',
            );

      state = state.copyWith(
        isLoading: false,
        error: error,
      );

      return false;
    }
  }

  /// Verifica se pode submeter formulário
  bool get canSubmit {
    return !state.isLoading &&
        brandController.text.isNotEmpty &&
        modelController.text.isNotEmpty &&
        yearController.text.isNotEmpty &&
        colorController.text.isNotEmpty &&
        plateController.text.isNotEmpty &&
        odometerController.text.isNotEmpty;
  }
}

// ============================================================================
// PROVIDERS
// ============================================================================

/// Provider principal do formulário de veículos
final vehicleFormNotifierProvider = StateNotifierProvider<VehicleFormNotifier, VehicleFormState>((ref) {
  return VehicleFormNotifier(ref);
});

/// Provider para verificar se pode submeter
final canSubmitVehicleFormProvider = Provider<bool>((ref) {
  return ref.watch(vehicleFormNotifierProvider.notifier).canSubmit;
});