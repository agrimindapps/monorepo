/// Types of legal documents available in the app
enum DocumentType {
  /// Privacy Policy document
  privacyPolicy('privacy_policy', 'Política de Privacidade'),

  /// Terms of Service document
  termsOfService('terms_of_service', 'Termos de Serviço'),

  /// Account Deletion Policy document
  accountDeletion('account_deletion', 'Política de Exclusão de Conta'),

  /// Cookies Policy document
  cookiesPolicy('cookies_policy', 'Política de Cookies');

  const DocumentType(this.id, this.displayName);

  /// Unique identifier for the document type
  final String id;

  /// User-friendly display name
  final String displayName;

  /// Get DocumentType from string id
  static DocumentType fromId(String id) {
    return DocumentType.values.firstWhere(
      (type) => type.id == id,
      orElse: () => DocumentType.privacyPolicy,
    );
  }
}
