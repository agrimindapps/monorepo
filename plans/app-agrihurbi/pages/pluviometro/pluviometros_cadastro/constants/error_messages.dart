/// Constantes para mensagens de erro padronizadas
class ErrorMessages {
  // Mensagens de validação para campos obrigatórios
  static const String requiredField = 'Este campo é obrigatório';
  static const String descricaoRequired = 'Descrição é obrigatória';
  static const String quantidadeRequired = 'Quantidade é obrigatória';

  // Mensagens de validação para descrição
  static const String descricaoMinLength =
      'Descrição deve ter pelo menos 3 caracteres';
  static const String descricaoMaxLength =
      'Descrição deve ter no máximo 80 caracteres';
  static const String descricaoInvalidFormat =
      'Descrição contém caracteres inválidos';
  static const String descricaoAlreadyExists =
      'Já existe um pluviômetro com esta descrição';

  // Mensagens de validação para quantidade
  static const String quantidadeInvalidNumber = 'Digite um número válido';
  static const String quantidadeNegative = 'Quantidade não pode ser negativa';
  static const String quantidadeZero = 'Quantidade deve ser maior que zero';
  static const String quantidadeMaxValue =
      'Quantidade não pode ser maior que {max}mm';
  static const String quantidadeMaxDecimal =
      'Quantidade deve ter no máximo {max} casas decimais';
  static const String quantidadeAtypicalValue =
      'Valor atípico. Sugestão: {suggestion}mm';

  // Mensagens de validação para coordenadas
  static const String latitudeInvalidNumber =
      'Latitude deve ser um número válido';
  static const String latitudeOutOfRange = 'Latitude deve estar entre -90 e 90';
  static const String longitudeInvalidNumber =
      'Longitude deve ser um número válido';
  static const String longitudeOutOfRange =
      'Longitude deve estar entre -180 e 180';

  // Mensagens de validação para grupo
  static const String grupoMinLength = 'Grupo deve ter pelo menos 2 caracteres';
  static const String grupoMaxLength = 'Grupo deve ter no máximo 50 caracteres';

  // Mensagens de validação contextual
  static const String valueAboveHistoricalMax =
      'Valor muito acima do máximo histórico ({max}mm)';
  static const String valueAboveHistoricalMean =
      'Valor muito acima da média histórica ({mean}mm)';
  static const String valueBelowHistoricalMin =
      'Valor abaixo do mínimo histórico ({min}mm)';

  // Mensagens de erro de sistema
  static const String networkError =
      'Erro de conexão. Verifique sua internet e tente novamente';
  static const String timeoutError =
      'Operação demorou muito para responder. Tente novamente';
  static const String permissionError =
      'Permissão negada. Verifique as configurações do aplicativo';
  static const String savingError = 'Erro ao salvar dados. Tente novamente';
  static const String loadingError = 'Erro ao carregar dados. Tente novamente';
  static const String validationError =
      'Erro de validação. Verifique os dados inseridos';
  static const String duplicateError = 'Valor já existe no sistema';
  static const String notFoundError = 'Registro não encontrado';
  static const String unexpectedError =
      'Erro inesperado. Tente novamente ou contate o suporte';

  // Mensagens de sucesso
  static const String saveSuccess = 'Dados salvos com sucesso';
  static const String updateSuccess = 'Dados atualizados com sucesso';
  static const String deleteSuccess = 'Registro excluído com sucesso';
  static const String validationSuccess = 'Todos os campos são válidos';

  // Mensagens de GPS
  static const String gpsUnavailable = 'GPS não disponível neste dispositivo';
  static const String gpsPermissionDenied = 'Permissão de localização negada';
  static const String gpsTimeout = 'Tempo limite para obter localização';
  static const String gpsInaccurate = 'Localização obtida com baixa precisão';
  static const String gpsSuccess = 'Localização obtida com sucesso';

  // Mensagens de formulário
  static const String unsavedChanges =
      'Existem alterações não salvas. Deseja continuar?';
  static const String confirmReset =
      'Deseja limpar todos os campos do formulário?';
  static const String confirmDelete = 'Deseja excluir este registro?';
  static const String loadingData = 'Carregando dados...';
  static const String savingData = 'Salvando dados...';
  static const String validatingData = 'Validando dados...';

  // Mensagens de ajuda
  static const String descricaoHelp =
      'Digite uma descrição única para identificar o pluviômetro';
  static const String quantidadeHelp = 'Digite a quantidade em milímetros (mm)';
  static const String latitudeHelp =
      'Digite a latitude no formato decimal (ex: -23.550520)';
  static const String longitudeHelp =
      'Digite a longitude no formato decimal (ex: -46.633309)';
  static const String grupoHelp = 'Digite o grupo ou categoria do pluviômetro';
  static const String gpsHelp =
      'Use o botão GPS para obter automaticamente as coordenadas';

