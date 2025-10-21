// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:app_calculei/core/style/shadcn_style.dart';
import 'package:app_calculei/core/themes/manager.dart';
import 'package:app_calculei/pages/calc/trabalhistas/horas_extras/widgets/controllers/horas_extras_controller.dart';
import 'package:app_calculei/services/formatting_service.dart';

class HorasExtrasResultWidget extends StatelessWidget {
  final HorasExtrasController controller;
  
  const HorasExtrasResultWidget({
    super.key,
    required this.controller,
  });
  
  @override
  Widget build(BuildContext context) {
    final model = controller.model;
    if (model == null) return const SizedBox.shrink();
    
    final isDark = ThemeManager().isDark.value;
    final formatter = FormattingService();
    
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Resultado das Horas Extras',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: ShadcnStyle.textColor,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.share),
                  onPressed: () {
                    // TODO: Implementar compartilhamento
                  },
                ),
              ],
            ),
            
            const Divider(),
            
            // Informações básicas
            _buildInfoRow(
              'Jornada semanal',
              formatter.formatJornada(model.horasSemanais),
              Icons.schedule,
              Colors.blue,
              isDark,
            ),
            
            _buildInfoRow(
              'Horas trabalhadas/mês',
              formatter.formatHoursDecimal(model.horasTrabalhadasMes),
              Icons.work,
              Colors.green,
              isDark,
            ),
            
            _buildInfoRow(
              'Valor hora normal',
              formatter.formatCurrency(model.valorHoraNormal),
              Icons.attach_money,
              Colors.purple,
              isDark,
            ),
            
            const SizedBox(height: 16),
            
            // Horas Extras
            if (model.horasExtrasMes > 0) ...[
              Text(
                'Horas Extras Trabalhadas',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: ShadcnStyle.textColor,
                ),
              ),
              const SizedBox(height: 8),
              
              if (model.horas50 > 0)
                _buildResultRow(
                  'Horas extras 50% (${formatter.formatHoursDecimal(model.horas50)}h)',
                  formatter.formatCurrency(model.totalHoras50),
                  Icons.add_circle_outline,
                  Colors.orange,
                  isDark,
                ),
              
              if (model.horas100 > 0)
                _buildResultRow(
                  'Horas extras 100% (${formatter.formatHoursDecimal(model.horas100)}h)',
                  formatter.formatCurrency(model.totalHoras100),
                  Icons.add_circle,
                  Colors.red,
                  isDark,
                ),
              
              _buildResultRow(
                'Total horas extras',
                formatter.formatCurrency(model.totalHorasExtras),
                Icons.schedule,
                Colors.indigo,
                isDark,
                isBold: true,
              ),
              
              const SizedBox(height: 16),
            ],
            
            // Adicionais Especiais
            if (model.horasNoturnas > 0 || model.horasDomingoFeriado > 0) ...[
              Text(
                'Adicionais Especiais',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: ShadcnStyle.textColor,
                ),
              ),
              const SizedBox(height: 8),
              
              if (model.horasNoturnas > 0)
                _buildResultRow(
                  'Adicional noturno (${formatter.formatHoursDecimal(model.horasNoturnas)}h)',
                  formatter.formatCurrency(model.totalAdicionalNoturno),
                  Icons.nights_stay,
                  Colors.indigo,
                  isDark,
                ),
              
              if (model.horasDomingoFeriado > 0)
                _buildResultRow(
                  'Domingo/Feriado (${formatter.formatHoursDecimal(model.horasDomingoFeriado)}h)',
                  formatter.formatCurrency(model.totalDomingoFeriado),
                  Icons.weekend,
                  Colors.purple,
                  isDark,
                ),
              
              const SizedBox(height: 16),
            ],
            
            // Reflexos
            if (model.totalHorasExtras > 0) ...[
              Text(
                'Reflexos das Horas Extras',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: ShadcnStyle.textColor,
                ),
              ),
              const SizedBox(height: 8),
              
              _buildResultRow(
                'DSR sobre horas extras',
                formatter.formatCurrency(model.dsrSobreExtras),
                Icons.weekend,
                Colors.teal,
                isDark,
              ),
              
              _buildResultRow(
                'Reflexo nas férias',
                formatter.formatCurrency(model.reflexoFerias),
                Icons.beach_access,
                Colors.cyan,
                isDark,
              ),
              
              _buildResultRow(
                'Reflexo no 13º salário',
                formatter.formatCurrency(model.reflexoDecimoTerceiro),
                Icons.card_giftcard,
                Colors.amber,
                isDark,
              ),
              
              const SizedBox(height: 16),
            ],
            
            // Resumo financeiro
            Text(
              'Resumo Financeiro',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: ShadcnStyle.textColor,
              ),
            ),
            const SizedBox(height: 8),
            
            _buildResultRow(
              'Salário base',
              formatter.formatCurrency(model.salarioBruto),
              Icons.attach_money,
              Colors.blue,
              isDark,
            ),
            
            _buildResultRow(
              'Total bruto',
              formatter.formatCurrency(model.totalBruto),
              Icons.account_balance_wallet,
              Colors.green,
              isDark,
              isBold: true,
            ),
            
            const SizedBox(height: 16),
            
            // Descontos
            Text(
              'Descontos',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: ShadcnStyle.textColor,
              ),
            ),
            const SizedBox(height: 8),
            
            _buildResultRow(
              'INSS (${formatter.formatPercent(model.aliquotaInss)})',
              formatter.formatCurrency(model.descontoInss),
              Icons.account_balance,
              Colors.orange,
              isDark,
              isDiscount: true,
            ),
            
            if (model.descontoIrrf > 0)
              _buildResultRow(
                'IRRF (${formatter.formatPercent(model.aliquotaIrrf)})',
                formatter.formatCurrency(model.descontoIrrf),
                Icons.description,
                Colors.red,
                isDark,
                isDiscount: true,
              ),
            
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 8),
            
            // Total líquido
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.account_balance_wallet, color: Colors.green),
                      SizedBox(width: 8),
                      Text(
                        'Total Líquido',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    formatter.formatCurrency(model.totalLiquido),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Análise de impacto
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.trending_up, color: Colors.blue, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Análise de Impacto',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Aumento de ${formatter.formatCurrency(model.totalLiquido - model.salarioBruto)} ' '(${((model.totalLiquido - model.salarioBruto) / model.salarioBruto * 100).toStringAsFixed(1)}%) ' 'em relação ao salário base',
                    style: TextStyle(
                      color: ShadcnStyle.textColor,
                      fontSize: 14,
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
  
  Widget _buildInfoRow(
    String label,
    String value,
    IconData icon,
    Color color,
    bool isDark,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 18),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: ShadcnStyle.textColor,
                ),
              ),
            ],
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: ShadcnStyle.textColor,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildResultRow(
    String label,
    String value,
    IconData icon,
    Color color,
    bool isDark, {
    bool isDiscount = false,
    bool isBold = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 18),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
                  color: ShadcnStyle.textColor,
                ),
              ),
            ],
          ),
          Text(
            isDiscount ? '- $value' : value,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
