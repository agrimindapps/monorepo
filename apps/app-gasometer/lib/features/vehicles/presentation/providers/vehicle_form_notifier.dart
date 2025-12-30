import 'dart:io';

import 'package:core/core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' as flutter show FormState;
import 'package:flutter/material.dart' hide FormState;
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/error/app_error.dart' as local_error;
import '../../../../core/providers/dependency_providers.dart';
import '../../../../core/services/analytics/gasometer_analytics_service.dart';
import '../../../../core/validation/input_sanitizer.dart';
import '../../../auth/presentation/notifiers/auth_notifier.dart';
import '../../domain/entities/fuel_type_mapper.dart';
import '../../domain/entities/vehicle_entity.dart';
import 'vehicles_notifier.dart';

part 'vehicle_form_notifier.g.dart';

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
      editingVehicle: clearEditingVehicle
          ? null
          : (editingVehicle ?? this.editingVehicle),
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
@riverpod
class VehicleFormNotifier extends _$VehicleFormNotifier {
  final GlobalKey<flutter.FormState> formKey = GlobalKey<flutter.FormState>();
  final TextEditingController brandController = TextEditingController();
  final TextEditingController modelController = TextEditingController();
  final TextEditingController yearController = TextEditingController();
  final TextEditingController colorController = TextEditingController();
  final TextEditingController plateController = TextEditingController();
  final TextEditingController chassisController = TextEditingController();
  final TextEditingController renavamController = TextEditingController();
  final TextEditingController odometerController = TextEditingController();
  
  late final GasometerAnalyticsService _analyticsService;

