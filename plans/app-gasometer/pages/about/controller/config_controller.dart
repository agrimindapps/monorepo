// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:url_launcher/url_launcher.dart';

// Project imports:
import '../../../../../core/themes/manager.dart';
import '../../../../core/services/sync_firebase_service.dart';
import '../../../constants/atualizacao_const.dart';
import '../../../constants/config_const.dart';
import '../../../database/20_odometro_model.dart';
import '../../../database/21_veiculos_model.dart';
import '../../../database/22_despesas_model.dart';
import '../../../database/23_abastecimento_model.dart';
import '../../../database/25_manutencao_model.dart';
import '../../../repository/despesas_repository.dart';
import '../../../repository/manutecoes_repository.dart';
import '../../../repository/odometro_repository.dart';
import '../../../repository/veiculos_repository.dart';
import '../models/config_model.dart';

class ConfigController extends GetxController {
  final ConfigModel _model = ConfigModel();

  ConfigModel get model => _model;

  bool get isDarkTheme => ThemeManager().isDark.value;
  String get appVersion => atualizacoesText[0]['versao']!;
  String get appName => appEmailContato.split('@').first;

  Future<void> openExternalLink(String url, String path) async {
    try {
      final Uri toLaunch = Uri(scheme: 'https', host: url, path: path);
      if (await canLaunchUrl(toLaunch)) {
        await launchUrl(toLaunch);
      } else {
        _showError('Não foi possível abrir o link');
      }
    } catch (e) {
      _showError('Erro ao abrir link: $e');
    }
  }

  Future<void> openEmail(BuildContext context) async {
    try {
      final Uri toLaunch = Uri.parse(
        'mailto:$appEmailContato?subject=$appName%20-%20$appVersion%20|%20Problemas%20/%20Melhorias%20/%20Duvidas&body=Descreva%20aqui%20sua%20mensagem\n\n',
      );
      if (await canLaunchUrl(toLaunch)) {
        await launchUrl(toLaunch);
      } else {
        _showError('Não foi possível abrir o e-mail');
      }
    } catch (e) {
      _showError('Erro ao abrir e-mail: $e');
    }
  }

  void toggleTheme() {
    ThemeManager().toggleTheme();
    update();
  }

  void navigateToRoute(BuildContext context, String route) {
    Navigator.pushNamed(context, route);
  }

  void navigateToUpdates(BuildContext context) {
    _model.navigateToUpdates(context);
  }

  void exitApp(BuildContext context) {
    Navigator.pop(context);
  }

