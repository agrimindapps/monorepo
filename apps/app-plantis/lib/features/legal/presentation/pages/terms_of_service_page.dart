import 'package:flutter/material.dart';
import '../../../../core/theme/plantis_colors.dart';
import '../widgets/base_legal_page.dart';
import '../../data/legal_content_service.dart';

class TermsOfServicePage extends BaseLegalPage {
  const TermsOfServicePage({super.key})
      : super(
          title: 'Termos de Uso',
          headerIcon: Icons.description,
          headerTitle: 'Termos de Uso do Plantis',
          headerGradient: PlantisColors.primaryGradient,
          footerMessage:
              'Ao usar o Plantis, você confirma que leu, compreendeu e aceita estes Termos de Uso.',
        );

  @override
  State<TermsOfServicePage> createState() => _TermsOfServicePageState();

  @override
  List<LegalSection> buildSections(BuildContext context, ThemeData theme) {
    return LegalContentService.getTermsOfServiceSections();
  }
}

class _TermsOfServicePageState extends BaseLegalPageState<TermsOfServicePage> {
  @override
  Color getScrollButtonColor() {
    return PlantisColors.primary;
  }
}