import 'package:core/core.dart';

/// Data source local para funcionalidades premium de desenvolvimento
abstract class PremiumLocalDataSource {
  /// Gera uma licença local de desenvolvimento
  Future<void> generateLocalLicense({int days = 30});

  /// Revoga a licença local
  Future<void> revokeLocalLicense();

  /// Verifica se tem licença local ativa
  Future<bool> hasActiveLocalLicense();

  /// Obtém a data de expiração da licença local
  Future<DateTime?> getLocalLicenseExpiration();
}


class PremiumLocalDataSourceImpl implements PremiumLocalDataSource {
  PremiumLocalDataSourceImpl(this.sharedPreferences);
  static const String _localLicenseKey = 'gasometer_local_license';

  final SharedPreferences sharedPreferences;

  @override
  Future<void> generateLocalLicense({int days = 30}) async {
    final expirationDate = DateTime.now().add(Duration(days: days));

    await sharedPreferences.setString(
      _localLicenseKey,
      expirationDate.toIso8601String(),
    );

    print('Licença local gerada. Expira em: ${expirationDate.toString()}');
  }

  @override
  Future<void> revokeLocalLicense() async {
    await sharedPreferences.remove(_localLicenseKey);
    print('Licença local revogada');
  }

  @override
  Future<bool> hasActiveLocalLicense() async {
    final expiration = await getLocalLicenseExpiration();
    if (expiration == null) return false;

    return DateTime.now().isBefore(expiration);
  }

  @override
  Future<DateTime?> getLocalLicenseExpiration() async {
    final licenseString = sharedPreferences.getString(_localLicenseKey);
    if (licenseString == null) return null;

    try {
      return DateTime.parse(licenseString);
    } catch (e) {
      await revokeLocalLicense();
      return null;
    }
  }
}