  Future<void> simulateTestData(BuildContext context) async {
    try {
      _showLoadingDialog(context, 'Gerando dados de teste...');

      // Usar SyncFirebaseService para abastecimentos (nova arquitetura)
      final syncService = SyncFirebaseService.getInstance<AbastecimentoCar>(
        'gasometer_abastecimentos',
        (map) => AbastecimentoCar.fromMap(map),
        (item) => item.toMap(),
      );
      await syncService.initialize();

      // Repositórios tradicionais para outros dados
      final veiculosRepo = VeiculosRepository();
      final despesasRepo = DespesasRepository();
      final manutencoesRepo = ManutencoesRepository();
      final odometroRepo = OdometroRepository();

      final now = DateTime.now();
      final timestamp = now.millisecondsSinceEpoch;

      // Criar 2 veículos de teste com quilometragem inicial realista
      final veiculo1 = VeiculoCar(
        id: 'veiculo1_test',
        createdAt: timestamp,
        updatedAt: timestamp,
        marca: 'Honda',
        modelo: 'Civic',
        ano: 2020,
        placa: 'ABC-1234',
        odometroInicial: 25000, // 4 anos de uso
        combustivel: 1, // Gasolina
        renavan: '00123456789',
        chassi: '9BWHE21JX24060831',
        cor: 'Branco',
        vendido: false,
        valorVenda: 0,
        odometroAtual: 25000,
      );

      final veiculo2 = VeiculoCar(
        id: 'veiculo2_test',
        createdAt: timestamp,
        updatedAt: timestamp,
        marca: 'Volkswagen',
        modelo: 'Gol',
        ano: 2018,
        placa: 'XYZ-9876',
        odometroInicial: 80000, // 6 anos de uso
        combustivel: 2, // Álcool
        renavan: '98765432100',
        chassi: '9BWGF07X82P004251',
        cor: 'Prata',
        vendido: false,
        valorVenda: 0,
        odometroAtual: 80000,
      );

      await veiculosRepo.addVeiculo(veiculo1);
      await veiculosRepo.addVeiculo(veiculo2);

      // Configurações realistas para cada veículo
      final veiculoConfigs = {
        veiculo1.id: {
          'kmPorMes': 1200, // 14.400 km/ano (uso urbano)
          'consumo': 12.0, // km/l
          'precoGasolina': 5.80,
          'tanque': 50,
        },
        veiculo2.id: {
          'kmPorMes': 800, // 9.600 km/ano (uso moderado)
          'consumo': 14.0, // km/l
          'precoAlcool': 4.20,
          'tanque': 45,
        },
      };

      // Gerar registros dos últimos 12 meses (cronologicamente correto)
      int recordCounter = 0;
      final veiculos = [veiculo1, veiculo2];

      for (final veiculo in veiculos) {
        final config = veiculoConfigs[veiculo.id]!;
        double quilometragemAtual = veiculo.odometroInicial.toDouble();

        // Começar de 12 meses atrás até hoje
        for (int monthsAgo = 12; monthsAgo >= 0; monthsAgo--) {
          final dataBase = DateTime(now.year, now.month - monthsAgo, 1);
          final kmDoMes = config['kmPorMes'] as int;
          final kmPorDia = kmDoMes / 30;

          // Eventos do mês (3-6 eventos por mês)
          final eventosNoMes = 3 + (monthsAgo % 4);

          for (int evento = 0; evento < eventosNoMes; evento++) {
            recordCounter++;

            // Progressão de data dentro do mês
            final diaDoEvento = 3 + (evento * (28 / eventosNoMes)).round();
            final dataEvento =
                DateTime(dataBase.year, dataBase.month, diaDoEvento);
            final timestampEvento = dataEvento.millisecondsSinceEpoch;

            // Progressão da quilometragem
            final kmPercorridos = (kmPorDia * diaDoEvento).round();
            quilometragemAtual = veiculo.odometroInicial +
                ((12 - monthsAgo) * kmDoMes) +
                kmPercorridos;

            // Decidir tipo de evento baseado na sequência
            final tipoEvento = _decidirTipoEvento(evento, monthsAgo,
                quilometragemAtual, veiculo.odometroInicial.toDouble());

            switch (tipoEvento) {
              case 'odometro':
                final odometro = OdometroCar(
                  id: 'odometro_test_$recordCounter',
                  createdAt: timestampEvento,
                  updatedAt: timestampEvento,
                  idVeiculo: veiculo.id,
                  data: timestampEvento,
                  odometro: quilometragemAtual.toDouble(),
                  descricao: _gerarDescricaoOdometro(evento),
                  tipoRegistro: 'normal',
                );
                await odometroRepo.addOdometro(odometro);
                break;

              case 'abastecimento':
                final preco = veiculo.combustivel == 1
                    ? config['precoGasolina'] as double
                    : config['precoAlcool'] as double;
                final tanque = config['tanque'] as int;
                final litros = (tanque * 0.7) +
                    ((tanque * 0.3) *
                        (evento / eventosNoMes)); // 70-100% do tanque

                final abastecimento = AbastecimentoCar(
                  id: 'abast_test_$recordCounter',
                  createdAt: timestampEvento,
                  updatedAt: timestampEvento,
                  veiculoId: veiculo.id,
                  data: timestampEvento,
                  odometro: quilometragemAtual,
                  litros: litros,
                  valorTotal: litros * preco,
                  tanqueCheio: litros > (tanque * 0.9),
                  precoPorLitro: preco +
                      ((-0.2 +
                          (0.4 *
                              (evento / eventosNoMes)))), // Variação de ±R$0.20
                  posto: _gerarPostoAleatorio(evento),
                  observacao: litros > (tanque * 0.9)
                      ? 'Tanque cheio'
                      : 'Abastecimento parcial',
                  tipoCombustivel: veiculo.combustivel,
                );
                await syncService.create(abastecimento);
                break;

              case 'despesa':
                final tipoDespesa = _gerarTipoDespesa(evento);
                final valor = _gerarValorDespesa(tipoDespesa, evento);

                final despesa = DespesaCar(
                  id: 'despesa_test_$recordCounter',
                  createdAt: timestampEvento,
                  updatedAt: timestampEvento,
                  veiculoId: veiculo.id,
                  data: timestampEvento,
                  tipo: tipoDespesa,
                  valor: valor,
                  descricao: _gerarDescricaoDespesa(tipoDespesa),
                  odometro: quilometragemAtual,
                );
                await despesasRepo.addDespesa(despesa);
                break;

              case 'manutencao':
                final tipoManutencao = _gerarTipoManutencao(
                    quilometragemAtual, veiculo.odometroInicial.toDouble());
                final valor = _gerarValorManutencao(tipoManutencao);

                final manutencao = ManutencaoCar(
                  id: 'manut_test_$recordCounter',
                  createdAt: timestampEvento,
                  updatedAt: timestampEvento,
                  veiculoId: veiculo.id,
                  data: timestampEvento,
                  tipo: tipoManutencao,
                  valor: valor,
                  descricao: _gerarDescricaoManutencao(tipoManutencao),
                  odometro: quilometragemAtual.toInt(),
                );
                await manutencoesRepo.addManutencao(manutencao);
                break;
            }
          }
        }

        // Atualizar quilometragem atual do veículo
        final veiculoAtualizado = VeiculoCar(
          id: veiculo.id,
          createdAt: veiculo.createdAt,
          updatedAt: timestamp,
          marca: veiculo.marca,
          modelo: veiculo.modelo,
          ano: veiculo.ano,
          placa: veiculo.placa,
          odometroInicial: veiculo.odometroInicial,
          combustivel: veiculo.combustivel,
          renavan: veiculo.renavan,
          chassi: veiculo.chassi,
          cor: veiculo.cor,
          vendido: veiculo.vendido,
          valorVenda: veiculo.valorVenda,
          odometroAtual: quilometragemAtual,
        );
        await veiculosRepo.updateVeiculo(veiculoAtualizado);
      }

      Get.back(); // Fechar loading apenas
      _showSuccessMessage('Dados de teste gerados com sucesso!');
    } catch (e) {
      Get.back(); // Fechar loading apenas
      _showError('Erro ao gerar dados de teste: $e');
    }
  }

