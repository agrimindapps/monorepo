import 'package:flutter/material.dart';

import '../../../../core/theme/gasometer_colors.dart';
import '../../data/services/account_deletion_policy_content_provider.dart';
import '../widgets/base_legal_page.dart';

class AccountDeletionPolicyPage extends BaseLegalPage {
  const AccountDeletionPolicyPage({super.key})
    : super(
        title: 'Política de Exclusão de Conta',
        headerIcon: Icons.delete_forever,
        headerTitle: 'Política de Exclusão de Conta',
        headerGradient: GasometerColors.errorGradient,
        footerMessage:
            'Respeitamos seu direito de excluir seus dados. Estamos aqui para ajudar se tiver dúvidas.',
      );

  @override
  State<AccountDeletionPolicyPage> createState() =>
      _AccountDeletionPolicyPageState();

  @override
  List<LegalSection> buildSections(BuildContext context, ThemeData theme) {
    final provider = AccountDeletionPolicyContentProvider();
    return provider.getSections();
  }
}

class _AccountDeletionPolicyPageState
    extends BaseLegalPageState<AccountDeletionPolicyPage> {}
