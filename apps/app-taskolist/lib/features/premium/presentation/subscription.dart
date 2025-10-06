import 'package:core/core.dart';
import 'subscription_status.dart' as local;

class Subscription {
  static final subscriptionStatusProvider = 
    StreamProvider<local.SubscriptionStatus>((ref) async* {
      yield const local.SubscriptionStatus(
        isActive: false,
        expirationDate: null,
      );
    });
}
