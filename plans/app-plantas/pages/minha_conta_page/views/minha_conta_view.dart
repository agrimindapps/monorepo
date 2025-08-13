// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:get/get.dart';

// Project imports:
import '../../../../core/themes/manager.dart';
import '../../../constants/plantas_colors.dart';
import '../../../widgets/app_bottom_nav_widget.dart';
import '../controller/minha_conta_controller.dart';
import '../widgets/development_section_widget.dart';
import '../widgets/menu_item_widget.dart';
import '../widgets/subscription_card_widget.dart';
import '../widgets/user_profile_card_widget.dart';

class MinhaContaView extends GetView<MinhaContaController> {
  const MinhaContaView({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() => Scaffold(
          backgroundColor: PlantasColors.surfaceColor,
          body: SafeArea(
            child: Column(
              children: [
                _buildHeader(),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        const SizedBox(height: 16),
                        const UserProfileCardWidget(),
                        const SizedBox(height: 16),
                        const SubscriptionCardWidget(),
                        const SizedBox(height: 24),
                        _buildMenuSections(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          bottomNavigationBar: const AppBottomNavWidget(
            currentPage: BottomNavPage.conta,
          ),
        ));
  }

  Widget _buildHeader() {
    return Builder(
      builder: (context) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Minha Conta',
              style: TextStyle(
                fontSize: 28.0,
                fontWeight: FontWeight.bold,
                color: PlantasColors.textColor,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Bem-vindo, Usuário Anônimo',
              style: TextStyle(
                fontSize: 14.0,
                color: PlantasColors.subtitleColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppleSignInCard() {
    return Builder(
      builder: (context) => Container(
        margin: const EdgeInsets.symmetric(horizontal: 24),
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(12.0),
            onTap: _handleAppleSignIn,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.apple,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Entrar com Apple ID',
                          style: TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Sincronize seus dados entre dispositivos',
                          style: TextStyle(
                            fontSize: 14.0,
                            color: PlantasColors.subtitleColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.chevron_right,
                    color: PlantasColors.subtitleColor,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGrowPremiumCard() {
    return Builder(
      builder: (context) => Container(
        margin: const EdgeInsets.symmetric(horizontal: 24),
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFFD700), Color(0xFFFFA000)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(12.0),
              onTap: () => _handleMenuTap('premium'),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.star,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Grow Premium',
                            style: TextStyle(
                              fontSize: 18.0,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Desbloqueie recursos exclusivos',
                            style: TextStyle(
                              fontSize: 14.0,
                              color: Colors.white.withValues(alpha: 0.9),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Text(
                        'Conhecer',
                        style: TextStyle(
                          fontSize: 12.0,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFFFFD700),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMenuSections() {
    return Column(
      children: [
        _buildMenuSection('configuracoes', 'Configurações'),
        _buildMenuSection('suporte', 'Suporte'),
        _buildMenuSection('legal', 'Legal'),

        // Seções especiais
        _buildDevelopmentSection(),

        // Botão de sair
        _buildExitSection(),
      ],
    );
  }

  Widget _buildMenuSection(String section, String title) {
    const menuItens = {
      'configuracoes': [
        {
          'titulo': 'Notificações',
          'subtitulo': 'Configure quando ser notificado',
          'icone': Icons.notifications_outlined,
          'acao': 'notificacoes',
        },
        {
          'titulo': 'Tema',
          'subtitulo': 'Personalize a aparência do app',
          'icone': Icons.palette_outlined,
          'acao': 'tema',
        },
      ],
      'suporte': [
        {
          'titulo': 'Enviar Feedback',
          'subtitulo': 'Nos ajude a melhorar o app',
          'icone': Icons.feedback_outlined,
          'acao': 'feedback',
        },
        {
          'titulo': 'Avaliar o App',
          'subtitulo': 'Avalie nossa experiência',
          'icone': Icons.rate_review_outlined,
          'acao': 'avaliar',
        },
      ],
      'legal': [
        {
          'titulo': 'Política de Privacidade',
          'subtitulo': 'Como protegemos seus dados',
          'icone': Icons.privacy_tip_outlined,
          'acao': 'politica',
        },
        {
          'titulo': 'Termos de Uso',
          'subtitulo': 'Termos e condições de uso',
          'icone': Icons.description_outlined,
          'acao': 'termos',
        },
        {
          'titulo': 'Sobre o App',
          'subtitulo': 'Versão e informações do app',
          'icone': Icons.info_outline,
          'acao': 'sobre',
        },
      ],
    };

    final items = menuItens[section] ?? [];

    return Builder(
      builder: (context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: Text(
              title,
              style: TextStyle(
                fontSize: 14.0,
                fontWeight: FontWeight.w600,
                color: PlantasColors.subtitleColor,
              ),
            ),
          ),
          Card(
            elevation: ThemeManager().isDark.value ? 0 : 2,
            color: PlantasColors.cardColor,
            margin: const EdgeInsets.symmetric(horizontal: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                children: items.asMap().entries.map((entry) {
                  final index = entry.key;
                  final item = entry.value;

                  // Para o item tema, usar widget especializado com switch
                  IconData icon = item['icone'] as IconData;
                  String subtitle = item['subtitulo'] as String;

                  if (item['acao'] == 'tema') {
                    return Obx(() {
                      // Usar GlobalThemeHelper unificado
                      final isDark = ThemeManager().isDark.value;

                      return _buildThemeToggleItem(
                        context: context,
                        isDark: isDark,
                        onToggle: () => _handleMenuTap(item['acao'] as String),
                      );
                    });
                  }

                  return MenuItemWidget(
                    icon: icon,
                    title: item['titulo'] as String,
                    subtitle: subtitle,
                    onTap: () => _handleMenuTap(item['acao'] as String),
                    iconColor: PlantasColors.primaryColor,
                    titleColor: index == items.length - 1
                        ? null
                        : PlantasColors.textColor,
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildDevelopmentSection() {
    return Builder(
      builder: (context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: Text(
              'Desenvolvimento',
              style: TextStyle(
                fontSize: 14.0,
                fontWeight: FontWeight.w600,
                color: PlantasColors.subtitleColor,
              ),
            ),
          ),
          Card(
            elevation: ThemeManager().isDark.value ? 0 : 2,
            color: PlantasColors.cardColor,
            margin: const EdgeInsets.symmetric(horizontal: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(4),
              child: DevelopmentSectionWidget(
                onGerarDadosTeste: () => controller.gerarDadosDeTeste(),
                onLimparRegistros: () => controller.limparTodosRegistros(),
                onPaginaPromocional: () => controller.navigateToPromo(),
                onGerarLicenca: () => controller.gerarLicencaLocal(),
                onRevogarLicenca: () => controller.revogarLicencaLocal(),
              ),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  // Handlers para ações
  void _handleAppleSignIn() {
    // TODO: Implementar login com Apple
    Get.snackbar(
      'Em breve',
      'Login com Apple será implementado em breve',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void _handleMenuTap(String action) {
    switch (action) {
      case 'notificacoes':
        controller.navigateToNotifications();
        break;
      case 'tema':
        _toggleThemeWithFeedback();
        break;
      case 'feedback':
        controller.sendFeedback();
        break;
      case 'avaliar':
        controller.navigateToAppStore();
        break;
      case 'politica':
        controller.navigateToPoliticas();
        break;
      case 'termos':
        controller.navigateToTermos();
        break;
      case 'sobre':
        controller.navigateToAbout();
        break;
      case 'premium':
        controller.navigateToPromo();
        break;
      default:
        break;
    }
  }

  Widget _buildExitSection() {
    return Column(
      children: [
        const SizedBox(height: 16),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 24),
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _handleExitToModules,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red[600],
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.symmetric(vertical: 16),
              elevation: 2,
            ),
            icon: const Icon(
              Icons.exit_to_app,
              size: 20,
            ),
            label: const Text(
              'Sair do App Plantas',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(height: 32),
      ],
    );
  }

  Future<void> _handleExitToModules() async {
    final confirmar = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Sair do App Plantas'),
        content: const Text(
          'Tem certeza que deseja sair do App Plantas e voltar para a tela de módulos?',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red[600],
              foregroundColor: Colors.white,
            ),
            child: const Text('Sair'),
          ),
        ],
      ),
    );

    if (confirmar == true) {
      // Navegar de volta para a tela de módulos (root)
      Get.offAllNamed('/');

      Get.snackbar(
        'App Plantas',
        'Você saiu do App Plantas com sucesso',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.grey[600],
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );
    }
  }

  /// Widget especializado para toggle do tema com switch
  Widget _buildThemeToggleItem({
    required BuildContext context,
    required bool isDark,
    required VoidCallback onToggle,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 1),
      child: Material(
        color: PlantasColors.cardColor,
        elevation: ThemeManager().isDark.value ? 0 : 0.5,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            children: [
              // Ícone dinâmico baseado no tema
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFF20B2AA).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  isDark ? Icons.dark_mode : Icons.light_mode,
                  color: const Color(0xFF20B2AA),
                  size: 22,
                ),
              ),
              const SizedBox(width: 16),

              // Textos
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Tema',
                      style: TextStyle(
                        fontSize: 16,
                        color: PlantasColors.textColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      isDark ? 'Tema escuro ativo' : 'Tema claro ativo',
                      style: TextStyle(
                        fontSize: 13,
                        color: PlantasColors.subtitleColor,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),

              // Switch customizado
              Switch(
                value: isDark,
                activeColor: const Color(0xFF20B2AA),
                inactiveThumbColor: PlantasColors.subtitleColor,
                inactiveTrackColor: PlantasColors.borderColor,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                onChanged: (bool value) => onToggle(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Toggle do tema sem feedback visual
  void _toggleThemeWithFeedback() {
    // Toggle do tema
    controller.toggleTheme();
  }
}
