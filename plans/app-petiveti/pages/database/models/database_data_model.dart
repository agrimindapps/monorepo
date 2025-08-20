// Dart imports:
import 'dart:convert';

class DatabaseRecord {
  final String id;
  final Map<String, dynamic> data;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const DatabaseRecord({
    required this.id,
    required this.data,
    this.createdAt,
    this.updatedAt,
  });

  String getValue(String field) {
    final value = data[field];
    if (value == null) return '';
    
    if (value is DateTime) {
      return '${value.day}/${value.month}/${value.year}';
    } else if (value is double) {
      return value.toStringAsFixed(2);
    } else if (value is List) {
      return value.join(', ');
    } else if (value is Map) {
      return json.encode(value);
    }
    
    return value.toString();
  }

  bool containsSearchTerm(String searchTerm) {
    final term = searchTerm.toLowerCase();
    
    // Search in ID
    if (id.toLowerCase().contains(term)) return true;
    
    // Search in all data fields
    for (final value in data.values) {
      if (value != null && value.toString().toLowerCase().contains(term)) {
        return true;
      }
    }
    
    return false;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'data': data,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }
}

class DatabaseTableData {
  final List<DatabaseRecord> records;
  final Set<String> fields;
  final String searchTerm;

  const DatabaseTableData({
    required this.records,
    required this.fields,
    this.searchTerm = '',
  });

  List<DatabaseRecord> get filteredRecords {
    if (searchTerm.isEmpty) return records;
    
    return records.where((record) => record.containsSearchTerm(searchTerm)).toList();
  }

  int get totalRecords => records.length;
  int get filteredRecordCount => filteredRecords.length;
  bool get hasRecords => records.isNotEmpty;
  bool get isEmpty => records.isEmpty;
  bool get isFiltered => searchTerm.isNotEmpty;

  List<String> get sortedFields => ['id', ...fields.where((f) => f != 'id').toList()..sort()];

  DatabaseTableData copyWith({
    List<DatabaseRecord>? records,
    Set<String>? fields,
    String? searchTerm,
  }) {
    return DatabaseTableData(
      records: records ?? this.records,
      fields: fields ?? this.fields,
      searchTerm: searchTerm ?? this.searchTerm,
    );
  }

  static DatabaseTableData empty() {
    return const DatabaseTableData(
      records: [],
      fields: {},
      searchTerm: '',
    );
  }
}

class ExportData {
  final String format;
  final String content;
  final String filename;
  final DateTime exportedAt;

  const ExportData({
    required this.format,
    required this.content,
    required this.filename,
    required this.exportedAt,
  });

  bool get isJson => format.toLowerCase() == 'json';
  bool get isCsv => format.toLowerCase() == 'csv';
  
  String get mimeType {
    switch (format.toLowerCase()) {
      case 'json':
        return 'application/json';
      case 'csv':
        return 'text/csv';
      default:
        return 'text/plain';
    }
  }
}
