import '../../domain/entities/legal_document_entity.dart';

class LegalDocumentModel extends LegalDocumentEntity {
  const LegalDocumentModel({
    required super.id,
    required super.type,
    required super.title,
    required super.content,
    required super.version,
    required super.effectiveDate,
    super.lastModified,
  });

  factory LegalDocumentModel.fromJson(Map<String, dynamic> json) {
    return LegalDocumentModel(
      id: json['id'] as String,
      type: _typeFromString(json['type'] as String),
      title: json['title'] as String,
      content: json['content'] as String,
      version: json['version'] as String,
      effectiveDate: DateTime.parse(json['effectiveDate'] as String),
      lastModified: json['lastModified'] != null
          ? DateTime.parse(json['lastModified'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': _typeToString(type),
      'title': title,
      'content': content,
      'version': version,
      'effectiveDate': effectiveDate.toIso8601String(),
      'lastModified': lastModified?.toIso8601String(),
    };
  }

  static LegalDocumentType _typeFromString(String type) {
    switch (type) {
      case 'terms_of_service':
        return LegalDocumentType.termsOfService;
      case 'privacy_policy':
        return LegalDocumentType.privacyPolicy;
      case 'cookie_policy':
        return LegalDocumentType.cookiePolicy;
      case 'user_agreement':
        return LegalDocumentType.userAgreement;
      default:
        return LegalDocumentType.termsOfService;
    }
  }

  static String _typeToString(LegalDocumentType type) {
    switch (type) {
      case LegalDocumentType.termsOfService:
        return 'terms_of_service';
      case LegalDocumentType.privacyPolicy:
        return 'privacy_policy';
      case LegalDocumentType.cookiePolicy:
        return 'cookie_policy';
      case LegalDocumentType.userAgreement:
        return 'user_agreement';
    }
  }

  factory LegalDocumentModel.fromEntity(LegalDocumentEntity entity) {
    return LegalDocumentModel(
      id: entity.id,
      type: entity.type,
      title: entity.title,
      content: entity.content,
      version: entity.version,
      effectiveDate: entity.effectiveDate,
      lastModified: entity.lastModified,
    );
  }
}
