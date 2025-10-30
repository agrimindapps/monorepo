import '../../domain/entities/document_type.dart';
import '../../domain/entities/legal_document.dart';
import 'legal_section_model.dart';

/// Model for LegalDocument that can be converted from/to JSON
class LegalDocumentModel {
  final String id;
  final DocumentType type;
  final String title;
  final DateTime lastUpdated;
  final List<LegalSectionModel> sections;
  final String? version;

  const LegalDocumentModel({
    required this.id,
    required this.type,
    required this.title,
    required this.lastUpdated,
    required this.sections,
    this.version,
  });

  /// Creates a LegalDocumentModel from a Map
  factory LegalDocumentModel.fromMap(
    Map<String, dynamic> map,
    DocumentType type,
  ) {
    return LegalDocumentModel(
      id: map['id'] as String? ?? type.id,
      type: type,
      title: map['title'] as String? ?? type.displayName,
      lastUpdated: map['lastUpdated'] != null
          ? DateTime.parse(map['lastUpdated'] as String)
          : DateTime.now(),
      sections:
          (map['sections'] as List?)
              ?.map((e) => LegalSectionModel.fromMap(e as Map<String, dynamic>))
              .toList() ??
          [],
      version: map['version'] as String?,
    );
  }

  /// Converts to domain entity
  LegalDocument toEntity() {
    return LegalDocument(
      id: id,
      type: type,
      title: title,
      lastUpdated: lastUpdated,
      sections: sections.map((s) => s.toEntity()).toList(),
      version: version,
    );
  }

  /// Converts to Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type.id,
      'title': title,
      'lastUpdated': lastUpdated.toIso8601String(),
      'sections': sections.map((s) => s.toMap()).toList(),
      if (version != null) 'version': version,
    };
  }
}
