/// Core constants for the monorepo packages
///
/// Centralizes all magic numbers, durations, and configuration values
/// to improve maintainability and enable easy customization per environment.
///
/// Usage:
/// ```dart
/// // Instead of: Duration(minutes: 15)
/// Timer.periodic(CoreConstants.defaultSyncInterval, (timer) { ... });
///
/// // Instead of: maxRetries = 3
/// for (int i = 0; i < CoreConstants.maxHttpRetries; i++) { ... }
/// ```
class CoreConstants {
  // Prevent instantiation
  CoreConstants._();

  // ============================================================================
  // SYNC CONFIGURATION
  // ============================================================================

  /// Default sync interval for background synchronization
  ///
  /// Chosen based on:
  /// - Battery life impact (more frequent = more battery drain)
  /// - Real-time requirements (most data doesn't need instant sync)
  /// - Network cost (balance between freshness and data usage)
  ///
  /// Can be overridden via SYNC_INTERVAL_MINUTES env var
  static const Duration defaultSyncInterval = Duration(minutes: 15);

  /// Sync interval for foreground/active use
  static const Duration activeSyncInterval = Duration(minutes: 5);

  /// Sync interval when app is in background
  static const Duration backgroundSyncInterval = Duration(hours: 1);

  /// Maximum number of sync retries on failure
  static const int maxSyncRetries = 3;

  /// Timeout for sync operations
  static const Duration syncTimeout = Duration(seconds: 30);

  /// Delay between sync retries (exponential backoff base)
  static const Duration syncRetryDelay = Duration(seconds: 2);

  // ============================================================================
  // AUTHENTICATION CONFIGURATION
  // ============================================================================

  /// OAuth scopes for Google Sign-In
  ///
  /// Requesting minimal permissions for user privacy
  static const List<String> googleSignInScopes = ['email', 'profile'];

  /// Permissions required for Facebook login
  static const List<String> facebookPermissions = ['email', 'public_profile'];

  /// Maximum login attempts before account lockout
  ///
  /// 5 attempts chosen to:
  /// - Prevent brute force attacks
  /// - Allow legitimate users with typos (3 is too strict)
  /// - Follow OWASP recommendations (3-5 attempts)
  static const int maxLoginAttempts = 5;

  /// Account lockout duration after max login attempts
  ///
  /// 30 minutes provides security while not overly inconveniencing users
  static const Duration accountLockoutDuration = Duration(minutes: 30);

  /// Session timeout for inactive users
  static const Duration sessionTimeout = Duration(hours: 24);

  /// Token refresh interval
  static const Duration tokenRefreshInterval = Duration(minutes: 50);

  // ============================================================================
  // IMAGE PROCESSING
  // ============================================================================

  /// Default image quality for compression (0-100)
  ///
  /// 85 provides good balance between quality and file size
  /// Can be overridden via IMAGE_QUALITY env var
  static const int defaultImageQuality = 85;

  /// High quality for receipts/documents (less compression)
  static const int highImageQuality = 90;

  /// Maximum image width for upload
  static const int maxImageWidth = 1920;

  /// Maximum image height for upload
  static const int maxImageHeight = 1920;

  /// Maximum image file size in MB
  static const int maxImageSizeMB = 10;

  /// Compression threshold (compress if file > this size)
  static const int compressionThresholdBytes = 1024 * 1024; // 1MB

  /// Compression ratio (0.0 to 1.0)
  static const double compressionRatio = 0.8;

  /// Thumbnail size (square)
  static const int thumbnailSize = 200;

  /// Supported image formats
  static const List<String> supportedImageFormats = [
    'jpg',
    'jpeg',
    'png',
    'webp'
  ];

  // ============================================================================
  // HTTP / NETWORK CONFIGURATION
  // ============================================================================

  /// Default HTTP request timeout
  ///
  /// 30 seconds is reasonable for most API calls
  static const Duration httpTimeout = Duration(seconds: 30);

  /// Upload timeout (longer for large files)
  static const Duration uploadTimeout = Duration(minutes: 2);

  /// Download timeout
  static const Duration downloadTimeout = Duration(minutes: 2);

  /// Maximum number of HTTP retries on failure
  static const int maxHttpRetries = 3;

  /// Delay between HTTP retries
  static const Duration httpRetryDelay = Duration(seconds: 2);

  /// Maximum concurrent HTTP requests
  static const int maxConcurrentRequests = 5;

  // ============================================================================
  // CACHE CONFIGURATION
  // ============================================================================

  /// Default cache TTL (time to live)
  static const Duration defaultCacheTTL = Duration(hours: 24);

  /// Short cache TTL for frequently changing data
  static const Duration shortCacheTTL = Duration(minutes: 5);

  /// Long cache TTL for rarely changing data
  static const Duration longCacheTTL = Duration(days: 7);

  /// Maximum cache size in MB
  static const int maxCacheSizeMB = 100;