  Future<void> removeAllData(BuildContext context) async {
    // Mostrar confirmação
    final confirm = await _showConfirmationDialog(
      context,
      'Confirmar Remoção',
      'Tem certeza que deseja remover TODOS os dados do banco local? Esta ação não pode ser desfeita.',
    );

    if (!confirm) return;

    if (!context.mounted) return;

    try {
      _showLoadingDialog(context, 'Removendo todos os dados...');

      // Limpar boxes usando referências seguras
      try {
        final veiculosBox = Hive.isBoxOpen('box_car_veiculos')
            ? Hive.box('box_car_veiculos')
            : await Hive.openBox('box_car_veiculos');
        await veiculosBox.clear();
      } catch (e) {
        debugPrint('Erro ao limpar box_car_veiculos: $e');
      }

      try {
        final abastecimentosBox = Hive.isBoxOpen('box_car_abastecimentos')
            ? Hive.box('box_car_abastecimentos')
            : await Hive.openBox('box_car_abastecimentos');
        await abastecimentosBox.clear();
      } catch (e) {
        debugPrint('Erro ao limpar box_car_abastecimentos: $e');
      }

      try {
        final despesasBox = Hive.isBoxOpen('box_car_despesas')
            ? Hive.box('box_car_despesas')
            : await Hive.openBox('box_car_despesas');
        await despesasBox.clear();
      } catch (e) {
        debugPrint('Erro ao limpar box_car_despesas: $e');
      }

      try {
        final manutencoesBox = Hive.isBoxOpen('box_car_manutencoes')
            ? Hive.box('box_car_manutencoes')
            : await Hive.openBox('box_car_manutencoes');
        await manutencoesBox.clear();
      } catch (e) {
        debugPrint('Erro ao limpar box_car_manutencoes: $e');
      }

      try {
        final odometrosBox = Hive.isBoxOpen('box_car_odometros')
            ? Hive.box('box_car_odometros')
            : await Hive.openBox('box_car_odometros');
        await odometrosBox.clear();
      } catch (e) {
        debugPrint('Erro ao limpar box_car_odometros: $e');
      }

      Get.back(); // Fechar loading apenas
      // _showSuccessMessage('Todos os dados foram removidos com sucesso!');
    } catch (e) {
      Get.back(); // Fechar loading apenas
      debugPrint('Erro detalhado ao remover dados: $e');
      // _showError('Erro ao remover dados: $e');
    }
  }

  void _showLoadingDialog(BuildContext context, String message) {
    Get.dialog(
      AlertDialog(
        content: Row(
          children: [
            const CircularProgressIndicator(),
            const SizedBox(width: 16),
            Expanded(child: Text(message)),
          ],
        ),
      ),
      barrierDismissible: false,
    );
  }

