// import 'package:get/get.dart';

// import '../../models/database.dart';

// class DatabaseRepository {
//   static final DatabaseRepository _instance = DatabaseRepository._internal();
//   DatabaseRepository._internal();
//   factory DatabaseRepository() => _instance;

//   List<dynamic> gFitossanitarios = [];
//   List<dynamic> gDiagnosticos = [];
//   List<dynamic> gPlantasInf = [];
//   List<dynamic> gPragasInf = [];
//   List<dynamic> gPragas = [];
//   List<dynamic> gFitossanitariosInfo = [];
//   List<dynamic> gCulturas = [];

//   RxBool isLoaded = false.obs;

//   Future<void> carregaVariaveisPrimarias() async {
//     isLoaded.value = false;
//     var results = await Future.wait([
//       Database.getAll('tbfitossanitarios'),
//       Database.getAll('tbpragas'),
//       Database.getAll('tbculturas'),
//     ]);

//     gFitossanitarios = results[0];
//     gPragas = results[1];
//     gCulturas = results[2];
//   }

//   Future<void> carregaVariaveisSecundarias() async {
//     var results = await Future.wait([
//       Database.getAll('tbdiagnostico'),
//       Database.getAll('tbplantasinf'),
//       Database.getAll('tbpragasinf'),
//       Database.getAll('tbfitossanitariosinfo'),
//     ]);

//     gDiagnosticos = results[0];
//     gPlantasInf = results[1];
//     gPragasInf = results[2];
//     gFitossanitariosInfo = results[3];

//     isLoaded.value = true;
//   }
// }
