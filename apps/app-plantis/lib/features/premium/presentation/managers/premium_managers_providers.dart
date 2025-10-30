import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'premium_features_manager.dart';
import 'premium_purchase_manager.dart';
import 'premium_sync_manager.dart';

/// Provider for PremiumFeaturesManager
final premiumFeaturesManagerProvider = Provider(
  (ref) => PremiumFeaturesManager(ref),
);

/// Provider for PremiumPurchaseManager
final premiumPurchaseManagerProvider = Provider(
  (ref) => PremiumPurchaseManager(ref),
);

/// Provider for PremiumSyncManager
final premiumSyncManagerProvider = Provider((ref) => PremiumSyncManager(ref));
