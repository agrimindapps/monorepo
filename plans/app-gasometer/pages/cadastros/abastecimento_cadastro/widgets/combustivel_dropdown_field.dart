// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:get/get.dart';

// Project imports:
import '../../../../../core/style/shadcn_style.dart';
import '../../../../../core/themes/manager.dart';
import '../../../../database/enums.dart';
import '../controller/abastecimento_form_controller.dart';

class CombustivelDropdownField extends StatelessWidget {
  final AbastecimentoFormController controller;

  const CombustivelDropdownField({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() => DecoratedBox(
          decoration: BoxDecoration(
            color: ThemeManager().isDark.value
                ? Colors.grey.shade900
                : Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: ShadcnStyle.borderColor.withValues(alpha: 0.3),
            ),
          ),
          child: DropdownButtonFormField<TipoCombustivel>(
            decoration: InputDecoration(
              labelText: 'Tipo de Combustível',
              prefixIcon: Icon(
                _getCombustivelIcon(controller.formModel.tipoCombustivel),
                color: _getCombustivelColor(controller.formModel.tipoCombustivel),
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 16,
              ),
            ),
            value: controller.formModel.tipoCombustivel,
            dropdownColor: ThemeManager().isDark.value
                ? Colors.grey.shade900
                : Colors.white,
            items: TipoCombustivel.values.map((tipo) {
              return DropdownMenuItem(
                value: tipo,
                child: Row(
                  children: [
                    Container(
                      width: 4,
                      height: 20,
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        color: _getCombustivelColor(tipo),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    Icon(
                      _getCombustivelIcon(tipo),
                      size: 16,
                      color: _getCombustivelColor(tipo),
                    ),
                    const SizedBox(width: 8),
                    Text(tipo.descricao),
                  ],
                ),
              );
            }).toList(),
            onChanged: (TipoCombustivel? value) {
              if (value != null) {
                controller.updateTipoCombustivel(value);
              }
            },
            validator: controller.validateTipoCombustivel,
          ),
        ));
  }

  IconData _getCombustivelIcon(TipoCombustivel? tipo) {
    switch (tipo) {
      case TipoCombustivel.gasolina:
        return Icons.local_gas_station;
      case TipoCombustivel.etanol:
        return Icons.eco;
      case TipoCombustivel.diesel:
      case TipoCombustivel.dieselS10:
        return Icons.local_shipping;
      case TipoCombustivel.gnv:
        return Icons.air;
      case TipoCombustivel.eletrico:
        return Icons.electric_car;
      case TipoCombustivel.biCombustivel:
        return Icons.local_gas_station;
      case null:
        return Icons.local_gas_station_outlined;
    }
  }

  Color _getCombustivelColor(TipoCombustivel? tipo) {
    switch (tipo) {
      case TipoCombustivel.gasolina:
        return Colors.red;
      case TipoCombustivel.etanol:
        return Colors.green;
      case TipoCombustivel.diesel:
        return Colors.orange;
      case TipoCombustivel.dieselS10:
        return Colors.deepOrange;
      case TipoCombustivel.gnv:
        return Colors.blue;
      case TipoCombustivel.eletrico:
        return Colors.teal;
      case TipoCombustivel.biCombustivel:
        return Colors.purple;
      case null:
        return Colors.grey;
    }
  }
}
