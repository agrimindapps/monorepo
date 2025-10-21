// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:app_calculei/services/validacao_service.dart';

class ValidacaoMessageWidget extends StatelessWidget {
  final List<ResultadoValidacao> validacoes;

  const ValidacaoMessageWidget({
    super.key,
    required this.validacoes,
  });

  @override
  Widget build(BuildContext context) {
    if (validacoes.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: validacoes.map((validacao) {
        final isErro = validacao.tipo == TipoValidacao.erro;

        return Padding(
          padding: const EdgeInsets.only(top: 4.0),
          child: Row(
            children: [
              Icon(
                isErro ? Icons.error : Icons.warning,
                color: isErro ? Colors.red : Colors.orange,
                size: 16,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  validacao.mensagem,
                  style: TextStyle(
                    color: isErro ? Colors.red : Colors.orange,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
