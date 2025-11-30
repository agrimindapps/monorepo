
import '../presentation/widgets/base_legal_page.dart';
import 'services/privacy_policy_content_provider.dart';
import 'services/terms_of_service_content_provider.dart';

/// Service providing legal content for Gasometer
/// Delegates to specialized content providers following SRP

class LegalContentService {

  LegalContentService(
    this._privacyPolicyProvider,
    this._termsOfServiceProvider,
  );
  final PrivacyPolicyContentProvider _privacyPolicyProvider;
  final TermsOfServiceContentProvider _termsOfServiceProvider;

  /// Get privacy policy sections
  List<LegalSection> getPrivacyPolicySections() {
    return _privacyPolicyProvider.getSections();
  }

  /// Get terms of service sections
  List<LegalSection> getTermsOfServiceSections() {
    return _termsOfServiceProvider.getSections();
  }

  /// Get last updated date for privacy policy
  String getPrivacyPolicyLastUpdatedDate() {
    return _privacyPolicyProvider.lastUpdatedDate;
  }

  /// Get last updated date for terms of service
  String getTermsOfServiceLastUpdatedDate() {
    return _termsOfServiceProvider.lastUpdatedDate;
  }
}
