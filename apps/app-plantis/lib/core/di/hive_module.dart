import 'package:core/core.dart' hide Column;

import '../data/models/conflict_history_model.dart';

@module
abstract class HiveModule {
  @Named('conflictHistoryBox')
  @preResolve
  Future<Box<ConflictHistoryModel>> get conflictHistoryBox async {
    if (!Hive.isBoxOpen('conflict_history')) {
      return await Hive.openBox<ConflictHistoryModel>('conflict_history');
    }
    return Hive.box<ConflictHistoryModel>('conflict_history');
  }
}
