/// Serviço para coleta de localização GPS
class LocationService {
  /// Obtém a localização atual do dispositivo
  Future<LocationResult> getCurrentLocation() async {
    try {
      // Simulação de coleta de GPS - Em produção, usar geolocator
      // final Position position = await Geolocator.getCurrentPosition(
      //   desiredAccuracy: LocationAccuracy.high,
      //   timeLimit: const Duration(seconds: 10),
      // );

      // Por enquanto, retorna valores padrão ou solicita ao usuário
      return LocationResult(
        latitude: 0.0,
        longitude: 0.0,
        accuracy: 0.0,
        isSuccess: false,
        errorMessage: 'Localização não implementada - valores padrão',
      );
    } catch (e) {
      return LocationResult(
        latitude: 0.0,
        longitude: 0.0,
        accuracy: 0.0,
        isSuccess: false,
        errorMessage: 'Erro ao obter localização: $e',
      );
    }
  }

  /// Verifica se as permissões de localização estão disponíveis
  Future<bool> checkLocationPermissions() async {
    // Simulação - Em produção, verificar permissões reais
    return false;
  }

  /// Solicita permissões de localização
  Future<bool> requestLocationPermissions() async {
    // Simulação - Em produção, solicitar permissões reais
    return false;
  }

  /// Verifica se o GPS está habilitado
  Future<bool> isLocationServiceEnabled() async {
    // Simulação - Em produção, verificar se GPS está ativo
    return false;
  }

  /// Formata coordenadas para string
  String formatCoordinate(double coordinate, {int decimals = 6}) {
    return coordinate.toStringAsFixed(decimals);
  }

  /// Valida se as coordenadas são válidas
  bool isValidCoordinates(double latitude, double longitude) {
    return latitude >= -90 &&
        latitude <= 90 &&
        longitude >= -180 &&
        longitude <= 180;
  }
}

/// Resultado da coleta de localização
class LocationResult {
  final double latitude;
  final double longitude;
  final double accuracy;
  final bool isSuccess;
  final String? errorMessage;

  LocationResult({
    required this.latitude,
    required this.longitude,
    required this.accuracy,
    required this.isSuccess,
    this.errorMessage,
  });

  String get latitudeString => latitude.toStringAsFixed(6);
  String get longitudeString => longitude.toStringAsFixed(6);

  @override
  String toString() {
    if (isSuccess) {
      return 'Localização: $latitudeString, $longitudeString (±${accuracy}m)';
    } else {
      return 'Erro: $errorMessage';
    }
  }
}
