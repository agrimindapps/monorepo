// Package imports:
import 'package:hive/hive.dart';

// Project imports:
import '../../core/models/base_model.dart';
import '../pages/pluviometro/pluviometros_cadastro/utils/type_conversion_utils.dart';

part 'pluviometros_models.g.dart';

@HiveType(typeId: 31)
class Pluviometro extends BaseModel {
  @HiveField(7)
  String descricao;

  @HiveField(8)
  String quantidade;

  @HiveField(9)
  String? longitude;

  @HiveField(10)
  String? latitude;

  @HiveField(11)
  String? fkGrupo;

  Pluviometro({
    required super.id,
    required super.createdAt,
    required super.updatedAt,
    required this.descricao,
    required this.quantidade,
    this.longitude,
    this.latitude,
    this.fkGrupo,
  });

  /// Converte o objeto para um mapa
  @override
  Map<String, dynamic> toMap() {
    return super.toMap()
      ..addAll({
        'descricao': descricao,
        'quantidade': quantidade,
        'longitude': longitude,
        'latitude': latitude,
        'fkGrupo': fkGrupo,
      });
  }

  /// Cria uma instância de `Pluviometro` a partir de um mapa
  factory Pluviometro.fromMap(Map<String, dynamic> map) {
    return Pluviometro(
      id: map['id'] ?? '',
      createdAt: map['createdAt'] ?? 0,
      updatedAt: map['updatedAt'] ?? 0,
      descricao: map['descricao'] ?? '',
      quantidade: map['quantidade'] ?? '',
      longitude: map['longitude'],
      latitude: map['latitude'],
      fkGrupo: map['fkGrupo'],
    );
  }

  /// Retorna a descrição formatada para exibição
  String getDescricaoFormatted() {
    return descricao.toUpperCase();
  }

  /// Verifica se a quantidade é válida (um número positivo)
  bool isValidQuantity() {
    if (!TypeConversionUtils.isValidDouble(quantidade)) {
      return false;
    }

    final quantityValue = TypeConversionUtils.safeDoubleFromString(quantidade);
    return quantityValue > 0.0;
  }

  /// Obtém a quantidade como double de forma segura
  double getQuantidadeAsDouble() {
    return TypeConversionUtils.safeDoubleFromString(quantidade);
  }

  /// Define a quantidade a partir de um double
  void setQuantidadeFromDouble(double value) {
    quantidade = TypeConversionUtils.doubleToString(value);
  }

  /// Verifica se o pluviômetro está localizado em uma região específica
  bool isInRegion(String regionLongitude, String regionLatitude) {
    if (longitude != null && latitude != null) {
      return longitude == regionLongitude && latitude == regionLatitude;
    }
    return false;
  }

  /// Calcula a distância até outro pluviômetro com base nas coordenadas
  // double calculateDistanceTo(Pluviometro other) {
  //   // Lógica simples para calcular distância (apenas para ilustrar)
  //   double lat1 = double.parse(latitude ?? "0");
  //   double lon1 = double.parse(longitude ?? "0");
  //   double lat2 = double.parse(other.latitude ?? "0");
  //   double lon2 = double.parse(other.longitude ?? "0");

  //   // Fórmula de Haversine (não muito precisa, mas para fins ilustrativos)
  //   double dLat = (lat2 - lat1) * (3.141592653589793 / 180.0);
  //   double dLon = (lon2 - lon1) * (3.141592653589793 / 180.0);
  //   double a = (Math.sin(dLat / 2) * Math.sin(dLat / 2)) +
  //       Math.cos(lat1 * (3.141592653589793 / 180.0)) *
  //           Math.cos(lat2 * (3.141592653589793 / 180.0)) *
  //           (Math.sin(dLon / 2) * Math.sin(dLon / 2));
  //   double c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
  //   double distance = 6371 * c; // Distância em quilômetros
  //   return distance;
  // }

  /// Verifica se o pluviômetro pertence a um grupo específico
  bool isFromGroup(String groupId) {
    return fkGrupo == groupId;
  }

  /// Clona o objeto atual
  Pluviometro clone() {
    return Pluviometro(
      id: id,
      createdAt: createdAt,
      updatedAt: updatedAt,
      descricao: descricao,
      quantidade: quantidade,
      longitude: longitude,
      latitude: latitude,
      fkGrupo: fkGrupo,
    );
  }

  /// Sobrescreve o operador de igualdade para comparar por ID
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Pluviometro && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  /// Verifica se as coordenadas do pluviômetro estão definidas
  bool hasCoordinates() {
    return longitude != null && latitude != null;
  }

  /// Retorna uma representação string legível do pluviômetro
  @override
  String toString() {
    return 'Pluviômetro: $descricao, Quantidade: $quantidade, Localização: ($latitude, $longitude)';
  }
}
