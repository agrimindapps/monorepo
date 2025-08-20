// Project imports:
import '../../../../utils/medicamentos_utils.dart';

/// Form-specific helpers for medicamento registration
class FormHelpers {
  
  /// Gets field hint text based on medication type
  static String getHintForMedicationType(String? tipo) {
    switch (tipo?.toLowerCase()) {
      case 'antibiótico':
        return 'Ex: Amoxicilina, Cefalexina';
      case 'anti-inflamatório':
        return 'Ex: Meloxicam, Carprofeno';
      case 'vermífugo':
        return 'Ex: Drontal, Milbemax';
      case 'antiácido':
        return 'Ex: Omeprazol, Ranitidina';
      case 'vitamina':
        return 'Ex: Complexo B, Vitamina C';
      default:
        return 'Nome do medicamento';
    }
  }
  
  /// Gets field label text
  static String getFieldLabel(String field) {
    switch (field) {
      case 'nome':
        return 'Nome do Medicamento';
      case 'tipo':
        return 'Tipo';
      case 'dosagem':
        return 'Dosagem';
      case 'frequencia':
        return 'Frequência';
      case 'dataInicio':
        return 'Data de Início';
      case 'dataFim':
        return 'Data de Fim';
      case 'observacoes':
        return 'Observações';
      default:
        return field;
    }
  }
  
  /// Gets field hint text
  static String getFieldHint(String field) {
    switch (field) {
      case 'nome':
        return 'Digite o nome do medicamento';
      case 'tipo':
        return 'Selecione o tipo do medicamento';
      case 'dosagem':
        return 'Ex: 250mg, 1 comprimido';
      case 'frequencia':
        return 'Ex: 2x ao dia, De 8 em 8 horas';
      case 'dataInicio':
        return 'Quando iniciou o tratamento';
      case 'dataFim':
        return 'Quando termina o tratamento';
      case 'observacoes':
        return 'Informações adicionais sobre o medicamento';
      default:
        return '';
    }
  }
  
  /// Gets character count text
  static String getCharacterCount(String text, int maxLength) {
    return '${text.length}/$maxLength';
  }
  
  /// Gets medication type suggestions
  static List<String> getMedicationTypeSuggestions() {
    return MedicamentosUtils.getAvailableTipos();
  }
  
  /// Gets frequency suggestions based on medication type
  static List<String> getFrequencySuggestions(String? tipo) {
    switch (tipo?.toLowerCase()) {
      case 'antibiótico':
        return ['2x ao dia', '3x ao dia', 'De 8 em 8 horas', 'De 12 em 12 horas'];
      case 'anti-inflamatório':
        return ['1x ao dia', '2x ao dia', 'De 12 em 12 horas'];
      case 'vermífugo':
        return ['Dose única', '1x ao dia por 3 dias', '1x ao dia por 5 dias'];
      case 'vitamina':
        return ['1x ao dia', '1x por semana', '2x por semana'];
      default:
        return MedicamentosUtils.getFrequencias();
    }
  }
  
  /// Validates form specific to cadastro context
  static Map<String, String?> validateForm({
    required String? nome,
    required String? tipo,
    required String? dosagem,
    required String? frequencia,
    required DateTime? dataInicio,
    DateTime? dataFim,
    String? observacoes,
  }) {
    final errors = <String, String?>{};
    
    // Validate nome
    if (nome == null || nome.trim().isEmpty) {
      errors['nome'] = 'Nome do medicamento é obrigatório';
    } else if (nome.trim().length < 2) {
      errors['nome'] = 'Nome deve ter pelo menos 2 caracteres';
    }
    
    // Validate tipo
    if (tipo == null || tipo.trim().isEmpty) {
      errors['tipo'] = 'Tipo é obrigatório';
    }
    
    // Validate dosagem
    if (dosagem == null || dosagem.trim().isEmpty) {
      errors['dosagem'] = 'Dosagem é obrigatória';
    }
    
    // Validate frequencia
    if (frequencia == null || frequencia.trim().isEmpty) {
      errors['frequencia'] = 'Frequência é obrigatória';
    }
    
    // Validate dataInicio
    if (dataInicio == null) {
      errors['dataInicio'] = 'Data de início é obrigatória';
    } else if (dataInicio.isAfter(DateTime.now())) {
      errors['dataInicio'] = 'Data de início não pode ser futura';
    }
    
    // Validate dataFim
    if (dataFim != null && dataInicio != null) {
      if (dataFim.isBefore(dataInicio)) {
        errors['dataFim'] = 'Data de fim deve ser posterior à data de início';
      }
    }
    
    // Validate observacoes
    if (observacoes != null && observacoes.length > 500) {
      errors['observacoes'] = 'Observações devem ter no máximo 500 caracteres';
    }
    
    return errors;
  }
  
