import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/plantis_colors.dart';
import '../../../shared/widgets/base_page_scaffold.dart';
import '../../../shared/widgets/responsive_layout.dart';
import '../providers/license_notifier.dart';

/// Page to display license status and management options
class LicenseStatusPage extends ConsumerWidget {
  const LicenseStatusPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final licenseState = ref.watch(licenseNotifierProvider);

    return BasePageScaffold(
      appBar: AppBar(
        title: const Text('Status da Licença'),
        backgroundColor: PlantisColors.primary,
        foregroundColor: Colors.white,
      ),
      body: ResponsiveLayout(
        child: licenseState.when(
          loading: () => const _LoadingView(),
          error: (error, stack) => _ErrorView(
            error: error.toString(),
            onRetry: () => ref.refresh(licenseNotifierProvider),
          ),
          data: (state) {
            if (state.isLoading) {
              return const _LoadingView();
            }

            if (state.error != null) {
              return _ErrorView(
                error: state.error!,
                onRetry: () => ref.read(licenseNotifierProvider.notifier).refreshLicenseInfo(),
              );
            }

            return _LicenseStatusView(licenseState: state, ref: ref);
          },
        ),
      ),
    );
  }
}

/// Main license status view
class _LicenseStatusView extends StatelessWidget {
  final LicenseState licenseState;
  final WidgetRef ref;

  const _LicenseStatusView({required this.licenseState, required this.ref});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _LicenseStatusCard(licenseState: licenseState),
          const SizedBox(height: 24),
          _FeaturesOverviewCard(licenseState: licenseState, ref: ref),
          const SizedBox(height: 24),
          _ActionsSection(licenseState: licenseState, ref: ref),
          if (kDebugMode) ...[
            const SizedBox(height: 24),
            _DevelopmentTools(licenseState: licenseState, ref: ref),
          ],
        ],
      ),
    );
  }
}

/// License status information card
class _LicenseStatusCard extends StatelessWidget {
  final LicenseState licenseState;

  const _LicenseStatusCard({required this.licenseState});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final licenseInfo = licenseState.licenseInfo;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              licenseState.hasValidLicense
                  ? PlantisColors.primary
                  : Colors.orange,
              licenseState.hasValidLicense
                  ? PlantisColors.primaryDark
                  : Colors.orange.shade700,
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      licenseState.hasValidLicense
                          ? Icons.verified
                          : Icons.schedule,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          licenseState.typeText,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          licenseState.statusText,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _buildDetailRow(
                context,
                'Status',
                licenseState.statusText,
                Icons.info,
              ),
              const SizedBox(height: 12),

              if (licenseState.isTrialActive) ...[
                _buildDetailRow(
                  context,
                  'Tempo restante',
                  licenseState.remainingText,
                  Icons.access_time,
                ),
                const SizedBox(height: 12),
              ],

