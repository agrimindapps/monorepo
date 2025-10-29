import 'package:flutter/material.dart';

import '../../../../core/theme/gasometer_colors.dart';
import '../../data/legal_content_service.dart';
import '../widgets/base_legal_page.dart';

class TermsOfServicePage extends BaseLegalPage {
  const TermsOfServicePage({super.key})
    : super(
        title: 'Termos de Uso',
        headerIcon: Icons.description,
        headerTitle: 'Termos de Uso',
        headerGradient: GasometerColors.secondaryGradient,
        footerMessage:
            'Ao usar o Gasometer, você concorda com estes termos. Obrigado por escolher nosso app!',
      );

  @override
  State<TermsOfServicePage> createState() => _TermsOfServicePageState();

  @override
  List<LegalSection> buildSections(BuildContext context, ThemeData theme) {
    return LegalContentService.getTermsOfServiceSections();
  }
}

class _TermsOfServicePageState extends BaseLegalPageState<TermsOfServicePage> {}
