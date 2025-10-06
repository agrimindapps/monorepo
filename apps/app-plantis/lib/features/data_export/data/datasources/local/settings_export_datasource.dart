import '../../../domain/entities/export_request.dart';

abstract class SettingsExportDataSource {
  Future<UserSettingsExportData> getUserSettingsData(String userId);
}

class SettingsExportLocalDataSource implements SettingsExportDataSource {
  SettingsExportLocalDataSource();

  @override
  Future<UserSettingsExportData> getUserSettingsData(String userId) async {
    try {
      return UserSettingsExportData(
        notificationSettings: const {
          'plantsReminder': true,
          'wateringReminder': true,
          'fertilizerReminder': false,
        },
        backupSettings: const {
          'autoBackupEnabled': true,
          'wifiOnly': true,
          'backupFrequency': 'daily',
        },
        appPreferences: const {
          'theme': 'system',
          'language': 'pt-BR',
          'autoBackup': true,
          'wifiOnly': true,
          'premiumFeatures': false,
        },
        lastBackupDate: DateTime.now().subtract(const Duration(days: 1)),
        lastSyncDate: DateTime.now(),
      );
    } catch (e) {
      throw Exception(
        'Erro ao buscar configurações do usuário: ${e.toString()}',
      );
    }
  }
}
