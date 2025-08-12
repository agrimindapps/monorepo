// Flutter imports:
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Project imports:
import '../../../../../core/themes/manager.dart';
import 'controllers/settings_controller.dart';
import 'models/settings_model.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late SettingsController _controller;

  @override
  void initState() {
    super.initState();
    _controller = SettingsController();
    _controller.initialize();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _controller,
      builder: (context, child) {
        final size = MediaQuery.of(context).size;
        final bool isDesktop = size.width > 900;
        final bool isMobile = size.width <= 600;
        final isDark = ThemeManager().isDark.value;

        // Forçar orientação retrato para dispositivos móveis
        if (isMobile) {
          SystemChrome.setPreferredOrientations([
            DeviceOrientation.portraitUp,
            DeviceOrientation.portraitDown,
          ]);
        }

        return Scaffold(
          backgroundColor:
              isDark ? const Color(0xFF1A1A2E) : Colors.grey.shade50,
          body: SafeArea(
            child: Column(
              children: [
                // Header fixo
                Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: isDesktop ? 800 : double.infinity,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(
                        8,
                        0,
                        8,
                        8,
                      ),
                      child: _buildHeader(isDark),
                    ),
                  ),
                ),

                // Conteúdo com scroll
                Expanded(
                  child: SingleChildScrollView(
                    child: Center(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          maxWidth: isDesktop ? 800 : double.infinity,
                        ),
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(
                            isMobile ? 8 : 12,
                            0,
                            isMobile ? 8 : 12,
                            isMobile ? 8 : 12,
                          ),
                          child: Column(
                            children: [
                              // Seção de Conta (customizada)
                              _buildAccountSection(context, isDark),

                              // Seção de Assinatura (customizada)
                              _buildSubscriptionSection(context, isDark),

                              // Seções de configurações
                              ..._controller.model.settingsSections.map(
                                (section) =>
                                    _buildSection(context, section, isDark),
                              ),

                              const SizedBox(height: 16),

                              // Botão de sair do módulo
                              _buildExitModuleButton(context, isDark),

                              const SizedBox(height: 16),

                              // Copyright
                              _buildCopyright(isDark),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  const Color(0xFF2A2A2A),
                  const Color(0xFF1A1A1A),
                ]
              : [
                  Colors.grey.shade800,
                  Colors.grey.shade900,
                ],
        ),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Icon(
              Icons.local_gas_station,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'GasOMeter',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  'Gerencie suas preferências',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),

          // Botão de tema
          IconButton(
            onPressed: _controller.toggleTheme,
            style: IconButton.styleFrom(
              backgroundColor: Colors.white.withValues(alpha: 0.2),
              padding: const EdgeInsets.all(6),
            ),
            icon: Icon(
              isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
              color: Colors.white,
              size: 20,
            ),
            tooltip: isDark ? 'Tema claro' : 'Tema escuro',
          ),
        ],
      ),
    );
  }

  Widget _buildAccountSection(BuildContext context, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Título da seção
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 0, 12, 0),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'Conta',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.grey.shade300 : Colors.grey.shade700,
                  ),
                ),
              ),
              // Botões de debug para conta
              if (kDebugMode)
                IconButton(
                  icon: Icon(
                    Icons.person,
                    color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                    size: 20,
                  ),
                  tooltip: 'Alternar login',
                  onPressed: _controller.toggleLoginStatus,
                ),
            ],
          ),
        ),

        // Card da conta
        Card(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
              width: 0.5,
            ),
          ),
          color: isDark ? const Color(0xFF16213E) : Colors.white,
          child: _controller.model.isUserLoggedIn
              ? _buildLoggedInAccountCard(context, isDark)
              : _buildLoggedOutAccountCard(context, isDark),
        ),
      ],
    );
  }

  Widget _buildLoggedInAccountCard(BuildContext context, bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Header com avatar e informações do usuário
          Row(
            children: [
              // Avatar
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: isDark
                        ? [Colors.amber.shade400, Colors.amber.shade600]
                        : [Colors.grey.shade600, Colors.grey.shade800],
                  ),
                ),
                child: _controller.model.userPhotoUrl != null
                    ? ClipOval(
                        child: Image.network(
                          _controller.model.userPhotoUrl!,
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              _buildAvatarFallback(isDark),
                        ),
                      )
                    : _buildAvatarFallback(isDark),
              ),
              const SizedBox(width: 16),

              // Informações do usuário
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _controller.model.userName ?? 'Usuário',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _controller.model.userEmail ?? '',
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark
                            ? Colors.grey.shade300
                            : Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),
          const Divider(height: 1),
          const SizedBox(height: 16),

          // Ações da conta
          Column(
            children: [
              _buildAccountAction(
                context,
                Icons.sync_outlined,
                'Sincronizar Dados',
                'Atualizar informações na nuvem',
                () => _controller.syncData(),
                isDark,
              ),
              const SizedBox(height: 12),
              _buildAccountAction(
                context,
                Icons.delete_outline,
                'Excluir Conta',
                'Remover permanentemente sua conta',
                () => _controller.showDeleteAccountConfirmation(context),
                isDark,
                isDestructive: true,
              ),
              const SizedBox(height: 12),
              _buildAccountAction(
                context,
                Icons.logout,
                'Sair da Conta',
                'Fazer logout do aplicativo',
                () => _showLogoutConfirmation(context),
                isDark,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLoggedOutAccountCard(BuildContext context, bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Ícone e mensagem
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: (isDark ? Colors.grey.shade700 : Colors.grey.shade200)
                  .withValues(alpha: 0.5),
            ),
            child: Icon(
              Icons.person_outline,
              size: 40,
              color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 16),

          Text(
            'Faça login em sua conta',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Acesse recursos avançados, sincronize seus dados e mantenha suas informações seguras',
            style: TextStyle(
              fontSize: 14,
              color: isDark ? Colors.grey.shade300 : Colors.grey.shade600,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),

          // Botão de login
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              onPressed: () => _controller.navigateToLogin(context),
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    isDark ? Colors.grey.shade700 : Colors.grey.shade800,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              icon: const Icon(Icons.login, size: 20),
              label: const Text(
                'Fazer Login',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatarFallback(bool isDark) {
    return Center(
      child: Text(
        _controller.model.userInitials,
        style: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildAccountAction(
    BuildContext context,
    IconData icon,
    String title,
    String subtitle,
    VoidCallback onTap,
    bool isDark, {
    bool isDestructive = false,
  }) {
    final color = isDestructive
        ? Colors.red.shade400
        : (isDark ? Colors.grey.shade400 : Colors.grey.shade600);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: color,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: isDestructive
                          ? Colors.red.shade400
                          : (isDark ? Colors.white : Colors.black87),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color:
                          isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: isDark ? Colors.grey.shade500 : Colors.grey.shade400,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubscriptionSection(BuildContext context, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Título da seção
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 16, 12, 6),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'Assinatura',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.grey.shade300 : Colors.grey.shade700,
                  ),
                ),
              ),
              // Botões de debug para assinatura
              if (kDebugMode)
                IconButton(
                  icon: Icon(
                    Icons.star,
                    color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                    size: 20,
                  ),
                  tooltip: 'Alternar assinatura',
                  onPressed: _controller.simulateActiveSubscription,
                ),
            ],
          ),
        ),

        // Card da assinatura
        Card(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
              width: 0.5,
            ),
          ),
          color: isDark ? const Color(0xFF16213E) : Colors.white,
          child: _controller.model.hasActiveSubscription
              ? _buildActiveSubscriptionCard(context, isDark)
              : _buildNoSubscriptionCard(context, isDark),
        ),
      ],
    );
  }

  Widget _buildActiveSubscriptionCard(BuildContext context, bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header com ícone premium e tipo
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.amber.shade400,
                      Colors.amber.shade600,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.star,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _controller.model.subscriptionType,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _controller.model.subscriptionPrice,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.amber.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.green.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Text(
                  'ATIVO',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.green.shade600,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Progresso da assinatura
          Text(
            'Tempo restante',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: isDark ? Colors.grey.shade300 : Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 8),

          // Barra de progresso
          Stack(
            children: [
              Container(
                height: 8,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              Container(
                height: 8,
                width: (MediaQuery.of(context).size.width - 48) *
                    (_controller.model.subscriptionProgress / 100),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: _controller.model.subscriptionProgress > 70
                        ? [Colors.red.shade400, Colors.red.shade600]
                        : _controller.model.subscriptionProgress > 30
                            ? [Colors.orange.shade400, Colors.orange.shade600]
                            : [Colors.green.shade400, Colors.green.shade600],
                  ),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _controller.model.daysRemaining,
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                ),
              ),
              Text(
                '${_controller.model.subscriptionProgress.toInt()}%',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: isDark ? Colors.grey.shade300 : Colors.grey.shade700,
                ),
              ),
            ],
          ),

          if (_controller.model.renewalDate != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: (isDark ? Colors.grey.shade800 : Colors.grey.shade50)
                    .withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.calendar_today_outlined,
                    size: 16,
                    color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Renovação: ${_formatDate(_controller.model.renewalDate!)}',
                    style: TextStyle(
                      fontSize: 12,
                      color:
                          isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 16),

          // Botão para gerenciar assinatura
          SizedBox(
            width: double.infinity,
            height: 44,
            child: ElevatedButton.icon(
              onPressed: () => _controller.navigateToSubscription(context),
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    isDark ? Colors.grey.shade700 : Colors.grey.shade800,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              icon: const Icon(Icons.settings_outlined, size: 18),
              label: const Text(
                'Gerenciar Assinatura',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoSubscriptionCard(BuildContext context, bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Header com ícone premium
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.amber.shade400,
                  Colors.amber.shade600,
                ],
              ),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.star,
              color: Colors.white,
              size: 30,
            ),
          ),
          const SizedBox(height: 16),

          Text(
            'GasOMeter Premium',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Desbloqueie recursos avançados e tenha a melhor experiência',
            style: TextStyle(
              fontSize: 14,
              color: isDark ? Colors.grey.shade300 : Colors.grey.shade600,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),

          // Lista de benefícios
          ...(_controller.model.premiumFeatures.take(3).map(
                (feature) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.amber.shade400.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          feature.icon,
                          size: 16,
                          color: Colors.amber.shade600,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              feature.title,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: isDark ? Colors.white : Colors.black87,
                              ),
                            ),
                            Text(
                              feature.description,
                              style: TextStyle(
                                fontSize: 12,
                                color: isDark
                                    ? Colors.grey.shade400
                                    : Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              )),

          const SizedBox(height: 20),

          // Botão de assinatura
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              onPressed: () => _controller.navigateToSubscription(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber.shade600,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              icon: const Icon(Icons.star, size: 20),
              label: const Text(
                'Assinar Premium',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  Widget _buildSection(
      BuildContext context, SettingsSection section, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Título da seção
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 16, 12, 6),
          child: Text(
            section.title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.grey.shade300 : Colors.grey.shade700,
            ),
          ),
        ),

        // Card com itens da seção
        Card(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
              width: 0.5,
            ),
          ),
          color: isDark ? const Color(0xFF16213E) : Colors.white,
          child: Column(
            children: section.items
                .asMap()
                .entries
                .map((entry) => _buildListItem(
                      context,
                      entry.value,
                      isDark,
                      isLast: entry.key == section.items.length - 1,
                    ))
                .toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildListItem(BuildContext context, SettingsItem item, bool isDark,
      {bool isLast = false}) {
    return Column(
      children: [
        ListTile(
          leading: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: (isDark ? Colors.amber.shade600 : Colors.grey.shade600)
                  .withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              item.icon,
              color: isDark ? Colors.amber.shade400 : Colors.grey.shade600,
              size: 18,
            ),
          ),
          title: Text(
            item.title,
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          subtitle: Text(
            item.subtitle,
            style: TextStyle(
              color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
              fontSize: 12,
            ),
          ),
          trailing: _buildItemTrailing(item, isDark),
          onTap: () => _handleItemTap(context, item),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        if (!isLast)
          Divider(
            height: 1,
            indent: 60,
            endIndent: 12,
            color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
          ),
      ],
    );
  }

  Widget? _buildItemTrailing(SettingsItem item, bool isDark) {
    switch (item.type) {
      case SettingsItemType.theme:
        return Icon(
          isDark ? Icons.dark_mode : Icons.light_mode,
          size: 20,
          color: isDark ? Colors.amber.shade400 : Colors.grey.shade600,
        );

      case SettingsItemType.notifications:
        return Switch(
          value: _controller.model.notificationsEnabled,
          onChanged: (value) => _controller.toggleNotifications(),
          activeColor: isDark ? Colors.amber.shade400 : Colors.grey.shade600,
        );

      case SettingsItemType.autoSync:
        return Switch(
          value: _controller.model.autoSyncEnabled,
          onChanged: (value) => _controller.toggleAutoSync(),
          activeColor: isDark ? Colors.amber.shade400 : Colors.grey.shade600,
        );

      case SettingsItemType.logout:
        return Icon(
          Icons.logout,
          size: 20,
          color: Colors.red.shade400,
        );

      default:
        return Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: isDark ? Colors.grey.shade500 : Colors.grey.shade400,
        );
    }
  }

  void _handleItemTap(BuildContext context, SettingsItem item) {
    switch (item.type) {
      case SettingsItemType.navigation:
        final route = item.data?['route'];
        if (route != null) {
          Navigator.pushNamed(context, route);
        }
        break;

      case SettingsItemType.theme:
        _controller.toggleTheme();
        break;

      case SettingsItemType.language:
        _controller.showLanguageSelector(context);
        break;

      case SettingsItemType.currency:
        _controller.showCurrencySelector(context);
        break;

      case SettingsItemType.notifications:
        _controller.toggleNotifications();
        break;

      case SettingsItemType.autoSync:
        _controller.toggleAutoSync();
        break;

      case SettingsItemType.backup:
        _controller.performBackup();
        break;

      case SettingsItemType.export:
        _controller.exportData();
        break;

      case SettingsItemType.subscription:
        _controller.navigateToSubscription(context);
        break;

      case SettingsItemType.restore:
        _controller.restorePurchases();
        break;

      case SettingsItemType.help:
        _controller.navigateToHelp(context);
        break;

      case SettingsItemType.contact:
        _controller.openContactEmail();
        break;

      case SettingsItemType.bugReport:
        _controller.openBugReport();
        break;

      case SettingsItemType.about:
        _controller.navigateToAbout(context);
        break;

      case SettingsItemType.privacy:
        _controller.navigateToPrivacy(context);
        break;

      case SettingsItemType.terms:
        _controller.navigateToTerms(context);
        break;

      case SettingsItemType.logout:
        _showLogoutConfirmation(context);
        break;

      case SettingsItemType.login:
        _controller.navigateToLogin(context);
        break;

      case SettingsItemType.sync:
        _controller.syncData();
        break;

      case SettingsItemType.deleteAccount:
        _controller.showDeleteAccountConfirmation(context);
        break;

      case SettingsItemType.simulateData:
        _controller.simulateTestData(context);
        break;

      case SettingsItemType.removeData:
        _controller.removeAllData(context);
        break;

      case SettingsItemType.databaseInspector:
        _controller.navigateToDatabaseInspector(context);
        break;

      case SettingsItemType.appRating:
        _controller.handleAppRating();
        break;

      default:
        break;
    }
  }

  void _showLogoutConfirmation(BuildContext context) {
    final isDark = ThemeManager().isDark.value;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF16213E) : Colors.white,
        title: Text(
          'Confirmar Logout',
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        content: Text(
          'Tem certeza de que deseja sair da sua conta?',
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
              _controller.logout(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade600,
              foregroundColor: Colors.white,
            ),
            child: const Text('Sair'),
          ),
        ],
      ),
    );
  }

  Widget _buildExitModuleButton(BuildContext context, bool isDark) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
          width: 0.5,
        ),
      ),
      color: isDark ? const Color(0xFF16213E) : Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton.icon(
            onPressed: () => _showExitModuleConfirmation(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade600,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
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

  void _showExitModuleConfirmation(BuildContext context) {
    final isDark = ThemeManager().isDark.value;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF16213E) : Colors.white,
        title: Text(
          'Sair do Módulo',
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        content: Text(
          'Tem certeza de que deseja sair do GasOMeter e retornar ao menu principal?',
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
              _exitModule(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade600,
              foregroundColor: Colors.white,
            ),
            child: const Text('Sair'),
          ),
        ],
      ),
    );
  }

  void _exitModule(BuildContext context) {
    Navigator.pushNamedAndRemoveUntil(
      context,
      '/app-select',
      (route) => false,
    );
  }

  Widget _buildCopyright(bool isDark) {
    return const SizedBox.shrink();
  }
}
