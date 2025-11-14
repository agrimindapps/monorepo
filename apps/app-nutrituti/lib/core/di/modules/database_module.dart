import 'package:injectable/injectable.dart';
import '../../../drift_database/daos/agua_dao.dart';
import '../../../drift_database/nutrituti_database.dart';

/// Database module for Drift integration
@module
abstract class DatabaseModule {
  /// Provides singleton instance of NutitutiDatabase
  @singleton
  NutitutiDatabase get database => NutitutiDatabase.injectable();

  /// Provides AguaDao instance
  AguaDao get aguaDao => database.aguaDao;
}
