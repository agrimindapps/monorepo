/// RevenueCat constants for Taskolist app
class RevenueCatConstants {
  static const String entitlementId = 'Premium';
  
  // TODO: Replace with real RevenueCat API keys
  static const String appleApiKey = 'appl_TASKOLIST_KEY_PLACEHOLDER';
  static const String googleApiKey = 'goog_TASKOLIST_KEY_PLACEHOLDER';
  
  // Product IDs
  static const String monthlyProductId = 'taskolist_premium_monthly';
  static const String yearlyProductId = 'taskolist_premium_yearly';
  static const String lifetimeProductId = 'taskolist_premium_lifetime';
  
  static const List<String> allProductIds = [
    monthlyProductId,
    yearlyProductId,
    lifetimeProductId,
  ];
  
  static const String subscriptionRegex = 'taskolist_premium_(monthly|yearly|lifetime)';
  
  static const Map<String, Map<String, dynamic>> productDetails = {
    monthlyProductId: {
      'type': 'subscription',
      'desc': 'Monthly Premium',
      'valueId': 2628000, // 1 month in seconds
      'period': 'monthly',
    },
    yearlyProductId: {
      'type': 'subscription',
      'desc': 'Annual Premium',
      'valueId': 31536000, // 12 months in seconds
      'period': 'annual',
    },
    lifetimeProductId: {
      'type': 'lifetime',
      'desc': 'Lifetime Premium',
      'valueId': 0, // No expiration
      'period': 'lifetime',
    },
  };
  
  static const Map<String, String> termsOfUse = {
    'link': 'https://agrimindapps.blogspot.com/taskolist-terms',
    'google':
        'Taskolist subscription will be automatically renewed within 24 hours before the end of the subscription period and you will be charged through your Google Play account. You can manage your subscription through Google Play in the Subscriptions option.',
    'apple':
        'Taskolist subscription will automatically renew 24 hours before the end of the period and you will be charged through your iTunes account. The current subscription amount cannot be refunded and the service cannot be interrupted in case of withdrawal during the term.\n\nYour subscription can be managed through your iTunes Account Settings.',
  };
  
  static const List<Map<String, String>> premiumBenefits = [
    {
      'icon': '✅',
      'title': 'Unlimited Tasks',
      'desc': 'Create unlimited tasks and subtasks without restrictions',
    },
    {
      'icon': '🏷️',
      'title': 'Custom Tags',
      'desc': 'Organize with unlimited custom tags and categories',
    },
    {
      'icon': '⏱️',
      'title': 'Time Tracking',
      'desc': 'Track time spent on tasks with detailed analytics',
    },
    {
      'icon': '📊',
      'title': 'Productivity Analytics',
      'desc': 'Advanced insights and reports on your productivity',
    },
    {
      'icon': '☁️',
      'title': 'Cloud Sync',
      'desc': 'Seamless sync across all your devices',
    },
    {
      'icon': '📤',
      'title': 'Export Data',
      'desc': 'Export your data in multiple formats (CSV, JSON, PDF)',
    },
    {
      'icon': '🎨',
      'title': 'Custom Themes',
      'desc': 'Personalize with exclusive premium themes',
    },
    {
      'icon': '🚀',
      'title': 'Early Access',
      'desc': 'Be the first to try new features and updates',
    },
  ];
  
  static const Map<String, dynamic> defaultSubscriptionInfo = {
    'startDate': '',
    'endDate': '',
    'description': 'No active subscription',
    'daysRemaining': '0 days',
    'percentUsed': 0,
  };
}
