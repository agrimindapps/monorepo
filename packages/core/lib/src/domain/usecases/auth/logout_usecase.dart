import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';

import '../../../domain/contracts/i_app_data_cleaner.dart';
import '../../../shared/utils/failure.dart';
import '../../repositories/i_analytics_repository.dart';
import '../../repositories/i_auth_repository.dart';
import '../base_usecase.dart';

/// A use case for logging out the current user.
///
/// This use case includes cleaning local data to ensure user privacy.
class LogoutUseCase implements NoParamsUseCase<void> {
  final IAuthRepository _authRepository;
  final IAnalyticsRepository _analyticsRepository;
  final IAppDataCleaner? _appDataCleaner;

  /// Creates a new instance of [LogoutUseCase].
  ///
  /// [_authRepository] The repository for handling authentication tasks.
  /// [_analyticsRepository] The repository for logging analytics events.
  /// [_appDataCleaner] is optional. If provided, it will be used to clear local application data.
  LogoutUseCase(
    this._authRepository,
    this._analyticsRepository,
    [this._appDataCleaner]
  );

  @override
  Future<Either<Failure, void>> call() async {
    if (kDebugMode) {
      debugPrint('🚪 LogoutUseCase: Iniciando processo de logout completo');
    }

    try {
      if (kDebugMode) {
        debugPrint('🔥 LogoutUseCase: Fazendo logout do Firebase...');
      }

      final logoutResult = await _authRepository.signOut();
      if (logoutResult.isLeft()) {
        if (kDebugMode) {
          logoutResult.fold(
            (failure) => debugPrint('❌ LogoutUseCase: Logout falhou: ${failure.message}'),
            (_) => null,
          );
        }
        return logoutResult;
      }

      if (kDebugMode) {
        debugPrint('✅ LogoutUseCase: Logout do Firebase completado com sucesso');
      }
      if (_appDataCleaner != null) {
        if (kDebugMode) {
          debugPrint('🧹 LogoutUseCase: Limpando dados locais...');
        }

        try {
          final hasData = await _appDataCleaner.hasDataToClear();
          if (hasData) {
            final cleanupResult = await _appDataCleaner.clearAllAppData();

            if (kDebugMode) {
              debugPrint('📊 LogoutUseCase: Resultado da limpeza:');
              debugPrint('   Success: ${cleanupResult['success']}');
              debugPrint('   Records cleared: ${cleanupResult['totalRecordsCleared']}');
              debugPrint('   Boxes cleared: ${cleanupResult['clearedBoxes']?.length ?? 0}');

              if (cleanupResult['errors'] != null && (cleanupResult['errors'] as List).isNotEmpty) {
                debugPrint('   Errors: ${cleanupResult['errors']}');
              }
            }
            final verified = await _appDataCleaner.verifyDataCleanup();
            if (kDebugMode) {
              debugPrint('✅ LogoutUseCase: Verificação da limpeza: ${verified ? 'OK' : 'Falhou'}');
            }
          } else {
            if (kDebugMode) {
              debugPrint('ℹ️ LogoutUseCase: Nenhum dado local para limpar');
            }
          }
        } catch (cleanupError) {
          if (kDebugMode) {
            debugPrint('⚠️ LogoutUseCase: Erro na limpeza de dados: $cleanupError');
          }
        }
      } else {
        if (kDebugMode) {
          debugPrint('⚠️ LogoutUseCase: Nenhum data cleaner configurado - pulando limpeza');
        }
      }
      try {
        await _analyticsRepository.logLogout();
        if (kDebugMode) {
          debugPrint('📊 LogoutUseCase: Analytics de logout registrado');
        }
      } catch (analyticsError) {
        if (kDebugMode) {
          debugPrint('⚠️ LogoutUseCase: Erro no analytics: $analyticsError');
        }
      }

      if (kDebugMode) {
        debugPrint('✅ LogoutUseCase: Processo de logout completado com sucesso');
      }

      return logoutResult;

    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ LogoutUseCase: Erro inesperado: $e');
      }
      return Left(UnexpectedFailure('Erro inesperado durante logout: $e'));
    }
  }
}
