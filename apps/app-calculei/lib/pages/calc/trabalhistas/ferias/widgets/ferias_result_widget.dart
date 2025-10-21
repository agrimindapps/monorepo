// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:app_calculei/core/style/shadcn_style.dart';
import 'package:app_calculei/core/themes/manager.dart';
import 'package:app_calculei/pages/calc/trabalhistas/ferias/widgets/controllers/ferias_controller.dart';
import 'package:app_calculei/services/formatting_service.dart';

class FeriasResultWidget extends StatelessWidget {
  final FeriasController controller;
  
  const FeriasResultWidget({
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
                  'Resultado das Férias',
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
            
            // Informações do período
            _buildInfoRow(
              'Período aquisitivo',
              formatter.formatPeriodo(model.inicioAquisitivo, model.fimAquisitivo),
              Icons.date_range,
              Colors.blue,
              isDark,
            ),
            
            _buildInfoRow(
              'Direito às férias',
              formatter.formatDireitoFerias(model.diasDireito),
              Icons.beach_access,
              Colors.green,
              isDark,
            ),
            
            if (model.faltasNaoJustificadas > 0)
              _buildInfoRow(
                'Faltas não justificadas',
                formatter.formatFaltas(model.faltasNaoJustificadas),
                Icons.cancel,
                Colors.orange,
                isDark,
              ),
            
            const SizedBox(height: 16),
            
            // Divisão das férias
            Text(
              'Divisão das Férias',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: ShadcnStyle.textColor,
              ),
            ),
            const SizedBox(height: 8),
            
            _buildResultRow(
              'Dias para gozo',
              formatter.formatDias(model.diasGozados),
              Icons.beach_access,
              Colors.blue,
              isDark,
            ),
            
            if (model.diasVendidos > 0)
              _buildResultRow(
                'Dias vendidos (abono pecuniário)',
                formatter.formatDias(model.diasVendidos),
                Icons.monetization_on,
                Colors.purple,
                isDark,
              ),
            
            const SizedBox(height: 16),
            
            // Cálculo base
            Text(
              'Cálculo Base',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: ShadcnStyle.textColor,
              ),
            ),
            const SizedBox(height: 8),
            
            _buildResultRow(
              'Salário bruto mensal',
              formatter.formatCurrency(model.salarioBruto),
              Icons.attach_money,
              Colors.blue,
              isDark,
            ),
            
            _buildResultRow(
              'Valor por dia',
              formatter.formatCurrency(model.valorDia),
              Icons.calculate,
              Colors.green,
              isDark,
            ),
            
            const SizedBox(height: 16),
            
            // Valores das férias
            Text(
              'Valores das Férias',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: ShadcnStyle.textColor,
              ),
            ),
            const SizedBox(height: 8),
            
            _buildResultRow(
              'Férias proporcionais',
              formatter.formatCurrency(model.feriasProporcionais),
              Icons.beach_access,
              Colors.blue,
              isDark,
            ),
            
            _buildResultRow(
              'Abono constitucional (1/3)',
              formatter.formatCurrency(model.abonoConstitucional),
              Icons.add_circle,
              Colors.green,
              isDark,
            ),
            
            if (model.abonoPecuniarioValor > 0)
              _buildResultRow(
                'Abono pecuniário (venda)',
                formatter.formatCurrency(model.abonoPecuniarioValor),
                Icons.monetization_on,
                Colors.purple,
                isDark,
              ),
            
            const SizedBox(height: 8),
            
            _buildResultRow(
              'Total bruto',
              formatter.formatCurrency(model.feriasBruto),
              Icons.account_balance_wallet,
              Colors.indigo,
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
            
            // Valor líquido final
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
                      Icon(Icons.wallet, color: Colors.green),
                      SizedBox(width: 8),
                      Text(
                        'Férias Líquidas',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    formatter.formatCurrency(model.feriasLiquido),
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
            
            // Resumo final
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
                      Icon(Icons.info_outline, color: Colors.blue, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Resumo das Férias',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Período de ${formatter.formatDias(model.diasGozados)} de gozo${model.diasVendidos > 0 
                        ? ' + ${formatter.formatDias(model.diasVendidos)} vendidos'
                        : ''} = ${formatter.formatCurrency(model.feriasLiquido)} líquidos',
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
