import 'dart:convert';
import 'dart:math';

import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../intermediate.dart';

class Database {
  Future<List<dynamic>> loadJsonFiles(String table) async {
    List<dynamic> filenames = GlobalEnvironment().listaDbJson;
    filenames = filenames.where((row) => row['table'] == table).toList();

    List<dynamic> contents = [];

    // ignore: no_leading_underscores_for_local_identifiers
    List<dynamic> _itens = [];

    for (final filename in filenames) {
      final jsonString = await rootBundle.loadString(filename['file']);
      final jsonMap = jsonDecode(jsonString);
      _itens = List<dynamic>.from(jsonMap);
      contents.addAll(_itens);
    }

    return contents;
  }

  Future<Map<String, dynamic>> get(String table, dynamic value) async {
    final List<dynamic> data = await loadJsonFiles(table);
    return data.firstWhere((item) => item['IdReg'] == value);
  }

  Future<List<dynamic>> getAll(String table) async {
    return loadJsonFiles(table);
  }

  Future<List<dynamic>> getIndex(
    String table,
    String field,
    dynamic value,
  ) async {
    final List<dynamic> data = await loadJsonFiles(table);
    return data.where((item) => item[field] == value).toList();
  }

  List<dynamic> orderList(
    List<dynamic> arrayList,
    String field,
    String? field2,
    bool distinct,
  ) {
    if (field.isEmpty) {
      String message = 'O parâmetro "Field" não pode ser nulo ou vazio.';
      throw ArgumentError(message);
    }

    if (arrayList.isEmpty) {
      String message = 'O parâmetro "ArrayList" não pode ser nulo ou vazio.';
      throw ArgumentError(message);
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

  String generateIdReg() {
    String text = '';
    String possible =
        'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
    Random random = Random();
    for (int i = 0; i < 13; i++) {
      text += possible[random.nextInt(possible.length)];
    }
    return text;
  }

  Future<void> saveRegistryLastAccess(String varStorage, String id) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<dynamic> recuperado = jsonDecode(prefs.getString(varStorage) ?? '[]');
    int contMax = recuperado.length < 9 ? recuperado.length : 9;
    bool decision = false;

    if (prefs.containsKey(varStorage)) {
      for (int x = 0; x < contMax; x++) {
        Map<String, dynamic> item = recuperado[x];
        if (item['IdReg'] == id) {
          decision = true;
          break;
        }
      }
    }

    if (!decision) {
      if (recuperado.length == 15) {
        recuperado.insert(0, {'IdReg': id});
        recuperado.removeLast();
        prefs.setString(varStorage, jsonEncode(recuperado));
      } else {
        recuperado.insert(0, {'IdReg': id});
        prefs.setString(varStorage, jsonEncode(recuperado));
      }
    }
  }

  String encode(String text) {
    text = text
        .replaceAll('€', '')
        .replaceAll('–', '-')
        .replaceAll('•', '-')
        .replaceAll('’', '"')
        .replaceAll('”', '"')
        .replaceAll('“', '"')
        .replaceAll('‘', '"')
        .replaceAll('…', '...')
        .replaceAll('—', '-')
        .replaceAll('\uFFFD', '')
        .replaceAll('\u2122', 'TM')
        .replaceAll('„', ',,')
        .replaceAll('+', '†')
        .replaceAll('—', '-')
        .replaceAll('•', '-');

    List<String> impar = [];
    List<String> par = [];
    String a = base64.encode(utf8.encode(text));
    List<String> b = a.split('');
    for (int x = 0; x < b.length; x++) {
      x % 2 == 0 ? par.add(b[x]) : impar.add(b[x]);
    }
    String c = par.join() + impar.join();
    String d = base64.encode(utf8.encode(c));
    return d;
  }

  String dbDecode(String text) {
    String d = utf8.decode(base64.decode(text));
    String c1 = d.substring(0, d.length ~/ 2);
    String c2 = d.substring(d.length ~/ 2);
    String b = '';
    for (int x = 0; x < d.length ~/ 2; x++) {
      b += c1[x];
      b += c2[x];
    }
    String a = utf8.decode(base64.decode(b));
    return a;
  }

  String dbCrypt(String input, List<int> key) {
    String output = '';
    for (int i = 0, j = 0; i < input.length; i++) {
      int c = input.codeUnitAt(i);
      if (isUppercase(c)) {
        output += String.fromCharCode((c - 65 + key[j % key.length]) % 26 + 65);
        j++;
      } else if (isLowercase(c)) {
        output += String.fromCharCode((c - 97 + key[j % key.length]) % 26 + 97);
        j++;
      } else {
        output += input[i];
      }
    }
    return output;
  }

  List<int> filterKey(String key) {
    List<int> result = [];
    for (int i = 0; i < key.length; i++) {
      int c = key.codeUnitAt(i);
      if (isLetter(c)) {
        result.add((c - 65) % 32);
      }
    }
    return result;
  }

  bool isLetter(int c) {
    return isUppercase(c) || isLowercase(c);
  }

  bool isUppercase(int c) {
    return c >= 65 && c <= 90;
  }

  bool isLowercase(int c) {
    return c >= 97 && c <= 122;
  }

  String dbDeCrypt(String text, String key) {
    List<int> filteredKey = filterKey(key);
    for (int i = 0; i < filteredKey.length; i++) {
      filteredKey[i] = (26 - filteredKey[i]) % 26;
    }
    return dbCrypt(text, filteredKey);
  }
}

final database = Database();
