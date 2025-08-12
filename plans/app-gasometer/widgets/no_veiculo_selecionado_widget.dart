// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../core/themes/manager.dart';

class NoVeiculoSelecionadoWidget extends StatefulWidget {
  const NoVeiculoSelecionadoWidget({super.key});

  @override
  State<NoVeiculoSelecionadoWidget> createState() =>
      _NoVeiculoSelecionadoWidgetState();
}

class _NoVeiculoSelecionadoWidgetState
    extends State<NoVeiculoSelecionadoWidget> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 300,
      height: MediaQuery.of(context).size.height * 0.58,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: ThemeManager().isDark.value
                  ? const Color(0xFF424242)
                  : const Color(0xFFF5F5F5),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.directions_car_outlined,
              color: Colors.black54,
              size: 56,
            ),
          ),
          const SizedBox(height: 24),
          // const Text(
          //   'Nenhum veículo cadastrado',
          //   style: TextStyle(
          //     fontSize: 20,
          //     fontWeight: FontWeight.bold,
          //   ),
          // ),
          // const SizedBox(height: 8),
          const Text(
            'Para começar, selecione um veículo ou insira o primeiro veiculo no menu de veículos.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}
