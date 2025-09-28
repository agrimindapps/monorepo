import 'package:flutter/material.dart';

import '../../../../core/theme/plantis_colors.dart';
import '../../data/legal_content_service.dart';
import '../widgets/base_legal_page.dart';

/// Página de Política de Exclusão de Contas
///
/// Esta página apresenta as informações obrigatórias sobre:
/// - Como solicitar exclusão de conta
/// - Quais dados serão excluídos/retidos
/// - Prazo para conclusão da exclusão
/// - Consequências da exclusão
/// - Alternativas à exclusão
///
/// Conforme requisitos das lojas de aplicativos (Google Play Store e Apple App Store)
class AccountDeletionPage extends BaseLegalPage {
  const AccountDeletionPage({super.key})
    : super(
        title: 'Exclusão de Conta',
        headerIcon: Icons.delete_outline,
        headerTitle: 'Política de Exclusão de Contas',
        headerGradient: PlantisColors.errorGradient,
        footerMessage:
            'A exclusão de conta é irreversível. Certifique-se de fazer backup dos seus dados importantes antes de prosseguir.',
        footerIcon: Icons.warning_amber,
        footerTitle: 'Atenção: Processo Irreversível',
        footerDescription:
            'Uma vez excluída, sua conta e todos os dados associados não poderão ser recuperados. Este processo segue as diretrizes das lojas de aplicativos e legislações de privacidade.',
      );

  @override
  State<AccountDeletionPage> createState() => _AccountDeletionPageState();

  @override
  List<LegalSection> buildSections(BuildContext context, ThemeData theme) {
    return LegalContentService.getAccountDeletionSections();
  }
}

class _AccountDeletionPageState
    extends BaseLegalPageState<AccountDeletionPage> {
  @override
  Color getScrollButtonColor() {
    return PlantisColors.error;
  }
}
