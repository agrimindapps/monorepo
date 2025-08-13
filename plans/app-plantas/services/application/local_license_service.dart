// Package imports:
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Serviço para gerenciar licenças locais de teste (incubador de projetos)
class LocalLicenseService extends GetxService {
  static LocalLicenseService get instance => Get.find<LocalLicenseService>();

  static const String _testLicenseKey = 'plantas_test_license';
  static const String _testLicenseTimestampKey =
      'plantas_test_license_timestamp';
  static const int _licenseDurationDays = 30;

  /// Verifica se existe uma licença local ativa
  Future<bool> hasActiveLicense() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final licenseData = prefs.getString(_testLicenseKey);

      if (licenseData != null && licenseData == 'active') {
        // Verificar se a licença ainda é válida (30 dias)
        final timestamp = prefs.getInt(_testLicenseTimestampKey) ?? 0;
        final now = DateTime.now().millisecondsSinceEpoch;
        const durationMs = _licenseDurationDays * 24 * 60 * 60 * 1000;

        final isValid = (now - timestamp) < durationMs;

        // Se a licença expirou, remove automaticamente
        if (!isValid) {
          await _removeLicense();
        }

        return isValid;
      }

      return false;
    } catch (e) {
      return false;
    }
  }

  /// Gera uma licença local de teste por 30 dias
  Future<void> generateTestLicense() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final timestamp = DateTime.now().millisecondsSinceEpoch;

      await prefs.setString(_testLicenseKey, 'active');
      await prefs.setInt(_testLicenseTimestampKey, timestamp);

      print('✅ Licença local gerada: válida por $_licenseDurationDays dias');
    } catch (e) {
      print('❌ Erro ao gerar licença local: $e');
      rethrow;
    }
  }

  /// Remove a licença local de teste
  Future<void> removeTestLicense() async {
    try {
      await _removeLicense();
      print('✅ Licença local removida');
    } catch (e) {
      print('❌ Erro ao remover licença local: $e');
      rethrow;
    }
  }

  /// Remove dados da licença do storage
  Future<void> _removeLicense() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_testLicenseKey);
    await prefs.remove(_testLicenseTimestampKey);
  }

  /// Obtém informações sobre a licença atual
  Future<LicenseInfo> getLicenseInfo() async {
    final hasLicense = await hasActiveLicense();

    if (!hasLicense) {
      return LicenseInfo(
        isActive: false,
        daysRemaining: 0,
        expiryDate: null,
      );
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      final timestamp = prefs.getInt(_testLicenseTimestampKey) ?? 0;
      final createdDate = DateTime.fromMillisecondsSinceEpoch(timestamp);
      final expiryDate = createdDate.add(const Duration(days: _licenseDurationDays));
      final now = DateTime.now();
      final daysRemaining = expiryDate.difference(now).inDays;

      return LicenseInfo(
        isActive: true,
        daysRemaining: daysRemaining > 0 ? daysRemaining : 0,
        expiryDate: expiryDate,
      );
    } catch (e) {
      return LicenseInfo(
        isActive: false,
        daysRemaining: 0,
        expiryDate: null,
      );
    }
  }
}

/// Informações sobre a licença local
class LicenseInfo {
  final bool isActive;
  final int daysRemaining;
  final DateTime? expiryDate;

  LicenseInfo({
    required this.isActive,
    required this.daysRemaining,
    required this.expiryDate,
  });

  String get statusText {
    if (!isActive) {
      return 'Nenhuma licença ativa';
    }

    if (daysRemaining <= 0) {
      return 'Licença expirada';
    }

    return 'Licença ativa - $daysRemaining dias restantes';
  }

  String get expiryText {
    if (expiryDate == null) return '';

    final day = expiryDate!.day.toString().padLeft(2, '0');
    final month = expiryDate!.month.toString().padLeft(2, '0');
    final year = expiryDate!.year;

    return 'Expira em: $day/$month/$year';
  }
}
