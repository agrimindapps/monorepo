import 'dart:async';

import 'package:core/core.dart';
import 'package:flutter/foundation.dart';

import '../../../features/plants/domain/entities/plant.dart';
import '../../../features/plants/domain/usecases/add_plant_usecase.dart';
import '../../../features/plants/domain/usecases/get_plants_usecase.dart';
import '../../../features/plants/domain/usecases/update_plant_usecase.dart';
import '../../services/form_validation_service.dart';
import '../../services/image_management_service.dart';

/// Estado do formulário de planta
class PlantFormState {
  final bool isLoading;
  final bool isSaving;
  final bool isUploadingImages;
  final String? errorMessage;
  final Plant? originalPlant;
  final String name;
  final String species;
  final String? spaceId;
  final String notes;
  final DateTime? plantingDate;
  final String? imageBase64;
  final List<String> imageUrls;
  final int? wateringIntervalDays;
  final int? fertilizingIntervalDays;
  final int? pruningIntervalDays;
  final String? waterAmount;
  final bool? enableWateringCare;
  final DateTime? lastWateringDate;
  final bool? enableFertilizerCare;
  final DateTime? lastFertilizerDate;
  final bool? enableSunlightCare;
  final int? sunlightIntervalDays;
  final DateTime? lastSunlightDate;
  final bool? enablePestInspection;
  final int? pestInspectionIntervalDays;
  final DateTime? lastPestInspectionDate;
  final bool? enablePruning;
  final DateTime? lastPruningDate;
  final bool? enableReplanting;
  final int? replantingIntervalDays;
  final DateTime? lastReplantingDate;
  final Map<String, String> fieldErrors;
  final bool isFormValid;

  const PlantFormState({
    this.isLoading = false,
    this.isSaving = false,
    this.isUploadingImages = false,
    this.errorMessage,
    this.originalPlant,
    this.name = '',
    this.species = '',
    this.spaceId,
    this.notes = '',
    this.plantingDate,
    this.imageBase64,
    this.imageUrls = const [],
    this.wateringIntervalDays,
    this.fertilizingIntervalDays,
    this.pruningIntervalDays,
    this.waterAmount,
    this.enableWateringCare,
    this.lastWateringDate,
    this.enableFertilizerCare,
    this.lastFertilizerDate,
    this.enableSunlightCare,
    this.sunlightIntervalDays,
    this.lastSunlightDate,
    this.enablePestInspection,
    this.pestInspectionIntervalDays,
    this.lastPestInspectionDate,
    this.enablePruning,
    this.lastPruningDate,
    this.enableReplanting,
    this.replantingIntervalDays,
    this.lastReplantingDate,
    this.fieldErrors = const {},
    this.isFormValid = false,
  });

