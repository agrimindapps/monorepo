import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

enum DefensivosAgrupadosCategory {
  defensivos('defensivos'),
  fabricantes('fabricantes'),
  classeAgronomica('classeAgronomica'),
  ingredienteAtivo('ingredienteAtivo'),
  modoAcao('modoAcao');

  const DefensivosAgrupadosCategory(this.value);
  final String value;

  static DefensivosAgrupadosCategory fromString(String value) {
    return DefensivosAgrupadosCategory.values.firstWhere(
      (category) => category.value == value,
      orElse: () => DefensivosAgrupadosCategory.defensivos,
    );
  }

  String get title {
    switch (this) {
      case DefensivosAgrupadosCategory.defensivos:
        return 'Defensivos';
      case DefensivosAgrupadosCategory.fabricantes:
        return 'Fabricantes';
      case DefensivosAgrupadosCategory.classeAgronomica:
        return 'Classe Agronômica';
      case DefensivosAgrupadosCategory.ingredienteAtivo:
        return 'Ingrediente Ativo';
      case DefensivosAgrupadosCategory.modoAcao:
        return 'Modo de Ação';
    }
  }

  String get label {
    switch (this) {
      case DefensivosAgrupadosCategory.fabricantes:
        return 'Fabricante';
      case DefensivosAgrupadosCategory.classeAgronomica:
        return 'Classe';
      case DefensivosAgrupadosCategory.ingredienteAtivo:
        return 'Ingrediente';
      case DefensivosAgrupadosCategory.modoAcao:
        return 'Modo de Ação';
      default:
        return '';
    }
  }

  String get pluralLabel {
    switch (this) {
      case DefensivosAgrupadosCategory.fabricantes:
        return 'Fabricantes';
      case DefensivosAgrupadosCategory.classeAgronomica:
        return 'Classes';
      case DefensivosAgrupadosCategory.ingredienteAtivo:
        return 'Ingredientes';
      case DefensivosAgrupadosCategory.modoAcao:
        return 'Modos de Ação';
      default:
        return 'Defensivos';
    }
  }

  IconData get icon {
    switch (this) {
      case DefensivosAgrupadosCategory.fabricantes:
        return FontAwesomeIcons.industry;
      case DefensivosAgrupadosCategory.classeAgronomica:
        return FontAwesomeIcons.listUl;
      case DefensivosAgrupadosCategory.ingredienteAtivo:
        return FontAwesomeIcons.flask;
      case DefensivosAgrupadosCategory.modoAcao:
        return FontAwesomeIcons.bolt;
      default:
        return FontAwesomeIcons.shield;
    }
  }

  String get emptyStateMessage {
    switch (this) {
      case DefensivosAgrupadosCategory.fabricantes:
        return 'Nenhum fabricante encontrado';
      case DefensivosAgrupadosCategory.classeAgronomica:
        return 'Nenhuma classe agronômica encontrada';
      case DefensivosAgrupadosCategory.ingredienteAtivo:
        return 'Nenhum ingrediente ativo encontrado';
      case DefensivosAgrupadosCategory.modoAcao:
        return 'Nenhum modo de ação encontrado';
      default:
        return 'Nenhum defensivo encontrado';
    }
  }

  String get searchHint {
    switch (this) {
      case DefensivosAgrupadosCategory.fabricantes:
        return 'Buscar fabricantes...';
      case DefensivosAgrupadosCategory.classeAgronomica:
        return 'Buscar classes...';
      case DefensivosAgrupadosCategory.ingredienteAtivo:
        return 'Buscar ingredientes...';
      case DefensivosAgrupadosCategory.modoAcao:
        return 'Buscar modos de ação...';
      default:
        return 'Buscar defensivos...';
    }
  }
}