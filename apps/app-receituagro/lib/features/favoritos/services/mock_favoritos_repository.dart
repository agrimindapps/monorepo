import 'package:flutter/foundation.dart';
import '../models/favorito_defensivo_model.dart';
import '../models/favorito_praga_model.dart';
import '../models/favorito_diagnostico_model.dart';
import 'favoritos_data_service.dart';

class MockFavoritosRepository implements IFavoritosRepository {
  @override
  Future<List<FavoritoDefensivoModel>> getFavoritosDefensivos() async {
    await Future.delayed(const Duration(milliseconds: 500));
    
    return [
      FavoritoDefensivoModel(
        id: 1,
        idReg: 'DEF001',
        line1: 'Roundup Ultra',
        line2: 'Glifosato 480g/L',
        nomeComum: 'Roundup Ultra',
        ingredienteAtivo: 'Glifosato 480g/L',
        classeAgronomica: 'Herbicida',
        fabricante: 'Bayer',
        modoAcao: 'Sistêmico',
        dataCriacao: DateTime.now().subtract(const Duration(days: 5)),
      ),
      FavoritoDefensivoModel(
        id: 2,
        idReg: 'DEF002',
        line1: 'Connect',
        line2: 'Imidacloprido + Beta-ciflutrina',
        nomeComum: 'Connect',
        ingredienteAtivo: 'Imidacloprido + Beta-ciflutrina',
        classeAgronomica: 'Inseticida',
        fabricante: 'Bayer',
        modoAcao: 'Sistêmico + Contato',
        dataCriacao: DateTime.now().subtract(const Duration(days: 3)),
      ),
    ];
  }

  @override
  Future<List<FavoritoPragaModel>> getFavoritosPragas() async {
    await Future.delayed(const Duration(milliseconds: 300));
    
    return [
      FavoritoPragaModel(
        id: 1,
        idReg: 'PRAGA001',
        nomeComum: 'Lagarta da Soja',
        nomeSecundario: 'Anticarsia gemmatalis',
        nomeCientifico: 'Anticarsia gemmatalis',
        tipoPraga: '1', // Inseto
        descricao: 'Praga importante da cultura da soja',
        sintomas: 'Desfolha da soja',
        controle: 'Controle biológico e químico',
        dataCriacao: DateTime.now().subtract(const Duration(days: 7)),
      ),
      FavoritoPragaModel(
        id: 2,
        idReg: 'PRAGA002',
        nomeComum: 'Ferrugem Asiática',
        nomeCientifico: 'Phakopsora pachyrhizi',
        tipoPraga: '2', // Doença
        descricao: 'Doença fúngica da soja',
        sintomas: 'Pústulas amareladas nas folhas',
        controle: 'Aplicação de fungicidas',
        dataCriacao: DateTime.now().subtract(const Duration(days: 2)),
      ),
    ];
  }

  @override
  Future<List<FavoritoDiagnosticoModel>> getFavoritosDiagnosticos() async {
    await Future.delayed(const Duration(milliseconds: 400));
    
    return [
      FavoritoDiagnosticoModel(
        id: 1,
        idReg: 'DIAG001',
        nome: 'Diagnóstico de Ferrugem da Soja',
        descricao: 'Análise visual e laboratorial para identificação de ferrugem',
        cultura: 'Soja',
        categoria: 'Doença Fúngica',
        recomendacoes: 'Aplicação preventiva de fungicidas',
        dataCriacao: DateTime.now().subtract(const Duration(days: 1)),
      ),
    ];
  }

  @override
  Future<void> removeFavoritoDefensivo(int id) async {
    await Future.delayed(const Duration(milliseconds: 200));
    debugPrint('Mock: Removed defensivo favorite with id: $id');
  }

  @override
  Future<void> removeFavoritoPraga(int id) async {
    await Future.delayed(const Duration(milliseconds: 200));
    debugPrint('Mock: Removed praga favorite with id: $id');
  }

  @override
  Future<void> removeFavoritoDiagnostico(int id) async {
    await Future.delayed(const Duration(milliseconds: 200));
    debugPrint('Mock: Removed diagnostico favorite with id: $id');
  }
}