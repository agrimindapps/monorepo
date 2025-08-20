// Flutter imports:
import 'package:flutter/material.dart';

/// Configuração central para o módulo lembretes_cadastro
/// 
/// Concentra todas as constantes, validações e regras de negócio que eram
/// duplicadas entre LembreteConstants, LembreteFormValidators e LembreteFormService
class LembreteFormConfig {
  // Private constructor para prevenir instanciação
  LembreteFormConfig._();

  // ========== CONSTANTES DE VALIDAÇÃO ==========
  
  /// Limites de tamanho para campos de texto
  static const int minTituloLength = 3;
  static const int maxTituloLength = 50;
  static const int minDescricaoLength = 3;
  static const int maxDescricaoLength = 80;
  
  /// Limites temporais
  static const int maxDaysInFuture = 365;
  static const int minMinutesInFuture = 1;

  // ========== FORM SECTIONS (STANDARDIZED PATTERN) ==========
  
  /// Section titles mapping
  static const Map<String, String> titulosSecoes = {
    'lembrete_info': 'Informações do Lembrete',
    'data_hora': 'Data e Horário',
    'configuracoes': 'Configurações',
  };

  /// Section icons mapping  
  static const Map<String, String> iconesSecoes = {
    'lembrete_info': 'notification_important',
    'data_hora': 'schedule',
    'configuracoes': 'settings',
  };

  // ========== FIELD LABELS MAPPING (STANDARDIZED PATTERN) ==========
  
  /// Field labels mapping for consistency
  static const Map<String, String> rotulosCampos = {
    'titulo': 'Título *',
    'descricao': 'Descrição *',
    'animal': 'Animal *',
    'tipo': 'Tipo *',
    'data_lembrete': 'Data *',
    'hora_lembrete': 'Horário *',
    'repetir': 'Repetir',
    'concluido': 'Concluído',
  };

  // ========== FIELD HINTS MAPPING (STANDARDIZED PATTERN) ==========
  
  /// Field hints mapping for user guidance
  static const Map<String, String> dicasCampos = {
    'titulo': 'Ex: Consulta veterinária',
    'descricao': 'Descreva o lembrete',
    'animal': 'Selecione o animal',
    'tipo': 'Escolha o tipo de lembrete',
    'data_lembrete': 'dd/mm/aaaa',
    'hora_lembrete': 'HH:mm',
    'repetir': 'Frequência de repetição',
    'concluido': 'Marcar como concluído',
  };
  
  // ========== LISTAS DE VALORES VÁLIDOS ==========
  
  /// Tipos de lembrete disponíveis
  static const List<String> tiposValidos = [
    'Consulta',
    'Vacina',
    'Medicamento',
    'Banho e Tosa',
    'Exercício',
    'Alimentação',
    'Outros'
  ];
  
  /// Opções de repetição disponíveis
  static const List<String> repeticoesValidas = [
    'Sem repetição',
    'Diário',
    'Semanal',
    'Mensal',
    'Anual'
  ];
  
  // ========== CONFIGURAÇÕES DE FORMATAÇÃO ==========
  
  /// Padrões de formatação de data/hora
  static const String dateFormatPattern = 'dd/MM/yyyy';
  static const String timeFormatPattern = 'HH:mm';
  static const String dateTimeFormatPattern = 'dd/MM/yyyy às HH:mm';
  
  // ========== MENSAGENS DE ERRO PADRONIZADAS ==========
  
  /// Mensagens de erro para validação de título
  static const String errorTituloObrigatorio = 'Título é obrigatório';
  static const String errorTituloMuitoCurto = 'Título deve ter pelo menos $minTituloLength caracteres';
  static const String errorTituloMuitoLongo = 'Título não pode exceder $maxTituloLength caracteres';
  
  /// Mensagens de erro para validação de descrição
  static const String errorDescricaoObrigatoria = 'Descrição é obrigatória';
  static const String errorDescricaoMuitoCurta = 'Descrição deve ter pelo menos $minDescricaoLength caracteres';
  static const String errorDescricaoMuitoLonga = 'Descrição não pode exceder $maxDescricaoLength caracteres';
  
