// Flutter imports:
// Package imports:
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:url_launcher/url_launcher.dart';

// Project imports:
import '../../../../../../core/themes/manager.dart';
import '../../../../core/pages/database_inspector_page.dart';
import '../../../../core/services/app_rating_service.dart';
import '../../../../core/services/database_inspector_service.dart';
import '../../../../core/services/sync_firebase_service.dart';
import '../../../database/20_odometro_model.dart';
import '../../../database/21_veiculos_model.dart';
import '../../../database/22_despesas_model.dart';
import '../../../database/23_abastecimento_model.dart';
import '../../../database/25_manutencao_model.dart';
import '../../../repository/despesas_repository.dart';
import '../../../repository/manutecoes_repository.dart';
import '../../../repository/odometro_repository.dart';
import '../../../repository/veiculos_repository.dart';
import '../../about/index.dart';
import '../../login_page.dart';
import '../../subscription/subscription_page.dart';
import '../models/settings_model.dart';

class SettingsController extends ChangeNotifier {
  final SettingsModel _model = SettingsModel();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  SettingsModel get model => _model;
  bool get isDarkTheme => ThemeManager().isDark.value;

  void initialize() {
    _model.initialize();
    _checkUserAuthStatus();
    notifyListeners();
  }

  void _checkUserAuthStatus() {
    final user = _auth.currentUser;
    if (user != null) {
      _model.setUserLoggedIn(
        true,
        email: user.email,
        name: user.displayName ?? user.email?.split('@')[0],
        photoUrl: user.photoURL,
      );
    } else {
      _model.logout();
    }
  }

  // Método para demonstração - simular login
  void simulateLogin() {
    _model.setUserLoggedIn(
      true,
      email: 'usuario@gasometer.com',
      name: 'João Silva',
      photoUrl: null,
    );
    notifyListeners();
  }

  // Método para demonstração - alternar status de login
  void toggleLoginStatus() {
    if (_model.isUserLoggedIn) {
      _model.logout();
    } else {
      simulateLogin();
    }
    notifyListeners();
  }

  // Método para demonstração - simular assinatura ativa
  void simulateActiveSubscription() {
    _model.setSubscriptionInfo(
      hasActive: !_model.hasActiveSubscription,
      type: _model.hasActiveSubscription ? '' : 'GasOMeter Premium',
      price: _model.hasActiveSubscription ? '' : 'R\$ 9,99/mês',
      progress: _model.hasActiveSubscription ? 0.0 : 65.0,
      days: _model.hasActiveSubscription ? '' : '10 dias restantes',
      renewal: _model.hasActiveSubscription
          ? null
          : DateTime.now().add(const Duration(days: 10)),
    );
    notifyListeners();
  }

