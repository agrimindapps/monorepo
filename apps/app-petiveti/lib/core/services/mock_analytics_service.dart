import 'package:core/core.dart';
import 'package:dartz/dartz.dart';

/// Implementação mock do repositório de analytics para desenvolvimento
/// Não envia dados reais, apenas simula as operações
class MockAnalyticsService implements IAnalyticsRepository {
  @override
  Future<Either<Failure, void>> logEvent(
    String eventName, {
    Map<String, dynamic>? parameters,
  }) async {
    // Em modo debug, apenas log no console
    print('📊 [MOCK] Analytics Event: $eventName, Params: $parameters');
    return const Right(null);
  }

  @override
  Future<Either<Failure, void>> setUserProperties({
    required Map<String, String> properties,
  }) async {
    print('👤 [MOCK] User Properties: $properties');
    return const Right(null);
  }

  @override
  Future<Either<Failure, void>> setUserId(String? userId) async {
    print('🆔 [MOCK] User ID: $userId');
    return const Right(null);
  }

  @override
  Future<Either<Failure, void>> setCurrentScreen({
    required String screenName,
    String? screenClassOverride,
  }) async {
    print('📱 [MOCK] Current Screen: $screenName');
    return const Right(null);
  }

  @override
  Future<Either<Failure, void>> logLogin({required String method}) async {
    print('🔐 [MOCK] Login: $method');
    return const Right(null);
  }

  @override
  Future<Either<Failure, void>> logLogout() async {
    print('🚪 [MOCK] Logout');
    return const Right(null);
  }

  @override
  Future<Either<Failure, void>> logSignUp({required String method}) async {
    print('✨ [MOCK] Sign Up: $method');
    return const Right(null);
  }

  @override
  Future<Either<Failure, void>> logPurchase({
    required String productId,
    required double value,
    required String currency,
    String? transactionId,
  }) async {
    print('💰 [MOCK] Purchase: $productId, $value $currency');
    return const Right(null);
  }

  @override
  Future<Either<Failure, void>> logCancelSubscription({
    required String productId,
    String? reason,
  }) async {
    print('❌ [MOCK] Subscription Cancelled: $productId, Reason: $reason');
    return const Right(null);
  }

  @override
  Future<Either<Failure, void>> logTrialStart({
    required String productId,
  }) async {
    print('🎯 [MOCK] Trial Start: $productId');
    return const Right(null);
  }

  @override
  Future<Either<Failure, void>> logTrialConversion({
    required String productId,
  }) async {
    print('🔄 [MOCK] Trial Conversion: $productId');
    return const Right(null);
  }

  @override
  Future<Either<Failure, void>> logError({
    required String error,
    String? stackTrace,
    Map<String, dynamic>? additionalInfo,
  }) async {
    print('❌ [MOCK] Error: $error, Stack: $stackTrace');
    return const Right(null);
  }

  @override
  Future<Either<Failure, void>> logSearch({
    required String searchTerm,
    String? category,
    int? resultCount,
  }) async {
    print(
      '� [MOCK] Search: "$searchTerm", Category: $category, Results: $resultCount',
    );
    return const Right(null);
  }

  @override
  Future<Either<Failure, void>> logShare({
    required String contentType,
    required String contentId,
    String? method,
  }) async {
    print('� [MOCK] Share: $contentType ($contentId), Method: $method');
    return const Right(null);
  }

  @override
  Future<Either<Failure, void>> logFeedback({
    required String type,
    required String content,
    double? rating,
  }) async {
    print('� [MOCK] Feedback: $type, Rating: $rating, Content: $content');
    return const Right(null);
  }

  @override
  Future<Either<Failure, void>> logOnboardingComplete({
    int? stepsCompleted,
    int? totalSteps,
  }) async {
    print('🎓 [MOCK] Onboarding Complete: $stepsCompleted/$totalSteps');
    return const Right(null);
  }

  @override
  Future<Either<Failure, void>> logTutorialComplete({
    required String tutorialId,
  }) async {
    print('🎓 [MOCK] Tutorial Complete: $tutorialId');
    return const Right(null);
  }

  @override
  Future<Either<Failure, void>> logSettingChanged({
    required String settingName,
    required dynamic oldValue,
    required dynamic newValue,
  }) async {
    print('⚙️ [MOCK] Setting Changed: $settingName, $oldValue → $newValue');
    return const Right(null);
  }
}
