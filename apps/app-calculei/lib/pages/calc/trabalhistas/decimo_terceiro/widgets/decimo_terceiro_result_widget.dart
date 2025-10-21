// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:app_calculei/core/style/shadcn_style.dart';
import 'package:app_calculei/core/themes/manager.dart';
import 'package:app_calculei/pages/calc/trabalhistas/decimo_terceiro/widgets/controllers/decimo_terceiro_controller.dart';
import 'package:app_calculei/services/formatting_service.dart';

class DecimoTerceiroResultWidget extends StatelessWidget {
  final DecimoTerceiroController controller;
  
  const DecimoTerceiroResultWidget({
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
                  'Resultado do Décimo Terceiro',
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
              'Período considerado',
              '${formatter.formatDate(model.dataAdmissao)} até ${formatter.formatDate(model.dataCalculo)}',
              Icons.date_range,
              Colors.blue,
              isDark,
            ),
            
            _buildInfoRow(
              'Meses trabalhados',
              '${formatter.formatMeses(model.mesesConsiderados)} de ${model.mesesTrabalhados}',
              Icons.work,
              Colors.purple,
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
              'Salário Bruto Mensal',
              formatter.formatCurrency(model.salarioBruto),
              Icons.attach_money,
              Colors.blue,
              isDark,
            ),
            
            _buildResultRow(
              'Valor por Mês',
              formatter.formatCurrency(model.valorPorMes),
              Icons.calculate,
              Colors.green,
              isDark,
            ),
            
            _buildResultRow(
              'Décimo Terceiro Bruto',
              formatter.formatCurrency(model.decimoTerceiroBruto),
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
            
            // Resultado final
            if (model.antecipacao) ...[
              // Antecipação
              Text(
                'Antecipação (duas parcelas)',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: ShadcnStyle.textColor,
                ),
              ),
              const SizedBox(height: 8),
              
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.looks_one, color: Colors.blue),
                            const SizedBox(width: 8),
                            Text(
                              '1ª Parcela (novembro)',
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                color: ShadcnStyle.textColor,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          formatter.formatCurrency(model.primeiraParcela),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.looks_two, color: Colors.blue),
                            const SizedBox(width: 8),
                            Text(
                              '2ª Parcela (dezembro)',
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                color: ShadcnStyle.textColor,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          formatter.formatCurrency(model.segundaParcela),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 16),
            ],
            
            // Valor líquido total
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
                      Icon(Icons.monetization_on, color: Colors.green),
                      SizedBox(width: 8),
                      Text(
                        'Décimo Terceiro Líquido',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    formatter.formatCurrency(model.decimoTerceiroLiquido),
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