  /// Substitui placeholders na mensagem
  static String substitute(String message, Map<String, dynamic> params) {
    String result = message;
    params.forEach((key, value) {
      result = result.replaceAll('{$key}', value.toString());
    });
    return result;
  }

  /// Obtém mensagem de erro baseada no tipo de validação
  static String getValidationError(String field, String validation,
      [Map<String, dynamic>? params]) {
    String message;

    switch (field) {
      case 'descricao':
        switch (validation) {
          case 'required':
            message = descricaoRequired;
            break;
          case 'minLength':
            message = descricaoMinLength;
            break;
          case 'maxLength':
            message = descricaoMaxLength;
            break;
          case 'invalidFormat':
            message = descricaoInvalidFormat;
            break;
          case 'alreadyExists':
            message = descricaoAlreadyExists;
            break;
          default:
            message = 'Erro de validação na descrição';
        }
        break;

      case 'quantidade':
        switch (validation) {
          case 'required':
            message = quantidadeRequired;
            break;
          case 'invalidNumber':
            message = quantidadeInvalidNumber;
            break;
          case 'negative':
            message = quantidadeNegative;
            break;
          case 'zero':
            message = quantidadeZero;
            break;
          case 'maxValue':
            message = quantidadeMaxValue;
            break;
          case 'maxDecimal':
            message = quantidadeMaxDecimal;
            break;
          case 'atypicalValue':
            message = quantidadeAtypicalValue;
            break;
          default:
            message = 'Erro de validação na quantidade';
        }
        break;

      case 'latitude':
        switch (validation) {
          case 'invalidNumber':
            message = latitudeInvalidNumber;
            break;
          case 'outOfRange':
            message = latitudeOutOfRange;
            break;
          default:
            message = 'Erro de validação na latitude';
        }
        break;

      case 'longitude':
        switch (validation) {
          case 'invalidNumber':
            message = longitudeInvalidNumber;
            break;
          case 'outOfRange':
            message = longitudeOutOfRange;
            break;
          default:
            message = 'Erro de validação na longitude';
        }
        break;

      case 'grupo':
        switch (validation) {
          case 'minLength':
            message = grupoMinLength;
            break;
          case 'maxLength':
            message = grupoMaxLength;
            break;
          default:
            message = 'Erro de validação no grupo';
        }
        break;

      default:
        message = 'Erro de validação';
    }

    return params != null ? substitute(message, params) : message;
  }
}

/// Tipos de validação
enum ValidationType {
  required,
  minLength,
  maxLength,
  invalidFormat,
  invalidNumber,
  negative,
  zero,
  maxValue,
  maxDecimal,
  outOfRange,
  alreadyExists,
  atypicalValue,
}

/// Extensão para converter enum em string
extension ValidationTypeExtension on ValidationType {
  String get name {
    switch (this) {
      case ValidationType.required:
        return 'required';
      case ValidationType.minLength:
        return 'minLength';
      case ValidationType.maxLength:
        return 'maxLength';
      case ValidationType.invalidFormat:
        return 'invalidFormat';
      case ValidationType.invalidNumber:
        return 'invalidNumber';
      case ValidationType.negative:
        return 'negative';
      case ValidationType.zero:
        return 'zero';
      case ValidationType.maxValue:
        return 'maxValue';
      case ValidationType.maxDecimal:
        return 'maxDecimal';
      case ValidationType.outOfRange:
        return 'outOfRange';
      case ValidationType.alreadyExists:
        return 'alreadyExists';
      case ValidationType.atypicalValue:
        return 'atypicalValue';
    }
  }
}

/// Helper para criar mensagens de erro com parâmetros
class ErrorMessageBuilder {
  final String field;
  final ValidationType validation;
  final Map<String, dynamic> params;

  ErrorMessageBuilder(this.field, this.validation, [this.params = const {}]);

  String build() {
    return ErrorMessages.getValidationError(field, validation.name, params);
  }

  /// Cria mensagem para quantidade máxima
  static ErrorMessageBuilder maxQuantity(double max) {
    return ErrorMessageBuilder(
        'quantidade', ValidationType.maxValue, {'max': max});
  }

  /// Cria mensagem para quantidade atípica
  static ErrorMessageBuilder atypicalQuantity(double suggestion) {
    return ErrorMessageBuilder(
        'quantidade', ValidationType.atypicalValue, {'suggestion': suggestion});
  }

  /// Cria mensagem para valor acima do histórico
  static ErrorMessageBuilder aboveHistoricalMax(double max) {
    return ErrorMessageBuilder(
        'quantidade', ValidationType.maxValue, {'max': max});
  }

  /// Cria mensagem para casas decimais
  static ErrorMessageBuilder maxDecimalPlaces(int max) {
    return ErrorMessageBuilder(
        'quantidade', ValidationType.maxDecimal, {'max': max});
  }
}