  /// Mensagens de erro para validação de animal
  static const String errorAnimalObrigatorio = 'Animal deve ser selecionado';
  
  /// Mensagens de erro para validação de data/hora
  static const String errorDataHoraObrigatoria = 'Data e hora são obrigatórias';
  static const String errorDataHoraPassado = 'Data e hora não podem ser no passado';
  static const String errorDataHoraMuitoFuturo = 'Data não pode ser superior a 1 ano';
  static const String errorDataObrigatoria = 'Data é obrigatória';
  static const String errorDataPassado = 'Data não pode ser anterior a hoje';
  static const String errorHoraObrigatoria = 'Hora é obrigatória';
  static const String errorHoraPassado = 'Hora não pode ser no passado';
  
  /// Mensagens de erro para validação de tipo e repetição
  static const String errorTipoObrigatorio = 'Tipo é obrigatório';
  static const String errorTipoInvalido = 'Tipo inválido';
  static const String errorRepeticaoObrigatoria = 'Opção de repetição é obrigatória';
  static const String errorRepeticaoInvalida = 'Opção de repetição inválida';

  // ========== VALIDATION ERROR MESSAGES (STANDARDIZED PATTERN) ==========
  
  /// Standard validation error messages
  static const String requiredFieldMessage = 'Campo obrigatório';
  static const String invalidDateMessage = 'Data inválida';
  static const String invalidTimeMessage = 'Horário inválido';
  static const String dateTooFutureMessage = 'Data muito distante no futuro';
  static const String timeTooEarlyMessage = 'Horário no passado';
  static const String animalNotSelectedMessage = 'Selecione um animal';
  static const String tipoNotSelectedMessage = 'Selecione o tipo de lembrete';

  // ========== SUCCESS MESSAGES (STANDARDIZED PATTERN) ==========
  
  /// Success messages
  static const String msgSuccessSave = 'Lembrete salvo com sucesso!';
  static const String msgSuccessUpdate = 'Lembrete atualizado com sucesso!';
  static const String msgSuccessDelete = 'Lembrete excluído com sucesso!';

  // ========== GENERAL ERROR MESSAGES (STANDARDIZED PATTERN) ==========
  
  /// General error messages
  static const String msgErrorSave = 'Erro ao salvar lembrete';
  static const String msgErrorUpdate = 'Erro ao atualizar lembrete';
  static const String msgErrorDelete = 'Erro ao excluir lembrete';
  static const String msgErrorLoad = 'Erro ao carregar dados';
  static const String msgErrorNetwork = 'Erro de conexão';
  static const String msgErrorValidation = 'Dados inválidos';

  // ========== BUTTON TEXTS (STANDARDIZED PATTERN) ==========
  
  /// Button text constants
  static const String buttonTextSave = 'Salvar';
  static const String buttonTextUpdate = 'Atualizar';
  static const String buttonTextCancel = 'Cancelar';
  static const String buttonTextDelete = 'Excluir';

  // ========== FORM TITLES (STANDARDIZED PATTERN) ==========
  
  /// Form titles
  static const String formTitleNew = 'Novo Lembrete';
  static const String formTitleEdit = 'Editar Lembrete';
  
  // ========== MÉTODOS DE VALIDAÇÃO CENTRALIZADOS ==========
  
  /// Valida título com regras unificadas
  static String? validateTitulo(String? value) {
    if (value == null || value.trim().isEmpty) {
      return errorTituloObrigatorio;
    }
    final trimmed = value.trim();
    if (trimmed.length < minTituloLength) {
      return errorTituloMuitoCurto;
    }
    if (trimmed.length > maxTituloLength) {
      return errorTituloMuitoLongo;
    }
    return null;
  }
  
  /// Valida descrição com regras unificadas
  static String? validateDescricao(String? value) {
    if (value == null || value.trim().isEmpty) {
      return errorDescricaoObrigatoria;
    }
    final trimmed = value.trim();
    if (trimmed.length < minDescricaoLength) {
      return errorDescricaoMuitoCurta;
    }
    if (trimmed.length > maxDescricaoLength) {
      return errorDescricaoMuitoLonga;
    }
    return null;
  }
  
