import 'package:core/core.dart';
import 'package:flutter/foundation.dart';

import '../../../../core/auth/auth_state_notifier.dart';
import '../../data/models/device_model.dart';
import '../repositories/device_repository.dart';

/// Use case para obter estatísticas de dispositivos no app-plantis
/// Fornece insights sobre uso de dispositivos do usuário
class GetDeviceStatisticsUseCase {
  final DeviceRepository _deviceRepository;
  final AuthStateNotifier _authStateNotifier;

  GetDeviceStatisticsUseCase(this._deviceRepository, this._authStateNotifier);

  /// Obtém estatísticas detalhadas dos dispositivos do usuário
  Future<Either<Failure, DeviceStatisticsModel>> call([
    GetDeviceStatisticsParams? params,
  ]) async {
    try {
      if (kDebugMode) {
        debugPrint('📊 DeviceStats: Getting device statistics');
      }

      // Obtém o usuário atual
      final currentUser = _authStateNotifier.currentUser;
      if (currentUser == null) {
        return const Left(AuthFailure('Usuário não autenticado'));
      }

      final userId = currentUser.id;

      // Obtém estatísticas do repository
      final result = await _deviceRepository.getDeviceStatistics(userId);

      return result.fold(
        (failure) {
          if (kDebugMode) {
            debugPrint('❌ DeviceStats: Failed to get statistics - $failure');
          }
          return Left(failure);
        },
        (statisticsMap) {
          try {
            // Converte o Map para DeviceStatisticsModel
            final statistics = _mapToDeviceStatistics(statisticsMap);

            if (kDebugMode) {
              debugPrint('✅ DeviceStats: Statistics retrieved successfully');
              debugPrint(
                '   Total: ${statistics.totalDevices}, Active: ${statistics.activeDevices}',
              );
            }

            // Adiciona informações específicas do plantis se solicitado
            if (params?.includeExtendedInfo == true) {
              final enhancedStats = _enhanceStatistics(statistics);
              return Right(enhancedStats);
            }

            return Right(statistics);
          } catch (e) {
            if (kDebugMode) {
              debugPrint('❌ DeviceStats: Error converting statistics: $e');
            }
            return Left(
              ServerFailure(
                'Erro ao processar estatísticas',
                code: 'STATISTICS_CONVERSION_ERROR',
                details: e,
              ),
            );
          }
        },
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ DeviceStats: Unexpected error - $e');
      }
      return Left(
        ServerFailure(
          'Erro ao obter estatísticas de dispositivos',
          code: 'GET_DEVICE_STATS_ERROR',
          details: e,
        ),
      );
    }
  }

  /// Converte Map&lt;String, dynamic&gt; para DeviceStatisticsModel
  DeviceStatisticsModel _mapToDeviceStatistics(Map<String, dynamic> map) {
    return DeviceStatisticsModel(
      totalDevices: map['totalDevices'] as int? ?? 0,
      activeDevices: map['activeDevices'] as int? ?? 0,
      devicesByPlatform: Map<String, int>.from(
        map['devicesByPlatform'] as Map? ?? {},
      ),
      lastActiveDevice:
          map['lastActiveDevice'] != null
              ? DeviceModel.fromEntity(map['lastActiveDevice'] as DeviceEntity)
              : null,
      oldestDevice:
          map['oldestDevice'] != null
              ? DeviceModel.fromEntity(map['oldestDevice'] as DeviceEntity)
              : null,
      newestDevice:
          map['newestDevice'] != null
              ? DeviceModel.fromEntity(map['newestDevice'] as DeviceEntity)
              : null,
    );
  }

  /// Aprimora estatísticas com informações específicas do plantis
  DeviceStatisticsModel _enhanceStatistics(DeviceStatisticsModel stats) {
    try {
      // Calcula métricas adicionais específicas do plantis
      final plantisMetrics = <String, dynamic>{};

      // Análise de atividade
      if (stats.lastActiveDevice != null) {
        final hoursSinceLastActivity =
            DateTime.now()
                .difference(stats.lastActiveDevice!.lastActiveAt)
                .inHours;

        plantisMetrics['hoursSinceLastActivity'] = hoursSinceLastActivity;
        plantisMetrics['isActiveToday'] = hoursSinceLastActivity < 24;
      }

      // Análise de plataformas
      if (stats.devicesByPlatform.isNotEmpty) {
        final mostUsedPlatform = stats.devicesByPlatform.entries.reduce(
          (a, b) => a.value > b.value ? a : b,
        );

        plantisMetrics['mostUsedPlatform'] = mostUsedPlatform.key;
        plantisMetrics['platformDiversity'] = stats.devicesByPlatform.length;
        plantisMetrics['isMobilePrimary'] =
            (stats.devicesByPlatform['iOS'] ?? 0) +
                (stats.devicesByPlatform['Android'] ?? 0) >
            stats.totalDevices / 2;
      }

      // Análise de segurança
      plantisMetrics['deviceUtilization'] =
          stats.totalDevices > 0
              ? (stats.activeDevices / stats.totalDevices * 100).round()
              : 0;

      plantisMetrics['hasInactiveDevices'] =
          stats.activeDevices < stats.totalDevices;

      // Recomendações baseadas nos dados
      final recommendations = <String>[];

      if (stats.totalDevices >= 3) {
        recommendations.add(
          'Limite de dispositivos atingido. Considere revogar dispositivos inativos.',
        );
      }

      if (stats.activeDevices < stats.totalDevices) {
        final inactiveCount = stats.totalDevices - stats.activeDevices;
        recommendations.add(
          'Você tem $inactiveCount dispositivo${inactiveCount > 1 ? 's' : ''} inativo${inactiveCount > 1 ? 's' : ''}. '
          'Revogue-${inactiveCount > 1 ? 'os' : 'o'} para liberar espaço.',
        );
      }

      if (stats.devicesByPlatform.length > 2) {
        recommendations.add(
          'Você usa múltiplas plataformas. Mantenha apenas os dispositivos que usa regularmente.',
        );
      }

      plantisMetrics['recommendations'] = recommendations;

      return DeviceStatisticsModel(
        totalDevices: stats.totalDevices,
        activeDevices: stats.activeDevices,
        devicesByPlatform: stats.devicesByPlatform,
        lastActiveDevice: stats.lastActiveDevice,
        oldestDevice: stats.oldestDevice,
        newestDevice: stats.newestDevice,
        plantisMetrics: plantisMetrics,
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('⚠️ DeviceStats: Error enhancing statistics: $e');
      }
      // Retorna estatísticas originais se falhar
      return stats;
    }
  }
}

/// Parâmetros para GetDeviceStatisticsUseCase
class GetDeviceStatisticsParams {
  final bool includeExtendedInfo;
  final bool refreshCache;

  const GetDeviceStatisticsParams({
    this.includeExtendedInfo = true,
    this.refreshCache = false,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is GetDeviceStatisticsParams &&
        other.includeExtendedInfo == includeExtendedInfo &&
        other.refreshCache == refreshCache;
  }

  @override
  int get hashCode => includeExtendedInfo.hashCode ^ refreshCache.hashCode;

  @override
  String toString() =>
      'GetDeviceStatisticsParams(includeExtendedInfo: $includeExtendedInfo)';
}
