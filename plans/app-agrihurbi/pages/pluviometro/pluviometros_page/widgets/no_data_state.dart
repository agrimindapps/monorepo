// Flutter imports:
import 'package:flutter/material.dart';

class NoDataStateWidget extends StatelessWidget {
  const NoDataStateWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 40),
          Icon(
            Icons.water_drop_outlined,
            size: 64,
            color: Colors.blue[300],
          ),
          const SizedBox(height: 24),
          const Text(
            'Nenhum pluviômetro cadastrado',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}
