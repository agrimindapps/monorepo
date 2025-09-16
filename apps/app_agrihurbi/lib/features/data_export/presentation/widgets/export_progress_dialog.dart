import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/data_export_provider.dart';

class ExportProgressDialog extends StatelessWidget {
  const ExportProgressDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<DataExportProvider>(
      builder: (context, provider, child) {
        final progress = provider.exportProgress;

        if (progress == null) {
          return _buildInitialState(context);
        }

        if (progress.hasError) {
          return _buildErrorState(context, progress.error!, provider);
        }

        if (progress.isCompleted) {
          return _buildCompletedState(context, provider);
        }

        return _buildProgressState(context, progress, provider);
      },
    );
  }

  Widget _buildInitialState(BuildContext context) {
    return AlertDialog(
      title: Text('Exportando Dados'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Preparando exportação...'),
        ],
      ),
    );
  }

  Widget _buildProgressState(
    BuildContext context,
    ExportProgress progress,
    DataExportProvider provider,
  ) {
    return AlertDialog(
      title: Text('Exportando Dados'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Progress bar
          LinearProgressIndicator(
            value: progress.percentage,
            backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
          ),
          SizedBox(height: 16),

          // Current task
          Text(
            progress.currentTask,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          SizedBox(height: 8),

          // Progress counter
          Text(
            '${progress.current} de ${progress.total} etapas concluídas',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            provider.cancelExport();
            Navigator.of(context).pop();
          },
          child: Text('Cancelar'),
        ),
      ],
    );
  }

  Widget _buildCompletedState(
    BuildContext context,
    DataExportProvider provider,
  ) {
    return AlertDialog(
      title: Row(
        children: [
          Icon(
            Icons.check_circle,
            color: Colors.green,
          ),
          SizedBox(width: 8),
          Text('Export Concluído'),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Seus dados foram exportados com sucesso!'),
          SizedBox(height: 16),
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.secondaryContainer,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.folder_outlined,
                  color: Theme.of(context).colorScheme.onSecondaryContainer,
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'O arquivo foi salvo na pasta Downloads do seu dispositivo.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSecondaryContainer,
                        ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        ElevatedButton(
          onPressed: () {
            provider.clearResults();
            Navigator.of(context).pop();
          },
          child: Text('Concluir'),
        ),
      ],
    );
  }

  Widget _buildErrorState(
    BuildContext context,
    String error,
    DataExportProvider provider,
  ) {
    return AlertDialog(
      title: Row(
        children: [
          Icon(
            Icons.error_outline,
            color: Theme.of(context).colorScheme.error,
          ),
          SizedBox(width: 8),
          Text('Erro na Exportação'),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Ocorreu um erro durante a exportação dos dados:'),
          SizedBox(height: 16),
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.errorContainer,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              error,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onErrorContainer,
                  ),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            provider.clearResults();
            Navigator.of(context).pop();
          },
          child: Text('Fechar'),
        ),
        ElevatedButton(
          onPressed: () {
            // TODO: Implementar retry se desejado
            provider.clearResults();
            Navigator.of(context).pop();
          },
          child: Text('Tentar Novamente'),
        ),
      ],
    );
  }
}