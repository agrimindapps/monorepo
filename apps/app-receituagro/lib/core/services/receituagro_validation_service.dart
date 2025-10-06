import 'package:core/core.dart';
import 'package:flutter/foundation.dart';

/// ReceitaAgro-specific validation service that integrates with Core Package's ValidationService
/// Provides agricultural domain-specific validations while using core validation infrastructure
class ReceitaAgroValidationService {
  static final ReceitaAgroValidationService _instance = ReceitaAgroValidationService._internal();
  factory ReceitaAgroValidationService() => _instance;
  ReceitaAgroValidationService._internal();
  late final ValidationService _coreValidationService;
  bool _isInitialized = false;

  /// Initialize with Core Package's ValidationService
  void initialize(ValidationService coreValidationService) {
    _coreValidationService = coreValidationService;
    _isInitialized = true;
  }

  /// Validate agricultural data input
  ReceitaAgroValidationResult validateAgriculturalData(Map<String, dynamic> data) {
    if (!_isInitialized) {
      if (kDebugMode) print('ReceitaAgroValidationService not initialized, using fallback mode');
    }

    final errors = <String>[];
    try {
      if (data.containsKey('email')) {
        final email = data['email'] as String;
        if (email.isEmpty || !email.contains('@')) {
          errors.add('Email inválido');
        }
      }

      if (data.containsKey('phone')) {
        final phone = data['phone'] as String;
        if (phone.isEmpty || phone.length < 10) {
          errors.add('Telefone inválido');
        }
      }
    } catch (e) {
      if (kDebugMode) print('Core validation failed, using fallback: $e');
    }
    if (data.containsKey('cultura_name')) {
      final culturaResult = validateCulturaName(data['cultura_name'] as String);
      if (!culturaResult.isValid) {
        errors.addAll(culturaResult.errors);
      }
    }

    if (data.containsKey('praga_name')) {
      final pragaResult = validatePragaName(data['praga_name'] as String);
      if (!pragaResult.isValid) {
        errors.addAll(pragaResult.errors);
      }
    }

    if (data.containsKey('defensivo_name')) {
      final defensivoResult = validateDefensivoName(data['defensivo_name'] as String);
      if (!defensivoResult.isValid) {
        errors.addAll(defensivoResult.errors);
      }
    }

    if (data.containsKey('application_rate')) {
      final rateResult = validateApplicationRate(data['application_rate']);
      if (!rateResult.isValid) {
        errors.addAll(rateResult.errors);
      }
    }

    if (data.containsKey('area_hectares')) {
      final areaResult = validateAreaSize(data['area_hectares']);
      if (!areaResult.isValid) {
        errors.addAll(areaResult.errors);
      }
    }

    return ReceitaAgroValidationResult(
      isValid: errors.isEmpty,
      errors: errors,
    );
  }

  /// Validate cultura (crop) name
  ReceitaAgroValidationResult validateCulturaName(String culturaName) {
    final errors = <String>[];

    if (culturaName.isEmpty) {
      errors.add('Nome da cultura é obrigatório');
    }

    if (culturaName.length < 2) {
      errors.add('Nome da cultura deve ter pelo menos 2 caracteres');
    }

    if (culturaName.length > 100) {
      errors.add('Nome da cultura não pode exceder 100 caracteres');
    }
    if (!RegExp(r'^[a-zA-ZÀ-ÿ\s\-]+$').hasMatch(culturaName)) {
      errors.add('Nome da cultura contém caracteres inválidos');
    }
    final standardizedNames = {
      'soja': 'Soja',
      'milho': 'Milho',
      'algodao': 'Algodão',
      'cana': 'Cana-de-açúcar',
      'cafe': 'Café',
      'arroz': 'Arroz',
      'feijao': 'Feijão',
      'trigo': 'Trigo',
    };

    if (standardizedNames.containsKey(culturaName.toLowerCase())) {
    }

    return ReceitaAgroValidationResult(
      isValid: errors.isEmpty,
      errors: errors,
    );
  }

  /// Validate praga (pest) name
  ReceitaAgroValidationResult validatePragaName(String pragaName) {
    final errors = <String>[];

    if (pragaName.isEmpty) {
      errors.add('Nome da praga é obrigatório');
    }

    if (pragaName.length < 3) {
      errors.add('Nome da praga deve ter pelo menos 3 caracteres');
    }

    if (pragaName.length > 150) {
      errors.add('Nome da praga não pode exceder 150 caracteres');
    }
    if (!RegExp(r'^[a-zA-ZÀ-ÿ\s\-\.\(\)]+$').hasMatch(pragaName)) {
      errors.add('Nome da praga contém caracteres inválidos');
    }

    return ReceitaAgroValidationResult(
      isValid: errors.isEmpty,
      errors: errors,
    );
  }

