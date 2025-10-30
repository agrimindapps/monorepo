import 'package:equatable/equatable.dart';

/// Represents a section within a legal document
class LegalSection extends Equatable {
  /// Title of the section
  final String title;

  /// Content of the section (supports markdown)
  final String content;

  /// Optional subsections
  final List<LegalSection>? subsections;

  const LegalSection({
    required this.title,
    required this.content,
    this.subsections,
  });

  @override
  List<Object?> get props => [title, content, subsections];

  @override
  String toString() => 'LegalSection(title: $title)';
}
