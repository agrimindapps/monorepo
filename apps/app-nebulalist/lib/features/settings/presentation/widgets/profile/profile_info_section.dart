import 'package:flutter/material.dart';

import '../../../../auth/data/models/user_model.dart';

/// Section displaying user account information
class ProfileInfoSection extends StatelessWidget {
  final UserModel? user;

  const ProfileInfoSection({
    super.key,
    this.user,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(context, 'Informações da Conta'),
        const SizedBox(height: 8),
        Card(
          elevation: isDark ? 0 : 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildInfoItem(
                  context,
                  Icons.email_outlined,
                  'Email',
                  user?.email ?? 'Não disponível',
                ),
                const Divider(height: 24),
                _buildInfoItem(
                  context,
                  Icons.calendar_today_outlined,
                  'Membro desde',
                  _formatMemberSince(user?.createdAt),
                ),
                const Divider(height: 24),
                _buildInfoItem(
                  context,
                  Icons.verified_user_outlined,
                  'Status da conta',
                  user?.isEmailVerified == true ? 'Verificado' : 'Não verificado',
                  statusColor: user?.isEmailVerified == true
                      ? Colors.green
                      : Colors.orange,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor,
            ),
      ),
    );
  }

  Widget _buildInfoItem(
    BuildContext context,
    IconData icon,
    String label,
    String value, {
    Color? statusColor,
  }) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: (statusColor ?? theme.primaryColor).withAlpha(26),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: 20,
            color: statusColor ?? theme.primaryColor,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: statusColor,
                ),
              ),
            ],
          ),
        ),
        if (statusColor != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor.withAlpha(26),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              statusColor == Colors.green ? Icons.check_circle : Icons.warning_amber,
              size: 16,
              color: statusColor,
            ),
          ),
      ],
    );
  }

  String _formatMemberSince(DateTime? date) {
    if (date == null) return 'Não disponível';
    final months = [
      'Janeiro',
      'Fevereiro',
      'Março',
      'Abril',
      'Maio',
      'Junho',
      'Julho',
      'Agosto',
      'Setembro',
      'Outubro',
      'Novembro',
      'Dezembro',
    ];
    return '${months[date.month - 1]} de ${date.year}';
  }
}
