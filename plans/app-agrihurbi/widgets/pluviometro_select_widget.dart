// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../controllers/pluviometros_controller.dart';
import '../models/pluviometros_models.dart';

class PluvioSelect extends StatefulWidget {
  final Function(String?) onPluviometroSelected;

  const PluvioSelect({
    super.key,
    required this.onPluviometroSelected,
  });

  @override
  State<PluvioSelect> createState() => _PluvioSelectState();
}

class _PluvioSelectState extends State<PluvioSelect> {
  final _controller = PluviometrosController();
  List<Pluviometro> _pluviometros = [];
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadPluviometros();
  }

  Future<void> _loadPluviometros() async {
    try {
      final pluviometros = await _controller.getPluviometros();
      setState(() {
        _pluviometros = pluviometros;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return _buildErrorState();
    }

    if (_pluviometros.isEmpty) {
      return _buildEmptyState();
    }

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: DropdownButtonFormField<String>(
        elevation: 3,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        menuMaxHeight: 400,
        isDense: false,
        style: const TextStyle(fontSize: 16),
        decoration: const InputDecoration(
          border: InputBorder.none,
          contentPadding: EdgeInsets.zero,
        ),
        hint: _buildHintRow(),
        value: _controller.selectedPluviometroId.isEmpty
            ? null
            : _controller.selectedPluviometroId,
        items: _pluviometros.map((pluviometro) {
          return DropdownMenuItem<String>(
            value: pluviometro.id,
            child: _pluviometroItem(pluviometro),
          );
        }).toList(),
        onChanged: (value) {
          if (value != null) {
            _controller.setSelectedPluviometroId(value);
            widget.onPluviometroSelected(value);
          }
        },
        icon: const Icon(
          Icons.arrow_drop_down,
          color: Colors.black,
          size: 32,
        ),
        isExpanded: true,
        dropdownColor: Colors.white,
      ),
    );
  }

  Widget _buildHintRow() {
    return Row(
      children: [
        CircleAvatar(
          radius: 24,
          backgroundColor: Colors.blue[100],
          child: Icon(
            Icons.water_drop,
            size: 28,
            color: Colors.blue[700],
          ),
        ),
        const SizedBox(width: 16),
        const Text(
          'Selecione um pluviômetro',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildErrorState() {
    return SizedBox(
      height: 52,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.red[50],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.red[300]!),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Erro ao carregar pluviômetros',
              style: TextStyle(color: Colors.red[700]),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.refresh, color: Colors.red),
              onPressed: _loadPluviometros,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return SizedBox(
      height: 52,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: const Center(
          child: Text(
            'Nenhum pluviômetro cadastrado',
            style: TextStyle(color: Colors.grey),
          ),
        ),
      ),
    );
  }

  Widget _pluviometroItem(Pluviometro pluviometro) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 4, 8, 4),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 24,
            backgroundColor: Colors.black12,
            child: Icon(
              Icons.water_drop,
              size: 28,
              color: Colors.black,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  pluviometro.descricao,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Capacidade :${pluviometro.quantidade} mm',
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
    );
  }
}
