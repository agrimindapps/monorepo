
/// Service responsible for account deletion business logic
/// Follows SRP by handling only account deletion operations

class AccountDeletionService {
  /// Validate if user can delete account
  AccountDeletionValidation validateDeletion({
    required bool isAuthenticated,
    required bool confirmationChecked,
  }) {
    if (!isAuthenticated) {
      return AccountDeletionValidation(
        canDelete: false,
        errorMessage: 'Você precisa estar autenticado para deletar sua conta.',
      );
    }

    if (!confirmationChecked) {
      return AccountDeletionValidation(
        canDelete: false,
        errorMessage:
            'Você precisa confirmar que leu e entendeu as consequências.',
      );
    }

    return AccountDeletionValidation(canDelete: true);
  }

  /// Get deletion consequences
  List<DeletionConsequence> getDeletionConsequences() {
    return [
      DeletionConsequence(
        icon: '🗑️',
        title: 'Dados Permanentemente Deletados',
        description:
            'Todos os seus dados (veículos, abastecimentos, manutenções) serão permanentemente removidos em até 30 dias.',
      ),
      DeletionConsequence(
        icon: '⏰',
        title: 'Período de Retenção',
        description:
            'Por questões legais e de segurança, seus dados ficarão em quarentena por 30 dias antes da exclusão definitiva.',
      ),
      DeletionConsequence(
        icon: '🔐',
        title: 'Acesso Bloqueado',
        description:
            'Você não poderá mais acessar sua conta imediatamente após a confirmação.',
      ),
      DeletionConsequence(
        icon: '🔄',
        title: 'Sem Recuperação',
        description:
            'Após o período de 30 dias, não será possível recuperar seus dados de forma alguma.',
      ),
    ];
  }

  /// Get what will be deleted
  List<DataCategory> getDeletedDataCategories() {
    return [
      DataCategory(
        icon: '🚗',
        title: 'Veículos',
        description: 'Todos os veículos cadastrados',
      ),
      DataCategory(
        icon: '⛽',
        title: 'Abastecimentos',
        description: 'Histórico completo de abastecimentos',
      ),
      DataCategory(
        icon: '🔧',
        title: 'Manutenções',
        description: 'Registros de manutenções e revisões',
      ),
      DataCategory(
        icon: '💰',
        title: 'Despesas',
        description: 'Histórico de gastos e despesas',
      ),
      DataCategory(
        icon: '📊',
        title: 'Relatórios',
        description: 'Estatísticas e análises geradas',
      ),
      DataCategory(
        icon: '🔔',
        title: 'Lembretes',
        description: 'Lembretes e notificações configuradas',
      ),
      DataCategory(
        icon: '👤',
        title: 'Perfil',
        description: 'Informações pessoais e configurações',
      ),
      DataCategory(
        icon: '☁️',
        title: 'Backup',
        description: 'Backups na nuvem',
      ),
    ];
  }

  /// Get third party services affected
  List<ThirdPartyService> getAffectedThirdPartyServices() {
    return [
      ThirdPartyService(
        name: 'Google Authentication',
        description:
            'A conexão com sua conta Google será removida. Você poderá usar o Google novamente em um novo cadastro.',
      ),
      ThirdPartyService(
        name: 'Firebase',
        description:
            'Todos os dados armazenados no Firebase serão permanentemente deletados após 30 dias.',
      ),
      ThirdPartyService(
        name: 'Apple Sign In',
        description: 'Se você usou Apple Sign In, a autorização será revogada.',
      ),
    ];
  }

  /// Get deletion process steps
  List<DeletionStep> getDeletionProcessSteps() {
    return [
      DeletionStep(
        step: 1,
        title: 'Leia Atentamente',
        description:
            'Leia todas as informações sobre o que será deletado e as consequências.',
      ),
      DeletionStep(
        step: 2,
        title: 'Marque a Confirmação',
        description:
            'Marque o checkbox confirmando que você leu e entendeu as consequências.',
      ),
      DeletionStep(
        step: 3,
        title: 'Confirme sua Identidade',
        description:
            'Se solicitado, forneça sua senha atual para confirmar sua identidade.',
      ),
      DeletionStep(
        step: 4,
        title: 'Confirmação Final',
        description:
            'Clique no botão de deletar e confirme na caixa de diálogo final.',
      ),
      DeletionStep(
        step: 5,
        title: 'Processamento',
        description:
            'Sua conta será desativada imediatamente e os dados deletados em até 30 dias.',
      ),
    ];
  }

  /// Get contact support info
  ContactSupportInfo getContactSupport() {
    return ContactSupportInfo(
      title: 'Precisa de Ajuda?',
      description:
          'Se você tiver dúvidas ou precisar de suporte antes de deletar sua conta, entre em contato conosco.',
      email: 'suporte@gasometer.app',
      expectedResponseTime: '24-48 horas',
    );
  }

  /// Check if requires password authentication
  bool requiresPasswordAuth({required bool isAnonymous}) {
    return !isAnonymous;
  }

  /// Get deletion confirmation message
  String getConfirmationMessage() {
    return 'Esta ação não pode ser desfeita. Todos os seus dados serão '
        'permanentemente deletados em até 30 dias.\n\n'
        'Deseja realmente prosseguir com a exclusão da conta?';
  }

  /// Get deletion success message
  String getSuccessMessage() {
    return 'Conta deletada com sucesso. Você será redirecionado para a tela inicial.';
  }

  /// Get retention period in days
  int getRetentionPeriodDays() {
    return 30;
  }
}

// Models

class AccountDeletionValidation {
  final bool canDelete;
  final String? errorMessage;

  AccountDeletionValidation({required this.canDelete, this.errorMessage});
}

class DeletionConsequence {
  final String icon;
  final String title;
  final String description;

  DeletionConsequence({
    required this.icon,
    required this.title,
    required this.description,
  });
}

class DataCategory {
  final String icon;
  final String title;
  final String description;

  DataCategory({
    required this.icon,
    required this.title,
    required this.description,
  });
}

class ThirdPartyService {
  final String name;
  final String description;

  ThirdPartyService({required this.name, required this.description});
}

class DeletionStep {
  final int step;
  final String title;
  final String description;

  DeletionStep({
    required this.step,
    required this.title,
    required this.description,
  });
}

class ContactSupportInfo {
  final String title;
  final String description;
  final String email;
  final String expectedResponseTime;

  ContactSupportInfo({
    required this.title,
    required this.description,
    required this.email,
    required this.expectedResponseTime,
  });
}