  @override
  VehicleFormState build() {
    _analyticsService = ref.watch(gasometerAnalyticsServiceProvider);
    
    ref.onDispose(() {
      brandController.dispose();
      modelController.dispose();
      yearController.dispose();
      colorController.dispose();
      plateController.dispose();
      chassisController.dispose();
      renavamController.dispose();
      odometerController.dispose();
    });
    return const VehicleFormState.initial();
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

    // Determinar tipo de combustível para exibição
    // Se o veículo suporta múltiplos combustíveis (Gasolina, Etanol, GNV), é Flex
    final String fuelType;
    if (vehicle.supportedFuels.length > 1 &&
        vehicle.supportedFuels.contains(FuelType.gasoline) &&
        vehicle.supportedFuels.contains(FuelType.ethanol)) {
      fuelType = 'Flex';
    } else if (vehicle.supportedFuels.isNotEmpty) {
      fuelType = FuelTypeMapper.toStringFormat(vehicle.supportedFuels.first);
    } else {
      fuelType = 'Gasolina';
    }

    state = state.copyWith(selectedFuelType: fuelType);

    // A imagem agora é armazenada como Base64 em metadata['foto']
    // Não precisamos carregar como File, pois o CoreImageWidget lida com Base64
    // O vehicleImage só é usado para novas imagens selecionadas pelo picker
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
      state = state.copyWith(selectedFuelType: fuelType, hasChanges: true);
    }
  }

  /// Alias para updateSelectedFuelType (compatibilidade)
  void updateSelectedFuel(String fuelType) {
    updateSelectedFuelType(fuelType);
  }

  /// Atualiza imagem do veículo
  void updateVehicleImage(File? image) {
    if (state.vehicleImage != image) {
      state = state.copyWith(vehicleImage: image, hasChanges: true);
    }
  }

  /// Remove imagem do veículo com validação de segurança
  Future<void> removeVehicleImage() async {
    try {
      final currentImage = state.vehicleImage;
      // Em web, não podemos deletar arquivos, então apenas limpar do estado
      if (currentImage != null && (kIsWeb || currentImage.existsSync())) {
        if (kIsWeb) {
          // Na web, apenas remover do estado (arquivo já foi enviado/deletado pelo servidor)
          state = state.copyWith(
            clearImage: true,
            hasChanges: true,
            clearError: true,
          );
        } else if (await _isFileOwnedByUser(currentImage)) {
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
        state = state.copyWith(clearImage: true, hasChanges: true);
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
      if (filePath.contains('cache') ||
          filePath.contains('tmp') ||
          filePath.contains('TemporaryItems')) {
        return true;
      }
      final allowedDirectories = ['tmp', 'cache', 'Documents', 'files'];
      final isInAllowedDir = allowedDirectories.any(
        (dir) => filePath.contains(dir),
      );

      if (!isInAllowedDir) {
        return false;
      }
      final fileStats = await file.stat(); // ignore: avoid_slow_async_io
      final now = DateTime.now();
      final fileAge = now.difference(fileStats.modified);
      return fileAge.inHours < 24;
    } catch (e) {
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
          message:
              'Por favor, preencha os seguintes campos obrigatórios: ${missingFields.join(', ')}',
        ),
      );
      return false;
    }
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
  Future<VehicleEntity> buildVehicleEntity({String? userId}) async {
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
    final odometerValue =
        double.tryParse(odometerController.text.replaceAll(',', '.')) ?? 0.0;
    final sanitizedBrand = InputSanitizer.sanitizeName(brandController.text);
    final sanitizedModel = InputSanitizer.sanitizeName(modelController.text);
    final sanitizedColor = InputSanitizer.sanitizeName(colorController.text);
    final sanitizedPlate = InputSanitizer.sanitize(
      plateController.text,
    ).toUpperCase();
    final sanitizedChassis = InputSanitizer.sanitize(chassisController.text);
    final sanitizedRenavam = InputSanitizer.sanitizeNumeric(
      renavamController.text,
    );

    // Validação adicional: Drift não aceita strings vazias para campos obrigatórios
    if (sanitizedBrand.isEmpty) {
      throw const local_error.ValidationError(message: 'Marca é obrigatória');
    }
    if (sanitizedModel.isEmpty) {
      throw const local_error.ValidationError(message: 'Modelo é obrigatório');
    }
    if (sanitizedPlate.isEmpty) {
      throw const local_error.ValidationError(message: 'Placa é obrigatória');
    }

    // Determinar combustíveis suportados
    // Se for Flex, suporta Gasolina, Etanol e GNV
    final List<FuelType> supportedFuels = fuelType == FuelType.flex
        ? [FuelType.gasoline, FuelType.ethanol, FuelType.gas]
        : [fuelType];

    // Converter imagem para Base64 otimizado se existir
    String? imageBase64;
    if (state.vehicleImage != null) {
      try {
        if (!kIsWeb && state.vehicleImage!.existsSync()) {
          final bytes = await state.vehicleImage!.readAsBytes();
          
          // Usar ImageProcessingService para otimizar a imagem (max 600KB)
          final processed = await ImageProcessingService.instance.processImage(
            bytes,
            config: ImageProcessingConfig.standard,
          );
          
          imageBase64 = processed.base64DataUri;
          debugPrint('📷 Imagem processada: ${processed.sizeBytes} bytes '
              '(${processed.width}x${processed.height}), '
              'economia: ${processed.savedPercent.toStringAsFixed(1)}%');
        }
      } catch (e) {
        debugPrint('⚠️ Erro ao processar imagem: $e');
      }
    }
    
    // Se não conseguiu converter, usar valor existente do veículo em edição
    imageBase64 ??= state.editingVehicle?.metadata['foto'] as String?;

    return VehicleEntity(
      id:
          state.editingVehicle?.id ??
          DateTime.now().millisecondsSinceEpoch.toString(),
      userId: effectiveUserId,
      name: '$sanitizedBrand $sanitizedModel',
      brand: sanitizedBrand,
      model: sanitizedModel,
      year: int.tryParse(yearController.text) ?? DateTime.now().year,
      color: sanitizedColor,
      licensePlate: sanitizedPlate,
      type: VehicleType.car,
      supportedFuels: supportedFuels,
      currentOdometer: odometerValue,
      createdAt: state.editingVehicle?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
      metadata: {
        if (sanitizedChassis.isNotEmpty) 'chassi': sanitizedChassis,
        if (sanitizedRenavam.isNotEmpty) 'renavam': sanitizedRenavam,
        if (imageBase64 != null && imageBase64.isNotEmpty) 'foto': imageBase64,
        'odometroInicial': odometerValue,
      },
    );
  }

  /// Alias para buildVehicleEntity (compatibilidade)
  Future<VehicleEntity> createVehicleEntity({String? userId}) {
    return buildVehicleEntity(userId: userId);
  }

  /// Salva veículo (adiciona ou atualiza)
  Future<bool> saveVehicle() async {
    if (!validateForm()) {
      return false;
    }

    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final vehicle = await buildVehicleEntity();
      final notifier = ref.read(vehiclesProvider.notifier);
      final isNewVehicle = !state.isEditing;

      if (state.isEditing) {
        await notifier.updateVehicle(vehicle);
      } else {
        await notifier.addVehicle(vehicle);
      }

      state = state.copyWith(isLoading: false, hasChanges: false);

      // 📊 Analytics: Track vehicle creation only for new vehicles
      if (isNewVehicle) {
        _trackVehicleCreated(vehicle);
      }

      return true;
    } catch (e) {
      final error = e is local_error.AppError
          ? e
          : local_error.UnexpectedError(
              message: 'Erro ao salvar veículo: ${e.toString()}',
            );

      state = state.copyWith(isLoading: false, error: error);

      return false;
    }
  }

  /// 📊 Track vehicle created event to Firebase Analytics
  void _trackVehicleCreated(VehicleEntity vehicle) {
    try {
      final vehicleType = '${vehicle.brand} ${vehicle.model}';
      _analyticsService.logVehicleCreated(vehicleType);
      if (kDebugMode) {
        debugPrint('📊 [Analytics] Vehicle created tracked: $vehicleType');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('📊 [Analytics] Error tracking vehicle created: $e');
      }
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

/// Provider para verificar se pode submeter
@riverpod
bool canSubmitVehicleForm(Ref ref) {
  return ref.watch(vehicleFormProvider.notifier).canSubmit;
}
