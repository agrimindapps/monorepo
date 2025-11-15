/// Abstração para diferentes backends de armazenamento
///
/// Este adapter permite que a aplicação use diferentes estratégias
/// de armazenamento dependendo da plataforma (web vs mobile)
abstract interface class IDatabaseAdapter {
  /// Verifica se o adapter está disponível nesta plataforma
  bool get isAvailable;

  /// Nome descritivo do adapter
  String get name;
}

/// Adapter para Drift (Mobile/Desktop)
class DriftDatabaseAdapter implements IDatabaseAdapter {
  const DriftDatabaseAdapter();

  @override
  bool get isAvailable => true;

  @override
  String get name => 'Drift (Local SQLite)';
}

/// Adapter para Firestore (Web)
class FirestoreDatabaseAdapter implements IDatabaseAdapter {
  const FirestoreDatabaseAdapter();

  @override
  bool get isAvailable => true;

  @override
  String get name => 'Firestore (Cloud)';
}
