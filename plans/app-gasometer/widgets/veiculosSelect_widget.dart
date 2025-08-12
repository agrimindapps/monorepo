// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:get/get.dart';

// Project imports:
import '../../core/themes/manager.dart';
import '../database/21_veiculos_model.dart';
import '../repository/veiculos_repository.dart';

class VeiculoDropdownWidget extends StatefulWidget {
  final Function(String?, VeiculoCar?) onVeiculoSelected;

  const VeiculoDropdownWidget({super.key, required this.onVeiculoSelected});

  @override
  State<VeiculoDropdownWidget> createState() => _VeiculoDropdownWidgetState();
}

class _VeiculoDropdownWidgetState extends State<VeiculoDropdownWidget> {
  late final VeiculosRepository _repository;
  List<VeiculoCar> _veiculos = [];
  String _selectedVeiculoId = '';

  @override
  void initState() {
    super.initState();
    _repository = Get.find<VeiculosRepository>();
    _loadData();
  }

  Future<void> _loadData() async {
    // Carregar veículos e ID selecionado em paralelo
    final futures = await Future.wait([
      _repository.getVeiculos(),
      _repository.getSelectedVeiculoId(),
    ]);

    final veiculosRaw = futures[0] as List<VeiculoCar>;
    final selectedId = futures[1] as String;

    // Remover duplicatas baseado no ID do veículo
    final Map<String, VeiculoCar> veiculosMap = {};
    for (final veiculo in veiculosRaw) {
      veiculosMap[veiculo.id] = veiculo;
    }
    final veiculos = veiculosMap.values.toList();

    // Verificar se o ID selecionado ainda existe na lista
    String finalSelectedId = selectedId;
    final veiculoExists = veiculos.any((v) => v.id == selectedId);

    if (!veiculoExists || selectedId.isEmpty) {
      if (veiculos.isNotEmpty) {
        finalSelectedId = veiculos.first.id;
        await _repository.setSelectedVeiculoId(finalSelectedId);
        // Notificar a seleção
        widget.onVeiculoSelected(finalSelectedId, veiculos.first);
      } else {
        finalSelectedId = '';
      }
    }

    setState(() {
      _veiculos = veiculos;
      _selectedVeiculoId = finalSelectedId;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: double.infinity,
          child: DropdownButtonFormField<String>(
            elevation: 0,
            padding: EdgeInsets.symmetric(
              horizontal: 16,
              vertical: _veiculos.isEmpty
                  ? 16
                  : GetPlatform.isIOS && _repository.selectedVeiculoId != ''
                      ? 0
                      : 8,
            ),
            menuMaxHeight: 400,
            isDense: false,
            style: const TextStyle(fontSize: 16),
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.zero,
            ),
            hint: Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: Theme.of(context).cardColor,
                  child: Icon(
                    _veiculos.isEmpty
                        ? Icons.directions_car
                        : Icons.directions_car,
                    size: 28,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                const SizedBox(width: 16),
                Text(
                  _veiculos.isEmpty
                      ? 'Nenhum veículo cadastrado'
                      : 'Selecione um veículo',
                  style: const TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ],
            ),
            value: _getValue(),
            items: _veiculos.map((veiculo) {
              return DropdownMenuItem<String>(
                value: veiculo.id,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircleAvatar(
                        radius: 24,
                        backgroundColor: Theme.of(context).cardColor,
                        child: Icon(
                          Icons.directions_car,
                          size: 28,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Flexible(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '${veiculo.marca} ${veiculo.modelo}',
                              style: TextStyle(
                                fontSize: 16,
                                color: ThemeManager().isDark.value
                                    ? Colors.white
                                    : Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Placa: ${veiculo.placa.isEmpty ? 'Não informado' : veiculo.placa}',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[700],
                              ),
                            ),
                            Text(
                              '${veiculo.odometroAtual} km',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[700],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                final selectedVeiculo = _veiculos.firstWhere(
                  (veiculo) => veiculo.id == value,
                  orElse: () => _veiculos.first,
                );

                setState(() {
                  _selectedVeiculoId = value;
                });

                _repository.setSelectedVeiculoId(value);
                widget.onVeiculoSelected(value, selectedVeiculo);
              }
            },
            icon: Icon(
              Icons.arrow_drop_down,
              color: Theme.of(context).primaryColor,
              size: 32,
            ),
            isExpanded: true,
            dropdownColor: Theme.of(context).cardColor,
          ),
        ),
      ],
    );
  }

  String? _getValue() {
    if (_selectedVeiculoId.isEmpty || _veiculos.isEmpty) {
      return null;
    }

    final exists = _veiculos.any((veiculo) => veiculo.id == _selectedVeiculoId);
    return exists ? _selectedVeiculoId : null;
  }
}
