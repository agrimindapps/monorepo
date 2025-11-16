import 'package:equatable/equatable.dart';

enum LegalDocumentType {
  termsOfService,
  privacyPolicy,
  cookiePolicy,
  userAgreement,
}

class LegalDocumentEntity extends Equatable {
  final String id;
  final LegalDocumentType type;
  final String title;
  final String content;
  final String version;
  final DateTime effectiveDate;
  final DateTime? lastModified;

  const LegalDocumentEntity({
    required this.id,
    required this.type,
    required this.title,
    required this.content,
    required this.version,
    required this.effectiveDate,
    this.lastModified,
  });

  @override
  List<Object?> get props => [
        id,
        type,
        title,
        content,
        version,
        effectiveDate,
        lastModified,
      ];
}
