class FormValidationService {
  static const int maxNomeMedicamentoLength = 100;
  static const int maxDosagemLength = 50;
  static const int maxFrequenciaLength = 50;
  static const int maxDuracaoLength = 50;
  static const int maxObservacoesLength = 500;
  static const int minFieldLength = 2;

  static String? validateNomeMedicamento(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Nome do medicamento é obrigatório';
    }
    if (value.trim().length < minFieldLength) {
      return 'Nome deve ter pelo menos $minFieldLength caracteres';
    }
    if (value.trim().length > maxNomeMedicamentoLength) {
      return 'Nome não pode exceder $maxNomeMedicamentoLength caracteres';
    }
    return null;
  }

  static String? validateDosagem(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Dosagem é obrigatória';
    }
    if (value.trim().length > maxDosagemLength) {
      return 'Dosagem não pode exceder $maxDosagemLength caracteres';
    }
    return null;
  }

  static String? validateFrequencia(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Frequência é obrigatória';
    }
    if (value.trim().length < 3) {
      return 'Frequência deve ter pelo menos 3 caracteres';
    }
    if (value.trim().length > maxFrequenciaLength) {
      return 'Frequência não pode exceder $maxFrequenciaLength caracteres';
    }
    return null;
  }

  static String? validateDuracao(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Duração é obrigatória';
    }
    if (value.trim().length > maxDuracaoLength) {
      return 'Duração não pode exceder $maxDuracaoLength caracteres';
    }
    return null;
  }

  static String? validateObservacoes(String? value) {
    if (value != null && value.length > maxObservacoesLength) {
      return 'Observações não podem exceder $maxObservacoesLength caracteres';
    }
    return null;
  }

  static String? validateAnimalId(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Animal deve ser selecionado';
    }
    return null;
  }

  static String? validateDataInicio(DateTime? value) {
    if (value == null) {
      return 'Data de início é obrigatória';
    }
    final twoYearsAgo = DateTime.now().subtract(const Duration(days: 730));
    if (value.isBefore(twoYearsAgo)) {
      return 'Data não pode ser anterior a 2 anos';
    }
    return null;
  }

  static String? validateDataFim(DateTime? inicio, DateTime? fim) {
    if (fim == null) {
      return 'Data de fim é obrigatória';
    }
    if (inicio != null && fim.isBefore(inicio)) {
      return 'Data de fim deve ser posterior ou igual à data de início';
    }
    if (inicio != null) {
      final maxDuration = inicio.add(const Duration(days: 730)); // 2 anos
      if (fim.isAfter(maxDuration)) {
        return 'Tratamento não pode exceder 2 anos';
      }
    }
    return null;
  }

  static bool isFormValid({
    required String animalId,
    required String nomeMedicamento,
    required String dosagem,
    required String frequencia,
    required String duracao,
    required DateTime dataInicio,
    required DateTime dataFim,
    String? observacoes,
  }) {
    return validateAnimalId(animalId) == null &&
           validateNomeMedicamento(nomeMedicamento) == null &&
           validateDosagem(dosagem) == null &&
           validateFrequencia(frequencia) == null &&
           validateDuracao(duracao) == null &&
           validateDataInicio(dataInicio) == null &&
           validateDataFim(dataInicio, dataFim) == null &&
           validateObservacoes(observacoes) == null;
  }

  static Map<String, String?> validateAllFields({
    required String animalId,
    required String nomeMedicamento,
    required String dosagem,
    required String frequencia,
    required String duracao,
    required DateTime dataInicio,
    required DateTime dataFim,
    String? observacoes,
  }) {
    return {
      'animalId': validateAnimalId(animalId),
      'nomeMedicamento': validateNomeMedicamento(nomeMedicamento),
      'dosagem': validateDosagem(dosagem),
      'frequencia': validateFrequencia(frequencia),
      'duracao': validateDuracao(duracao),
      'dataInicio': validateDataInicio(dataInicio),
      'dataFim': validateDataFim(dataInicio, dataFim),
      'observacoes': validateObservacoes(observacoes),
    };
  }

  static bool isValidDateRange(DateTime inicio, DateTime fim) {
    return fim.isAfter(inicio) || fim.isAtSameMomentAs(inicio);
  }

  static Duration getTreatmentDuration(DateTime inicio, DateTime fim) {
    return fim.difference(inicio);
  }

  static bool isTreatmentDurationValid(DateTime inicio, DateTime fim) {
    final duration = getTreatmentDuration(inicio, fim);
    return duration.inDays >= 0 && duration.inDays <= 730; // Entre 0 dias e 2 anos
  }
}