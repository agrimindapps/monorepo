import 'package:core/core.dart';
import 'package:flutter/widgets.dart';

/// Ícones centralizados do app ReceitaAgro
///
/// Usa icons_plus (Bootstrap Icons) para consistência visual
/// e melhor adequação ao tema agrícola
class AppIcons {
  AppIcons._();

  // ===========================================
  // NAVEGAÇÃO PRINCIPAL
  // ===========================================

  /// Ícone de Defensivos (escudo com check - proteção)
  static const IconData defensivos = Bootstrap.shield_fill_check;

  /// Ícone de Defensivos outlined
  static const IconData defensivosOutlined = Bootstrap.shield_check;

  /// Ícone de Pragas (inseto)
  static const IconData pragas = Bootstrap.bug_fill;

  /// Ícone de Pragas outlined
  static const IconData pragasOutlined = Bootstrap.bug;

  /// Ícone de Favoritos
  static const IconData favoritos = Bootstrap.heart;

  /// Ícone de Favoritos preenchido
  static const IconData favoritosFill = Bootstrap.heart_fill;

  /// Ícone de Comentários
  static const IconData comentarios = Bootstrap.chat_left_text;

  /// Ícone de Comentários preenchido
  static const IconData comentariosFill = Bootstrap.chat_left_text_fill;

  /// Ícone de Configurações
  static const IconData configuracoes = Bootstrap.gear;

  /// Ícone de Configurações preenchido
  static const IconData configuracoesFill = Bootstrap.gear_fill;

  // ===========================================
  // TIPOS DE PRAGAS
  // ===========================================

  /// Ícone de Insetos
  static const IconData insetos = Bootstrap.bug_fill;

  /// Ícone de Doenças (vírus)
  static const IconData doencas = Bootstrap.virus;

  /// Ícone de Plantas daninhas
  static const IconData plantasDaninhas = Bootstrap.flower2;

  // ===========================================
  // AÇÕES COMUNS
  // ===========================================

  /// Ícone de Busca
  static const IconData busca = Bootstrap.search;

  /// Ícone de Filtro
  static const IconData filtro = Bootstrap.funnel;

  /// Ícone de Adicionar
  static const IconData adicionar = Bootstrap.plus_circle;

  /// Ícone de Editar
  static const IconData editar = Bootstrap.pencil;

  /// Ícone de Deletar
  static const IconData deletar = Bootstrap.trash;

  /// Ícone de Compartilhar
  static const IconData compartilhar = Bootstrap.share;

  /// Ícone de Info
  static const IconData info = Bootstrap.info_circle;

  /// Ícone de Alerta
  static const IconData alerta = Bootstrap.exclamation_triangle;

  /// Ícone de Sucesso
  static const IconData sucesso = Bootstrap.check_circle;

  /// Ícone de Erro
  static const IconData erro = Bootstrap.x_circle;

  // ===========================================
  // FUNCIONALIDADES ESPECÍFICAS
  // ===========================================

  /// Ícone de Diagnóstico
  static const IconData diagnostico = Bootstrap.clipboard_check;

  /// Ícone de Tecnologia de Aplicação
  static const IconData tecnologia = Bootstrap.droplet;

  /// Ícone de Segurança
  static const IconData seguranca = Bootstrap.shield_exclamation;

  /// Ícone de Dosagem
  static const IconData dosagem = Bootstrap.clipboard_data;

  /// Ícone de Calendário
  static const IconData calendario = Bootstrap.calendar3;

  /// Ícone de Notificações
  static const IconData notificacoes = Bootstrap.bell;

  /// Ícone de Premium
  static const IconData premium = Bootstrap.star_fill;

  /// Ícone de Usuário
  static const IconData usuario = Bootstrap.person_circle;

  /// Ícone de Sair/Logout
  static const IconData sair = Bootstrap.box_arrow_right;

  // ===========================================
  // HELPERS
  // ===========================================

  /// Retorna ícone de defensivo baseado no contexto
  static IconData getDefensivoIcon({bool outlined = false}) {
    return outlined ? defensivosOutlined : defensivos;
  }

  /// Retorna ícone de praga baseado no contexto
  static IconData getPragaIcon({bool outlined = false}) {
    return outlined ? pragasOutlined : pragas;
  }

  /// Retorna ícone de tipo de praga
  static IconData getTipoPragaIcon(String tipo) {
    switch (tipo.toLowerCase()) {
      case 'inseto':
      case 'insetos':
        return insetos;
      case 'doença':
      case 'doencas':
      case 'doenças':
        return doencas;
      case 'planta':
      case 'plantas':
      case 'planta daninha':
      case 'plantas daninhas':
        return plantasDaninhas;
      default:
        return pragas;
    }
  }
}
