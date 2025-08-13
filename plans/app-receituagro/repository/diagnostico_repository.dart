// Package imports:
import 'package:get/get.dart';

// Project imports:
import 'database_repository.dart';

class DiagnosticoRepository {
  // Constants
  static const String _notSpecified = 'Não Especificado';
  static const String _noAerialApplication =
      'Não indicado para aplicações aéreas';

  DiagnosticoRepository();

  // Main Methods
  Map<String, dynamic>? getDiagnosticoDetalhes(String id) {
    final data = _fetchDiagnosticData(id);
    if (data == null) return null;

    final diagnosticoUnico = <String, dynamic>{};

    _populateDiagnosticoBasico(diagnosticoUnico, data);
    _populateDiagnosticoDosagem(diagnosticoUnico, data.diag);
    _populateDiagnosticoVazoes(diagnosticoUnico, data.diag);
    _populateDiagnosticoIntervalos(diagnosticoUnico, data.diag);

    return diagnosticoUnico;
  }

  // Data Fetching
  _DiagnosticData? _fetchDiagnosticData(String id) {
    // Usar a instância compartilhada em vez de criar uma nova
    final db = Get.find<DatabaseRepository>();
    // Corrigido: converter Diagnostico para Map usando toJson()
    final diag = db.gDiagnosticos.map((d) => d.toJson()).firstWhere(
          (r) => r['idReg'] == id,
          orElse: () => {},
        );
    if (diag.isEmpty) return null;

    return _DiagnosticData(
      diag: diag,
      fito: db.gFitossanitarios.map((f) => f.toJson()).firstWhere(
            (r) => r['idReg'] == diag['fkIdDefensivo'],
            orElse: () => {},
          ),
      praga: db.gPragas.map((p) => p.toJson()).firstWhere(
            (r) => r['idReg'] == diag['fkIdPraga'],
            orElse: () => {},
          ),
      cultura: db.gCulturas.map((c) => c.toJson()).firstWhere(
            (r) => r['idReg'] == diag['fkIdCultura'],
            orElse: () => {},
          ),
      info: db.gFitossanitariosInfo.map((f) => f.toJson()).firstWhere(
            (r) => r['fkIdDefensivo'] == diag['fkIdDefensivo'],
            orElse: () => {},
          ),
    );
  }

  // Update Methods
  void _populateDiagnosticoBasico(
      Map<String, dynamic> diagnosticoUnico, _DiagnosticData data) {
    diagnosticoUnico.addAll({
      'idReg': data.diag['idReg'],
      'nomeDefensivo': data.fito['nomeComum'],
      'nomePraga': data.praga['nomeComum'],
      'nomeCientifico': data.praga['nomeCientifico'],
      'cultura': data.cultura['cultura'],
      'ingredienteAtivo':
          '${data.fito['ingredienteAtivo']} ${data.fito['quantProduto']}',
      'toxico': data.fito['toxico'],
      'classAmbiental': data.fito['classAmbiental'],
      'classeAgronomica': data.fito['classeAgronomica'],
      'formulacao': data.fito['formulacao'],
      'modoAcao': data.fito['modoAcao'],
      'mapa': data.fito['mapa'],
      'tecnologia': data.info['tecnologia'],
    });
  }

  void _populateDiagnosticoDosagem(
      Map<String, dynamic> diagnosticoUnico, Map<String, dynamic> diag) {
    diagnosticoUnico['dosagem'] = _formatDosagem(
      diag['dsMin'] ?? '',
      diag['dsMax'] ?? '',
      diag['um'] ?? '',
    );
  }

  void _populateDiagnosticoVazoes(
      Map<String, dynamic> diagnosticoUnico, Map<String, dynamic> diag) {
    diagnosticoUnico.addAll({
      'vazaoTerrestre': _formatVazao(
        diag['minAplicacaoT'] ?? '',
        diag['maxAplicacaoT'] ?? '',
        diag['umT'] ?? '',
        _notSpecified,
      ),
      'vazaoAerea': _formatVazao(
        diag['minAplicacaoA'] ?? '',
        diag['maxAplicacaoA'] ?? '',
        diag['umA'] ?? '',
        _noAerialApplication,
      ),
    });
  }

  void _populateDiagnosticoIntervalos(
      Map<String, dynamic> diagnosticoUnico, Map<String, dynamic> diag) {
    diagnosticoUnico.addAll({
      'intervaloAplicacao': _formatInterval(diag['intervalo']),
      'intervaloSeguranca': _formatInterval(diag['intervalo2']),
    });
  }

  // Helper formatting methods
  String _formatDosagem(String min, String max, String um) {
    if (min.isEmpty && max.isEmpty) return _notSpecified;
    if (min == max) return '$min $um';
    return '$min a $max $um';
  }

  String _formatVazao(String min, String max, String um, String defaultValue) {
    if (min.isEmpty && max.isEmpty) return defaultValue;
    if (min == max) return '$min $um';
    return '$min a $max $um';
  }

  String _formatInterval(dynamic interval) {
    if (interval == null || interval.toString().isEmpty) return _notSpecified;
    return '$interval dias';
  }
}

// Helper Class
class _DiagnosticData {
  final Map<String, dynamic> diag;
  final Map<String, dynamic> fito;
  final Map<String, dynamic> praga;
  final Map<String, dynamic> cultura;
  final Map<String, dynamic> info;

  _DiagnosticData({
    required this.diag,
    required this.fito,
    required this.praga,
    required this.cultura,
    required this.info,
  });
}
