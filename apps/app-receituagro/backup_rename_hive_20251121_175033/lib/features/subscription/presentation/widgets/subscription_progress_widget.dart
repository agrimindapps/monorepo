import 'package:flutter/material.dart';

/// Widget de progresso de assinatura
///
/// Exibe:
/// - Barra de progresso colorida (verde → laranja → vermelho)
/// - Dias restantes da assinatura
/// - Percentual de tempo usado
/// - Badge "ATIVA" ou "TESTE" (se sandbox)
/// - Período de validade (data início - data fim)
///
/// Inspirado no layout do app legado fReceituagro
class SubscriptionProgressWidget extends StatelessWidget {
  const SubscriptionProgressWidget({
    required this.expirationDate,
    required this.purchaseDate,
    this.isSandbox = false,
    this.isCompact = false,
    super.key,
  });

  /// Data de expiração da assinatura
  final DateTime expirationDate;

  /// Data de compra/início da assinatura
  final DateTime? purchaseDate;

  /// Se é assinatura de teste (sandbox)
  final bool isSandbox;

  /// Modo compacto (para usar em ProfilePage)
  final bool isCompact;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final daysRemaining = expirationDate.difference(now).inDays;
    final totalDays = purchaseDate != null
        ? expirationDate.difference(purchaseDate!).inDays
        : 365; // Assume 1 ano se não tiver data de compra

    // Calcula percentual de tempo RESTANTE (não usado)
    final percentComplete = totalDays > 0
        ? ((daysRemaining / totalDays) * 100).clamp(0.0, 100.0)
        : 0.0;

    // Determina cor baseada no percentual restante
    final progressColor = _getProgressColor(percentComplete);

    if (isCompact) {
      return _buildCompactView(
        context,
        daysRemaining,
        percentComplete,
        progressColor,
      );
    }

    return _buildFullView(
      context,
      daysRemaining,
      percentComplete,
      progressColor,
    );
  }

  /// View completa para SubscriptionStatusWidget
  Widget _buildFullView(
    BuildContext context,
    int daysRemaining,
    double percentComplete,
    Color progressColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: progressColor.withValues(alpha: 0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Título com badges
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Sua Assinatura',
                style: TextStyle(
                  color: Colors.black87,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Row(
                children: [
                  if (isSandbox) ...[
                    _buildBadge(
                      label: 'TESTE',
                      color: Colors.orange,
                      icon: Icons.bug_report,
                    ),
                    const SizedBox(width: 6),
                  ],
                  _buildBadge(
                    label: 'ATIVA',
                    color: progressColor,
                    icon: Icons.check_circle,
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Barra de progresso
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: percentComplete / 100,
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation<Color>(progressColor),
              minHeight: 8,
            ),
          ),

          const SizedBox(height: 12),

          // Informações de dias restantes e percentual
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.event_available,
                    size: 16,
                    color: progressColor,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    _formatDaysRemaining(daysRemaining),
                    style: TextStyle(
                      color: progressColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              Text(
                '${percentComplete.toInt()}% restante',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Período de validade
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Colors.grey.shade200,
                width: 1,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Início',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _formatDate(purchaseDate ?? expirationDate),
                      style: const TextStyle(
                        color: Colors.black87,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                Icon(
                  Icons.arrow_forward,
                  size: 16,
                  color: Colors.grey.shade400,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Renovação',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _formatDate(expirationDate),
                      style: const TextStyle(
                        color: Colors.black87,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// View compacta para ProfilePage
  Widget _buildCompactView(
    BuildContext context,
    int daysRemaining,
    double percentComplete,
    Color progressColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: progressColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: progressColor.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.workspace_premium,
            color: progressColor,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Assinatura Premium',
                  style: TextStyle(
                    color: progressColor,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _formatDaysRemaining(daysRemaining),
                  style: TextStyle(
                    color: Colors.grey.shade700,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${percentComplete.toInt()}%',
            style: TextStyle(
              color: progressColor,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  /// Badge de status
  Widget _buildBadge({
    required String label,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 12,
            color: color,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  /// Determina cor baseada no percentual restante
  Color _getProgressColor(double percentComplete) {
    if (percentComplete > 50) {
      return const Color(0xFF4CAF50); // Verde
    } else if (percentComplete > 20) {
      return Colors.orange; // Laranja
    } else {
      return const Color(0xFFF44336); // Vermelho
    }
  }

  /// Formata dias restantes
  String _formatDaysRemaining(int days) {
    if (days < 0) {
      return 'Expirada';
    } else if (days == 0) {
      return 'Expira hoje';
    } else if (days == 1) {
      return '1 dia restante';
    } else if (days < 30) {
      return '$days dias restantes';
    } else if (days < 365) {
      final months = (days / 30).floor();
      return '$months ${months == 1 ? 'mês' : 'meses'} restantes';
    } else {
      final years = (days / 365).floor();
      return '$years ${years == 1 ? 'ano' : 'anos'} restantes';
    }
  }

  /// Formata data para dd/MM/yyyy
  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}
