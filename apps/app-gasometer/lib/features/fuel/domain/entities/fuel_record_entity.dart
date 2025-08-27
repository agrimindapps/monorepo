import 'package:equatable/equatable.dart';
import '../../../vehicles/domain/entities/vehicle_entity.dart';

class FuelRecordEntity extends Equatable {
  final String id;
  final String idUsuario;
  final String veiculoId;
  final FuelType tipoCombustivel;
  final double litros;
  final double precoPorLitro;
  final double valorTotal;
  final double odometro;
  final DateTime data;
  final String? nomePosto;
  final String? marcaPosto;
  final double? latitude;
  final double? longitude;
  final bool tanqueCheio;
  final String? observacoes;
  final double? odometroAnterior;
  final double? distanciaPercorrida;
  final double? consumo; // km/l
  final DateTime criadoEm;
  final DateTime atualizadoEm;
  
  const FuelRecordEntity({
    required this.id,
    required this.idUsuario,
    required this.veiculoId,
    required this.tipoCombustivel,
    required this.litros,
    required this.precoPorLitro,
    required this.valorTotal,
    required this.odometro,
    required this.data,
    this.nomePosto,
    this.marcaPosto,
    this.latitude,
    this.longitude,
    this.tanqueCheio = true,
    this.observacoes,
    this.odometroAnterior,
    this.distanciaPercorrida,
    this.consumo,
    required this.criadoEm,
    required this.atualizadoEm,
  });
  
  @override
  List<Object?> get props => [
    id,
    idUsuario,
    veiculoId,
    tipoCombustivel,
    litros,
    precoPorLitro,
    valorTotal,
    odometro,
    data,
    nomePosto,
    marcaPosto,
    latitude,
    longitude,
    tanqueCheio,
    observacoes,
    odometroAnterior,
    distanciaPercorrida,
    consumo,
    criadoEm,
    atualizadoEm,
  ];
  
  // English getters for compatibility
  String get userId => idUsuario;
  String get vehicleId => veiculoId;
  FuelType get fuelType => tipoCombustivel;
  double get liters => litros;
  double get pricePerLiter => precoPorLitro;
  double get totalPrice => valorTotal;
  double get odometer => odometro;
  DateTime get date => data;
  String? get gasStationName => nomePosto;
  String? get gasStationBrand => marcaPosto;
  bool get fullTank => tanqueCheio;
  String? get notes => observacoes;
  double? get previousOdometer => odometroAnterior;
  double? get distanceTraveled => distanciaPercorrida;
  double? get consumption => consumo;
  DateTime get createdAt => criadoEm;
  DateTime get updatedAt => atualizadoEm;
  String? get address => null; // Not available in current entity
  List<String>? get photos => null; // Not available in current entity
  Map<String, dynamic>? get metadata => null; // Not available in current entity
  
  // Formatted getters
  String get formattedPricePerLiter => 'R\$ ${precoPorLitro.toStringAsFixed(3)}';
  
  FuelRecordEntity copyWith({
    String? id,
    String? idUsuario,
    String? veiculoId,
    FuelType? tipoCombustivel,
    double? litros,
    double? precoPorLitro,
    double? valorTotal,
    double? odometro,
    DateTime? data,
    String? nomePosto,
    String? marcaPosto,
    double? latitude,
    double? longitude,
    bool? tanqueCheio,
    String? observacoes,
    double? odometroAnterior,
    double? distanciaPercorrida,
    double? consumo,
    DateTime? criadoEm,
    DateTime? atualizadoEm,
  }) {
    return FuelRecordEntity(
      id: id ?? this.id,
      idUsuario: idUsuario ?? this.idUsuario,
      veiculoId: veiculoId ?? this.veiculoId,
      tipoCombustivel: tipoCombustivel ?? this.tipoCombustivel,
      litros: litros ?? this.litros,
      precoPorLitro: precoPorLitro ?? this.precoPorLitro,
      valorTotal: valorTotal ?? this.valorTotal,
      odometro: odometro ?? this.odometro,
      data: data ?? this.data,
      nomePosto: nomePosto ?? this.nomePosto,
      marcaPosto: marcaPosto ?? this.marcaPosto,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      tanqueCheio: tanqueCheio ?? this.tanqueCheio,
      observacoes: observacoes ?? this.observacoes,
      odometroAnterior: odometroAnterior ?? this.odometroAnterior,
      distanciaPercorrida: distanciaPercorrida ?? this.distanciaPercorrida,
      consumo: consumo ?? this.consumo,
      criadoEm: criadoEm ?? this.criadoEm,
      atualizadoEm: atualizadoEm ?? this.atualizadoEm,
    );
  }
  
  bool get temLocalizacao => latitude != null && longitude != null;
  
  bool get temObservacoes => observacoes != null && observacoes!.isNotEmpty;
  
  bool get podeCalcularConsumo => 
      odometroAnterior != null && distanciaPercorrida != null && distanciaPercorrida! > 0;
  
  double get consumoCalculado {
    if (!podeCalcularConsumo) return 0.0;
    return distanciaPercorrida! / litros;
  }
  
  double get precoPorKm {
    if (!podeCalcularConsumo) return 0.0;
    return valorTotal / distanciaPercorrida!;
  }
  
  String get dataFormatada {
    final now = DateTime.now();
    final difference = now.difference(data);
    
    if (difference.inDays == 0) {
      return 'Hoje';
    } else if (difference.inDays == 1) {
      return 'Ontem';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} dias atrás';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return '$weeks ${weeks == 1 ? 'semana' : 'semanas'} atrás';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return '$months ${months == 1 ? 'mês' : 'meses'} atrás';
    } else {
      final years = (difference.inDays / 365).floor();
      return '$years ${years == 1 ? 'ano' : 'anos'} atrás';
    }
  }
  
  String get valorTotalFormatado => 'R\$ ${valorTotal.toStringAsFixed(2)}';
  
  String get precoPorLitroFormatado => 'R\$ ${precoPorLitro.toStringAsFixed(3)}';
  
  String get litrosFormatados => '${litros.toStringAsFixed(2)} L';
  
  String get odometroFormatado => '${odometro.toStringAsFixed(0)} km';
  
  String get consumoFormatado {
    if (consumo != null && consumo! > 0) {
      return '${consumo!.toStringAsFixed(1)} km/l';
    }
    return 'N/A';
  }
}