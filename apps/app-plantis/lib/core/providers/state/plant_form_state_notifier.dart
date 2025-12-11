import 'package:core/core.dart' hide Column;
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../database/providers/database_providers.dart';
import '../../../features/plants/domain/entities/plant.dart';
import '../../../features/plants/domain/usecases/add_plant_usecase.dart';
import '../../../features/plants/domain/usecases/get_plants_usecase.dart';
import '../../../features/plants/domain/usecases/update_plant_usecase.dart';
import '../../../features/plants/presentation/providers/plants_providers.dart';
import '../../services/form_validation_service.dart';
import '../../services/image_management_service.dart';
import '../../services/local_image_storage_service.dart';
import '../image_providers.dart';

part 'plant_form_state_notifier.g.dart';

/// Estado do formulário de planta
class PlantFormState {
  final bool isLoading;
  final bool isSaving;
  final bool isUploadingImages;
  final double uploadProgress; // 0.0 - 1.0
  final int? uploadingImageIndex; // Índice da imagem sendo enviada
  final int? totalImagesToUpload; // Total de imagens a enviar
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
    this.uploadProgress = 0.0,
    this.uploadingImageIndex,
    this.totalImagesToUpload,
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
    double? uploadProgress,
    int? uploadingImageIndex,
    int? totalImagesToUpload,
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
    bool clearUploadProgress = false,
  }) {
    return PlantFormState(
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      isUploadingImages: isUploadingImages ?? this.isUploadingImages,
      uploadProgress: clearUploadProgress
          ? 0.0
          : (uploadProgress ?? this.uploadProgress),
      uploadingImageIndex: clearUploadProgress
          ? null
          : (uploadingImageIndex ?? this.uploadingImageIndex),
      totalImagesToUpload: clearUploadProgress
          ? null
          : (totalImagesToUpload ?? this.totalImagesToUpload),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      originalPlant: clearOriginalPlant
          ? null
          : (originalPlant ?? this.originalPlant),
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
  bool get canSave => isFormValid && hasChanges && !isSaving;

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

/// Notifier para gerenciamento de estado do formulário de planta
@riverpod
class PlantFormStateNotifier extends _$PlantFormStateNotifier {
  late final FormValidationService _validationService;
  late final ImageManagementService _imageService;
  late final LocalImageStorageService _localImageService;
  late final GetPlantsUseCase _getPlantsUseCase;
  late final AddPlantUseCase _addPlantUseCase;
  late final UpdatePlantUseCase _updatePlantUseCase;

  @override
  PlantFormState build() {
    _validationService = ref.read(formValidationServiceProvider);
    _imageService = ref.read(imageManagementServiceProvider);
    _localImageService = ref.read(localImageStorageServiceProvider);
    _getPlantsUseCase = ref.read(getPlantsUseCaseProvider);
    _addPlantUseCase = ref.read(addPlantUseCaseProvider);
    _updatePlantUseCase = ref.read(updatePlantUseCaseProvider);

    return const PlantFormState();
  }

  /// Carrega planta para edição (simplificado - busca por ID na lista)
  Future<void> loadPlant(String plantId) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final result = await _getPlantsUseCase.call(const NoParams());

      result.fold(
        (failure) {
          state = state.copyWith(
            isLoading: false,
            errorMessage: failure.message,
          );
        },
        (plants) {
          final plant = plants.where((p) => p.id == plantId).firstOrNull;

          if (plant == null) {
            state = state.copyWith(
              isLoading: false,
              errorMessage: 'Planta não encontrada',
            );
            return;
          }

          state = state.copyWith(
            isLoading: false,
            originalPlant: plant,
            name: plant.name,
            species: plant.species ?? '',
            spaceId: plant.spaceId,
            notes: plant.notes ?? '',
            plantingDate: plant.plantingDate,
            imageBase64: plant.imageBase64,
            imageUrls: List<String>.from(plant.imageUrls),
            // Watering
            wateringIntervalDays: plant.config?.wateringIntervalDays,
            enableWateringCare: plant.config?.enableWateringCare,
            lastWateringDate: plant.config?.lastWateringDate,
            // Fertilizer
            fertilizingIntervalDays: plant.config?.fertilizingIntervalDays,
            enableFertilizerCare: plant.config?.enableFertilizerCare,
            lastFertilizerDate: plant.config?.lastFertilizerDate,
            // Pruning
            pruningIntervalDays: plant.config?.pruningIntervalDays,
            enablePruning:
                plant.config?.pruningIntervalDays != null &&
                plant.config!.pruningIntervalDays! > 0,
            // Sunlight
            sunlightIntervalDays: plant.config?.sunlightCheckIntervalDays,
            enableSunlightCare:
                plant.config?.sunlightCheckIntervalDays != null &&
                plant.config!.sunlightCheckIntervalDays! > 0,
            // Pest Inspection
            pestInspectionIntervalDays:
                plant.config?.pestInspectionIntervalDays,
            enablePestInspection:
                plant.config?.pestInspectionIntervalDays != null &&
                plant.config!.pestInspectionIntervalDays! > 0,
            // Replanting
            replantingIntervalDays: plant.config?.replantingIntervalDays,
            enableReplanting:
                plant.config?.replantingIntervalDays != null &&
                plant.config!.replantingIntervalDays! > 0,
            // Other
            waterAmount: plant.config?.waterAmount,
            clearError: true,
          );

          _validateForm();
        },
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Erro inesperado: $e',
      );
    }
  }

  /// Inicializa formulário vazio para nova planta
  void initializeForNewPlant() {
    state = const PlantFormState();
    _validateForm();
  }

  /// Atualiza campo nome
  void setName(String name) {
    state = state.copyWith(name: name);
    _validateForm();
  }

  /// Atualiza campo espécie
  void setSpecies(String species) {
    state = state.copyWith(species: species);
    _validateForm();
  }

  /// Atualiza espaço
  void setSpaceId(String? spaceId) {
    state = state.copyWith(spaceId: spaceId);
    _validateForm();
  }

  /// Atualiza notas
  void setNotes(String notes) {
    state = state.copyWith(notes: notes);
    _validateForm();
  }

  /// Atualiza data de plantio
  void setPlantingDate(DateTime? date) {
    state = state.copyWith(plantingDate: date);
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
        (enabled == true && state.wateringIntervalDays == null
            ? 7
            : state.wateringIntervalDays);

    state = state.copyWith(
      enableWateringCare: enabled ?? state.enableWateringCare,
      wateringIntervalDays: effectiveIntervalDays,
      lastWateringDate: lastDate ?? state.lastWateringDate,
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
        (enabled == true && state.fertilizingIntervalDays == null
            ? 30
            : state.fertilizingIntervalDays);

    state = state.copyWith(
      enableFertilizerCare: enabled ?? state.enableFertilizerCare,
      fertilizingIntervalDays: effectiveIntervalDays,
      lastFertilizerDate: lastDate ?? state.lastFertilizerDate,
    );
    _validateForm();
  }

  /// Atualiza quantidade de água
  void setWaterAmount(String? amount) {
    state = state.copyWith(waterAmount: amount);
    _validateForm();
  }

  /// Captura imagem da câmera
  Future<void> captureImageFromCamera() async {
    state = state.copyWith(isUploadingImages: true, clearError: true);

    try {
      final result = await _imageService.captureFromCamera();

      result.fold(
        (failure) {
          state = state.copyWith(
            isUploadingImages: false,
            errorMessage: failure.message,
          );
        },
        (base64Image) {
          final imageResult = _imageService.addImageToList(
            state.imageUrls,
            base64Image,
          );

          if (imageResult.isSuccess) {
            state = state.copyWith(
              isUploadingImages: false,
              imageUrls: imageResult.updatedImages,
              clearError: true,
            );
          } else {
            state = state.copyWith(
              isUploadingImages: false,
              errorMessage: imageResult.message,
            );
          }
        },
      );
    } catch (e) {
      state = state.copyWith(
        isUploadingImages: false,
        errorMessage: 'Erro inesperado: $e',
      );
    }
  }

  /// Seleciona imagem da galeria
  Future<void> selectImageFromGallery() async {
    debugPrint(
      '📷 [PlantFormStateNotifier] selectImageFromGallery - Iniciando seleção',
    );
    state = state.copyWith(isUploadingImages: true, clearError: true);

    try {
      debugPrint(
        '📷 [PlantFormStateNotifier] selectImageFromGallery - Chamando _imageService.selectFromGallery()',
      );
      final result = await _imageService.selectFromGallery();
      debugPrint(
        '📷 [PlantFormStateNotifier] selectImageFromGallery - Resultado recebido: ${result.isRight() ? "Sucesso" : "Falha"}',
      );

      result.fold(
        (failure) {
          debugPrint(
            '📷 [PlantFormStateNotifier] selectImageFromGallery - FALHA: ${failure.message}',
          );
          state = state.copyWith(
            isUploadingImages: false,
            errorMessage: failure.message,
          );
        },
        (base64Image) {
          debugPrint(
            '📷 [PlantFormStateNotifier] selectImageFromGallery - Imagem recebida, tamanho: ${base64Image.length} chars',
          );
          debugPrint(
            '📷 [PlantFormStateNotifier] selectImageFromGallery - Prefixo: ${base64Image.substring(0, base64Image.length > 50 ? 50 : base64Image.length)}...',
          );

          final imageResult = _imageService.addImageToList(
            state.imageUrls,
            base64Image,
          );

          if (imageResult.isSuccess) {
            debugPrint(
              '📷 [PlantFormStateNotifier] selectImageFromGallery - Imagem adicionada à lista com sucesso',
            );
            debugPrint(
              '📷 [PlantFormStateNotifier] selectImageFromGallery - updatedImages.length: ${imageResult.updatedImages.length}',
            );
            state = state.copyWith(
              isUploadingImages: false,
              imageUrls: imageResult.updatedImages,
              clearError: true,
            );
            debugPrint(
              '📷 [PlantFormStateNotifier] selectImageFromGallery - Novo state.imageUrls.length: ${state.imageUrls.length}',
            );
          } else {
            debugPrint(
              '📷 [PlantFormStateNotifier] selectImageFromGallery - Erro ao adicionar imagem: ${imageResult.message}',
            );
            state = state.copyWith(
              isUploadingImages: false,
              errorMessage: imageResult.message,
            );
          }
        },
      );
    } catch (e, stackTrace) {
      debugPrint(
        '📷 [PlantFormStateNotifier] selectImageFromGallery - EXCEÇÃO: $e',
      );
      debugPrint(
        '📷 [PlantFormStateNotifier] selectImageFromGallery - StackTrace: $stackTrace',
      );
      state = state.copyWith(
        isUploadingImages: false,
        errorMessage: 'Erro inesperado: $e',
      );
    }
  }

  /// Remove imagem
  void removeImage(int index) {
    final result = _imageService.removeImageFromList(state.imageUrls, index);

    if (result.isSuccess) {
      state = state.copyWith(imageUrls: result.updatedImages, clearError: true);
    } else {
      state = state.copyWith(errorMessage: result.message);
    }
  }

  /// Salva planta
  ///
  /// Fluxo offline-first:
  /// 1. Salva a planta com imagens base64 no estado (para display imediato)
  /// 2. Após salvar, armazena as imagens como BLOB no Drift local
  /// 3. Upload para Firebase Storage acontece em background (sync service)
  Future<bool> savePlant() async {
    if (!state.canSave) return false;

    state = state.copyWith(isSaving: true, clearError: true);

    try {
      // Salvar planta (com base64 nas imageUrls para display)
      // O upload para Firebase acontecerá em background via sync service
      if (state.isEditMode) {
        return await _updatePlant();
      } else {
        return await _addPlant();
      }
    } catch (e) {
      state = state.copyWith(
        isSaving: false,
        isUploadingImages: false,
        errorMessage: 'Erro inesperado: $e',
        clearUploadProgress: true,
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
        state = state.copyWith(isSaving: false, errorMessage: failure.message);
        return false;
      },
      (plant) async {
        // Salvar imagens localmente como BLOB (offline-first)
        await _saveImagesToLocalStorage(plant.id);

        state = state.copyWith(
          isSaving: false,
          originalPlant: plant,
          clearError: true,
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
        state = state.copyWith(isSaving: false, errorMessage: failure.message);
        return false;
      },
      (plant) async {
        // Salvar imagens localmente como BLOB (offline-first)
        await _saveImagesToLocalStorage(plant.id);

        state = state.copyWith(
          isSaving: false,
          originalPlant: plant,
          clearError: true,
        );
        return true;
      },
    );
  }

  /// Salva imagens base64 no armazenamento local como BLOB
  Future<void> _saveImagesToLocalStorage(String plantFirebaseId) async {
    final base64Images = state.imageUrls
        .where((url) => url.startsWith('data:image/'))
        .toList();

    if (base64Images.isEmpty) return;

    debugPrint(
      '📷 [PlantFormStateNotifier] Salvando ${base64Images.length} imagens localmente para planta $plantFirebaseId',
    );

    try {
      // Obter o ID local do Drift pelo firebaseId
      final plantsRepo = ref.read(plantsDriftRepositoryProvider);
      final localPlantId = await plantsRepo.getLocalIdByFirebaseId(
        plantFirebaseId,
      );

      if (localPlantId == null) {
        debugPrint(
          '📷 [PlantFormStateNotifier] Erro: não encontrou ID local para firebaseId: $plantFirebaseId',
        );
        return;
      }

      debugPrint(
        '📷 [PlantFormStateNotifier] ID local encontrado: $localPlantId',
      );

      for (int i = 0; i < base64Images.length; i++) {
        final isPrimary = i == 0; // Primeira imagem é a principal
        await _localImageService.saveBase64Image(
          plantId: localPlantId,
          base64Image: base64Images[i],
          isPrimary: isPrimary,
        );
      }

      debugPrint(
        '📷 [PlantFormStateNotifier] Imagens salvas localmente com sucesso',
      );
    } catch (e) {
      debugPrint(
        '📷 [PlantFormStateNotifier] Erro ao salvar imagens localmente: $e',
      );
      // Não falhar a operação de salvar - as imagens estão no state.imageUrls
    }
  }

  /// Constrói parâmetros para adicionar planta
  AddPlantParams _buildAddParams() {
    final config = PlantConfig(
      wateringIntervalDays: state.enableWateringCare == true
          ? state.wateringIntervalDays
          : null,
      fertilizingIntervalDays: state.enableFertilizerCare == true
          ? state.fertilizingIntervalDays
          : null,
      pruningIntervalDays: state.enablePruning == true
          ? state.pruningIntervalDays
          : null,
      sunlightCheckIntervalDays: state.enableSunlightCare == true
          ? state.sunlightIntervalDays
          : null,
      pestInspectionIntervalDays: state.enablePestInspection == true
          ? state.pestInspectionIntervalDays
          : null,
      replantingIntervalDays: state.enableReplanting == true
          ? state.replantingIntervalDays
          : null,
      waterAmount: state.waterAmount?.trim().isNotEmpty == true
          ? state.waterAmount
          : null,
      enableWateringCare: state.enableWateringCare,
      lastWateringDate: state.lastWateringDate,
      enableFertilizerCare: state.enableFertilizerCare,
      lastFertilizerDate: state.lastFertilizerDate,
    );

    return AddPlantParams(
      name: state.name.trim(),
      species: state.species.trim().isEmpty ? null : state.species.trim(),
      spaceId: state.spaceId,
      notes: state.notes.trim().isEmpty ? null : state.notes.trim(),
      plantingDate: state.plantingDate,
      imageBase64: state.imageBase64,
      imageUrls: state.imageUrls.isEmpty
          ? null
          : List<String>.from(state.imageUrls),
      config: config,
    );
  }

  /// Constrói parâmetros para atualizar planta
  UpdatePlantParams _buildUpdateParams() {
    final config = PlantConfig(
      wateringIntervalDays: state.enableWateringCare == true
          ? state.wateringIntervalDays
          : null,
      fertilizingIntervalDays: state.enableFertilizerCare == true
          ? state.fertilizingIntervalDays
          : null,
      pruningIntervalDays: state.enablePruning == true
          ? state.pruningIntervalDays
          : null,
      sunlightCheckIntervalDays: state.enableSunlightCare == true
          ? state.sunlightIntervalDays
          : null,
      pestInspectionIntervalDays: state.enablePestInspection == true
          ? state.pestInspectionIntervalDays
          : null,
      replantingIntervalDays: state.enableReplanting == true
          ? state.replantingIntervalDays
          : null,
      waterAmount: state.waterAmount?.trim().isNotEmpty == true
          ? state.waterAmount
          : null,
      enableWateringCare: state.enableWateringCare,
      lastWateringDate: state.lastWateringDate,
      enableFertilizerCare: state.enableFertilizerCare,
      lastFertilizerDate: state.lastFertilizerDate,
    );

    return UpdatePlantParams(
      id: state.originalPlant!.id,
      name: state.name.trim(),
      species: state.species.trim().isEmpty ? null : state.species.trim(),
      spaceId: state.spaceId,
      notes: state.notes.trim().isEmpty ? null : state.notes.trim(),
      plantingDate: state.plantingDate,
      imageBase64: state.imageBase64,
      imageUrls: state.imageUrls.isEmpty
          ? null
          : List<String>.from(state.imageUrls),
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
        (enabled == true && state.sunlightIntervalDays == null
            ? 7
            : state.sunlightIntervalDays);

    state = state.copyWith(
      enableSunlightCare: enabled ?? state.enableSunlightCare,
      sunlightIntervalDays: effectiveIntervalDays,
      lastSunlightDate: lastDate ?? state.lastSunlightDate,
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
        (enabled == true && state.pestInspectionIntervalDays == null
            ? 14
            : state.pestInspectionIntervalDays);

    state = state.copyWith(
      enablePestInspection: enabled ?? state.enablePestInspection,
      pestInspectionIntervalDays: effectiveIntervalDays,
      lastPestInspectionDate: lastDate ?? state.lastPestInspectionDate,
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
        (enabled == true && state.pruningIntervalDays == null
            ? 30
            : state.pruningIntervalDays);

    state = state.copyWith(
      enablePruning: enabled ?? state.enablePruning,
      pruningIntervalDays: effectiveIntervalDays,
      lastPruningDate: lastDate ?? state.lastPruningDate,
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
        (enabled == true && state.replantingIntervalDays == null
            ? 180
            : state.replantingIntervalDays);

    state = state.copyWith(
      enableReplanting: enabled ?? state.enableReplanting,
      replantingIntervalDays: effectiveIntervalDays,
      lastReplantingDate: lastDate ?? state.lastReplantingDate,
    );
    _validateForm();
  }

  /// Valida formulário completo
  void _validateForm() {
    final validation = _validationService.validatePlantForm(
      name: state.name,
      species: state.species,
      notes: state.notes,
      plantingDate: state.plantingDate,
      enableWateringCare: state.enableWateringCare,
      wateringIntervalDays: state.wateringIntervalDays,
      enableFertilizerCare: state.enableFertilizerCare,
      fertilizingIntervalDays: state.fertilizingIntervalDays,
      waterAmount: state.waterAmount,
    );

    state = state.copyWith(
      fieldErrors: validation.errors,
      isFormValid: validation.isValid,
    );
  }

  /// Limpa erros
  void clearError() {
    state = state.copyWith(clearError: true);
  }

  /// Reset do formulário
  void reset() {
    state = const PlantFormState();
  }
}

// Providers for use cases
@riverpod
FormValidationService formValidationService(Ref ref) {
  return FormValidationService();
}

@riverpod
GetPlantsUseCase getPlantsUseCaseForForm(Ref ref) {
  return ref.watch(getPlantsUseCaseProvider);
}

@riverpod
AddPlantUseCase addPlantUseCaseForForm(Ref ref) {
  return ref.watch(addPlantUseCaseProvider);
}

@riverpod
UpdatePlantUseCase updatePlantUseCaseForForm(Ref ref) {
  return ref.watch(updatePlantUseCaseProvider);
}

// LEGACY ALIAS
// ignore: deprecated_member_use_from_same_package
const plantFormStateNotifierProvider = plantFormStateProvider;
