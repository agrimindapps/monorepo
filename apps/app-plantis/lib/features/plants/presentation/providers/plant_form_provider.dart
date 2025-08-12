import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:core/core.dart';
import '../../domain/entities/plant.dart';
import '../../domain/usecases/get_plants_usecase.dart';
import '../../domain/usecases/add_plant_usecase.dart';
import '../../domain/usecases/update_plant_usecase.dart';
import '../../../../core/services/image_service.dart';

class PlantFormProvider extends ChangeNotifier {
  final GetPlantByIdUseCase getPlantByIdUseCase;
  final AddPlantUseCase addPlantUseCase;
  final UpdatePlantUseCase updatePlantUseCase;
  final ImageService imageService;

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
  String? _lightRequirement;
  String? _waterAmount;
  String? _soilType;
  double? _idealTemperature;
  double? _idealHumidity;

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
  String? get lightRequirement => _lightRequirement;
  String? get waterAmount => _waterAmount;
  String? get soilType => _soilType;
  double? get idealTemperature => _idealTemperature;
  double? get idealHumidity => _idealHumidity;

  // Form validation
  bool get isValid => _name.trim().isNotEmpty;
  
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
    
    if (_idealTemperature != null && (_idealTemperature! < -50 || _idealTemperature! > 60)) {
      errors['temperature'] = 'Temperatura deve estar entre -50°C e 60°C';
    }
    
    if (_idealHumidity != null && (_idealHumidity! < 0 || _idealHumidity! > 100)) {
      errors['humidity'] = 'Umidade deve estar entre 0% e 100%';
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
    notifyListeners();
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

  // Métodos para gerenciar múltiplas imagens
  Future<void> addImageFromCamera() async {
    _isUploadingImages = true;
    notifyListeners();

    try {
      final imageFile = await imageService.pickImageFromCamera();
      if (imageFile != null) {
        final downloadUrl = await imageService.uploadImage(
          imageFile,
          folder: ImageUploadType.plant.folder,
        );
        
        if (downloadUrl != null) {
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
          folder: ImageUploadType.plant.folder,
        );
        
        if (downloadUrl != null) {
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

  Future<void> addMultipleImagesFromGallery() async {
    _isUploadingImages = true;
    notifyListeners();

    try {
      final imageFiles = await imageService.pickMultipleImages(
        maxImages: 5 - _imageUrls.length, // Limitar total a 5 imagens
      );
      
      if (imageFiles.isNotEmpty) {
        final downloadUrls = await imageService.uploadMultipleImages(
          imageFiles,
          folder: ImageUploadType.plant.folder,
        );
        
        _imageUrls.addAll(downloadUrls);
      }
    } catch (e) {
      _errorMessage = 'Erro ao fazer upload das imagens';
    } finally {
      _isUploadingImages = false;
      notifyListeners();
    }
  }

  void removeImage(int index) {
    if (index >= 0 && index < _imageUrls.length) {
      final imageUrl = _imageUrls[index];
      _imageUrls.removeAt(index);
      notifyListeners();
      
      // Remover a imagem do Firebase Storage em background
      imageService.deleteImage(imageUrl);
    }
  }

  void removeAllImages() {
    final urlsToDelete = List<String>.from(_imageUrls);
    _imageUrls.clear();
    notifyListeners();
    
    // Remover todas as imagens do Firebase Storage em background
    imageService.deleteMultipleImages(urlsToDelete);
  }

  // Config setters
  void setWateringInterval(int? value) {
    _wateringIntervalDays = value;
    notifyListeners();
  }

  void setFertilizingInterval(int? value) {
    _fertilizingIntervalDays = value;
    notifyListeners();
  }

  void setPruningInterval(int? value) {
    _pruningIntervalDays = value;
    notifyListeners();
  }

  void setLightRequirement(String? value) {
    _lightRequirement = value;
    notifyListeners();
  }

  void setWaterAmount(String? value) {
    _waterAmount = value;
    notifyListeners();
  }

  void setSoilType(String? value) {
    _soilType = value;
    notifyListeners();
  }

  void setIdealTemperature(double? value) {
    _idealTemperature = value;
    notifyListeners();
  }

  void setIdealHumidity(double? value) {
    _idealHumidity = value;
    notifyListeners();
  }

  // Save plant
  Future<bool> savePlant() async {
    if (!isValid) return false;

    _isSaving = true;
    _errorMessage = null;
    notifyListeners();

    final result = isEditMode
        ? await updatePlantUseCase(_buildUpdateParams())
        : await addPlantUseCase(_buildAddParams());
    
    bool success = false;
    result.fold(
      (failure) {
        _errorMessage = _getErrorMessage(failure);
      },
      (savedPlant) {
        success = true;
        _originalPlant = savedPlant;
        _populateFormFromPlant(savedPlant);
      },
    );

    _isSaving = false;
    notifyListeners();

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
      _lightRequirement = config.lightRequirement;
      _waterAmount = config.waterAmount;
      _soilType = config.soilType;
      _idealTemperature = config.idealTemperature;
      _idealHumidity = config.idealHumidity;
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
    _lightRequirement = null;
    _waterAmount = null;
    _soilType = null;
    _idealTemperature = null;
    _idealHumidity = null;
  }

  AddPlantParams _buildAddParams() {
    final config = _hasConfigData()
        ? PlantConfig(
            wateringIntervalDays: _wateringIntervalDays,
            fertilizingIntervalDays: _fertilizingIntervalDays,
            pruningIntervalDays: _pruningIntervalDays,
            lightRequirement: _lightRequirement,
            waterAmount: _waterAmount,
            soilType: _soilType,
            idealTemperature: _idealTemperature,
            idealHumidity: _idealHumidity,
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
    final config = _hasConfigData()
        ? PlantConfig(
            wateringIntervalDays: _wateringIntervalDays,
            fertilizingIntervalDays: _fertilizingIntervalDays,
            pruningIntervalDays: _pruningIntervalDays,
            lightRequirement: _lightRequirement,
            waterAmount: _waterAmount,
            soilType: _soilType,
            idealTemperature: _idealTemperature,
            idealHumidity: _idealHumidity,
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
           _pruningIntervalDays != null ||
           _lightRequirement != null ||
           _waterAmount != null ||
           _soilType != null ||
           _idealTemperature != null ||
           _idealHumidity != null;
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

  @override
  void dispose() {
    super.dispose();
  }
}