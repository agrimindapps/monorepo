import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Modelo para histórico de acesso
class AccessHistoryItem {
  final String id;
  final String type; // 'defensivo' ou 'praga'
  final String name;
  final String? subtitle;
  final DateTime accessDate;
  final Map<String, dynamic> metadata;

  AccessHistoryItem({
    required this.id,
    required this.type,
    required this.name,
    this.subtitle,
    required this.accessDate,
    this.metadata = const {},
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type,
        'name': name,
        'subtitle': subtitle,
        'accessDate': accessDate.toIso8601String(),
        'metadata': metadata,
      };

  factory AccessHistoryItem.fromJson(Map<String, dynamic> json) {
    return AccessHistoryItem(
      id: json['id'] as String,
      type: json['type'] as String,
      name: json['name'] as String,
      subtitle: json['subtitle'] as String?,
      accessDate: DateTime.parse(json['accessDate'] as String),
      metadata: json['metadata'] as Map<String, dynamic>? ?? {},
    );
  }
}

/// Serviço para gerenciar histórico de acessos
class AccessHistoryService {
  static const String _keyDefensivos = 'access_history_defensivos';
  static const String _keyPragas = 'access_history_pragas';
  static const int _maxHistoryItems = 10; // Máximo de itens no histórico

  /// Registra acesso a um defensivo
  Future<void> recordDefensivoAccess({
    required String id,
    required String name,
    String? fabricante,
    String? ingrediente,
    String? classe,
  }) async {
    final item = AccessHistoryItem(
      id: id,
      type: 'defensivo',
      name: name,
      subtitle: fabricante,
      accessDate: DateTime.now(),
      metadata: {
        'fabricante': fabricante,
        'ingrediente': ingrediente,
        'classe': classe,
      },
    );

    await _recordAccess(_keyDefensivos, item);
  }

  /// Registra acesso a uma praga
  Future<void> recordPragaAccess({
    required String id,
    required String nomeComum,
    required String nomeCientifico,
    required String tipoPraga,
  }) async {
    final item = AccessHistoryItem(
      id: id,
      type: 'praga',
      name: nomeComum,
      subtitle: nomeCientifico,
      accessDate: DateTime.now(),
      metadata: {
        'nomeCientifico': nomeCientifico,
        'tipoPraga': tipoPraga,
      },
    );

    await _recordAccess(_keyPragas, item);
  }

  /// Obtém histórico de defensivos
  Future<List<AccessHistoryItem>> getDefensivosHistory() async {
    return _getHistory(_keyDefensivos);
  }

  /// Obtém histórico de pragas
  Future<List<AccessHistoryItem>> getPragasHistory() async {
    return _getHistory(_keyPragas);
  }

  /// Limpa histórico de defensivos
  Future<void> clearDefensivosHistory() async {
    await _clearHistory(_keyDefensivos);
  }

  /// Limpa histórico de pragas
  Future<void> clearPragasHistory() async {
    await _clearHistory(_keyPragas);
  }

  /// Registra um acesso (método interno)
  Future<void> _recordAccess(String key, AccessHistoryItem item) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Verifica se SharedPreferences foi inicializado corretamente
      if (!prefs.containsKey('_initialized')) {
        await prefs.setBool('_initialized', true);
      }
      final historyJson = prefs.getString(key);

      List<AccessHistoryItem> history = [];
      if (historyJson != null) {
        final historyList = jsonDecode(historyJson) as List;
        history = historyList
            .map((json) => AccessHistoryItem.fromJson(json as Map<String, dynamic>))
            .toList();
      }

      // Remove item existente se houver (evita duplicatas)
      history.removeWhere((existing) => existing.id == item.id);

      // Adiciona novo item no início
      history.insert(0, item);

      // Mantém apenas os últimos itens
      if (history.length > _maxHistoryItems) {
        history = history.take(_maxHistoryItems).toList();
      }

      // Salva histórico atualizado
      final updatedHistoryJson = jsonEncode(
        history.map((item) => item.toJson()).toList(),
      );
      await prefs.setString(key, updatedHistoryJson);
    } catch (e) {
      // Em caso de erro, não interrompe o fluxo
      print('Erro ao salvar histórico: $e');
    }
  }

  /// Obtém histórico (método interno)
  Future<List<AccessHistoryItem>> _getHistory(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final historyJson = prefs.getString(key);

      if (historyJson == null) return [];

      final historyList = jsonDecode(historyJson) as List;
      return historyList
          .map((json) => AccessHistoryItem.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Erro ao carregar histórico: $e');
      return [];
    }
  }

  /// Limpa histórico (método interno)
  Future<void> _clearHistory(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(key);
    } catch (e) {
      print('Erro ao limpar histórico: $e');
    }
  }
}