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
  final String? address;
  final bool fullTank;
  final String? notes;
  final List<String> photos;
  final double? previousOdometer;
  final double? distanceTraveled;
  final double? consumption; // km/l
  final DateTime createdAt;
  final DateTime updatedAt;
  final Map<String, dynamic> metadata;
  
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
    this.address,
    this.fullTank = true,
    this.notes,
    this.photos = const [],
    this.previousOdometer,
    this.distanceTraveled,
    this.consumption,
    required this.createdAt,
    required this.updatedAt,
    this.metadata = const {},
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
    address,
    fullTank,
    notes,
    photos,
    previousOdometer,
    distanceTraveled,
    consumption,
    createdAt,
    updatedAt,
    metadata,
  ];
  
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
    String? address,
    bool? fullTank,
    String? notes,
    List<String>? photos,
    double? previousOdometer,
    double? distanceTraveled,
    double? consumption,
    DateTime? createdAt,
    DateTime? updatedAt,
    Map<String, dynamic>? metadata,
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
      address: address ?? this.address,
      fullTank: fullTank ?? this.fullTank,
      notes: notes ?? this.notes,
      photos: photos ?? this.photos,
      previousOdometer: previousOdometer ?? this.previousOdometer,
      distanceTraveled: distanceTraveled ?? this.distanceTraveled,
      consumption: consumption ?? this.consumption,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      metadata: metadata ?? this.metadata,
    );
  }
  
  bool get hasLocation => latitude != null && longitude != null;
  
  bool get hasPhotos => photos.isNotEmpty;
  
  bool get hasNotes => notes != null && notes!.isNotEmpty;
  
  bool get canCalculateConsumption => 
      previousOdometer != null && distanceTraveled != null && distanceTraveled! > 0;
  
  double get calculatedConsumption {
    if (!canCalculateConsumption) return 0.0;
    return distanceTraveled! / liters;
  }
  
  double get pricePerKm {
    if (!canCalculateConsumption) return 0.0;
    return totalPrice / distanceTraveled!;
  }
  
  String get displayDate {
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
  
  String get formattedTotalPrice => 'R\$ ${totalPrice.toStringAsFixed(2)}';
  
  String get formattedPricePerLiter => 'R\$ ${pricePerLiter.toStringAsFixed(3)}';
  
  String get formattedLiters => '${liters.toStringAsFixed(2)} L';
  
  String get formattedOdometer => '${odometer.toStringAsFixed(0)} km';
  
  String get formattedConsumption {
    if (consumption != null && consumption! > 0) {
      return '${consumption!.toStringAsFixed(1)} km/l';
    }
    return 'N/A';
  }
}