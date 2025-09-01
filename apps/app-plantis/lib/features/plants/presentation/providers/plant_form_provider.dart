import 'dart:async';

import 'package:core/core.dart';
import 'package:flutter/foundation.dart';

import '../../../../core/services/image_service.dart' as local;
import '../../domain/entities/plant.dart';
import '../../domain/usecases/add_plant_usecase.dart';
import '../../domain/usecases/get_plants_usecase.dart';
import '../../domain/usecases/update_plant_usecase.dart';

/// Default care interval constants in days
class PlantCareIntervals {
  static const int defaultSunlightInterval = 7; // 1 week
  static const int defaultPestInspectionInterval = 14; // 2 weeks  
  static const int defaultPruningInterval = 90; // 3 months
  static const int defaultReplantingInterval = 365; // 1 year
}

class PlantFormProvider extends ChangeNotifier {
  final GetPlantByIdUseCase getPlantByIdUseCase;
  final AddPlantUseCase addPlantUseCase;
  final UpdatePlantUseCase updatePlantUseCase;
  final local.ImageService imageService;

  PlantFormProvider({
    required this.getPlantByIdUseCase,
    required this.addPlantUseCase,
    required this.updatePlantUseCase,
    required this.imageService,
  });

  // Form state
  Plant? _originalPlant;
  bool _isLoading = false;
  String? _errorMessage;
  bool _isSaving = false;

  // Form fields
  String _name = '';
  String _species = '';
  String? _spaceId;
  String _notes = '';
  DateTime? _plantingDate;
  String? _imageBase64; // Manter para compatibilidade
  List<String> _imageUrls = []; // Nova lista de URLs de imagens
  bool _isUploadingImages = false;

  // Plant config fields
  int? _wateringIntervalDays;
  int? _fertilizingIntervalDays;
  int? _pruningIntervalDays;
  String? _waterAmount;

  // New care configuration fields
  bool? _enableSunlightCare;
  int? _sunlightIntervalDays;
  DateTime? _lastSunlightDate;

  bool? _enablePestInspection;
  int? _pestInspectionIntervalDays;
  DateTime? _lastPestInspectionDate;

  bool? _enablePruning;
  DateTime? _lastPruningDate;

  bool? _enableReplanting;
  int? _replantingIntervalDays;
  DateTime? _lastReplantingDate;

  // New care fields for Water and Fertilizer
  bool? _enableWateringCare;
  DateTime? _lastWateringDate;

  bool? _enableFertilizerCare;
  DateTime? _lastFertilizerDate;

  // Getters
  Plant? get originalPlant => _originalPlant;
  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;
  String? get errorMessage => _errorMessage;
  bool get hasError => _errorMessage != null;
  bool get isEditMode => _originalPlant != null;

  // Form field getters
  String get name => _name;
  String get species => _species;
  String? get spaceId => _spaceId;
  String get notes => _notes;
  DateTime? get plantingDate => _plantingDate;
  String? get imageBase64 => _imageBase64;
  List<String> get imageUrls => List.unmodifiable(_imageUrls);
  bool get isUploadingImages => _isUploadingImages;
  bool get hasImages => _imageUrls.isNotEmpty;

  // Config getters
  int? get wateringIntervalDays => _wateringIntervalDays;
  int? get fertilizingIntervalDays => _fertilizingIntervalDays;
  int? get pruningIntervalDays => _pruningIntervalDays;
  String? get waterAmount => _waterAmount;

  // New care configuration getters
  bool? get enableSunlightCare => _enableSunlightCare;
  int? get sunlightIntervalDays => _sunlightIntervalDays;
  DateTime? get lastSunlightDate => _lastSunlightDate;

  bool? get enablePestInspection => _enablePestInspection;
  int? get pestInspectionIntervalDays => _pestInspectionIntervalDays;
  DateTime? get lastPestInspectionDate => _lastPestInspectionDate;

  bool? get enablePruning => _enablePruning;
  DateTime? get lastPruningDate => _lastPruningDate;

  bool? get enableReplanting => _enableReplanting;
  int? get replantingIntervalDays => _replantingIntervalDays;
  DateTime? get lastReplantingDate => _lastReplantingDate;

