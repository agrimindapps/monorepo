import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/data_export_provider.dart';
import '../widgets/export_availability_widget.dart';
import '../widgets/export_options_dialog.dart';
import '../widgets/export_progress_dialog.dart';
import '../../domain/entities/export_request.dart';

class DataExportPage extends StatefulWidget {
  const DataExportPage({Key? key}) : super(key: key);

  @override
  State<DataExportPage> createState() => _DataExportPageState();
}

class _DataExportPageState extends State<DataExportPage> {
  @override
  void initState() {
    super.initState();
    // Verificar disponibilidade ao entrar na página
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DataExportProvider>().checkExportAvailability();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Exportar Dados'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Consumer<DataExportProvider>(
        builder: (context, provider, child) {
          return SingleChildScrollView(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Seção informativa
                _buildInfoSection(context),
                SizedBox(height: 24),

                // Widget de disponibilidade e exportação
                ExportAvailabilityWidget(
                  onExportPressed: () => _showExportOptions(context),
                ),
                SizedBox(height: 24),

                // Seção de ajuda
                _buildHelpSection(context),

                // Listener para mostrar dialog de progresso
                _buildProgressListener(provider),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoSection(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.privacy_tip_outlined,
                  color: Theme.of(context).colorScheme.primary,
                ),
                SizedBox(width: 8),
                Text(
                  'Lei Geral de Proteção de Dados (LGPD)',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            SizedBox(height: 12),
            Text(
              'Em conformidade com a LGPD, você tem o direito de obter uma cópia de todos os seus dados pessoais que mantemos. Isso inclui:',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            SizedBox(height: 12),
            _buildDataTypeList(context),
          ],
        ),
      ),
    );
  }

  Widget _buildDataTypeList(BuildContext context) {
    final dataTypes = [
      {'icon': Icons.person_outline, 'title': 'Perfil do usuário', 'desc': 'Nome, email e informações de conta'},
      {'icon': Icons.favorite_outline, 'title': 'Favoritos', 'desc': 'Produtos marcados como favoritos'},
      {'icon': Icons.comment_outlined, 'title': 'Comentários', 'desc': 'Avaliações e comentários sobre produtos'},
      {'icon': Icons.settings_outlined, 'title': 'Configurações', 'desc': 'Preferências e configurações personalizadas'},
    ];

    return Column(
      children: dataTypes.map((item) {
        return Padding(
          padding: EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              Icon(
                item['icon'] as IconData,
                size: 20,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item['title'] as String,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                    Text(
                      item['desc'] as String,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildHelpSection(BuildContext context) {
    return Card(
      child: ExpansionTile(
        leading: Icon(Icons.help_outline),
        title: Text('Perguntas Frequentes'),
        children: [
          Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildFaqItem(
                  context,
                  'Com que frequência posso exportar meus dados?',
                  'Por questões de segurança, você pode exportar seus dados apenas uma vez a cada 24 horas.',
                ),
                SizedBox(height: 16),
                _buildFaqItem(
                  context,
                  'Onde o arquivo é salvo?',
                  'O arquivo é salvo automaticamente na pasta Downloads do seu dispositivo.',
                ),
                SizedBox(height: 16),
                _buildFaqItem(
                  context,
                  'Que formatos estão disponíveis?',
                  'Você pode escolher entre JSON (formato estruturado) ou CSV (planilha compatível com Excel).',
                ),
                SizedBox(height: 16),
                _buildFaqItem(
                  context,
                  'Os dados são seguros?',
                  'Sim, apenas os dados de sua propriedade são exportados. Dados do aplicativo como catálogo de produtos não são incluídos.',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFaqItem(BuildContext context, String question, String answer) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          question,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
        ),
        SizedBox(height: 4),
        Text(
          answer,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
      ],
    );
  }

  Widget _buildProgressListener(DataExportProvider provider) {
    // Este widget monitora mudanças no estado de exportação
    // para mostrar o dialog de progresso automaticamente
    return Consumer<DataExportProvider>(
      builder: (context, provider, child) {
        if (provider.isExporting && provider.exportProgress != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _showProgressDialog(context);
          });
        }
        return SizedBox.shrink();
      },
    );
  }

  void _showExportOptions(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => ExportOptionsDialog(
        onExport: (request) => _startExport(context, request),
      ),
    );
  }

  void _startExport(BuildContext context, ExportRequest request) {
    final provider = context.read<DataExportProvider>();
    provider.startExport(request);
  }

  void _showProgressDialog(BuildContext context) {
    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => ExportProgressDialog(),
    );
  }
}