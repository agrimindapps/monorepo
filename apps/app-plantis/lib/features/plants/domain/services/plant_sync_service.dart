/// Interface for plant background sync
abstract class PlantSyncService {
  /// Sync all plants for a user in the background
  Future<void> syncPlantsInBackground(
    String userId, {
    bool connectionRestored = false,
  });

  /// Sync a single plant in the background
  Future<void> syncSinglePlantInBackground(String plantId, String userId);
}