              if (licenseInfo.license != null) ...[
                _buildDetailRow(
                  context,
                  'ID da Licença',
                  licenseInfo.license!.id,
                  Icons.tag,
                ),
                const SizedBox(height: 12),
                _buildDetailRow(
                  context,
                  'Data de início',
                  _formatDate(licenseInfo.license!.startDate),
                  Icons.calendar_today,
                ),
                const SizedBox(height: 12),
                _buildDetailRow(
                  context,
                  'Data de expiração',
                  _formatDate(licenseInfo.license!.expirationDate),
                  Icons.event,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    return Row(
      children: [
        Icon(icon, color: Colors.white70, size: 16),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: const TextStyle(color: Colors.white70, fontSize: 14),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

/// Features overview card
class _FeaturesOverviewCard extends StatelessWidget {
  final LicenseState licenseState;
  final WidgetRef ref;

  const _FeaturesOverviewCard({required this.licenseState, required this.ref});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.star, color: PlantisColors.primary, size: 24),
                const SizedBox(width: 8),
                Text(
                  'Recursos Disponíveis',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            _buildFeatureItem(
              'Plantas ilimitadas',
              licenseState.hasValidLicense,
              Icons.eco,
            ),
            _buildFeatureItem(
              'Lembretes personalizados',
              licenseState.hasValidLicense,
              Icons.notifications,
            ),
            _buildFeatureItem(
              'Análises avançadas',
              licenseState.hasValidLicense,
              Icons.analytics,
            ),
            _buildFeatureItem(
              'Integração meteorológica',
              licenseState.hasValidLicense,
              Icons.wb_sunny,
            ),
            _buildFeatureItem(
              'Identificação de plantas',
              licenseState.hasValidLicense,
              Icons.camera_alt,
            ),
            _buildFeatureItem(
              'Suporte especializado',
              licenseState.hasValidLicense,
              Icons.support_agent,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureItem(String title, bool available, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color:
                  available
                      ? PlantisColors.primary.withValues(alpha: 0.1)
                      : Colors.grey.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(
              icon,
              color: available ? PlantisColors.primary : Colors.grey,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: available ? Colors.black87 : Colors.grey,
              ),
            ),
          ),
          Icon(
            available ? Icons.check_circle : Icons.lock,
            color: available ? Colors.green : Colors.grey,
            size: 20,
          ),
        ],
      ),
    );
  }
}

/// Actions section
class _ActionsSection extends StatelessWidget {
  final LicenseState licenseState;
  final WidgetRef ref;

  const _ActionsSection({required this.licenseState, required this.ref});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Ações',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            if (!licenseState.isPremiumActive) ...[
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _navigateToPremium(context),
                  icon: const Icon(Icons.workspace_premium),
                  label: const Text('Upgrade para Premium'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: PlantisColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed:
                    licenseState.isLoading
                        ? null
                        : () => ref.read(licenseNotifierProvider.notifier).refreshLicenseInfo(),
                icon: const Icon(Icons.refresh),
                label: const Text('Atualizar Status'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: PlantisColors.primary,
                  side: const BorderSide(color: PlantisColors.primary),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToPremium(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Navegação para página premium'),
        backgroundColor: PlantisColors.primary,
      ),
    );
  }
}

/// Development tools section (debug mode only)
class _DevelopmentTools extends StatelessWidget {
  final LicenseState licenseState;
  final WidgetRef ref;

  const _DevelopmentTools({required this.licenseState, required this.ref});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.developer_mode, color: Colors.orange, size: 24),
                const SizedBox(width: 8),
                Text(
                  'Ferramentas de Desenvolvimento',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.orange,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _showExtendTrialDialog(context),
                icon: const Icon(Icons.add_box),
                label: const Text('Estender Trial'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _showResetLicenseDialog(context),
                icon: const Icon(Icons.restore),
                label: const Text('Resetar Licença'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showExtendTrialDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Estender Trial'),
            content: const Text('Quantos dias adicionar ao trial?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancelar'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  ref.read(licenseNotifierProvider.notifier).extendTrial(30);
                },
                child: const Text('30 dias'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  ref.read(licenseNotifierProvider.notifier).extendTrial(7);
                },
                child: const Text('7 dias'),
              ),
            ],
          ),
    );
  }

  void _showResetLicenseDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Resetar Licença'),
            content: const Text(
              'Isso irá remover a licença atual. Esta ação não pode ser desfeita.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancelar'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  ref.read(licenseNotifierProvider.notifier).resetLicense();
                },
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('Resetar'),
              ),
            ],
          ),
    );
  }
}

/// Loading view
class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: PlantisColors.primary),
          SizedBox(height: 16),
          Text('Carregando informações da licença...'),
        ],
      ),
    );
  }
}

/// Error view
class _ErrorView extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;

  const _ErrorView({required this.error, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Erro ao carregar licença',
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              error,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Tentar Novamente'),
              style: ElevatedButton.styleFrom(
                backgroundColor: PlantisColors.primary,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
