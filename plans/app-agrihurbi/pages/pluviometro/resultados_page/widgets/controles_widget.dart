// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../../../../../../core/style/shadcn_style.dart';
import '../../../../models/pluviometros_models.dart';
import 'pluviometria_models.dart';

class ControlesWidget extends StatelessWidget {
  final List<Pluviometro> pluviometros;
  final Pluviometro? pluviometroSelecionado;
  final String tipoVisualizacao;
  final int anoSelecionado;
  final int mesSelecionado;
  final Function(Pluviometro?) onPluviometroChanged;
  final Function(String) onTipoVisualizacaoChanged;
  final Function(int) onAnoChanged;
  final Function(int) onMesChanged;

  const ControlesWidget({
    super.key,
    required this.pluviometros,
    required this.pluviometroSelecionado,
    required this.tipoVisualizacao,
    required this.anoSelecionado,
    required this.mesSelecionado,
    required this.onPluviometroChanged,
    required this.onTipoVisualizacaoChanged,
    required this.onAnoChanged,
    required this.onMesChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(width: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildVisualizacaoToggle(),
              ],
            ),
            const SizedBox(height: 16),
            _buildPluviometroSelector(),
            const SizedBox(height: 16),
            tipoVisualizacao == 'Ano'
                ? _buildAnoSelector()
                : _buildMesAnoSelector(),
          ],
        ),
      ),
    );
  }

  Widget _buildPluviometroSelector() {
    if (pluviometros.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 8.0),
        child: Center(
          child: Text('Nenhum pluviômetro encontrado'),
        ),
      );
    }

    return DropdownButtonFormField<Pluviometro>(
      decoration: ShadcnStyle.dropdownDecoration.copyWith(
        labelText: 'Pluviômetro',
      ),
      value: pluviometroSelecionado,
      items: pluviometros.map((pluviometro) {
        return DropdownMenuItem<Pluviometro>(
          value: pluviometro,
          child: Text(
            pluviometro.descricao,
            style: TextStyle(color: ShadcnStyle.textColor),
          ),
        );
      }).toList(),
      onChanged: onPluviometroChanged,
      dropdownColor: ShadcnStyle.backgroundColor,
      icon: Icon(Icons.arrow_drop_down, color: ShadcnStyle.labelColor),
    );
  }

  Widget _buildVisualizacaoToggle() {
    return SegmentedButton<String>(
      segments: const [
        ButtonSegment(
          value: 'Ano',
          label: Text('Por Ano'),
          icon: Icon(Icons.calendar_today),
        ),
        ButtonSegment(
          value: 'Mes',
          label: Text('Por Mês'),
          icon: Icon(Icons.calendar_view_month),
        ),
      ],
      selected: {tipoVisualizacao},
      onSelectionChanged: (Set<String> newSelection) {
        onTipoVisualizacaoChanged(newSelection.first);
      },
      style: ShadcnStyle.segmentedButtonTheme,
    );
  }

  Widget _buildAnoSelector() {
    final anoAtual = DateTime.now().year;
    final anos = List.generate(5, (index) => anoAtual - index);

    return DropdownButtonFormField<int>(
      decoration: ShadcnStyle.dropdownDecoration.copyWith(
        labelText: 'Ano',
      ),
      value: anoSelecionado,
      items: anos.map((ano) {
        return DropdownMenuItem<int>(
          value: ano,
          child: Text(
            ano.toString(),
            style: TextStyle(color: ShadcnStyle.textColor),
          ),
        );
      }).toList(),
      onChanged: (value) {
        if (value != null) onAnoChanged(value);
      },
      dropdownColor: ShadcnStyle.backgroundColor,
      icon: Icon(Icons.arrow_drop_down, color: ShadcnStyle.labelColor),
    );
  }

  Widget _buildMesAnoSelector() {
    final anoAtual = DateTime.now().year;
    final anos = List.generate(5, (index) => anoAtual - index);

    return Column(
      children: [
        DropdownButtonFormField<int>(
          decoration: ShadcnStyle.dropdownDecoration.copyWith(
            labelText: 'Mês',
          ),
          value: mesSelecionado,
          items: List.generate(12, (index) {
            return DropdownMenuItem<int>(
              value: index + 1,
              child: Text(
                mesesCompletos[index],
                style: TextStyle(color: ShadcnStyle.textColor),
              ),
            );
          }),
          onChanged: (value) {
            if (value != null) onMesChanged(value);
          },
          dropdownColor: ShadcnStyle.backgroundColor,
          icon: Icon(Icons.arrow_drop_down, color: ShadcnStyle.labelColor),
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<int>(
          decoration: ShadcnStyle.dropdownDecoration.copyWith(
            labelText: 'Ano',
          ),
          value: anoSelecionado,
          items: anos.map((ano) {
            return DropdownMenuItem<int>(
              value: ano,
              child: Text(
                ano.toString(),
                style: TextStyle(color: ShadcnStyle.textColor),
              ),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null) onAnoChanged(value);
          },
          dropdownColor: ShadcnStyle.backgroundColor,
          icon: Icon(Icons.arrow_drop_down, color: ShadcnStyle.labelColor),
        ),
      ],
    );
  }
}
