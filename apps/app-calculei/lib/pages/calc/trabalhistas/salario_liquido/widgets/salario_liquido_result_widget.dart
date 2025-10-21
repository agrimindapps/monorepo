// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:app_calculei/core/style/shadcn_style.dart';
import 'package:app_calculei/core/themes/manager.dart';
import 'package:app_calculei/pages/calc/trabalhistas/salario_liquido/widgets/controllers/salario_liquido_controller.dart';
import 'package:app_calculei/services/formatting_service.dart';

class SalarioLiquidoResultWidget extends StatelessWidget {
  final SalarioLiquidoController controller;
  
  const SalarioLiquidoResultWidget({
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
                  'Resultado do Cálculo',
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
            
            // Salário Bruto
            _buildResultRow(
              'Salário Bruto',
              formatter.formatCurrency(model.salarioBruto),
              Icons.attach_money,
              Colors.blue,
              isDark,
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
            
            if (model.descontoValeTransporte > 0)
              _buildResultRow(
                'Vale Transporte',
                formatter.formatCurrency(model.descontoValeTransporte),
                Icons.directions_bus,
                Colors.purple,
                isDark,
                isDiscount: true,
              ),
            
            if (model.planoSaude > 0)
              _buildResultRow(
                'Plano de Saúde',
                formatter.formatCurrency(model.planoSaude),
                Icons.local_hospital,
                Colors.teal,
                isDark,
                isDiscount: true,
              ),
            
            if (model.outrosDescontos > 0)
              _buildResultRow(
                'Outros Descontos',
                formatter.formatCurrency(model.outrosDescontos),
                Icons.remove_circle_outline,
                Colors.brown,
                isDark,
                isDiscount: true,
              ),
            
            const SizedBox(height: 8),
            
            _buildResultRow(
              'Total de Descontos',
              formatter.formatCurrency(model.totalDescontos),
              Icons.remove,
              Colors.red,
              isDark,
              isDiscount: true,
              isBold: true,
            ),
            
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 8),
            
            // Salário Líquido
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
                        'Salário Líquido',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    formatter.formatCurrency(model.salarioLiquido),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
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
