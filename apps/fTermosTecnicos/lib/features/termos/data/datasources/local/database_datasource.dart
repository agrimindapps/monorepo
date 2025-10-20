import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:injectable/injectable.dart';

import '../../../../../const/database_const.dart';

/// Abstract contract for database operations
abstract class DatabaseDataSource {
  /// Load all terms from a specific table (asset key)
  Future<List<Map<String, dynamic>>> loadTermosFromAsset(String tableKey);

  /// Decrypt description using the provided key
  String decryptDescription(String encrypted, String decryptKey);
}

/// Implementation of database data source
/// Handles loading JSON from assets and decryption logic
@LazySingleton(as: DatabaseDataSource)
class DatabaseDataSourceImpl implements DatabaseDataSource {
  @override
  Future<List<Map<String, dynamic>>> loadTermosFromAsset(
    String tableKey,
  ) async {
    try {
      // Get the list of JSON files mapped to tables
      final List<Map<String, dynamic>> dbFiles = listaDbJson();

      // Filter files by table key
      final matchingFiles =
          dbFiles.where((row) => row['table'] == tableKey).toList();

      if (matchingFiles.isEmpty) {
        throw Exception('No files found for table key: $tableKey');
      }

      List<Map<String, dynamic>> allTerms = [];

      // Load each matching file and aggregate results
      for (final fileEntry in matchingFiles) {
        final String filePath = fileEntry['file'] as String;
        final jsonString = await rootBundle.loadString(filePath);
        final dynamic jsonData = jsonDecode(jsonString);

        // Ensure we have a list
        if (jsonData is List) {
          final List<Map<String, dynamic>> terms =
              jsonData.cast<Map<String, dynamic>>();
          allTerms.addAll(terms);
        }
      }

      return allTerms;
    } catch (e) {
      throw Exception('Failed to load terms from asset: $e');
    }
  }

  @override
  String decryptDescription(String encrypted, String decryptKey) {
    try {
      final List<int> filteredKey = _filterKey(decryptKey);

      // Invert the key for decryption
      for (int i = 0; i < filteredKey.length; i++) {
        filteredKey[i] = (26 - filteredKey[i]) % 26;
      }

      return _dbCrypt(encrypted, filteredKey);
    } catch (e) {
      // Return encrypted text if decryption fails
      return encrypted;
    }
  }

  // Private helper methods migrated from Database class

  String _dbCrypt(String input, List<int> key) {
    String output = '';
    for (int i = 0, j = 0; i < input.length; i++) {
      int c = input.codeUnitAt(i);
      if (_isUppercase(c)) {
        output += String.fromCharCode((c - 65 + key[j % key.length]) % 26 + 65);
        j++;
      } else if (_isLowercase(c)) {
        output += String.fromCharCode((c - 97 + key[j % key.length]) % 26 + 97);
        j++;
      } else {
        output += input[i];
      }
    }
    return output;
  }

  List<int> _filterKey(String key) {
    List<int> result = [];
    for (int i = 0; i < key.length; i++) {
      int c = key.codeUnitAt(i);
      if (_isLetter(c)) {
        result.add((c - 65) % 32);
      }
    }
    return result;
  }

  bool _isLetter(int c) {
    return _isUppercase(c) || _isLowercase(c);
  }

  bool _isUppercase(int c) {
    return c >= 65 && c <= 90;
  }

  bool _isLowercase(int c) {
    return c >= 97 && c <= 122;
  }
}
