import 'package:flutter/material.dart';

/// Diálogo de confirmação LGPD/GDPR para exclusão de conta
/// Exibe informações legais e requer consentimento explícito do usuário
class AccountDeletionConfirmationDialog extends StatefulWidget {
  final String appName;
  final VoidCallback onConfirmed;
  final VoidCallback? onCancelled;
  final Map<String, dynamic>? dataPreview;
  final bool hasActiveSubscription;
  final String? subscriptionMessage;

  const AccountDeletionConfirmationDialog({
    super.key,
    required this.appName,
    required this.onConfirmed,
    this.onCancelled,
    this.dataPreview,
    this.hasActiveSubscription = false,
    this.subscriptionMessage,
  });

  @override
  State<AccountDeletionConfirmationDialog> createState() =>
      _AccountDeletionConfirmationDialogState();
}

class _AccountDeletionConfirmationDialogState
    extends State<AccountDeletionConfirmationDialog> {
  bool _hasReadInformation = false;
  bool _acknowledgesConsequences = false;
  bool _confirmsUnderstanding = false;
  final ScrollController _scrollController = ScrollController();

  bool get _canConfirm =>
      _hasReadInformation && _acknowledgesConsequences && _confirmsUnderstanding;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 50) {
      if (!_hasReadInformation) {
        setState(() => _hasReadInformation = true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.policy, color: Theme.of(context).colorScheme.error),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Direito ao Esquecimento',
              style: TextStyle(fontSize: 18),
            ),
          ),
        ],
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: SingleChildScrollView(
                controller: _scrollController,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInfoSection(
                      icon: Icons.info_outline,
                      title: 'LGPD/GDPR - Lei Geral de Proteção de Dados',
                      content: Text(
                          'Você tem o direito de solicitar a exclusão de seus dados '
                          'pessoais de acordo com a LGPD (Lei 13.709/2018) e GDPR. '
                          'Esta ação é permanente e não pode ser desfeita.'),
                      color: Colors.blue,
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.orange.withOpacity(0.3)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.delete_forever, color: Colors.orange, size: 20),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'O que será excluído',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.orange.withOpacity(0.9),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          _buildDeletionList(),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.red.withOpacity(0.3)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.warning_amber, color: Colors.red, size: 20),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Consequências Importantes',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.red.withOpacity(0.9),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          _buildConsequencesList(),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (widget.hasActiveSubscription) ...[
                      _buildSubscriptionWarning(),
                      const SizedBox(height: 16),
                    ],
                    _buildDataPreview(),
                    const SizedBox(height: 16),
                    _buildLegalNotice(),
                    const SizedBox(height: 24),
                    if (!_hasReadInformation)
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.amber.shade50,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.arrow_downward,
                                color: Colors.amber.shade700),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Role até o final para continuar',
                                style: TextStyle(color: Colors.amber.shade700),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            _buildConfirmationCheckboxes(),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            widget.onCancelled?.call();
            Navigator.of(context).pop();
          },
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _canConfirm
              ? () {
                  Navigator.of(context).pop();
                  widget.onConfirmed();
                }
              : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.error,
            foregroundColor: Colors.white,
          ),
          child: const Text('Confirmar Exclusão'),
        ),
      ],
    );
  }

  Widget _buildInfoSection({
    required IconData icon,
    required String title,
    required Widget content,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: color.withOpacity(0.9),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          content,
        ],
      ),
    );
  }

  Widget _buildDeletionList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildBulletPoint('Sua conta de usuário no ${widget.appName}'),
        _buildBulletPoint('Todos os seus dados armazenados localmente'),
        _buildBulletPoint('Todos os seus dados na nuvem (Firestore)'),
        _buildBulletPoint('Arquivos e imagens no Storage'),
        _buildBulletPoint('Configurações e preferências do app'),
        _buildBulletPoint('Histórico e registros de atividades'),
      ],
    );
  }

  Widget _buildConsequencesList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildBulletPoint('⚠️ Esta ação é IRREVERSÍVEL'),
        _buildBulletPoint('⚠️ Você perderá TODOS os seus dados'),
        _buildBulletPoint('⚠️ Não será possível recuperar sua conta'),
        _buildBulletPoint('⚠️ Você precisará criar uma nova conta para usar o app'),
        if (widget.hasActiveSubscription)
          _buildBulletPoint(
              '⚠️ Assinaturas devem ser canceladas manualmente na loja',
              isWarning: true),
      ],
    );
  }

  Widget _buildSubscriptionWarning() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.credit_card, color: Colors.red.shade700, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'ASSINATURA ATIVA DETECTADA',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.red.shade700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            widget.subscriptionMessage ??
                'Você possui uma assinatura ativa. '
                    'A exclusão da conta NÃO cancela automaticamente sua assinatura. '
                    'Você deve cancelar manualmente através da App Store ou Google Play.',
            style: TextStyle(color: Colors.red.shade700),
          ),
        ],
      ),
    );
  }

  Widget _buildDataPreview() {
    if (widget.dataPreview == null) return const SizedBox.shrink();

    final localData = widget.dataPreview!['localData'] as Map<String, dynamic>?;
    final cloudData = widget.dataPreview!['cloudData'] as Map<String, dynamic>?;

    if (localData == null && cloudData == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.storage, color: Colors.grey.shade700, size: 20),
              const SizedBox(width: 8),
              Text(
                'Resumo dos Dados',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (localData != null) ...[
            Text('Dados Locais: ${localData['stats']?['totalRecords'] ?? 0} registros'),
          ],
          if (cloudData != null) ...[
            Text('Dados na Nuvem: ${cloudData['totalDocuments'] ?? 0} documentos'),
          ],
        ],
      ),
    );
  }

  Widget _buildLegalNotice() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.gavel, color: Colors.grey.shade700, size: 20),
              const SizedBox(width: 8),
              Text(
                'Aviso Legal',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Alguns dados podem ser mantidos por obrigações legais '
            '(fiscal, contábil) pelo período exigido por lei. '
            'Dados anonimizados podem ser mantidos para fins estatísticos.',
            style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
          ),
        ],
      ),
    );
  }

  Widget _buildConfirmationCheckboxes() {
    return Column(
      children: [
        CheckboxListTile(
          value: _acknowledgesConsequences,
          enabled: _hasReadInformation,
          onChanged: (value) =>
              setState(() => _acknowledgesConsequences = value ?? false),
          title: const Text(
            'Estou ciente que esta ação é IRREVERSÍVEL',
            style: TextStyle(fontSize: 13),
          ),
          controlAffinity: ListTileControlAffinity.leading,
          dense: true,
          contentPadding: EdgeInsets.zero,
        ),
        CheckboxListTile(
          value: _confirmsUnderstanding,
          enabled: _hasReadInformation,
          onChanged: (value) =>
              setState(() => _confirmsUnderstanding = value ?? false),
          title: const Text(
            'Confirmo que li e entendi todas as consequências',
            style: TextStyle(fontSize: 13),
          ),
          controlAffinity: ListTileControlAffinity.leading,
          dense: true,
          contentPadding: EdgeInsets.zero,
        ),
      ],
    );
  }

  Widget _buildBulletPoint(String text, {bool isWarning = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '• ',
            style: TextStyle(
              fontWeight: isWarning ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontWeight: isWarning ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
