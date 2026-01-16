import 'package:core/core.dart' show FirebaseAuth;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../widgets/admin_guard.dart';

/// Dashboard administrativo principal
///
/// Gerencia:
/// - Bovinos públicos
/// - Equinos públicos
/// - Estatísticas gerais
/// - Acesso rápido às funcionalidades
/// 
/// **Protegido por AdminGuard** - valida role de admin
class AdminDashboardPage extends ConsumerStatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  ConsumerState<AdminDashboardPage> createState() =>
      _AdminDashboardPageState();
}

class _AdminDashboardPageState extends ConsumerState<AdminDashboardPage> {
  static const _primaryColor = Color(0xFF4CAF50); // Green
  static const _cardColor = Color(0xFF252545);

  @override
  Widget build(BuildContext context) {
    // Proteção em múltiplas camadas:
    // 1. Router redirect (app_router.dart)
    // 2. AdminGuard widget (verifica role aqui)
    // 3. Firestore rules (backend validation)
    return AdminGuard(
      child: _buildDashboard(context),
    );
  }

  Widget _buildDashboard(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF1A1A2E) : Colors.grey.shade100,
      appBar: AppBar(
        title: const Text('Painel Administrativo - AgriHurbi'),
        backgroundColor: _primaryColor,
        foregroundColor: Colors.white,
        actions: [
          // User info
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Icon(Icons.person, color: Colors.white.withOpacity(0.8)),
                const SizedBox(width: 8),
                Text(
                  user?.email ?? 'Admin',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),

          // Logout
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Sair',
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              if (context.mounted) {
                context.go('/admin');
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome header
            Text(
              'Bem-vindo ao Painel Administrativo',
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black87,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Gerencie dados públicos de bovinos e equinos',
              style: TextStyle(
                color: isDark ? Colors.white60 : Colors.black54,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 32),

            // Stats Overview
            _buildStatsSection(isDark),

            const SizedBox(height: 32),

            // Quick Actions
            _buildQuickActionsSection(isDark),

            const SizedBox(height: 32),

            // Recent Activity (placeholder)
            _buildRecentActivitySection(isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsSection(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Estatísticas',
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black87,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        LayoutBuilder(
          builder: (context, constraints) {
            final crossAxisCount = constraints.maxWidth > 900
                ? 4
                : (constraints.maxWidth > 600 ? 2 : 1);

            return GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.5,
              children: [
                _buildStatCard(
                  title: 'Bovinos',
                  value: '0',
                  icon: Icons.agriculture,
                  color: Colors.brown,
                  isDark: isDark,
                ),
                _buildStatCard(
                  title: 'Equinos',
                  value: '0',
                  icon: Icons.pets, // Using pets icon for horses
                  color: Colors.deepOrange,
                  isDark: isDark,
                ),
                _buildStatCard(
                  title: 'Total de Dados',
                  value: '0',
                  icon: Icons.storage,
                  color: Colors.blue,
                  isDark: isDark,
                ),
                _buildStatCard(
                  title: 'Última Atualização',
                  value: 'Hoje',
                  icon: Icons.update,
                  color: Colors.teal,
                  isDark: isDark,
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? _cardColor : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: color, size: 32),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.trending_up, color: color, size: 16),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black87,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              color: isDark ? Colors.white60 : Colors.black54,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionsSection(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Ações Rápidas',
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black87,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [
            _buildActionCard(
              title: 'Gerenciar Bovinos',
              subtitle: 'Adicionar, editar ou remover dados',
              icon: Icons.agriculture,
              color: Colors.brown,
              isDark: isDark,
              onTap: () => context.go('/admin/bovines'),
            ),
            _buildActionCard(
              title: 'Gerenciar Equinos',
              subtitle: 'Adicionar, editar ou remover dados',
              icon: Icons.pets, // Using pets icon for horses
              color: Colors.deepOrange,
              isDark: isDark,
              onTap: () => context.go('/admin/equines'),
            ),
            _buildActionCard(
              title: 'Importar Dados',
              subtitle: 'Upload em lote via CSV/Excel',
              icon: Icons.upload_file,
              color: Colors.blue,
              isDark: isDark,
              onTap: () {
                // TODO: Implement
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Em desenvolvimento')),
                );
              },
            ),
            _buildActionCard(
              title: 'Exportar Dados',
              subtitle: 'Download dos dados em CSV',
              icon: Icons.download,
              color: Colors.green,
              isDark: isDark,
              onTap: () {
                // TODO: Implement
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Em desenvolvimento')),
                );
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 280,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDark ? _cardColor : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(
            color: color.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 32),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black87,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: isDark ? Colors.white60 : Colors.black54,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: isDark ? Colors.white30 : Colors.black26,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentActivitySection(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Atividade Recente',
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black87,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: isDark ? _cardColor : Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Center(
            child: Column(
              children: [
                Icon(
                  Icons.timeline,
                  size: 48,
                  color: isDark ? Colors.white30 : Colors.black26,
                ),
                const SizedBox(height: 16),
                Text(
                  'Nenhuma atividade recente',
                  style: TextStyle(
                    color: isDark ? Colors.white60 : Colors.black54,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