  // New care configuration getters
  bool? get enableWateringCare => _enableWateringCare;
  DateTime? get lastWateringDate => _lastWateringDate;

  bool? get enableFertilizerCare => _enableFertilizerCare;
  DateTime? get lastFertilizerDate => _lastFertilizerDate;

  // Form validation
  bool get isValid => _name.trim().isNotEmpty;

  /// Comprehensive check for unsaved changes by comparing current form state with original/initial state
  bool get hasUnsavedChanges {
    // For new plants (add mode), check if any field has meaningful data
    if (!isEditMode) {
      return _hasAnyFormData();
    }

    // For editing existing plants, compare current state with original
    if (_originalPlant == null) return false;

    return _hasChangesFromOriginal();
  }

  /// Checks if any form field contains meaningful data (for add mode)
  bool _hasAnyFormData() {
    // Basic info fields - these are high value user data
    if (_name.trim().isNotEmpty) return true;
    if (_species.trim().isNotEmpty) return true;
    if (_spaceId != null) return true;
    if (_notes.trim().isNotEmpty) return true;
    if (_plantingDate != null) return true;
    if (_imageUrls.isNotEmpty) return true;

    // Care configuration fields - meaningful settings
    if (_wateringIntervalDays != null) return true;
    if (_fertilizingIntervalDays != null) return true;
    if (_waterAmount?.trim().isNotEmpty == true) return true;

    // Extended care configuration - toggles and intervals are meaningful
    if (_enableWateringCare == true && (_wateringIntervalDays != null || _lastWateringDate != null)) return true;
    if (_enableFertilizerCare == true && (_fertilizingIntervalDays != null || _lastFertilizerDate != null)) return true;
    if (_enableSunlightCare == true && _sunlightIntervalDays != null) return true;
    if (_enablePestInspection == true && _pestInspectionIntervalDays != null) return true;
    if (_enablePruning == true && _pruningIntervalDays != null) return true;
    if (_enableReplanting == true && _replantingIntervalDays != null) return true;

    return false;
  }

  /// Compares current form state with original plant data (for edit mode)
  bool _hasChangesFromOriginal() {
    final original = _originalPlant!;
    final originalConfig = original.config;

    // Compare basic info
    if (_name.trim() != original.name) return true;
    if (_species.trim() != (original.species ?? '')) return true;
    if (_spaceId != original.spaceId) return true;
    if (_notes.trim() != (original.notes ?? '')) return true;
    if (_plantingDate != original.plantingDate) return true;
    
    // Compare images (order matters for user experience)
    if (_imageUrls.length != original.imageUrls.length) return true;
    for (int i = 0; i < _imageUrls.length; i++) {
      if (i >= original.imageUrls.length || _imageUrls[i] != original.imageUrls[i]) {
        return true;
      }
    }

    // Compare care configuration
    if (_wateringIntervalDays != originalConfig?.wateringIntervalDays) return true;
    if (_fertilizingIntervalDays != originalConfig?.fertilizingIntervalDays) return true;
    if (_pruningIntervalDays != originalConfig?.pruningIntervalDays) return true;
    if (_waterAmount?.trim() != originalConfig?.waterAmount) return true;

    // Compare extended care fields
    if (_enableWateringCare != originalConfig?.enableWateringCare) return true;
    if (_lastWateringDate != originalConfig?.lastWateringDate) return true;
    if (_enableFertilizerCare != originalConfig?.enableFertilizerCare) return true;
    if (_lastFertilizerDate != originalConfig?.lastFertilizerDate) return true;

    // Compare sunlight care
    final originalEnableSunlight = originalConfig?.sunlightCheckIntervalDays != null;
    if (_enableSunlightCare != originalEnableSunlight) return true;
    if (_sunlightIntervalDays != originalConfig?.sunlightCheckIntervalDays) return true;
    // Note: lastSunlightDate is not stored in PlantConfig, it's a UI-only field

    // Compare pest inspection
    final originalEnablePest = originalConfig?.pestInspectionIntervalDays != null;
    if (_enablePestInspection != originalEnablePest) return true;
    if (_pestInspectionIntervalDays != originalConfig?.pestInspectionIntervalDays) return true;
    // Note: lastPestInspectionDate is not stored in PlantConfig, it's a UI-only field

    // Compare pruning
    final originalEnablePruning = originalConfig?.pruningIntervalDays != null;
    if (_enablePruning != originalEnablePruning) return true;
    // Note: lastPruningDate is not stored in PlantConfig, it's a UI-only field

    // Compare replanting
    final originalEnableReplanting = originalConfig?.replantingIntervalDays != null;
    if (_enableReplanting != originalEnableReplanting) return true;
    if (_replantingIntervalDays != originalConfig?.replantingIntervalDays) return true;
    // Note: lastReplantingDate is not stored in PlantConfig, it's a UI-only field

    return false;
  }

