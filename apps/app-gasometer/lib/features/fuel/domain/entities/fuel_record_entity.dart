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
  }) {
    return FuelRecordEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      vehicleId: vehicleId ?? this.vehicleId,
      fuelType: fuelType ?? this.fuelType,
      liters: liters ?? this.liters,
      pricePerLiter: pricePerLiter ?? this.pricePerLiter,
      totalPrice: totalPrice ?? this.totalPrice,
      odometer: odometer ?? this.odometer,
      date: date ?? this.date,
      gasStationName: gasStationName ?? this.gasStationName,
      gasStationBrand: gasStationBrand ?? this.gasStationBrand,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      fullTank: fullTank ?? this.fullTank,
      notes: notes ?? this.notes,
      previousOdometer: previousOdometer ?? this.previousOdometer,
      distanceTraveled: distanceTraveled ?? this.distanceTraveled,
      consumption: consumption ?? this.consumption,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
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