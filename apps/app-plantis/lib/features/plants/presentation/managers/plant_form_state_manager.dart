/// Manages plant form state transitions and validation
class PlantFormStateManager {
  /// Check if there are unsaved changes in the form
  bool hasUnsavedChanges({
    required String name,
    required String species,
    required String? spaceId,
    required String notes,
    required DateTime? plantingDate,
    required List<String> imageUrls,
    required bool? enableWateringCare,
    required int? wateringIntervalDays,
    required bool? enableFertilizerCare,
    required int? fertilizingIntervalDays,
    required bool? enableSunlightCare,
    required bool? enablePestInspection,
    required bool? enablePruning,
    required bool? enableReplanting,
  }) {
    if (name.trim().isNotEmpty) return true;
    if (species.trim().isNotEmpty) return true;
    if (spaceId != null) return true;
    if (notes.trim().isNotEmpty) return true;
    if (plantingDate != null) return true;
    if (imageUrls.isNotEmpty) return true;
    if (enableWateringCare == true || wateringIntervalDays != null) return true;
    if (enableFertilizerCare == true || fertilizingIntervalDays != null) {
      return true;
    }
    if (enableSunlightCare == true) return true;
    if (enablePestInspection == true) return true;
    if (enablePruning == true) return true;
    if (enableReplanting == true) return true;

    return false;
  }

  /// Build list of changed fields for display
  List<String> getChangedFields({
    required String name,
    required String species,
    required String? spaceId,
    required String notes,
    required DateTime? plantingDate,
    required List<String> imageUrls,
    required bool? enableWateringCare,
    required int? wateringIntervalDays,
    required bool? enableFertilizerCare,
    required int? fertilizingIntervalDays,
    required bool? enableSunlightCare,
    required bool? enablePestInspection,
    required bool? enablePruning,
    required bool? enableReplanting,
  }) {
    final changes = <String>[];

    if (name.trim().isNotEmpty) changes.add('Nome da planta');
    if (species.trim().isNotEmpty) changes.add('Espécie');
    if (spaceId != null) changes.add('Espaço selecionado');
    if (notes.trim().isNotEmpty) changes.add('Observações');
    if (plantingDate != null) changes.add('Data de plantio');
    if (imageUrls.isNotEmpty) {
      changes.add('Foto${imageUrls.length > 1 ? 's' : ''} da planta');
    }
    if (enableWateringCare == true || wateringIntervalDays != null) {
      changes.add('Configuração de rega');
    }
    if (enableFertilizerCare == true || fertilizingIntervalDays != null) {
      changes.add('Configuração de adubo');
    }
    if (enableSunlightCare == true) changes.add('Configuração de luz solar');
    if (enablePestInspection == true) {
      changes.add('Configuração de verificação de pragas');
    }
    if (enablePruning == true) changes.add('Configuração de poda');
    if (enableReplanting == true) changes.add('Configuração de replantio');

    return changes;
  }

  /// Format plant name for display
  String formatPlantName(String name) =>
      name.trim().isNotEmpty ? name : 'planta';

  /// Validate form before saving
  bool validateFormBeforeSave({required String name, required String species}) {
    if (name.trim().isEmpty) return false;
    if (species.trim().isEmpty) return false;
    return true;
  }

  /// Get save success message
  String getSaveSuccessMessage(bool isEditing) {
    return isEditing
        ? 'Planta atualizada com sucesso!'
        : 'Planta adicionada com sucesso!';
  }

  /// Get form title
  String getFormTitle(bool isEditing) {
    return isEditing ? 'Editar Planta' : 'Nova Planta';
  }
}
