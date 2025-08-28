import 'package:flutter/material.dart';
import '../../../../core/theme/plantis_colors.dart';
import '../widgets/base_legal_page.dart';
import '../../data/legal_content_service.dart';

class PrivacyPolicyPage extends BaseLegalPage {
  const PrivacyPolicyPage({super.key})
      : super(
          title: 'Política de Privacidade',
          headerIcon: Icons.privacy_tip,
          headerTitle: 'Política de Privacidade',
          headerGradient: PlantisColors.secondaryGradient,
          footerMessage: '',
          footerIcon: Icons.verified_user,
          footerTitle: 'Sua privacidade é nossa prioridade',
          footerDescription:
              'Estamos comprometidos em proteger suas informações pessoais com os mais altos padrões de segurança e transparência.',
        );

  @override
  State<PrivacyPolicyPage> createState() => _PrivacyPolicyPageState();

  @override
  List<LegalSection> buildSections(BuildContext context, ThemeData theme) {
    return LegalContentService.getPrivacyPolicySections();
  }
}

class _PrivacyPolicyPageState extends BaseLegalPageState<PrivacyPolicyPage> {
  @override
  Color getScrollButtonColor() {
    return PlantisColors.secondary;
  }
}