import 'package:dartz/dartz.dart';

/// Interface for asset loading services
abstract class IAssetLoader {
  /// Load a JSON asset file and return parsed data
  Future<Either<Exception, List<Map<String, dynamic>>>> loadJsonAsset(String assetPath);
}
