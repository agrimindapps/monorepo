import '../../domain/entities/legal_section.dart';

/// Model for LegalSection that can be converted from/to JSON
class LegalSectionModel {
  final String title;
  final String content;
  final List<LegalSectionModel>? subsections;

  const LegalSectionModel({
    required this.title,
    required this.content,
    this.subsections,
  });

  /// Creates a LegalSectionModel from a Map
  factory LegalSectionModel.fromMap(Map<String, dynamic> map) {
    return LegalSectionModel(
      title: map['title'] as String? ?? '',
      content: map['content'] as String? ?? '',
      subsections: map['subsections'] != null
          ? (map['subsections'] as List)
                .map(
                  (e) => LegalSectionModel.fromMap(e as Map<String, dynamic>),
                )
                .toList()
          : null,
    );
  }

  /// Converts to domain entity
  LegalSection toEntity() {
    return LegalSection(
      title: title,
      content: content,
      subsections: subsections?.map((s) => s.toEntity()).toList(),
    );
  }

  /// Converts to Map
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'content': content,
      if (subsections != null)
        'subsections': subsections!.map((s) => s.toMap()).toList(),
    };
  }
}