  Map<String, String> get fieldErrors {
    final errors = <String, String>{};

    if (_name.trim().isEmpty) {
      errors['name'] = 'Nome é obrigatório';
    }

    if (_wateringIntervalDays != null && _wateringIntervalDays! <= 0) {
      errors['wateringInterval'] = 'Intervalo deve ser maior que 0';
    }

    if (_fertilizingIntervalDays != null && _fertilizingIntervalDays! <= 0) {
      errors['fertilizingInterval'] = 'Intervalo deve ser maior que 0';
    }

    if (_pruningIntervalDays != null && _pruningIntervalDays! <= 0) {
      errors['pruningInterval'] = 'Intervalo deve ser maior que 0';
    }

    return errors;
  }

  // Initialize form for editing
  Future<void> initializeForEdit(String plantId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await getPlantByIdUseCase(plantId);

    result.fold(
      (failure) {
        _errorMessage = _getErrorMessage(failure);
        _originalPlant = null;
      },
      (plant) {
        _originalPlant = plant;
        _populateFormFromPlant(plant);
        _errorMessage = null;
      },
    );

    _isLoading = false;
    notifyListeners();
  }

  // Initialize form for adding new plant
  void initializeForAdd() {
    _originalPlant = null;
    _clearForm();
    _errorMessage = null;
    notifyListeners();
  }

  // Form field setters
  void setName(String value) {
    _name = value;
    notifyListeners(); // This will trigger validation display in real-time
  }

  void setSpecies(String value) {
    _species = value;
    notifyListeners();
  }

  void setSpaceId(String? value) {
    _spaceId = value;
    notifyListeners();
  }

  void setNotes(String value) {
    _notes = value;
    notifyListeners();
  }

  void setPlantingDate(DateTime? value) {
    _plantingDate = value;
    notifyListeners();
  }

  void setImageBase64(String? value) {
    _imageBase64 = value;
    notifyListeners();
  }

  // Métodos para gerenciar uma única imagem
  Future<void> addImageFromCamera() async {
    _isUploadingImages = true;
    notifyListeners();

    try {
      final imageFile = await imageService.pickImageFromCamera();
      if (imageFile != null) {
        final downloadUrl = await imageService.uploadImage(
          imageFile,
          folder: local.ImageUploadType.plant.folder,
        );

        if (downloadUrl != null) {
          // Remove imagem anterior se existir
          if (_imageUrls.isNotEmpty) {
            final oldImageUrl = _imageUrls.first;
            unawaited(imageService.deleteImage(oldImageUrl)); // Fire and forget
          }
          _imageUrls.clear();
          _imageUrls.add(downloadUrl);
        }
      }
    } catch (e) {
      _errorMessage = 'Erro ao capturar imagem da câmera';
    } finally {
      _isUploadingImages = false;
      notifyListeners();
    }
  }

  Future<void> addImageFromGallery() async {
    _isUploadingImages = true;
    notifyListeners();

    try {
      final imageFile = await imageService.pickImageFromGallery();
      if (imageFile != null) {
        final downloadUrl = await imageService.uploadImage(
          imageFile,
          folder: local.ImageUploadType.plant.folder,
        );

        if (downloadUrl != null) {
          // Remove imagem anterior se existir
          if (_imageUrls.isNotEmpty) {
            final oldImageUrl = _imageUrls.first;
            unawaited(imageService.deleteImage(oldImageUrl)); // Fire and forget
          }
          _imageUrls.clear();
          _imageUrls.add(downloadUrl);
        }
      }
    } catch (e) {
      _errorMessage = 'Erro ao selecionar imagem da galeria';
    } finally {
      _isUploadingImages = false;
      notifyListeners();
    }
  }

