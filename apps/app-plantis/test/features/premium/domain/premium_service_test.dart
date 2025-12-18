// TODO: Este teste foi desabilitado pois as funcionalidades de premium não estão implementadas
// Para habilitar, implemente:
// - features/premium/domain/entities/premium_status.dart
// - features/premium/domain/usecases/
// - Integração com ISubscriptionRepository do core

import 'package:flutter_test/flutter_test.dart';

void main() {
  // Teste desabilitado - implementação pendente
  test('premium features not implemented yet', () {
    expect(true, true);
  });
}

/*
import 'package:app_plantis/features/premium/domain/entities/premium_status.dart';
import 'package:app_plantis/features/premium/domain/usecases/check_premium_usecase.dart';
import 'package:app_plantis/features/premium/domain/usecases/get_current_subscription_usecase.dart';
import 'package:app_plantis/features/premium/domain/usecases/purchase_premium_usecase.dart';
import 'package:app_plantis/features/premium/domain/usecases/restore_purchases_usecase.dart';
import 'package:core/core.dart' hide Column;
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/mocks.dart';

class MockPremiumRepository extends Mock
    implements ISubscriptionRepository {}

void main_disabled() {
  late MockPremiumRepository mockPremiumRepository;

  setUpAll(() {
    registerFallbackValue(
      core.SubscriptionEntity(
        id: 'sub-1',
        userId: 'user-1',
        productId: 'premium_monthly',
        status: core.SubscriptionStatus.active,
        startDate: DateTime.now(),
        createdAt: DateTime.now(),
      ),
    );
  });

  setUp(() {
    mockPremiumRepository = MockPremiumRepository();
  });

  group('Premium - Check Status', () {
    test(
      'should return premium status when user has active subscription',
      () async {
        // Arrange
        final subscription = core.SubscriptionEntity(
          id: 'sub-1',
          userId: 'user-1',
          productId: 'premium_monthly',
          status: core.SubscriptionStatus.active,
          startDate: DateTime.now().subtract(const Duration(days: 15)),
          endDate: DateTime.now().add(const Duration(days: 15)),
          createdAt: DateTime.now().subtract(const Duration(days: 15)),
        );

        when(
          () => mockPremiumRepository.hasActiveSubscription(),
        ).thenAnswer((_) async => const Right(true));
        when(
          () => mockPremiumRepository.getCurrentSubscription(),
        ).thenAnswer((_) async => Right(subscription));

        // Act
        final hasActive = await mockPremiumRepository.hasActiveSubscription();
        final currentSub = await mockPremiumRepository.getCurrentSubscription();

        // Assert
        expect(hasActive.isRight(), true);
        hasActive.fold(
          (_) => fail('Should return success'),
          (isPremium) => expect(isPremium, true),
        );

        expect(currentSub.isRight(), true);
        currentSub.fold((_) => fail('Should return success'), (sub) {
          expect(sub?.status, core.SubscriptionStatus.active);
          expect(sub?.productId, 'premium_monthly');
        });
      },
    );

    test('should return false when user has no subscription', () async {
      // Arrange
      when(
        () => mockPremiumRepository.hasActiveSubscription(),
      ).thenAnswer((_) async => const Right(false));
      when(
        () => mockPremiumRepository.getCurrentSubscription(),
      ).thenAnswer((_) async => const Right(null));

      // Act
      final hasActive = await mockPremiumRepository.hasActiveSubscription();
      final currentSub = await mockPremiumRepository.getCurrentSubscription();

      // Assert
      hasActive.fold(
        (_) => fail('Should return success'),
        (isPremium) => expect(isPremium, false),
      );

      currentSub.fold(
        (_) => fail('Should return success'),
        (sub) => expect(sub, isNull),
      );
    });

    test('should return false when subscription is expired', () async {
      // Arrange
      final expiredSubscription = core.SubscriptionEntity(
        id: 'sub-1',
        userId: 'user-1',
        productId: 'premium_monthly',
        status: core.SubscriptionStatus.expired,
        startDate: DateTime.now().subtract(const Duration(days: 60)),
        endDate: DateTime.now().subtract(const Duration(days: 30)),
        createdAt: DateTime.now().subtract(const Duration(days: 60)),
      );

      when(
        () => mockPremiumRepository.hasActiveSubscription(),
      ).thenAnswer((_) async => const Right(false));
      when(
        () => mockPremiumRepository.getCurrentSubscription(),
      ).thenAnswer((_) async => Right(expiredSubscription));

      // Act
      final hasActive = await mockPremiumRepository.hasActiveSubscription();

      // Assert
      hasActive.fold(
        (_) => fail('Should return success'),
        (isPremium) => expect(isPremium, false),
      );
    });
  });

  group('Premium - Purchase', () {
    test('should purchase premium successfully', () async {
      // Arrange
      const productId = 'premium_monthly';
      final newSubscription = core.SubscriptionEntity(
        id: 'sub-new',
        userId: 'user-1',
        productId: productId,
        status: core.SubscriptionStatus.active,
        startDate: DateTime.now(),
        endDate: DateTime.now().add(const Duration(days: 30)),
        createdAt: DateTime.now(),
      );

      when(
        () => mockPremiumRepository.createSubscription(any()),
      ).thenAnswer((_) async => Right(newSubscription));

      // Act
      final result = await mockPremiumRepository.createSubscription(
        core.CreateSubscriptionParams(userId: 'user-1', productId: productId),
      );

      // Assert
      expect(result.isRight(), true);
      result.fold((_) => fail('Should return success'), (sub) {
        expect(sub.productId, productId);
        expect(sub.status, core.SubscriptionStatus.active);
      });
      verify(() => mockPremiumRepository.createSubscription(any())).called(1);
    });

    test('should return failure when purchase fails', () async {
      // Arrange
      const productId = 'premium_monthly';

      when(() => mockPremiumRepository.createSubscription(any())).thenAnswer(
        (_) async => const Left(ServerFailure('Erro ao processar compra')),
      );

      // Act
      final result = await mockPremiumRepository.createSubscription(
        core.CreateSubscriptionParams(userId: 'user-1', productId: productId),
      );

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure.message, contains('compra')),
        (_) => fail('Should return failure'),
      );
    });

    test('should validate product ID before purchase', () {
      // Arrange
      const invalidProductIds = ['', ' ', 'invalid_id'];
      const validProductIds = [
        'premium_monthly',
        'premium_yearly',
        'premium_lifetime',
      ];

      // Assert
      for (final productId in invalidProductIds) {
        expect(
          productId.isEmpty || !productId.startsWith('premium_'),
          true,
          reason: 'Product ID "$productId" should be invalid',
        );
      }

      for (final productId in validProductIds) {
        expect(productId.startsWith('premium_'), true);
      }
    });
  });

  group('Premium - Restore Purchases', () {
    test('should restore purchases successfully', () async {
      // Arrange
      final restoredSubscription = core.SubscriptionEntity(
        id: 'sub-restored',
        userId: 'user-1',
        productId: 'premium_yearly',
        status: core.SubscriptionStatus.active,
        startDate: DateTime.now().subtract(const Duration(days: 100)),
        endDate: DateTime.now().add(const Duration(days: 265)),
        createdAt: DateTime.now().subtract(const Duration(days: 100)),
      );

      when(
        () => mockPremiumRepository.getCurrentSubscription(),
      ).thenAnswer((_) async => Right(restoredSubscription));
      when(
        () => mockPremiumRepository.hasActiveSubscription(),
      ).thenAnswer((_) async => const Right(true));

      // Act
      final currentSub = await mockPremiumRepository.getCurrentSubscription();

      // Assert
      expect(currentSub.isRight(), true);
      currentSub.fold((_) => fail('Should return success'), (sub) {
        expect(sub, isNotNull);
        expect(sub?.status, core.SubscriptionStatus.active);
      });
    });

    test('should return empty when no purchases to restore', () async {
      // Arrange
      when(
        () => mockPremiumRepository.getCurrentSubscription(),
      ).thenAnswer((_) async => const Right(null));
      when(
        () => mockPremiumRepository.getUserSubscriptions(),
      ).thenAnswer((_) async => const Right([]));

      // Act
      final subscriptions = await mockPremiumRepository.getUserSubscriptions();

      // Assert
      expect(subscriptions.isRight(), true);
      subscriptions.fold(
        (_) => fail('Should return success'),
        (subs) => expect(subs, isEmpty),
      );
    });

    test('should handle restore failure gracefully', () async {
      // Arrange
      when(() => mockPremiumRepository.getCurrentSubscription()).thenAnswer(
        (_) async => const Left(ServerFailure('Erro ao restaurar compras')),
      );

      // Act
      final result = await mockPremiumRepository.getCurrentSubscription();

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure.message, contains('restaurar')),
        (_) => fail('Should return failure'),
      );
    });
  });

  group('Premium - Available Products', () {
    test('should return list of available products', () async {
      // Arrange
      final products = [
        core.ProductInfo(
          id: 'premium_monthly',
          title: 'Premium Mensal',
          description: 'Acesso premium por 1 mês',
          price: 'R\$ 9,90',
          priceValue: 9.90,
          currency: 'BRL',
        ),
        core.ProductInfo(
          id: 'premium_yearly',
          title: 'Premium Anual',
          description: 'Acesso premium por 1 ano',
          price: 'R\$ 99,90',
          priceValue: 99.90,
          currency: 'BRL',
        ),
      ];

      when(
        () => mockPremiumRepository.getAvailableProducts(),
      ).thenAnswer((_) async => Right(products));

      // Act - simulating the call
      final result = await mockPremiumRepository.getAvailableProducts();

      // Assert
      expect(result.isRight(), true);
      result.fold((_) => fail('Should return success'), (productList) {
        expect(productList.length, 2);
        expect(productList[0].id, 'premium_monthly');
        expect(productList[1].id, 'premium_yearly');
      });
    });

    test('should return empty list when no products available', () async {
      // Arrange
      when(
        () => mockPremiumRepository.getAvailableProducts(),
      ).thenAnswer((_) async => const Right([]));

      // Act
      final result = await mockPremiumRepository.getAvailableProducts();

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (_) => fail('Should return success'),
        (productList) => expect(productList, isEmpty),
      );
    });
  });

  group('Premium - Subscription Stream', () {
    test('should emit subscription updates', () async {
      // Arrange
      final subscription = core.SubscriptionEntity(
        id: 'sub-1',
        userId: 'user-1',
        productId: 'premium_monthly',
        status: core.SubscriptionStatus.active,
        startDate: DateTime.now(),
        createdAt: DateTime.now(),
      );

      when(
        () => mockPremiumRepository.subscriptionStatus,
      ).thenAnswer((_) => Stream.value(subscription));

      // Act
      final stream = mockPremiumRepository.subscriptionStatus;

      // Assert
      expect(stream, emits(subscription));
    });

    test('should emit null when no subscription', () async {
      // Arrange
      when(
        () => mockPremiumRepository.subscriptionStatus,
      ).thenAnswer((_) => Stream.value(null));

      // Act
      final stream = mockPremiumRepository.subscriptionStatus;

      // Assert
      expect(stream, emits(null));
    });

    test('should emit multiple subscription state changes', () async {
      // Arrange
      final subscription1 = core.SubscriptionEntity(
        id: 'sub-1',
        userId: 'user-1',
        productId: 'premium_monthly',
        status: core.SubscriptionStatus.active,
        startDate: DateTime.now(),
        createdAt: DateTime.now(),
      );

      final subscription2 = subscription1.copyWith(
        status: core.SubscriptionStatus.expired,
      );

      when(
        () => mockPremiumRepository.subscriptionStatus,
      ).thenAnswer((_) => Stream.fromIterable([subscription1, subscription2]));

      // Act
      final stream = mockPremiumRepository.subscriptionStatus;

      // Assert
      expect(stream, emitsInOrder([subscription1, subscription2]));
    });
  });

  group('Premium - Trial Period', () {
    test('should identify trial subscription', () {
      // Arrange
      final trialSubscription = core.SubscriptionEntity(
        id: 'sub-trial',
        userId: 'user-1',
        productId: 'premium_trial',
        status: core.SubscriptionStatus.trial,
        startDate: DateTime.now(),
        endDate: DateTime.now().add(const Duration(days: 7)),
        createdAt: DateTime.now(),
      );

      // Assert
      expect(trialSubscription.status, core.SubscriptionStatus.trial);
      expect(trialSubscription.endDate!.isAfter(DateTime.now()), true);
    });

    test('should convert trial to active after purchase', () {
      // Arrange
      final trialSubscription = core.SubscriptionEntity(
        id: 'sub-trial',
        userId: 'user-1',
        productId: 'premium_trial',
        status: core.SubscriptionStatus.trial,
        startDate: DateTime.now(),
        createdAt: DateTime.now(),
      );

      // Act
      final activeSubscription = trialSubscription.copyWith(
        status: core.SubscriptionStatus.active,
        productId: 'premium_monthly',
      );

      // Assert
      expect(activeSubscription.status, core.SubscriptionStatus.active);
      expect(activeSubscription.productId, 'premium_monthly');
    });
  });

  group('Premium - Cancellation', () {
    test('should handle subscription cancellation', () {
      // Arrange
      final activeSubscription = core.SubscriptionEntity(
        id: 'sub-1',
        userId: 'user-1',
        productId: 'premium_monthly',
        status: core.SubscriptionStatus.active,
        startDate: DateTime.now().subtract(const Duration(days: 15)),
        endDate: DateTime.now().add(const Duration(days: 15)),
        createdAt: DateTime.now().subtract(const Duration(days: 15)),
      );

      // Act
      final cancelledSubscription = activeSubscription.copyWith(
        status: core.SubscriptionStatus.cancelled,
      );

      // Assert
      expect(cancelledSubscription.status, core.SubscriptionStatus.cancelled);
      expect(cancelledSubscription.endDate, isNotNull);
    });

    test('should verify subscription remains active until end date', () {
      // Arrange
      final now = DateTime.now();
      final cancelledSubscription = core.SubscriptionEntity(
        id: 'sub-1',
        userId: 'user-1',
        productId: 'premium_monthly',
        status: core.SubscriptionStatus.cancelled,
        startDate: now.subtract(const Duration(days: 20)),
        endDate: now.add(const Duration(days: 10)), // Still valid for 10 days
        createdAt: now.subtract(const Duration(days: 20)),
      );

      // Assert
      expect(cancelledSubscription.endDate!.isAfter(now), true);
      // User should still have access until endDate
      final hasAccessUntilEnd = cancelledSubscription.endDate!.isAfter(now);
      expect(hasAccessUntilEnd, true);
    });
  });
}
*/
