import 'package:drift/drift.dart';
import 'package:drift/wasm.dart';
import 'package:sqlite3/wasm.dart';

LazyDatabase driftDatabase() {
  return LazyDatabase(() async {
    final sqlite3 = await WasmSqlite3.loadFromUrl(Uri.parse('/sqlite3.wasm'));
    return WasmDatabase(path: 'taskolist_database', sqlite3: sqlite3);
  });
}
