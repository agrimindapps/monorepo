/// Defines the available levels for logging in the system.
///
/// The levels are ordered by severity, from least to most critical.
enum LogLevel {
  /// Detailed trace information, typically for in-depth debugging.
  trace,

  /// Detailed information useful for development and debugging.
  debug,

  /// General application information and flow events.
  info,

  /// Warnings that indicate potential issues that require attention.
  warning,

  /// Errors that need to be addressed but do not halt the application.
  error,

  /// Critical errors that can cause application failures or data loss.
  critical,
}