  PlantFormState copyWith({
    bool? isLoading,
    bool? isSaving,
    bool? isUploadingImages,
    String? errorMessage,
    Plant? originalPlant,
    String? name,
    String? species,
    String? spaceId,
    String? notes,
    DateTime? plantingDate,
    String? imageBase64,
    List<String>? imageUrls,
    int? wateringIntervalDays,
    int? fertilizingIntervalDays,
    int? pruningIntervalDays,
    String? waterAmount,
    bool? enableWateringCare,
    DateTime? lastWateringDate,
    bool? enableFertilizerCare,
    DateTime? lastFertilizerDate,
    bool? enableSunlightCare,
    int? sunlightIntervalDays,
    DateTime? lastSunlightDate,
    bool? enablePestInspection,
    int? pestInspectionIntervalDays,
    DateTime? lastPestInspectionDate,
    bool? enablePruning,
    DateTime? lastPruningDate,
    bool? enableReplanting,
    int? replantingIntervalDays,
    DateTime? lastReplantingDate,
    Map<String, String>? fieldErrors,
    bool? isFormValid,
    bool clearError = false,
    bool clearOriginalPlant = false,
  }) {
    return PlantFormState(
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      isUploadingImages: isUploadingImages ?? this.isUploadingImages,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      originalPlant:
          clearOriginalPlant ? null : (originalPlant ?? this.originalPlant),
      name: name ?? this.name,
      species: species ?? this.species,
      spaceId: spaceId ?? this.spaceId,
      notes: notes ?? this.notes,
      plantingDate: plantingDate ?? this.plantingDate,
      imageBase64: imageBase64 ?? this.imageBase64,
      imageUrls: imageUrls ?? this.imageUrls,
      wateringIntervalDays: wateringIntervalDays ?? this.wateringIntervalDays,
      fertilizingIntervalDays:
          fertilizingIntervalDays ?? this.fertilizingIntervalDays,
      pruningIntervalDays: pruningIntervalDays ?? this.pruningIntervalDays,
      waterAmount: waterAmount ?? this.waterAmount,
      enableWateringCare: enableWateringCare ?? this.enableWateringCare,
      lastWateringDate: lastWateringDate ?? this.lastWateringDate,
      enableFertilizerCare: enableFertilizerCare ?? this.enableFertilizerCare,
      lastFertilizerDate: lastFertilizerDate ?? this.lastFertilizerDate,
      enableSunlightCare: enableSunlightCare ?? this.enableSunlightCare,
      sunlightIntervalDays: sunlightIntervalDays ?? this.sunlightIntervalDays,
      lastSunlightDate: lastSunlightDate ?? this.lastSunlightDate,
      enablePestInspection: enablePestInspection ?? this.enablePestInspection,
      pestInspectionIntervalDays:
          pestInspectionIntervalDays ?? this.pestInspectionIntervalDays,
      lastPestInspectionDate:
          lastPestInspectionDate ?? this.lastPestInspectionDate,
      enablePruning: enablePruning ?? this.enablePruning,
      lastPruningDate: lastPruningDate ?? this.lastPruningDate,
      enableReplanting: enableReplanting ?? this.enableReplanting,
      replantingIntervalDays:
          replantingIntervalDays ?? this.replantingIntervalDays,
      lastReplantingDate: lastReplantingDate ?? this.lastReplantingDate,
      fieldErrors: fieldErrors ?? this.fieldErrors,
      isFormValid: isFormValid ?? this.isFormValid,
    );
  }

  bool get hasError => errorMessage != null;
  bool get isEditMode => originalPlant != null;
  bool get hasChanges => _hasChanges();
  bool get canSave {
    final result = isFormValid && hasChanges && !isSaving;
    return result;
  }

  bool _hasChanges() {
    if (originalPlant == null) return true; // Novo plant sempre tem mudanças

    return name != originalPlant!.name ||
        species != (originalPlant!.species ?? '') ||
        spaceId != originalPlant!.spaceId ||
        notes != (originalPlant!.notes ?? '') ||
        plantingDate != originalPlant!.plantingDate ||
        imageBase64 != originalPlant!.imageBase64 ||
        !_listsEqual(imageUrls, originalPlant!.imageUrls) ||
        _configHasChanges();
  }

  bool _configHasChanges() {
    final originalConfig = originalPlant?.config;

    return wateringIntervalDays != originalConfig?.wateringIntervalDays ||
        fertilizingIntervalDays != originalConfig?.fertilizingIntervalDays ||
        pruningIntervalDays != originalConfig?.pruningIntervalDays ||
        waterAmount != originalConfig?.waterAmount ||
        enableWateringCare != originalConfig?.enableWateringCare ||
        lastWateringDate != originalConfig?.lastWateringDate ||
        enableFertilizerCare != originalConfig?.enableFertilizerCare ||
        lastFertilizerDate != originalConfig?.lastFertilizerDate;
  }

  bool _listsEqual(List<String> a, List<String> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}

/// Gerenciador de estado APENAS para coordenação do formulário
/// Resolve violação SRP - separando coordenação de validação e lógica de imagens
class PlantFormStateManager extends ChangeNotifier {
  final FormValidationService _validationService;
  final ImageManagementService _imageService;
  final GetPlantsUseCase _getPlantsUseCase;
  final AddPlantUseCase _addPlantUseCase;
  final UpdatePlantUseCase _updatePlantUseCase;

  PlantFormState _state = const PlantFormState();

  PlantFormStateManager({
    required FormValidationService validationService,
    required ImageManagementService imageService,
    required GetPlantsUseCase getPlantsUseCase,
    required AddPlantUseCase addPlantUseCase,
    required UpdatePlantUseCase updatePlantUseCase,
  }) : _validationService = validationService,
       _imageService = imageService,
       _getPlantsUseCase = getPlantsUseCase,
       _addPlantUseCase = addPlantUseCase,
       _updatePlantUseCase = updatePlantUseCase;

