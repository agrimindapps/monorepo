import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../diagnosticos/presentation/providers/diagnosticos_provider.dart';
import '../providers/detalhe_defensivo_provider.dart';

/// Widget para tab de diagnósticos com filtros e listagem
class DiagnosticosTabWidget extends StatelessWidget {
  final String defensivoName;

  const DiagnosticosTabWidget({
    super.key,
    required this.defensivoName,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer2<DiagnosticosProvider, DetalheDefensivoProvider>(
      builder: (context, diagnosticosProvider, defensivoProvider, child) {
        // Debug info card
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  border: Border.all(color: Colors.green.shade200),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('DEBUG - Diagnósticos Tab', 
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                    Text('Loading: ${diagnosticosProvider.isLoading}'),
                    Text('Error: ${diagnosticosProvider.hasError}'),
                    Text('Diagnósticos: ${diagnosticosProvider.diagnosticos.length}'),
                    Text('Defensivo ID: ${defensivoProvider.defensivoData?.idReg ?? 'null'}'),
                    Text('Defensivo Nome: ${defensivoProvider.defensivoData?.nomeComum ?? 'null'}'),
                  ],
                ),
              ),
              
              _buildContent(diagnosticosProvider, defensivoProvider),
            ],
          ),
        );
      },
    );
  }

  Widget _buildContent(DiagnosticosProvider diagnosticosProvider, DetalheDefensivoProvider defensivoProvider) {
    if (diagnosticosProvider.isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (diagnosticosProvider.hasError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Erro ao carregar diagnósticos',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              diagnosticosProvider.errorMessage ?? 'Erro desconhecido',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                final idReg = defensivoProvider.defensivoData?.idReg;
                if (idReg != null) {
                  diagnosticosProvider.getDiagnosticosByDefensivo(idReg);
                }
              },
              child: const Text('Tentar novamente'),
            ),
          ],
        ),
      );
    }

    if (diagnosticosProvider.diagnosticos.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.search_off, size: 48, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              'Nenhum diagnóstico encontrado',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Não há diagnósticos disponíveis para $defensivoName',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: diagnosticosProvider.diagnosticos.length,
      itemBuilder: (context, index) {
        final diagnostico = diagnosticosProvider.diagnosticos[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: const Icon(Icons.bug_report, color: Colors.green),
            title: Text(diagnostico.nomePraga ?? 'Praga não especificada'),
            subtitle: Text(diagnostico.nomeCultura ?? 'Cultura não especificada'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              // Navigate to diagnostic details
            },
          ),
        );
      },
    );
  }
}