import '../repositories/i_settings_repository.dart';

/// Use case for syncing settings
/// Single Responsibility: Handle settings synchronization logic
class SyncSettingsUseCase {
  final ISettingsRepository _repository;

  const SyncSettingsUseCase(this._repository);

  Future<void> execute() async {
    final settings = await _repository.getSettings();
    final updatedSettings = settings.copyWith(
      lastSyncDate: DateTime.now(),
    );
    await _repository.saveSettings(updatedSettings);
  }
}