  /// Estado atual
  PlantFormState get state => _state;

  /// Atualiza o estado e notifica listeners
  void _updateState(PlantFormState newState) {
    _state = newState;
    notifyListeners();
  }

  /// Carrega planta para edição (simplificado - busca por ID na lista)
  Future<void> loadPlant(String plantId) async {
    _updateState(_state.copyWith(isLoading: true, clearError: true));

    try {
      final result = await _getPlantsUseCase.call(const NoParams());

      result.fold(
        (failure) {
          _updateState(
            _state.copyWith(isLoading: false, errorMessage: failure.message),
          );
        },
        (plants) {
          final plant = plants.where((p) => p.id == plantId).firstOrNull;

          if (plant == null) {
            _updateState(
              _state.copyWith(
                isLoading: false,
                errorMessage: 'Planta não encontrada',
              ),
            );
            return;
          }
          if (kDebugMode) {
            print('🌱 loadPlant - Carregando planta: ${plant.name}');
            print('   🔧 plant.config existe? ${plant.config != null}');
            print(
              '   💧 enableWateringCare: ${plant.config?.enableWateringCare}',
            );
            print(
              '   💧 wateringIntervalDays: ${plant.config?.wateringIntervalDays}',
            );
            print('   💧 lastWateringDate: ${plant.config?.lastWateringDate}');
            print(
              '   🌿 enableFertilizerCare: ${plant.config?.enableFertilizerCare}',
            );
            print(
              '   🌿 fertilizingIntervalDays: ${plant.config?.fertilizingIntervalDays}',
            );
            print(
              '   🌿 lastFertilizerDate: ${plant.config?.lastFertilizerDate}',
            );
          }

          _updateState(
            _state.copyWith(
              isLoading: false,
              originalPlant: plant,
              name: plant.name,
              species: plant.species ?? '',
              spaceId: plant.spaceId,
              notes: plant.notes ?? '',
              plantingDate: plant.plantingDate,
              imageBase64: plant.imageBase64,
              imageUrls: List<String>.from(plant.imageUrls),
              wateringIntervalDays: plant.config?.wateringIntervalDays,
              fertilizingIntervalDays: plant.config?.fertilizingIntervalDays,
              pruningIntervalDays: plant.config?.pruningIntervalDays,
              waterAmount: plant.config?.waterAmount,
              enableWateringCare: plant.config?.enableWateringCare,
              lastWateringDate: plant.config?.lastWateringDate,
              enableFertilizerCare: plant.config?.enableFertilizerCare,
              lastFertilizerDate: plant.config?.lastFertilizerDate,
              clearError: true,
            ),
          );
          if (kDebugMode) {
            print('✅ loadPlant - Estado atualizado:');
            print(
              '   💧 _state.enableWateringCare: ${_state.enableWateringCare}',
            );
            print(
              '   💧 _state.wateringIntervalDays: ${_state.wateringIntervalDays}',
            );
            print('   💧 _state.lastWateringDate: ${_state.lastWateringDate}');
            print(
              '   🌿 _state.enableFertilizerCare: ${_state.enableFertilizerCare}',
            );
            print(
              '   🌿 _state.fertilizingIntervalDays: ${_state.fertilizingIntervalDays}',
            );
            print(
              '   🌿 _state.lastFertilizerDate: ${_state.lastFertilizerDate}',
            );
          }

          _validateForm();
        },
      );
    } catch (e) {
      _updateState(
        _state.copyWith(isLoading: false, errorMessage: 'Erro inesperado: $e'),
      );
    }
  }

  /// Inicializa formulário vazio para nova planta
  void initializeForNewPlant() {
    _updateState(const PlantFormState());
    _validateForm();
  }

  /// Atualiza campo nome
  void setName(String name) {
    _updateState(_state.copyWith(name: name));
    _validateForm();
  }

  /// Atualiza campo espécie
  void setSpecies(String species) {
    _updateState(_state.copyWith(species: species));
    _validateForm();
  }

  /// Atualiza espaço
  void setSpaceId(String? spaceId) {
    _updateState(_state.copyWith(spaceId: spaceId));
    _validateForm();
  }

  /// Atualiza notas
  void setNotes(String notes) {
    _updateState(_state.copyWith(notes: notes));
    _validateForm();
  }

