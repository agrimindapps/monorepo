/// Dados puros do domínio Volume Sanguíneo
///
/// Esta classe contém apenas dados do domínio sem dependências de UI,
/// formatação ou lógica de negócio. Segue princípios de arquitetura limpa.
class VolumeSanguineoData {
  final double peso;
  final int tipoPessoaId;
  final String tipoPessoaTexto;
  final int fatorCalculoMlKg;
  final double? volumeSanguineoLitros;
  final DateTime? dataCalculo;

  const VolumeSanguineoData({
    required this.peso,
    required this.tipoPessoaId,
    required this.tipoPessoaTexto,
    required this.fatorCalculoMlKg,
    this.volumeSanguineoLitros,
    this.dataCalculo,
  });

  /// Cria uma cópia com novos valores
  VolumeSanguineoData copyWith({
    double? peso,
    int? tipoPessoaId,
    String? tipoPessoaTexto,
    int? fatorCalculoMlKg,
    double? volumeSanguineoLitros,
    DateTime? dataCalculo,
  }) {
    return VolumeSanguineoData(
      peso: peso ?? this.peso,
      tipoPessoaId: tipoPessoaId ?? this.tipoPessoaId,
      tipoPessoaTexto: tipoPessoaTexto ?? this.tipoPessoaTexto,
      fatorCalculoMlKg: fatorCalculoMlKg ?? this.fatorCalculoMlKg,
      volumeSanguineoLitros:
          volumeSanguineoLitros ?? this.volumeSanguineoLitros,
      dataCalculo: dataCalculo ?? this.dataCalculo,
    );
  }

  /// Cria instância vazia para inicialização
  factory VolumeSanguineoData.empty() {
    return const VolumeSanguineoData(
      peso: 0,
      tipoPessoaId: 1,
      tipoPessoaTexto: 'Masculino',
      fatorCalculoMlKg: 75,
    );
  }

  /// Cria instância com resultado calculado
  VolumeSanguineoData withCalculatedResult(double volumeLitros) {
    return copyWith(
      volumeSanguineoLitros: volumeLitros,
      dataCalculo: DateTime.now(),
    );
  }

  /// Verifica se o cálculo foi realizado
  bool get isCalculated => volumeSanguineoLitros != null;

  /// Converte para Map para serialização
  Map<String, dynamic> toMap() {
    return {
      'peso': peso,
      'tipoPessoaId': tipoPessoaId,
      'tipoPessoaTexto': tipoPessoaTexto,
      'fatorCalculoMlKg': fatorCalculoMlKg,
      'volumeSanguineoLitros': volumeSanguineoLitros,
      'dataCalculo': dataCalculo?.toIso8601String(),
    };
  }

  /// Cria instância a partir de Map
  factory VolumeSanguineoData.fromMap(Map<String, dynamic> map) {
    return VolumeSanguineoData(
      peso: map['peso']?.toDouble() ?? 0.0,
      tipoPessoaId: map['tipoPessoaId']?.toInt() ?? 1,
      tipoPessoaTexto: map['tipoPessoaTexto'] ?? 'Masculino',
      fatorCalculoMlKg: map['fatorCalculoMlKg']?.toInt() ?? 75,
      volumeSanguineoLitros: map['volumeSanguineoLitros']?.toDouble(),
      dataCalculo: map['dataCalculo'] != null
          ? DateTime.parse(map['dataCalculo'])
          : null,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is VolumeSanguineoData &&
        other.peso == peso &&
        other.tipoPessoaId == tipoPessoaId &&
        other.tipoPessoaTexto == tipoPessoaTexto &&
        other.fatorCalculoMlKg == fatorCalculoMlKg &&
        other.volumeSanguineoLitros == volumeSanguineoLitros;
  }

  @override
  int get hashCode {
    return peso.hashCode ^
        tipoPessoaId.hashCode ^
        tipoPessoaTexto.hashCode ^
        fatorCalculoMlKg.hashCode ^
        volumeSanguineoLitros.hashCode;
  }

  @override
  String toString() {
    return 'VolumeSanguineoData(peso: $peso, tipo: $tipoPessoaTexto, '
        'fator: $fatorCalculoMlKg, volume: $volumeSanguineoLitros)';
  }
}
