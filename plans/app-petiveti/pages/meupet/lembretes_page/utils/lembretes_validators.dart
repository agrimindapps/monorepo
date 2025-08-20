class LembretesValidators {
  static const int maxTituloLength = 100;
  static const int maxDescricaoLength = 500;
  static const int maxTipoLength = 50;
  static const int minTituloLength = 3;
  static const int minDescricaoLength = 5;

  static String? validateTitulo(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Título é obrigatório';
    }
    final trimmed = value.trim();
    if (trimmed.length < minTituloLength) {
      return 'Título deve ter pelo menos $minTituloLength caracteres';
    }
    if (trimmed.length > maxTituloLength) {
      return 'Título não pode exceder $maxTituloLength caracteres';
    }
    return null;
  }

  static String? validateDescricao(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Descrição é obrigatória';
    }
    final trimmed = value.trim();
    if (trimmed.length < minDescricaoLength) {
      return 'Descrição deve ter pelo menos $minDescricaoLength caracteres';
    }
    if (trimmed.length > maxDescricaoLength) {
      return 'Descrição não pode exceder $maxDescricaoLength caracteres';
    }
    return null;
  }

  static String? validateTipo(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Tipo é obrigatório';
    }
    final trimmed = value.trim();
    if (trimmed.length > maxTipoLength) {
      return 'Tipo não pode exceder $maxTipoLength caracteres';
    }
    return null;
  }

  static String? validateAnimalId(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Animal deve ser selecionado';
    }
    return null;
  }

  static String? validateDataHora(DateTime? value) {
    if (value == null) {
      return 'Data e hora são obrigatórias';
    }
    
    final now = DateTime.now();
    final oneYearAgo = now.subtract(const Duration(days: 365));
    final fiveYearsFromNow = now.add(const Duration(days: 1825));
    
    if (value.isBefore(oneYearAgo)) {
      return 'Data não pode ser anterior a um ano';
    }
    if (value.isAfter(fiveYearsFromNow)) {
      return 'Data não pode ser posterior a 5 anos';
    }
    
    return null;
  }

  static String? validateRepetir(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Opção de repetição é obrigatória';
    }
    
    final validOptions = [
      'Não repetir',
      'Diário',
      'Semanal',
      'Quinzenal',
      'Mensal',
      'Trimestral',
      'Semestral',
      'Anual',
    ];
    
    if (!validOptions.contains(value.trim())) {
      return 'Opção de repetição inválida';
    }
    
    return null;
  }

  static bool isFormValid({
    required String titulo,
    required String descricao,
    required String tipo,
    required String animalId,
    required DateTime dataHora,
    required String repetir,
  }) {
    return validateTitulo(titulo) == null &&
           validateDescricao(descricao) == null &&
           validateTipo(tipo) == null &&
           validateAnimalId(animalId) == null &&
           validateDataHora(dataHora) == null &&
           validateRepetir(repetir) == null;
  }

  static Map<String, String?> validateAllFields({
    required String titulo,
    required String descricao,
    required String tipo,
    required String animalId,
    required DateTime dataHora,
    required String repetir,
  }) {
    return {
      'titulo': validateTitulo(titulo),
      'descricao': validateDescricao(descricao),
      'tipo': validateTipo(tipo),
      'animalId': validateAnimalId(animalId),
      'dataHora': validateDataHora(dataHora),
      'repetir': validateRepetir(repetir),
    };
  }

  static bool isValidTitulo(String titulo) {
    final trimmed = titulo.trim();
    return trimmed.length >= minTituloLength && 
           trimmed.length <= maxTituloLength;
  }

  static bool isValidDescricao(String descricao) {
    final trimmed = descricao.trim();
    return trimmed.length >= minDescricaoLength && 
           trimmed.length <= maxDescricaoLength;
  }

  static bool isValidTipo(String tipo) {
    final trimmed = tipo.trim();
    return trimmed.isNotEmpty && trimmed.length <= maxTipoLength;
  }

  static bool isValidDataHora(DateTime dataHora) {
    final now = DateTime.now();
    final oneYearAgo = now.subtract(const Duration(days: 365));
    final fiveYearsFromNow = now.add(const Duration(days: 1825));
    
    return !dataHora.isBefore(oneYearAgo) && !dataHora.isAfter(fiveYearsFromNow);
  }

  static bool isValidRepetir(String repetir) {
    final validOptions = [
      'Não repetir',
      'Diário',
      'Semanal',
      'Quinzenal',
      'Mensal',
      'Trimestral',
      'Semestral',
      'Anual',
    ];
    
    return validOptions.contains(repetir.trim());
  }

  static String sanitizeTitulo(String titulo) {
    return titulo.trim().replaceAll(RegExp(r'\s+'), ' ');
  }

  static String sanitizeDescricao(String descricao) {
    return descricao.trim().replaceAll(RegExp(r'\s+'), ' ');
  }

  static String sanitizeTipo(String tipo) {
    return tipo.trim().replaceAll(RegExp(r'\s+'), ' ');
  }

  static DateTime? getNextValidDateTime(DateTime? currentDateTime) {
    if (currentDateTime == null) {
      return DateTime.now().add(const Duration(hours: 1));
    }
    
    final now = DateTime.now();
    if (currentDateTime.isBefore(now)) {
      return now.add(const Duration(hours: 1));
    }
    
    return currentDateTime;
  }

  static List<String> getValidRepetirOptions() {
    return [
      'Não repetir',
      'Diário',
      'Semanal',
      'Quinzenal',
      'Mensal',
      'Trimestral',
      'Semestral',
      'Anual',
    ];
  }

  static String? validateSearchQuery(String? query) {
    if (query != null && query.length > 100) {
      return 'Busca não pode exceder 100 caracteres';
    }
    return null;
  }
}