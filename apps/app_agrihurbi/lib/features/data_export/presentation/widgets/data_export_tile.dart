import 'package:flutter/material.dart';
import '../pages/data_export_page.dart';

/// Widget simples para ser usado em listas de configurações
class DataExportTile extends StatelessWidget {
  const DataExportTile({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        Icons.download_outlined,
        color: Theme.of(context).colorScheme.primary,
      ),
      title: Text('Exportar Meus Dados'),
      subtitle: Text('Baixar uma cópia dos seus dados pessoais (LGPD)'),
      trailing: Icon(Icons.arrow_forward_ios, size: 16),
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => DataExportPage(),
          ),
        );
      },
    );
  }
}

/// Widget para seção completa em configurações
class DataExportSection extends StatelessWidget {
  const DataExportSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            'Privacidade e Dados',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ),
        Card(
          margin: EdgeInsets.symmetric(horizontal: 16),
          child: DataExportTile(),
        ),
      ],
    );
  }
}