import 'package:flutter/material.dart';
import '../../domain/entities/export_request.dart';

class ExportOptionsDialog extends StatefulWidget {
  final Function(ExportRequest) onExport;

  const ExportOptionsDialog({
    Key? key,
    required this.onExport,
  }) : super(key: key);

  @override
  State<ExportOptionsDialog> createState() => _ExportOptionsDialogState();
}

class _ExportOptionsDialogState extends State<ExportOptionsDialog> {
  ExportFormat _selectedFormat = ExportFormat.json;
  final Set<DataType> _selectedDataTypes = {
    DataType.userProfile,
    DataType.favorites,
    DataType.comments,
    DataType.preferences,
  };

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Configurações de Exportação'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Formato do Arquivo',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            SizedBox(height: 8),
            _buildFormatOptions(),
            SizedBox(height: 24),
            Text(
              'Dados para Exportar',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            SizedBox(height: 8),
            _buildDataTypeOptions(),
            SizedBox(height: 16),
            _buildInfoCard(),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _selectedDataTypes.isNotEmpty ? _handleExport : null,
          child: Text('Exportar'),
        ),
      ],
    );
  }

  Widget _buildFormatOptions() {
    return Column(
      children: [
        RadioListTile<ExportFormat>(
          title: Text('JSON'),
          subtitle: Text('Formato estruturado, ideal para desenvolvedores'),
          value: ExportFormat.json,
          groupValue: _selectedFormat,
          onChanged: (value) {
            setState(() {
              _selectedFormat = value!;
            });
          },
          contentPadding: EdgeInsets.zero,
        ),
        RadioListTile<ExportFormat>(
          title: Text('CSV'),
          subtitle: Text('Planilha, fácil de abrir em Excel ou similar'),
          value: ExportFormat.csv,
          groupValue: _selectedFormat,
          onChanged: (value) {
            setState(() {
              _selectedFormat = value!;
            });
          },
          contentPadding: EdgeInsets.zero,
        ),
      ],
    );
  }

  Widget _buildDataTypeOptions() {
    return Column(
      children: [
        CheckboxListTile(
          title: Text('Perfil do Usuário'),
          subtitle: Text('Nome, email, datas de criação'),
          value: _selectedDataTypes.contains(DataType.userProfile),
          onChanged: (value) {
            setState(() {
              if (value == true) {
                _selectedDataTypes.add(DataType.userProfile);
              } else {
                _selectedDataTypes.remove(DataType.userProfile);
              }
            });
          },
          contentPadding: EdgeInsets.zero,
        ),
        CheckboxListTile(
          title: Text('Favoritos'),
          subtitle: Text('Produtos marcados como favoritos'),
          value: _selectedDataTypes.contains(DataType.favorites),
          onChanged: (value) {
            setState(() {
              if (value == true) {
                _selectedDataTypes.add(DataType.favorites);
              } else {
                _selectedDataTypes.remove(DataType.favorites);
              }
            });
          },
          contentPadding: EdgeInsets.zero,
        ),
        CheckboxListTile(
          title: Text('Comentários'),
          subtitle: Text('Avaliações e comentários sobre produtos'),
          value: _selectedDataTypes.contains(DataType.comments),
          onChanged: (value) {
            setState(() {
              if (value == true) {
                _selectedDataTypes.add(DataType.comments);
              } else {
                _selectedDataTypes.remove(DataType.comments);
              }
            });
          },
          contentPadding: EdgeInsets.zero,
        ),
        CheckboxListTile(
          title: Text('Configurações'),
          subtitle: Text('Preferências e configurações personalizadas'),
          value: _selectedDataTypes.contains(DataType.preferences),
          onChanged: (value) {
            setState(() {
              if (value == true) {
                _selectedDataTypes.add(DataType.preferences);
              } else {
                _selectedDataTypes.remove(DataType.preferences);
              }
            });
          },
          contentPadding: EdgeInsets.zero,
        ),
      ],
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            size: 20,
            color: Theme.of(context).colorScheme.primary,
          ),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'O arquivo será salvo na pasta Downloads do seu dispositivo.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleExport() {
    final request = ExportRequest(
      format: _selectedFormat,
      dataTypes: _selectedDataTypes,
      sanitizeData: true,
    );

    Navigator.of(context).pop();
    widget.onExport(request);
  }
}