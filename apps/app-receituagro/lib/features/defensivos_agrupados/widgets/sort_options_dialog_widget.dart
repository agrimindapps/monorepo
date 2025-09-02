import 'package:flutter/material.dart';

/// Widget especializado para exibir opções de ordenação
/// 
/// Características:
/// - Dialog modal com opções de ordenação
/// - Interface limpa com RadioListTile
/// - Callback para mudança de ordenação
/// - Suporte completo a diferentes critérios
class SortOptionsDialogWidget extends StatelessWidget {
  final String ordenacaoAtual;
  final Function(String) onOrdenacaoChanged;

  const SortOptionsDialogWidget({
    super.key,
    required this.ordenacaoAtual,
    required this.onOrdenacaoChanged,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Ordenar por'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildOpcaoOrdenacao(
            context,
            'Prioridade',
            'prioridade',
          ),
          _buildOpcaoOrdenacao(
            context,
            'Nome',
            'nome',
          ),
          _buildOpcaoOrdenacao(
            context,
            'Fabricante',
            'fabricante',
          ),
          _buildOpcaoOrdenacao(
            context,
            'Quantidade de Usos',
            'usos',
          ),
        ],
      ),
    );
  }

  Widget _buildOpcaoOrdenacao(
    BuildContext context,
    String label,
    String valor,
  ) {
    return RadioListTile<String>(
      title: Text(label),
      value: valor,
      groupValue: ordenacaoAtual,
      onChanged: (value) {
        onOrdenacaoChanged(value!);
        Navigator.of(context).pop();
      },
    );
  }

  /// Método estático para facilitar o uso do dialog
  static Future<void> show(
    BuildContext context, {
    required String ordenacaoAtual,
    required Function(String) onOrdenacaoChanged,
  }) {
    return showDialog(
      context: context,
      builder: (context) => SortOptionsDialogWidget(
        ordenacaoAtual: ordenacaoAtual,
        onOrdenacaoChanged: onOrdenacaoChanged,
      ),
    );
  }
}