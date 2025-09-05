import 'package:equatable/equatable.dart';
import '../../../vehicles/domain/entities/vehicle_entity.dart';

class FuelRecordEntity extends Equatable {
  final String id;
  final String userId;
  final String vehicleId;
  final FuelType fuelType;
  final double liters;
  final double pricePerLiter;
  final double totalPrice;
  final double odometer;
  final DateTime date;
  final String? gasStationName;
  final String? gasStationBrand;
  final double? latitude;
  final double? longitude;
  final bool fullTank;
  final String? notes;
  final double? previousOdometer;
  final double? distanceTraveled;
  final double? consumption; // km/l
  final DateTime createdAt;
  final DateTime updatedAt;
  
  const FuelRecordEntity({
    required this.id,
    required this.userId,
    required this.vehicleId,
    required this.fuelType,
    required this.liters,
    required this.pricePerLiter,
    required this.totalPrice,
    required this.odometer,
    required this.date,
    this.gasStationName,
    this.gasStationBrand,
    this.latitude,
    this.longitude,
    this.fullTank = true,
    this.notes,
    this.previousOdometer,
    this.distanceTraveled,
    this.consumption,
    required this.createdAt,
    required this.updatedAt,
  });
  
  @override
  List<Object?> get props => [
    id,
    userId,
    vehicleId,
    fuelType,
    liters,
    pricePerLiter,
    totalPrice,
    odometer,
    date,
    gasStationName,
    gasStationBrand,
    latitude,
    longitude,
    fullTank,
    notes,
    previousOdometer,
    distanceTraveled,
    consumption,
    createdAt,
    updatedAt,
  ];
  
  // Legacy Portuguese getters for backward compatibility
  String get idUsuario => userId;
  String get veiculoId => vehicleId;
  FuelType get tipoCombustivel => fuelType;
  double get litros => liters;
  double get precoPorLitro => pricePerLiter;
  double get valorTotal => totalPrice;
  double get odometro => odometer;
  DateTime get data => date;
  String? get nomePosto => gasStationName;
  String? get marcaPosto => gasStationBrand;
  bool get tanqueCheio => fullTank;
  String? get observacoes => notes;
  double? get odometroAnterior => previousOdometer;
  double? get distanciaPercorrida => distanceTraveled;
  double? get consumo => consumption;
  DateTime get criadoEm => createdAt;
  DateTime get atualizadoEm => updatedAt;
  
  // Additional properties not in model
  String? get address => null; // Not available in current entity
  List<String>? get photos => null; // Not available in current entity
  Map<String, dynamic>? get metadata => null; // Not available in current entity
  
  // Formatted getters
  String get formattedPricePerLiter => 'R\$ ${pricePerLiter.toStringAsFixed(3)}';
  
  FuelRecordEntity copyWith({
    String? id,
    String? userId,
    String? vehicleId,
    FuelType? fuelType,
    double? liters,
    double? pricePerLiter,
    double? totalPrice,
    double? odometer,
    DateTime? date,
    String? gasStationName,
    String? gasStationBrand,
    double? latitude,
    double? longitude,
    bool? fullTank,
    String? notes,
    double? previousOdometer,
    double? distanceTraveled,
    double? consumption,
    DateTime? createdAt,
    DateTime? updatedAt,
    // Legacy support
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
      userId: userId ?? idUsuario ?? this.userId,
      vehicleId: vehicleId ?? veiculoId ?? this.vehicleId,
      fuelType: fuelType ?? tipoCombustivel ?? this.fuelType,
      liters: liters ?? litros ?? this.liters,
      pricePerLiter: pricePerLiter ?? precoPorLitro ?? this.pricePerLiter,
      totalPrice: totalPrice ?? valorTotal ?? this.totalPrice,
      odometer: odometer ?? odometro ?? this.odometer,
      date: date ?? data ?? this.date,
      gasStationName: gasStationName ?? nomePosto ?? this.gasStationName,
      gasStationBrand: gasStationBrand ?? marcaPosto ?? this.gasStationBrand,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      fullTank: fullTank ?? tanqueCheio ?? this.fullTank,
      notes: notes ?? observacoes ?? this.notes,
      previousOdometer: previousOdometer ?? odometroAnterior ?? this.previousOdometer,
      distanceTraveled: distanceTraveled ?? distanciaPercorrida ?? this.distanceTraveled,
      consumption: consumption ?? consumo ?? this.consumption,
      createdAt: createdAt ?? criadoEm ?? this.createdAt,
      updatedAt: updatedAt ?? atualizadoEm ?? this.updatedAt,
    );
  }
  
  bool get temLocalizacao => latitude != null && longitude != null;
  
  bool get temObservacoes => notes != null && notes!.isNotEmpty;
  
  bool get podeCalcularConsumo => 
      previousOdometer != null && distanceTraveled != null && distanceTraveled! > 0;
  
  double get consumoCalculado {
    if (!podeCalcularConsumo) return 0.0;
    return distanceTraveled! / liters;
  }
  
  double get precoPorKm {
    if (!podeCalcularConsumo) return 0.0;
    return totalPrice / distanceTraveled!;
  }
  
  String get dataFormatada {
    final now = DateTime.now();
    final difference = now.difference(date);
    
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
  
  String get valorTotalFormatado => 'R\$ ${totalPrice.toStringAsFixed(2)}';
  
  String get precoPorLitroFormatado => 'R\$ ${pricePerLiter.toStringAsFixed(3)}';
  
  String get litrosFormatados => '${liters.toStringAsFixed(2)} L';
  
  String get odometroFormatado => '${odometer.toStringAsFixed(0)} km';
  
  String get consumoFormatado {
    if (consumption != null && consumption! > 0) {
      return '${consumption!.toStringAsFixed(1)} km/l';
    }
    return 'N/A';
  }
}