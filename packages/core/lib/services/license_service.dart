import 'dart:convert';
import 'package:dartz/dartz.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/license_info.dart';

/// Service for managing app licenses using SharedPreferences
/// ✅ Migrated from Hive to SharedPreferences
class LicenseService {
  static const String _licenseKey = 'app_license_info';
  static const String _activationDateKey = 'license_activation_date';
  static const String _trialStartDateKey = 'trial_start_date';

  final SharedPreferences _prefs;

  LicenseService(this._prefs);

  /// Initialize license (compatibility method - auto-loads from SharedPreferences)
  Future<Either<Exception, LicenseInfo>> initializeLicense() async {
    // Just return current license info - SharedPreferences auto-loads
    return await getLicenseInfo();
  }

  /// Get current license information
  Future<Either<Exception, LicenseInfo>> getLicenseInfo() async {
    try {
      final licenseJson = _prefs.getString(_licenseKey);
      
      if (licenseJson == null) {
        // No license stored - return free/trial default
        final trialStartDate = _prefs.getString(_trialStartDateKey);
        if (trialStartDate != null) {
          final startDate = DateTime.parse(trialStartDate);
          final daysRemaining = _calculateTrialDaysRemaining(startDate);
          final expirationDate = startDate.add(const Duration(days: 30));
          
          return Right(LicenseInfo.trial(
            expirationDate: expirationDate,
            daysRemaining: daysRemaining,
            startDate: startDate,
          ));
        }
        
        return Right(LicenseInfo.noLicense());
      }

      final license = LicenseInfo.fromJson(
        jsonDecode(licenseJson) as Map<String, dynamic>,
      );
      
      // Check if trial expired
      if (license.type == 'trial' && license.expirationDate != null) {
        final daysRemaining = license.expirationDate!.difference(DateTime.now()).inDays;
        if (daysRemaining <= 0) {
          return Right(license.copyWith(
            isActive: false,
            isExpired: true,
            trialDaysRemaining: 0,
          ));
        }
      }

      return Right(license);
    } catch (e) {
      return Left(Exception('Failed to get license info: $e'));
    }
  }

  /// Activate premium license
  Future<Either<Exception, LicenseInfo>> activatePremium({
    DateTime? expirationDate,
    String? licenseKey,
    String? subscriptionId,
  }) async {
    try {
      final premium = LicenseInfo.premium(
        expirationDate: expirationDate,
        id: subscriptionId ?? licenseKey,
      );
      await _saveLicense(premium);
      await _prefs.setString(
        _activationDateKey,
        DateTime.now().toIso8601String(),
      );
      return Right(premium);
    } catch (e) {
      return Left(Exception('Failed to activate premium: $e'));
    }
  }

  /// Extend trial period
  Future<Either<Exception, LicenseInfo>> extendTrial(int days) async {
    try {
      final currentInfo = await getLicenseInfo();
      
      return currentInfo.fold(
        (error) => Left(error),
        (info) async {
          if (info.type != 'trial') {
            return Left(Exception('Can only extend trial licenses'));
          }

          final newExpirationDate = (info.expirationDate ?? DateTime.now())
              .add(Duration(days: days));
          
          final newDaysRemaining = newExpirationDate.difference(DateTime.now()).inDays;

          final extendedLicense = LicenseInfo.trial(
            expirationDate: newExpirationDate,
            daysRemaining: newDaysRemaining,
            startDate: info.startDate,
          );

          await _saveLicense(extendedLicense);
          return Right(extendedLicense);
        },
      );
    } catch (e) {
      return Left(Exception('Failed to extend trial: $e'));
    }
  }

  /// Deactivate license (revert to free)
  Future<Either<Exception, void>> deactivateLicense() async {
    try {
      await _prefs.remove(_licenseKey);
      await _prefs.remove(_activationDateKey);
      return const Right(null);
    } catch (e) {
      return Left(Exception('Failed to deactivate license: $e'));
    }
  }

  /// Reset license (clear all license data)
  Future<Either<Exception, void>> resetLicense() async {
    try {
      await _prefs.remove(_licenseKey);
      await _prefs.remove(_activationDateKey);
      await _prefs.remove(_trialStartDateKey);
      return const Right(null);
    } catch (e) {
      return Left(Exception('Failed to reset license: $e'));
    }
  }

