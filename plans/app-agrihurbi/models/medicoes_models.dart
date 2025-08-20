// Package imports:
import 'package:hive/hive.dart';

// Project imports:
import '../../core/models/base_model.dart';

part 'medicoes_models.g.dart';

@HiveType(typeId: 30)
class Medicoes extends BaseModel {
  @HiveField(7)
  String fkPluviometro;

  @HiveField(8)
  int dtMedicao;

  @HiveField(9)
  double quantidade;

  @HiveField(10)
  String? observacoes;

  Medicoes({
    required super.id,
    required super.createdAt,
    required super.updatedAt,
    required this.fkPluviometro,
    required this.dtMedicao,
    required this.quantidade,
    this.observacoes,
  });

  /// Converte o objeto para um mapa
  @override
  Map<String, dynamic> toMap() {
    return super.toMap()
      ..addAll({
        'fkPluviometro': fkPluviometro,
        'dtMedicao': dtMedicao,
        'quantidade': quantidade,
        'observacoes': observacoes,
      });
  }

  /// Cria uma instância de `Medicoes` a partir de um mapa
  factory Medicoes.fromMap(Map<String, dynamic> map) {
    return Medicoes(
      id: map['id'] ?? '',
      createdAt: map['createdAt'] ?? 0,
      updatedAt: map['updatedAt'] ?? 0,
      fkPluviometro: map['fkPluviometro'] ?? '',
      dtMedicao: map['dtMedicao'] ?? 0,
      quantidade: map['quantidade'] ?? 0,
      observacoes: map['observacoes'],
    );
  }

  /// Retorna a data da medição em formato legível
  String getFormattedDate() {
    DateTime date = DateTime.fromMillisecondsSinceEpoch(dtMedicao);
    return '${date.day}/${date.month}/${date.year}';
  }

  /// Retorna a quantidade de precipitação com unidade
  String getQuantidadeFormatted() {
    return '${quantidade.toStringAsFixed(1)} mm';
  }

  /// Compara a medição de duas instâncias e verifica se são do mesmo pluviômetro
  bool isSamePluviometer(Medicoes other) {
    return fkPluviometro == other.fkPluviometro;
  }

  /// Verifica se a medição foi realizada em uma data específica
  bool isFromDate(DateTime date) {
    DateTime medicaoDate = DateTime.fromMillisecondsSinceEpoch(dtMedicao);
    return medicaoDate.year == date.year &&
        medicaoDate.month == date.month &&
        medicaoDate.day == date.day;
  }

  /// Filtra medições por uma lista de pluviômetros
  static List<Medicoes> filterByPluviometer(
      List<Medicoes> medicoes, String pluviometro) {
    return medicoes
        .where((medicao) => medicao.fkPluviometro == pluviometro)
        .toList();
  }

  /// Soma a quantidade de precipitação de uma lista de medições
  static double sumPrecipitation(List<Medicoes> medicoes) {
    return medicoes.fold(0.0, (sum, medicao) => sum + medicao.quantidade);
  }

  /// Ordena as medições por data (mais recente primeiro)
  static List<Medicoes> sortByDate(List<Medicoes> medicoes) {
    medicoes.sort((a, b) => b.dtMedicao.compareTo(a.dtMedicao));
    return medicoes;
  }

  /// Verifica se a medição é maior do que um valor de precipitação fornecido
  bool isHigherThan(double threshold) {
    return quantidade > threshold;
  }

  /// Clona o objeto atual
  Medicoes clone() {
    return Medicoes(
      id: id,
      createdAt: createdAt,
      updatedAt: updatedAt,
      fkPluviometro: fkPluviometro,
      dtMedicao: dtMedicao,
      quantidade: quantidade,
      observacoes: observacoes,
    );
  }

  /// Sobrescreve o operador de igualdade para comparar por ID
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Medicoes && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  /// Verifica se a medição está dentro de um intervalo de precipitação
  bool isInPrecipitationRange(double min, double max) {
    return quantidade >= min && quantidade <= max;
  }
}
