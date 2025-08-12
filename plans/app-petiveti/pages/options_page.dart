// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:get/get.dart';
import 'package:hive/hive.dart';

// Project imports:
import '../../core/services/app_rating_service.dart';
import '../controllers/sync/sync_controllers.dart';
import '../core/navigation/route_manager.dart';
import '../models/11_animal_model.dart';
import '../models/12_consulta_model.dart';
import '../models/13_despesa_model.dart';
import '../models/14_lembrete_model.dart';
import '../models/15_medicamento_model.dart';
import '../models/16_vacina_model.dart';
import '../models/17_peso_model.dart';
import '../widgets/config/subscription_card_widget.dart';
import '../widgets/config/user_profile_card_widget.dart';
import '../widgets/page_header_widget.dart';

class OptionsVetPage extends StatefulWidget {
  const OptionsVetPage({super.key});

  @override
  State<OptionsVetPage> createState() => _OptionsVetPageState();
}

class _OptionsVetPageState extends State<OptionsVetPage>
    with TickerProviderStateMixin {
  // Example settings
  bool _notificationsEnabled = true;
  bool _darkMode = false;
  String _selectedLanguage = 'pt_BR';
  String _selectedWeightUnit = 'kg';

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? Colors.grey[900] : Colors.grey[50],
      body: SafeArea(
        child: Center(
          child: SizedBox(
            width: 1120,
            child: Column(
              children: [
                // Header personalizado do PetiVeti
                const PageHeaderWidget(
                  title: 'Configurações',
                  subtitle: 'Personalize suas preferências do PetiVeti',
                  icon: Icons.settings,
                  showBackButton: true,
                ),

                // Conteúdo principal
                Expanded(
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(8, 16, 8, 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Seção de Conta (cards de usuário e assinatura)
                          _buildSectionHeader('Conta', Icons.account_circle_outlined),
                          _buildAccountSection(),
                          
                          _buildSectionHeader('Geral', Icons.settings_outlined),
                          _buildGeneralSection(),
                          _buildSectionHeader(
                              'Notificações', Icons.notifications_outlined),
                          _buildNotificationSection(),
                          _buildSectionHeader(
                              'Aparência', Icons.palette_outlined),
                          _buildAppearanceSection(),
                          _buildSectionHeader(
                              'Backup e Dados', Icons.storage_outlined),
                          _buildBackupSection(),
                          _buildSectionHeader(
                              'Desenvolvimento', Icons.code_outlined),
                          _buildDevelopmentSection(),
                          _buildSectionHeader('Sobre', Icons.info_outline),
                          _buildAboutSection(),
                          const SizedBox(height: 24),
                          _buildExitModuleSection(),
                          const SizedBox(height: 32),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor =
        isDark ? Colors.purple.shade400 : Colors.purple.shade700;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 32, 16, 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              size: 20,
              color: primaryColor,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : Colors.grey.shade800,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountSection() {
    return const Column(
      children: [
        UserProfileCardWidget(),
        SizedBox(height: 16),
        SubscriptionCardWidget(),
        SizedBox(height: 8),
      ],
    );
  }

  Widget _buildGeneralSection() {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[850] : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black26 : Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: isDark ? Colors.grey[800]! : Colors.grey[200]!,
          width: 0.5,
        ),
      ),
      child: Column(
        children: [
          _buildModernListTile(
            icon: Icons.language_outlined,
            title: 'Idioma',
            subtitle: 'Português (Brasil)',
            trailing: Icon(
              Icons.chevron_right_rounded,
              color: colorScheme.onSurface.withValues(alpha: 0.6),
            ),
            onTap: () {
              _showLanguageSelector();
            },
          ),
          Divider(
            height: 1,
            thickness: 0.5,
            color: isDark ? Colors.grey.shade700 : Colors.grey.shade200,
            indent: 56,
          ),
          _buildModernListTile(
            icon: Icons.scale_outlined,
            title: 'Unidade de peso padrão',
            subtitle: null,
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.purple.shade100,
                borderRadius: BorderRadius.circular(20),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedWeightUnit,
                  isDense: true,
                  style: TextStyle(
                    color: Colors.purple.shade800,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                  dropdownColor: colorScheme.surface,
                  items: const [
                    DropdownMenuItem(value: 'kg', child: Text('kg')),
                    DropdownMenuItem(value: 'g', child: Text('g')),
                    DropdownMenuItem(value: 'lb', child: Text('lb')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedWeightUnit = value!;
                    });
                  },
                ),
              ),
            ),
            onTap: null,
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationSection() {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[850] : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black26 : Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: isDark ? Colors.grey[800]! : Colors.grey[200]!,
          width: 0.5,
        ),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.purple.shade100.withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.notifications_outlined,
                    size: 20,
                    color: Colors.purple.shade700,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Ativar notificações',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Receber alertas de consultas e medicamentos',
                        style: TextStyle(
                          fontSize: 14,
                          color: isDark
                              ? Colors.grey.shade300
                              : Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                Transform.scale(
                  scale: 0.9,
                  child: Switch.adaptive(
                    value: _notificationsEnabled,
                    onChanged: (bool value) {
                      setState(() {
                        _notificationsEnabled = value;
                      });
                    },
                    activeColor: Colors.purple.shade700,
                  ),
                ),
              ],
            ),
          ),
          Divider(
            height: 1,
            thickness: 0.5,
            color: isDark ? Colors.grey.shade700 : Colors.grey.shade200,
            indent: 56,
          ),
          _buildModernListTile(
            icon: Icons.schedule_outlined,
            title: 'Horário das notificações',
            subtitle: 'Definir horário preferido para alertas',
            trailing: Icon(
              Icons.chevron_right_rounded,
              color: _notificationsEnabled
                  ? colorScheme.onSurface.withValues(alpha: 0.6)
                  : colorScheme.onSurface.withValues(alpha: 0.3),
            ),
            onTap: _notificationsEnabled
                ? () {
                    _showTimeSelector();
                  }
                : null,
          ),
        ],
      ),
    );
  }

  Widget _buildAppearanceSection() {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[850] : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black26 : Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: isDark ? Colors.grey[800]! : Colors.grey[200]!,
          width: 0.5,
        ),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.purple.shade100.withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    _darkMode
                        ? Icons.dark_mode_outlined
                        : Icons.light_mode_outlined,
                    size: 20,
                    color: Colors.purple.shade700,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Modo escuro',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _darkMode ? 'Tema escuro ativo' : 'Tema claro ativo',
                        style: TextStyle(
                          fontSize: 14,
                          color: isDark
                              ? Colors.grey.shade300
                              : Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                Transform.scale(
                  scale: 0.9,
                  child: Switch.adaptive(
                    value: _darkMode,
                    onChanged: (bool value) {
                      setState(() {
                        _darkMode = value;
                      });
                    },
                    activeColor: Colors.purple.shade700,
                  ),
                ),
              ],
            ),
          ),
          Divider(
            height: 1,
            thickness: 0.5,
            color: isDark ? Colors.grey.shade700 : Colors.grey.shade200,
            indent: 56,
          ),
          _buildModernListTile(
            icon: Icons.palette_outlined,
            title: 'Tema personalizado',
            subtitle: 'Personalizar cores do aplicativo',
            trailing: Icon(
              Icons.chevron_right_rounded,
              color: colorScheme.onSurface.withValues(alpha: 0.6),
            ),
            onTap: () {
              _showThemeSelector();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBackupSection() {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[850] : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black26 : Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: isDark ? Colors.grey[800]! : Colors.grey[200]!,
          width: 0.5,
        ),
      ),
      child: Column(
        children: [
          _buildModernListTile(
            icon: Icons.cloud_upload_outlined,
            title: 'Fazer backup',
            subtitle: 'Último backup: Nunca',
            trailing: Icon(
              Icons.chevron_right_rounded,
              color: colorScheme.onSurface.withValues(alpha: 0.6),
            ),
            onTap: () {
              _performBackup();
            },
          ),
          Divider(
            height: 1,
            thickness: 0.5,
            color: isDark ? Colors.grey.shade700 : Colors.grey.shade200,
            indent: 56,
          ),
          _buildModernListTile(
            icon: Icons.cloud_download_outlined,
            title: 'Restaurar dados',
            subtitle: 'Recuperar dados do backup',
            trailing: Icon(
              Icons.chevron_right_rounded,
              color: colorScheme.onSurface.withValues(alpha: 0.6),
            ),
            onTap: () {
              _performRestore();
            },
          ),
          Divider(
            height: 1,
            thickness: 0.5,
            color: isDark ? Colors.grey.shade700 : Colors.grey.shade200,
            indent: 56,
          ),
          _buildModernListTile(
            icon: Icons.delete_sweep_outlined,
            title: 'Limpar dados',
            subtitle: 'Apagar todos os dados do aplicativo',
            trailing: Icon(
              Icons.chevron_right_rounded,
              color: Colors.red.withValues(alpha: 0.8),
            ),
            onTap: () {
              _showDeleteConfirmationDialog();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDevelopmentSection() {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[850] : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black26 : Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: isDark ? Colors.grey[800]! : Colors.grey[200]!,
          width: 0.5,
        ),
      ),
      child: Column(
        children: [
          _buildModernListTile(
            icon: Icons.science_outlined,
            title: 'Simular Dados',
            subtitle: 'Criar 2 animais com histórico completo de 14 meses',
            trailing: Icon(
              Icons.chevron_right_rounded,
              color: colorScheme.onSurface.withValues(alpha: 0.6),
            ),
            onTap: () {
              _simulateTestData();
            },
          ),
          Divider(
            height: 1,
            thickness: 0.5,
            color: isDark ? Colors.grey.shade700 : Colors.grey.shade200,
            indent: 56,
          ),
          _buildModernListTile(
            icon: Icons.delete_forever_outlined,
            title: 'Remover Dados',
            subtitle: 'Limpar todo o banco de dados local',
            trailing: Icon(
              Icons.chevron_right_rounded,
              color: Colors.red.withValues(alpha: 0.8),
            ),
            onTap: () {
              _removeAllData();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAboutSection() {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[850] : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black26 : Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: isDark ? Colors.grey[800]! : Colors.grey[200]!,
          width: 0.5,
        ),
      ),
      child: Column(
        children: [
          _buildModernListTile(
            icon: Icons.info_outline,
            title: 'Versão do aplicativo',
            subtitle: '1.0.0 (Build 1)',
            trailing: null,
            onTap: null,
          ),
          Divider(
            height: 1,
            thickness: 0.5,
            color: isDark ? Colors.grey.shade700 : Colors.grey.shade200,
            indent: 56,
          ),
          _buildModernListTile(
            icon: Icons.description_outlined,
            title: 'Termos de uso',
            subtitle: 'Leia nossos termos e condições',
            trailing: Icon(
              Icons.chevron_right_rounded,
              color: colorScheme.onSurface.withValues(alpha: 0.6),
            ),
            onTap: () {
              _showTermsOfService();
            },
          ),
          Divider(
            height: 1,
            thickness: 0.5,
            color: isDark ? Colors.grey.shade700 : Colors.grey.shade200,
            indent: 56,
          ),
          _buildModernListTile(
            icon: Icons.privacy_tip_outlined,
            title: 'Política de privacidade',
            subtitle: 'Como tratamos seus dados',
            trailing: Icon(
              Icons.chevron_right_rounded,
              color: colorScheme.onSurface.withValues(alpha: 0.6),
            ),
            onTap: () {
              _showPrivacyPolicy();
            },
          ),
          Divider(
            height: 1,
            thickness: 0.5,
            color: isDark ? Colors.grey.shade700 : Colors.grey.shade200,
            indent: 56,
          ),
          _buildModernListTile(
            icon: Icons.star_rate_outlined,
            title: 'Avaliar o App',
            subtitle: 'Avalie nossa experiência na loja',
            trailing: Icon(
              Icons.chevron_right_rounded,
              color: colorScheme.onSurface.withValues(alpha: 0.6),
            ),
            onTap: _handleAppRating,
          ),
        ],
      ),
    );
  }

  Widget _buildModernListTile({
    required IconData icon,
    required String title,
    String? subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.purple.shade100.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                size: 20,
                color: Colors.purple.shade700,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark
                            ? Colors.grey.shade300
                            : Colors.grey.shade600,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (trailing != null) trailing,
          ],
        ),
      ),
    );
  }

  void _showLanguageSelector() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                height: 4,
                width: 40,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Selecionar Idioma',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 16),
              ListTile(
                title: const Text('Português (Brasil)'),
                trailing: _selectedLanguage == 'pt_BR'
                    ? const Icon(Icons.check_circle, color: Colors.green)
                    : null,
                onTap: () {
                  setState(() {
                    _selectedLanguage = 'pt_BR';
                  });
                  RouteManager.instance.back();
                },
              ),
              ListTile(
                title: const Text('English'),
                trailing: _selectedLanguage == 'en'
                    ? const Icon(Icons.check_circle, color: Colors.green)
                    : null,
                onTap: () {
                  setState(() {
                    _selectedLanguage = 'en';
                  });
                  RouteManager.instance.back();
                },
              ),
              ListTile(
                title: const Text('Español'),
                trailing: _selectedLanguage == 'es'
                    ? const Icon(Icons.check_circle, color: Colors.green)
                    : null,
                onTap: () {
                  setState(() {
                    _selectedLanguage = 'es';
                  });
                  RouteManager.instance.back();
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  void _showTimeSelector() async {
    final TimeOfDay? selectedTime = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 9, minute: 0),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            timePickerTheme: TimePickerThemeData(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (selectedTime != null) {
      // Implementar salvamento do horário
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text('Horário definido para ${selectedTime.format(context)}'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }

  void _showThemeSelector() {
    final themes = [
      {'name': 'Azul Padrão', 'color': Colors.blue, 'id': 'blue'},
      {'name': 'Verde Natureza', 'color': Colors.green, 'id': 'green'},
      {'name': 'Roxo Moderno', 'color': Colors.purple, 'id': 'purple'},
      {'name': 'Laranja Vibrante', 'color': Colors.orange, 'id': 'orange'},
      {'name': 'Teal Profissional', 'color': Colors.teal, 'id': 'teal'},
    ];

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                height: 4,
                width: 40,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Selecionar Tema',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 16),
              ...themes.map((theme) => ListTile(
                    leading: Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: theme['color'] as Color,
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    title: Text(theme['name'] as String),
                    onTap: () {
                      RouteManager.instance.back();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Tema "${theme['name']}" aplicado'),
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      );
                    },
                  )),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  void _performBackup() async {
    // Mostrar indicador de loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Fazendo backup dos dados...'),
          ],
        ),
      ),
    );

    // Simular processo de backup
    await Future.delayed(const Duration(seconds: 2));

    RouteManager.instance.back(); // Fechar loading

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: 8),
            Text('Backup realizado com sucesso!'),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _performRestore() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Restaurar dados'),
        content: const Text(
          'Esta ação irá substituir todos os dados atuais pelos dados do backup. Deseja continuar?',
        ),
        actions: [
          TextButton(
            onPressed: () => RouteManager.instance.back(result: false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => RouteManager.instance.back(result: true),
            child: const Text('Restaurar'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      // Mostrar indicador de loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Restaurando dados...'),
            ],
          ),
        ),
      );

      // Simular processo de restauração
      await Future.delayed(const Duration(seconds: 2));

      RouteManager.instance.back(); // Fechar loading

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 8),
              Text('Dados restaurados com sucesso!'),
            ],
          ),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  void _showDeleteConfirmationDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.warning_amber_outlined,
                color: Colors.red[700],
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Confirmar exclusão',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ],
        ),
        content: const Text(
          'Esta ação irá apagar todos os dados do aplicativo permanentemente. Esta ação não pode ser desfeita.',
          style: TextStyle(fontSize: 16, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(
              'Cancelar',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _performDataDeletion();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red[700],
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(
              'Apagar',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  void _performDataDeletion() async {
    // Mostrar indicador de loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Apagando dados...'),
          ],
        ),
      ),
    );

    // Simular processo de exclusão
    await Future.delayed(const Duration(seconds: 2));

    RouteManager.instance.back(); // Fechar loading

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: 8),
            Text('Todos os dados foram apagados'),
          ],
        ),
        backgroundColor: Colors.red[700],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _showTermsOfService() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.8,
          maxChildSize: 0.9,
          minChildSize: 0.5,
          builder: (context, scrollController) {
            return Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Container(
                    height: 4,
                    width: 40,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Termos de Uso',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: SingleChildScrollView(
                      controller: scrollController,
                      child: const Text(
                        'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.\n\nDuis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.\n\nSed ut perspiciatis unde omnis iste natus error sit voluptatem accusantium doloremque laudantium, totam rem aperiam, eaque ipsa quae ab illo inventore veritatis et quasi architecto beatae vitae dicta sunt explicabo.',
                        style: TextStyle(fontSize: 16, height: 1.5),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showPrivacyPolicy() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.8,
          maxChildSize: 0.9,
          minChildSize: 0.5,
          builder: (context, scrollController) {
            return Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Container(
                    height: 4,
                    width: 40,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Política de Privacidade',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: SingleChildScrollView(
                      controller: scrollController,
                      child: const Text(
                        'Sua privacidade é importante para nós. Esta política de privacidade explica quais informações coletamos, como as usamos e como protegemos seus dados.\n\n1. Informações Coletadas\nColetamos apenas as informações necessárias para o funcionamento do aplicativo.\n\n2. Uso das Informações\nUsamos suas informações apenas para fornecer e melhorar nossos serviços.\n\n3. Proteção de Dados\nImplementamos medidas de segurança apropriadas para proteger suas informações.',
                        style: TextStyle(fontSize: 16, height: 1.5),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildExitModuleSection() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[850] : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color:
                isDark ? Colors.black26 : Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: isDark ? Colors.grey[800]! : Colors.grey[200]!,
          width: 0.5,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () => _showExitModuleConfirmation(),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade600,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(vertical: 16),
              elevation: 0,
            ),
            icon: const Icon(Icons.exit_to_app, size: 20),
            label: const Text(
              'Sair do Módulo',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showExitModuleConfirmation() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: isDark ? Colors.grey[850] : Colors.white,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.exit_to_app,
                color: Colors.red.shade600,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Sair do Módulo',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
          ],
        ),
        content: Text(
          'Tem certeza de que deseja sair do PetiVeti e retornar ao menu principal?',
          style: TextStyle(
            fontSize: 16,
            height: 1.4,
            color: isDark ? Colors.grey.shade300 : Colors.grey.shade700,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(
              'Cancelar',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _exitModule();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade600,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(
              'Sair',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _simulateTestData() async {
    try {
      _showLoadingDialog('Gerando dados de teste...');

      final animalsController = Get.find<AnimalsSyncController>();
      final pesosController = Get.find<PesosSyncController>();
      final vacinasController = Get.find<VacinasSyncController>();
      final lembretesController = Get.find<LembretesSyncController>();
      final medicamentosController = Get.find<MedicamentosSyncController>();
      final despesasController = Get.find<DespesasSyncController>();
      final consultasController = Get.find<ConsultasSyncController>();

      final now = DateTime.now();
      final baseTimestamp = now.millisecondsSinceEpoch;

      // Gerar IDs únicos usando timestamp
      String generateUniqueId(String prefix) {
        return '${prefix}_${DateTime.now().millisecondsSinceEpoch}_${(DateTime.now().microsecond % 1000)}';
      }

      // Criar 2 animais de teste com dados mais realistas
      final animal1 = Animal(
        id: generateUniqueId('animal'),
        createdAt: baseTimestamp,
        updatedAt: baseTimestamp,
        isDeleted: false,
        needsSync: true,
        version: 1,
        lastSyncAt: null,
        nome: 'Max',
        especie: 'Cachorro',
        raca: 'Golden Retriever',
        dataNascimento: DateTime(2020, 6, 15).millisecondsSinceEpoch,
        sexo: 'Macho',
        cor: 'Dourado',
        pesoAtual: 28.5,
        foto: null,
        observacoes: 'Animal de teste muito dócil e brincalhão. Gosta de buscar a bolinha.',
      );

      final animal2 = Animal(
        id: generateUniqueId('animal'),
        createdAt: baseTimestamp,
        updatedAt: baseTimestamp,
        isDeleted: false,
        needsSync: true,
        version: 1,
        lastSyncAt: null,
        nome: 'Luna',
        especie: 'Gato',
        raca: 'Persa',
        dataNascimento: DateTime(2021, 3, 10).millisecondsSinceEpoch,
        sexo: 'Fêmea',
        cor: 'Branco com manchas cinzas',
        pesoAtual: 4.2,
        foto: null,
        observacoes: 'Gata de teste muito carinhosa e independente. Adora dormir no sol.',
      );

      await animalsController.createAnimal(animal1);
      await animalsController.createAnimal(animal2);

      // Gerar dados históricos para 14 meses
      final animais = [animal1, animal2];
      int recordCounter = 0;

      for (int month = 0; month < 14; month++) {
        final monthDate = DateTime(now.year, now.month - month, 1);
        
        for (final animal in animais) {
          // Gerar 3-5 registros por mês para cada animal
          final recordsCount = 3 + (month % 3);
          
          for (int record = 0; record < recordsCount; record++) {
            recordCounter++;
            final day = (5 + (record * 6)).clamp(1, 28); // Espaçar os registros no mês
            final recordDate = DateTime(monthDate.year, monthDate.month, day);
            final recordTimestamp = recordDate.millisecondsSinceEpoch;

            // Registros de Peso (mais frequentes)
            if (record % 2 == 0) {
              final pesoVariacao = (month * 0.3) - (record * 0.1) + ((recordCounter % 5) * 0.2);
              final pesoCalculado = animal.pesoAtual + pesoVariacao;
              final pesoFinal = pesoCalculado > 0 ? pesoCalculado : (animal.pesoAtual * 0.8);
              
              final peso = PesoAnimal(
                id: generateUniqueId('peso'),
                createdAt: recordTimestamp,
                updatedAt: recordTimestamp,
                isDeleted: false,
                needsSync: true,
                version: 1,
                lastSyncAt: null,
                animalId: animal.id,
                dataPesagem: recordTimestamp,
                peso: double.parse(pesoFinal.toStringAsFixed(1)),
                observacoes: month < 2 ? 'Peso atual registrado - animal saudável' : null,
              );
              await pesosController.createPeso(peso);
            }

            // Consultas (bimestrais)
            if (month % 2 == 0 && record == 0) {
              final consulta = Consulta(
                id: generateUniqueId('consulta'),
                createdAt: recordTimestamp,
                updatedAt: recordTimestamp,
                isDeleted: false,
                needsSync: true,
                version: 1,
                lastSyncAt: null,
                animalId: animal.id,
                dataConsulta: recordTimestamp,
                veterinario: month % 4 == 0 ? 'Dr. Carlos Silva' : 'Dra. Maria Santos',
                motivo: month % 6 == 0 ? 'Consulta de rotina' : 'Acompanhamento preventivo',
                diagnostico: 'Animal saudável. Sem alterações significativas detectadas.',
                valor: 80.0 + (month * 5) + (recordCounter % 20),
                observacoes: month < 4 ? 'Paciente colaborativo durante o exame' : null,
              );
              await consultasController.createConsulta(consulta);
            }

            // Vacinas (a cada 4 meses)
            if (month % 4 == 0 && record == 0) {
              final proximaDose = DateTime(recordDate.year, recordDate.month + 12, recordDate.day).millisecondsSinceEpoch;
              final vacinas = ['V10', 'Antirrábica', 'V8', 'Gripe Canina', 'Giardia'];
              final vacinaIndex = month ~/ 4;
              
              final vacina = VacinaVet(
                id: generateUniqueId('vacina'),
                createdAt: recordTimestamp,
                updatedAt: recordTimestamp,
                isDeleted: false,
                needsSync: true,
                version: 1,
                lastSyncAt: null,
                animalId: animal.id,
                nomeVacina: vacinas[vacinaIndex % vacinas.length],
                dataAplicacao: recordTimestamp,
                proximaDose: proximaDose,
                observacoes: 'Vacina aplicada sem intercorrências. Lote: LOTE${1000 + recordCounter}',
              );
              await vacinasController.createVacina(vacina);
            }

            // Lembretes (mensais com variação)
            if (record == 0 || (month < 3 && record == 2)) {
              final tipos = ['Consulta', 'Vacina', 'Medicamento', 'Banho e Tosa', 'Vermifugação'];
              final repeticoes = ['Sem repetição', 'Mensal', 'Semanal', 'Diário'];
              
              final lembrete = LembreteVet(
                id: generateUniqueId('lembrete'),
                createdAt: recordTimestamp,
                updatedAt: recordTimestamp,
                isDeleted: false,
                needsSync: true,
                version: 1,
                lastSyncAt: null,
                animalId: animal.id,
                dataHora: DateTime(recordDate.year, recordDate.month, recordDate.day, 9 + (record * 2), 0).millisecondsSinceEpoch,
                titulo: '${tipos[recordCounter % tipos.length]} - ${animal.nome}',
                descricao: 'Lembrete importante gerado automaticamente para acompanhamento de ${animal.nome}',
                tipo: tipos[recordCounter % tipos.length],
                repetir: repeticoes[recordCounter % repeticoes.length],
                concluido: month > 8, // Marcar como concluído lembretes mais antigos
              );
              await lembretesController.createLembrete(lembrete);
            }

            // Medicamentos (tratamentos esporádicos)
            if (month % 5 == 0 && record == 1) {
              final medicamentos = ['Vermífugo', 'Anti-inflamatório', 'Antibiótico', 'Vitaminas', 'Probiótico'];
              final dosagens = ['1 comprimido', '0.5ml', '2 comprimidos', '1 cápsula', '1 sachê'];
              final frequencias = ['Uma vez ao dia', 'Duas vezes ao dia', 'Três vezes ao dia', 'A cada 12 horas'];
              final duracoes = ['7 dias', '10 dias', '5 dias', '14 dias', '21 dias'];
              
              final medIndex = recordCounter % medicamentos.length;
              final duracaoDias = [7, 10, 5, 14, 21][medIndex];
              final fimTratamento = DateTime(recordDate.year, recordDate.month, recordDate.day + duracaoDias).millisecondsSinceEpoch;
              
              final medicamento = MedicamentoVet(
                id: generateUniqueId('medicamento'),
                createdAt: recordTimestamp,
                updatedAt: recordTimestamp,
                isDeleted: false,
                needsSync: true,
                version: 1,
                lastSyncAt: null,
                animalId: animal.id,
                nomeMedicamento: medicamentos[medIndex],
                dosagem: dosagens[medIndex],
                frequencia: frequencias[medIndex % frequencias.length],
                duracao: duracoes[medIndex],
                inicioTratamento: recordTimestamp,
                fimTratamento: fimTratamento,
                observacoes: month < 2 ? 'Medicamento prescrito como medida preventiva' : null,
              );
              await medicamentosController.createMedicamento(medicamento);
            }

            // Despesas (variadas e realistas)
            if (record % 2 == 1) {
              final tiposDespesas = ['Consulta', 'Ração Premium', 'Medicamento', 'Brinquedo', 'Banho e Tosa', 'Exame', 'Vacina'];
              final valoresBase = [85.0, 120.0, 35.0, 25.0, 60.0, 150.0, 45.0];
              final descricoes = [
                'Consulta veterinária de rotina',
                'Ração premium para animal adulto - 15kg',
                'Medicamento prescrito pelo veterinário',
                'Brinquedo educativo e resistente',
                'Banho, tosa e cuidados estéticos',
                'Exames laboratoriais de rotina',
                'Vacina preventiva anual'
              ];
              
              final despesaIndex = recordCounter % tiposDespesas.length;
              final valorVariacao = (record * 5) + (month % 10);
              
              final despesa = DespesaVet(
                id: generateUniqueId('despesa'),
                createdAt: recordTimestamp,
                updatedAt: recordTimestamp,
                isDeleted: false,
                needsSync: true,
                version: 1,
                lastSyncAt: null,
                animalId: animal.id,
                dataDespesa: recordTimestamp,
                tipo: tiposDespesas[despesaIndex],
                descricao: descricoes[despesaIndex],
                valor: valoresBase[despesaIndex] + valorVariacao,
              );
              await despesasController.createDespesa(despesa);
            }
          }
        }
      }

      if (mounted) {
        Navigator.pop(context);
      }
      _showSuccessMessage('Dados de teste gerados com sucesso!\n${animais.length} animais criados com histórico de 14 meses');
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
      }
      _showErrorMessage('Erro ao gerar dados de teste: $e');
      debugPrint('Erro detalhado na simulação: $e');
    }
  }

  Future<void> _removeAllData() async {
    // Mostrar confirmação
    final confirm = await _showDataConfirmationDialog(
      'Confirmar Remoção',
      'Tem certeza que deseja remover TODOS os dados do banco local? Esta ação não pode ser desfeita.',
    );

    if (!confirm) return;

    if (!mounted) return;

    try {
      _showLoadingDialog('Removendo todos os dados...');

      // Usar método organizado via controller sync
      final animalsController = Get.find<AnimalsSyncController>();
      await animalsController.clearAllAnimals();
      
      // Para os demais, usar Hive diretamente (os controllers ainda não têm métodos clear implementados)
      final boxNames = [
        'box_vet_pesos',
        'box_vet_vacinas', 
        'box_vet_lembrete',
        'box_vet_medicamentos',
        'box_vet_despesas',
      ];
      
      for (final boxName in boxNames) {
        try {
          await Hive.box(boxName).clear();
        } catch (e) {
          debugPrint('Erro ao limpar $boxName: $e');
        }
      }

      if (mounted) {
        Navigator.pop(context); // Fechar loading apenas
      }
      _showSuccessMessage('Todos os dados foram removidos com sucesso!');
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Fechar loading apenas
      }
      _showErrorMessage('Erro ao remover dados: $e');
    }
  }

  void _showLoadingDialog(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Row(
          children: [
            const CircularProgressIndicator(),
            const SizedBox(width: 16),
            Expanded(child: Text(message)),
          ],
        ),
      ),
    );
  }

  Future<bool> _showDataConfirmationDialog(String title, String message) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
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

  void _showErrorMessage(String message) {
    Get.snackbar(
      'Erro',
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.red,
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
    );
  }

  void _exitModule() {
    Navigator.pushNamedAndRemoveUntil(
      context,
      '/app-select',
      (route) => false,
    );
  }

  /// Lida com a solicitação de avaliação do app
  Future<void> _handleAppRating() async {
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
        // Log do erro mas não interrompe a experiência do usuário
        print('Erro ao abrir avaliação do app: $fallbackError');
      }
    }
  }
}
