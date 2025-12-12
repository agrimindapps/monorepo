import 'package:flutter/material.dart';

import '../widgets/privacy_policy/privacy_changes_section.dart';
import '../widgets/privacy_policy/privacy_children_section.dart';
import '../widgets/privacy_policy/privacy_contact_section.dart';
import '../widgets/privacy_policy/privacy_cookies_section.dart';
import '../widgets/privacy_policy/privacy_footer_section.dart';
import '../widgets/privacy_policy/privacy_header_section.dart';
import '../widgets/privacy_policy/privacy_info_collection_section.dart';
import '../widgets/privacy_policy/privacy_intro_section.dart';
import '../widgets/privacy_policy/privacy_links_section.dart';
import '../widgets/privacy_policy/privacy_log_data_section.dart';
import '../widgets/privacy_policy/privacy_navigation_menu.dart';
import '../widgets/privacy_policy/privacy_security_section.dart';
import '../widgets/privacy_policy/privacy_service_providers_section.dart';

class PrivacyPolicyPage extends StatefulWidget {
  const PrivacyPolicyPage({super.key});

  @override
  State<PrivacyPolicyPage> createState() => _PrivacyPolicyPageState();
}

class _PrivacyPolicyPageState extends State<PrivacyPolicyPage> {
  final scrollController = ScrollController();
  final GlobalKey _introSection = GlobalKey();
  final GlobalKey _coletaSection = GlobalKey();
  final GlobalKey _logDataSection = GlobalKey();
  final GlobalKey _cookiesSection = GlobalKey();
  final GlobalKey _providersSection = GlobalKey();
  final GlobalKey _securitySection = GlobalKey();
  final GlobalKey _linksSection = GlobalKey();
  final GlobalKey _childrenSection = GlobalKey();
  final GlobalKey _changesSection = GlobalKey();
  final GlobalKey _contactSection = GlobalKey();

  void _scrollToSection(GlobalKey key) {
    final context = key.currentContext;
    if (context != null) {
      Scrollable.ensureVisible(
        context,
        duration: const Duration(milliseconds: 800),
        curve: Curves.easeInOut,
      );
    }
  }

  void _handleSectionSelected(String section) {
    switch (section) {
      case 'intro':
        _scrollToSection(_introSection);
        break;
      case 'coleta':
        _scrollToSection(_coletaSection);
        break;
      case 'logdata':
        _scrollToSection(_logDataSection);
        break;
      case 'cookies':
        _scrollToSection(_cookiesSection);
        break;
      case 'providers':
        _scrollToSection(_providersSection);
        break;
      case 'security':
        _scrollToSection(_securitySection);
        break;
      case 'links':
        _scrollToSection(_linksSection);
        break;
      case 'children':
        _scrollToSection(_childrenSection);
        break;
      case 'changes':
        _scrollToSection(_changesSection);
        break;
      case 'contact':
        _scrollToSection(_contactSection);
        break;
    }
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          SingleChildScrollView(
            controller: scrollController,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const PrivacyHeaderSection(),
                PrivacyIntroSection(key: _introSection),
                PrivacyInfoCollectionSection(key: _coletaSection),
                PrivacyLogDataSection(key: _logDataSection),
                PrivacyCookiesSection(key: _cookiesSection),
                PrivacyServiceProvidersSection(key: _providersSection),
                PrivacySecuritySection(key: _securitySection),
                PrivacyLinksSection(key: _linksSection),
                PrivacyChildrenSection(key: _childrenSection),
                PrivacyChangesSection(key: _changesSection),
                PrivacyContactSection(key: _contactSection),
                const PrivacyFooterSection(),
              ],
            ),
          ),
          PrivacyNavigationMenu(onSectionSelected: _handleSectionSelected),
        ],
      ),
    );
  }
}
