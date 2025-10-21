// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../../../../core/style/shadcn_style.dart';
import '../model/znew_indice_adiposidade_model.dart';

class ZNewIndiceAdiposidadeResultCard extends StatelessWidget {
  final ZNewIndiceAdiposidadeModel modelo;
  final VoidCallback onCompartilhar;
  const ZNewIndiceAdiposidadeResultCard(
      {super.key, required this.modelo, required this.onCompartilhar});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: isDark ? ShadcnStyle.backgroundColor : Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Resultado',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.share),
                onPressed: onCompartilhar,
                tooltip: 'Compartilhar resultado',
              ),
            ],
          ),
          const SizedBox(height: 16),
          Center(
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _getColorForClassificacao(modelo.classificacao)
                    .withValues(alpha: 0.2),
                border: Border.all(
                  color: _getColorForClassificacao(modelo.classificacao),
                  width: 2,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'IAC',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white70 : Colors.black54,
                    ),
                  ),
                  Text(
                    '${modelo.iac}',
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: _getColorForClassificacao(modelo.classificacao),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    modelo.classificacao,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: _getColorForClassificacao(modelo.classificacao),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Interpretação:',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            modelo.comentario,
            style: TextStyle(
              fontSize: 14,
              color: isDark ? Colors.white70 : Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'O IAC (Índice de Adiposidade Corporal) é uma medida alternativa ao IMC para estimar a porcentagem de gordura corporal. Baseia-se na altura e na circunferência do quadril, sendo útil quando não é possível medir o peso.',
            style: TextStyle(
              fontSize: 12,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Color _getColorForClassificacao(String classificacao) {
    switch (classificacao) {
      case 'Adiposidade essencial':
        return Colors.blue;
      case 'Adiposidade saudável':
        return Colors.green;
      case 'Sobrepeso':
        return Colors.orange;
      case 'Obesidade':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
