import 'package:flutter/material.dart';

import '../../../../core/widgets/semantic_widgets.dart';
import '../../domain/models/dashboard_indicator.dart';

/// Dashboard indicator detail page
class DashboardIndicatorDetailPage extends StatelessWidget {
  const DashboardIndicatorDetailPage({
    required this.indicatorId,
    super.key,
  });

  final String indicatorId;

  @override
  Widget build(BuildContext context) {
    final indicator = DashboardIndicatorDatabase.getById(indicatorId);

    if (indicator == null) {
      return Scaffold(
        body: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                Text(
                  'Indicador não encontrado',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Voltar'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context, indicator),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildMainCard(indicator),
                    const SizedBox(height: 16),
                    _buildWhatToDoCard(indicator),
                    if (indicator.possibleCauses != null) ...[
                      const SizedBox(height: 16),
                      _buildPossibleCausesCard(indicator),
                    ],
                    if (indicator.relatedSystems != null) ...[
                      const SizedBox(height: 16),
                      _buildRelatedSystemsCard(indicator),
                    ],
                    const SizedBox(height: 16),
                    _buildSafetyWarning(indicator),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, DashboardIndicator indicator) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
      child: Container(
        margin: const EdgeInsets.fromLTRB(0, 0, 0, 0),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        decoration: BoxDecoration(
          color: indicator.color,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: indicator.color.withValues(alpha: 0.3),
              blurRadius: 9,
              offset: const Offset(0, 3),
              spreadRadius: 0,
            ),
          ],
        ),
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.of(context).pop(),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.all(9),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(9),
              ),
              child: Icon(
                indicator.icon,
                color: Colors.white,
                size: 19,
              ),
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  SemanticText.heading(
                    indicator.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 3),
                  SemanticText.subtitle(
                    indicator.severityLabel,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                      height: 1.2,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainCard(DashboardIndicator indicator) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: indicator.color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: indicator.color.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: indicator.color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
              border: Border.all(
                color: indicator.color.withValues(alpha: 0.3),
                width: 3,
              ),
            ),
            child: Icon(
              indicator.icon,
              color: indicator.color,
              size: 40,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            indicator.description,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade800,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Divider(color: indicator.color.withValues(alpha: 0.2)),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Column(
                children: [
                  Icon(
                    indicator.canDrive ? Icons.check_circle : Icons.cancel,
                    size: 32,
                    color: indicator.canDrive ? Colors.green : Colors.red,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    indicator.canDrive ? 'Pode Dirigir' : 'Não Dirija',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: indicator.canDrive ? Colors.green : Colors.red,
                    ),
                  ),
                  Text(
                    indicator.canDrive ? 'Com cuidado' : 'Pare agora',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
              Container(
                width: 1,
                height: 60,
                color: indicator.color.withValues(alpha: 0.2),
              ),
              Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: indicator.severityColor.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      indicator.severity == IndicatorSeverity.critical
                          ? Icons.error
                          : indicator.severity == IndicatorSeverity.warning
                              ? Icons.warning
                              : Icons.info,
                      color: indicator.severityColor,
                      size: 24,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    indicator.severityLabel,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: indicator.severityColor,
                    ),
                  ),
                  Text(
                    _getSeveritySubtitle(indicator.severity),
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWhatToDoCard(DashboardIndicator indicator) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.help_outline, color: Colors.blue.shade700, size: 24),
              const SizedBox(width: 12),
              const Text(
                'O que fazer?',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            indicator.whatToDo,
            style: TextStyle(
              fontSize: 15,
              color: Colors.grey.shade800,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPossibleCausesCard(DashboardIndicator indicator) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.orange.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.list_alt, color: Colors.orange.shade700, size: 24),
              const SizedBox(width: 12),
              const Text(
                'Possíveis Causas',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...indicator.possibleCauses!.map((cause) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.check_circle_outline,
                    size: 20,
                    color: Colors.orange.shade700,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      cause,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade800,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildRelatedSystemsCard(DashboardIndicator indicator) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.purple.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.purple.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.settings, color: Colors.purple.shade700, size: 24),
              const SizedBox(width: 12),
              const Text(
                'Sistemas Relacionados',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: indicator.relatedSystems!.map((system) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.purple.shade100,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.purple.shade300),
                ),
                child: Text(
                  system,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.purple.shade900,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSafetyWarning(DashboardIndicator indicator) {
    if (indicator.severity != IndicatorSeverity.critical) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.red.shade300, width: 2),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.warning, color: Colors.red.shade700, size: 28),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'ATENÇÃO - RISCO CRÍTICO',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Este indicador representa um problema grave que pode causar '
            'danos ao veículo ou riscos à sua segurança. Siga rigorosamente '
            'as orientações acima.',
            style: TextStyle(
              fontSize: 14,
              color: Colors.red.shade900,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  String _getSeveritySubtitle(IndicatorSeverity severity) {
    switch (severity) {
      case IndicatorSeverity.critical:
        return 'Urgente';
      case IndicatorSeverity.warning:
        return 'Importante';
      case IndicatorSeverity.information:
        return 'Normal';
    }
  }
}
