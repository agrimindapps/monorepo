import 'package:injectable/injectable.dart';
import '../../../database/petiveti_database.dart';

/// Database module for Drift integration
@module
abstract class DatabaseModule {
  /// Provides singleton instance of PetivetiDatabase
  @singleton
  PetivetiDatabase get database => PetivetiDatabase();
}
