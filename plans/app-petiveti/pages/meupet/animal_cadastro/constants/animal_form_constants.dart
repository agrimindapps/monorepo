// Flutter imports:
import 'package:flutter/material.dart';

/// Constantes de validação para formulário de animais
///
/// Este arquivo centraliza todos os valores usados nas validações,
/// facilitando manutenção e configuração por espécie quando necessário.
class AnimalFormConstants {
  // === COMPRIMENTO DE TEXTO ===

  /// Comprimento máximo permitido para o nome do animal
  static const int maxNomeLength = 80;

  /// Comprimento mínimo para o nome do animal
  static const int minNomeLength = 2;

  /// Comprimento máximo para o campo raça
  static const int maxRacaLength = 80;

  /// Comprimento máximo para observações
  static const int maxObservacoesLength = 255;

  // === LIMITES NUMÉRICOS ===

  /// Peso máximo permitido em kg (aplicável para a maioria das espécies)
  static const double maxPesoKg = 500.0;

  /// Peso mínimo permitido em kg
  static const double minPesoKg = 0.0;

  // === LIMITES ESPECÍFICOS POR ESPÉCIE ===

  /// Weight limits by species (in kg)
  static const Map<String, WeightLimits> weightLimitsBySpecies = {
    'Cachorro': WeightLimits(min: 0.1, max: 150.0),
    'Gato': WeightLimits(min: 0.1, max: 25.0),
    'Ave': WeightLimits(min: 0.01, max: 50.0),
    'Peixe': WeightLimits(min: 0.001, max: 500.0),
    'Coelho': WeightLimits(min: 0.1, max: 15.0),
    'Hamster': WeightLimits(min: 0.01, max: 1.0),
    'Réptil': WeightLimits(min: 0.01, max: 200.0),
    'Porquinho da Índia': WeightLimits(min: 0.1, max: 3.0),
    'Furão': WeightLimits(min: 0.1, max: 5.0),
    'Outro': WeightLimits(min: 0.001, max: 500.0),
  };

  /// Legacy constant name for backward compatibility
  @Deprecated('Use weightLimitsBySpecies instead')
  static const Map<String, WeightLimits> pesoLimitesPorEspecie = weightLimitsBySpecies;

  // === DATAS ===

  /// Ano mínimo para data de nascimento
  static const int minAnoNascimento = 2000;

  // === ERROR MESSAGES ===

  /// Standardized error messages
  static const String requiredFieldMessage = 'Campo obrigatório';
  static const String nameTooShortMessage = 'Nome muito curto';
  static const String nameTooLongMessage =
      'Nome muito longo (máx. 80 caracteres)';
  static const String breedTooLongMessage =
      'Raça muito longa (máx. 80 caracteres)';
  static const String invalidNumberMessage = 'Digite um número válido';
  static const String weightTooLowMessage = 'O peso deve ser maior que zero';
  static const String weightTooHighMessage = 'Peso parece muito alto, verifique';

  // === LEGACY NAMES (for backward compatibility) ===
  @Deprecated('Use requiredFieldMessage instead')
  static const String msgCampoObrigatorio = requiredFieldMessage;
  @Deprecated('Use nameTooShortMessage instead')
  static const String msgNomeMuitoCurto = nameTooShortMessage;
  @Deprecated('Use nameTooLongMessage instead')
  static const String msgNomeMuitoLongo = nameTooLongMessage;
  @Deprecated('Use breedTooLongMessage instead')
  static const String msgRacaMuitoLonga = breedTooLongMessage;
  @Deprecated('Use invalidNumberMessage instead')
  static const String msgNumeroInvalido = invalidNumberMessage;
  @Deprecated('Use weightTooLowMessage instead')
  static const String msgPesoMenorQueZero = weightTooLowMessage;
  @Deprecated('Use weightTooHighMessage instead')
  static const String msgPesoMuitoAlto = weightTooHighMessage;

  // === CONFIGURAÇÕES DE UI ===

  /// Número máximo de linhas para o campo observações
  static const int maxLinhasObservacoes = 5;

  // === SEÇÕES DO FORMULÁRIO ===

  /// Títulos das seções do formulário
  static const Map<String, String> titulosSecoes = {
    'identificacao': 'Identificação do Animal',
    'informacoes_fisicas': 'Informações Físicas',
    'informacoes_adicionais': 'Informações Adicionais',
  };

  /// Ícones das seções do formulário
  static const Map<String, IconData> iconesSecoes = {
    'identificacao': Icons.pets,
    'informacoes_fisicas': Icons.monitor_weight,
    'informacoes_adicionais': Icons.notes,
  };

