import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/data_export_provider.dart';

class ExportAvailabilityWidget extends StatelessWidget {
  final VoidCallback? onExportPressed;

  const ExportAvailabilityWidget({
    Key? key,
    this.onExportPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<DataExportProvider>(
      builder: (context, provider, child) {
        if (provider.isCheckingAvailability) {
          return _buildLoadingWidget(context);
        }

        if (provider.hasAvailabilityError) {
          return _buildErrorWidget(context, provider.availabilityError!);
        }

        if (provider.availabilityResult == null) {
          return _buildInitialWidget(context, provider);
        }

        if (provider.canExport) {
          return _buildCanExportWidget(context);
        }

        return _buildRateLimitedWidget(context, provider);
      },
    );
  }

  Widget _buildLoadingWidget(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Text(
                'Verificando disponibilidade...',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorWidget(BuildContext context, String error) {
    return Card(
      color: Theme.of(context).colorScheme.errorContainer,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.error_outline,
                  color: Theme.of(context).colorScheme.onErrorContainer,
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Erro ao verificar disponibilidade',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: Theme.of(context).colorScheme.onErrorContainer,
                        ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Text(
              error,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onErrorContainer,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInitialWidget(BuildContext context, DataExportProvider provider) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Exportar Meus Dados',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            SizedBox(height: 8),
            Text(
              'Baixe uma cópia de todos os seus dados pessoais armazenados no aplicativo.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: provider.checkExportAvailability,
              icon: Icon(Icons.download_outlined),
              label: Text('Verificar Disponibilidade'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCanExportWidget(BuildContext context) {
    return Card(
      color: Theme.of(context).colorScheme.secondaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.check_circle_outline,
                  color: Theme.of(context).colorScheme.onSecondaryContainer,
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Export Disponível',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSecondaryContainer,
                        ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Text(
              'Você pode exportar seus dados agora. O processo pode levar alguns minutos.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSecondaryContainer,
                  ),
            ),
            SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: onExportPressed,
              icon: Icon(Icons.file_download_outlined),
              label: Text('Exportar Dados'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRateLimitedWidget(BuildContext context, DataExportProvider provider) {
    final timeUntilNext = provider.timeUntilNextExport;
    String timeMessage = '';

    if (timeUntilNext != null) {
      if (timeUntilNext.inHours > 0) {
        timeMessage = 'Próximo export disponível em ${timeUntilNext.inHours}h ${timeUntilNext.inMinutes % 60}min';
      } else if (timeUntilNext.inMinutes > 0) {
        timeMessage = 'Próximo export disponível em ${timeUntilNext.inMinutes}min';
      } else {
        timeMessage = 'Próximo export disponível em breve';
      }
    }

    return Card(
      color: Theme.of(context).colorScheme.surfaceVariant,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.schedule_outlined,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Export Limitado',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Text(
              'Por questões de segurança, você pode exportar seus dados apenas uma vez por dia.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            if (timeMessage.isNotEmpty) ...[
              SizedBox(height: 8),
              Text(
                timeMessage,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w500,
                    ),
              ),
            ],
            SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: provider.checkExportAvailability,
              icon: Icon(Icons.refresh_outlined),
              label: Text('Verificar Novamente'),
            ),
          ],
        ),
      ),
    );
  }
}