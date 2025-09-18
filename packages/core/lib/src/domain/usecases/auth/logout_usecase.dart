import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';

import '../../../domain/contracts/i_app_data_cleaner.dart';
import '../../../shared/utils/failure.dart';
import '../../repositories/i_analytics_repository.dart';
import '../../repositories/i_auth_repository.dart';
import '../base_usecase.dart';

/// Use case para fazer logout do usuário atual
/// Inclui limpeza de dados locais para garantir privacidade
class LogoutUseCase implements NoParamsUseCase<void> {
  final IAuthRepository _authRepository;
  final IAnalyticsRepository _analyticsRepository;
  final IAppDataCleaner? _appDataCleaner;

  /// Construtor do LogoutUseCase
  /// [_appDataCleaner] é opcional - se fornecido, fará limpeza de dados locais
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
      // 1. Limpar dados locais primeiro (se configurado)
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

            // Verificar integridade da limpeza
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
          // Continue with logout even if cleanup fails
        }
      } else {
        if (kDebugMode) {
          debugPrint('⚠️ LogoutUseCase: Nenhum data cleaner configurado - pulando limpeza');
        }
      }

      // 2. Fazer logout do Firebase
      if (kDebugMode) {
        debugPrint('🔥 LogoutUseCase: Fazendo logout do Firebase...');
      }

      final logoutResult = await _authRepository.signOut();

      // 3. Log analytics independentemente do resultado
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
        logoutResult.fold(
          (failure) => debugPrint('❌ LogoutUseCase: Logout falhou: ${failure.message}'),
          (_) => debugPrint('✅ LogoutUseCase: Logout completado com sucesso'),
        );
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