  void removeImage(int index) {
    if (index >= 0 && index < _imageUrls.length) {
      final imageUrl = _imageUrls[index];
      _imageUrls.clear();
      notifyListeners();

      // Remover a imagem do Firebase Storage em background
      imageService.deleteImage(imageUrl);
    }
  }

  // Config setters
  void setWateringInterval(int? value) {
    _wateringIntervalDays = value;
    notifyListeners(); // This will trigger validation display in real-time
  }

  void setFertilizingInterval(int? value) {
    _fertilizingIntervalDays = value;
    notifyListeners(); // This will trigger validation display in real-time
  }

  void setWaterAmount(String? value) {
    _waterAmount = value;
    notifyListeners();
  }

  // New care configuration setters
  void setEnableSunlightCare(bool value) {
    _enableSunlightCare = value;
    if (!value) {
      _sunlightIntervalDays = null;
      _lastSunlightDate = null;
    } else {
      _sunlightIntervalDays ??= PlantCareIntervals.defaultSunlightInterval;
    }
    notifyListeners();
  }

  void setSunlightInterval(int value) {
    _sunlightIntervalDays = value;
    notifyListeners();
  }

  void setLastSunlightDate(DateTime? value) {
    _lastSunlightDate = value;
    notifyListeners();
  }

  void setEnablePestInspection(bool value) {
    _enablePestInspection = value;
    if (!value) {
      _pestInspectionIntervalDays = null;
      _lastPestInspectionDate = null;
    } else {
      _pestInspectionIntervalDays ??= PlantCareIntervals.defaultPestInspectionInterval;
    }
    notifyListeners();
  }

  void setPestInspectionInterval(int value) {
    _pestInspectionIntervalDays = value;
    notifyListeners();
  }

  void setLastPestInspectionDate(DateTime? value) {
    _lastPestInspectionDate = value;
    notifyListeners();
  }

  void setEnablePruning(bool value) {
    _enablePruning = value;
    if (!value) {
      _pruningIntervalDays = null;
      _lastPruningDate = null;
    } else {
      _pruningIntervalDays ??= PlantCareIntervals.defaultPruningInterval;
    }
    notifyListeners();
  }

  void setPruningInterval(int value) {
    _pruningIntervalDays = value;
    notifyListeners(); // This will trigger validation display in real-time
  }

  void setLastPruningDate(DateTime? value) {
    _lastPruningDate = value;
    notifyListeners();
  }

  void setEnableReplanting(bool value) {
    _enableReplanting = value;
    if (!value) {
      _replantingIntervalDays = null;
      _lastReplantingDate = null;
    } else {
      _replantingIntervalDays ??= PlantCareIntervals.defaultReplantingInterval;
    }
    notifyListeners();
  }

  void setReplantingInterval(int value) {
    _replantingIntervalDays = value;
    notifyListeners();
  }

  void setLastReplantingDate(DateTime? value) {
    _lastReplantingDate = value;
    notifyListeners();
  }

  // New care setters
  void setEnableWateringCare(bool value) {
    _enableWateringCare = value;
    if (!value) {
      _lastWateringDate = null;
    }
    notifyListeners();
  }

  void setLastWateringDate(DateTime? value) {
    _lastWateringDate = value;
    notifyListeners();
  }

  void setEnableFertilizerCare(bool value) {
    _enableFertilizerCare = value;
    if (!value) {
      _lastFertilizerDate = null;
    }
    notifyListeners();
  }

  void setLastFertilizerDate(DateTime? value) {
    _lastFertilizerDate = value;
    notifyListeners();
  }

