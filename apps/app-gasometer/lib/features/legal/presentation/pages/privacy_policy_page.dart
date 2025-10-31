import 'package:flutter/material.dart';

import '../../../../core/theme/gasometer_colors.dart';
import '../../data/services/privacy_policy_content_provider.dart';
import '../widgets/base_legal_page.dart';

class PrivacyPolicyPage extends BaseLegalPage {
  const PrivacyPolicyPage({super.key})
    : super(
        title: 'Política de Privacidade',
        headerIcon: Icons.privacy_tip,
        headerTitle: 'Política de Privacidade',
        headerGradient: GasometerColors.primaryGradient,
        footerMessage:
            'Sua privacidade é nossa prioridade. Estamos comprometidos em proteger suas informações.',
      );

  @override
  State<PrivacyPolicyPage> createState() => _PrivacyPolicyPageState();

  @override
  List<LegalSection> buildSections(BuildContext context, ThemeData theme) {
    final provider = PrivacyPolicyContentProvider();
    return provider.getSections();
  }
}

class _PrivacyPolicyPageState extends BaseLegalPageState<PrivacyPolicyPage> {}