  /// Valida animal ID
  static String? validateAnimalId(String? value) {
    if (value == null || value.trim().isEmpty) {
      return errorAnimalObrigatorio;
    }
    return null;
  }
  
  /// Valida data/hora combinada com regras unificadas
  static String? validateDataHora(DateTime? value) {
    if (value == null) {
      return errorDataHoraObrigatoria;
    }
    
    final now = DateTime.now();
    final limitePasado = now.subtract(const Duration(minutes: minMinutesInFuture));
    
    if (value.isBefore(limitePasado)) {
      return errorDataHoraPassado;
    }
    
    final limiteFuturo = now.add(const Duration(days: maxDaysInFuture));
    if (value.isAfter(limiteFuturo)) {
      return errorDataHoraMuitoFuturo;
    }
    
    return null;
  }
  
  /// Valida tipo
  static String? validateTipo(String? value) {
    if (value == null || value.trim().isEmpty) {
      return errorTipoObrigatorio;
    }
    
    if (!tiposValidos.contains(value.trim())) {
      return errorTipoInvalido;
    }
    
    return null;
  }
  
  /// Valida repetição
  static String? validateRepetir(String? value) {
    if (value == null || value.trim().isEmpty) {
      return errorRepeticaoObrigatoria;
    }
    
    if (!repeticoesValidas.contains(value.trim())) {
      return errorRepeticaoInvalida;
    }
    
    return null;
  }
  
  /// Valida apenas data (sem hora)
  static String? validateDataOnly(DateTime? date) {
    if (date == null) {
      return errorDataObrigatoria;
    }
    
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final selectedDate = DateTime(date.year, date.month, date.day);
    
    if (selectedDate.isBefore(today)) {
      return errorDataPassado;
    }
    
    final oneYearFromNow = DateTime(now.year + 1, now.month, now.day);
    if (selectedDate.isAfter(oneYearFromNow)) {
      return errorDataHoraMuitoFuturo;
    }
    
    return null;
  }
  
  /// Valida apenas hora (considerando data)
  static String? validateTimeOnly({
    required TimeOfDay? time,
    required DateTime date,
  }) {
    if (time == null) {
      return errorHoraObrigatoria;
    }
    
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final selectedDate = DateTime(date.year, date.month, date.day);
    
    if (selectedDate.isAtSameMomentAs(today)) {
      final selectedDateTime = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
      
      if (selectedDateTime.isBefore(now)) {
        return errorHoraPassado;
      }
    }
    
    return null;
  }
  
  // ========== MÉTODOS DE SANITIZAÇÃO ==========
  
  /// Sanitiza texto removendo espaços extras
  static String sanitizeText(String text) {
    return text.trim().replaceAll(RegExp(r'\s+'), ' ');
  }
  
  /// Sanitiza título
  static String sanitizeTitulo(String titulo) => sanitizeText(titulo);
  
  /// Sanitiza descrição
  static String sanitizeDescricao(String descricao) => sanitizeText(descricao);
  
  // ========== MÉTODOS DE VALIDAÇÃO BOOLEANA ==========
  
  /// Verifica se título é válido
  static bool isValidTitulo(String titulo) {
    return validateTitulo(titulo) == null;
  }
  
  /// Verifica se descrição é válida
  static bool isValidDescricao(String descricao) {
    return validateDescricao(descricao) == null;
  }
  
  /// Verifica se data/hora é válida
  static bool isValidDataHora(DateTime dataHora) {
    return validateDataHora(dataHora) == null;
  }
  
  /// Verifica se animal ID é válido
  static bool isValidAnimalId(String animalId) {
    return validateAnimalId(animalId) == null;
  }
  
  /// Verifica se tipo é válido
  static bool isValidTipo(String tipo) {
    return validateTipo(tipo) == null;
  }
  
  /// Verifica se repetição é válida
  static bool isValidRepetir(String repetir) {
    return validateRepetir(repetir) == null;
  }
  
  // ========== VALIDAÇÃO COMPLETA ==========
  
  /// Valida todos os campos de uma vez
  static Map<String, String?> validateAllFields({
    required String titulo,
    required String descricao,
    required String animalId,
    required DateTime dataHora,
    required String tipo,
    required String repetir,
  }) {
    return {
      'titulo': validateTitulo(titulo),
      'descricao': validateDescricao(descricao),
      'animalId': validateAnimalId(animalId),
      'dataHora': validateDataHora(dataHora),
      'tipo': validateTipo(tipo),
      'repetir': validateRepetir(repetir),
    };
  }
  
