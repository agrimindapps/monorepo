// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../model/cintura_quadril_model.dart';

class CinturaQuadrilResultWidget extends StatelessWidget {
  final CinturaQuadrilModel resultado;
  final VoidCallback onCompartilhar;

  const CinturaQuadrilResultWidget({
    super.key,
    required this.resultado,
    required this.onCompartilhar,
  });

  @override
  Widget build(BuildContext context) {
    Color classificacaoCor = _getClassificacaoCor(resultado.classificacao);

    return Card(
      margin: EdgeInsets.zero,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeader(context),
            const Divider(),
            const SizedBox(height: 8),
            _buildResultadoItem('RCQ:', resultado.rcq.toStringAsFixed(2)),
            _buildResultadoItem(
              'Classificação:',
              resultado.classificacao,
              color: classificacaoCor,
              fontWeight: FontWeight.bold,
            ),
            const SizedBox(height: 16),
            _buildComentarioBox(classificacaoCor),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        Icon(
          Icons.analytics_outlined,
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.teal.shade300
              : Colors.teal,
        ),
        const SizedBox(width: 12),
        const Text(
          'Resultados',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const Spacer(),
        IconButton(
          icon: const Icon(Icons.share),
          onPressed: onCompartilhar,
          tooltip: 'Compartilhar resultados',
        ),
      ],
    );
  }

  Widget _buildResultadoItem(String label, String valor,
      {Color? color, FontWeight? fontWeight}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            valor,
            style: TextStyle(
              fontWeight: fontWeight ?? FontWeight.normal,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComentarioBox(Color cor) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: cor.withValues(alpha: 0.1),
        border: Border.all(
          color: cor.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline,
                size: 18,
                color: cor,
              ),
              const SizedBox(width: 8),
              Text(
                'Observação:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: cor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(resultado.comentario),
        ],
      ),
    );
  }

  Color _getClassificacaoCor(String classificacao) {
    switch (classificacao) {
      case 'Baixo':
        return Colors.green;
      case 'Moderado':
        return Colors.amber;
      case 'Alto':
        return Colors.orange;
      case 'Muito Alto':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
