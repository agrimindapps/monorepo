import 'package:core/core.dart';
import 'package:flutter/material.dart';

import '../../../auth/presentation/notifiers/notifiers.dart';

class AccountDeletionPage extends ConsumerStatefulWidget {
  const AccountDeletionPage({super.key});

  @override
  ConsumerState<AccountDeletionPage> createState() =>
      _AccountDeletionPageState();
}

class _AccountDeletionPageState extends ConsumerState<AccountDeletionPage> {
  final scrollController = ScrollController();
  bool _isDeleting = false;
  bool _confirmationChecked = false;
  final GlobalKey _introSection = GlobalKey();
  final GlobalKey _whatDeletedSection = GlobalKey();
  final GlobalKey _consequencesSection = GlobalKey();
  final GlobalKey _thirdPartySection = GlobalKey();
  final GlobalKey _processSection = GlobalKey();
  final GlobalKey _confirmationSection = GlobalKey();
  final GlobalKey _contactSection = GlobalKey();

  void _scrollToSection(GlobalKey key) {
    final context = key.currentContext;
    if (context != null) {
      Scrollable.ensureVisible(
        context,
        duration: const Duration(milliseconds: 800),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _handleAccountDeletion() async {
    if (!_confirmationChecked || _isDeleting) return;

    final authState = ref.read(authProvider);
    final authNotifier = ref.read(authProvider.notifier);
    String? currentPassword;
    if (authState.isAuthenticated && !authState.isAnonymous) {
      currentPassword = await _showPasswordDialog();
      if (currentPassword == null || currentPassword.isEmpty) {
        return; // User cancelled or didn't provide password
      }
    }
    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => AlertDialog(
            title: const Row(
              children: [
                Icon(Icons.warning, color: Colors.red),
                SizedBox(width: 8),
                Text('Confirmação Final'),
              ],
            ),
            content: const Text(
              'Esta ação não pode ser desfeita. Todos os seus dados serão permanentemente deletados em até 30 dias.\n\nDeseja realmente prosseguir com a exclusão da conta?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Confirmar Exclusão'),
              ),
            ],
          ),
    );

    if (confirmed != true) return;

    setState(() => _isDeleting = true);

    try {
      await authNotifier.deleteAccount(currentPassword: currentPassword);
      final errorMessage = ref.read(authProvider).errorMessage;
      if (errorMessage != null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMessage),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 5),
            ),
          );
        }
        return;
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Conta deletada com sucesso. Você será redirecionado para a tela inicial.',
            ),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );
        await Future<void>.delayed(const Duration(seconds: 2));
        if (mounted) {
          context.go('/login');
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao deletar conta: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isDeleting = false);
      }
    }
  }

  Future<String?> _showPasswordDialog() async {
    final TextEditingController passwordController = TextEditingController();

    return showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (context) => _PasswordDialog(controller: passwordController),
    );
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          SingleChildScrollView(
            controller: scrollController,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                _buildIntroduction(),
                _buildWhatWillBeDeleted(),
                _buildConsequences(),
                _buildThirdPartyServices(),
                _buildProcess(),
                _buildConfirmationSection(),
                _buildContact(),
                _buildFooter(),
              ],
            ),
          ),
          _buildNavBar(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      height: 300,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.red.shade800, Colors.red.shade600],
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 70), // Espaço para a barra de navegação
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.white.withValues(alpha: 0.1),
                  blurRadius: 9,
                  offset: const Offset(0, 3),
                  spreadRadius: 0,
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(9),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: const Icon(
                    Icons.delete_forever,
                    color: Colors.white,
                    size: 19,
                  ),
                ),
                const SizedBox(width: 13),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Exclusão de Conta',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                          height: 1.2,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 3),
                      Text(
                        'GasOMeter - Direito ao Esquecimento (LGPD/GDPR)',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
                          height: 1.3,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavBar() {
    return Container(
      height: 70,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isMobile = MediaQuery.of(context).size.width < 800;

          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () => context.go('/promo'),
                child: Row(
                  children: [
                    Icon(
                      Icons.local_gas_station,
                      color: Colors.blue.shade700,
                      size: 28,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'GasOMeter',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade800,
                      ),
                    ),
                  ],
                ),
              ),
              if (isMobile)
                PopupMenuButton<String>(
                  icon: const Icon(Icons.menu),
                  onSelected: (value) {
                    switch (value) {
                      case 'intro':
                        _scrollToSection(_introSection);
                        break;
                      case 'what_deleted':
                        _scrollToSection(_whatDeletedSection);
                        break;
                      case 'consequences':
                        _scrollToSection(_consequencesSection);
                        break;
                      case 'third_party':
                        _scrollToSection(_thirdPartySection);
                        break;
                      case 'process':
                        _scrollToSection(_processSection);
                        break;
                      case 'confirmation':
                        _scrollToSection(_confirmationSection);
                        break;
                      case 'contact':
                        _scrollToSection(_contactSection);
                        break;
                    }
                  },
                  itemBuilder: (BuildContext context) {
                    return [
                      const PopupMenuItem(
                        value: 'intro',
                        child: Text('Introdução'),
                      ),
                      const PopupMenuItem(
                        value: 'what_deleted',
                        child: Text('O que será deletado'),
                      ),
                      const PopupMenuItem(
                        value: 'consequences',
                        child: Text('Consequências'),
                      ),
                      const PopupMenuItem(
                        value: 'third_party',
                        child: Text('Serviços Terceiros'),
                      ),
                      const PopupMenuItem(
                        value: 'process',
                        child: Text('Processo'),
                      ),
                      const PopupMenuItem(
                        value: 'confirmation',
                        child: Text('Confirmação'),
                      ),
                      const PopupMenuItem(
                        value: 'contact',
                        child: Text('Contato'),
                      ),
                    ];
                  },
                )
              else
                Row(
                  children: [
                    _navBarButton(
                      'Introdução',
                      () => _scrollToSection(_introSection),
                    ),
                    _navBarButton(
                      'O que será deletado',
                      () => _scrollToSection(_whatDeletedSection),
                    ),
                    _navBarButton(
                      'Consequências',
                      () => _scrollToSection(_consequencesSection),
                    ),
                    _navBarButton(
                      'Serviços Terceiros',
                      () => _scrollToSection(_thirdPartySection),
                    ),
                    _navBarButton(
                      'Processo',
                      () => _scrollToSection(_processSection),
                    ),
                    _navBarButton(
                      'Confirmação',
                      () => _scrollToSection(_confirmationSection),
                    ),
                    _navBarButton(
                      'Contato',
                      () => _scrollToSection(_contactSection),
                    ),
                  ],
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _navBarButton(String title, VoidCallback onPressed) {
    return TextButton(
      onPressed: onPressed,
      child: Text(
        title,
        style: TextStyle(color: Colors.grey[800], fontSize: 14),
      ),
    );
  }

  Widget _buildIntroduction() {
    return Container(
      key: _introSection,
      padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 24),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Direito à Exclusão de Dados',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Container(width: 60, height: 4, color: Colors.red.shade700),
              const SizedBox(height: 30),
              _buildParagraph(
                'De acordo com a Lei Geral de Proteção de Dados (LGPD) brasileira e o Regulamento Geral sobre Proteção de Dados (GDPR) europeu, você tem o direito fundamental ao esquecimento, também conhecido como direito ao apagamento.',
              ),
              const SizedBox(height: 16),
              _buildParagraph(
                'Este direito permite que você solicite a exclusão completa e permanente de todos os seus dados pessoais coletados e processados pelo GasOMeter.',
              ),
              const SizedBox(height: 16),
              _buildParagraph(
                'Esta página foi criada para facilitar o exercício deste direito de forma transparente, segura e em conformidade com todas as regulamentações aplicáveis.',
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  border: const Border(
                    left: BorderSide(width: 4, color: Colors.orange),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(Icons.warning, color: Colors.orange.shade600),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'ATENÇÃO: Esta ação é irreversível e todos os seus dados serão permanentemente deletados.',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.orange.shade800,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWhatWillBeDeleted() {
    return Container(
      key: _whatDeletedSection,
      padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 24),
      color: Colors.grey[50],
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'O que será Deletado',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Container(width: 60, height: 4, color: Colors.red.shade700),
              const SizedBox(height: 30),
              _buildParagraph(
                'Ao solicitar a exclusão da sua conta, os seguintes dados serão permanentemente removidos de nossos sistemas:',
              ),
              const SizedBox(height: 20),
              _buildDataCategoryCard('Dados da Conta', Icons.person, [
                'Informações de perfil (nome, email)',
                'Dados de autenticação',
                'Preferências e configurações',
                'Histórico de login e sessões',
              ]),
              const SizedBox(height: 16),
              _buildDataCategoryCard('Dados dos Veículos', Icons.car_repair, [
                'Informações dos veículos cadastrados',
                'Histórico de abastecimentos',
                'Registros de manutenção',
                'Dados do odômetro',
              ]),
              const SizedBox(height: 16),
              _buildDataCategoryCard('Dados Financeiros', Icons.attach_money, [
                'Registros de despesas',
                'Relatórios de custos',
                'Estatísticas de consumo',
                'Dados de assinaturas premium',
              ]),
              const SizedBox(height: 16),
              _buildDataCategoryCard('Dados Técnicos', Icons.analytics, [
                'Logs de uso da aplicação',
                'Dados de analytics anonimizados',
                'Informações de crash reports',
                'Dados de sincronização',
              ]),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDataCategoryCard(
    String title,
    IconData icon,
    List<String> items,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.red.shade600, size: 24),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          for (final item in items)
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '• ',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Expanded(
                    child: Text(
                      item,
                      style: TextStyle(
                        fontSize: 15,
                        height: 1.5,
                        color: Colors.grey[700],
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildConsequences() {
    return Container(
      key: _consequencesSection,
      padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 24),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Consequências da Exclusão',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Container(width: 60, height: 4, color: Colors.red.shade700),
              const SizedBox(height: 30),
              _buildParagraph(
                'É importante entender as consequências permanentes da exclusão da sua conta:',
              ),
              const SizedBox(height: 20),
              _buildConsequenceCard(
                'Perda Completa de Dados',
                Icons.data_usage,
                'Todos os dados de veículos, abastecimentos, manutenções e relatórios serão perdidos permanentemente.',
                Colors.red,
              ),
              const SizedBox(height: 16),
              _buildConsequenceCard(
                'Cancelamento de Assinatura Premium',
                Icons.star,
                'Sua assinatura premium será automaticamente cancelada sem direito a reembolso proporcional.',
                Colors.orange,
              ),
              const SizedBox(height: 16),
              _buildConsequenceCard(
                'Impossibilidade de Recuperação',
                Icons.restore,
                'Não será possível recuperar os dados após a confirmação da exclusão, mesmo contatando o suporte.',
                Colors.red,
              ),
              const SizedBox(height: 16),
              _buildConsequenceCard(
                'Interrupção da Sincronização',
                Icons.sync_disabled,
                'A sincronização entre dispositivos será interrompida e dados locais podem permanecer no dispositivo.',
                Colors.blue,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildConsequenceCard(
    String title,
    IconData icon,
    String description,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 15,
                    height: 1.5,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThirdPartyServices() {
    return Container(
      key: _thirdPartySection,
      padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 24),
      color: Colors.grey[50],
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Serviços de Terceiros',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Container(width: 60, height: 4, color: Colors.red.shade700),
              const SizedBox(height: 30),
              _buildParagraph(
                'O GasOMeter utiliza serviços de terceiros que também processam seus dados. A exclusão afetará os seguintes serviços:',
              ),
              const SizedBox(height: 20),
              _buildThirdPartyCard(
                'Firebase Authentication',
                'Dados de autenticação e perfil serão completamente removidos dos servidores do Google Firebase.',
                Icons.security,
              ),
              const SizedBox(height: 16),
              _buildThirdPartyCard(
                'Firebase Cloud Firestore',
                'Todos os documentos e coleções associados à sua conta serão deletados permanentemente.',
                Icons.cloud_off,
              ),
              const SizedBox(height: 16),
              _buildThirdPartyCard(
                'RevenueCat (Assinaturas)',
                'Sua assinatura será cancelada e os dados de cobrança serão removidos conforme as políticas da RevenueCat.',
                Icons.payment,
              ),
              const SizedBox(height: 16),
              _buildThirdPartyCard(
                'Google Analytics',
                'Dados analíticos associados ao seu ID serão removidos ou anonimizados conforme as políticas do Google.',
                Icons.analytics,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildThirdPartyCard(
    String service,
    String description,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.blue.shade600, size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  service,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 15,
                    height: 1.5,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProcess() {
    return Container(
      key: _processSection,
      padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 24),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Como Funciona o Processo',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Container(width: 60, height: 4, color: Colors.red.shade700),
              const SizedBox(height: 30),
              _buildParagraph(
                'O processo de exclusão da conta seguirá os seguintes passos:',
              ),
              const SizedBox(height: 20),
              _buildProcessStep(
                '1',
                'Confirmação',
                'Você deve marcar a caixa de confirmação e clicar no botão "Excluir Conta" nesta página.',
              ),
              _buildProcessStep(
                '2',
                'Verificação de Identidade',
                'Para sua segurança, será solicitada a confirmação da sua senha atual antes de prosseguir.',
              ),
              _buildProcessStep(
                '3',
                'Processamento Imediato',
                'Sua conta será imediatamente desativada e você será desconectado de todos os dispositivos.',
              ),
              _buildProcessStep(
                '4',
                'Período de Retenção',
                'Os dados serão mantidos por até 30 dias em sistemas de backup para cumprimento de obrigações legais.',
              ),
              _buildProcessStep(
                '5',
                'Exclusão Definitiva',
                'Após 30 dias, todos os dados serão permanentemente removidos de todos os sistemas e backups.',
              ),
              const SizedBox(height: 30),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info, color: Colors.blue.shade600),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Prazo Legal',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue.shade800,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'De acordo com a LGPD, temos até 30 dias para processar completamente sua solicitação de exclusão.',
                            style: TextStyle(
                              fontSize: 15,
                              height: 1.5,
                              color: Colors.blue.shade700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProcessStep(String step, String title, String description) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.red.shade600,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                step,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 15,
                    height: 1.5,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConfirmationSection() {
    return Container(
      key: _confirmationSection,
      padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 24),
      color: Colors.red.shade50,
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Confirmar Exclusão da Conta',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Container(width: 60, height: 4, color: Colors.red.shade700),
              const SizedBox(height: 30),
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.warning,
                          color: Colors.red.shade600,
                          size: 28,
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            'Ação Irreversível',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Ao marcar a caixa abaixo e clicar em "Excluir Conta", você confirma que:',
                      style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                    ),
                    const SizedBox(height: 16),
                    _buildConfirmationItem(
                      'Entende que esta ação não pode ser desfeita',
                    ),
                    _buildConfirmationItem(
                      'Aceita a perda permanente de todos os dados',
                    ),
                    _buildConfirmationItem(
                      'Concorda com o cancelamento da assinatura premium',
                    ),
                    _buildConfirmationItem(
                      'Leu e entendeu as consequências descritas acima',
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Checkbox(
                          value: _confirmationChecked,
                          onChanged:
                              _isDeleting
                                  ? null
                                  : (value) {
                                    setState(() {
                                      _confirmationChecked = value ?? false;
                                    });
                                  },
                          activeColor: Colors.red.shade600,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Confirmo que li, entendi e aceito todas as condições acima',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[800],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton.icon(
                        onPressed:
                            _confirmationChecked && !_isDeleting
                                ? _handleAccountDeletion
                                : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red.shade600,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        icon:
                            _isDeleting
                                ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                )
                                : const Icon(Icons.delete_forever),
                        label: Text(
                          _isDeleting
                              ? 'Excluindo Conta...'
                              : 'Excluir Conta Permanentemente',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildConfirmationItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.check_circle, color: Colors.red.shade600, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 15,
                height: 1.4,
                color: Colors.grey[700],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContact() {
    return Container(
      key: _contactSection,
      padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 24),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Precisa de Ajuda?',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Container(width: 60, height: 4, color: Colors.red.shade700),
              const SizedBox(height: 30),
              _buildParagraph(
                'Se você tem dúvidas sobre o processo de exclusão ou sobre seus direitos de proteção de dados, nossa equipe está pronta para ajudar.',
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.support_agent, color: Colors.blue.shade600),
                        const SizedBox(width: 12),
                        Text(
                          'Suporte Especializado',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade800,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Email: agrimind.br@gmail.com',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.blue.shade700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Resposta em até 24 horas úteis',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.blue.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              _buildParagraph(
                'Nosso compromisso é garantir que seus direitos sejam respeitados de acordo com a LGPD e GDPR.',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
      color: Colors.blue.shade900,
      child: Center(
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.local_gas_station,
                  color: Colors.white.withValues(alpha: 0.9),
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  'GasOMeter',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              '© ${DateTime.now().year} Agrimind Apps. Todos os direitos reservados.',
              style: TextStyle(
                fontSize: 14,
                color: Colors.white.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _footerLink(
                  'Política de Privacidade',
                  () => context.go('/privacy'),
                ),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 10),
                  height: 12,
                  width: 1,
                  color: Colors.white.withValues(alpha: 0.4),
                ),
                _footerLink('Termos de Uso', () => context.go('/terms')),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 10),
                  height: 12,
                  width: 1,
                  color: Colors.white.withValues(alpha: 0.4),
                ),
                _footerLink('Exclusão de Conta', () {}),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _footerLink(String title, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          color: Colors.white.withValues(alpha: 0.7),
        ),
      ),
    );
  }

  Widget _buildParagraph(String text) {
    return Text(
      text,
      style: TextStyle(fontSize: 16, height: 1.6, color: Colors.grey[800]),
      textAlign: TextAlign.justify,
    );
  }
}

class _PasswordDialog extends StatefulWidget {
  const _PasswordDialog({required this.controller});
  final TextEditingController controller;

  @override
  State<_PasswordDialog> createState() => _PasswordDialogState();
}

class _PasswordDialogState extends State<_PasswordDialog> {
  bool _isPasswordVisible = false;
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_updateButtonState);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_updateButtonState);
    super.dispose();
  }

  void _updateButtonState() {
    setState(() {
      _hasText = widget.controller.text.trim().isNotEmpty;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.security, color: Colors.blue),
          SizedBox(width: 12),
          Text('Confirmação de Identidade'),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Por questões de segurança, confirme sua senha atual para prosseguir com a exclusão da conta.',
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 24),
          TextField(
            controller: widget.controller,
            obscureText: !_isPasswordVisible,
            autofocus: true,
            decoration: InputDecoration(
              labelText: 'Senha atual',
              hintText: 'Digite sua senha atual',
              prefixIcon: const Icon(Icons.lock),
              suffixIcon: IconButton(
                icon: Icon(
                  _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                ),
                onPressed:
                    () => setState(
                      () => _isPasswordVisible = !_isPasswordVisible,
                    ),
              ),
              border: const OutlineInputBorder(),
            ),
            onSubmitted:
                _hasText
                    ? (_) =>
                        Navigator.of(context).pop(widget.controller.text.trim())
                    : null,
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                Icon(Icons.info, color: Colors.blue.shade600, size: 20),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Esta validação é obrigatória para proteger sua conta de exclusões não autorizadas.',
                    style: TextStyle(fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(null),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed:
              _hasText
                  ? () =>
                      Navigator.of(context).pop(widget.controller.text.trim())
                  : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
          ),
          child: const Text('Confirmar'),
        ),
      ],
    );
  }
}