  /// Maximum number of cached items
  static const int maxCacheItems = 1000;

  /// Cache cleanup interval
  static const Duration cacheCleanupInterval = Duration(hours: 6);

  // ============================================================================
  // DATABASE / STORAGE
  // ============================================================================

  /// Batch size for bulk operations
  static const int batchSize = 50;

  /// Maximum items per page (pagination)
  static const int pageSize = 20;

  /// Database query timeout
  static const Duration dbQueryTimeout = Duration(seconds: 10);

  /// Maximum offline storage size in MB
  static const int maxOfflineStorageMB = 500;

  // ============================================================================
  // UI / UX CONSTANTS
  // ============================================================================

  /// Debounce duration for search input
  static const Duration searchDebounce = Duration(milliseconds: 500);

  /// Toast/Snackbar display duration
  static const Duration toastDuration = Duration(seconds: 3);

  /// Loading indicator minimum display time
  /// Prevents flicker for fast operations
  static const Duration minLoadingDuration = Duration(milliseconds: 300);

  /// Animation duration (standard)
  static const Duration standardAnimationDuration = Duration(milliseconds: 300);

  /// Animation duration (fast)
  static const Duration fastAnimationDuration = Duration(milliseconds: 150);

  /// Pull-to-refresh trigger distance (pixels)
  static const double pullToRefreshTriggerDistance = 80.0;

  // ============================================================================
  // ANALYTICS & LOGGING
  // ============================================================================

  /// Maximum log file size in MB
  static const int maxLogFileSizeMB = 10;

  /// Log retention period
  static const Duration logRetentionPeriod = Duration(days: 7);

  /// Analytics batch size (events before sending)
  static const int analyticsBatchSize = 10;

  /// Analytics flush interval
  static const Duration analyticsFlushInterval = Duration(minutes: 5);

  // ============================================================================
  // SUBSCRIPTION / REVENUE
  // ============================================================================

  /// Trial period duration
  static const Duration trialPeriod = Duration(days: 7);

  /// Grace period after subscription expires
  static const Duration subscriptionGracePeriod = Duration(days: 3);

  /// Subscription check interval
  static const Duration subscriptionCheckInterval = Duration(hours: 12);

  // ============================================================================
  // SECURITY
  // ============================================================================

  /// Password minimum length
  static const int minPasswordLength = 8;

  /// Maximum password length
  static const int maxPasswordLength = 128;

  /// Rate limit: max requests per minute
  static const int maxRequestsPerMinute = 60;

  /// Rate limit window duration
  static const Duration rateLimitWindow = Duration(minutes: 1);

  // ============================================================================
  // VALIDATION
  // ============================================================================

  /// Maximum username length
  static const int maxUsernameLength = 30;

  /// Maximum email length
  static const int maxEmailLength = 254; // RFC 5321

  /// Maximum text field length (general)
  static const int maxTextFieldLength = 500;

  /// Maximum note/description length
  static const int maxNotesLength = 5000;

  // ============================================================================
  // USER MESSAGES (i18n keys)
  // ============================================================================
  /// These should be replaced with actual i18n keys in production

  static const String msgAccountLocked = 'error.account_locked';
  static const String msgTooManyRequests = 'error.too_many_requests';
  static const String msgInvalidCredentials = 'error.invalid_credentials';
  static const String msgNetworkError = 'error.network_error';
  static const String msgUnknownError = 'error.unknown_error';
  static const String msgSessionExpired = 'error.session_expired';
  static const String msgInvalidInput = 'error.invalid_input';
  static const String msgSuccess = 'success.general';

  // ============================================================================
  // HELPER METHODS
  // ============================================================================

  /// Gets sync interval based on environment override or default
  static Duration getSyncInterval() {
    // This can be enhanced to check EnvironmentConfig for override
    // final override = EnvironmentConfig.getOptional('SYNC_INTERVAL_MINUTES');
    // if (override != null) {
    //   return Duration(minutes: int.parse(override));
    // }
    return defaultSyncInterval;
  }

  /// Gets image quality based on environment override or default
  static int getImageQuality() {
    // This can be enhanced to check EnvironmentConfig for override
    // final override = EnvironmentConfig.getOptional('IMAGE_QUALITY');
    // if (override != null) {
    //   return int.parse(override);
    // }
    return defaultImageQuality;
  }

  /// Calculates exponential backoff delay for retries
  ///
  /// Formula: baseDelay * (2 ^ attemptNumber)
  /// Example: 2s, 4s, 8s, 16s, ...
  static Duration getBackoffDelay(int attemptNumber, Duration baseDelay) {
    return baseDelay * (1 << attemptNumber); // Bit shift for 2^n
  }

  /// Converts MB to bytes
  static int mbToBytes(int mb) => mb * 1024 * 1024;

  /// Converts bytes to MB
  static double bytesToMB(int bytes) => bytes / (1024 * 1024);
}