  /// Atualiza data de plantio
  void setPlantingDate(DateTime? date) {
    _updateState(_state.copyWith(plantingDate: date));
    _validateForm();
  }

  /// Atualiza configurações de rega
  void setWateringConfig({
    bool? enabled,
    int? intervalDays,
    DateTime? lastDate,
  }) {
    final effectiveIntervalDays =
        intervalDays ??
        (enabled == true && _state.wateringIntervalDays == null
            ? 7
            : _state.wateringIntervalDays);

    _updateState(
      _state.copyWith(
        enableWateringCare: enabled ?? _state.enableWateringCare,
        wateringIntervalDays: effectiveIntervalDays,
        lastWateringDate: lastDate ?? _state.lastWateringDate,
      ),
    );
    _validateForm();
  }

  /// Atualiza configurações de fertilização
  void setFertilizerConfig({
    bool? enabled,
    int? intervalDays,
    DateTime? lastDate,
  }) {
    final effectiveIntervalDays =
        intervalDays ??
        (enabled == true && _state.fertilizingIntervalDays == null
            ? 30
            : _state.fertilizingIntervalDays);

    _updateState(
      _state.copyWith(
        enableFertilizerCare: enabled ?? _state.enableFertilizerCare,
        fertilizingIntervalDays: effectiveIntervalDays,
        lastFertilizerDate: lastDate ?? _state.lastFertilizerDate,
      ),
    );
    _validateForm();
  }

  /// Atualiza quantidade de água
  void setWaterAmount(String? amount) {
    _updateState(_state.copyWith(waterAmount: amount));
    _validateForm();
  }

  /// Captura imagem da câmera
  Future<void> captureImageFromCamera() async {
    _updateState(_state.copyWith(isUploadingImages: true, clearError: true));

    try {
      final result = await _imageService.captureFromCamera();

      result.fold(
        (failure) {
          _updateState(
            _state.copyWith(
              isUploadingImages: false,
              errorMessage: failure.message,
            ),
          );
        },
        (base64Image) {
          final imageResult = _imageService.addImageToList(
            _state.imageUrls,
            base64Image,
          );

          if (imageResult.isSuccess) {
            _updateState(
              _state.copyWith(
                isUploadingImages: false,
                imageUrls: imageResult.updatedImages,
                clearError: true,
              ),
            );
          } else {
            _updateState(
              _state.copyWith(
                isUploadingImages: false,
                errorMessage: imageResult.message,
              ),
            );
          }
        },
      );
    } catch (e) {
      _updateState(
        _state.copyWith(
          isUploadingImages: false,
          errorMessage: 'Erro inesperado: $e',
        ),
      );
    }
  }

  /// Seleciona imagem da galeria
  Future<void> selectImageFromGallery() async {
    _updateState(_state.copyWith(isUploadingImages: true, clearError: true));

    try {
      final result = await _imageService.selectFromGallery();

      result.fold(
        (failure) {
          _updateState(
            _state.copyWith(
              isUploadingImages: false,
              errorMessage: failure.message,
            ),
          );
        },
        (base64Image) {
          final imageResult = _imageService.addImageToList(
            _state.imageUrls,
            base64Image,
          );

          if (imageResult.isSuccess) {
            _updateState(
              _state.copyWith(
                isUploadingImages: false,
                imageUrls: imageResult.updatedImages,
                clearError: true,
              ),
            );
          } else {
            _updateState(
              _state.copyWith(
                isUploadingImages: false,
                errorMessage: imageResult.message,
              ),
            );
          }
        },
      );
    } catch (e) {
      _updateState(
        _state.copyWith(
          isUploadingImages: false,
          errorMessage: 'Erro inesperado: $e',
        ),
      );
    }
  }

  /// Remove imagem
  void removeImage(int index) {
    final result = _imageService.removeImageFromList(_state.imageUrls, index);

    if (result.isSuccess) {
      _updateState(
        _state.copyWith(imageUrls: result.updatedImages, clearError: true),
      );
    } else {
      _updateState(_state.copyWith(errorMessage: result.message));
    }
  }

  /// Salva planta
  Future<bool> savePlant() async {
    if (!_state.canSave) return false;

    _updateState(_state.copyWith(isSaving: true, clearError: true));

    try {
      if (_state.isEditMode) {
        return await _updatePlant();
      } else {
        return await _addPlant();
      }
    } catch (e) {
      _updateState(
        _state.copyWith(isSaving: false, errorMessage: 'Erro inesperado: $e'),
      );
      return false;
    }
  }