  /// Get expiration warning
  Future<Either<Exception, String?>> getExpirationWarning() async {
    try {
      final licenseInfo = await getLicenseInfo();
      
      return licenseInfo.fold(
        (error) => Left(error),
        (info) {
          if (info.type == 'trial') {
            final daysRemaining = info.trialDaysRemaining ?? 0;
            if (daysRemaining <= 0) {
              return const Right('Seu período de teste expirou');
            } else if (daysRemaining <= 3) {
              return Right('Seu período de teste expira em $daysRemaining dias');
            } else if (daysRemaining <= 7) {
              return Right('Seu período de teste expira em $daysRemaining dias');
            }
          } else if (info.type == 'premium' && info.expirationDate != null) {
            final daysRemaining = info.expirationDate!.difference(DateTime.now()).inDays;
            if (daysRemaining <= 0) {
              return const Right('Sua licença premium expirou');
            } else if (daysRemaining <= 7) {
              return Right('Sua licença premium expira em $daysRemaining dias');
            }
          }
          
          return const Right(null);
        },
      );
    } catch (e) {
      return Left(Exception('Failed to get expiration warning: $e'));
    }
  }

  /// Start trial (if not already started)
  Future<Either<Exception, LicenseInfo>> startTrial({int days = 30}) async {
    try {
      // Check if trial already exists
      final existingTrialStart = _prefs.getString(_trialStartDateKey);
      if (existingTrialStart != null) {
        // Trial already started, return current info
        return await getLicenseInfo();
      }

      final now = DateTime.now();
      final expirationDate = now.add(Duration(days: days));
      
      final trial = LicenseInfo.trial(
        expirationDate: expirationDate,
        daysRemaining: days,
        startDate: now,
      );

      await _saveLicense(trial);
      await _prefs.setString(_trialStartDateKey, now.toIso8601String());
      
      return Right(trial);
    } catch (e) {
      return Left(Exception('Failed to start trial: $e'));
    }
  }

  /// Check if premium is active
  Future<bool> isPremiumActive() async {
    final result = await getLicenseInfo();
    return result.fold(
      (_) => false,
      (info) => info.isActive && info.type == 'premium',
    );
  }

  /// Check if trial is active
  Future<bool> isTrialActive() async {
    final result = await getLicenseInfo();
    return result.fold(
      (_) => false,
      (info) => info.isActive && info.type == 'trial',
    );
  }

  /// Check if user can access a premium feature
  Future<Either<Exception, bool>> canAccessFeature(PremiumFeature feature) async {
    try {
      final licenseInfo = await getLicenseInfo();
      
      return licenseInfo.fold(
        (error) => Left(error),
        (info) {
          // Premium users can access all features
          if (info.type == 'premium' && info.isActive) {
            return const Right(true);
          }
          
          // Trial users can access all features during trial
          if (info.type == 'trial' && info.isActive && !info.isExpired) {
            return const Right(true);
          }
          
          // Free users cannot access premium features
          return const Right(false);
        },
      );
    } catch (e) {
      return Left(Exception('Failed to check feature access: $e'));
    }
  }

  // Private helpers

  Future<void> _saveLicense(LicenseInfo license) async {
    await _prefs.setString(_licenseKey, jsonEncode(license.toJson()));
  }

  int _calculateTrialDaysRemaining(DateTime startDate) {
    final expirationDate = startDate.add(const Duration(days: 30));
    final daysRemaining = expirationDate.difference(DateTime.now()).inDays;
    return daysRemaining > 0 ? daysRemaining : 0;
  }
}

/// Enum for premium features
enum PremiumFeature {
  unlimitedPlants,
  customReminders,
  advancedAnalytics,
  weatherIntegration,
  plantIdentification,
  expertSupport,
}

/// Extension for PremiumFeature display
extension PremiumFeatureExtension on PremiumFeature {
  String get displayName {
    switch (this) {
      case PremiumFeature.unlimitedPlants:
        return 'Plantas ilimitadas';
      case PremiumFeature.customReminders:
        return 'Lembretes personalizados';
      case PremiumFeature.advancedAnalytics:
        return 'Análises avançadas';
      case PremiumFeature.weatherIntegration:
        return 'Integração meteorológica';
      case PremiumFeature.plantIdentification:
        return 'Identificação de plantas';
      case PremiumFeature.expertSupport:
        return 'Suporte especializado';
    }
  }

  String get description {
    switch (this) {
      case PremiumFeature.unlimitedPlants:
        return 'Adicione quantas plantas quiser';
      case PremiumFeature.customReminders:
        return 'Crie lembretes personalizados';
      case PremiumFeature.advancedAnalytics:
        return 'Relatórios e estatísticas detalhadas';
      case PremiumFeature.weatherIntegration:
        return 'Cuidados baseados no clima';
      case PremiumFeature.plantIdentification:
        return 'Identifique plantas por foto';
      case PremiumFeature.expertSupport:
        return 'Suporte de especialistas em plantas';
    }
  }
}


