// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:get/get.dart';

// Project imports:
import '../../../../repository/equinos_repository.dart';

class EquinoFormWidget extends StatelessWidget {
  const EquinoFormWidget({
    super.key,
    required this.formKey,
    required this.onStatusChanged,
  });

  final GlobalKey<FormState> formKey;
  final Function(bool) onStatusChanged;

  Widget _buildFormField({
    required String label,
    required String initialValue,
    required Function(String) onChanged,
    bool isRequired = false,
    int maxLines = 1,
    String? hintText,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        initialValue: initialValue,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          hintText: hintText,
          border: const OutlineInputBorder(),
          suffixIcon: isRequired
              ? const Icon(Icons.star, size: 10, color: Colors.red)
              : null,
        ),
        validator: isRequired
            ? (value) => value?.isEmpty ?? true ? 'Campo obrigatório' : null
            : null,
        onChanged: onChanged,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final equino = EquinoRepository().mapEquinos.value;

      return Form(
        key: formKey,
        child: Column(
          children: [
            // Card com informações básicas
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Informações Básicas',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 16),
                    _buildFormField(
                      label: 'Nome Comum',
                      initialValue: equino.nomeComum,
                      onChanged: (value) => equino.nomeComum = value,
                      isRequired: true,
                      hintText: 'Ex: Cavalo Árabe',
                    ),
                    _buildFormField(
                      label: 'País de Origem',
                      initialValue: equino.paisOrigem,
                      onChanged: (value) => equino.paisOrigem = value,
                      hintText: 'Ex: Brasil',
                    ),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Disponível'),
                      subtitle: Text(
                        equino.status ? 'Registro ativo' : 'Registro inativo',
                        style: TextStyle(
                          color: equino.status ? Colors.green : Colors.orange,
                          fontSize: 12,
                        ),
                      ),
                      value: equino.status,
                      onChanged: (value) {
                        equino.status = value;
                        onStatusChanged(value);
                      },
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Card com detalhes
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Detalhes',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 16),
                    _buildFormField(
                      label: 'Histórico',
                      initialValue: equino.historico,
                      onChanged: (value) => equino.historico = value,
                      maxLines: 3,
                      hintText: 'Origem e história da raça',
                    ),
                    _buildFormField(
                      label: 'Temperamento',
                      initialValue: equino.temperamento,
                      onChanged: (value) => equino.temperamento = value,
                      maxLines: 2,
                      hintText: 'Características comportamentais',
                    ),
                    _buildFormField(
                      label: 'Pelagem',
                      initialValue: equino.pelagem,
                      onChanged: (value) => equino.pelagem = value,
                      hintText: 'Cores e padrões típicos',
                    ),
                    _buildFormField(
                      label: 'Uso',
                      initialValue: equino.uso,
                      onChanged: (value) => equino.uso = value,
                      maxLines: 2,
                      hintText: 'Principais utilizações',
                    ),
                    _buildFormField(
                      label: 'Influências',
                      initialValue: equino.influencias,
                      onChanged: (value) => equino.influencias = value,
                      maxLines: 2,
                      hintText: 'Outras raças que influenciaram',
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Card com características físicas
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Características Físicas',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildFormField(
                            label: 'Altura',
                            initialValue: equino.altura,
                            onChanged: (value) => equino.altura = value,
                            hintText: 'Ex: 1.50-1.60m',
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildFormField(
                            label: 'Peso',
                            initialValue: equino.peso,
                            onChanged: (value) => equino.peso = value,
                            hintText: 'Ex: 400-500kg',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
}
