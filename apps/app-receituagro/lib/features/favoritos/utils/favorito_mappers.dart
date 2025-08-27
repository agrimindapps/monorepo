import '../domain/entities/favorito_entity.dart';
import '../models/favorito_defensivo_model.dart';
import '../models/favorito_diagnostico_model.dart';
import '../models/favorito_praga_model.dart';

/// Mappers automáticos para transição entre Models e Entities
/// Serão removidos gradualmente conforme refatoração avança
class FavoritoMappers {
  
  /// Converte Entity para Model (para compatibilidade temporária)
  static FavoritoDefensivoModel entityToDefensivoModel(FavoritoDefensivoEntity entity) {
    return FavoritoDefensivoModel(
      id: 0, // ID temporário, será removido
      idReg: entity.id,
      line1: entity.nomeComum,
      line2: entity.ingredienteAtivo,
      nomeComum: entity.nomeComum,
      ingredienteAtivo: entity.ingredienteAtivo,
      fabricante: entity.fabricante,
      dataCriacao: entity.adicionadoEm ?? DateTime.now(),
    );
  }

  static FavoritoPragaModel entityToPragaModel(FavoritoPragaEntity entity) {
    return FavoritoPragaModel(
      id: 0, // ID temporário, será removido
      idReg: entity.id,
      nomeComum: entity.nomeComum,
      nomeCientifico: entity.nomeCientifico,
      tipoPraga: entity.tipoPraga,
      dataCriacao: entity.adicionadoEm ?? DateTime.now(),
    );
  }

  static FavoritoDiagnosticoModel entityToDiagnosticoModel(FavoritoDiagnosticoEntity entity) {
    return FavoritoDiagnosticoModel(
      id: 0, // ID temporário, será removido
      idReg: entity.id,
      nome: entity.nome,
      cultura: entity.cultura,
      dataCriacao: entity.adicionadoEm ?? DateTime.now(),
    );
  }

  /// Converte Model para Entity (para migração)
  static FavoritoDefensivoEntity defensivoModelToEntity(FavoritoDefensivoModel model) {
    return FavoritoDefensivoEntity(
      id: model.idReg,
      nomeComum: model.nomeComum ?? model.line1,
      ingredienteAtivo: model.ingredienteAtivo ?? model.line2,
      fabricante: model.fabricante,
      adicionadoEm: model.dataCriacao,
    );
  }

  static FavoritoPragaEntity pragaModelToEntity(FavoritoPragaModel model) {
    return FavoritoPragaEntity(
      id: model.idReg,
      nomeComum: model.nomeComum,
      nomeCientifico: model.nomeCientifico ?? '',
      tipoPraga: model.tipoPraga,
      adicionadoEm: model.dataCriacao,
    );
  }

  static FavoritoDiagnosticoEntity diagnosticoModelToEntity(FavoritoDiagnosticoModel model) {
    return FavoritoDiagnosticoEntity(
      id: model.idReg,
      nomePraga: _extractPragaFromNome(model.nome),
      nomeDefensivo: _extractDefensivoFromNome(model.nome),
      cultura: model.cultura ?? '',
      dosagem: '', // Não disponível no model, será buscado quando necessário
      adicionadoEm: model.dataCriacao,
    );
  }

  /// Helpers privados
  static String _extractPragaFromNome(String nome) {
    final parts = nome.split(' → ');
    return parts.length > 1 ? parts[1] : nome;
  }

  static String _extractDefensivoFromNome(String nome) {
    final parts = nome.split(' → ');
    return parts.isNotEmpty ? parts[0] : nome;
  }
}

/// Extension methods para facilitar conversão
extension FavoritoEntityMappers on FavoritoEntity {
  /// Converte qualquer Entity para seu Model correspondente
  dynamic toModel() {
    if (this is FavoritoDefensivoEntity) {
      return FavoritoMappers.entityToDefensivoModel(this as FavoritoDefensivoEntity);
    } else if (this is FavoritoPragaEntity) {
      return FavoritoMappers.entityToPragaModel(this as FavoritoPragaEntity);
    } else if (this is FavoritoDiagnosticoEntity) {
      return FavoritoMappers.entityToDiagnosticoModel(this as FavoritoDiagnosticoEntity);
    }
    throw UnsupportedError('Tipo de entidade não suportado: $runtimeType');
  }
}

/// Extension methods para Models
extension FavoritoDefensivoModelMapper on FavoritoDefensivoModel {
  FavoritoDefensivoEntity toEntity() {
    return FavoritoMappers.defensivoModelToEntity(this);
  }
}

extension FavoritoPragaModelMapper on FavoritoPragaModel {
  FavoritoPragaEntity toEntity() {
    return FavoritoMappers.pragaModelToEntity(this);
  }
}

extension FavoritoDiagnosticoModelMapper on FavoritoDiagnosticoModel {
  FavoritoDiagnosticoEntity toEntity() {
    return FavoritoMappers.diagnosticoModelToEntity(this);
  }
}