  /// Validate defensivo (pesticide) name
  ReceitaAgroValidationResult validateDefensivoName(String defensivoName) {
    final errors = <String>[];

    if (defensivoName.isEmpty) {
      errors.add('Nome do defensivo é obrigatório');
    }

    if (defensivoName.length < 3) {
      errors.add('Nome do defensivo deve ter pelo menos 3 caracteres');
    }

    if (defensivoName.length > 200) {
      errors.add('Nome do defensivo não pode exceder 200 caracteres');
    }
    if (!RegExp(r'^[a-zA-Z0-9À-ÿ\s\-\.\+]+$').hasMatch(defensivoName)) {
      errors.add('Nome do defensivo contém caracteres inválidos');
    }

    return ReceitaAgroValidationResult(
      isValid: errors.isEmpty,
      errors: errors,
    );
  }

  /// Validate application rate (dose)
  ReceitaAgroValidationResult validateApplicationRate(dynamic applicationRate) {
    final errors = <String>[];

    if (applicationRate == null) {
      errors.add('Taxa de aplicação é obrigatória');
      return ReceitaAgroValidationResult(isValid: false, errors: errors);
    }

    double? rate;
    if (applicationRate is String) {
      rate = double.tryParse(applicationRate);
    } else if (applicationRate is num) {
      rate = applicationRate.toDouble();
    }

    if (rate == null) {
      errors.add('Taxa de aplicação deve ser um número válido');
      return ReceitaAgroValidationResult(isValid: false, errors: errors);
    }

    if (rate <= 0) {
      errors.add('Taxa de aplicação deve ser maior que zero');
    }

    if (rate > 1000) {
      errors.add('Taxa de aplicação parece muito alta (máximo 1000)');
    }

    return ReceitaAgroValidationResult(
      isValid: errors.isEmpty,
      errors: errors,
    );
  }

  /// Validate area size in hectares
  ReceitaAgroValidationResult validateAreaSize(dynamic areaSize) {
    final errors = <String>[];

    if (areaSize == null) {
      return const ReceitaAgroValidationResult(isValid: true, errors: []); // Area is optional
    }

    double? area;
    if (areaSize is String) {
      area = double.tryParse(areaSize);
    } else if (areaSize is num) {
      area = areaSize.toDouble();
    }

    if (area == null) {
      errors.add('Área deve ser um número válido');
      return ReceitaAgroValidationResult(isValid: false, errors: errors);
    }

    if (area <= 0) {
      errors.add('Área deve ser maior que zero');
    }

    if (area > 100000) {
      errors.add('Área parece muito grande (máximo 100.000 hectares)');
    }

    return ReceitaAgroValidationResult(
      isValid: errors.isEmpty,
      errors: errors,
    );
  }

  /// Validate comentário content
  ReceitaAgroValidationResult validateComentario(String comentario) {
    final errors = <String>[];

    if (comentario.isEmpty) {
      errors.add('Comentário não pode estar vazio');
    }

    if (comentario.length < 5) {
      errors.add('Comentário deve ter pelo menos 5 caracteres');
    }

    if (comentario.length > 1000) {
      errors.add('Comentário não pode exceder 1000 caracteres');
    }
    if (comentario.toLowerCase().contains('spam') ||
        comentario.toLowerCase().contains('teste teste teste')) {
      errors.add('Conteúdo parece ser spam');
    }
    try {
      final inappropriateWords = ['palavra1', 'palavra2']; // Placeholder
      for (final word in inappropriateWords) {
        if (comentario.toLowerCase().contains(word)) {
          errors.add('Comentário contém linguagem inapropriada');
          break;
        }
      }
    } catch (e) {
    }

    return ReceitaAgroValidationResult(
      isValid: errors.isEmpty,
      errors: errors,
    );
  }

