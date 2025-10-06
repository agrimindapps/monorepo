import 'dart:convert';
import 'dart:math';

import 'package:core/core.dart';

import '../entities/calculation_template.dart';

/// Serviço de gerenciamento de templates de cálculo
///
/// Implementa persistência local para templates salvos
/// com funcionalidades de busca, filtragem e organização
class CalculatorTemplateService {
  static const String _templatesKey = 'calculator_templates';
  static const String _templatesBackupKey = 'calculator_templates_backup';
  static const String _lastSyncKey = 'calculator_templates_last_sync';

  final SharedPreferences _prefs;
  final Random _random = Random();

  CalculatorTemplateService(this._prefs);

  /// Gera ID único para template
  String _generateUniqueId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final randomSuffix = _random.nextInt(9999).toString().padLeft(4, '0');
    return 'template_${timestamp}_$randomSuffix';
  }

  /// Obtém todos os templates salvos
  Future<List<CalculationTemplate>> getAllTemplates() async {
    try {
      final templatesJson = _prefs.getString(_templatesKey);
      if (templatesJson == null) return [];

      final templatesList = jsonDecode(templatesJson) as List;
      return templatesList
          .map((json) => _templateFromJson(json as Map<String, dynamic>))
          .where((template) => template.isValid)
          .toList();
    } catch (e) {
      // Tentar backup em caso de erro
      return await _restoreFromBackup();
    }
  }

  /// Obtém templates por calculadora específica
  Future<List<CalculationTemplate>> getTemplatesForCalculator(
    String calculatorId,
  ) async {
    final allTemplates = await getAllTemplates();
    return allTemplates
        .where((template) => template.calculatorId == calculatorId)
        .toList()
      ..sort(
        (a, b) => b.lastUsed?.compareTo(a.lastUsed ?? DateTime(1970)) ?? 0,
      );
  }

  /// Obtém template por ID
  Future<CalculationTemplate?> getTemplateById(String templateId) async {
    final templates = await getAllTemplates();
    try {
      return templates.firstWhere((template) => template.id == templateId);
    } catch (e) {
      return null;
    }
  }

  /// Salva novo template
  Future<bool> saveTemplate(CalculationTemplate template) async {
    try {
      final templates = await getAllTemplates();

      // Verificar se já existe template com mesmo nome para esta calculadora
      final existingIndex = templates.indexWhere(
        (t) =>
            t.name == template.name &&
            t.calculatorId == template.calculatorId &&
            t.userId == template.userId,
      );

      if (existingIndex != -1) {
        // Atualizar template existente
        templates[existingIndex] = template.copyWith(
          id: templates[existingIndex].id, // Manter ID original
        );
      } else {
        // Adicionar novo template
        final newTemplate = template.copyWith(
          id: template.id.isEmpty ? _generateUniqueId() : template.id,
        );
        templates.add(newTemplate);
      }

      await _saveTemplates(templates);
      await _createBackup(templates);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Remove template
  Future<bool> deleteTemplate(String templateId) async {
    try {
      final templates = await getAllTemplates();
      templates.removeWhere((template) => template.id == templateId);

      await _saveTemplates(templates);
      await _createBackup(templates);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Atualiza template (marca como usado)
  Future<bool> markTemplateAsUsed(String templateId) async {
    try {
      final templates = await getAllTemplates();
      final templateIndex = templates.indexWhere((t) => t.id == templateId);

      if (templateIndex != -1) {
        templates[templateIndex] = templates[templateIndex].markAsUsed();
        await _saveTemplates(templates);
        return true;
      }

      return false;
    } catch (e) {
      return false;
    }
  }

  /// Busca templates por termo
  Future<List<CalculationTemplate>> searchTemplates(String query) async {
    if (query.trim().isEmpty) return await getAllTemplates();

    final templates = await getAllTemplates();
    final normalizedQuery = _normalizeText(query);

    return templates.where((template) {
      return _normalizeText(template.name).contains(normalizedQuery) ||
          _normalizeText(
            template.description ?? '',
          ).contains(normalizedQuery) ||
          template.tags.any(
            (tag) => _normalizeText(tag).contains(normalizedQuery),
          ) ||
          _normalizeText(template.calculatorName).contains(normalizedQuery);
    }).toList();
  }

  /// Filtra templates por calculadora
  Future<List<CalculationTemplate>> filterByCalculator(
    String calculatorId,
  ) async {
    return await getTemplatesForCalculator(calculatorId);
  }

  /// Obtém templates usados recentemente
  Future<List<CalculationTemplate>> getRecentTemplates({int limit = 10}) async {
    final templates = await getAllTemplates();

    // Filtrar templates que foram usados
    final usedTemplates =
        templates.where((template) => template.lastUsed != null).toList()
          ..sort((a, b) => b.lastUsed!.compareTo(a.lastUsed!));

    return usedTemplates.take(limit).toList();
  }

  /// Obtém templates mais populares (mais usados)
  Future<List<CalculationTemplate>> getPopularTemplates({
    int limit = 10,
  }) async {
    final templates = await getAllTemplates();

    // Por simplicidade, considerar templates com lastUsed como mais populares
    // Em implementação mais avançada, poderia ter contador de usos
    final popularTemplates =
        templates.where((template) => template.wasUsedRecently).toList()..sort(
          (a, b) => (b.lastUsed ?? DateTime(1970)).compareTo(
            a.lastUsed ?? DateTime(1970),
          ),
        );

    return popularTemplates.take(limit).toList();
  }

  /// Exporta templates
  Future<String> exportTemplates() async {
    final templates = await getAllTemplates();
    return jsonEncode(templates.map((t) => _templateToJson(t)).toList());
  }

  /// Importa templates
  Future<bool> importTemplates(String jsonData) async {
    try {
      final templatesList = jsonDecode(jsonData) as List;
      final templates =
          templatesList
              .map((json) => _templateFromJson(json as Map<String, dynamic>))
              .where((template) => template.isValid)
              .toList();

      final existingTemplates = await getAllTemplates();

      // Combinar templates, evitando duplicatas
      final combinedTemplates = <CalculationTemplate>[...existingTemplates];

      for (final template in templates) {
        final existsIndex = combinedTemplates.indexWhere(
          (t) =>
              t.name == template.name &&
              t.calculatorId == template.calculatorId,
        );

        if (existsIndex == -1) {
          combinedTemplates.add(template.copyWith(id: _generateUniqueId()));
        }
      }

      await _saveTemplates(combinedTemplates);
      await _createBackup(combinedTemplates);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Limpa todos os templates
  Future<bool> clearAllTemplates() async {
    try {
      await _prefs.remove(_templatesKey);
      await _createBackup([]);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Obtém estatísticas dos templates
  Future<TemplateStats> getStats() async {
    final templates = await getAllTemplates();
    final lastSync = _prefs.getString(_lastSyncKey);

    return TemplateStats(
      totalTemplates: templates.length,
      recentlyUsed: templates.where((t) => t.wasUsedRecently).length,
      publicTemplates: templates.where((t) => t.isPublic).length,
      lastSync: lastSync != null ? DateTime.parse(lastSync) : null,
      hasBackup: _prefs.containsKey(_templatesBackupKey),
    );
  }

  /// Métodos privados

  Future<void> _saveTemplates(List<CalculationTemplate> templates) async {
    final templatesJson = jsonEncode(
      templates.map((t) => _templateToJson(t)).toList(),
    );
    await _prefs.setString(_templatesKey, templatesJson);
    await _prefs.setString(_lastSyncKey, DateTime.now().toIso8601String());
  }

  Future<void> _createBackup(List<CalculationTemplate> templates) async {
    try {
      final backupData = {
        'templates': templates.map((t) => _templateToJson(t)).toList(),
        'timestamp': DateTime.now().toIso8601String(),
      };
      final backupJson = jsonEncode(backupData);
      await _prefs.setString(_templatesBackupKey, backupJson);
    } catch (e) {
      // Falha no backup não deve impedir operação principal
    }
  }

  Future<List<CalculationTemplate>> _restoreFromBackup() async {
    try {
      final backupJson = _prefs.getString(_templatesBackupKey);
      if (backupJson == null) return [];

      final backupData = jsonDecode(backupJson) as Map<String, dynamic>;
      final templates =
          (backupData['templates'] as List)
              .map((json) => _templateFromJson(json as Map<String, dynamic>))
              .where((template) => template.isValid)
              .toList();

      // Restaurar dados principais
      await _saveTemplates(templates);

      return templates;
    } catch (e) {
      return [];
    }
  }

  Map<String, dynamic> _templateToJson(CalculationTemplate template) {
    return {
      'id': template.id,
      'name': template.name,
      'calculatorId': template.calculatorId,
      'calculatorName': template.calculatorName,
      'inputValues': template.inputValues,
      'description': template.description,
      'tags': template.tags,
      'createdAt': template.createdAt.toIso8601String(),
      'lastUsed': template.lastUsed?.toIso8601String(),
      'userId': template.userId,
      'isPublic': template.isPublic,
    };
  }

  CalculationTemplate _templateFromJson(Map<String, dynamic> json) {
    return CalculationTemplate(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      calculatorId: json['calculatorId']?.toString() ?? '',
      calculatorName: json['calculatorName']?.toString() ?? '',
      inputValues: Map<String, dynamic>.from(
        (json['inputValues'] as Map<dynamic, dynamic>?) ?? {},
      ),
      description: json['description']?.toString(),
      tags: List<String>.from((json['tags'] as Iterable?) ?? []),
      createdAt: DateTime.parse(
        json['createdAt']?.toString() ?? DateTime.now().toIso8601String(),
      ),
      lastUsed:
          json['lastUsed']?.toString() != null
              ? DateTime.parse(json['lastUsed'].toString())
              : null,
      userId: json['userId']?.toString() ?? '',
      isPublic: json['isPublic'] == true,
    );
  }

  String _normalizeText(String text) {
    return text
        .toLowerCase()
        .replaceAll(RegExp(r'[àáâãäå]'), 'a')
        .replaceAll(RegExp(r'[èéêë]'), 'e')
        .replaceAll(RegExp(r'[ìíîï]'), 'i')
        .replaceAll(RegExp(r'[òóôõö]'), 'o')
        .replaceAll(RegExp(r'[ùúûü]'), 'u')
        .replaceAll(RegExp(r'[ç]'), 'c')
        .replaceAll(RegExp(r'[ñ]'), 'n')
        .trim();
  }
}

/// Estatísticas dos templates
class TemplateStats {
  final int totalTemplates;
  final int recentlyUsed;
  final int publicTemplates;
  final DateTime? lastSync;
  final bool hasBackup;

  const TemplateStats({
    required this.totalTemplates,
    required this.recentlyUsed,
    required this.publicTemplates,
    this.lastSync,
    required this.hasBackup,
  });
}
