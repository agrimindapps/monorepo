/// Resultado de uma operação de push (local → Firebase)
class SyncPushResult {
  final int recordsPushed;
  final int recordsFailed;
  final List<String> errors;
  final Duration duration;

  const SyncPushResult({
    required this.recordsPushed,
    required this.recordsFailed,
    this.errors = const [],
    required this.duration,
  });

  bool get hasErrors => recordsFailed > 0;
  bool get isSuccess => recordsFailed == 0;

  String get summary =>
      'Push completed: $recordsPushed pushed, $recordsFailed failed in ${duration.inMilliseconds}ms' +
      (errors.isNotEmpty ? '\nErrors: ${errors.join(", ")}' : '');
}

/// Resultado de uma operação de pull (Firebase → local)
class SyncPullResult {
  final int recordsPulled;
  final int recordsFailed;
  final List<String> errors;
  final Duration duration;

  const SyncPullResult({
    required this.recordsPulled,
    required this.recordsFailed,
    this.errors = const [],
    required this.duration,
  });

  bool get hasErrors => recordsFailed > 0;
  bool get isSuccess => recordsFailed == 0;

  String get summary =>
      'Pull completed: $recordsPulled pulled, $recordsFailed failed in ${duration.inMilliseconds}ms' +
      (errors.isNotEmpty ? '\nErrors: ${errors.join(", ")}' : '');
}

/// Resultado completo de uma operação de sincronização bidirecional
class DriftSyncResult {
  final SyncPushResult push;
  final SyncPullResult pull;
  final Duration totalDuration;

  const DriftSyncResult({
    required this.push,
    required this.pull,
    required this.totalDuration,
  });

  bool get isSuccess => push.isSuccess && pull.isSuccess;
  bool get hasErrors => push.hasErrors || pull.hasErrors;

  int get totalRecordsSynced => push.recordsPushed + pull.recordsPulled;
  int get totalRecordsFailed => push.recordsFailed + pull.recordsFailed;

  String get summary =>
      'Sync completed in ${totalDuration.inMilliseconds}ms\n' +
      'Push: ${push.recordsPushed} pushed, ${push.recordsFailed} failed\n' +
      'Pull: ${pull.recordsPulled} pulled, ${pull.recordsFailed} failed';
}