  /// Verifica se formulário completo é válido
  static bool isFormValid({
    required String titulo,
    required String descricao,
    required String animalId,
    required DateTime dataHora,
    String? tipo,
    String? repetir,
  }) {
    return validateTitulo(titulo) == null &&
           validateDescricao(descricao) == null &&
           validateAnimalId(animalId) == null &&
           validateDataHora(dataHora) == null &&
           (tipo == null || validateTipo(tipo) == null) &&
           (repetir == null || validateRepetir(repetir) == null);
  }
  
  /// Verifica se há algum erro de validação
  static bool hasAnyValidationError({
    required String titulo,
    required String descricao,
    required String animalId,
    required DateTime dataHora,
    required String tipo,
    required String repetir,
  }) {
    final errors = validateAllFields(
      titulo: titulo,
      descricao: descricao,
      animalId: animalId,
      dataHora: dataHora,
      tipo: tipo,
      repetir: repetir,
    );
    
    return errors.values.any((error) => error != null);
  }
  
  // ========== MÉTODOS UTILITÁRIOS ==========
  
  /// Retorna próxima data/hora válida
  static DateTime getNextValidDateTime([DateTime? currentDateTime]) {
    if (currentDateTime == null) {
      return DateTime.now().add(const Duration(hours: 1));
    }
    
    final now = DateTime.now();
    if (currentDateTime.isBefore(now)) {
      return now.add(const Duration(hours: 1));
    }
    
    return currentDateTime;
  }
  
  /// Verifica se data é hoje
  static bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
           date.month == now.month &&
           date.day == now.day;
  }
  
  /// Verifica se data é amanhã
  static bool isTomorrow(DateTime date) {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return date.year == tomorrow.year &&
           date.month == tomorrow.month &&
           date.day == tomorrow.day;
  }
  
  /// Verifica se data/hora está atrasada
  static bool isPastDue(DateTime dateTime) {
    return dateTime.isBefore(DateTime.now());
  }
  
  /// Calcula tempo até data/hora
  static Duration getTimeUntil(DateTime dateTime) {
    return dateTime.difference(DateTime.now());
  }
  
  /// Formata erro de validação
  static String formatValidationError(String fieldName, String? error) {
    if (error == null) return '';
    return '$fieldName: $error';
  }
  
  /// Retorna todos os erros de validação formatados
  static List<String> getAllValidationErrors({
    required String titulo,
    required String descricao,
    required String animalId,
    required DateTime dataHora,
    required String tipo,
    required String repetir,
  }) {
    final errors = <String>[];
    final validation = validateAllFields(
      titulo: titulo,
      descricao: descricao,
      animalId: animalId,
      dataHora: dataHora,
      tipo: tipo,
      repetir: repetir,
    );
    
    validation.forEach((field, error) {
      if (error != null) {
        errors.add(formatValidationError(field, error));
      }
    });
    
    return errors;
  }

  // ========== VALIDAÇÃO DE CONFIGURAÇÃO ==========
  
  /// Valida se a configuração está correta
  static bool validateConfiguration() {
    try {
      assert(minTituloLength > 0, 'minTituloLength deve ser positivo');
      assert(maxTituloLength > minTituloLength, 'maxTituloLength deve ser maior que minTituloLength');
      assert(minDescricaoLength > 0, 'minDescricaoLength deve ser positivo');
      assert(maxDescricaoLength > minDescricaoLength, 'maxDescricaoLength deve ser maior que minDescricaoLength');
      assert(maxDaysInFuture > 0, 'maxDaysInFuture deve ser positivo');
      assert(minMinutesInFuture > 0, 'minMinutesInFuture deve ser positivo');
      assert(tiposValidos.isNotEmpty, 'tiposValidos não pode estar vazio');
      assert(repeticoesValidas.isNotEmpty, 'repeticoesValidas não pode estar vazio');
      return true;
    } catch (e) {
      return false;
    }
  }
}
