// Project imports:
import '../data/volume_sanguineo_data.dart';

/// Calculator especializado para operações de volume sanguíneo
///
/// Responsável apenas por cálculos matemáticos específicos do domínio,
/// sem dependências de UI ou formatação.
class VolumeSanguineoCalculator {
  /// Tipos de pessoa disponíveis com seus fatores
  static const Map<int, PersonType> _personTypes = {
    1: PersonType(id: 1, text: 'Masculino', factorMlKg: 75),
    2: PersonType(id: 2, text: 'Feminino', factorMlKg: 65),
    3: PersonType(id: 3, text: 'Criança', factorMlKg: 80),
    4: PersonType(id: 4, text: 'Prematuro', factorMlKg: 95),
    5: PersonType(id: 5, text: 'Recém-nascido', factorMlKg: 85),
  };

  /// Calcula o volume sanguíneo baseado nos dados fornecidos
  ///
  /// Fórmula: Volume (L) = Peso (kg) × Fator (ml/kg) / 1000
  ///
  /// [data] - Dados de entrada para o cálculo
  /// Retorna VolumeSanguineoData com resultado calculado
  static VolumeSanguineoData calculate(VolumeSanguineoData data) {
    if (data.peso <= 0) {
      throw ArgumentError('Peso deve ser maior que zero');
    }

    // Fórmula médica padrão para volume sanguíneo
    final volumeMilliliters = data.peso * data.fatorCalculoMlKg;
    final volumeLiters = volumeMilliliters / 1000;

    return data.withCalculatedResult(volumeLiters);
  }

  /// Calcula volume sanguíneo com peso e tipo específicos
  ///
  /// [peso] - Peso em kg
  /// [tipoPessoaId] - ID do tipo de pessoa
  /// Retorna VolumeSanguineoData com resultado
  static VolumeSanguineoData calculateFromParameters(
      double peso, int tipoPessoaId) {
    final personType = getPersonTypeById(tipoPessoaId);

    final data = VolumeSanguineoData(
      peso: peso,
      tipoPessoaId: personType.id,
      tipoPessoaTexto: personType.text,
      fatorCalculoMlKg: personType.factorMlKg,
    );

    return calculate(data);
  }

  /// Obtém todos os tipos de pessoa disponíveis
  static List<PersonType> getAllPersonTypes() {
    return _personTypes.values.toList();
  }

  /// Obtém tipo de pessoa por ID
  static PersonType getPersonTypeById(int id) {
    final personType = _personTypes[id];
    if (personType == null) {
      throw ArgumentError('Tipo de pessoa não encontrado para ID: $id');
    }
    return personType;
  }

  /// Verifica se o resultado está dentro de valores biologicamente plausíveis
  ///
  /// [volumeLitros] - Volume em litros
  /// Retorna true se plausível
  static bool isResultPlausible(double volumeLitros) {
    // Volume sanguíneo humano típico: 0.035L a 7L
    return volumeLitros >= 0.035 && volumeLitros <= 7.0;
  }

  /// Calcula percentual do peso corporal que o sangue representa
  ///
  /// [data] - Dados com cálculo realizado
  /// Retorna percentual (0-100)
  static double calculateBloodPercentage(VolumeSanguineoData data) {
    if (!data.isCalculated || data.volumeSanguineoLitros == null) {
      throw StateError('Cálculo não foi realizado');
    }

    // Densidade média do sangue: ~1.06 kg/L
    const bloodDensity = 1.06;
    final bloodWeightKg = data.volumeSanguineoLitros! * bloodDensity;

    return (bloodWeightKg / data.peso) * 100;
  }

  /// Estima número de batimentos cardíacos necessários para circular todo o sangue
  ///
  /// [data] - Dados com cálculo realizado
  /// [heartRateBpm] - Frequência cardíaca em bpm (padrão: 70)
  /// Retorna tempo em minutos
  static double estimateFullCirculationTime(
    VolumeSanguineoData data, {
    int heartRateBpm = 70,
  }) {
    if (!data.isCalculated || data.volumeSanguineoLitros == null) {
      throw StateError('Cálculo não foi realizado');
    }

    // Volume de ejeção médio por batimento: ~70ml
    const strokeVolumeL = 0.07;
    final beatsNeeded = data.volumeSanguineoLitros! / strokeVolumeL;

    return beatsNeeded / heartRateBpm;
  }
}

/// Classe para representar tipos de pessoa
class PersonType {
  final int id;
  final String text;
  final int factorMlKg;

  const PersonType({
    required this.id,
    required this.text,
    required this.factorMlKg,
  });

  /// Converte para Map compatível com o formato antigo
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'text': text,
      'value': factorMlKg,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PersonType &&
        other.id == id &&
        other.text == text &&
        other.factorMlKg == factorMlKg;
  }

  @override
  int get hashCode => id.hashCode ^ text.hashCode ^ factorMlKg.hashCode;

  @override
  String toString() => 'PersonType(id: $id, text: $text, factor: $factorMlKg)';
}
