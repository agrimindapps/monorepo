/// Location data model for secure storage
class LocationData {
  final double latitude;
  final double longitude;
  final String? address;
  final DateTime timestamp;

  const LocationData({
    required this.latitude,
    required this.longitude,
    this.address,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
    'latitude': latitude,
    'longitude': longitude,
    'address': address,
    'timestamp': timestamp.toIso8601String(),
  };

  factory LocationData.fromJson(Map<String, dynamic> json) => LocationData(
    latitude: json['latitude'] as double,
    longitude: json['longitude'] as double,
    address: json['address'] as String?,
    timestamp: DateTime.parse(json['timestamp'] as String),
  );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is LocationData &&
        other.latitude == latitude &&
        other.longitude == longitude &&
        other.address == address &&
        other.timestamp == timestamp;
  }

  @override
  int get hashCode {
    return latitude.hashCode ^
        longitude.hashCode ^
        address.hashCode ^
        timestamp.hashCode;
  }

  @override
  String toString() {
    return 'LocationData(latitude: $latitude, longitude: $longitude, address: $address, timestamp: $timestamp)';
  }
}