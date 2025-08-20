// Package imports:
import 'package:shared_preferences/shared_preferences.dart';

class GraoModel {
  // Variáveis de estado
  double? _espigasPorPlanta;
  double? _fileirasPorEspiga;
  double? _graosPorFileira;
  double? _pesoMilSementes;
  double? _plantasM2;
  double? _resultado;

  // Getters e Setters
  double? get espigasPorPlanta => _espigasPorPlanta;
  set espigasPorPlanta(double? value) => _espigasPorPlanta = value;

  double? get fileirasPorEspiga => _fileirasPorEspiga;
  set fileirasPorEspiga(double? value) => _fileirasPorEspiga = value;

  double? get graosPorFileira => _graosPorFileira;
  set graosPorFileira(double? value) => _graosPorFileira = value;

  double? get pesoMilSementes => _pesoMilSementes;
  set pesoMilSementes(double? value) => _pesoMilSementes = value;

  double? get plantasM2 => _plantasM2;
  set plantasM2(double? value) => _plantasM2 = value;

  double? get resultado => _resultado;

  // Construtor
  GraoModel({
    double? espigasPorPlanta,
    double? fileirasPorEspiga,
    double? graosPorFileira,
    double? pesoMilSementes,
    double? plantasM2,
  }) {
    _espigasPorPlanta = espigasPorPlanta;
    _fileirasPorEspiga = fileirasPorEspiga;
    _graosPorFileira = graosPorFileira;
    _pesoMilSementes = pesoMilSementes;
    _plantasM2 = plantasM2;
  }

  // Classificação do rendimento
  String classificarRendimento() {
    if (_resultado == null) return '';
    if (_resultado! < 5000) return 'Baixo rendimento';
    if (_resultado! < 8000) return 'Rendimento médio';
    if (_resultado! < 12000) return 'Bom rendimento';
    return 'Excelente rendimento';
  }

  // Cálculo do rendimento
  void calcularRendimento() {
    if (!validarCampos()) {
      _resultado = null;
      return;
    }

    final espigasFileiras = (_espigasPorPlanta! * _fileirasPorEspiga!);
    final graosplantas = (_graosPorFileira! * _plantasM2!);
    _resultado = (espigasFileiras * graosplantas) * (_pesoMilSementes! / 1000);
  }

  // Validação dos campos
  bool validarCampos() {
    return _espigasPorPlanta != null &&
        _fileirasPorEspiga != null &&
        _graosPorFileira != null &&
        _pesoMilSementes != null &&
        _plantasM2 != null;
  }

  // Persistência
  Future<void> salvar(SharedPreferences prefs) async {
    await prefs.setDouble('grao_espigas_por_planta', _espigasPorPlanta ?? 0);
    await prefs.setDouble('grao_fileiras_por_espiga', _fileirasPorEspiga ?? 0);
    await prefs.setDouble('grao_graos_por_fileira', _graosPorFileira ?? 0);
    await prefs.setDouble('grao_peso_mil_sementes', _pesoMilSementes ?? 0);
    await prefs.setDouble('grao_plantas_m2', _plantasM2 ?? 0);
  }

  Future<void> carregar(SharedPreferences prefs) async {
    _espigasPorPlanta = prefs.getDouble('grao_espigas_por_planta');
    _fileirasPorEspiga = prefs.getDouble('grao_fileiras_por_espiga');
    _graosPorFileira = prefs.getDouble('grao_graos_por_fileira');
    _pesoMilSementes = prefs.getDouble('grao_peso_mil_sementes');
    _plantasM2 = prefs.getDouble('grao_plantas_m2');

    if (validarCampos()) {
      calcularRendimento();
    }
  }

  void limpar() {
    _espigasPorPlanta = null;
    _fileirasPorEspiga = null;
    _graosPorFileira = null;
    _pesoMilSementes = null;
    _plantasM2 = null;
    _resultado = null;
  }
}
