/// Serviço responsável por operações matemáticas relacionadas ao volume sanguíneo
///
/// Este serviço centraliza toda a lógica de cálculo, incluindo conversões
/// e fórmulas médicas específicas para cada tipo de pessoa.
class VolumeSanguineoCalculationService {
  /// Calcula o volume sanguíneo com base no peso e tipo de pessoa
  ///
  /// [peso] - Peso em kg
  /// [fatorTipoPessoa] - Fator multiplicador por tipo (ml/kg)
  ///
  /// Retorna o volume sanguíneo em litros
  double calculateVolumeSanguineo(double peso, int fatorTipoPessoa) {
    // Fórmula: Volume (L) = Peso (kg) × Fator (ml/kg) / 1000
    return (peso * fatorTipoPessoa) / 1000;
  }

  /// Converte texto para double, tratando vírgulas como separador decimal
  ///
  /// [pesoText] - Texto do peso a ser convertido
  ///
  /// Retorna o valor convertido em double
  /// Lança [FormatException] se não conseguir converter
  double parsePeso(String pesoText) {
    return double.parse(pesoText.replaceAll(',', '.'));
  }

  /// Verifica se o resultado está dentro de valores esperados
  ///
  /// [volumeSanguineo] - Volume calculado em litros
  ///
  /// Retorna true se o resultado está dentro da faixa normal
  bool isResultadoPlausivel(double volumeSanguineo) {
    // Volume sanguíneo humano típico está entre 0.035L e 7L
    return volumeSanguineo >= 0.035 && volumeSanguineo <= 7.0;
  }

  /// Obtém o fator de cálculo baseado no ID do tipo de pessoa
  ///
  /// [tipoId] - ID do tipo de pessoa
  ///
  /// Retorna o fator em ml/kg
  int getFatorPorTipoId(int tipoId) {
    switch (tipoId) {
      case 1:
        return 75; // Masculino
      case 2:
        return 65; // Feminino
      case 3:
        return 80; // Criança
      case 4:
        return 95; // Prematuro
      case 5:
        return 85; // Recém-nascido
      default:
        return 70; // Valor padrão
    }
  }
}