  /// Adiciona nova planta
  Future<bool> _addPlant() async {
    final params = _buildAddParams();
    final result = await _addPlantUseCase.call(params);

    return result.fold(
      (failure) {
        _updateState(
          _state.copyWith(isSaving: false, errorMessage: failure.message),
        );
        return false;
      },
      (plant) {
        _updateState(
          _state.copyWith(
            isSaving: false,
            originalPlant: plant,
            clearError: true,
          ),
        );
        return true;
      },
    );
  }

  /// Atualiza planta existente
  Future<bool> _updatePlant() async {
    final params = _buildUpdateParams();
    final result = await _updatePlantUseCase.call(params);

    return result.fold(
      (failure) {
        _updateState(
          _state.copyWith(isSaving: false, errorMessage: failure.message),
        );
        return false;
      },
      (plant) {
        _updateState(
          _state.copyWith(
            isSaving: false,
            originalPlant: plant,
            clearError: true,
          ),
        );
        return true;
      },
    );
  }

  /// Constrói parâmetros para adicionar planta
  AddPlantParams _buildAddParams() {
    if (kDebugMode) {
      print('🆕 _buildAddParams - Criando nova planta:');
      print('   💧 _state.enableWateringCare: ${_state.enableWateringCare}');
      print(
        '   💧 _state.wateringIntervalDays: ${_state.wateringIntervalDays}',
      );
      print('   💧 _state.lastWateringDate: ${_state.lastWateringDate}');
      print(
        '   🌿 _state.enableFertilizerCare: ${_state.enableFertilizerCare}',
      );
      print(
        '   🌿 _state.fertilizingIntervalDays: ${_state.fertilizingIntervalDays}',
      );
      print('   🌿 _state.lastFertilizerDate: ${_state.lastFertilizerDate}');
    }

    final config = PlantConfig(
      wateringIntervalDays: _state.wateringIntervalDays,
      fertilizingIntervalDays: _state.fertilizingIntervalDays,
      pruningIntervalDays: _state.pruningIntervalDays,
      waterAmount:
          _state.waterAmount?.trim().isNotEmpty == true
              ? _state.waterAmount
              : null,
      enableWateringCare: _state.enableWateringCare,
      lastWateringDate: _state.lastWateringDate,
      enableFertilizerCare: _state.enableFertilizerCare,
      lastFertilizerDate: _state.lastFertilizerDate,
    );

    return AddPlantParams(
      name: _state.name.trim(),
      species: _state.species.trim().isEmpty ? null : _state.species.trim(),
      spaceId: _state.spaceId,
      notes: _state.notes.trim().isEmpty ? null : _state.notes.trim(),
      plantingDate: _state.plantingDate,
      imageBase64: _state.imageBase64,
      imageUrls:
          _state.imageUrls.isEmpty ? null : List<String>.from(_state.imageUrls),
      config: config,
    );
  }

  /// Constrói parâmetros para atualizar planta
  UpdatePlantParams _buildUpdateParams() {
    if (kDebugMode) {
      print('🔄 _buildUpdateParams - Atualizando planta:');
      print('   💧 _state.enableWateringCare: ${_state.enableWateringCare}');
      print(
        '   💧 _state.wateringIntervalDays: ${_state.wateringIntervalDays}',
      );
      print('   💧 _state.lastWateringDate: ${_state.lastWateringDate}');
      print(
        '   🌿 _state.enableFertilizerCare: ${_state.enableFertilizerCare}',
      );
      print(
        '   🌿 _state.fertilizingIntervalDays: ${_state.fertilizingIntervalDays}',
      );
      print('   🌿 _state.lastFertilizerDate: ${_state.lastFertilizerDate}');
    }

    final config = PlantConfig(
      wateringIntervalDays: _state.wateringIntervalDays,
      fertilizingIntervalDays: _state.fertilizingIntervalDays,
      pruningIntervalDays: _state.pruningIntervalDays,
      waterAmount:
          _state.waterAmount?.trim().isNotEmpty == true
              ? _state.waterAmount
              : null,
      enableWateringCare: _state.enableWateringCare,
      lastWateringDate: _state.lastWateringDate,
      enableFertilizerCare: _state.enableFertilizerCare,
      lastFertilizerDate: _state.lastFertilizerDate,
    );

    return UpdatePlantParams(
      id: _state.originalPlant!.id,
      name: _state.name.trim(),
      species: _state.species.trim().isEmpty ? null : _state.species.trim(),
      spaceId: _state.spaceId,
      notes: _state.notes.trim().isEmpty ? null : _state.notes.trim(),
      plantingDate: _state.plantingDate,
      imageBase64: _state.imageBase64,
      imageUrls:
          _state.imageUrls.isEmpty ? null : List<String>.from(_state.imageUrls),
      config: config,
    );
  }