  /// Rótulos dos campos do formulário
  static const Map<String, String> rotulosCampos = {
    'nome': 'Nome',
    'especie': 'Espécie',
    'raca': 'Raça',
    'cor': 'Cor',
    'sexo': 'Sexo',
    'data_nascimento': 'Data de Nascimento',
    'peso_atual': 'Peso Atual (kg)',
    'observacoes': 'Observações',
  };

  /// Dicas dos campos do formulário
  static const Map<String, String> dicasCampos = {
    'nome': 'Digite o nome do animal',
    'especie': 'Selecione a espécie',
    'raca': 'Ex: Labrador, Persa, SRD...',
    'cor': 'Ex: Marrom, Preto, Branco...',
    'sexo': 'Selecione o sexo',
    'data_nascimento': 'dd/mm/aaaa',
    'peso_atual': 'Ex: 5.5 ou 5,5',
    'observacoes': 'Informações adicionais sobre o animal...',
  };

  // === ESPAÇAMENTOS ===

  /// Espaçamento entre seções
  static const double sectionSpacing = 16.0;
  
  /// Espaçamento entre campos
  static const double fieldSpacing = 12.0;

  // === OPÇÕES DE FORMULÁRIO ===

  /// Species options with their corresponding Material Design icons
  static const Map<String, IconData> speciesOptions = {
    'Cachorro': Icons.pets,
    'Gato': Icons.catching_pokemon,
    'Ave': Icons.flutter_dash,
    'Peixe': Icons.water,
    'Coelho': Icons.cruelty_free,
    'Hamster': Icons.pest_control_rodent,
    'Réptil': Icons.air,
    'Porquinho da Índia': Icons.catching_pokemon,
    'Furão': Icons.pets,
    'Outro': Icons.more_horiz,
  };

  /// Available sex options
  static const List<String> sexOptions = ['Macho', 'Fêmea'];

  /// Legacy constant names for backward compatibility
  @Deprecated('Use speciesOptions instead')
  static const Map<String, IconData> especiesOptions = speciesOptions;
  @Deprecated('Use sexOptions instead')
  static const List<String> sexoOptions = sexOptions;

  /// Emojis corresponding to species for better visualization
  static const Map<String, String> speciesEmojis = {
    'Cachorro': '🐕',
    'Gato': '🐱',
    'Ave': '🐦',
    'Peixe': '🐠',
    'Coelho': '🐰',
    'Hamster': '🐹',
    'Réptil': '🦎',
    'Porquinho da Índia': '🐭',
    'Furão': '🦔',
    'Outro': '🐾',
  };

  /// Legacy constant name for backward compatibility
  @Deprecated('Use speciesEmojis instead')
  static const Map<String, String> especiesComEmojis = speciesEmojis;

  // === REGIONAL CONFIGURATIONS ===

  /// Configurations for different locales (preparing for internationalization)
  static const Map<String, AnimalFormConfig> configsByRegion = {
    'pt_BR': AnimalFormConfig(
      formatoData: 'dd/MM/yyyy',
      separadorDecimal: ',',
      moedaLocal: 'R\$',
    ),
    'en_US': AnimalFormConfig(
      formatoData: 'MM/dd/yyyy',
      separadorDecimal: '.',
      moedaLocal: '\$',
    ),
  };

  /// Default configuration (Brazil)
  static const AnimalFormConfig defaultConfig = AnimalFormConfig(
    formatoData: 'dd/MM/yyyy',
    separadorDecimal: ',',
    moedaLocal: 'R\$',
  );

  /// Legacy constant names for backward compatibility
  @Deprecated('Use configsByRegion instead')
  static const Map<String, AnimalFormConfig> configsPorRegiao = configsByRegion;
  @Deprecated('Use defaultConfig instead')
  static const AnimalFormConfig configPadrao = defaultConfig;
}

/// Class to represent weight limits by species
class WeightLimits {
  final double min;
  final double max;

  const WeightLimits({
    required this.min,
    required this.max,
  });
}

/// Legacy class name for backward compatibility
@Deprecated('Use WeightLimits instead')
class PesoLimites extends WeightLimits {
  const PesoLimites({required super.min, required super.max});
}

/// Class for regional form configurations
class AnimalFormConfig {
  final String formatoData;
  final String separadorDecimal;
  final String moedaLocal;

  const AnimalFormConfig({
    required this.formatoData,
    required this.separadorDecimal,
    required this.moedaLocal,
  });
}
