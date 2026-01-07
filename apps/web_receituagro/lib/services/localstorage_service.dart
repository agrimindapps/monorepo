import 'package:flutter/foundation.dart';
import 'dart:convert';

import 'package:core/core.dart';

class LocalStorageService {
  Future<List<String>> setUltimoAcessado(String box, String id) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey(box)) {
      debugPrint('Shared Preferences $box não existe com esse nome');
      return [];
    }

    List<String>? array = prefs.getStringList(box);
    array ??= [];
    if (array.contains(id)) {
      array.remove(id);
    }

    array.insert(0, id);
    await prefs.setStringList(box, array.sublist(0, array.length));

    return array;
  }

  Future<List<String>> initUltimoAcessado(String box, List<String> ids) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey(box)) {
      debugPrint('Shared Preferences $box já existe com carga');
      return [];
    }

    await prefs.setStringList(box, ids);
    return ids;
  }

  Future<List<String>> getUltimosAcessados(String box) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey(box)) {
      debugPrint('Shared Preferences $box não existe com esse nome');
      return [];
    }

    final List<String>? items = prefs.getStringList(box);
    return items ?? [];
  }

  Future<bool> setFavorito(String box, String id) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? array = prefs.getStringList(box);

    array ??= [];
    bool status = false;
    if (array.contains(id)) {
      array.remove(id);
    } else {
      array.add(id);
      status = true;
    }

    await prefs.setStringList(box, array);
    return status;
  }

  Future<bool> validFavorito(String box, String id) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey(box)) {
      debugPrint('Shared Preferences $box não existe com esse nome');
      return false;
    }

    List<String>? array = prefs.getStringList(box);
    array ??= [];

    return array.contains(id);
  }

  Future<List<String>> getFavoritos(String box) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey(box)) {
      debugPrint('Shared Preferences $box não existe com esse nome');
      return [];
    }

    List<String>? array = prefs.getStringList(box);
    array ??= [];
    return array;
  }

  Future<void> adicionar(String box, Map<String, dynamic> data) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var dataEncodec = json.encode(data);
    await prefs.setString(box, dataEncodec.toString());
  }

  Future<Map<String, dynamic>> carregar(String box) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey(box)) {
      debugPrint('Shared Preferences $box não existe com esse nome');
      return {};
    }

    final String? data = prefs.getString(box);
    if (data == null) {
      return {};
    }
    var dataDecodec = json.decode(data);
    return dataDecodec;
  }
}

final localStorage = LocalStorageService();