  Future<bool> _showConfirmationDialog(
    BuildContext context,
    String title,
    String message,
  ) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  void _showSuccessMessage(String message) {
    Get.snackbar(
      'Sucesso',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green,
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
    );
  }

  void _showError(String message) {
    Get.snackbar(
      'Erro',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red,
      colorText: Colors.white,
    );
  }

  // Helper methods for test data generation
  String _decidirTipoEvento(
      int evento, int monthsAgo, double quilometragem, double odometroInicial) {
    // Prioritizar abastecimentos (mais frequentes)
    if (evento % 3 == 0) return 'abastecimento';

    // Odômetro a cada 5.000 km ou primeiro evento do mês
    if (evento == 0 || (quilometragem - odometroInicial) % 5000 < 1000) {
      return 'odometro';
    }

    // Manutenções baseadas em quilometragem
    if ((quilometragem - odometroInicial) > 10000 && evento % 8 == 0) {
      return 'manutencao';
    }

    // Despesas ocasionais
    if (evento % 5 == 0) return 'despesa';

    return 'abastecimento'; // Padrão
  }

  String _gerarDescricaoOdometro(int evento) {
    final descricoes = [
      'Verificação mensal do odômetro',
      'Controle de quilometragem',
      'Registro de uso do veículo',
      'Acompanhamento de rodagem',
      'Verificação trimestral',
    ];
    return descricoes[evento % descricoes.length];
  }

  String _gerarPostoAleatorio(int evento) {
    final postos = [
      'Posto Ipiranga',
      'Shell Select',
      'BR Petrobras',
      'Posto Ale',
      'Raizen',
      'Posto Bandeira Branca',
    ];
    return postos[evento % postos.length];
  }

  String _gerarTipoDespesa(int evento) {
    final tipos = [
      'Estacionamento',
      'Pedágio',
      'Lavagem',
      'Seguro',
      'IPVA',
      'Multa',
      'Vistoria',
    ];
    return tipos[evento % tipos.length];
  }

  double _gerarValorDespesa(String tipo, int evento) {
    final baseValues = {
      'Estacionamento': 8.0,
      'Pedágio': 12.0,
      'Lavagem': 25.0,
      'Seguro': 150.0,
      'IPVA': 800.0,
      'Multa': 195.0,
      'Vistoria': 45.0,
    };

    final baseValue = baseValues[tipo] ?? 50.0;
    final variation = 1.0 + (evento % 6 - 3) * 0.1; // ±30% variação
    return baseValue * variation;
  }

  String _gerarDescricaoDespesa(String tipo) {
    final descricoes = {
      'Estacionamento': 'Estacionamento rotativo',
      'Pedágio': 'Taxa de pedágio',
      'Lavagem': 'Lavagem completa',
      'Seguro': 'Seguro do veículo',
      'IPVA': 'Imposto sobre veículo',
      'Multa': 'Multa de trânsito',
      'Vistoria': 'Vistoria veicular',
    };
    return descricoes[tipo] ?? 'Despesa geral';
  }

  String _gerarTipoManutencao(double quilometragem, double odometroInicial) {
    final kmPercorridos = quilometragem - odometroInicial;

    if (kmPercorridos > 40000) return 'Revisão Geral';
    if (kmPercorridos > 30000) return 'Troca de Pneus';
    if (kmPercorridos > 20000) return 'Alinhamento';
    if (kmPercorridos > 15000) return 'Troca de Óleo';
    if (kmPercorridos > 10000) return 'Filtros';

    return 'Revisão Básica';
  }

  double _gerarValorManutencao(String tipo) {
    final valores = {
      'Revisão Geral': 450.0,
      'Troca de Pneus': 800.0,
      'Alinhamento': 80.0,
      'Troca de Óleo': 120.0,
      'Filtros': 150.0,
      'Revisão Básica': 200.0,
    };
    return valores[tipo] ?? 250.0;
  }

  String _gerarDescricaoManutencao(String tipo) {
    final descricoes = {
      'Revisão Geral': 'Revisão completa do veículo',
      'Troca de Pneus': 'Substituição de pneus',
      'Alinhamento': 'Alinhamento e balanceamento',
      'Troca de Óleo': 'Troca de óleo e filtro',
      'Filtros': 'Troca de filtros do ar e combustível',
      'Revisão Básica': 'Revisão básica preventiva',
    };
    return descricoes[tipo] ?? 'Manutenção geral';
  }

  @override
  void onInit() {
    super.onInit();
    _model.initialize();
  }

  @override
  void onClose() {
    _model.dispose();
    super.onClose();
  }
}
