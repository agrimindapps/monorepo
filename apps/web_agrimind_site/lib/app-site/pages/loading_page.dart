// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:receituagro/app/repository/database_repository.dart';
// import 'package:receituagro/app/repository/pragas_repository.dart';

// import '../repository/defensivos_repository.dart';

// class CarregandoPage extends StatefulWidget {
//   const CarregandoPage({super.key});

//   @override
//   State<CarregandoPage> createState() => _CarregandoPageState();
// }

// class _CarregandoPageState extends State<CarregandoPage> {
//   @override
//   void initState() {
//     super.initState();
//     DatabaseRepository().carregaVariaveisPrimarias().then((value) {
//       DatabaseRepository().carregaVariaveisSecundarias();
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(body: Center(
//       child: Obx(() {
//         if (!DatabaseRepository().isLoaded.value) {
//           return const Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               CircularProgressIndicator(),
//               SizedBox(height: 20),
//               Text('Carregando dados para uso...'),
//             ],
//           );
//         } else {
//           Future.delayed(const Duration(milliseconds: 100), () {
//             DefensivosRepository().initInfo();
//             PragasRepository().initInfo();
//             Navigator.of(context).pushNamed('/home');
//           });
//           return const SizedBox();
//         }
//       }),
//     ));
//   }
// }
