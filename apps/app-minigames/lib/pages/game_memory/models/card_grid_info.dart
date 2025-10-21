/// Classe que contém informações calculadas para o layout da grade de cartas
///
/// Esta classe encapsula todos os valores necessários para posicionar
/// e dimensionar corretamente a grade de cartas do jogo da memória,
/// garantindo que funcione em diferentes tamanhos de tela.
class CardGridInfo {
  /// Tamanho de cada slot da grade (incluindo margem)
  final double cardSize;

  /// Tamanho real da carta (excluindo margem)
  final double actualCardSize;

  /// Largura total da grade
  final double gridWidth;

  /// Altura total da grade
  final double gridHeight;

  /// Número de colunas/linhas da grade
  final int gridSize;

  const CardGridInfo({
    required this.cardSize,
    required this.actualCardSize,
    required this.gridWidth,
    required this.gridHeight,
    required this.gridSize,
  });

  @override
  String toString() {
    return 'CardGridInfo('
        'cardSize: $cardSize, '
        'actualCardSize: $actualCardSize, '
        'gridWidth: $gridWidth, '
        'gridHeight: $gridHeight, '
        'gridSize: $gridSize)';
  }
}
