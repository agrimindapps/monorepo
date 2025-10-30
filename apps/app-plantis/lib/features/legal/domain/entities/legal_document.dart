import 'package:equatable/equatable.dart';

import 'document_type.dart';
import 'legal_section.dart';

/// Represents a complete legal document with metadata
class LegalDocument extends Equatable {
  /// Unique identifier for the document
  final String id;

  /// Type of document (privacy policy, terms of service, etc.)
  final DocumentType type;

  /// Title of the document
  final String title;

  /// Date when the document was last updated
  final DateTime lastUpdated;

  /// List of sections that compose the document
  final List<LegalSection> sections;

  /// Optional version number for tracking changes
  final String? version;

  const LegalDocument({
    required this.id,
    required this.type,
    required this.title,
    required this.lastUpdated,
    required this.sections,
    this.version,
  });

  /// Get formatted date string
  String get formattedDate {
    return '${lastUpdated.day.toString().padLeft(2, '0')}/'
        '${lastUpdated.month.toString().padLeft(2, '0')}/'
        '${lastUpdated.year}';
  }

  /// Check if document has been recently updated (within 30 days)
  bool get isRecentlyUpdated {
    final now = DateTime.now();
    final difference = now.difference(lastUpdated);
    return difference.inDays <= 30;
  }

  @override
  List<Object?> get props => [id, type, title, lastUpdated, sections, version];

  @override
  String toString() =>
      'LegalDocument(type: ${type.displayName}, '
      'lastUpdated: $formattedDate)';
}
