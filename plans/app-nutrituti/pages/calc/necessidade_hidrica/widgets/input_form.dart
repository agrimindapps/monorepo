// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../../../../../../core/style/shadcn_style.dart';
import '../models/necessidade_hidrica_model.dart';

class NecessidadeHidricaInputForm extends StatelessWidget {
  final NecessidadeHidricaModel model;
  final VoidCallback onCalcular;
  final VoidCallback onLimpar;

  const NecessidadeHidricaInputForm({
    super.key,
    required this.model,
    required this.onCalcular,
    required this.onLimpar,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAliasWithSaveLayer,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: ShadcnStyle.borderColor, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 32, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            _buildPesoField(),
            _buildNivelAtividadeDropdown(),
            _buildClimaDropdown(),
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildPesoField() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: model.pesoController,
        focusNode: model.focusPeso,
        decoration: const InputDecoration(
          labelText: 'Peso (kg)',
          border: OutlineInputBorder(),
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        inputFormatters: [model.pesoMask],
      ),
    );
  }

  Widget _buildNivelAtividadeDropdown() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: DropdownButtonFormField<int>(
        decoration: const InputDecoration(
          labelText: 'Nível de Atividade Física',
          border: OutlineInputBorder(),
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
        value: model.nivelAtividadeSelecionado,
        items: model.niveisAtividade.map((nivel) {
          return DropdownMenuItem<int>(
            value: nivel['id'] as int,
            child: Text(nivel['text'] as String),
          );
        }).toList(),
        onChanged: (value) {
          model.nivelAtividadeSelecionado = value ?? 1;
        },
      ),
    );
  }

  Widget _buildClimaDropdown() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: DropdownButtonFormField<int>(
        decoration: const InputDecoration(
          labelText: 'Clima',
          border: OutlineInputBorder(),
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
        value: model.climaSelecionado,
        items: model.tiposClima.map((clima) {
          return DropdownMenuItem<int>(
            value: clima['id'] as int,
            child: Text(clima['text'] as String),
          );
        }).toList(),
        onChanged: (value) {
          model.climaSelecionado = value ?? 2;
        },
      ),
    );
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 16, 0, 0),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          OutlinedButton.icon(
            onPressed: onLimpar,
            icon: Icon(
              Icons.refresh,
              size: 18,
              color: ShadcnStyle.mutedTextColor,
            ),
            label: Text(
              'Limpar',
              style: TextStyle(
                color: ShadcnStyle.mutedTextColor,
              ),
            ),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: ShadcnStyle.borderColor),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
          const SizedBox(width: 16),
          ElevatedButton.icon(
            onPressed: onCalcular,
            icon: const Icon(
              Icons.calculate,
              size: 18,
              color: Colors.white,
            ),
            label: const Text(
              'Calcular',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.cyan.shade600,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              elevation: 2,
            ),
          ),
        ],
      ),
    );
  }
}
