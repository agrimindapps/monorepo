class ConsultaFormValidators {
  static Map<String, String?> validateAllFields({
    required String animalId,
    required String veterinario,
    required String motivo,
    required String diagnostico,
    required String observacoes,
    required DateTime dataConsulta,
    required double valor,
  }) {
    final errors = <String, String?>{};

    // Validar animal ID
    if (animalId.isEmpty) {
      errors['animalId'] = 'Selecione um animal';
    }

    // Validar veterinário
    if (veterinario.trim().isEmpty) {
      errors['veterinario'] = 'Nome do veterinário é obrigatório';
    } else if (veterinario.trim().length < 2) {
      errors['veterinario'] = 'Nome deve ter pelo menos 2 caracteres';
    }

    // Validar motivo
    if (motivo.trim().isEmpty) {
      errors['motivo'] = 'Motivo da consulta é obrigatório';
    } else if (motivo.trim().length < 3) {
      errors['motivo'] = 'Motivo deve ter pelo menos 3 caracteres';
    }

    // Validar diagnóstico
    if (diagnostico.trim().isEmpty) {
      errors['diagnostico'] = 'Diagnóstico é obrigatório';
    } else if (diagnostico.trim().length < 3) {
      errors['diagnostico'] = 'Diagnóstico deve ter pelo menos 3 caracteres';
    }

    // Validar data da consulta
    final now = DateTime.now();
    final twoYearsAgo = DateTime(now.year - 2, now.month, now.day);
    final oneYearFromNow = DateTime(now.year + 1, now.month, now.day);
    
    if (dataConsulta.isBefore(twoYearsAgo)) {
      errors['dataConsulta'] = 'Data não pode ser anterior a 2 anos';
    } else if (dataConsulta.isAfter(oneYearFromNow)) {
      errors['dataConsulta'] = 'Data não pode ser superior a 1 ano no futuro';
    }

    // Validar valor
    if (valor < 0) {
      errors['valor'] = 'Valor não pode ser negativo';
    } else if (valor > 10000) {
      errors['valor'] = 'Valor muito alto para uma consulta';
    }

    return errors;
  }

  static String? validateVeterinario(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Nome do veterinário é obrigatório';
    }
    if (value.trim().length < 2) {
      return 'Nome deve ter pelo menos 2 caracteres';
    }
    return null;
  }

  static String? validateMotivo(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Motivo da consulta é obrigatório';
    }
    if (value.trim().length < 3) {
      return 'Motivo deve ter pelo menos 3 caracteres';
    }
    return null;
  }

  static String? validateDiagnostico(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Diagnóstico é obrigatório';
    }
    if (value.trim().length < 3) {
      return 'Diagnóstico deve ter pelo menos 3 caracteres';
    }
    return null;
  }

  static String? validateValor(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // Valor pode ser opcional
    }
    
    final valorDouble = double.tryParse(value.replaceAll(',', '.'));
    if (valorDouble == null) {
      return 'Valor inválido';
    }
    
    if (valorDouble < 0) {
      return 'Valor não pode ser negativo';
    }
    
    if (valorDouble > 10000) {
      return 'Valor muito alto para uma consulta';
    }
    
    return null;
  }
}