class AtualizacaoModel {
  final String versao;
  final List<String> notas;

  const AtualizacaoModel({
    required this.versao,
    required this.notas,
  });

  factory AtualizacaoModel.fromMap(Map<String, dynamic> map) {
    return AtualizacaoModel(
      versao: map['versao'] ?? '',
      notas: List<String>.from(map['notas'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'versao': versao,
      'notas': notas,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AtualizacaoModel &&
        other.versao == versao &&
        _listEquals(other.notas, notas);
  }

  @override
  int get hashCode => versao.hashCode ^ notas.hashCode;

  bool _listEquals<T>(List<T>? a, List<T>? b) {
    if (a == null) return b == null;
    if (b == null || a.length != b.length) return false;
    for (int index = 0; index < a.length; index += 1) {
      if (a[index] != b[index]) return false;
    }
    return true;
  }
}