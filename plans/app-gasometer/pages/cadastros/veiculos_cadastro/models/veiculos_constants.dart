// Flutter imports:
import 'package:flutter/material.dart';

/// Constantes unificadas para o módulo de veículos
///
/// Centraliza TODAS as constantes relacionadas a veículos:
/// - Validação e regras de negócio
/// - Interface e apresentação
/// - Responsividade e layout
/// - Mensagens e textos
class VeiculosConstants {
  // ===========================================
  // SEÇÃO 1: VALIDAÇÃO E REGRAS DE NEGÓCIO
  // ===========================================

  /// Limites e validações numéricas
  static const int anoMinimo = 1900;
  static const int chassiComprimento = 17;
  static const int renavamComprimento = 11;
  static const int placaComprimento = 7;

  /// Padrões de validação regex consolidados
  static final RegExp placaMercosulRegex =
      RegExp(r'^[A-Z]{3}[0-9][A-Z][0-9]{2}$');
  static final RegExp placaAntigaRegex = RegExp(r'^[A-Z]{3}[0-9]{4}$');
  static final RegExp chassiRegex = RegExp(r'^[A-HJ-NPR-Z0-9]{17}$');

  /// Compatibilidade com padrão anterior
  static final RegExp placaRegex = RegExp(r'^[A-Z]{3}[0-9][A-Z0-9][0-9]{2}$');

  /// Mensagens de validação
  static const Map<String, String> mensagensValidacao = {
    'campoObrigatorio': 'Campo obrigatório',
    'anoObrigatorio': 'Ano obrigatório',
    'anoInvalido': 'Ano inválido',
    'placaInvalida': 'Formato inválido. Use ABC1234 ou ABC1D23',
    'chassiInvalido': 'Chassi inválido.',
    'combustivelObrigatorio': 'Selecione um combustível',
    'odometroMaiorQueAtual':
        'O odômetro inicial não pode ser maior que o atual',
  };

  /// Mensagens de erro do sistema
  static const Map<String, String> mensagensErro = {
    'carregarVeiculos': 'Erro ao carregar veículos.',
    'limiteVeiculos': 'Apenas 2 veículos podem ser cadastrados para testes.',
    'criarVeiculo': 'Não foi possível cadastrar o veículo. Tente novamente.',
    'inicializarControllers': 'Erro ao inicializar controllers',
    'verificarLancamentos': 'Erro ao verificar lançamentos',
  };

  /// Regras de validação consolidadas
  static Map<String, dynamic> regrasValidacao = {
    'anoMinimo': anoMinimo,
    'chassiComprimento': chassiComprimento,
    'renavamComprimento': renavamComprimento,
    'placaComprimento': placaComprimento,
    'placaRegex': placaRegex,
    'placaMercosulRegex': placaMercosulRegex,
    'placaAntigaRegex': placaAntigaRegex,
    'chassiRegex': chassiRegex,
  };

  // ===========================================
  // SEÇÃO 2: INTERFACE DO FORMULÁRIO
  // ===========================================

  /// Títulos dos diálogos
  static const Map<String, String> titulosDialogos = {
    'cadastrar': 'Cadastrar Veículo',
    'editar': 'Editar Veículo',
  };

  /// Títulos das seções do formulário
  static const Map<String, String> titulosSecoes = {
    'identificacao': 'Identificação do Veículo',
    'informacoesTecnicas': 'Informações Técnicas',
    'documentacao': 'Documentação',
  };

  /// Ícones das seções do formulário
  static const Map<String, IconData> iconesSecoes = {
    'identificacao': Icons.directions_car,
    'informacoesTecnicas': Icons.speed,
    'documentacao': Icons.description,
  };

  /// Rótulos dos campos do formulário
  static const Map<String, String> rotulosCampos = {
    'marca': 'Marca',
    'modelo': 'Modelo',
    'ano': 'Ano',
    'cor': 'Cor',
    'combustivel': 'Tipo de Combustível',
    'odometroAtual': 'Odômetro Atual',
    'odometroInicial': 'Odômetro Inicial',
    'placa': 'Placa',
    'chassi': 'Chassi',
    'renavam': 'Renavam',
  };

  /// Dicas para preenchimento dos campos
  static const Map<String, String> dicasCampos = {
    'marca': 'Ex: Ford, Volkswagen, etc.',
    'modelo': 'Ex: Gol, Fiesta, etc.',
    'cor': 'Ex: Branco, Preto, etc.',
    'odometroAtual': '0,00',
    'placa': 'Ex: ABC1234 ou ABC1D23',
    'chassi': 'Ex: 9BWZZZ377VT004251',
    'renavam': 'Ex: 12345678901',
  };

  /// Textos de ajuda contextuais
  static const Map<String, String> textosAjuda = {
    'odometroComLancamentos':
        'O odômetro inicial não pode ser alterado pois já existem lançamentos associados a este veículo.',
  };

