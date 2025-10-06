import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static final SupabaseService _instance = SupabaseService._internal();

  factory SupabaseService() {
    return _instance;
  }

  SupabaseService._internal();
  Future<void> initializeSupabase() async {
    await Supabase.initialize(
      url: 'https://fkjakafxqciukoesqvkp.supabase.co', // Substitua pela sua URL
      anonKey:
          'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImZramFrYWZ4cWNpdWtvZXNxdmtwIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Mjc0OTE5ODYsImV4cCI6MjA0MzA2Nzk4Nn0.f8O9na_WhlwGJsX1EXu8E6yu0MKJHsS7dSa0HO8Ic3M', // Substitua pela sua Anon Key
    );
  }
  SupabaseClient get client => Supabase.instance.client;
  Future<List<dynamic>> fetchFitossanitarios() async {
    final response = await Supabase.instance.client
        .from('fitossanitarios') // Nome da tabela
        .select('idreg, nomecomum, ingredienteativo, fabricante')
        .eq('status', true)
        .order('nomecomum', ascending: true)
        .limit(50);

    debugPrint(response.toString());

    return response;
  }

  String dbDecode(String text) {
    String decoded = utf8.decode(base64.decode(text));
    debugPrint(decoded);
    List<String> c1 = decoded.substring(0, decoded.length ~/ 2).split('');
    List<String> c2 = decoded.substring(decoded.length ~/ 2).split('');
    String b = '';
    for (int i = 0; i < c1.length; i++) {
      b += c1[i];
      b += c2[i];
    }
    try {
      Uint8List decoded = base64.decode(b);
      String finalDecoded = '';

      for (var item in decoded) {
        try {
          finalDecoded += utf8.decode([item]);
        } catch (e) {
          debugPrint('Erro: $item');
          finalDecoded += uftNotRecognized(item);
        }
      }

      return finalDecoded;
    } catch (e) {
      return b;
    }
  }

  String uftNotRecognized(int code) {
    switch (code) {
      case 225:
        return 'á';
      case 233:
        return 'é';
      case 237:
        return 'í';
      case 243:
        return 'ó';
      case 250:
        return 'ú';
      case 193:
        return 'Á';
      case 201:
        return 'É';
      case 205:
        return 'Í';
      case 211:
        return 'Ó';
      case 218:
        return 'Ú';
      case 231:
        return 'ç';
      case 234:
        return 'ê';
      case 199:
        return 'Ç';
      case 241:
        return 'ñ';
      case 209:
        return 'Ñ';
      default:
        return ' ';
    }
  }
}
