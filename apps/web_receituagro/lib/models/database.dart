import 'dart:convert';

import 'package:flutter/services.dart';

import '../app-site/const/database_consts.dart';

class Database {
  static final Database _singleton = Database._internal();

  factory Database() {
    return _singleton;
  }

  Database._internal();

  static Future<List<dynamic>> loadJsonFiles(String table) async {
    List<dynamic> filenames = jsonFitos();
    filenames = filenames.where((row) => row['table'] == table).toList();

    List<dynamic> contents = [];

    List<dynamic> itens = [];

    for (final filename in filenames) {
      final jsonString = await rootBundle.loadString(filename['file']);
      final jsonMap = jsonDecode(jsonString);
      itens = List<dynamic>.from(jsonMap);
      contents.addAll(itens);
    }

    return contents;
  }

  static Future<Map<String, dynamic>> get(String table, dynamic value) async {
    final List<dynamic> data = await loadJsonFiles(table);
    return data.firstWhere((item) => item['IdReg'] == value);
  }

  static Future<List<dynamic>> getAll(String table) async {
    return loadJsonFiles(table);
  }

  static Future<List<dynamic>> getIndex(
    String table,
    String field,
    dynamic value,
  ) async {
    final List<dynamic> data = await loadJsonFiles(table);
    return data.where((item) => item[field] == value).toList();
  }

  static List<dynamic> orderList(
    List<dynamic> arrayList,
    String field,
    String? field2,
    bool distinct,
  ) {
    if (field.isEmpty) {
      throw ArgumentError('O parâmetro "Field" não pode ser nulo ou vazio.');
    }

    if (arrayList.isEmpty) {
      return [];
    }

    arrayList.sort((a, b) => a[field].compareTo(b[field]));

    if (field2 != null && field2.isNotEmpty) {
      arrayList.sort((a, b) => a[field2].compareTo(b[field2]));
    }

    if (distinct) {
      List<dynamic> distinctList = [];
      Set<dynamic> uniqueValues = {};

      for (var element in arrayList) {
        var value = element[field];
        if (!uniqueValues.contains(value)) {
          uniqueValues.add(value);
          distinctList.add(element);
        }
      }

      return distinctList;
    }

    return arrayList;
  }
}