  /// Calculates form completion percentage
  static double calculateFormProgress({
    required String? nome,
    required String? tipo,
    required String? dosagem,
    required String? frequencia,
    required DateTime? dataInicio,
    DateTime? dataFim,
    String? observacoes,
  }) {
    int completed = 0;
    int total = 5; // Required fields: nome, tipo, dosagem, frequencia, dataInicio
    
    if (nome != null && nome.trim().isNotEmpty) completed++;
    if (tipo != null && tipo.trim().isNotEmpty) completed++;
    if (dosagem != null && dosagem.trim().isNotEmpty) completed++;
    if (frequencia != null && frequencia.trim().isNotEmpty) completed++;
    if (dataInicio != null) completed++;
    
    return completed / total;
  }
  
  /// Gets form progress text
  static String getFormProgressText(double progress) {
    final percentage = (progress * 100).round();
    
    if (percentage == 100) {
      return 'Formulário completo';
    } else if (percentage >= 80) {
      return 'Quase pronto ($percentage%)';
    } else if (percentage >= 60) {
      return 'Mais da metade ($percentage%)';
    } else if (percentage >= 40) {
      return 'Metade completa ($percentage%)';
    } else if (percentage > 0) {
      return 'Iniciado ($percentage%)';
    } else {
      return 'Não iniciado';
    }
  }
  
  /// Gets contextual help text for medication input
  static String getContextualHelpText(String? tipo) {
    switch (tipo?.toLowerCase()) {
      case 'antibiótico':
        return 'Importante: Complete todo o tratamento mesmo que o animal melhore.';
      case 'anti-inflamatório':
        return 'Administre preferencialmente com alimento para evitar problemas gástricos.';
      case 'vermífugo':
        return 'Recomenda-se vermifugar a cada 3-6 meses ou conforme orientação veterinária.';
      case 'vitamina':
        return 'Vitaminas devem ser administradas conforme prescrição para evitar overdose.';
      default:
        return 'Sempre siga as orientações do veterinário sobre dosagem e duração.';
    }
  }
  
  /// Formats medication data for form display
  static String formatMedicationForForm({
    required String nome,
    required String dosagem,
    required String frequencia,
  }) {
    return '$nome - $dosagem ($frequencia)';
  }
  
  /// Gets dosage suggestions based on medication type
  static List<String> getDosageSuggestions(String? tipo) {
    switch (tipo?.toLowerCase()) {
      case 'antibiótico':
        return ['250mg', '500mg', '1 comprimido', '2 comprimidos', '1ml', '2ml'];
      case 'anti-inflamatório':
        return ['1 comprimido', '0.5 comprimido', '1ml', '2ml', '5mg'];
      case 'vermífugo':
        return ['1 comprimido', '2 comprimidos', '1ml por kg', '2ml por kg'];
      case 'vitamina':
        return ['1 comprimido', '1 cápsula', '1ml', '5ml', '1 gota por kg'];
      default:
        return ['1 comprimido', '1ml', '2ml', '250mg', '500mg'];
    }
  }
  
  /// Checks if medication requires prescription
  static bool requiresPrescription(String? tipo) {
    switch (tipo?.toLowerCase()) {
      case 'antibiótico':
      case 'anti-inflamatório':
      case 'corticóide':
      case 'analgésico':
        return true;
      case 'vitamina':
      case 'suplemento':
        return false;
      default:
        return true; // Default to requiring prescription for safety
    }
  }
  
  /// Gets warning message for medication type
  static String? getWarningMessage(String? tipo) {
    switch (tipo?.toLowerCase()) {
      case 'antibiótico':
        return 'Atenção: Não interrompa o tratamento antes do prazo prescrito.';
      case 'corticóide':
        return 'Atenção: Corticóides devem ser reduzidos gradualmente.';
      case 'anti-inflamatório':
        return 'Atenção: Pode causar problemas gastrointestinais.';
      default:
        return null;
    }
  }
}
