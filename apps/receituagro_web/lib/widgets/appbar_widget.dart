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
      // Spacer(),
      // Padding(
      //   padding: const EdgeInsets.fromLTRB(25, 12, 25, 4),
      //   child: TextButton(
      //     style: ButtonStyle(
      //       backgroundColor: WidgetStateProperty.all(Colors.transparent),
      //       foregroundColor: WidgetStateProperty.all(Colors.green),
      //     ),
      //     onPressed: () {
      //       Navigator.pushNamed(context, '/');
      //     },
      //     child: const Text(
      //       'NutriTuti',
      //       style: TextStyle(color: Colors.black),
      //     ),
      //   ),
      // ),
      // Padding(
      //   padding: const EdgeInsets.fromLTRB(25, 12, 25, 4),
      //   child: TextButton(
      //     style: ButtonStyle(
      //       backgroundColor: WidgetStateProperty.all(Colors.transparent),
      //       foregroundColor: WidgetStateProperty.all(Colors.green),
      //     ),
      //     onPressed: () {
      //       Navigator.pushNamed(context, '/');
      //     },
      //     child: const Text(
      //       'Termus',
      //       style: TextStyle(color: Colors.black),
      //     ),
      //   ),
      // ),
      // Padding(
      //   padding: const EdgeInsets.fromLTRB(25, 12, 25, 4),
      //   child: TextButton(
      //     style: ButtonStyle(
      //       backgroundColor: WidgetStateProperty.all(Colors.transparent),
      //       foregroundColor: WidgetStateProperty.all(Colors.green),
      //     ),
      //     onPressed: () {
      //       Navigator.pushNamed(context, '/');
      //     },
      //     child: const Text(
      //       'AgriHurbi',
      //       style: TextStyle(color: Colors.black),
      //     ),
      //   ),
      // ),
    ],
  );
}