  // Save plant
  Future<bool> savePlant() async {
    if (kDebugMode) {
      print('🌱 PlantFormProvider.savePlant() - Iniciando salvamento');
      print('🌱 PlantFormProvider.savePlant() - isEditMode: $isEditMode');
      print('🌱 PlantFormProvider.savePlant() - isValid: $isValid');
    }
    
    if (!isValid) return false;

    _isSaving = true;
    _errorMessage = null;
    notifyListeners();

    if (kDebugMode) {
      if (isEditMode) {
        final params = _buildUpdateParams();
        print('🌱 PlantFormProvider.savePlant() - UPDATE params:');
        print('   - id: ${params.id}');
        print('   - name: ${params.name}');
      } else {
        final params = _buildAddParams();
        print('🌱 PlantFormProvider.savePlant() - ADD params:');
        print('   - id: ${params.id}');
        print('   - name: ${params.name}');
      }
    }

    final result =
        isEditMode
            ? await updatePlantUseCase(_buildUpdateParams())
            : await addPlantUseCase(_buildAddParams());

    bool success = false;
    result.fold(
      (failure) {
        if (kDebugMode) {
          print('❌ PlantFormProvider.savePlant() - FALHA: ${failure.message}');
        }
        _errorMessage = _getErrorMessage(failure);
      },
      (savedPlant) {
        if (kDebugMode) {
          print('✅ PlantFormProvider.savePlant() - SUCESSO:');
          print('   - savedPlant.id: ${savedPlant.id}');
          print('   - savedPlant.name: ${savedPlant.name}');
          print('   - savedPlant.createdAt: ${savedPlant.createdAt}');
          print('   - savedPlant.updatedAt: ${savedPlant.updatedAt}');
        }
        success = true;
        _originalPlant = savedPlant;
        _populateFormFromPlant(savedPlant);
      },
    );

    _isSaving = false;
    notifyListeners();

    if (kDebugMode) {
      print('🌱 PlantFormProvider.savePlant() - Finalizando salvamento, success: $success');
    }

    return success;
  }

  // Clear error
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Reset form
  void resetForm() {
    if (isEditMode && _originalPlant != null) {
      _populateFormFromPlant(_originalPlant!);
    } else {
      _clearForm();
    }
    _errorMessage = null;
    notifyListeners();
  }

  // Private methods
  void _populateFormFromPlant(Plant plant) {
    _name = plant.name;
    _species = plant.species ?? '';
    _spaceId = plant.spaceId;
    _notes = plant.notes ?? '';
    _plantingDate = plant.plantingDate;
    _imageBase64 = plant.imageBase64;
    _imageUrls = List<String>.from(plant.imageUrls);

    final config = plant.config;
    if (config != null) {
      _wateringIntervalDays = config.wateringIntervalDays;
      _fertilizingIntervalDays = config.fertilizingIntervalDays;
      _pruningIntervalDays = config.pruningIntervalDays;
      _waterAmount = config.waterAmount;

      // Load new care configuration fields
      _sunlightIntervalDays = config.sunlightCheckIntervalDays;
      _enableSunlightCare = config.sunlightCheckIntervalDays != null;

      _pestInspectionIntervalDays = config.pestInspectionIntervalDays;
      _enablePestInspection = config.pestInspectionIntervalDays != null;

      _enablePruning = config.pruningIntervalDays != null;

      _replantingIntervalDays = config.replantingIntervalDays;
      _enableReplanting = config.replantingIntervalDays != null;

      // Load new care fields for Water and Fertilizer
      _enableWateringCare = config.enableWateringCare;
      _lastWateringDate = config.lastWateringDate;

      _enableFertilizerCare = config.enableFertilizerCare;
      _lastFertilizerDate = config.lastFertilizerDate;
    } else {
      _clearConfig();
    }
  }

  void _clearForm() {
    _name = '';
    _species = '';
    _spaceId = null;
    _notes = '';
    _plantingDate = null;
    _imageBase64 = null;
    _imageUrls.clear();
    _clearConfig();
  }

  void _clearConfig() {
    _wateringIntervalDays = null;
    _fertilizingIntervalDays = null;
    _pruningIntervalDays = null;
    _waterAmount = null;

    // Clear new care configuration fields
    _enableSunlightCare = null;
    _sunlightIntervalDays = null;
    _lastSunlightDate = null;

    _enablePestInspection = null;
    _pestInspectionIntervalDays = null;
    _lastPestInspectionDate = null;

    _enablePruning = null;
    _lastPruningDate = null;

    _enableReplanting = null;
    _replantingIntervalDays = null;
    _lastReplantingDate = null;

    // Clear new care fields for Water and Fertilizer
    _enableWateringCare = null;
    _lastWateringDate = null;

    _enableFertilizerCare = null;
    _lastFertilizerDate = null;
  }

