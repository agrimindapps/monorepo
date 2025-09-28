import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/premium_provider.dart';

/// Widget que exibe o status de sincronização premium
///
/// Mostra indicadores visuais para:
/// - Status de sincronização em tempo real
/// - Botão para força sincronização
/// - Indicadores de erro/sucesso
class PremiumSyncStatusWidget extends StatelessWidget {

  const PremiumSyncStatusWidget({
    super.key,
    this.showSyncButton = true,
    this.compact = false,
  });
  final bool showSyncButton;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Consumer<PremiumProvider>(
      builder: (context, premiumProvider, child) {
        if (compact) {
          return _buildCompactView(context, premiumProvider);
        }

        return Card(
          margin: const EdgeInsets.all(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.sync,
                      color: Theme.of(context).primaryColor,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Sincronização Premium',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildStatusInfo(context, premiumProvider),
                if (showSyncButton) ...[
                  const SizedBox(height: 16),
                  _buildSyncButton(context, premiumProvider),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCompactView(BuildContext context, PremiumProvider provider) {
    final isPremium = provider.isPremium;
    final isLoading = provider.isLoading;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isPremium ? Colors.green.shade50 : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isPremium ? Colors.green.shade200 : Colors.grey.shade300,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isLoading)
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Theme.of(context).primaryColor,
              ),
            )
          else
            Icon(
              isPremium ? Icons.verified : Icons.account_circle_outlined,
              size: 16,
              color: isPremium ? Colors.green : Colors.grey,
            ),
          const SizedBox(width: 6),
          Text(
            provider.subscriptionStatus,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: isPremium ? Colors.green.shade700 : Colors.grey.shade700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusInfo(BuildContext context, PremiumProvider provider) {
    return Column(
      children: [
        _buildStatusRow('Status:', provider.subscriptionStatus),
        if (provider.isPremium) ...[
          const SizedBox(height: 8),
          _buildStatusRow(
            'Fonte:',
            _getPremiumSourceLabel(provider.premiumSource),
          ),
          if (provider.expirationDate != null) ...[
            const SizedBox(height: 8),
            _buildStatusRow(
              'Expira em:',
              _formatDate(provider.expirationDate!),
            ),
          ],
        ],
        const SizedBox(height: 16),
        _buildSyncStatusStream(context, provider),
      ],
    );
  }

  Widget _buildStatusRow(String label, String value) {
    return Row(
      children: [
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              color: Colors.grey,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSyncStatusStream(BuildContext context, PremiumProvider provider) {
    return StreamBuilder<String>(
      stream: provider.syncStatus,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox.shrink();
        }

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.blue.shade200),
          ),
          child: Row(
            children: [
              Icon(
                Icons.info_outline,
                size: 16,
                color: Colors.blue.shade600,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  snapshot.data!,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.blue.shade700,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSyncButton(BuildContext context, PremiumProvider provider) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: provider.isLoading ? null : provider.syncAcrossDevices,
        icon: provider.isLoading
            ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.sync),
        label: Text(
          provider.isLoading ? 'Sincronizando...' : 'Sincronizar Agora',
        ),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );
  }

  String _getPremiumSourceLabel(String source) {
    switch (source) {
      case 'revenue_cat':
        return 'RevenueCat';
      case 'local_license':
        return 'Licença Local';
      case 'firebase':
        return 'Nuvem';
      default:
        return source;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }
}

/// Widget minimalista para mostrar status de sync na AppBar
class PremiumSyncIndicator extends StatelessWidget {
  const PremiumSyncIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<PremiumProvider>(
      builder: (context, provider, child) {
        return GestureDetector(
          onTap: () {
            _showSyncDialog(context, provider);
          },
          child: Container(
            margin: const EdgeInsets.only(right: 8),
            child: StreamBuilder<String>(
              stream: provider.syncStatus,
              builder: (context, snapshot) {
                final isSync = snapshot.hasData &&
                    snapshot.data!.contains('Sincronização');

                return Stack(
                  children: [
                    Icon(
                      provider.isPremium ? Icons.verified : Icons.sync,
                      color: provider.isPremium ? Colors.green : Colors.grey,
                    ),
                    if (isSync)
                      Positioned(
                        right: 0,
                        top: 0,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Colors.orange,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }

  void _showSyncDialog(BuildContext context, PremiumProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Status de Sincronização'),
        content: const PremiumSyncStatusWidget(showSyncButton: false),
        actions: [
          TextButton(
            onPressed: provider.syncAcrossDevices,
            child: const Text('Sincronizar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }
}