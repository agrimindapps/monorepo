// Project imports:
import '../../../../models/pluviometros_models.dart';
import 'location_service.dart';

/// Serviço para gerenciar campos obrigatórios
class RequiredFieldsService {
  final LocationService _locationService;

  RequiredFieldsService({LocationService? locationService})
      : _locationService = locationService ?? LocationService();

  /// Define valores padrão para campos obrigatórios
  Future<RequiredFieldsData> getDefaultRequiredFields() async {
    // Tenta obter localização atual
    final locationResult = await _locationService.getCurrentLocation();

    return RequiredFieldsData(
      latitude: locationResult.isSuccess ? locationResult.latitudeString : null,
      longitude:
          locationResult.isSuccess ? locationResult.longitudeString : null,
      fkGrupo: _getDefaultGroup(),
      locationError:
          locationResult.isSuccess ? null : locationResult.errorMessage,
    );
  }

  /// Obtém o grupo padrão para novos pluviômetros
  String _getDefaultGroup() {
    // Por enquanto, retorna grupo padrão
    // Em produção, poderia buscar do perfil do usuário ou configurações
    return 'default_group';
  }

  /// Valida se todos os campos obrigatórios estão preenchidos
  FieldValidationResult validateRequiredFields(Pluviometro pluviometro) {
    final errors = <String>[];
    final warnings = <String>[];

    // Validação de descrição (obrigatória)
    if (pluviometro.descricao.trim().isEmpty) {
      errors.add('Descrição é obrigatória');
    }

    // Validação de quantidade (obrigatória)
    if (!pluviometro.isValidQuantity()) {
      errors.add('Quantidade deve ser um número válido e positivo');
    }

    // Validação de localização (recomendada)
    if (pluviometro.latitude == null || pluviometro.latitude!.isEmpty) {
      warnings
          .add('Localização não definida - recomendamos adicionar coordenadas');
    }

    if (pluviometro.longitude == null || pluviometro.longitude!.isEmpty) {
      warnings
          .add('Longitude não definida - recomendamos adicionar coordenadas');
    }

    // Validação de grupo (recomendado)
    if (pluviometro.fkGrupo == null || pluviometro.fkGrupo!.isEmpty) {
      warnings.add('Grupo não definido - recomendamos associar a um grupo');
    }

    return FieldValidationResult(
      isValid: errors.isEmpty,
      errors: errors,
      warnings: warnings,
    );
  }

  /// Preenche campos obrigatórios faltantes
  Future<Pluviometro> fillMissingRequiredFields(Pluviometro pluviometro) async {
    String? latitude = pluviometro.latitude;
    String? longitude = pluviometro.longitude;
    String? fkGrupo = pluviometro.fkGrupo;

    // Preenche localização se não estiver definida
    if ((latitude == null || latitude.isEmpty) &&
        (longitude == null || longitude.isEmpty)) {
      final locationResult = await _locationService.getCurrentLocation();
      if (locationResult.isSuccess) {
        latitude = locationResult.latitudeString;
        longitude = locationResult.longitudeString;
      }
    }

    // Preenche grupo se não estiver definido
    if (fkGrupo == null || fkGrupo.isEmpty) {
      fkGrupo = _getDefaultGroup();
    }

    return Pluviometro(
      id: pluviometro.id,
      createdAt: pluviometro.createdAt,
      updatedAt: pluviometro.updatedAt,
      descricao: pluviometro.descricao,
      quantidade: pluviometro.quantidade,
      latitude: latitude,
      longitude: longitude,
      fkGrupo: fkGrupo,
    );
  }

  /// Verifica se o pluviômetro tem todos os campos essenciais
  bool hasEssentialFields(Pluviometro pluviometro) {
    return pluviometro.descricao.isNotEmpty &&
        pluviometro.isValidQuantity() &&
        pluviometro.latitude != null &&
        pluviometro.longitude != null &&
        pluviometro.fkGrupo != null;
  }

  /// Retorna lista de campos obrigatórios faltantes
  List<String> getMissingRequiredFields(Pluviometro pluviometro) {
    final missing = <String>[];

    if (pluviometro.descricao.trim().isEmpty) {
      missing.add('Descrição');
    }

    if (!pluviometro.isValidQuantity()) {
      missing.add('Quantidade válida');
    }

    if (pluviometro.latitude == null || pluviometro.latitude!.isEmpty) {
      missing.add('Latitude');
    }

    if (pluviometro.longitude == null || pluviometro.longitude!.isEmpty) {
      missing.add('Longitude');
    }

    if (pluviometro.fkGrupo == null || pluviometro.fkGrupo!.isEmpty) {
      missing.add('Grupo');
    }

    return missing;
  }
}

/// Dados de campos obrigatórios
class RequiredFieldsData {
  final String? latitude;
  final String? longitude;
  final String? fkGrupo;
  final String? locationError;

  RequiredFieldsData({
    this.latitude,
    this.longitude,
    this.fkGrupo,
    this.locationError,
  });

  bool get hasLocation => latitude != null && longitude != null;
  bool get hasLocationError => locationError != null;
}

/// Resultado de validação de campos
class FieldValidationResult {
  final bool isValid;
  final List<String> errors;
  final List<String> warnings;

  FieldValidationResult({
    required this.isValid,
    required this.errors,
    required this.warnings,
  });

  String get errorMessage => errors.join('\n');
  String get warningMessage => warnings.join('\n');

  bool get hasWarnings => warnings.isNotEmpty;
  bool get hasErrors => errors.isNotEmpty;

  @override
  String toString() {
    if (isValid && warnings.isEmpty) return 'Todos os campos OK';

    final parts = <String>[];
    if (errors.isNotEmpty) parts.add('Erros: ${errors.join(', ')}');
    if (warnings.isNotEmpty) parts.add('Avisos: ${warnings.join(', ')}');

    return parts.join(' | ');
  }
}
