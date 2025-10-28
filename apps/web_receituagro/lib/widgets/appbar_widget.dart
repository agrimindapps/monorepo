import 'package:flutter/material.dart';

Widget rowOpcoesMenuSuperior() {
  return Row(
    mainAxisAlignment: MainAxisAlignment.start,
    children: [
      const SizedBox(
        width: 1,
        height: 32,
      ),
      Padding(
        padding: const EdgeInsets.fromLTRB(8, 12, 4, 4),
        child: Image.asset('lib/assets/icon.png', width: 140),
      ),
    ],
  );
}