  void navigateToSubscription(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const GasometerSubscriptionPage(),
      ),
    );
  }

  void toggleTheme() {
    ThemeManager().toggleTheme();
    notifyListeners();
  }

  void toggleNotifications() {
    _model.updateNotifications(!_model.notificationsEnabled);
    notifyListeners();
  }

  void toggleAutoSync() {
    _model.updateAutoSync(!_model.autoSyncEnabled);
    notifyListeners();
  }

  Future<void> logout(BuildContext context) async {
    try {
      await _auth.signOut();
      _model.logout();
      Get.snackbar(
        'Logout realizado',
        'Você foi desconectado com sucesso',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 2),
      );
      notifyListeners();
    } catch (e) {
      _showError('Erro ao fazer logout: $e');
    }
  }

  void navigateToLogin(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const LoginPage(),
      ),
    );
  }

  Future<void> syncData() async {
    try {
      Get.snackbar(
        'Sincronização iniciada',
        'Sincronizando seus dados...',
        backgroundColor: Colors.blue,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 2),
      );

      await Future.delayed(const Duration(seconds: 2));

      Get.snackbar(
        'Sincronização concluída',
        'Seus dados foram sincronizados com sucesso',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 3),
      );
    } catch (e) {
      _showError('Erro ao sincronizar dados: $e');
    }
  }

  void showDeleteAccountConfirmation(BuildContext context) {
    final isDark = ThemeManager().isDark.value;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF16213E) : Colors.white,
        title: Text(
          'Excluir Conta',
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        content: Text(
          'Esta ação é irreversível. Todos os seus dados serão permanentemente removidos. Tem certeza de que deseja excluir sua conta?',
          style: TextStyle(
            color: isDark ? Colors.grey.shade300 : Colors.grey.shade700,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancelar',
              style: TextStyle(
                color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteAccount();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade600,
              foregroundColor: Colors.white,
            ),
            child: const Text('Excluir Conta'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteAccount() async {
    try {
      Get.snackbar(
        'Processando',
        'Excluindo sua conta...',
        backgroundColor: Colors.orange,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 2),
      );

      // Simular exclusão da conta
      await Future.delayed(const Duration(seconds: 2));

      // Aqui você implementaria a lógica real de exclusão
      // await _auth.currentUser?.delete();

      _model.logout();
      notifyListeners();

      Get.snackbar(
        'Conta excluída',
        'Sua conta foi excluída com sucesso',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 3),
      );
    } catch (e) {
      _showError('Erro ao excluir conta: $e');
    }
  }

  void navigateToProfile(BuildContext context) {
    Navigator.pushNamed(context, '/profile');
  }

  void navigateToSecurity(BuildContext context) {
    Navigator.pushNamed(context, '/security');
  }

  void navigateToHelp(BuildContext context) {
    Navigator.pushNamed(context, '/help');
  }

  void navigateToAbout(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const OptionsPage(),
      ),
    );
  }

  void navigateToPrivacy(BuildContext context) {
    Navigator.pushNamed(context, '/privacy');
  }

  void navigateToTerms(BuildContext context) {
    Navigator.pushNamed(context, '/terms');
  }

  Future<void> openContactEmail() async {
    try {
      final Uri emailUri = Uri.parse(
        'mailto:${_model.contactEmail}?subject=GasOMeter - Contato&body=Descreva aqui sua mensagem\n\n',
      );
      if (await canLaunchUrl(emailUri)) {
        await launchUrl(emailUri);
      } else {
        _showError('Não foi possível abrir o cliente de email');
      }
    } catch (e) {
      _showError('Erro ao abrir email: $e');
    }
  }

  Future<void> openBugReport() async {
    try {
      final Uri emailUri = Uri.parse(
        'mailto:${_model.contactEmail}?subject=GasOMeter - Bug Report&body=Descreva o problema encontrado:\n\n- Versão do app: ${_model.appVersion}\n- Dispositivo: \n- Passos para reproduzir:\n\n',
      );
      if (await canLaunchUrl(emailUri)) {
        await launchUrl(emailUri);
      } else {
        _showError('Não foi possível abrir o cliente de email');
      }
    } catch (e) {
      _showError('Erro ao abrir email: $e');
    }
  }

  void showLanguageSelector(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Selecionar Idioma'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Português (Brasil)'),
              leading: Radio<String>(
                value: 'pt-BR',
                groupValue: _model.selectedLanguage,
                onChanged: (value) {
                  _model.updateLanguage(value!);
                  Navigator.pop(context);
                  notifyListeners();
                },
              ),
            ),
            ListTile(
              title: const Text('English (US)'),
              leading: Radio<String>(
                value: 'en-US',
                groupValue: _model.selectedLanguage,
                onChanged: (value) {
                  _model.updateLanguage(value!);
                  Navigator.pop(context);
                  notifyListeners();
                },
              ),
            ),
            ListTile(
              title: const Text('Español'),
              leading: Radio<String>(
                value: 'es-ES',
                groupValue: _model.selectedLanguage,
                onChanged: (value) {
                  _model.updateLanguage(value!);
                  Navigator.pop(context);
                  notifyListeners();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void showCurrencySelector(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Selecionar Moeda'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Real Brasileiro (R\$)'),
              leading: Radio<String>(
                value: 'BRL',
                groupValue: _model.selectedCurrency,
                onChanged: (value) {
                  _model.updateCurrency(value!);
                  Navigator.pop(context);
                  notifyListeners();
                },
              ),
            ),
            ListTile(
              title: const Text('Dólar Americano (US\$)'),
              leading: Radio<String>(
                value: 'USD',
                groupValue: _model.selectedCurrency,
                onChanged: (value) {
                  _model.updateCurrency(value!);
                  Navigator.pop(context);
                  notifyListeners();
                },
              ),
            ),
            ListTile(
              title: const Text('Euro (€)'),
              leading: Radio<String>(
                value: 'EUR',
                groupValue: _model.selectedCurrency,
                onChanged: (value) {
                  _model.updateCurrency(value!);
                  Navigator.pop(context);
                  notifyListeners();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> performBackup() async {
    try {
      Get.snackbar(
        'Backup iniciado',
        'Seus dados estão sendo salvos...',
        backgroundColor: Colors.blue,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 2),
      );

      // Simular backup
      await Future.delayed(const Duration(seconds: 2));

      Get.snackbar(
        'Backup concluído',
        'Seus dados foram salvos com sucesso',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 3),
      );
    } catch (e) {
      _showError('Erro ao fazer backup: $e');
    }
  }

  Future<void> exportData() async {
    try {
      Get.snackbar(
        'Exportação iniciada',
        'Preparando seus dados para download...',
        backgroundColor: Colors.blue,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 2),
      );

      // Simular exportação
      await Future.delayed(const Duration(seconds: 2));

      Get.snackbar(
        'Dados exportados',
        'Arquivo CSV salvo na pasta Downloads',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 3),
      );
    } catch (e) {
      _showError('Erro ao exportar dados: $e');
    }
  }

  Future<void> restorePurchases() async {
    try {
      Get.snackbar(
        'Restaurando compras',
        'Verificando assinaturas anteriores...',
        backgroundColor: Colors.blue,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 2),
      );

      // Simular restauração
      await Future.delayed(const Duration(seconds: 2));

      Get.snackbar(
        'Compras restauradas',
        'Suas assinaturas foram restauradas com sucesso',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 3),
      );
    } catch (e) {
      _showError('Erro ao restaurar compras: $e');
    }
  }

  Future<void> simulateTestData(BuildContext context) async {
    try {
      _showLoadingDialog(context, 'Gerando dados de teste...');

      // 1. LIMPEZA COMPLETA - Fechar e deletar todas as boxes
      await _clearAllHiveData();

      // 2. RECRIAR ESTRUTURA LIMPA
      final repositories = await _initializeRepositories();

      // 3. GERAR DADOS DE TESTE
      final testData = _generateTestDataStructure();

      // 4. PERSISTIR DADOS
      await _persistTestData(repositories, testData);

      Get.back();
      _showSuccessMessage(
          '✅ Dados de teste gerados com sucesso!\n📊 2 veículos, 14 meses de histórico');
    } catch (e) {
      Get.back();
      _showError('❌ Erro ao gerar dados de teste: $e');
      debugPrint('Erro completo na simulação: $e');
    }
  }

  Future<void> _clearAllHiveData() async {
    debugPrint('🧹 Iniciando limpeza completa do Hive...');

    final boxNames = [
      'box_car_veiculos',
      'box_car_abastecimentos',
      'box_car_despesas',
      'box_car_manutencoes',
      'box_car_odometros'
    ];

    for (final boxName in boxNames) {
      try {
        if (Hive.isBoxOpen(boxName)) {
          final box = Hive.box(boxName);
          await box.clear();
          await box.close();
        }
        // Deletar o arquivo da box fisicamente
        await Hive.deleteBoxFromDisk(boxName);
        debugPrint('✅ Box $boxName limpa e removida');
      } catch (e) {
        debugPrint('⚠️ Erro ao limpar box $boxName: $e');
      }
    }

    debugPrint('🧹 Limpeza completa finalizada');
  }

  Future<Map<String, dynamic>> _initializeRepositories() async {
    debugPrint('🔧 Inicializando repositórios...');

    // Reabrir boxes com estrutura limpa
    final veiculosRepo = VeiculosRepository();
    final despesasRepo = DespesasRepository();
    final manutencoesRepo = ManutencoesRepository();
    final odometroRepo = OdometroRepository();

    // Reinicializar SyncFirebaseService
    final syncService = SyncFirebaseService.getInstance<AbastecimentoCar>(
      'gasometer_abastecimentos',
      (map) => AbastecimentoCar.fromMap(map),
      (item) => item.toMap(),
    );
    await syncService.initialize();

    debugPrint('✅ Repositórios inicializados');

    return {
      'veiculos': veiculosRepo,
      'despesas': despesasRepo,
      'manutencoes': manutencoesRepo,
      'odometro': odometroRepo,
      'abastecimentos': syncService,
    };
  }

  Map<String, dynamic> _generateTestDataStructure() {
    debugPrint('📊 Gerando estrutura de dados de teste...');

    final now = DateTime.now();
    final timestamp = now.millisecondsSinceEpoch;

    // Dados dos veículos
    final veiculos = [
      {
        'id': 'honda_civic_2020',
        'marca': 'Honda',
        'modelo': 'Civic',
        'ano': 2020,
        'placa': 'HND-2020',
        'odometroInicial': 15000.0,
        'combustivel': 1, // Gasolina
        'cor': 'Prata',
        'renavan': '12345678901',
        'chassi': '9BWHE21JX24060831',
      },
      {
        'id': 'vw_gol_2018',
        'marca': 'Volkswagen',
        'modelo': 'Gol',
        'ano': 2018,
        'placa': 'VWG-2018',
        'odometroInicial': 45000.0,
        'combustivel': 2, // Álcool
        'cor': 'Branco',
        'renavan': '98765432100',
        'chassi': '9BWGF07X82P004251',
      }
    ];

    // Gerar registros temporais
    final registros = <Map<String, dynamic>>[];
    int counter = 1;

    for (int mes = 0; mes < 14; mes++) {
      final dataBase = DateTime(now.year, now.month - mes, 1);

      for (final veiculo in veiculos) {
        final registrosPorMes = 2 + (mes % 3); // 2-4 registros por mês

        for (int registro = 0; registro < registrosPorMes; registro++) {
          final dia = (5 + (registro * 7)).clamp(1, 28);
          final data = DateTime(dataBase.year, dataBase.month, dia);
          final odometroInicial =
              (veiculo['odometroInicial'] as double?) ?? 0.0;
          final odometro = odometroInicial + (mes * 1200) + (registro * 150);

          registros.add({
            'id': counter++,
            'veiculoId': veiculo['id'],
            'data': data,
            'odometro': odometro,
            'mes': mes,
            'registro': registro,
          });
        }
      }
    }

    debugPrint(
        '📊 Estrutura gerada: ${veiculos.length} veículos, ${registros.length} registros');

    return {
      'veiculos': veiculos,
      'registros': registros,
      'timestamp': timestamp,
    };
  }

  Future<void> _persistTestData(
      Map<String, dynamic> repos, Map<String, dynamic> testData) async {
    debugPrint('💾 Persistindo dados de teste...');

    final veiculosRepo = repos['veiculos'] as VeiculosRepository;
    final abastecimentosService =
        repos['abastecimentos'] as SyncFirebaseService<AbastecimentoCar>;
    final despesasRepo = repos['despesas'] as DespesasRepository;
    final manutencoesRepo = repos['manutencoes'] as ManutencoesRepository;
    final odometroRepo = repos['odometro'] as OdometroRepository;

    final veiculos = testData['veiculos'] as List;
    final registros = testData['registros'] as List;
    final timestamp = testData['timestamp'] as int;

    // 1. Criar veículos
    final veiculosModels = <VeiculoCar>[];
    for (final veiculo in veiculos) {
      final veiculoModel = VeiculoCar(
        id: veiculo['id'],
        createdAt: timestamp,
        updatedAt: timestamp,
        isDeleted: false,
        needsSync: false, // Dados de teste não precisam ser sincronizados
        lastSyncAt: timestamp,
        version: 1,
        marca: veiculo['marca'],
        modelo: veiculo['modelo'],
        ano: veiculo['ano'],
        placa: veiculo['placa'],
        odometroInicial: veiculo['odometroInicial'],
        combustivel: veiculo['combustivel'],
        renavan: veiculo['renavan'],
        chassi: veiculo['chassi'],
        cor: veiculo['cor'],
        vendido: false,
        valorVenda: 0.0,
        odometroAtual: veiculo['odometroInicial'], // Será atualizado depois
      );

      await veiculosRepo.addVeiculo(veiculoModel);
      veiculosModels.add(veiculoModel);
      debugPrint('✅ Veículo criado: ${veiculo['marca']} ${veiculo['modelo']}');
    }

    // 2. Criar registros baseados na estrutura
    for (final registro in registros) {
      final dataTimestamp =
          (registro['data'] as DateTime).millisecondsSinceEpoch;
      final id = registro['id'];
      final odometro = (registro['odometro'] as num).toDouble();

      // Sempre criar registro de odômetro
      final odometroRecord = OdometroCar(
        id: 'odo_$id',
        createdAt: dataTimestamp,
        updatedAt: dataTimestamp,
        isDeleted: false,
        needsSync: false, // Dados de teste não precisam ser sincronizados
        lastSyncAt: dataTimestamp,
        version: 1,
        idVeiculo: registro['veiculoId'],
        data: dataTimestamp,
        odometro: odometro,
        descricao: 'Registro automático',
        tipoRegistro: 'automatico',
      );
      await odometroRepo.addOdometro(odometroRecord);

      // Abastecimento (a cada 2 registros)
      if (registro['registro'] % 2 == 0) {
        final veiculo =
            veiculos.firstWhere((v) => v['id'] == registro['veiculoId']);
        final abastecimento = AbastecimentoCar(
          id: 'abast_$id',
          createdAt: dataTimestamp,
          updatedAt: dataTimestamp,
          isDeleted: false,
          needsSync: false, // Dados de teste não precisam ser sincronizados
          lastSyncAt: dataTimestamp,
          version: 1,
          veiculoId: registro['veiculoId'],
          data: dataTimestamp,
          odometro: odometro,
          litros: 35.0 + (registro['registro'] * 3),
          valorTotal: 180.0 + (registro['registro'] * 15),
          tanqueCheio: true,
          precoPorLitro: 5.2 + (registro['mes'] * 0.05),
          posto: registro['mes'] % 3 == 0
              ? 'Shell'
              : registro['mes'] % 3 == 1
                  ? 'Petrobras'
                  : 'Ipiranga',
          observacao: 'Abastecimento automático',
          tipoCombustivel: veiculo['combustivel'],
        );
        await abastecimentosService.create(abastecimento);
      }

      // Despesa (a cada 3 registros)
      if (registro['registro'] % 3 == 0) {
        final tipos = ['Estacionamento', 'Pedágio', 'Lavagem', 'Multa'];
        final despesa = DespesaCar(
          id: 'desp_$id',
          createdAt: dataTimestamp,
          updatedAt: dataTimestamp,
          isDeleted: false,
          needsSync: false, // Dados de teste não precisam ser sincronizados
          lastSyncAt: dataTimestamp,
          version: 1,
          veiculoId: registro['veiculoId'],
          data: dataTimestamp,
          tipo: tipos[registro['mes'] % tipos.length],
          valor: 15.0 + (registro['registro'] * 8),
          descricao: 'Despesa automática',
          odometro: odometro,
        );
        await despesasRepo.addDespesa(despesa);
      }

      // Manutenção (a cada 5 meses, primeiro registro do mês)
      if (registro['mes'] % 5 == 0 && registro['registro'] == 0) {
        final tipos = [
          'Revisão',
          'Troca de óleo',
          'Alinhamento',
          'Balanceamento'
        ];
        final manutencao = ManutencaoCar(
          id: 'manut_$id',
          createdAt: dataTimestamp,
          updatedAt: dataTimestamp,
          isDeleted: false,
          needsSync: false, // Dados de teste não precisam ser sincronizados
          lastSyncAt: dataTimestamp,
          version: 1,
          veiculoId: registro['veiculoId'],
          data: dataTimestamp,
          tipo: tipos[registro['mes'] % tipos.length],
          valor: 120.0 + (registro['mes'] * 20),
          descricao: 'Manutenção automática',
          odometro: odometro.toInt(),
        );
        await manutencoesRepo.addManutencao(manutencao);
      }
    }

    // 3. Atualizar odometroAtual dos veículos
    for (int i = 0; i < veiculosModels.length; i++) {
      final veiculo = veiculosModels[i];
      final ultimosRegistros =
          registros.where((r) => r['veiculoId'] == veiculo.id).toList();
      if (ultimosRegistros.isNotEmpty) {
        ultimosRegistros.sort(
            (a, b) => (b['data'] as DateTime).compareTo(a['data'] as DateTime));
        final ultimoOdometro =
            (ultimosRegistros.first['odometro'] as num).toDouble();

        final veiculoAtualizado = VeiculoCar(
          id: veiculo.id,
          createdAt: veiculo.createdAt,
          updatedAt: DateTime.now().millisecondsSinceEpoch,
          isDeleted: veiculo.isDeleted,
          needsSync: false, // Dados de teste não precisam ser sincronizados
          lastSyncAt: DateTime.now().millisecondsSinceEpoch,
          version: veiculo.version + 1,
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
          odometroAtual: ultimoOdometro,
          foto: veiculo.foto,
        );
        await veiculosRepo.updateVeiculo(veiculoAtualizado);
        debugPrint(
            '✅ Odômetro atualizado: ${veiculo.marca} ${veiculo.modelo} -> ${ultimoOdometro.toInt()} km');
      }
    }

    debugPrint('💾 Persistência concluída com sucesso!');
  }

  Future<void> removeAllData(BuildContext context) async {
    final confirm = await _showConfirmationDialog(
      context,
      'Confirmar Remoção',
      'Tem certeza que deseja remover TODOS os dados do banco local? Esta ação não pode ser desfeita.',
    );

    if (!confirm) return;

    if (!context.mounted) return;

    try {
      _showLoadingDialog(context, 'Removendo todos os dados...');

      debugPrint('🧹 Iniciando remoção de todos os dados...');

      final boxNames = [
        'box_car_veiculos',
        'box_car_abastecimentos',
        'box_car_despesas',
        'box_car_manutencoes',
        'box_car_odometros'
      ];

      for (final boxName in boxNames) {
        try {
          if (Hive.isBoxOpen(boxName)) {
            final box = Hive.box(boxName);
            await box.clear();
            debugPrint('✅ Box $boxName limpa');
          } else {
            // Tentar abrir a box se ela existir
            try {
              final box = await Hive.openBox(boxName);
              await box.clear();
              debugPrint('✅ Box $boxName aberta e limpa');
            } catch (openError) {
              debugPrint(
                  '⚠️ Box $boxName não existe ou não pôde ser aberta: $openError');
            }
          }
        } catch (e) {
          debugPrint('⚠️ Erro ao limpar box $boxName: $e');
        }
      }

      Get.back(); // Fechar loading apenas
      _showSuccessMessage('Todos os dados foram removidos com sucesso!');
      debugPrint('🧹 Remoção de dados concluída');
    } catch (e) {
      Get.back(); // Fechar loading apenas
      _showError('Erro ao remover dados: $e');
      debugPrint('❌ Erro na remoção de dados: $e');
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
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.green,
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
    );
  }

  void _showError(String message) {
    Get.snackbar(
      'Erro',
      message,
      backgroundColor: Colors.red,
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP,
      duration: const Duration(seconds: 3),
    );
  }

  /// Lida com a solicitação de avaliação do app
  Future<void> handleAppRating() async {
    try {
      final success = await AppRatingService.instance.requestRating();
      if (!success) {
        // Se não conseguir mostrar o diálogo nativo, abre a loja diretamente
        await AppRatingService.instance.openStoreListing();
      }
    } catch (e) {
      // Em caso de erro, tenta abrir a loja como fallback
      try {
        await AppRatingService.instance.openStoreListing();
      } catch (fallbackError) {
        _showError('Erro ao abrir avaliação do app: $fallbackError');
      }
    }
  }

  /// Navega para o inspetor de banco de dados
  void navigateToDatabaseInspector(BuildContext context) {
    DatabaseInspectorPage.navigate(
      context,
      initialStorageType: StorageType.hive,
      customTitle: 'Inspetor de Banco',
      primaryColor: const Color.fromARGB(255, 46, 55, 107),
    );
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }
}