  /// Ícones para tipos de combustível
  static const Map<String, IconData> iconesCombustivel = {
    'gasolina': Icons.local_gas_station,
    'etanol': Icons.eco,
    'diesel': Icons.local_shipping,
    'biCombustivel': Icons.sync,
    'eletrico': Icons.electric_car,
    'gnv': Icons.cloud,
  };

  /// Sufixos de unidades
  static const Map<String, String> sufixos = {
    'odometro': 'km',
    'quilometros': 'km',
  };

  /// IDs dos campos para GetBuilder
  static const Map<String, String> camposGetBuilder = {
    'marca': 'marca_field',
    'modelo': 'modelo_field',
    'ano': 'ano_field',
    'cor': 'cor_field',
    'placa': 'placa_field',
    'chassi': 'chassi_field',
    'renavam': 'renavam_field',
  };

  // ===========================================
  // SEÇÃO 3: INTERFACE DA PÁGINA DE LISTAGEM
  // ===========================================

  /// Títulos e rótulos da página
  static const Map<String, String> paginaTitulos = {
    'titulo': 'Veículos',
    'subtitulo': 'Gerenciamento de veículos',
    'semDadosTitulo': 'Nenhum veículo cadastrado',
    'semDadosSubtitulo': 'Adicione seu primeiro veículo para começar',
  };

  /// Rótulos dos botões
  static const Map<String, String> botoes = {
    'adicionar': 'Adicionar veículo',
    'editar': 'Editar',
  };

  /// Ícones da interface
  static const Map<String, IconData> icones = {
    'carro': Icons.directions_car,
    'carroOutline': Icons.directions_car_outlined,
    'editar': Icons.edit_outlined,
    'adicionar': Icons.add,
    'placa': Icons.credit_card,
    'combustivel': Icons.local_gas_station,
    'odometroInicial': Icons.trip_origin,
    'odometroAtual': Icons.speed,
  };

  /// Mensagens informativas
  static const Map<String, String> mensagensInfo = {
    'naoInformado': 'Não informado',
  };

  // ===========================================
  // SEÇÃO 4: RESPONSIVIDADE E LAYOUT
  // ===========================================

  /// Breakpoints responsivos
  static const double breakpointMobile = 600.0;
  static const double breakpointTablet = 900.0;
  static const double breakpointDesktop = 1200.0;
  static const double breakpointDesktopGrande = 1600.0;

  /// Configuração de grid responsivo
  static const int gridColunasMovel = 1;
  static const int gridColunasTablet = 2;
  static const int gridColunasDesktop = 3;
  static const int gridColunasDesktopGrande = 4;

  /// Configuração da página
  static const double larguraMaxima = 1120.0;

  /// Métodos helper para responsividade
  static bool isMovel(double largura) => largura < breakpointMobile;
  static bool isTablet(double largura) =>
      largura >= breakpointMobile && largura < breakpointTablet;
  static bool isDesktop(double largura) =>
      largura >= breakpointTablet && largura < breakpointDesktop;
  static bool isDesktopGrande(double largura) => largura >= breakpointDesktop;

  static int obterColunasGrid(double largura) {
    if (isMovel(largura)) return gridColunasMovel;
    if (isTablet(largura)) return gridColunasTablet;
    if (isDesktop(largura)) return gridColunasDesktop;
    return gridColunasDesktopGrande;
  }

  static Size obterTamanhoPreferido(double largura) {
    return Size.fromHeight(isMovel(largura) ? 72.0 : 72.0);
  }

  /// Dimensões e espaçamentos
  static const Map<String, double> dimensoes = {
    'borderRadiusCard': 12.0,
    'tamanhoIcone': 28.0,
    'tamanhoIconePequeno': 20.0,
    'raioAvatar': 24.0,
    'tamanhoIconeSemDados': 56.0,
    'padding': 8.0,
    'paddingPequeno': 8.0,
    'paddingContainerSemDados': 32.0,
    'espacamento': 16.0,
    'espacamentoPequeno': 8.0,
    'espacamentoGrid': 8.0,
    'larguraBorda': 1.0,
    'alturaDivisor': 16.0,
    'alturaSemDados': 250.0,
  };

  /// Tamanhos de fonte
  static const Map<String, double> tamanhosFonte = {
    'titulo': 18.0,
    'subtitulo': 14.0,
    'rotuloInfo': 14.0,
    'valorInfo': 14.0,
    'tituloSemDados': 20.0,
    'subtituloSemDados': 16.0,
  };

  /// Chaves de cores (serão resolvidas pelo tema)
  static const Map<String, String> chavesCores = {
    'bordaCard': 'cardBorder',
    'fundoAvatar': 'avatarBackground',
    'corIcone': 'iconColor',
    'fundoSemDados': 'noDataBackground',
    'iconeSemDados': 'noDataIcon',
  };
}
