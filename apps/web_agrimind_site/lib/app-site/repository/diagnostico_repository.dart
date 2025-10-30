// import 'package:get/get.dart';

// import 'database_repository.dart';

// class DiagnosticoRepository {
//   // classe é um singleton
//   static final DiagnosticoRepository _singleton = DiagnosticoRepository._internal();
//   factory DiagnosticoRepository() {
//     return _singleton;
//   }
//   DiagnosticoRepository._internal();

//   RxMap<dynamic, dynamic> diagnosticoUnico = {
//     'IdReg': '',
//     'nomeDefensivo': '',
//     'nomePraga': '',
//     'nomeCientifico': '',
//     'cultura': '',
//     'ingredienteAtivo': '',
//     'toxico': '',
//     'classAmbiental': '',
//     'classeAgronomica': '',
//     'formulacao': '',
//     'modoAcao': '',
//     'mapa': '',
//     'dosagem': '',
//     'terrestre': '',
//     'aerea': '',
//     'intervaloAplicacao': '',
//     'intervaloSeguranca': '',
//     'tecnologia': '',
//   }.obs;

//   void getDiagnosticoDetalhes(String id) {
//     var globalVars = DatabaseRepository();
//     final diag = globalVars.gDiagnosticos.firstWhere((r) => r['IdReg'] == id, orElse: () => {});
//     final fito = globalVars.gFitossanitarios.firstWhere((r) => r['IdReg'] == diag['fkIdDefensivo'], orElse: () => {});
//     final prag = globalVars.gPragas.firstWhere((r) => r['IdReg'] == diag['fkIdPraga'], orElse: () => {});
//     final cult = globalVars.gCulturas.firstWhere((r) => r['IdReg'] == diag['fkIdCultura'], orElse: () => {});
//     final info = globalVars.gFitossanitariosInfo.firstWhere((r) => r['fkIdDefensivo'] == diag['fkIdDefensivo'], orElse: () => {});

//     diagnosticoUnico['IdReg'] = diag['IdReg'];
//     diagnosticoUnico['nomeDefensivo'] = fito['nomeComum'];
//     diagnosticoUnico['nomePraga'] = prag['nomeComum'];
//     diagnosticoUnico['nomeCientifico'] = prag['nomeCientifico'];
//     diagnosticoUnico['cultura'] = cult['cultura'];
//     diagnosticoUnico['ingredienteAtivo'] = fito['ingredienteAtivo'] + ' ' + fito['quantProduto'];
//     diagnosticoUnico['toxico'] = fito['toxico'];
//     diagnosticoUnico['classAmbiental'] = fito['classAmbiental'];
//     diagnosticoUnico['classeAgronomica'] = fito['classeAgronomica'];
//     diagnosticoUnico['formulacao'] = fito['formulacao'];
//     diagnosticoUnico['modoAcao'] = fito['modoAcao'];
//     diagnosticoUnico['mapa'] = fito['mapa'];
//     diagnosticoUnico['tecnologia'] = info['tecnologia'];

//     diagnosticoUnico['dosagem'] = (diag['dsMin']?.length ?? 0) > 0 && diag['dsMin'] != '-'
//         ? '${diag['dsMin']} - ${diag['dsMax']} ${diag['um']}'
//         : '${diag['dsMax']} ${diag['um']}';

//     diagnosticoUnico['vazaoTerrestre'] = formatVazao(diag['minAplicacaoT'], diag['maxAplicacaoT'], diag['umT'], 'Não Especificado');
//     diagnosticoUnico['vazaoAerea'] =
//         formatVazao(diag['minAplicacaoA'], diag['maxAplicacaoA'], diag['umA'], 'Não indicado para aplicações aéreas');

//     diagnosticoUnico['intervaloAplicacao'] = diag['intervalo']?.length > 0 ? diag['intervalo'] : 'Não Especificado';
//     diagnosticoUnico['intervaloSeguranca'] = diag['intervalo2']?.length > 0 ? diag['intervalo2'] : 'Não Especificado';
//   }

//   String formatVazao(String min, String max, String um, String defaultText) {
//     min = min.trim();
//     max = max.trim();
//     var vazao = max.isEmpty
//         ? min
//         : min.isNotEmpty
//             ? '$min - $max'
//             : max;
//     vazao = vazao.isNotEmpty ? '$vazao $um' : vazao;
//     return vazao == '' ? defaultText : vazao;
//   }
// }
