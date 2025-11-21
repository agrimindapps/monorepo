/// Analytics user type classification for tracking purposes
enum AnalyticsUserType {
  /// Guest user (not authenticated)
  guest,

  /// Registered user (authenticated but not premium)
  registered,

  /// Premium subscriber (authenticated with active subscription)
  premium,
}