  /// Atualiza configurações de luz solar
  void setSunlightConfig({
    bool? enabled,
    int? intervalDays,
    DateTime? lastDate,
  }) {
    final effectiveIntervalDays =
        intervalDays ??
        (enabled == true && _state.sunlightIntervalDays == null
            ? 7
            : _state.sunlightIntervalDays);

    _updateState(
      _state.copyWith(
        enableSunlightCare: enabled ?? _state.enableSunlightCare,
        sunlightIntervalDays: effectiveIntervalDays,
        lastSunlightDate: lastDate ?? _state.lastSunlightDate,
      ),
    );
    _validateForm();
  }

  /// Atualiza configurações de inspeção de pragas
  void setPestInspectionConfig({
    bool? enabled,
    int? intervalDays,
    DateTime? lastDate,
  }) {
    final effectiveIntervalDays =
        intervalDays ??
        (enabled == true && _state.pestInspectionIntervalDays == null
            ? 14
            : _state.pestInspectionIntervalDays);

    _updateState(
      _state.copyWith(
        enablePestInspection: enabled ?? _state.enablePestInspection,
        pestInspectionIntervalDays: effectiveIntervalDays,
        lastPestInspectionDate: lastDate ?? _state.lastPestInspectionDate,
      ),
    );
    _validateForm();
  }

  /// Atualiza configurações de poda
  void setPruningConfig({
    bool? enabled,
    int? intervalDays,
    DateTime? lastDate,
  }) {
    final effectiveIntervalDays =
        intervalDays ??
        (enabled == true && _state.pruningIntervalDays == null
            ? 30
            : _state.pruningIntervalDays);

    _updateState(
      _state.copyWith(
        enablePruning: enabled ?? _state.enablePruning,
        pruningIntervalDays: effectiveIntervalDays,
        lastPruningDate: lastDate ?? _state.lastPruningDate,
      ),
    );
    _validateForm();
  }

  /// Atualiza configurações de replantio
  void setReplantingConfig({
    bool? enabled,
    int? intervalDays,
    DateTime? lastDate,
  }) {
    final effectiveIntervalDays =
        intervalDays ??
        (enabled == true && _state.replantingIntervalDays == null
            ? 180
            : _state.replantingIntervalDays);

    _updateState(
      _state.copyWith(
        enableReplanting: enabled ?? _state.enableReplanting,
        replantingIntervalDays: effectiveIntervalDays,
        lastReplantingDate: lastDate ?? _state.lastReplantingDate,
      ),
    );
    _validateForm();
  }

  /// Valida formulário completo
  void _validateForm() {
    final validation = _validationService.validatePlantForm(
      name: _state.name,
      species: _state.species,
      notes: _state.notes,
      plantingDate: _state.plantingDate,
      enableWateringCare: _state.enableWateringCare,
      wateringIntervalDays: _state.wateringIntervalDays,
      enableFertilizerCare: _state.enableFertilizerCare,
      fertilizingIntervalDays: _state.fertilizingIntervalDays,
      waterAmount: _state.waterAmount,
    );

    _updateState(
      _state.copyWith(
        fieldErrors: validation.errors,
        isFormValid: validation.isValid,
      ),
    );
  }

  /// Limpa erros
  void clearError() {
    _updateState(_state.copyWith(clearError: true));
  }

  /// Reset do formulário
  void reset() {
    _updateState(const PlantFormState());
  }

  /// Dispose - Libera recursos e limpa listeners
  @override
  void dispose() {
    _state = const PlantFormState();
    super.dispose();

    if (kDebugMode) {
      print('🧹 PlantFormStateManager disposed - listeners cleaned up');
    }
  }
}