  /// Validate diagnostic search filters
  ReceitaAgroValidationResult validateDiagnosticFilters(Map<String, dynamic> filters) {
    final errors = <String>[];
    if (filters.containsKey('cultura') && filters['cultura'] != null) {
      final culturaResult = validateCulturaName(filters['cultura'] as String);
      if (!culturaResult.isValid) {
        errors.add('Filtro de cultura inválido: ${culturaResult.errors.first}');
      }
    }
    if (filters.containsKey('praga') && filters['praga'] != null) {
      final pragaResult = validatePragaName(filters['praga'] as String);
      if (!pragaResult.isValid) {
        errors.add('Filtro de praga inválido: ${pragaResult.errors.first}');
      }
    }
    if (filters.containsKey('query') && filters['query'] != null) {
      final query = filters['query'] as String;
      if (query.length > 200) {
        errors.add('Termo de busca muito longo (máximo 200 caracteres)');
      }
    }

    return ReceitaAgroValidationResult(
      isValid: errors.isEmpty,
      errors: errors,
    );
  }

  /// Validate favorite item data
  ReceitaAgroValidationResult validateFavoriteItem(String type, String id, Map<String, dynamic> data) {
    final errors = <String>[];
    final validTypes = ['defensivo', 'praga', 'cultura', 'diagnostico'];
    if (!validTypes.contains(type)) {
      errors.add('Tipo de favorito inválido');
    }
    if (id.isEmpty || id.length > 50) {
      errors.add('ID do item favorito inválido');
    }
    switch (type) {
      case 'defensivo':
        if (!data.containsKey('nome') || data['nome'] == null) {
          errors.add('Nome do defensivo é obrigatório');
        } else {
          final nameResult = validateDefensivoName(data['nome'] as String);
          if (!nameResult.isValid) {
            errors.addAll(nameResult.errors);
          }
        }
        break;
      case 'praga':
        if (!data.containsKey('nome') || data['nome'] == null) {
          errors.add('Nome da praga é obrigatório');
        } else {
          final nameResult = validatePragaName(data['nome'] as String);
          if (!nameResult.isValid) {
            errors.addAll(nameResult.errors);
          }
        }
        break;
      case 'cultura':
        if (!data.containsKey('nome') || data['nome'] == null) {
          errors.add('Nome da cultura é obrigatório');
        } else {
          final nameResult = validateCulturaName(data['nome'] as String);
          if (!nameResult.isValid) {
            errors.addAll(nameResult.errors);
          }
        }
        break;
    }

    return ReceitaAgroValidationResult(
      isValid: errors.isEmpty,
      errors: errors,
    );
  }

  /// Get validation suggestions for agricultural inputs
  List<String> getValidationSuggestions(String input, String type) {
    switch (type) {
      case 'cultura':
        return _getCulturaSuggestions(input);
      case 'praga':
        return _getPragaSuggestions(input);
      case 'defensivo':
        return _getDefensivoSuggestions(input);
      default:
        return [];
    }
  }

  List<String> _getCulturaSuggestions(String input) {
    final commonCulturas = [
      'Soja', 'Milho', 'Algodão', 'Cana-de-açúcar', 'Café',
      'Arroz', 'Feijão', 'Trigo', 'Girassol', 'Sorgo'
    ];
    
    return commonCulturas
        .where((cultura) => cultura.toLowerCase().contains(input.toLowerCase()))
        .take(5)
        .toList();
  }

  List<String> _getPragaSuggestions(String input) {
    final commonPragas = [
      'Lagarta-do-cartucho', 'Percevejos', 'Ferrugem asiática',
      'Spodoptera frugiperda', 'Helicoverpa armigera', 'Diabrotica speciosa'
    ];
    
    return commonPragas
        .where((praga) => praga.toLowerCase().contains(input.toLowerCase()))
        .take(5)
        .toList();
  }

  List<String> _getDefensivoSuggestions(String input) {
    final commonDefensivos = [
      'Glifosato', '2,4-D', 'Atrazina', 'Paraquat', 'Dicamba',
      'Imidacloprida', 'Lambda-cialotrina', 'Tebuconazol'
    ];
    
    return commonDefensivos
        .where((defensivo) => defensivo.toLowerCase().contains(input.toLowerCase()))
        .take(5)
        .toList();
  }
}

/// ReceitaAgro specific validation result class to avoid conflict with Core Package ValidationResult
class ReceitaAgroValidationResult {
  final bool isValid;
  final List<String> errors;

  const ReceitaAgroValidationResult({
    required this.isValid,
    required this.errors,
  });

  String get firstError => errors.isNotEmpty ? errors.first : '';
  
  @override
  String toString() => isValid ? 'Valid' : 'Invalid: ${errors.join(', ')}';
  
  /// Convert to Core Package ValidationResult if needed
  /*
  ValidationResult toCoreValidationResult() {
    return ValidationResult(
      isValid: isValid,
      errors: errors,
    );
  }
  */
}
