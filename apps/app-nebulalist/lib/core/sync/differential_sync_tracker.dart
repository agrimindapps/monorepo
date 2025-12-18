import 'package:flutter/foundation.dart';

/// Resultado de comparação de campos
class FieldDiff {
  final String fieldName;
  final dynamic oldValue;
  final dynamic newValue;
  final bool isChanged;

  const FieldDiff({
    required this.fieldName,
    required this.oldValue,
    required this.newValue,
    required this.isChanged,
  });

  @override
  String toString() =>
      'FieldDiff($fieldName: $oldValue → $newValue, changed: $isChanged)';
}

/// Resultado de differential sync
class DifferentialSyncResult {
  final Map<String, dynamic> changedFields;
  final List<FieldDiff> diffs;
  final bool hasChanges;

  const DifferentialSyncResult({
    required this.changedFields,
    required this.diffs,
    required this.hasChanges,
  });

  /// Apenas campos que mudaram (para sync parcial)
  Map<String, dynamic> toPartialUpdate() => changedFields;

  /// Número de campos alterados
  int get changedCount => changedFields.length;
}

/// Tracker de mudanças incrementais para sync eficiente
///
/// Compara versão base (última sincronizada) com versão atual,
/// retornando apenas os campos que mudaram.
///
/// **Benefícios:**
/// - Reduz payload de rede (envia só o que mudou)
/// - Melhora performance
/// - Diminui conflitos (campos independentes não colidem)
///
/// **Exemplo:**
/// ```dart
/// final tracker = DifferentialSyncTracker();
///
/// final result = tracker.diff(
///   base: {'name': 'Shopping', 'itemCount': 5},
///   current: {'name': 'Shopping', 'itemCount': 7},
/// );
///
/// if (result.hasChanges) {
///   // Sync apenas campos alterados
///   await firestore.update(result.changedFields);
///   // Envia: {'itemCount': 7} em vez do documento completo
/// }
/// ```
class DifferentialSyncTracker {
  /// Campos que devem sempre ser incluídos (mesmo se não mudaram)
  final Set<String> alwaysIncludeFields;

  /// Campos que devem ser ignorados na comparação
  final Set<String> ignoreFields;

  DifferentialSyncTracker({
    this.alwaysIncludeFields = const {'id', 'ownerId', 'updatedAt'},
    this.ignoreFields = const {'createdAt'},
  });

  /// Compara dois maps e retorna apenas campos alterados
  ///
  /// [base] - Versão base (última sincronizada)
  /// [current] - Versão atual (local)
  /// [includeMetadata] - Se true, inclui always/ignore fields
  DifferentialSyncResult diff({
    required Map<String, dynamic> base,
    required Map<String, dynamic> current,
    bool includeMetadata = true,
  }) {
    final changedFields = <String, dynamic>{};
    final diffs = <FieldDiff>[];

    // Campos em current
    for (final key in current.keys) {
      // Ignorar campos marcados como ignore
      if (ignoreFields.contains(key)) {
        continue;
      }

      final oldValue = base[key];
      final newValue = current[key];

      final isChanged = !_deepEquals(oldValue, newValue);

      diffs.add(FieldDiff(
        fieldName: key,
        oldValue: oldValue,
        newValue: newValue,
        isChanged: isChanged,
      ));

      // Adicionar se mudou OU se é campo always-include
      if (isChanged || (includeMetadata && alwaysIncludeFields.contains(key))) {
        changedFields[key] = newValue;
      }
    }

    // Campos removidos em current (existem em base mas não em current)
    for (final key in base.keys) {
      if (!current.containsKey(key) && !ignoreFields.contains(key)) {
        diffs.add(FieldDiff(
          fieldName: key,
          oldValue: base[key],
          newValue: null,
          isChanged: true,
        ));

        // Marcar como null (remoção)
        changedFields[key] = FieldValue.delete();
      }
    }

    return DifferentialSyncResult(
      changedFields: changedFields,
      diffs: diffs,
      hasChanges: changedFields.isNotEmpty,
    );
  }

  /// Compara valores de forma profunda (suporta listas, maps, primitivos)
  bool _deepEquals(dynamic a, dynamic b) {
    if (identical(a, b)) return true;
    if (a == null || b == null) return a == b;

    // Tipos diferentes
    if (a.runtimeType != b.runtimeType) return false;

    // Lists
    if (a is List && b is List) {
      if (a.length != b.length) return false;
      for (var i = 0; i < a.length; i++) {
        if (!_deepEquals(a[i], b[i])) return false;
      }
      return true;
    }

    // Maps
    if (a is Map && b is Map) {
      if (a.length != b.length) return false;
      for (final key in a.keys) {
        if (!b.containsKey(key)) return false;
        if (!_deepEquals(a[key], b[key])) return false;
      }
      return true;
    }

    // DateTime (comparar milissegundos para evitar precision issues)
    if (a is DateTime && b is DateTime) {
      return a.millisecondsSinceEpoch == b.millisecondsSinceEpoch;
    }

    // Primitivos (String, int, double, bool, etc)
    return a == b;
  }
}

/// Marcador especial para deleção de campo no Firestore
class FieldValue {
  static const String _deleteMarker = '__DELETE__';

  static String delete() => _deleteMarker;

  static bool isDelete(dynamic value) => value == _deleteMarker;
}

/// Extensão para facilitar uso com models
extension MapDifferentialExtension on Map<String, dynamic> {
  /// Compara com outro map e retorna diff
  DifferentialSyncResult diffWith(
    Map<String, dynamic> other, {
    DifferentialSyncTracker? tracker,
  }) {
    final t = tracker ?? DifferentialSyncTracker();
    return t.diff(base: this, current: other);
  }

  /// Aplica mudanças de diff neste map
  void applyDiff(Map<String, dynamic> diff) {
    for (final entry in diff.entries) {
      if (FieldValue.isDelete(entry.value)) {
        remove(entry.key);
      } else {
        this[entry.key] = entry.value;
      }
    }
  }
}

/// Cache de versões base para differential sync
///
/// Armazena última versão sincronizada de cada documento
/// para permitir diff incremental.
class DifferentialSyncCache {
  final Map<String, Map<String, dynamic>> _baseVersions = {};

  /// Salva versão base após sync bem-sucedido
  void saveBaseVersion(String modelId, Map<String, dynamic> data) {
    _baseVersions[modelId] = Map.from(data);
    debugPrint('DifferentialSyncCache: Saved base for $modelId');
  }

  /// Obtém versão base de um modelo
  Map<String, dynamic>? getBaseVersion(String modelId) {
    return _baseVersions[modelId];
  }

  /// Verifica se tem versão base
  bool hasBaseVersion(String modelId) {
    return _baseVersions.containsKey(modelId);
  }

  /// Remove versão base (após delete por exemplo)
  void removeBaseVersion(String modelId) {
    _baseVersions.remove(modelId);
    debugPrint('DifferentialSyncCache: Removed base for $modelId');
  }

  /// Limpa todo o cache
  void clear() {
    _baseVersions.clear();
    debugPrint('DifferentialSyncCache: Cleared all base versions');
  }

  /// Número de versões em cache
  int get size => _baseVersions.length;
}
