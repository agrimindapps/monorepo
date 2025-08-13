/// Classe auxiliar para armazenar os dados do diagnóstico
class DiagnosticData {
  final Map<String, dynamic> diag;
  final Map<String, dynamic> fito;
  final Map<String, dynamic> praga;
  final Map<String, dynamic> cultura;
  final Map<String, dynamic> info;

  DiagnosticData({
    required this.diag,
    required this.fito,
    required this.praga,
    required this.cultura,
    required this.info,
  });
  
  /// Cria uma instância com mapas vazios para casos de erro
  factory DiagnosticData.empty() {
    return DiagnosticData(
      diag: {},
      fito: {},
      praga: {},
      cultura: {},
      info: {},
    );
  }
  
  /// Verifica se o diagnóstico está vazio
  bool get isEmpty => diag.isEmpty;
  bool get isNotEmpty => !isEmpty;
}