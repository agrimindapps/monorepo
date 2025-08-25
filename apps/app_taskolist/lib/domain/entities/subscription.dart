import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'subscription_status.dart';

class Subscription {
  static final subscriptionStatusProvider = 
    StreamProvider<SubscriptionStatus>((ref) async* {
      // TODO: Implement actual subscription status stream
      yield const SubscriptionStatus(
        isActive: false,
        expirationDate: null,
      );
    });
}