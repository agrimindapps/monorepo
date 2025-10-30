import '../../data/models/device_model.dart';

/// Manager para computar status de dispositivos
/// Isolaç a lógica de status, limites e validações
class DeviceStatusManager {
  static const int _maxActiveDevices = 3;

  /// Obtém texto de status do dispositivo
  static String getStatusText(DeviceModel device) {
    if (!device.isActive) return 'Inativo';
    return 'Ativo';
  }

  /// Obtém cor de status
  static String getStatusColor(DeviceModel device) {
    return device.isActive ? 'green' : 'grey';
  }

  /// Verifica se pode adicionar mais dispositivos
  static bool canAddMoreDevices(int activeCount) {
    return activeCount < _maxActiveDevices;
  }

  /// Obtém texto do limite de dispositivos
  static String getDeviceLimitText(int activeCount) {
    final remaining = _maxActiveDevices - activeCount;
    if (remaining <= 0) return 'Limite de dispositivos atingido';
    if (remaining == 1) return 'Mais 1 dispositivo permitido';
    return 'Mais $remaining dispositivos permitidos';
  }

  /// Obtém mensagem de status geral
  static String getGeneralStatusMessage(int activeCount, int totalCount) {
    if (totalCount == 0) return 'Nenhum dispositivo registrado';
    if (activeCount == 1) return '1 dispositivo ativo de $totalCount';
    return '$activeCount dispositivos ativos de $totalCount';
  }

  /// Classifica dispositivos por status
  static Map<String, List<DeviceModel>> classifyByStatus(
    List<DeviceModel> devices,
  ) {
    return {
      'active': devices.where((d) => d.isActive).toList(),
      'inactive': devices.where((d) => !d.isActive).toList(),
    };
  }
}
