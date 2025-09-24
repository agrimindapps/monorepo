// import 'package:get/get.dart';

// import 'database_repository.dart';
// import '../../services/localstorage_service.dart';

// class FavoritoRepository {
//   static final FavoritoRepository _singleton = FavoritoRepository._internal();
//   factory FavoritoRepository() {
//     return _singleton;
//   }
//   FavoritoRepository._internal();

//   void init() {
//     carregaDefensivos();
//     carregaPragas();
//     carregarDiagnosticos();
//   }

//   RxList<dynamic> favDefensivos = [].obs;
//   RxList<dynamic> favDefensivosFiltered = [].obs;
//   RxList<dynamic> favPragas = [].obs;
//   RxList<dynamic> favPragasFiltered = [].obs;
//   RxList<dynamic> favDiagnostico = [].obs;
//   RxList<dynamic> favDiagnosticoFiltered = [].obs;

//   void carregaDefensivos() async {
//     List<String> favs =
//         await LocalStorageService().getFavoritos('favDefensivos');
//     List<dynamic> newList = DatabaseRepository().gFitossanitarios.where((row) {
//       return favs.contains(row['IdReg']);
//     }).toList();

//     favDefensivos
//       ..clear()
//       ..addAll(newList);
//     favDefensivosFiltered
//       ..clear()
//       ..addAll(newList);
//   }

//   void carregaPragas() async {
//     List<String> favs = await LocalStorageService().getFavoritos('favPragas');
//     List<dynamic> newList = DatabaseRepository().gPragas.where((row) {
//       return favs.contains(row['IdReg']);
//     }).toList();

//     favPragas
//       ..clear()
//       ..addAll(newList);
//     favPragasFiltered
//       ..clear()
//       ..addAll(newList);
//   }

//   void carregarDiagnosticos() async {
//     List<String> favs =
//         await LocalStorageService().getFavoritos('favDiagnostico');

//     List<dynamic> newList = DatabaseRepository().gDiagnosticos.where((row) {
//       return favs.contains(row['IdReg']);
//     }).map((row) {
//       final praga = DatabaseRepository()
//           .gPragas
//           .firstWhere((r) => r['IdReg'] == row['fkIdPraga']);
//       final fito = DatabaseRepository()
//           .gFitossanitarios
//           .firstWhere((r) => r['IdReg'] == row['fkIdDefensivo']);
//       final cult = DatabaseRepository()
//           .gCulturas
//           .firstWhere((r) => r['IdReg'] == row['fkIdCultura']);

//       final priNome = praga['nomeComum'].split(';');

//       return {
//         'IdReg': row['IdReg'],
//         'nomeComum': fito['nomeComum'],
//         'priNome': priNome[0],
//         'nomePraga': praga['nomeComum'],
//         'nomeCientifico': praga['nomeCientifico'],
//         'cultura': cult['cultura'],
//       };
//     }).toList();

//     favDiagnostico
//       ..clear()
//       ..addAll(newList);
//     favDiagnosticoFiltered
//       ..clear()
//       ..addAll(newList);
//   }

//   void filterList(List<dynamic> sourceList, List<dynamic> filteredList,
//       String text, List<String> keys) {
//     if (text.length > 2) {
//       final list = sourceList.where((row) {
//         return keys.any((key) =>
//             row[key]?.toString().toLowerCase().contains(text.toLowerCase()) ??
//             false);
//       }).toList();
//       filteredList.clear();
//       filteredList.addAll(list);
//     } else {
//       filteredList.clear();
//       filteredList.addAll(sourceList);
//     }
//   }

//   void filtraDefensivos(String text) {
//     filterList(
//         favDefensivos, favDefensivosFiltered, text, ['nomeComum', 'cultura']);
//   }

//   void filtraPragas(String text) {
//     filterList(favPragas, favPragasFiltered, text, ['nomeComum', 'cultura']);
//   }

//   void filtraDiagnosticos(String text) {
//     filterList(
//         favDiagnostico, favDiagnosticoFiltered, text, ['nomeComum', 'cultura']);
//   }
// }
