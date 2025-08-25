import 'package:hive/hive.dart';

import '../models/favorito_defensivo_model.dart';
import '../models/favorito_diagnostico_model.dart';
import '../models/favorito_praga_model.dart';
import '../services/favoritos_data_service.dart';

class FavoritosHiveRepository implements IFavoritosRepository {
  final Box<dynamic> _defensivosBox;
  final Box<dynamic> _pragasBox;
  final Box<dynamic> _diagnosticosBox;

  FavoritosHiveRepository() 
    : _defensivosBox = Hive.box('favoritos_defensivos'),
      _pragasBox = Hive.box('favoritos_pragas'),
      _diagnosticosBox = Hive.box('favoritos_diagnosticos');

  @override
  Future<List<FavoritoDefensivoModel>> getFavoritosDefensivos() async {
    return _defensivosBox.values.cast<FavoritoDefensivoModel>().toList();
  }

  @override
  Future<List<FavoritoPragaModel>> getFavoritosPragas() async {
    return _pragasBox.values.cast<FavoritoPragaModel>().toList();
  }

  @override
  Future<List<FavoritoDiagnosticoModel>> getFavoritosDiagnosticos() async {
    return _diagnosticosBox.values.cast<FavoritoDiagnosticoModel>().toList();
  }

  @override
  Future<void> removeFavoritoDefensivo(int id) async {
    final index = _defensivosBox.values.toList().indexWhere((item) => item.id == id);
    if (index != -1) {
      await _defensivosBox.deleteAt(index);
    }
  }

  @override
  Future<void> removeFavoritoPraga(int id) async {
    final index = _pragasBox.values.toList().indexWhere((item) => item.id == id);
    if (index != -1) {
      await _pragasBox.deleteAt(index);
    }
  }

  @override
  Future<void> removeFavoritoDiagnostico(int id) async {
    final index = _diagnosticosBox.values.toList().indexWhere((item) => item.id == id);
    if (index != -1) {
      await _diagnosticosBox.deleteAt(index);
    }
  }
}