import 'package:flutter/material.dart';

class CupSlider extends StatefulWidget {
  final double maxValue; // Valor máximo do slider
  final double initialValue; // Valor inicial
  final ValueChanged<double> onChanged; // Callback para atualizar valor

  const CupSlider({
    super.key,
    required this.maxValue,
    required this.initialValue,
    required this.onChanged,
  });

  @override
  _CupSliderState createState() => _CupSliderState();
}

class _CupSliderState extends State<CupSlider> {
  late double _quantidade;

  @override
  void initState() {
    super.initState();
    _quantidade = widget.initialValue; // Inicializa com o valor passado
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          'Quantidade (mm)',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              alignment: Alignment.bottomCenter,
              children: [
                // Contorno do copo
                Container(
                  width: 100,
                  height: 200,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black, width: 2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                // Área preenchida (água)
                Container(
                  width: 96,
                  height: 196 *
                      (_quantidade /
                          widget.maxValue), // Altura proporcional ao valor
                  decoration: const BoxDecoration(
                    color: Colors.blueAccent,
                    borderRadius: BorderRadius.vertical(
                      bottom: Radius.circular(18),
                      top: Radius.circular(18),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 30),
            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                trackHeight: 10.0,
                thumbShape:
                    const RoundSliderThumbShape(enabledThumbRadius: 12.0),
                overlayShape:
                    const RoundSliderOverlayShape(overlayRadius: 24.0),
                activeTrackColor: Colors.blueAccent,
                inactiveTrackColor: Colors.grey[300],
                thumbColor: Colors.blue,
              ),
              child: RotatedBox(
                quarterTurns: 3, // Rotação do slider para vertical
                child: Slider(
                  value: _quantidade,
                  min: 0,
                  max: widget.maxValue,
                  divisions: widget.maxValue.toInt(),
                  label: _quantidade.toStringAsFixed(0),
                  onChanged: (double value) {
                    setState(() {
                      _quantidade = value;
                    });
                    widget
                        .onChanged(value); // Retorna o valor ao componente pai
                  },
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
