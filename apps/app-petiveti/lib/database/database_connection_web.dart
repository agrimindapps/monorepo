import 'package:drift/drift.dart';
import 'package:drift/web.dart';

LazyDatabase driftDatabase() {
  return LazyDatabase(() async {
    return WebDatabase('petiveti_database');
  });
}
