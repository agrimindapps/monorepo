import 'package:core/core.dart' show Equatable;

/// Classe base abstrata para todos os inputs de calculadoras
///
/// Define a interface comum para entradas de dados das calculadoras,
/// garantindo que todas implementem corretamente a comparação e
/// serialização necessárias para o sistema.
abstract class CalculatorInput extends Equatable {
  const CalculatorInput();

  /// Converte o input para um mapa para persistência/serialização
  ///
  /// Retorna um mapa com os dados do input que pode ser usado
  /// para salvar no banco de dados ou transmitir pela rede
  Map<String, dynamic> toMap();

  /// Cria uma instância do input a partir de um mapa
  ///
  /// [map] - Mapa com os dados serializados do input
  /// Retorna uma instância tipada do input
  static CalculatorInput fromMap(Map<String, dynamic> map) {
    throw UnimplementedError('fromMap deve ser implementado pelas subclasses');
  }

  /// Valida se os dados do input estão corretos
  ///
  /// Retorna lista de mensagens de erro. Lista vazia indica que
  /// o input é válido
  List<String> validate() {
    return []; // Implementação padrão - sem validação
  }

  /// Verifica se o input é válido
  ///
  /// Retorna true se o input passou em todas as validações
  bool get isValid => validate().isEmpty;

  /// Cria uma cópia do input com os campos especificados alterados
  ///
  /// Deve ser implementado pelas subclasses para permitir
  /// modificações imutáveis do input
  CalculatorInput copyWith();
}
