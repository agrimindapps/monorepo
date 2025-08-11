import 'package:dartz/dartz.dart';
import '../../domain/repositories/i_analytics_repository.dart';
import '../../shared/utils/failure.dart';

/// Mock simples do Analytics Service apenas com os métodos essenciais
class MockAnalyticsService implements IAnalyticsRepository {
  @override
  Future<Either<Failure, void>> logLogin({required String method}) async {
    // Mock - apenas retorna sucesso
    return const Right(null);
  }

  @override
  Future<Either<Failure, void>> logLogout() async {
    return const Right(null);
  }

  @override
  Future<Either<Failure, void>> logEvent(String name, {Map<String, dynamic>? parameters}) async {
    return const Right(null);
  }
  
  // Implementações vazias para satisfazer a interface
  @override
  Future<Either<Failure, void>> logSignUp({required String method}) => 
      Future.value(const Right(null));

  @override
  Future<Either<Failure, void>> logPurchase({required String currency, required String productId, String? transactionId, required double value}) => 
      Future.value(const Right(null));

  @override
  Future<Either<Failure, void>> logShare({required String contentId, required String contentType, String? method}) => 
      Future.value(const Right(null));

  @override
  Future<Either<Failure, void>> logSearch({String? category, int? resultCount, required String searchTerm}) => 
      Future.value(const Right(null));

  @override
  Future<Either<Failure, void>> logViewItem({required String itemId, required String itemName, required String itemCategory, Map<String, dynamic>? parameters}) => 
      Future.value(const Right(null));

  @override
  Future<Either<Failure, void>> logError({Map<String, dynamic>? additionalInfo, required String error, String? stackTrace}) => 
      Future.value(const Right(null));

  @override
  Future<Either<Failure, void>> setUserId(String? userId) => 
      Future.value(const Right(null));

  @override
  Future<Either<Failure, void>> setUserProperty({required String name, required String value}) => 
      Future.value(const Right(null));

  @override
  Future<Either<Failure, void>> setCurrentScreen({String? screenClassOverride, required String screenName}) => 
      Future.value(const Right(null));

  @override
  Future<Either<Failure, void>> logCancelSubscription({required String productId, String? reason}) => 
      Future.value(const Right(null));

  @override
  Future<Either<Failure, void>> logOnboardingComplete({int? stepsCompleted, int? totalSteps}) => 
      Future.value(const Right(null));

  @override
  Future<Either<Failure, void>> logTrialStart({required String productId}) => 
      Future.value(const Right(null));

  @override
  Future<Either<Failure, void>> logTrialConversion({required String productId}) => 
      Future.value(const Right(null));

  @override
  Future<Either<Failure, void>> logSettingChanged({required String settingName, required dynamic oldValue, required dynamic newValue}) => 
      Future.value(const Right(null));

  @override
  Future<Either<Failure, void>> logFeedback({required String type, required String content, double? rating}) => 
      Future.value(const Right(null));

  @override
  Future<Either<Failure, void>> logTutorialComplete({required String tutorialId}) => 
      Future.value(const Right(null));

  @override
  Future<Either<Failure, void>> setUserProperties({required Map<String, String> properties}) => 
      Future.value(const Right(null));
}