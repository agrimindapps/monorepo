import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'agrihurbi_database.dart';

final agrihurbiDatabaseProvider = Provider<AgrihurbiDatabase>((ref) {
  return AgrihurbiDatabase.production();
});