  AddPlantParams _buildAddParams() {
    final config =
        _hasConfigData()
            ? PlantConfig(
              wateringIntervalDays: _wateringIntervalDays,
              fertilizingIntervalDays: _fertilizingIntervalDays,
              pruningIntervalDays:
                  (_enablePruning == true) ? _pruningIntervalDays : null,
              sunlightCheckIntervalDays:
                  (_enableSunlightCare == true) ? _sunlightIntervalDays : null,
              pestInspectionIntervalDays:
                  (_enablePestInspection == true)
                      ? _pestInspectionIntervalDays
                      : null,
              replantingIntervalDays:
                  (_enableReplanting == true) ? _replantingIntervalDays : null,
              waterAmount: _waterAmount,
              // Add new care fields
              enableWateringCare: _enableWateringCare,
              lastWateringDate: _lastWateringDate,
              enableFertilizerCare: _enableFertilizerCare,
              lastFertilizerDate: _lastFertilizerDate,
            )
            : null;

    return AddPlantParams(
      name: _name.trim(),
      species: _species.trim().isEmpty ? null : _species.trim(),
      spaceId: _spaceId,
      notes: _notes.trim().isEmpty ? null : _notes.trim(),
      plantingDate: _plantingDate,
      imageBase64: _imageBase64,
      imageUrls: _imageUrls.isEmpty ? null : List<String>.from(_imageUrls),
      config: config,
    );
  }

  UpdatePlantParams _buildUpdateParams() {
    final config =
        _hasConfigData()
            ? PlantConfig(
              wateringIntervalDays: _wateringIntervalDays,
              fertilizingIntervalDays: _fertilizingIntervalDays,
              pruningIntervalDays:
                  (_enablePruning == true) ? _pruningIntervalDays : null,
              sunlightCheckIntervalDays:
                  (_enableSunlightCare == true) ? _sunlightIntervalDays : null,
              pestInspectionIntervalDays:
                  (_enablePestInspection == true)
                      ? _pestInspectionIntervalDays
                      : null,
              replantingIntervalDays:
                  (_enableReplanting == true) ? _replantingIntervalDays : null,
              waterAmount: _waterAmount,
              // Add new care fields
              enableWateringCare: _enableWateringCare,
              lastWateringDate: _lastWateringDate,
              enableFertilizerCare: _enableFertilizerCare,
              lastFertilizerDate: _lastFertilizerDate,
            )
            : null;

    return UpdatePlantParams(
      id: _originalPlant!.id,
      name: _name.trim(),
      species: _species.trim().isEmpty ? null : _species.trim(),
      spaceId: _spaceId,
      notes: _notes.trim().isEmpty ? null : _notes.trim(),
      plantingDate: _plantingDate,
      imageBase64: _imageBase64,
      imageUrls: _imageUrls.isEmpty ? null : List<String>.from(_imageUrls),
      config: config,
    );
  }

  bool _hasConfigData() {
    return _wateringIntervalDays != null ||
        _fertilizingIntervalDays != null ||
        (_enablePruning == true && _pruningIntervalDays != null) ||
        (_enableSunlightCare == true && _sunlightIntervalDays != null) ||
        (_enablePestInspection == true &&
            _pestInspectionIntervalDays != null) ||
        (_enableReplanting == true && _replantingIntervalDays != null) ||
        _waterAmount != null ||
        (_enableWateringCare == true && _lastWateringDate != null) ||
        (_enableFertilizerCare == true && _lastFertilizerDate != null);
  }

  String _getErrorMessage(Failure failure) {
    switch (failure.runtimeType) {
      case ValidationFailure:
        return failure.message;
      case NotFoundFailure:
        return 'Planta não encontrada';
      case NetworkFailure:
        return 'Sem conexão com a internet';
      case ServerFailure:
        return 'Erro no servidor. Tente novamente.';
      case CacheFailure:
        return 'Erro local. Verifique o armazenamento.';
      default:
        return 'Erro inesperado. Tente novamente.';
    }
  }
}
